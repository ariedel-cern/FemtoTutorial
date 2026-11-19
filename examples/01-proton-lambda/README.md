# Example 1: proton–Lambda from AO2D

The final workflow is already configured. Introduce it through five live steps:

1. Set up the producer for protons: `TrackFilters`, minimal track quality, optional proton PID, neutral pion PID, and the producer TOF threshold.
2. Enable `femto-track-qa` and inspect proton QA and the producer metadata.
3. Switch from `processTracksRun3pp` to `processTracksV0sRun3pp` and inspect `V0Filters` / `LambdaBits`.
4. Enable `femto-v0-qa`, select Lambda candidates with `LambdaSelection1`, and inspect daughter/candidate QA.
5. Enable `femto-pair-track-v0`, inspect same/mixed events and form the correlation.

`run.sh` and `configuration.json` ship with **all five steps enabled**. Collision settings are `rctFlags = "1"` (minimal), `sel8 = "-1"` (optional), and `noSameBunchPileup = "0"` (disabled); the RCT preset is `CBT_hadronPID`. With no triggers or other optional collision selections configured, the optional condition is satisfied by sel8. During the live demonstration, comment out the V0-QA and pair-task lines for the earlier steps and choose the corresponding producer process. Only one producer process should be enabled. The extra helper tasks can remain in the script; their table requirements are resolved by the workflow.

## Run

Load your O2Physics environment, acquire a valid AliEn token, and run from the repository root:

```bash
bash scripts/download-input.sh
bash examples/01-proton-lambda/run.sh
```

The run script enters this example directory. `input_data.txt` contains `../../AO2D.root`. Outputs are `AnalysisResults.root`, `dpl-config.json` in this directory. `alien-token-init` is invoked if token validation fails; the token is required for CCDB even with a local input.

The input-reader's `end-value-enumeration` setting in `configuration.json` controls the number of input timeframes (`-1` processes the full file). Memory limits can be overridden, for example:

```bash
SHM_SEGMENT_SIZE=4 AOD_MEMORY_RATE_LIMIT=1 bash examples/01-proton-lambda/run.sh
```

`PIPELINE`, `CONFIG_FILE`, and `INPUT_DATA_FILE` can also be overridden. The run script keeps the explicit setup/options/pipeline structure so it can be edited live. All JSON scalar values, including array entries, are strings.

Without processing events or requesting a token:

```bash
bash examples/01-proton-lambda/run.sh --dry-run
```

This creates `workflow.json`. It validates assembly, not access to conditions or event processing.

## Proton selections

`TrackFilters` selects standalone tracks with `0.3 < pT < 4 GeV/c` and `|eta| < 0.8`. Minimal quality thresholds include TPC clusters `[90,100,110]`, crossed rows `[80,100,110]`, ITS clusters `[5,6]` and the DCA/other quality settings. Only tighter quality thresholds need stored bits in normal production.

`requirePidProton = "true"` makes the configured proton PID decisions optional. `requirePidPion = "false"` leaves the configured pion PID decision neutral: it cannot admit a candidate but is available for a later veto. `minMomTofProton = "0.75"` gates proton acceptance on TOF presence at `p >= 0.75 GeV/c`.

The QA and pair consumers use the same positive-proton selection: TPC PID below `pidThres = "0.75"` and combined TPC+TOF PID above it. Producer acceptance is an OR of its configured optional decisions; the consumer explicitly requires its selected bits. No pion veto is applied initially.

Verified normal-production mapping:

| Decision | Bit | Value |
| --- | --- | --- |
| TPC clusters >=100 / >=110 | 0 / 1 | 1 / 2 |
| Crossed rows >=100 / >=110 | 2 / 3 | 4 / 8 |
| ITS clusters >=6 | 4 | 16 |
| TPC pion PID, -3 to 3 | 5 | 32 |
| TPC proton PID, -3 to 3 / -2.5 to 2.5 | 6 / 7 | 64 / 128 |
| Combined TPC+TOF proton PID, 3 / 2.5 | 8 / 9 | 256 / 512 |

The required masks are `"64"` and `"256"`. To demonstrate a pion veto later, use `"32"` in the relevant rejection-mask fields. Recompute masks with CutCulator when threshold lists change.

## Lambda selections

`V0Filters` retains a broad production mass window, 1.08–1.16 GeV/c². `LambdaBits` contains minimal topology and daughter-quality/PID selections. The Lambda QA and pair consumers both use `sign = "1"`, a 1.11–1.12 GeV/c² mass window, and mask `"15"`, requiring:

| Decision | Bit | Value |
| --- | --- | --- |
| CPA >=0.995 | 0 | 1 |
| Daughter DCA <=1.0 cm | 1 | 2 |
| Positive daughter TPC proton PID <=3 in absolute value | 2 | 4 |
| Negative daughter TPC pion PID <=3 in absolute value | 3 | 8 |

These bit assignments were verified during local producer initialization. The broader minimal baselines remain guaranteed. Anti-Lambda has a different daughter assignment; this example explicitly selects Lambda.

## Pair output

The pair task fills same- and mixed-event histograms under `femto-pair-track-v0/TrackV0/SE/Analysis/` and `TrackV0/ME/Analysis/` in `AnalysisResults.root`.

## Validation and Hyperloop

Shell/JSON syntax, workflow assembly, input metadata, producer masks and task initialization were checked locally. Initialization reaches the Femto tasks, but event processing stops because this session lacks a valid AliEn token for CCDB. A complete physics output has not been validated.

For Hyperloop use the corresponding producer, track QA, V0 QA and track–V0 pair workflows, matching their process switches and the same task-grouped configuration values. Include the event-selection, propagation, multiplicity, TPC/TOF PID and strangeness TOF dependencies. Retrieve the producer and consumer `AnalysisResults.root` output and inspect the same metadata/histograms. No train has been submitted by these scripts.

Input provenance is recorded in `scripts/download-input.sh`: LHC26ad, run 570703, `apass1_sampled`.

## Pair configuration and collision tagging

The final prepared chain includes `o2-analysis-cf-femto-producer-collision-tagger`, with `processTrackLambda` enabled. Pairing uses ordinary same-event processing and `processLambdaMixedEventWithTagging` (the ordinary mixed-event switch is disabled). The tagger reads each wagon's consumer selections and sets a per-wagon bit for collisions containing both selected species. The pair task discovers that bit automatically. Shared-daughter pair cleaning and CPR remain separate checks. This intentionally changes the eligible mixing pool compared with untagged mixing.

The JSON now explicitly exposes the pair binning, all mixing controls, `CprTrackV0Daughter`, `PairCuts`, `PairCleanerBinning` and MC particle-cleaner settings. The slides show their roles and histogram paths. Physics histograms live under the `Analysis/` subdirectory.
