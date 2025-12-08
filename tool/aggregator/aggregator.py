import json
import os
import re
import ssl
import time
from collections import deque
from datetime import datetime, timedelta

import paho.mqtt.client as mqtt
from dotenv import load_dotenv
import pytz

# ------------------ Config ------------------
load_dotenv()

MQTT_HOST = os.getenv("MQTT_HOST", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USERNAME = os.getenv("MQTT_USERNAME")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD")
MQTT_CLIENT_ID = os.getenv("MQTT_CLIENT_ID", "pakebun-aggregator")
MQTT_TLS = os.getenv("MQTT_TLS", "false").lower() == "true"
MQTT_TLS_INSECURE = os.getenv("MQTT_TLS_INSECURE", "false").lower() == "true"
INPUT_TOPIC = os.getenv("INPUT_TOPIC", "aws/+/data")
OUTPUT_TOPIC = os.getenv("OUTPUT_TOPIC", "aws/{deviceId}/rain/derived")
PUBLISH_DERIVED = os.getenv("PUBLISH_DERIVED", "false").lower() == "true"
PUBLISH_ENRICHED_TO_DATA = os.getenv("PUBLISH_ENRICHED_TO_DATA", "true").lower() == "true"
TZ_NAME = os.getenv("TIMEZONE", "Asia/Jakarta")
DEVICE_IDS = [s.strip() for s in os.getenv("DEVICE_IDS", "").split(",") if s.strip()]
STATE_FILE = os.getenv("STATE_FILE", "state.json")
LOG_DIR = os.getenv("LOG_DIR", "logs")

# Derived metrics windows
WINDOW_LAST_HOUR = timedelta(minutes=60)
WINDOW_RATE_10M = timedelta(minutes=10)

os.makedirs(LOG_DIR, exist_ok=True)

# ------------------ Utilities ------------------

def log(msg: str):
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{now}] {msg}"
    print(line, flush=True)
    try:
        with open(os.path.join(LOG_DIR, "aggregator.log"), "a", encoding="utf-8") as f:
            f.write(line + "\n")
    except Exception:
        pass


def parse_device_id(topic: str) -> str | None:
    # Expect aws/<deviceId>/rain or similar with + wildcard in INPUT_TOPIC
    parts = topic.split("/")
    try:
        i = parts.index("aws")
        return parts[i + 1]
    except Exception:
        # Fallback: regex for aws/<id>/
        m = re.search(r"aws/([^/]+)/", topic)
        return m.group(1) if m else None


def now_tz():
    tz = pytz.timezone(TZ_NAME)
    return datetime.now(tz)


# ------------------ State ------------------

class DeviceState:
    def __init__(self):
        self.baseline_value: float | None = None
        self.baseline_ts_iso: str | None = None
        self.samples: deque[tuple[datetime, float]] = deque()  # (ts, cumulative)

    def to_dict(self):
        return {
            "baseline_value": self.baseline_value,
            "baseline_ts_iso": self.baseline_ts_iso,
            "samples": [(ts.isoformat(), val) for ts, val in self.samples],
        }

    @staticmethod
    def from_dict(d: dict):
        s = DeviceState()
        s.baseline_value = d.get("baseline_value")
        s.baseline_ts_iso = d.get("baseline_ts_iso")
        samples = d.get("samples", [])
        tz = pytz.timezone(TZ_NAME)
        for ts_iso, val in samples:
            try:
                ts = datetime.fromisoformat(ts_iso)
                if ts.tzinfo is None:
                    ts = tz.localize(ts)
                s.samples.append((ts, float(val)))
            except Exception:
                continue
        return s


