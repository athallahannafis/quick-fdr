#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

flutter build web --release --no-web-resources-cdn
node scripts/generate_sw.mjs

echo "Offline PWA build ready in: $(pwd)/build/web"
