# MQTT Rain Aggregator (Temporary Server)

This folder contains a small Python service you can run on your laptop to act as the "server" (aggregator) that consumes cumulative rain data from your MQTT broker and publishes derived metrics:
- rain_today (mm)
- rain_last_hour (mm)
- rain_rate_10m (mm/h)

All outputs are published as retained messages so late subscribers (like the app) get the latest values immediately.

## What your laptop needs

- Windows 10/11, always-on while the aggregator runs
- Network access to the MQTT broker (host/port reachable)
- Python 3.10+ installed and available in PATH
- MQTT broker credentials (if required): host, port, username, password, TLS info

## Configure

1. Copy `.env.example` to `.env` and edit values.
2. Confirm your broker uses non‑TLS (1883) or TLS (8883) and set `MQTT_TLS` accordingly.
3. List AWS device IDs you want to track, or leave empty to auto-learn from incoming topics.

## Run (Windows, cmd)

- Create/activate a virtual env and install deps:

```
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

- Start the service:
```
python aggregator.py
```

The service logs to console and also writes rotating logs under `logs/`.

## Topic conventions

- Input (raw cumulative) topic example: `aws/<deviceId>/data` with payload containing nested JSON, e.g.:
  `{ "id": "<deviceId>", "aws": { "rain": <mm>, ... }, ... }`
- Output options:
  1) Merge into original data (default): republishes to `aws/<deviceId>/data` (retained) with extra fields inside `aws`:
     ```
     { "id":"...", "ts":..., "aws": { "rain": 3.81, "rain_today": 0.2, "rain_last_hour": 0.05, "rain_rate_10m": 0.8, ... }, "_agg": {"source":"pakebun-aggregator","v":1} }
     ```
     The `_agg` marker prevents the aggregator from reprocessing its own message.
  2) Separate derived topic (optional): `aws/<deviceId>/rain/derived` retained JSON:
     ```
     { "rain_today": 0.0, "rain_last_hour": 0.0, "rain_rate_10m": 0.0, "updated_at": "2025-10-20T12:34:56+07:00" }
     ```
  Control via `.env`: `PUBLISH_ENRICHED_TO_DATA=true`, `PUBLISH_DERIVED=false` (defaults shown).

If your raw topic/payload differ, adjust the parser in `aggregator.py`.

## How it works

- Maintains a per-device baseline at each local midnight (timezone configurable) to compute daily totals.
- Uses a sliding window of 60 minutes for `rain_last_hour` and 10 minutes for `rain_rate_10m`.
- Handles counter resets by detecting drops in the cumulative value and re-baselining.
- Publishes derived metrics on every new message.

## Safety & reliability

- Uses MQTT persistent session (clean_session=false) and QoS 1 for input and output
- Auto-reconnects on disconnects
- Retains last state on disk (`state.json`) for fast restarts

## Next steps

- Once this proves stable, move it to the same host as the MQTT broker or a VPS.
- If you prefer Node-RED, this logic can be ported to a flow using `context` + `rbe` + `function` nodes.
