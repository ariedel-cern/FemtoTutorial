# Derived-to-derived production

The demonstration starts on Hyperloop: add `o2-analysis-cf-femto-producer-derived-to-derived` to a derived input dataset, configure the particle/collision selections and candidate-count limits, enable the matching process function and select its rewritten output tables. Download the task configuration as `configuration.json` into this directory for the local run.

```bash
bash examples/05-derived-to-derived/run.sh
```

The script is self-contained, changes into this directory and reads `@input_data.txt`. The supplied list points to `../03-derived-data/FemtoDerived.root`; replace it with a downloaded input file. `CONFIG_FILE` and `INPUT_DATA_FILE` override the defaults. `--dry-run` dumps the workflow without processing events. No raw-AO2D helper tasks are needed.

The supplied configuration is an illustrative proton–Lambda selection matching Example 1, not a replacement for the configuration/metadata of a different Hyperloop production. All scalar configuration values are strings.

- Exactly one process is enabled: default `processTracks` is disabled and `processTracksLambdas` enabled.
- `TrackSelection1` keeps both charges (`chargeSign="0"`); its PID masks are the original normal-producer masks 64 and 256. `LambdaSelection1` uses mask 15 and sign 1.
- `TrackTables.limitTrack1="1"` and `V0Tables.limitLambda="1"` require at least one candidate of each category. `limitTrack2="0"` disables the second track category, including its standalone output.
- `CollisionDownsampling.fraction="1"` keeps every collision surviving the selections. A fixed positive seed gives reproducible random downsampling when a smaller fraction is chosen.
- Necessary Lambda daughter tracks are copied regardless of the standalone-track cuts; row indices and references are remapped, and reused tracks are deduplicated. Stored masks are copied unchanged.

`writer.json` selects the rewritten **AOD1** tables, rather than the incoming AOD tables, and writes `FemtoSkim.root`. This file can feed another derived-to-derived pass or ordinary consumers. Recompute collision tags in the final analysis workflow for the current consumer selections. Discarded particles, detector observables or threshold decisions cannot be recovered by later passes.

For Lite input, as illustrated in the Hyperloop screenshots:

```bash
LITE_INPUT=1 bash examples/05-derived-to-derived/run.sh
```

This prepends `o2-analysis-cf-femto-producer-lite-converter`; its configuration enables collision, track and Lambda conversion. Keep these converter switches in a downloaded configuration when using this option. Conversion exposes the binned Lite kinematics through the full table interface; it does not restore precision lost during Lite production. Masks must be available in the input too.

The ordinary six-table example does not contain detailed QA or FitVars information. `WithFitVars` and MC process variants require the corresponding extra input tables and writer descriptors.

Validation: shell/JSON checks, workflow assembly, and execution on an empty six-table schema fixture succeeded. `FemtoSkim.root` was written through the AOD1 descriptors. This validates the input/output contract and startup, not event-level physics or a particular Hyperloop dataset.
