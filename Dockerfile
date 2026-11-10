FROM ghcr.io/sagernet/sing-box:v1.14.4
WORKDIR /etc/sing-box
COPY config/config.json /etc/sing-box/config.template.json
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh
ENV VLESS_UUID="" WS_PATH="/ws"
EXPOSE 3000/tcp
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["run", "-c", "/etc/sing-box/config.json"]
