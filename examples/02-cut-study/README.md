# Example 2: pass-through production and cumulative QA cuts

Run one producer and five independent QA consumers in a single workflow:

```bash
bash examples/02-cut-study/run.sh
```

The input list points to `../../AO2D.root`. A valid O2Physics environment and AliEn token are needed. Output is `AnalysisResults.root` in this directory. The same memory/configuration override conventions as Example 1 apply. For workflow assembly only:

```bash
bash examples/02-cut-study/run.sh --dry-run
```

## What pass-through does

`TrackBits.passThrough = "true"`:

- bypasses rejection by track prefilters as well as the minimal/optional acceptance gate;
- evaluates configured decisions and retains the loosest threshold bits too;
- makes the track decisions neutral in the selection metadata.

Filter QA still records the configured comparisons; they no longer discard tracks. `CollisionBits.passThrough` remains false, so the ordinary collision selection is shared by every wagon: minimal RCT (`CBT_hadronPID`), optional sel8, and disabled same-bunch pileup selection. The baseline is thus no additional **track** selection, not an unselected collision sample.

The bit layout differs from Example 1. The relevant verified values here are:

| Decision | Value |
| --- | --- |
| TPC clusters >=90 | 1 |
| Crossed rows >=100 | 16 |
| ITS clusters >=5 | 512 |
| TPC proton PID within -3 to 3 | 32768 |
| Combined TPC+TOF proton PID <=3 | 131072 |

## QA wagons

`--workflow-suffix` gives each executable a distinct task/configuration/output name:

| Task suffix | New requirement | Low mask | High mask |
| --- | --- | --- | --- |
| `-base` | None | `"0"` | `"0"` |
| `-clusters` | TPC clusters >=90 | `"1"` | `"1"` |
| `-rows` | Crossed rows >=100 | `"17"` | `"17"` |
| `-its` | ITS clusters >=5 | `"529"` | `"529"` |
| `-pid` | Proton PID | `"33297"` | `"131601"` |

The requirements accumulate in each mask. The QA tasks all read the same producer tables: the task order in the shell pipe does not chain their selections. All charge signs are retained, broad QA kinematic bounds avoid additional track cuts, and the PID switch is at total momentum 0.75 GeV/c. Configured pion PID remains available but no pion veto is applied in these wagons.

The five wagons write separate QA directories in `AnalysisResults.root`. Two-dimensional plots are disabled consistently to keep output size down.

The workflow names, cumulative masks, pass-through metadata and task initialization were checked locally. Full event processing still needs a valid AliEn token for CCDB. The comparison script was checked with synthetic counts.

On Hyperloop use the same pass-through producer and repeated QA wagons with unique names and their matching options. Compare the separate wagon outputs. These are ordered incremental efficiencies, not independent per-cut efficiencies.
