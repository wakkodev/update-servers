#!/bin/bash

echo "=== GENERADOR DE LLAVES SSH PERSONALIZADO ==="

# Pedir datos al usuario
read -p "Nombre del archivo de llave (sin extensión): " NOMBRE_LLAVE
read -p "Nombre del usuario SSH (debe existir): " USUARIO
read -s -p "Escribe el passphrase: " PASSPHRASE1
echo
read -s -p "Confirma el passphrase: " PASSPHRASE2
echo

if [[ "$PASSPHRASE1" != "$PASSPHRASE2" ]]; then
    echo "Los passphrases no coinciden. Abortando."
    exit 1
fi

if [[ -z "$PASSPHRASE1" ]]; then
    echo "El passphrase no puede estar vacío. Abortando."
    exit 1
fi

# Obtener IP del servidor automáticamente
IP_SERVIDOR=$(hostname -I | awk '{print $1}')
echo "IP detectada: $IP_SERVIDOR"

# Crear directorio home si no existe
HOME_USUARIO="/home/$USUARIO"
if [ ! -d "$HOME_USUARIO" ]; then
  echo "Creando directorio home para $USUARIO..."
  mkdir -p "$HOME_USUARIO"
  chown "$USUARIO:$USUARIO" "$HOME_USUARIO"
fi

# Crear carpeta .ssh si no existe
SSH_DIR="$HOME_USUARIO/.ssh"
mkdir -p "$SSH_DIR"
chown "$USUARIO:$USUARIO" "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Generar la llave
KEY_PATH="$SSH_DIR/$NOMBRE_LLAVE"
echo "Generando llave SSH en: $KEY_PATH"
ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -N "$PASSPHRASE1"

# Autorizar la llave pública
cat "$KEY_PATH.pub" >> "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"
chown "$USUARIO:$USUARIO" "$SSH_DIR/authorized_keys"

echo ""
echo "=== LLAVE CREADA Y CONFIGURADA EXITOSAMENTE ==="
echo "Usuario SSH: $USUARIO"
echo "IP del servidor: $IP_SERVIDOR"
echo "Ruta de la llave privada: $KEY_PATH"
