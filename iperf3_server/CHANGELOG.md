# Changelog

## 2.2.3
- Fixed silent crash-loop: removed blanket `set -e` so a transient MQTT publish
  or state-file write no longer kills the whole add-on
- State file (`/data/state.json`) is now reset when missing **or corrupt** (a
  truncated write from a full disk previously caused every boot to crash-loop)

## 2.2.1
- Fixed `TX_LOCK: unbound variable` crash — variable was used but never defined
- Stale lock file now cleared on add-on start

## 2.2.0
- Added `--connect-timeout` and a hard overall timeout to TX tests so an unresponsive target fails/reports instead of hanging indefinitely
- Added a lock so concurrent TX triggers (web UI + MQTT) can't run at the same time; second request gets "Busy" status

## 2.1.2
- Fixed root cause of the hangs: `stdbuf` isn't in Alpine's base image, so the exec/tee redirection line was silently failing and breaking the script. Added `coreutils` package.

## 2.1.1
- Fixed GUI log not matching add-on log: added no-cache headers + cache-busting on the log fetch
- Note: GUI log starts from container start and won't include the s6-overlay boot lines HA's own Log tab shows

## 2.1.0
- Added live log viewer + Clear Log button to the ingress web UI
- All output now line-buffered and mirrored to a file for prompt display (works around HA's Log tab lag)

## 2.0.1
- Fixed ingress web UI silently failing to fetch state (relative-path resolution under HA's ingress proxy); errors now shown in the UI

## 2.0.0
- Added ingress web UI (sidebar panel): live RX/TX status, form to run TX tests, works without MQTT
- Added `sensor.iperf3_rx_status` and `sensor.iperf3_rx_last_test`

## 1.6.0
- Renamed add-on from "iperf3 Server" to "iperf3" (it's both server and client) — slug/entities unchanged, no migration needed

## 1.5.0
- Renamed all entities/topics to RX (server/receive) and TX (client/transmit) prefixes for clarity
- BREAKING: unique_ids changed — old entities become unavailable, remove manually

## 1.4.0
- Added `verbose_logging` config option (logs exact iperf3 command + raw JSON result)
- Every received MQTT command now logged (topic + payload) to catch stale-value/ordering issues

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
