# Kitty Random Background

Script para abrir Kitty con imágenes de fondo aleatorias.

## Instalación

1. Clona este repo en tu directorio de configuración de Kitty:

```bash
git clone <tu-repo> ~/.config/kitty
```

2. Actualiza la ruta del usuario en `kitty.conf`:

```bash
# Cambiar esta línea con tu usuario actual en el archivo kitty.conf (actualmente con dasdasd)
background_image        /home/TU_USUARIO/.config/kitty/background_images/default_background.webp
```

3. Agrega tus imágenes en la carpeta `background_images/`

4. Crea el acceso directo para el menú:

```bash
cd ~/.config/kitty
./create-desktop.sh
```

## Uso scripts

- **Desde menú**: Busca "Kitty Random Background"
- **Desde terminal**: ` chmod +x setup-kitty.sh`
- **Desde terminal**: `./setup-kitty.sh`

- **Desde terminal**: ` chmod +x create-desktop.sh`
- **Desde terminal**: `./create-desktop.sh`

- **Listar imágenes**: `./setup-kitty.sh -l`
- **Restaurar config**: `./setup-kitty.sh -r`

## Estructura

```
~/.config/kitty/
├── kitty.conf                 # Configuración principal
├── background_images/         # Carpeta de imágenes
├── setup-kitty.sh            # Script principal
└── create-desktop.sh         # Crear acceso directo
```

Formatos soportados: jpg, jpeg, png, webp, gif, bmp

#para probar temas
kitty +kitten themes
