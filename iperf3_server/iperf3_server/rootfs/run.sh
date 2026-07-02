#!/usr/bin/with-contenv bashio
set -e

PORT=$(bashio::config 'port')
VERBOSE=$(bashio::config 'verbose_logging')

log_debug() {
    [ "${VERBOSE}" = "true" ] && bashio::log.info "[debug] $1"
}

MQTT_OK=false
if bashio::services.available "mqtt"; then
    MQTT_HOST=$(bashio::services mqtt "host")
    MQTT_PORT=$(bashio::services mqtt "port")
    MQTT_USER=$(bashio::services mqtt "username")
    MQTT_PASS=$(bashio::services mqtt "password")
    MQ_ARGS=(-h "${MQTT_HOST}" -p "${MQTT_PORT}" -u "${MQTT_USER}" -P "${MQTT_PASS}")
    MQTT_OK=true
else
    bashio::log.warning "No MQTT service available - entities will not be published, iperf3 will still run"
fi

DEVICE_ID="iperf3_server"
DISC_PREFIX="homeassistant"

publish() {
    if [ "${MQTT_OK}" = true ]; then
        mosquitto_pub "${MQ_ARGS[@]}" -r -t "$1" -m "$2" || bashio::log.warning "MQTT publish to $1 failed"
    fi
}

