ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache iperf3 jq mosquitto-clients python3

COPY rootfs /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
