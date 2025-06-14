#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-kitty.sh"
DESKTOP_FILE="$SCRIPT_DIR/kitty-random-bg.desktop"
USER_APPS_DIR="$HOME/.local/share/applications"

# Verificar script
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "Error: setup-kitty.sh no encontrado"
  exit 1
fi

# Hacer ejecutable
chmod +x "$SCRIPT_PATH"

# Crear .desktop
cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Kitty Random Background
Comment=Abrir Kitty con imagen de fondo aleatoria
Exec=$SCRIPT_PATH
Icon=kitty
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
StartupNotify=true
Path=$SCRIPT_DIR
EOF

# Instalar
chmod +x "$DESKTOP_FILE"
mkdir -p "$USER_APPS_DIR"
cp "$DESKTOP_FILE" "$USER_APPS_DIR/"

# Actualizar base de datos
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$USER_APPS_DIR/"
fi

echo "Listo. Busca 'Kitty Random Background' en el menú"
