#!/usr/bin/env bash

# Directorio de configuración de Kitty
KITTY_DIR="$HOME/.config/kitty"
IMAGES_DIR="$KITTY_DIR/background_images"
CONFIG_FILE="$KITTY_DIR/kitty.conf"
BACKUP_CONFIG="$KITTY_DIR/kitty.conf.backup"

# Función para crear backup
backup_config() {
  if [ ! -f "$BACKUP_CONFIG" ]; then
    cp "$CONFIG_FILE" "$BACKUP_CONFIG"
  fi
}

# Función para buscar imágenes
find_images() {
  find "$IMAGES_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" -o -iname "*.bmp" \) 2>/dev/null
}

# Función para actualizar configuración
update_config() {
  local image_path="$1"
  local temp_config=$(mktemp)

  while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*background_image ]]; then
      echo "background_image        $image_path"
    else
      echo "$line"
    fi
  done <"$CONFIG_FILE" >"$temp_config"

  mv "$temp_config" "$CONFIG_FILE"
}

# Función para restaurar configuración
restore_config() {
  if [ -f "$BACKUP_CONFIG" ]; then
    cp "$BACKUP_CONFIG" "$CONFIG_FILE"
  fi
}

# Función principal
main() {
  # Verificar directorios
  if [ ! -d "$IMAGES_DIR" ]; then
    echo "Error: $IMAGES_DIR no existe"
    exit 1
  fi

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE no existe"
    exit 1
  fi

  # Buscar imágenes
  mapfile -t IMAGES < <(find_images)

  if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "No hay imágenes en $IMAGES_DIR"
    exit 1
  fi

  # Seleccionar imagen aleatoria
  RANDOM_INDEX=$((RANDOM % ${#IMAGES[@]}))
  SELECTED_IMAGE="${IMAGES[RANDOM_INDEX]}"

  echo "Usando: $(basename "$SELECTED_IMAGE")"

  # Backup y actualizar
  backup_config
  update_config "$SELECTED_IMAGE"

  # Abrir Kitty
  kitty --detach &
  sleep 1

  # Restaurar configuración
  restore_config
}

# Manejo de argumentos
case "${1:-}" in
-h | --help)
  echo "Uso: $0 [opción]"
  echo "  -l  Listar imágenes"
  echo "  -r  Restaurar config original"
  ;;
-l | --list)
  find_images | xargs -n1 basename
  ;;
-r | --restore)
  restore_config
  echo "Configuración restaurada"
  ;;
"")
  main
  ;;
*)
  echo "Opción inválida: $1"
  exit 1
  ;;
esac
