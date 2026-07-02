#!/usr/bin/with-contenv bashio
set -e

PORT=$(bashio::config 'port')

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

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/sending_host/config" \
    "{\"name\":\"iperf3 Sending Host\",\"unique_id\":\"iperf3_sending_host\",\"state_topic\":\"iperf3/sending_host\",\"icon\":\"mdi:ip-network\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/throughput_mbps/config" \
    "{\"name\":\"iperf3 Throughput\",\"unique_id\":\"iperf3_throughput_mbps\",\"state_topic\":\"iperf3/throughput_mbps\",\"unit_of_measurement\":\"Mbit/s\",\"device_class\":\"data_rate\",\"state_class\":\"measurement\",\"icon\":\"mdi:speedometer\",\"device\":${DEVICE_JSON}}"

    # --- Client-test controls ---
    publish "${DISC_PREFIX}/text/${DEVICE_ID}/target_ip/config" \
    "{\"name\":\"iperf3 Target IP\",\"unique_id\":\"iperf3_target_ip\",\"command_topic\":\"iperf3/client/target_ip/set\",\"state_topic\":\"iperf3/client/target_ip/state\",\"icon\":\"mdi:ip-network-outline\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/number/${DEVICE_ID}/streams/config" \
    "{\"name\":\"iperf3 Streams\",\"unique_id\":\"iperf3_streams\",\"command_topic\":\"iperf3/client/streams/set\",\"state_topic\":\"iperf3/client/streams/state\",\"min\":1,\"max\":10,\"step\":1,\"mode\":\"box\",\"icon\":\"mdi:call-split\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/select/${DEVICE_ID}/protocol/config" \
    "{\"name\":\"iperf3 Protocol\",\"unique_id\":\"iperf3_protocol\",\"command_topic\":\"iperf3/client/protocol/set\",\"state_topic\":\"iperf3/client/protocol/state\",\"options\":[\"TCP\",\"UDP\"],\"icon\":\"mdi:swap-vertical\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/number/${DEVICE_ID}/duration/config" \
    "{\"name\":\"iperf3 Duration\",\"unique_id\":\"iperf3_duration\",\"command_topic\":\"iperf3/client/duration/set\",\"state_topic\":\"iperf3/client/duration/state\",\"min\":1,\"max\":60,\"step\":1,\"unit_of_measurement\":\"s\",\"mode\":\"box\",\"icon\":\"mdi:timer-outline\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/switch/${DEVICE_ID}/reverse/config" \
    "{\"name\":\"iperf3 Reverse (download)\",\"unique_id\":\"iperf3_reverse\",\"command_topic\":\"iperf3/client/reverse/set\",\"state_topic\":\"iperf3/client/reverse/state\",\"payload_on\":\"ON\",\"payload_off\":\"OFF\",\"state_on\":\"ON\",\"state_off\":\"OFF\",\"icon\":\"mdi:arrow-down-bold\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/number/${DEVICE_ID}/udp_bandwidth/config" \
    "{\"name\":\"iperf3 UDP Bandwidth\",\"unique_id\":\"iperf3_udp_bandwidth\",\"command_topic\":\"iperf3/client/udp_bandwidth/set\",\"state_topic\":\"iperf3/client/udp_bandwidth/state\",\"min\":1,\"max\":1000,\"step\":1,\"unit_of_measurement\":\"Mbit/s\",\"mode\":\"box\",\"icon\":\"mdi:speedometer-slow\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/button/${DEVICE_ID}/run_test/config" \
    "{\"name\":\"iperf3 Run Test\",\"unique_id\":\"iperf3_run_test\",\"command_topic\":\"iperf3/client/run/set\",\"payload_press\":\"PRESS\",\"icon\":\"mdi:play-circle\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/client_tested_ip/config" \
    "{\"name\":\"iperf3 Tested IP\",\"unique_id\":\"iperf3_client_tested_ip\",\"state_topic\":\"iperf3/client/tested_ip\",\"icon\":\"mdi:ip-network\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/client_total_transferred/config" \
    "{\"name\":\"iperf3 Total Transferred\",\"unique_id\":\"iperf3_client_total_transferred\",\"state_topic\":\"iperf3/client/total_transferred\",\"unit_of_measurement\":\"MB\",\"device_class\":\"data_size\",\"state_class\":\"measurement\",\"icon\":\"mdi:database-arrow-down\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/client_bitrate/config" \
    "{\"name\":\"iperf3 Client Bitrate\",\"unique_id\":\"iperf3_client_bitrate\",\"state_topic\":\"iperf3/client/bitrate\",\"unit_of_measurement\":\"Mbit/s\",\"device_class\":\"data_rate\",\"state_class\":\"measurement\",\"icon\":\"mdi:speedometer\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/client_status/config" \
    "{\"name\":\"iperf3 Client Test Status\",\"unique_id\":\"iperf3_client_status\",\"state_topic\":\"iperf3/client/status\",\"icon\":\"mdi:check-network\",\"device\":${DEVICE_JSON}}"

    publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/client_last_test/config" \
    "{\"name\":\"iperf3 Last Test Time\",\"unique_id\":\"iperf3_client_last_test\",\"state_topic\":\"iperf3/client/last_test\",\"device_class\":\"timestamp\",\"icon\":\"mdi:clock-outline\",\"device\":${DEVICE_JSON}}"

    # seed default retained states so controls show a value immediately
    publish "iperf3/client/target_ip/state" ""
    publish "iperf3/client/streams/state" "1"
    publish "iperf3/client/protocol/state" "TCP"
    publish "iperf3/client/duration/state" "10"
    publish "iperf3/client/reverse/state" "OFF"
    publish "iperf3/client/udp_bandwidth/state" "100"
fi

bashio::log.info "Starting iperf3 server loop on port ${PORT}"

server_loop() {
    while true; do
        bashio::log.info "Waiting for iperf3 client on port ${PORT}"
        RESULT=$(iperf3 --server --port "${PORT}" --one-off --json 2>/dev/null) || {
            bashio::log.warning "iperf3 test failed or was interrupted, retrying"
            sleep 2
            continue
        }

        HOST=$(echo "${RESULT}" | jq -r '.start.connected[0].remote_host // empty')
        BPS=$(echo "${RESULT}" | jq -r '.end.sum_received.bits_per_second // .end.sum.bits_per_second // empty')

        if [ -n "${HOST}" ] && [ -n "${BPS}" ]; then
            MBPS=$(echo "${BPS}" | awk '{printf "%.2f", $1/1000000}')
            bashio::log.info "Test from ${HOST}: ${MBPS} Mbps"
            publish "iperf3/sending_host" "${HOST}"
            publish "iperf3/throughput_mbps" "${MBPS}"
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

run_client_test() {
    if ! is_valid_target "${CUR_TARGET}"; then
        bashio::log.warning "iperf3 client test requested but Target IP '${CUR_TARGET}' is empty or invalid"
        publish "iperf3/client/status" "Invalid target IP"
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

    bashio::log.info "Running iperf3 client test to ${CUR_TARGET} (streams=${CUR_STREAMS}, proto=${CUR_PROTO}, duration=${CUR_DURATION}s, reverse=${CUR_REVERSE})"

    CRESULT=$(iperf3 "${ARGS[@]}" 2>/dev/null) || {
        bashio::log.warning "iperf3 client test to ${CUR_TARGET} failed"
        publish "iperf3/client/status" "Failed"
        publish "iperf3/client/last_test" "$(date -u +%Y-%m-%dT%H:%M:%S+00:00)"
        return
    }

    BPS=$(echo "${CRESULT}" | jq -r '.end.sum_received.bits_per_second // .end.sum.bits_per_second // empty')
    BYTES=$(echo "${CRESULT}" | jq -r '.end.sum_received.bytes // .end.sum.bytes // empty')

    MBPS=""
    MB=""
    [ -n "${BPS}" ] && MBPS=$(echo "${BPS}" | awk '{printf "%.2f", $1/1000000}')
    [ -n "${BYTES}" ] && MB=$(echo "${BYTES}" | awk '{printf "%.2f", $1/1000000}')

    bashio::log.info "Client test result: ${CUR_TARGET} - ${MB} MB - ${MBPS} Mbps"
    publish "iperf3/client/tested_ip" "${CUR_TARGET}"
    publish "iperf3/client/total_transferred" "${MB}"
    publish "iperf3/client/bitrate" "${MBPS}"
    publish "iperf3/client/status" "OK"
    publish "iperf3/client/last_test" "$(date -u +%Y-%m-%dT%H:%M:%S+00:00)"
}

client_listener() {
    CUR_TARGET=""
    CUR_STREAMS=1
    CUR_PROTO="TCP"
    CUR_DURATION=10
    CUR_REVERSE="OFF"
    CUR_UDP_BW=100

    mosquitto_sub "${MQ_ARGS[@]}" -v -t "iperf3/client/+/set" | while read -r TOPIC PAYLOAD; do
        case "${TOPIC}" in
            iperf3/client/target_ip/set)
                CUR_TARGET="${PAYLOAD}"
                publish "iperf3/client/target_ip/state" "${CUR_TARGET}"
                ;;
            iperf3/client/streams/set)
                CUR_STREAMS="${PAYLOAD}"
                publish "iperf3/client/streams/state" "${CUR_STREAMS}"
                ;;
            iperf3/client/protocol/set)
                CUR_PROTO="${PAYLOAD}"
                publish "iperf3/client/protocol/state" "${CUR_PROTO}"
                ;;
            iperf3/client/duration/set)
                CUR_DURATION="${PAYLOAD}"
                publish "iperf3/client/duration/state" "${CUR_DURATION}"
                ;;
            iperf3/client/reverse/set)
                CUR_REVERSE="${PAYLOAD}"
                publish "iperf3/client/reverse/state" "${CUR_REVERSE}"
                ;;
            iperf3/client/udp_bandwidth/set)
                CUR_UDP_BW="${PAYLOAD}"
                publish "iperf3/client/udp_bandwidth/state" "${CUR_UDP_BW}"
                ;;
            iperf3/client/run/set)
                run_client_test
                ;;
        esac
    done
}

if [ "${MQTT_OK}" = true ]; then
    client_listener &
fi

server_loop
