# iperf3 Add-on

Runs an iperf3 server (RX) and lets you trigger outgoing iperf3 tests (TX). Exposes both via MQTT entities and a built-in web UI (Home Assistant ingress panel — shows up in the sidebar, like ESPHome's dashboard).

## Requirements

- MQTT entities require the official Mosquitto broker add-on (or any MQTT broker set up as HA's MQTT integration) — auto-discovered via `services: mqtt:want`. The web UI works even without MQTT.

## Install (local add-on)

1. Copy the `iperf3_server` folder into `/addons/` on your HA host (Samba add-on or SSH).
2. Settings → Add-ons → Add-on Store → refresh (⋮ menu) → find it under "Local add-ons".
3. Install, then Start.
4. Open it from the sidebar (panel icon) for the live web UI, or use the entities below.

## Options

- `port` (default `5201`): iperf3 listen port. Update the `ports:` mapping in config.yaml too if changed.
- `verbose_logging` (default `false`): logs the exact iperf3 command run and raw JSON result for TX tests.

## Web UI

Live RX/TX status (auto-refreshes every 2s) plus a form to run a TX test (target IP, streams, protocol, duration, UDP bandwidth, reverse). Works independently of MQTT.

## Entities (requires MQTT)

**RX (incoming tests — this add-on as the server):**
- `sensor.iperf3_rx_sending_host` — client IP/hostname of the last incoming test
- `sensor.iperf3_rx_throughput_mbps` — throughput in Mbit/s of the last incoming test
- `sensor.iperf3_rx_status` — waiting / OK
- `sensor.iperf3_rx_last_test` — timestamp of the last completed RX test

**TX (outgoing tests — this add-on as the client):**
- `text.iperf3_tx_target_ip` — IP to test against
- `number.iperf3_tx_streams` — parallel streams, 1-10
- `select.iperf3_tx_protocol` — TCP or UDP
- `number.iperf3_tx_duration` — test length in seconds, 1-60 (default 10)
- `switch.iperf3_tx_reverse` — ON tests download (server-to-client) instead of upload
- `number.iperf3_tx_udp_bandwidth` — target Mbit/s for UDP tests (UDP defaults to 1Mbit/s in iperf3 otherwise, so set this or UDP results will look broken)
- `button.iperf3_tx_run_test` — press to run the test
- `sensor.iperf3_tx_tested_ip` — result: IP tested
- `sensor.iperf3_tx_total_transferred` — result: total data (MB)
- `sensor.iperf3_tx_bitrate` — result: throughput (Mbit/s)
- `sensor.iperf3_tx_status` — Running / OK / Failed / Invalid target IP
- `sensor.iperf3_tx_last_test` — timestamp of the last TX test

## Usage

RX: `iperf3 -c <home-assistant-ip> -p 5201`

TX: use the web UI, or set the `text`/`number`/`select` entities in HA then press `button.iperf3_tx_run_test`.
