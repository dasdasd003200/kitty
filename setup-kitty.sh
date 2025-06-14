#!/usr/bin/env bash
# Script para abrir Kitty con imagen de fondo aleatoria
# Autor: DevDan
# Descripción: Selecciona una imagen aleatoria del directorio de Kitty y abre una nueva terminal

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorio de configuración de Kitty
KITTY_DIR="$HOME/.config/kitty"
CONFIG_FILE="$KITTY_DIR/kitty.conf"
BACKUP_CONFIG="$KITTY_DIR/kitty.conf.backup"

# Función para mostrar mensajes con colores
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}[$(date '+%H:%M:%S')] ${message}${NC}"
}

# Función para crear backup de la configuración
backup_config() {
  if [ ! -f "$BACKUP_CONFIG" ]; then
    cp "$CONFIG_FILE" "$BACKUP_CONFIG"
    print_message "$GREEN" "Backup de configuración creado"
  fi
}

# Función para buscar imágenes
find_images() {
  local images=()
  while IFS= read -r -d '' file; do
    images+=("$file")
  done < <(find "$KITTY_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" \) -print0 2>/dev/null)

  printf '%s\n' "${images[@]}"
}

# Función para actualizar la configuración
update_config() {
  local image_path="$1"
  local temp_config=$(mktemp)

  # Leer la configuración actual y actualizar la línea de background_image
  while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*background_image[[:space:]]+ ]]; then
      echo "background_image        $image_path"
    elif [[ $line =~ ^[[:space:]]*#.*kitten[[:space:]]+icat ]]; then
      # Comentar completamente las líneas problemáticas de kitten icat
      echo "# $line"
    else
      echo "$line"
    fi
  done <"$CONFIG_FILE" >"$temp_config"

  # Reemplazar la configuración
  mv "$temp_config" "$CONFIG_FILE"
}

# Función para restaurar configuración original
restore_config() {
  if [ -f "$BACKUP_CONFIG" ]; then
    cp "$BACKUP_CONFIG" "$CONFIG_FILE"
    print_message "$GREEN" "Configuración restaurada"
  fi
}

# Función principal
main() {
  print_message "$BLUE" "🐱 Iniciando script de Kitty con fondo aleatorio"

  # Verificar si el directorio existe
  if [ ! -d "$KITTY_DIR" ]; then
    print_message "$RED" "Error: Directorio de Kitty no encontrado: $KITTY_DIR"
    exit 1
  fi

  # Verificar si el archivo de configuración existe
  if [ ! -f "$CONFIG_FILE" ]; then
    print_message "$RED" "Error: Archivo de configuración no encontrado: $CONFIG_FILE"
    exit 1
  fi

  # Buscar imágenes
  print_message "$YELLOW" "Buscando imágenes en $KITTY_DIR..."
  mapfile -t IMAGES < <(find_images)

  # Debug: Mostrar archivos encontrados
  print_message "$BLUE" "🔍 Debug - Archivos encontrados:"
  find "$KITTY_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" \) -exec basename {} \;

  # Verificar si hay imágenes
  if [ ${#IMAGES[@]} -eq 0 ]; then
    print_message "$RED" "⚠️  No se encontraron imágenes en $KITTY_DIR"
    print_message "$YELLOW" "Formatos soportados: jpg, jpeg, png, webp, gif, bmp"
    print_message "$BLUE" "Archivos en el directorio:"
    ls -la "$KITTY_DIR"/ | grep -E '\.(jpg|jpeg|png|webp|gif|bmp)$'
    print_message "$BLUE" "Abriendo Kitty sin imagen de fondo..."

    # Crear configuración temporal sin imagen de fondo
    backup_config
    sed 's/^[[:space:]]*background_image/#&/' "$CONFIG_FILE" >/tmp/kitty_no_bg.conf
    cp /tmp/kitty_no_bg.conf "$CONFIG_FILE"

    kitty --detach &
    sleep 2
    restore_config
    exit 0
  fi

  # Mostrar imágenes encontradas
  print_message "$GREEN" "✅ Encontradas ${#IMAGES[@]} imagen(es):"
  for i in "${!IMAGES[@]}"; do
    echo "   $((i + 1)). $(basename "${IMAGES[i]}")"
  done

  # Seleccionar imagen aleatoria
  RANDOM_INDEX=$((RANDOM % ${#IMAGES[@]}))
  SELECTED_IMAGE="${IMAGES[RANDOM_INDEX]}"

  print_message "$GREEN" "🎲 Imagen seleccionada: $(basename "$SELECTED_IMAGE")"

  # Crear backup y actualizar configuración
  backup_config
  update_config "$SELECTED_IMAGE"

  print_message "$BLUE" "🚀 Abriendo Kitty con nueva imagen de fondo..."

  # Abrir Kitty en segundo plano
  kitty --detach &
  KITTY_PID=$!

  # Esperar un momento para que Kitty se abra
  sleep 2

  # Restaurar configuración original
  restore_config

  print_message "$GREEN" "✨ ¡Kitty abierto exitosamente!"
  print_message "$BLUE" "PID del proceso: $KITTY_PID"

  # Mostrar información adicional
  echo
  print_message "$YELLOW" "📝 Información:"
  echo "   • Imagen: $(basename "$SELECTED_IMAGE")"
  echo "   • Ruta completa: $SELECTED_IMAGE"
  echo "   • Configuración respaldada en: $BACKUP_CONFIG"
}

# Función de ayuda
show_help() {
  echo "🐱 Script de Kitty con fondo aleatorio"
  echo
  echo "Uso: $0 [OPCIÓN]"
  echo
  echo "Opciones:"
  echo "  -h, --help     Mostrar esta ayuda"
  echo "  -l, --list     Listar imágenes disponibles"
  echo "  -r, --restore  Restaurar configuración original"
  echo
  echo "El script busca imágenes en: $KITTY_DIR"
  echo "Formatos soportados: jpg, jpeg, png, webp, gif, bmp"
}

# Función para listar imágenes
list_images() {
  print_message "$BLUE" "📋 Listando imágenes en $KITTY_DIR:"
  mapfile -t IMAGES < <(find_images)

  if [ ${#IMAGES[@]} -eq 0 ]; then
    print_message "$RED" "No se encontraron imágenes"
    exit 1
  fi

  for i in "${!IMAGES[@]}"; do
    echo "   $((i + 1)). $(basename "${IMAGES[i]}")"
  done
  echo
  print_message "$GREEN" "Total: ${#IMAGES[@]} imagen(es) encontrada(s)"
}

# Manejo de argumentos
case "${1:-}" in
-h | --help)
  show_help
  exit 0
  ;;
-l | --list)
  list_images
  exit 0
  ;;
-r | --restore)
  print_message "$BLUE" "Restaurando configuración original..."
  restore_config
  exit 0
  ;;
"")
  main
  ;;
*)
  print_message "$RED" "Opción desconocida: $1"
  echo "Usa '$0 --help' para ver las opciones disponibles"
  exit 1
  ;;
esac