class Aggregator:
    def __init__(self):
        self.states: dict[str, DeviceState] = {}
        self.load_state()

    def load_state(self):
        if os.path.exists(STATE_FILE):
            try:
                with open(STATE_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
                for dev_id, sd in data.items():
                    self.states[dev_id] = DeviceState.from_dict(sd)
                log(f"Loaded state for {len(self.states)} devices")
            except Exception as e:
                log(f"Failed to load state: {e}")

    def save_state(self):
        try:
            data = {k: v.to_dict() for k, v in self.states.items()}
            with open(STATE_FILE, "w", encoding="utf-8") as f:
                json.dump(data, f)
        except Exception as e:
            log(f"Failed to save state: {e}")

    def ensure_device(self, device_id: str) -> DeviceState:
        if device_id not in self.states:
            self.states[device_id] = DeviceState()
        return self.states[device_id]

    def maybe_reset_daily_baseline(self, dev: DeviceState, cumulative: float, ts: datetime):
        # Reset at local midnight or when counter drops (device reset)
        tz = pytz.timezone(TZ_NAME)
        midnight = ts.astimezone(tz).replace(hour=0, minute=0, second=0, microsecond=0)
        if dev.baseline_ts_iso:
            try:
                bl_ts = datetime.fromisoformat(dev.baseline_ts_iso)
                if bl_ts.tzinfo is None:
                    bl_ts = tz.localize(bl_ts)
            except Exception:
                bl_ts = midnight
        else:
            bl_ts = midnight

        baseline_due = ts >= midnight and (not dev.baseline_ts_iso or bl_ts < midnight)
        counter_reset = dev.samples and cumulative < dev.samples[-1][1]
        if dev.baseline_value is None or baseline_due or counter_reset:
            dev.baseline_value = cumulative
            dev.baseline_ts_iso = ts.isoformat()
            log(f"Baseline set for device at {ts.isoformat()}: {dev.baseline_value}")

    def add_sample(self, device_id: str, cumulative: float, ts: datetime):
        dev = self.ensure_device(device_id)
        self.maybe_reset_daily_baseline(dev, cumulative, ts)
        # append sample
        dev.samples.append((ts, cumulative))
        # trim windows > 60m
        cutoff = ts - WINDOW_LAST_HOUR
        while dev.samples and dev.samples[0][0] < cutoff:
            dev.samples.popleft()

    def compute_metrics(self, device_id: str, ts: datetime):
        dev = self.ensure_device(device_id)
        rain_today = 0.0
        rain_last_hour = 0.0
        rain_rate_10m = 0.0
        if dev.samples:
            current = dev.samples[-1][1]
            baseline = dev.baseline_value or current
            rain_today = max(0.0, current - baseline)

            # last hour
            cutoff_hour = ts - WINDOW_LAST_HOUR
            first_in_window = None
            for t, v in dev.samples:
                if t >= cutoff_hour:
                    first_in_window = (t, v)
                    break
            if first_in_window:
                rain_last_hour = max(0.0, current - first_in_window[1])

            # rate 10m
            cutoff_10m = ts - WINDOW_RATE_10M
            first10 = None
            for t, v in dev.samples:
                if t >= cutoff_10m:
                    first10 = (t, v)
                    break
            if first10 and (ts - first10[0]).total_seconds() > 0:
                delta = max(0.0, current - first10[1])
                minutes = max(1.0, (ts - first10[0]).total_seconds() / 60.0)
                rain_rate_10m = (delta / minutes) * 60.0  # mm per hour
        return {
            "rain_today": round(rain_today, 3),
            "rain_last_hour": round(rain_last_hour, 3),
            "rain_rate_10m": round(rain_rate_10m, 3),
            "updated_at": ts.isoformat(),
        }


# ------------------ MQTT Client ------------------

agg = Aggregator()
log(f"Config: host={MQTT_HOST}:{MQTT_PORT} tls={MQTT_TLS} user={'set' if MQTT_USERNAME else 'none'} topic_in='{INPUT_TOPIC}' topic_out='{OUTPUT_TOPIC}' tz='{TZ_NAME}'")
client = mqtt.Client(client_id=MQTT_CLIENT_ID, clean_session=False)

if MQTT_USERNAME:
    client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD or "")

