# iperf3 Server Add-on

Runs an iperf3 server and publishes two entities via MQTT after each test:

- `sensor.iperf3_sending_host` — client IP/hostname of the last test
- `sensor.iperf3_throughput_mbps` — throughput in Mbit/s of the last test

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
