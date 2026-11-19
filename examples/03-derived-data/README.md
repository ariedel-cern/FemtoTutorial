# Example 3: producer-only derivation, then standalone pairing

Run inside the O2Physics environment. The scripts are self-contained and change into this directory. `input_data.txt` points to the root-level raw `AO2D.root`.

```bash
bash examples/03-derived-data/produce.sh
bash examples/03-derived-data/analyze.sh
```

`produce.sh` runs the producer and raw-AO2D helper tasks, without QA or pairing. `producer.json` preserves the producer selections from Example 1 and forces on the six tables needed by ordinary proton–Lambda pairing. All unrelated output tables are explicitly off. `writer.json` selects the matching AOD descriptions and versions, including **FLAMBDAMASK version 2**, and writes `FemtoDerived.root`. Keep the producer's `AnalysisResults.root` with the derived file: it contains the configuration and threshold/filter metadata used by CutCulator.

`analyze.sh` reads `@input_derived.txt`, which contains `FemtoDerived.root`. It runs the collision tagger and pair task with `pair.json`, including tagged mixed-event processing. Raw event selection, propagation and PID services are unnecessary. No AliEn token is initialized for this local derived-only analysis. The tagger recomputes eligibility from the current pair selections; no tag bits are persisted from production. The consumer masks are still specific to the producer configuration that created the file.

The minimal tables do not support full QA, MC or FitVars consumers. Those require additional producer switches **and** writer descriptors. Daughter tracks and their indices are retained by the producer for shared-track cleaning and CPR; they must not be stripped from the derived file.

The producer script also saves `ProducerResults.root` automatically, because standalone analysis writes a new `AnalysisResults.root`. An explicit manual copy is equivalent:

```bash
cp examples/03-derived-data/AnalysisResults.root examples/03-derived-data/ProducerResults.root
```

The prepared scripts retain configurable `CONFIG_FILE`, `INPUT_DATA_FILE`, `PIPELINE` and memory settings. Each supports `--dry-run` to dump the workflow without processing events. Workflow dumps do not validate every required input tree or prove that event processing succeeds.

## Local dataframe merging

```bash
bash examples/03-derived-data/merge.sh
INPUT_DATA_FILE=FemtoMerged.root bash examples/03-derived-data/analyze.sh
```

`merge.sh` accepts `INPUT_LIST`, `OUTPUT_FILE` and `MAX_SIZE_BYTES` overrides and refuses to overwrite an existing output. The default target is 100,000,000 **uncompressed** bytes per output dataframe directory. Complete input DFs are appended until the target is exceeded; this tool does not split an already-large DF. It updates table indices and expects compatible, self-contained inputs. `--max-size 0` preserves DF boundaries for non-self-contained inputs. Do not use `hadd` for AOD tables with row references.

Mixing is bounded by the input dataframe and configured pools, not simply the file size. Re-merging can change the available event-mixing combinations; compare mixing QA and memory use.

## Hyperloop

The corresponding production runs the raw-AO2D producer and dependencies with these selections and explicit output-table settings. The analysis uses the resulting derived dataset with collision-tagger and pair wagons, matching software/table versions and the same consumer settings. `writer.json` is the local DPL writer configuration; Hyperloop output selection is configured through the train's derived-data setup, rather than assuming this file is automatically consumed by Hyperloop.

Validation: the producer's forced table switches and data tagger assignment were checked during task initialization; writer JSON and workflow assembly were checked. Full event processing is blocked in the available environment by the missing AliEn token required by CCDB. No derived physics output is supplied as if it had been validated.

The standalone tagger/pair workflow also completed with exit 0 on an empty six-table schema fixture, and its real ROOT output paths were verified. `o2-aod-merger` completed on the same fixture. These are format/integration checks, not event-level physics validation.