if [ "${MQTT_OK}" = true ]; then
    bashio::log.info "Publishing MQTT discovery for iperf3 sensors"
    DEVICE_JSON='{"identifiers":["iperf3_server"],"name":"iperf3 Server","model":"iperf3","manufacturer":"ESnet"}'

    # --- RX (server / receiving tests) ---
    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/rx_sending_host/config" \
    "{\"name\":\"iperf3 RX Sending Host\",\"unique_id\":\"iperf3_rx_sending_host\",\"state_topic\":\"iperf3/rx/sending_host\",\"icon\":\"mdi:ip-network\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/rx_throughput_mbps/config" \
    "{\"name\":\"iperf3 RX Throughput\",\"unique_id\":\"iperf3_rx_throughput_mbps\",\"state_topic\":\"iperf3/rx/throughput_mbps\",\"unit_of_measurement\":\"Mbit/s\",\"device_class\":\"data_rate\",\"state_class\":\"measurement\",\"icon\":\"mdi:speedometer\",\"device\":${DEVICE_JSON}}"

    # --- TX (client / outgoing tests) ---
    publish "${DISC_PREFIX}/text/${DEVICE_ID}/tx_target_ip/config" \
    "{\"name\":\"iperf3 TX Target IP\",\"unique_id\":\"iperf3_tx_target_ip\",\"command_topic\":\"iperf3/tx/target_ip/set\",\"state_topic\":\"iperf3/tx/target_ip/state\",\"icon\":\"mdi:ip-network-outline\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/number/${DEVICE_ID}/tx_streams/config" \
    "{\"name\":\"iperf3 TX Streams\",\"unique_id\":\"iperf3_tx_streams\",\"command_topic\":\"iperf3/tx/streams/set\",\"state_topic\":\"iperf3/tx/streams/state\",\"min\":1,\"max\":10,\"step\":1,\"mode\":\"box\",\"icon\":\"mdi:call-split\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/select/${DEVICE_ID}/tx_protocol/config" \
    "{\"name\":\"iperf3 TX Protocol\",\"unique_id\":\"iperf3_tx_protocol\",\"command_topic\":\"iperf3/tx/protocol/set\",\"state_topic\":\"iperf3/tx/protocol/state\",\"options\":[\"TCP\",\"UDP\"],\"icon\":\"mdi:swap-vertical\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/number/${DEVICE_ID}/tx_duration/config" \
    "{\"name\":\"iperf3 TX Duration\",\"unique_id\":\"iperf3_tx_duration\",\"command_topic\":\"iperf3/tx/duration/set\",\"state_topic\":\"iperf3/tx/duration/state\",\"min\":1,\"max\":60,\"step\":1,\"unit_of_measurement\":\"s\",\"mode\":\"box\",\"icon\":\"mdi:timer-outline\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/switch/${DEVICE_ID}/tx_reverse/config" \
    "{\"name\":\"iperf3 TX Reverse (download)\",\"unique_id\":\"iperf3_tx_reverse\",\"command_topic\":\"iperf3/tx/reverse/set\",\"state_topic\":\"iperf3/tx/reverse/state\",\"payload_on\":\"ON\",\"payload_off\":\"OFF\",\"state_on\":\"ON\",\"state_off\":\"OFF\",\"icon\":\"mdi:arrow-down-bold\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/number/${DEVICE_ID}/tx_udp_bandwidth/config" \
    "{\"name\":\"iperf3 TX UDP Bandwidth\",\"unique_id\":\"iperf3_tx_udp_bandwidth\",\"command_topic\":\"iperf3/tx/udp_bandwidth/set\",\"state_topic\":\"iperf3/tx/udp_bandwidth/state\",\"min\":1,\"max\":1000,\"step\":1,\"unit_of_measurement\":\"Mbit/s\",\"mode\":\"box\",\"icon\":\"mdi:speedometer-slow\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/button/${DEVICE_ID}/tx_run_test/config" \
    "{\"name\":\"iperf3 TX Run Test\",\"unique_id\":\"iperf3_tx_run_test\",\"command_topic\":\"iperf3/tx/run/set\",\"payload_press\":\"PRESS\",\"icon\":\"mdi:play-circle\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/tx_tested_ip/config" \
    "{\"name\":\"iperf3 TX Tested IP\",\"unique_id\":\"iperf3_tx_tested_ip\",\"state_topic\":\"iperf3/tx/tested_ip\",\"icon\":\"mdi:ip-network\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/tx_total_transferred/config" \
    "{\"name\":\"iperf3 TX Total Transferred\",\"unique_id\":\"iperf3_tx_total_transferred\",\"state_topic\":\"iperf3/tx/total_transferred\",\"unit_of_measurement\":\"MB\",\"device_class\":\"data_size\",\"state_class\":\"measurement\",\"icon\":\"mdi:database-arrow-down\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/tx_bitrate/config" \
    "{\"name\":\"iperf3 TX Bitrate\",\"unique_id\":\"iperf3_tx_bitrate\",\"state_topic\":\"iperf3/tx/bitrate\",\"unit_of_measurement\":\"Mbit/s\",\"device_class\":\"data_rate\",\"state_class\":\"measurement\",\"icon\":\"mdi:speedometer\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/tx_status/config" \
    "{\"name\":\"iperf3 TX Status\",\"unique_id\":\"iperf3_tx_status\",\"state_topic\":\"iperf3/tx/status\",\"icon\":\"mdi:check-network\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/tx_last_test/config" \
    "{\"name\":\"iperf3 TX Last Test Time\",\"unique_id\":\"iperf3_tx_last_test\",\"state_topic\":\"iperf3/tx/last_test\",\"device_class\":\"timestamp\",\"icon\":\"mdi:clock-outline\",\"device\":${DEVICE_JSON}}"

    # seed default retained states so controls show a value immediately
    publish "iperf3/tx/target_ip/state" ""
    publish "iperf3/tx/streams/state" "1"
    publish "iperf3/tx/protocol/state" "TCP"
    publish "iperf3/tx/duration/state" "10"
    publish "iperf3/tx/reverse/state" "OFF"
    publish "iperf3/tx/udp_bandwidth/state" "100"
fi

bashio::log.info "Starting iperf3 RX (server) loop on port ${PORT}"

rx_loop() {
    while true; do
        bashio::log.info "RX: waiting for iperf3 client on port ${PORT}"
        RESULT=$(iperf3 --server --port "${PORT}" --one-off --json 2>/dev/null) || {
            bashio::log.warning "RX: iperf3 test failed or was interrupted, retrying"
            sleep 2
            continue
        }

        HOST=$(echo "${RESULT}" | jq -r '.start.connected[0].remote_host // empty')
        BPS=$(echo "${RESULT}" | jq -r '.end.sum_received.bits_per_second // .end.sum.bits_per_second // empty')

        if [ -n "${HOST}" ] && [ -n "${BPS}" ]; then
            MBPS=$(echo "${BPS}" | awk '{printf "%.2f", $1/1000000}')
            bashio::log.info "RX: test from ${HOST}: ${MBPS} Mbps"
            publish "iperf3/rx/sending_host" "${HOST}"
            publish "iperf3/rx/throughput_mbps" "${MBPS}"
        fi
    done
}

is_valid_target() {
    case "$1" in
        "") return 1 ;;
        *[!a-zA-Z0-9._-]*) return 1 ;;
        *) return 0 ;;
    esac
}

