#!/usr/bin/with-contenv bashio
set -e

PORT=$(bashio::config 'port')

MQTT_HOST=$(bashio::services mqtt "host")
MQTT_PORT=$(bashio::services mqtt "port")
MQTT_USER=$(bashio::services mqtt "username")
MQTT_PASS=$(bashio::services mqtt "password")

DEVICE_ID="iperf3_server"
DISC_PREFIX="homeassistant"

MQ_ARGS=(-h "${MQTT_HOST}" -p "${MQTT_PORT}" -u "${MQTT_USER}" -P "${MQTT_PASS}")

publish() {
    mosquitto_pub "${MQ_ARGS[@]}" -r -t "$1" -m "$2"
}

bashio::log.info "Publishing MQTT discovery for iperf3 sensors"

DEVICE_JSON='{"identifiers":["iperf3_server"],"name":"iperf3 Server","model":"iperf3","manufacturer":"ESnet"}'

publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/sending_host/config" \
"{\"name\":\"iperf3 Sending Host\",\"unique_id\":\"iperf3_sending_host\",\"state_topic\":\"iperf3/sending_host\",\"icon\":\"mdi:ip-network\",\"device\":${DEVICE_JSON}}"

publish "${DISC_PREFIX}/sensor/${DEVICE_ID}/throughput_mbps/config" \
"{\"name\":\"iperf3 Throughput\",\"unique_id\":\"iperf3_throughput_mbps\",\"state_topic\":\"iperf3/throughput_mbps\",\"unit_of_measurement\":\"Mbit/s\",\"device_class\":\"data_rate\",\"state_class\":\"measurement\",\"icon\":\"mdi:speedometer\",\"device\":${DEVICE_JSON}}"

bashio::log.info "Starting iperf3 server loop on port ${PORT}"

while true; do
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
