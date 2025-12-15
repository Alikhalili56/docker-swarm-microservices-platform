FROM codeberg.org/forgejo/forgejo:9.0.3

# Install dependencies for entrypoint script
RUN apk add --no-cache sudo curl postgresql-client ca-certificates \
 && update-ca-certificates

# Add custom entrypoint
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
