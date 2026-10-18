#!/bin/bash
# Export mold.stl with a high $fn via -D fn_override.
# Customizer / -D interaction: https://github.com/openscad/openscad/issues/2037
set -euo pipefail
cd "$(dirname "$0")"

FN="${1:-200}"

if [ -n "${OPENSCAD:-}" ]; then
  :
elif command -v openscad >/dev/null 2>&1; then
  OPENSCAD=openscad
elif [ -x "/c/Program Files/OpenSCAD/openscad.exe" ]; then
  OPENSCAD="/c/Program Files/OpenSCAD/openscad.exe"
else
  echo "openscad not found. Set OPENSCAD=... or add it to PATH." >&2
  exit 1
fi

echo "Building mold.stl with fn_override=${FN}"
"$OPENSCAD" -o mold.stl \
  -D "fn_override=${FN}" \
  mold.scad
echo "Wrote $(pwd)/mold.stl"