run_tx_test() {
    if ! is_valid_target "${CUR_TARGET}"; then
        bashio::log.warning "TX: test requested but Target IP '${CUR_TARGET}' is empty or invalid"
        publish "iperf3/tx/status" "Invalid target IP"
        return
    fi

    case "${CUR_STREAMS}" in
        ''|*[!0-9]*) CUR_STREAMS=1 ;;
    esac
    [ "${CUR_STREAMS}" -lt 1 ] && CUR_STREAMS=1
    [ "${CUR_STREAMS}" -gt 10 ] && CUR_STREAMS=10

    case "${CUR_DURATION}" in
        ''|*[!0-9]*) CUR_DURATION=10 ;;
    esac
    [ "${CUR_DURATION}" -lt 1 ] && CUR_DURATION=1
    [ "${CUR_DURATION}" -gt 60 ] && CUR_DURATION=60

    case "${CUR_UDP_BW}" in
        ''|*[!0-9]*) CUR_UDP_BW=100 ;;
    esac

    ARGS=(-c "${CUR_TARGET}" -P "${CUR_STREAMS}" -t "${CUR_DURATION}" --json)
    [ "${CUR_PROTO}" = "UDP" ] && ARGS+=(-u -b "${CUR_UDP_BW}M")
    [ "${CUR_REVERSE}" = "ON" ] && ARGS+=(-R)

    bashio::log.info "TX: running test to ${CUR_TARGET} (streams=${CUR_STREAMS}, proto=${CUR_PROTO}, duration=${CUR_DURATION}s, reverse=${CUR_REVERSE})"
    log_debug "TX command: iperf3 ${ARGS[*]}"

    CRESULT=$(iperf3 "${ARGS[@]}" 2>/dev/null) || {
        bashio::log.warning "TX: test to ${CUR_TARGET} failed"
        publish "iperf3/tx/status" "Failed"
        publish "iperf3/tx/last_test" "$(date -u +%Y-%m-%dT%H:%M:%S+00:00)"
        return
    }

    log_debug "TX raw result: ${CRESULT}"

    BPS=$(echo "${CRESULT}" | jq -r '.end.sum_received.bits_per_second // .end.sum.bits_per_second // empty')
    BYTES=$(echo "${CRESULT}" | jq -r '.end.sum_received.bytes // .end.sum.bytes // empty')

    MBPS=""
    MB=""
    [ -n "${BPS}" ] && MBPS=$(echo "${BPS}" | awk '{printf "%.2f", $1/1000000}')
    [ -n "${BYTES}" ] && MB=$(echo "${BYTES}" | awk '{printf "%.2f", $1/1000000}')

    bashio::log.info "TX: result ${CUR_TARGET} - ${MB} MB - ${MBPS} Mbps"
    publish "iperf3/tx/tested_ip" "${CUR_TARGET}"
    publish "iperf3/tx/total_transferred" "${MB}"
    publish "iperf3/tx/bitrate" "${MBPS}"
    publish "iperf3/tx/status" "OK"
    publish "iperf3/tx/last_test" "$(date -u +%Y-%m-%dT%H:%M:%S+00:00)"
}

tx_listener() {
    CUR_TARGET=""
    CUR_STREAMS=1
    CUR_PROTO="TCP"
    CUR_DURATION=10
    CUR_REVERSE="OFF"
    CUR_UDP_BW=100

    mosquitto_sub "${MQ_ARGS[@]}" -v -t "iperf3/tx/+/set" | while read -r TOPIC PAYLOAD; do
        bashio::log.info "TX: received command ${TOPIC} = '${PAYLOAD}'"
        case "${TOPIC}" in
            iperf3/tx/target_ip/set)
                CUR_TARGET="${PAYLOAD}"
                publish "iperf3/tx/target_ip/state" "${CUR_TARGET}"
                ;;
            iperf3/tx/streams/set)
                CUR_STREAMS="${PAYLOAD}"
                publish "iperf3/tx/streams/state" "${CUR_STREAMS}"
                ;;
            iperf3/tx/protocol/set)
                CUR_PROTO="${PAYLOAD}"
                publish "iperf3/tx/protocol/state" "${CUR_PROTO}"
                ;;
            iperf3/tx/duration/set)
                CUR_DURATION="${PAYLOAD}"
                publish "iperf3/tx/duration/state" "${CUR_DURATION}"
                ;;
            iperf3/tx/reverse/set)
                CUR_REVERSE="${PAYLOAD}"
                publish "iperf3/tx/reverse/state" "${CUR_REVERSE}"
                ;;
            iperf3/tx/udp_bandwidth/set)
                CUR_UDP_BW="${PAYLOAD}"
                publish "iperf3/tx/udp_bandwidth/state" "${CUR_UDP_BW}"
                ;;
            iperf3/tx/run/set)
                run_tx_test
                ;;
        esac
    done
}

if [ "${MQTT_OK}" = true ]; then
    tx_listener &
fi

rx_loop
