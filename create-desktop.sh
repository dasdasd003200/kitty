#!/usr/bin/env bash
# Script para crear el archivo .desktop para setup-kitty.sh
# Ejecutar desde ~/.config/kitty/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-kitty.sh"
DESKTOP_FILE="$SCRIPT_DIR/kitty-random-bg.desktop"
USER_APPS_DIR="$HOME/.local/share/applications"

echo "🔧 Creando archivo .desktop para setup-kitty.sh"
echo "📁 Directorio actual: $SCRIPT_DIR"

# Verificar que el script existe
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "❌ Error: No se encontró setup-kitty.sh en $SCRIPT_PATH"
  exit 1
fi

# Hacer el script ejecutable
chmod +x "$SCRIPT_PATH"
echo "✅ Permisos de ejecución otorgados a setup-kitty.sh"

# Crear el archivo .desktop en el mismo directorio
cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Kitty Random Background
Comment=Abrir Kitty con imagen de fondo aleatoria
Exec=$SCRIPT_PATH
Icon=kitty
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
Keywords=terminal;kitty;background;random;
StartupNotify=true
Name[es]=Kitty Fondo Aleatorio
Comment[es]=Abrir terminal Kitty con imagen de fondo aleatoria
Path=$SCRIPT_DIR
EOF

echo "✅ Archivo .desktop creado en: $DESKTOP_FILE"

# Hacer el archivo .desktop ejecutable
chmod +x "$DESKTOP_FILE"

# Crear directorio de aplicaciones de usuario si no existe
mkdir -p "$USER_APPS_DIR"

# Copiar el archivo .desktop al directorio de aplicaciones
cp "$DESKTOP_FILE" "$USER_APPS_DIR/"
echo "✅ Archivo .desktop copiado a: $USER_APPS_DIR/"

# Actualizar base de datos de aplicaciones
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$USER_APPS_DIR/"
  echo "✅ Base de datos de aplicaciones actualizada"
else
  echo "⚠️  Comando update-desktop-database no encontrado, pero el archivo debería funcionar"
fi

echo ""
echo "🎉 ¡Listo! Tu aplicación debería aparecer en el menú como 'Kitty Random Background'"
echo ""
echo "📋 Archivos creados:"
echo "   • $DESKTOP_FILE (local en tu config)"
echo "   • $USER_APPS_DIR/kitty-random-bg.desktop (para el menú)"
echo ""
echo "💡 Para usar en otras PCs:"
echo "   1. Clona tu repositorio con la carpeta .config/kitty"
echo "   2. Ejecuta: cd ~/.config/kitty && ./create-desktop.sh"
echo ""
echo "🔧 Para desinstalar:"
echo "   rm '$USER_APPS_DIR/kitty-random-bg.desktop'"
