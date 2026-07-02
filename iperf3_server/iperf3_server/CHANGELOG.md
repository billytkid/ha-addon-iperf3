# Changelog

## 1.3.0
- Added client test controls: duration, reverse (download) mode, UDP bandwidth
- Added `sensor.iperf3_client_status` and `sensor.iperf3_client_last_test`
- Target IP validation before running a test

## 1.2.0
- Added iperf3 client-test mode: target IP, streams (1-10), protocol (TCP/UDP), run button
- Added result entities: tested IP, total transferred, bitrate

## 1.1.0
- Added MQTT entities for server mode: sending host, throughput (Mbps)
- Guarded MQTT calls so a missing broker doesn't crash the add-on

## 1.0.0
- Initial release: iperf3 server add-on
