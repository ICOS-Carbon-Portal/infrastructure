#!/usr/bin/env bash
# Render all Dhall files back to YAML
# Requires: dhall-to-yaml (https://github.com/dhall-lang/dhall-haskell)
#           yq (https://github.com/mikefarah/yq)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${1:-$SCRIPT_DIR/../devops-rendered}"

mkdir -p "$OUTPUT_DIR"

find "$SCRIPT_DIR" -name "*.dhall" -print0 | while IFS= read -r -d "" f; do
  rel="${f#$SCRIPT_DIR/}"
  out="$OUTPUT_DIR/${rel%.dhall}.yml"
  mkdir -p "$(dirname "$out")"
  echo "Rendering $rel -> $out"
  dhall-to-yaml --file "$f" | yq 'del(.. | select(. == null))' > "$out"
done

echo "Done. Output in $OUTPUT_DIR"
