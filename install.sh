#!/bin/bash
set -e

BASE_URL="https://raw.githubusercontent.com/jasromao/openvpn-manager-multi-amigos/main"

echo "=========================================="
echo " Instalar OpenVPN Manager Multi - Amigos"
echo "=========================================="

apt-get update
apt-get install -y curl

echo "A descarregar backup..."
curl -fL "$BASE_URL/openvpn-multi-amigos.tar.gz" \
  -o /home/ubuntu/openvpn-multi-amigos.tar.gz

echo "A descarregar restaurador..."
curl -fL "$BASE_URL/restaurar-openvpn-multi" \
  -o /home/ubuntu/restaurar-openvpn-multi

chmod +x /home/ubuntu/restaurar-openvpn-multi

echo "A restaurar OpenVPN Multi..."
/home/ubuntu/restaurar-openvpn-multi \
  /home/ubuntu/openvpn-multi-amigos.tar.gz

echo
echo "=========================================="
echo " Instalação concluída"
echo "=========================================="
