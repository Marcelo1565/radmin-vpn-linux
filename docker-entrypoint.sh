#!/usr/bin/env bash
set -Eeuo pipefail

cd /opt/radmin

if [[ -z "${VNC_PASSWORD:-}" ]]; then
  echo "ERRO: configure VNC_PASSWORD na Stack do Portainer."
  exit 1
fi

INSTALLER="/opt/radmin/Radmin_VPN_2.1.4951.1.exe"

if [[ ! -f "$INSTALLER" ]]; then
  echo "Baixando o instalador oficial do Radmin VPN..."
  curl -fL --retry 3 \
    "https://download.radmin-vpn.com/download/files/Radmin_VPN_2.1.4951.1.exe" \
    -o "$INSTALLER"
fi

mkdir -p "$WINEPREFIX"

exec ./run_datacenter.sh \
  --installer "$INSTALLER" \
  --web-port 6080 \
  --web-bind 0.0.0.0 \
  --vnc-password "$VNC_PASSWORD"
