import os
import sys
import json
import time
import ssl
import paho.mqtt.client as mqtt
from dotenv import load_dotenv

"""
Usage:
  python send_test.py <deviceId> <rain_mm>
Example:
  python send_test.py C45120B7B3F8 4.12
Publishes to: aws/<deviceId>/data with payload:
  {"id":"<deviceId>", "ts": <epoch>, "aws": {"rain": <rain_mm>}}
"""

load_dotenv()
BROKER = os.getenv('MQTT_HOST', 'localhost')
PORT = int(os.getenv('MQTT_PORT', '1883'))
TLS = os.getenv('MQTT_TLS', 'false').lower() == 'true'
USERNAME = os.getenv('MQTT_USERNAME')
PASSWORD = os.getenv('MQTT_PASSWORD')

if len(sys.argv) < 3:
    print('Usage: python send_test.py <deviceId> <rain_mm>')
    sys.exit(1)

device_id = sys.argv[1]
try:
    rain_val = float(sys.argv[2])
except Exception:
    print('rain_mm must be a number')
    sys.exit(1)

topic = f'aws/{device_id}/data'
payload = {
    'id': device_id,
    'ts': int(time.time()),
    'aws': {
        'rain': rain_val
    }
}

client = mqtt.Client(client_id=f'pakebun-sendtest-{int(time.time())}', clean_session=True)
if USERNAME:
    client.username_pw_set(USERNAME, PASSWORD or '')
if TLS:
    client.tls_set(cert_reqs=ssl.CERT_REQUIRED)

client.connect(BROKER, PORT, keepalive=20)
client.loop_start()

client.publish(topic, json.dumps(payload), qos=1, retain=False)
print(f'Published test payload to {topic}: {json.dumps(payload)}')

# small wait to flush
time.sleep(0.5)
client.loop_stop()
client.disconnect()
