#!/usr/bin/env bash
set -eo pipefail

# === setup ===
# Run from this example directory, even when invoked from the repository root.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Try one of these if your connection to AliEn/CCDB is slow.
# export alien_CLOSE_SE=ALICE::Vienna::EOS
# export alien_CLOSE_SE=ALICE::ORNL::EOS
# export alien_CLOSE_SE=ALICE::UPB::EOS
# export alien_CLOSE_SE=ALICE::CCIN2P3::SE
# export alien_CLOSE_SE=ALICE::GSI::SE2
# export alien_CLOSE_SE=ALICE::FZK::SE

# Memory settings in GB; override for the machine used in the demonstration.
SHM_SEGMENT_SIZE="${SHM_SEGMENT_SIZE:-16}"
AOD_MEMORY_RATE_LIMIT="${AOD_MEMORY_RATE_LIMIT:-12}"
SHM_SEGMENT_SIZE_BYTES=$((SHM_SEGMENT_SIZE << 30))
AOD_MEMORY_RATE_LIMIT_BYTES=$((AOD_MEMORY_RATE_LIMIT << 30))

PIPELINE="${PIPELINE:-propagation-service:1,femto-producer:1}"
CONFIG_FILE="${CONFIG_FILE:-configuration.json}"
INPUT_DATA_FILE="${INPUT_DATA_FILE:-@input_data.txt}"

if [[ "${1:-}" == --dry-run ]]; then
        FinalOptions=(--dump-workflow --dump-workflow-file workflow.json)
else
        FinalOptions=(--run)
if ! alien-token-info &>/dev/null; then
        echo 'Initializing ALIEN token...'
        alien-token-init
fi
fi

Options=(
        -b
        --configuration "json://${CONFIG_FILE}"
        --pipeline "${PIPELINE}"
        --shm-segment-size "${SHM_SEGMENT_SIZE_BYTES}"
        --aod-memory-rate-limit "${AOD_MEMORY_RATE_LIMIT_BYTES}"
        --aod-file "${INPUT_DATA_FILE}"
)

# === analysis pipeline ===
o2-analysis-cf-femto-producer "${Options[@]}" |
        o2-analysis-cf-femto-track-qa "${Options[@]}" |
        o2-analysis-cf-femto-v0-qa "${Options[@]}" |
        o2-analysis-cf-femto-producer-collision-tagger "${Options[@]}" |
        o2-analysis-cf-femto-pair-track-v0 "${Options[@]}" |
        o2-analysis-lf-strangenesstofpid "${Options[@]}" |
        o2-analysis-tracks-extra-v002-converter "${Options[@]}" |
        o2-analysis-event-selection-service "${Options[@]}" |
        o2-analysis-multcenttable "${Options[@]}" |
        o2-analysis-ft0-corrected-table "${Options[@]}" |
        o2-analysis-propagationservice "${Options[@]}" |
        o2-analysis-pid-tof-merge "${Options[@]}" |
        o2-analysis-pid-tpc-service "${Options[@]}" "${FinalOptions[@]}"
