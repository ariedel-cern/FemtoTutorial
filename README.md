# Femto framework tutorial

An instructor-led demonstration, with local and Hyperloop examples. The introduction covers production, selection bitmasks, minimal/optional/neutral selections and CutCulator. Hands-on examples then build towards a proton–Lambda correlation function.

## Slides

Main Beamer document: [slides/main.tex](slides/main.tex).
Introductory slides: [slides/introduction.tex](slides/introduction.tex).
Compiled presentation: [slides/main.pdf](slides/main.pdf).

Build from the project root with the installed TeX distribution and `latexmk`:

```bash
latexmk
```

The project [`.latexmkrc`](.latexmkrc) selects `slides/main.tex`, writes the PDF to `slides/main.pdf`, and keeps intermediate files and logs in `.cache/beamer/`. Use `latexmk -pvc` to watch for changes and recompile automatically, or `latexmk -c` to clean intermediate files. The wrapper `bash scripts/build-slides.sh` runs the same build from any working directory.

Formatting preferences are in [`.latexindent.yaml`](.latexindent.yaml): two spaces, no paragraph reflow, no extra indentation after list items, and preserved table/listing layout. To format a file explicitly (requires `latexindent`):

```bash
mkdir -p .cache/latexindent
latexindent -l=.latexindent.yaml -c=.cache/latexindent -w slides/main.tex
```

Use the same `-l=.latexindent.yaml` option in your editor's formatter settings. Existing sources have not been reformatted automatically.

The source includes speaker notes with implementation details and suggested explanations. All introductory material, including selection types and CutCulator, is contained in `slides/introduction.tex`. Terminal and GUI CutCulator screenshots are stored in `slides/assets/`. After CutCulator, [slides/example-proton-lambda.tex](slides/example-proton-lambda.tex) introduces the first live example. Previous standalone explanations are preserved in `slides/reference-material.tex` and `slides/producer-configuration.tex` but are no longer included in the presentation.

## Example 1: proton–Lambda from AO2D

The complete producer + proton QA + Lambda QA + proton–Lambda pair chain is prepared for live changes, organized into producer configuration, QA and pairing. The slides describe the selections and resulting distributions; executable commands remain in the example scripts and instructions. Inside an O2Physics environment:

```bash
bash scripts/download-input.sh
bash examples/01-proton-lambda/run.sh
```

See [Example 1 instructions](examples/01-proton-lambda/README.md), [run.sh](examples/01-proton-lambda/run.sh), and [configuration.json](examples/01-proton-lambda/configuration.json). The input list points to the root-level `AO2D.root`; output stays in the example directory. All JSON scalar values are strings. The input download command and grid path are in [scripts/download-input.sh](scripts/download-input.sh).

## Example 2: pass-through cut study

```bash
bash examples/02-cut-study/run.sh
```

One pass-through producer feeds five independent QA wagons, with cumulative cuts from a baseline to proton PID. See [Example 2 instructions](examples/02-cut-study/README.md). In the current implementation, pass-through bypasses track prefilter rejection as well as bit-based acceptance; collision selection remains enabled in this example.

All raw-AO2D examples support `run.sh --dry-run` for workflow assembly without processing events. Workflow/task initialization and mask assignments were checked; completing event processing requires a valid AliEn token for CCDB.

## CutCulator demonstration

Use a Python environment with PyROOT. The GUI also requires tkinter and a graphical display. These wrappers invoke the existing tools in the local O2Physics checkout; they do not copy or modify them.

```bash
bash scripts/cutculator.sh tui /path/to/producer/AnalysisResults.root
bash scripts/cutculator.sh tui /path/to/producer/AnalysisResults.root --bitmask
bash scripts/cutculator.sh gui /path/to/producer/AnalysisResults.root
```

The default ROOT directory is `femto-producer`; override it with `--dir` when necessary. The launcher defaults to `$HOME/alice/O2Physics`; set `O2PHYSICS_SRC` to use a different checkout. Use the producer QA output matching the derived-data production, including its selection histogram metadata. TUI decode mode (`--bitmask`) is present in this local installation.

Minimal selections are mandatory at their loosest threshold; optional selections form an OR at producer acceptance; neutral selections do not gate acceptance. Consumer required masks require every selected bit; rejection masks veto any selected bit. The producer's optional OR does not turn a consumer required mask into an OR. Bit positions in the explanatory slides are illustrative, not configuration values.

Primary references are the installed files under `/tank1/ga45can/alice/O2Physics/PWGCF/Femto/`. The demonstration examples cover the full proton–Lambda chain, cumulative track cuts, derived data and reconstructed MC.

## Derived-data and MC demonstrations

[Example 3](examples/03-derived-data/README.md) provides producer-only table writing, standalone tagged proton–Lambda pairing and a local `o2-aod-merger` wrapper. [Example 4](examples/04-mc-reco/README.md) provides reconstructed MC QA, origin histograms, pair FitVars, and full MC derivation/standalone consumers.

The deck now has separate [derived-data](slides/example-derived-data.tex) and [MC](slides/example-mc-reco.tex) sources after the cut study. The main entry point remains `slides/main.tex`. QA/pair histogram layouts, configurable axes, all mixing and CPR controls, shared-track pair cleaning and collision tagging are included in Example 1.

The local MC tagging switch has a discovery bug; the runnable MC demonstration uses ordinary MC mixing. Data examples use the collision tagger. See the MC README for the exact limitation and the available FitVars observables.


## Derived-to-derived workflow

The [derived-to-derived run script](examples/05-derived-to-derived/run.sh) accepts a downloaded Hyperloop `configuration.json`, with local writer settings alongside it. See the [workflow instructions](examples/05-derived-to-derived/README.md), including optional Lite-input conversion. Its slides appear before MC; the summary closes the presentation.
