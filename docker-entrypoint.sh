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

O script oficial verifica o instalador antes de executá-lo. Se a verificação falhar, não tente desativá-la: consulte os logs e confirme se a versão baixada é compatível. 
GitHub
+1
4. Arquivo docker-compose.yml

Esse arquivo será usado pelo Portainer para construir e iniciar o container. Ele mantém o perfil do Wine em um volume persistente e habilita o acesso ao adaptador TAP.
yaml


services:
  radmin-vpn:
    container_name: radmin-vpn
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped

    # Necessário para que o TAP e as rotas do projeto
    # possam ser configurados no namespace de rede do host.
    network_mode: host

    cap_add:
      - NET_ADMIN

    devices:
      - /dev/net/tun:/dev/net/tun

    environment:
      VNC_PASSWORD: "TROQUE_POR_UMA_SENHA_FORTE"

    volumes:
      - radmin_data:/opt/radmin/wineprefix

volumes:
  radmin_data:
