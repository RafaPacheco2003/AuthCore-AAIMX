#!/usr/bin/env bash
# -------------------------------------------------------
#  stack.sh  —  Orquesta todo el stack AAAIMX
#  Uso (desde la raíz AAAIMX/):
#    ./stack.sh up       Construye imágenes y levanta todo
#    ./stack.sh down     Baja contenedores (datos persisten)
#    ./stack.sh clean    Baja contenedores + elimina volúmenes
#    ./stack.sh logs     Logs de todos los servicios en tiempo real
#    ./stack.sh logs <servicio>   Logs de un servicio específico
#                         Ej: ./stack.sh logs gateway
#    ./stack.sh ps       Estado de los contenedores
#    ./stack.sh rebuild <servicio>  Reconstruye un solo servicio
#                         Ej: ./stack.sh rebuild gateway
# -------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

case "$1" in
  up)
    echo "🚀  Levantando stack completo..."
    docker compose up --build -d
    echo ""
    docker compose ps
    echo ""
    echo "  gateway  →  http://localhost:8080"
    echo "  auth     →  http://localhost:8090"
    echo ""
    echo "📋  Logs en tiempo real → ./stack.sh logs"
    ;;
  down)
    echo "🛑  Bajando contenedores (datos conservados)..."
    docker compose down
    echo "✅  Listo."
    ;;
  clean)
    echo "🗑️   Bajando contenedores y eliminando volúmenes..."
    docker compose down -v
    echo "✅  Listo."
    ;;
  logs)
    if [ -n "$2" ]; then
      docker compose logs -f "$2"
    else
      docker compose logs -f
    fi
    ;;
  ps)
    docker compose ps
    ;;
  rebuild)
    if [ -z "$2" ]; then
      echo "Indica el servicio: ./stack.sh rebuild <servicio>"
      exit 1
    fi
    echo "🔄  Reconstruyendo $2..."
    docker compose up --build -d "$2"
    echo "✅  $2 actualizado."
    ;;
  *)
    echo "Uso: $0 {up|down|clean|logs [servicio]|ps|rebuild <servicio>}"
    exit 1
    ;;
esac
