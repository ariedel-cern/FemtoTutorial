#!/usr/bin/env bash
set -euo pipefail
mode="${1:-}"
if [[ "$mode" != tui && "$mode" != gui ]]; then
  printf 'Usage: bash scripts/cutculator.sh {tui|gui} [CutCulator arguments...]\n' >&2
  exit 2
fi
shift
o2physics_src="${O2PHYSICS_SRC:-$HOME/alice/O2Physics}"
tool=cutculator.py
if [[ "$mode" == gui ]]; then tool=cutculator_gui.py; fi
exec python3 "$o2physics_src/PWGCF/Femto/Macros/$tool" "$@"
