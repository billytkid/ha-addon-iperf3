ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache iperf3 jq mosquitto-clients

COPY rootfs /

CMD [ "/run.sh" ]
