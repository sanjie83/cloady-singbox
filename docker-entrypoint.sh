#!/bin/sh
set -eu
: "${VLESS_UUID:?VLESS_UUID is required}"
: "${WS_PATH:=/ws}"
: "${LISTEN_PORT:=3000}"
case "$VLESS_UUID" in ????????-????-????-????-????????????) ;; *) echo "VLESS_UUID must use 8-4-4-4-12 format" >&2; exit 1;; esac
case "$WS_PATH" in /*) ;; *) echo "WS_PATH must start with /" >&2; exit 1;; esac
case "$WS_PATH" in *[!A-Za-z0-9_./~-]*) echo "WS_PATH has unsupported characters" >&2; exit 1;; esac
case "$LISTEN_PORT" in ''|*[!0-9]*) echo "LISTEN_PORT must be numeric" >&2; exit 1;; esac
sed -e "s|\${VLESS_UUID}|$VLESS_UUID|g" -e "s|\${WS_PATH}|$WS_PATH|g" /etc/sing-box/config.template.json > /etc/sing-box/config.json
sed -i "s/\"listen_port\": 3000/\"listen_port\": $LISTEN_PORT/" /etc/sing-box/config.json
sing-box check -c /etc/sing-box/config.json
exec sing-box "$@"
