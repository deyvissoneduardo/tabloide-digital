#!/usr/bin/env bash
# Gera o build web e publica na Vercel (projeto tabloide-web).
#
# Uso:
#   scripts/deploy_web.sh          # deploy de preview
#   scripts/deploy_web.sh --prod   # deploy de produção (tabloide-digital.vercel.app)
#
# API_URL pode ser sobrescrita: API_URL=http://... scripts/deploy_web.sh
set -euo pipefail

PROJETO_VERCEL="tabloide-web"
API_URL="${API_URL:-https://tabloide-api.vercel.app/v1}"

alvo="preview"
args_vercel=(deploy --yes)
case "${1:-}" in
  "") ;;
  --prod)
    alvo="produção"
    args_vercel+=(--prod)
    ;;
  *)
    echo "Uso: $0 [--prod]" >&2
    exit 1
    ;;
esac

for cmd in flutter vercel; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Erro: '$cmd' não encontrado no PATH." >&2
    exit 1
  fi
done

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$raiz"

echo "==> Build web (API_URL=$API_URL)"
flutter build web --dart-define=API_URL="$API_URL"

saida="$raiz/build/web"
if [[ ! -f "$saida/vercel.json" ]]; then
  echo "Erro: build/web/vercel.json não existe (deveria vir de web/vercel.json)." >&2
  exit 1
fi

cd "$saida"
if [[ ! -f .vercel/project.json ]]; then
  echo "==> Vinculando build/web ao projeto $PROJETO_VERCEL"
  vercel link --yes --project "$PROJETO_VERCEL"
fi

echo "==> Deploy de $alvo na Vercel"
vercel "${args_vercel[@]}"
