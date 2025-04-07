#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Uso: $0 -disk /dev/sdX"
  echo "Exemplo: $0 -disk /dev/sda   # Formata disco inteiro com partições EFI + raiz"
  echo "         $0 -disk /dev/sda1  # Apenas formata uma partição ext4 (raiz)"
  exit 1
}

if [ "$#" -ne 2 ] || [ "$1" != "-disk" ]; then
  usage
fi

TARGET="$2"

if [ ! -b "$TARGET" ]; then
  echo "❌ Erro: dispositivo '$TARGET' não encontrado."
  exit 1
fi

read -p "⚠️ Isso irá apagar TODOS os dados em $TARGET. Continuar? (yes/N): " confirm
if [ "$confirm" != "yes" ]; then
  echo "Cancelado."
  exit 1
fi

echo ">> Verificando tipo do dispositivo..."
if [[ "$TARGET" =~ ^/dev/sd[a-z]$ || "$TARGET" =~ ^/dev/nvme[0-9]n[0-9]$ ]]; then
  echo ">> Formatando disco completo: $TARGET"

  wipefs -a "$TARGET"
  sgdisk --zap-all "$TARGET"
  parted "$TARGET" -- mklabel gpt

  parted "$TARGET" -- mkpart ESP fat32 1MiB 512MiB
  parted "$TARGET" -- set 1 esp on
  parted "$TARGET" -- mkpart primary ext4 512MiB 100%

  EFI_PART="${TARGET}1"
  ROOT_PART="${TARGET}2"
  [[ "$TARGET" == /dev/nvme* ]] && EFI_PART="${TARGET}p1" && ROOT_PART="${TARGET}p2"

  mkfs.fat -F32 "$EFI_PART"
  mkfs.ext4 -F "$ROOT_PART"

  echo ">> Montando partições..."
  mount "$ROOT_PART" /mnt
  mkdir -p /mnt/boot
  mount "$EFI_PART" /mnt/boot

else
  echo ">> Formatando partição única: $TARGET como ext4"
  mkfs.ext4 -F "$TARGET"

  echo ">> Montando partição em /mnt"
  mount "$TARGET" /mnt
fi

echo ">> Copiando configuration.nix..."
nixos-generate-config --root /mnt
mkdir -p /mnt/etc/nixos
cp ./configuration.nix /mnt/etc/nixos/

echo ">> Instalando NixOS..."
nixos-install --no-root-password

echo "✅ Instalação concluída! Remova o disco de instalação e reinicie o sistema."
