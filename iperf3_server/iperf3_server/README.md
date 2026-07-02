# iperf3 Server Add-on

Runs an iperf3 server and publishes two entities via MQTT after each test:

**Server (incoming tests):**
- `sensor.iperf3_sending_host` — client IP/hostname of the last test
- `sensor.iperf3_throughput_mbps` — throughput in Mbit/s of the last test

**Client (outgoing tests, run from the add-on):**
- `text.iperf3_target_ip` — IP to test against
- `number.iperf3_streams` — parallel streams, 1-10
- `select.iperf3_protocol` — TCP or UDP
- `number.iperf3_duration` — test length in seconds, 1-60 (default 10)
- `switch.iperf3_reverse` — ON tests download (server-to-client) instead of upload
- `number.iperf3_udp_bandwidth` — target Mbit/s for UDP tests (UDP defaults to 1Mbit/s in iperf3 otherwise, so set this or UDP results will look broken)
- `button.iperf3_run_test` — press to run the test
- `sensor.iperf3_client_tested_ip` — result: IP tested
- `sensor.iperf3_client_total_transferred` — result: total data (MB)
- `sensor.iperf3_client_bitrate` — result: throughput (Mbit/s)
- `sensor.iperf3_client_status` — OK / Failed / Invalid target IP
- `sensor.iperf3_client_last_test` — timestamp of the last test

## Requirements

- The official Mosquitto broker add-on (or any MQTT broker set up as HA's MQTT integration), since this add-on auto-discovers broker credentials via `services: mqtt:want`.

## Install (local add-on)

1. Copy the `iperf3_server` folder into `/addons/` on your HA host (Samba add-on or SSH).
2. Settings → Add-ons → Add-on Store → refresh (⋮ menu) → find it under "Local add-ons".
3. Install, then Start.

## Options

- `port` (default `5201`): iperf3 listen port. Update the `ports:` mapping in config.yaml too if changed.

## Usage

```
iperf3 -c <home-assistant-ip> -p 5201
```

Each completed test updates the two entities. The server loops automatically to accept the next test.