if MQTT_TLS:
    client.tls_set(cert_reqs=ssl.CERT_REQUIRED)
    if MQTT_TLS_INSECURE:
        client.tls_insecure_set(True)


def on_connect(client, userdata, flags, rc):
    if rc == 0:
        log("Connected to MQTT")
        client.subscribe(INPUT_TOPIC, qos=1)
        log(f"Subscribed to {INPUT_TOPIC}")
    else:
        log(f"Connect failed: {rc}")


def on_disconnect(client, userdata, rc):
    log(f"Disconnected: rc={rc}")


def on_message(client, userdata, msg):
    try:
        device_id = parse_device_id(msg.topic)
        if not device_id:
            return
        if DEVICE_IDS and device_id not in DEVICE_IDS:
            return

        payload = msg.payload.decode("utf-8", errors="ignore").strip()
        data = json.loads(payload) if payload.startswith("{") else {"rain": float(payload)}
        # Ignore messages produced by this aggregator to avoid loops
        if isinstance(data, dict) and data.get("_agg", {}).get("source") == "pakebun-aggregator":
            return
        # Accept either flat {"rain": <mm>} or nested {"aws": {"rain": <mm>}}
        if isinstance(data, dict) and "aws" in data and isinstance(data["aws"], dict):
            rain_val = data["aws"].get("rain")
        else:
            rain_val = data.get("rain")
        cumulative = float(rain_val)
        ts = now_tz()
        if "ts" in data:
            try:
                if isinstance(data["ts"], (int, float)):
                    ts = datetime.fromtimestamp(float(data["ts"]), pytz.timezone(TZ_NAME))
                else:
                    ts = datetime.fromisoformat(str(data["ts"]))
                    if ts.tzinfo is None:
                        ts = pytz.timezone(TZ_NAME).localize(ts)
            except Exception:
                ts = now_tz()

        agg.add_sample(device_id, cumulative, ts)
        metrics = agg.compute_metrics(device_id, ts)

        # Option A: publish single JSON metrics to derived topic (optional)
        if PUBLISH_DERIVED:
            out_topic = OUTPUT_TOPIC.format(deviceId=device_id)
            client.publish(out_topic, json.dumps(metrics), qos=1, retain=True)
            log(f"Published {metrics} to {out_topic}")

        # Option B: merge metrics into original aws/<id>/data payload (retained)
        if PUBLISH_ENRICHED_TO_DATA and isinstance(data, dict):
            aws_obj = data.get("aws")
            if isinstance(aws_obj, dict):
                # snake_case inside aws
                aws_obj["rain_today"] = metrics["rain_today"]
                aws_obj["rain_last_hour"] = metrics["rain_last_hour"]
                aws_obj["rain_rate_10m"] = metrics["rain_rate_10m"]
                data["aws"] = aws_obj
                # mark as produced by aggregator to avoid loop
                data["_agg"] = {"source": "pakebun-aggregator", "v": 1}
                enriched = json.dumps(data)
                client.publish(f"aws/{device_id}/data", enriched, qos=1, retain=True)
                log(f"Republished enriched aws data to aws/{device_id}/data")

        agg.save_state()
    except Exception as e:
        log(f"on_message error: {e}")


client.on_connect = on_connect
client.on_disconnect = on_disconnect
client.on_message = on_message

def on_log(client, userdata, level, buf):
    # Paho internal logs can be noisy; log only important states
    try:
        if any(k in buf for k in ("Connect", "connack", "disconnect", "socket", "failed")):
            log(f"[paho] {buf}")
    except Exception:
        pass

client.on_log = on_log

log(f"Connecting to MQTT {MQTT_HOST}:{MQTT_PORT} ...")
client.connect_async(MQTT_HOST, MQTT_PORT, keepalive=60)
client.loop_start()

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    log("Shutting down...")
finally:
    client.loop_stop()
    client.disconnect()
    agg.save_state()
