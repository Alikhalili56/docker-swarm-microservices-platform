FROM docker.io/grafana/grafana:11.4.0

USER root

RUN apk add --no-cache postgresql-client curl ca-certificates

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
