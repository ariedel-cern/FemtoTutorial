#!/usr/bin/env bash
set -eo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
# --max-size is an approximate uncompressed dataframe-directory target, in bytes.
# The merger combines complete input DFs; it does not split a large existing DF.
INPUT_LIST="${INPUT_LIST:-input_derived.txt}"
OUTPUT_FILE="${OUTPUT_FILE:-FemtoMerged.root}"
MAX_SIZE_BYTES="${MAX_SIZE_BYTES:-100000000}"
[[ ! -e "${OUTPUT_FILE}" ]] || { echo "Output already exists: ${OUTPUT_FILE}" >&2; exit 1; }
o2-aod-merger --input "${INPUT_LIST}" --output "${OUTPUT_FILE}" --max-size "${MAX_SIZE_BYTES}"
