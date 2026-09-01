#!/bin/bash
set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/jasromao/openvpn-manager-multi-amigos/main"
TMPDIR="$(mktemp -d)"

trap 'rm -rf "$TMPDIR"' EXIT

if [ "$(id -u)" -ne 0 ]; then
    echo "Execute este instalador com sudo."
    exit 1
fi

echo "=========================================="
echo " OpenVPN Manager Multi - Amigos"
echo "=========================================="
echo

while true; do
    read -rsp "Escolha a password do painel (admin): " PANEL_PASS
    echo
    read -rsp "Repita a password: " PANEL_PASS2
    echo

    if [ -z "$PANEL_PASS" ]; then
        echo "A password não pode ficar vazia."
    elif [ "$PANEL_PASS" != "$PANEL_PASS2" ]; then
        echo "As passwords não coincidem. Tente novamente."
    else
        break
    fi
done

apt-get update
apt-get install -y curl python3

echo "A descarregar backup..."
curl -fL "$BASE_URL/openvpn-multi-amigos.tar.gz" \
    -o "$TMPDIR/openvpn-multi-amigos.tar.gz"

echo "A descarregar restaurador..."
curl -fL "$BASE_URL/restaurar-openvpn-multi" \
    -o "$TMPDIR/restaurar-openvpn-multi"

chmod +x "$TMPDIR/restaurar-openvpn-multi"

mkdir -p "$TMPDIR/backup"

echo "A preparar instalação..."
tar -xzpf "$TMPDIR/openvpn-multi-amigos.tar.gz" -C "$TMPDIR/backup"

APP="$TMPDIR/backup/home/ubuntu/openvpn-manager-multi/app.py"

if [ ! -f "$APP" ]; then
    echo "ERRO: app.py não encontrado no backup."
    exit 1
fi

APP_PATH="$APP" PANEL_PASS="$PANEL_PASS" python3 <<'PY'
from pathlib import Path
import os
import re

p = Path(os.environ["APP_PATH"])
password = os.environ["PANEL_PASS"]

text = p.read_text()

pattern = r'''(?m)^(\s*["']admin["']\s*:\s*)["'][^"']*["'](\s*,?\s*)$'''

new_text, count = re.subn(
    pattern,
    lambda m: m.group(1) + repr(password) + m.group(2),
    text,
    count=1
)

if count != 1:
    raise SystemExit("ERRO: não foi possível alterar a password do admin.")

p.write_text(new_text)
PY

echo "A criar backup personalizado..."
tar -czpf "$TMPDIR/openvpn-multi-personalizado.tar.gz" \
    -C "$TMPDIR/backup" .

echo "A instalar/restaurar..."
"$TMPDIR/restaurar-openvpn-multi" \
    "$TMPDIR/openvpn-multi-personalizado.tar.gz"

echo
echo "=========================================="
echo " Instalação concluída"
echo " Utilizador do painel: admin"
echo " Password: a escolhida durante a instalação"
echo "=========================================="
