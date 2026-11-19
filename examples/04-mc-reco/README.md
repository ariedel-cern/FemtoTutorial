# Example 4: reconstructed MC QA and pair FitVars

The default input list points to `../../AO2D_MC.root`, a **raw Run 3 pp MC AO2D with reconstruction and MC labels**, not the data file from Example 1. A suitable local file was found and its metadata checked: `LHC24f3c_fix`, Run 3, DataType MC, anchor pass `apass7`:

```bash
ln -s /tank1/ga45can/OfflineAnalysis/test1/24f3c/68/AO2D.root AO2D_MC.root
bash examples/04-mc-reco/run.sh
```

The convenience symlink is already prepared in this workspace. Alternatively override `INPUT_DATA_FILE` with the absolute filename, or edit the list. The absolute example above is specific to this workstation; supply an appropriate local MC AO2D elsewhere. No grid provenance/download URL is invented for this existing file.

## Full workflow configuration

`configuration.json` enables exactly one producer process, `processTracksV0sRun3ppMc`. The propagation and TPC PID services use MC processing; multiplicity MC truth tables are enabled. MC producer RCT selection is disabled and `sel8` is minimal. Proton/Lambda consumer selections match Example 1, except that producer DCA limits are loosened to 0.5 cm in xy and 1 cm in z to retain template tails. This changes their guaranteed baseline but adds no DCA decision bits, so the proton PID bit positions remain unchanged.

Track QA uses `processMc`; Lambda QA uses `processLambdaMc`. Origin templates are enabled with secondary mothers `["3122", "3222", "3312"]`: the numbered histograms follow that order, with other secondary decays grouped separately. The template axes are `TrackBinning1.fractionDcaXy/fractionDcaZ`; the similarly named QA DCA axes are independent. Every DPL configurable scalar, including vector entries and process flags, is a string.

Pairing uses `processLambdaSameEventMc` and `processLambdaMixedEventMc`. These modes include FitVars: packed detector PID, track DCA and Lambda pointing angle, in addition to MC labels/truth. `TrackCleaner1` and `LambdaCleaner1` remain inactive to retain contamination and feed-down for the composition study. Their full options are explicit in the JSON. Common/non-common ancestry restrictions are also disabled.

**Local MC tagging limitation:** this checkout exposes `processLambdaMixedEventMcWithTagging`, but `Core/collisionTagger.h::discoverTaggedRoles()` matches only names starting with `processLambdaMixedEventWithTagging`. Consequently the MC switch is not discovered and tagged MC initialization fails. The runnable MC example deliberately uses ordinary mixing and omits the tagger. The source checkout was not modified. Example 1 and Example 3 use the working data tagger. Enabling the ordinary data tagged process alongside MC is invalid: the pair task rejects mixed processing families.

## Framework output

`AnalysisResults.root` contains reconstructed QA, MC origin histograms and separate SE/ME pair and constituent histograms. `TrackQA/FitVars/` contains DCA origin templates; pair-task `Track1/{SE,ME}/FitVars/` contains detector PID and DCA histograms, and `Lambda1/{SE,ME}/FitVars/` contains pointing-angle histograms.

SE constituent histograms are filled once per selected particle in a collision with an accepted pair. ME constituent histograms are filled for every accepted mixed pair. The tutorial demonstrates configuring and running these tasks and locating their output.

## Producer-only MC derivation and standalone consumers

```bash
bash examples/04-mc-reco/produce.sh
bash examples/04-mc-reco/analyze.sh
```

`producer-derived.json` explicitly enables full QA, FitVars and MC truth/label tables. `mc-writer.json` writes the corresponding descriptions/versions to `FemtoMC.root`. `analysis-derived.json` contains only the consumers; `analyze.sh` needs no raw-AO2D helper workflows. This richer derived file supports both QA and pairing, unlike the compact six-table data example.

On Hyperloop, the same MC producer/consumer process selections apply to a suitable MC dataset, or consumers run on the derived MC dataset with matching versions. The local writer file is not automatically a Hyperloop output configuration.

Validation: MC task initialization and packed slot assignment were checked with the local raw MC file; complete event processing requires a valid AliEn token for CCDB. Tagged MC startup was tested and its discovery failure identified, then the runnable configuration was changed to untagged mixing.
