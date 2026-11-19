#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
input_file="$project_dir/AO2D.root"
grid_path='/alice/data/2026/LHC26ad/570703/apass1_sampled/0150/o2_ctf_run00570703_orbit0498204672_tf0014897993_epn182/001/AO2D.root'
if [[ -s "$input_file" ]]; then
  printf 'Input already exists: %s\n' "$input_file"
  exit 0
fi
command -v alien_cp >/dev/null || {
  printf 'Load an AliEn/O2Physics environment providing alien_cp first.\n' >&2
  exit 1
}
mkdir -p "$project_dir/.cache"
export TMPDIR="$project_dir/.cache"
# Requires a valid grid token (alien-token-init in the AliEn environment).
alien_cp "alien://$grid_path" "file:$input_file"
