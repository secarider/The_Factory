![The_Factory Logo](TheFactory.png)
# THE_FACTORY

# SMCUT — SmartCut-Based Intro Removal System

The Factory Runs On SmartCut

Inspired and Powered by `https://github.com/skeskinen/smartcut`

Support Them Here `https://smartmediacutter.com/`

Inspired by `https://github.com/mifi/lossless-cut`

---

## Overview

**SMCUT** is a lightweight, modern replacement pipeline for intro removal and episode trimming.

It replaces large portions of the legacy Factory workflow with a simpler, faster model:

`
IntroFind (pHash) → intro_map.csv → SmartCut Batch → SMC_* Outputs
`

This approach eliminates the need for global re-encoding, keyframe normalization, and concat-based stitching.

---

## SmartCut Replaces GAPMAN

SmartCut (SMC) is now the preferred cutting engine within Factory.

The older GAPMAN workflow relied on keyframe alignment, normalization, and stitching operations. While effective, it required additional preprocessing and introduced complexity when working with mixed or imperfect source material.

SmartCut achieves the same goals with significantly less preprocessing while maintaining more accurate cut boundaries. By performing localized re-encoding only where required, SmartCut can remove intros, outros, and other unwanted segments without requiring full-file re-encoding or concat-based reconstruction.

This shift allows Factory to focus on detection, validation, and workflow safety rather than extensive normalization and repair steps.

---

## Core Philosophy

### Old Model (Factory)

```text
Normalize (REKEY)
→ Ensure Keyframes
→ Cut
→ Stitch
→ Verify
```

### New Model (SMCUT)

```text
Detect
→ Cut (SmartCut Handles Seams)
```

---

## Key Advantages

* No full-file re-encode required
* No GOP/keyframe dependency issues
* Seamless cuts via localized re-encoding
* Faster batch processing
* Simpler architecture
* CSV-driven automation

---

## Components

### IntroFind (pHash Engine)

* Scans video files using perceptual hashing
* Matches against templates stored in `intro_template/`
* Writes results to `intro_map.csv`
* Supports adjustable scan depth, step size, hash thresholds, and anchor positions

**Output Format**

```text
filename,start,end,start_hms,end_hms,template_used,diff
```

---

### intro_map.csv

Acts as the central instruction file for batch cutting.

Example:

```text
Some_Show_Series_SxxExx_Named_Episode.mkv,128,234,00:02:08,00:03:54,intro_template.mkv,10
```

Only the first three columns are required for SmartCut processing:

```text
filename,start,end
```

---

### SmartCut Engine

Uses either:

* `smartcut` (pipx installed)
* `smc.app` (AppImage)

Rename the AppImage to:

```text
SMC.App
```

and place it in the working directory alongside Factory.

Command pattern:

```text
--cut start,end,-tail,end
```

Examples:

```text
Intro Only:
--cut 128,234

Intro + Tail:
--cut 128,234,-72,end

Tip + Intro + Tail:
--cut 0,10,128,234,-72,end
```
## Prefix System

All SmartCut outputs are prefixed:

```text
SMC_<original_filename>
```

Example:

```text
SMC_Some_Show_Series_SxxExx_Named_Episode.mkv
```

Factory automatically filters workflow-generated files during processing to prevent accidental reprocessing:

```text
SMC_
SUTURED_
intro_template
```

---

## Template System

### Intro Templates

The current IntroFind workflow uses a full intro clip stored within:

```text
intro_template/
```

The template is used for both matching and duration calculations.

---

### Outro Templates

OutroFind uses a short outro template, typically between 10 and 30 seconds in length.

Unlike intro templates, outro templates are intended only to identify the start of the credits sequence. Template duration is not used for trimming calculations.

This approach improves reliability on difficult content, especially animated series where credits may contain black screens, changing cast cards, or repeated visual patterns.

---

## Trimming Controls

### Tip Snip

Removes unwanted material from the beginning of a file.

Examples:

```text
Network Logo
MGM Lion
Previously On
Sponsor Cards
```

Example cut:

```text
0,10
```

---

### Intro Cut

Generated automatically from IntroFind results:

```text
128,234
```

---

### Outro Cut

Generated automatically from OutroFind results:

```text
1450,end
```

---

### Tail Tuck

Optional fallback trimming from the end of the file when OutroFind is unavailable.

Example:

```text
-72,end
```

---

## Rolling Defaults

Factory maintains session defaults for commonly adjusted values.

Examples:

```text
Run 1: Tip=10 Tail=72
Run 2: Press Enter → Tip=10 Tail=72
Run 3: Change Tip=5 → New Default Becomes 5
```

This allows large batches to be tuned without repeatedly entering the same settings.

---

## Dependency Model

### Required

```text
ffmpeg
ffprobe
awk
sed
grep
df
python3
smartcut (pipx) OR smc.app
```

### Python Modules (IntroFind)

```text
opencv-python (cv2)
pillow (PIL)
imagehash
```

### Optional

```text
ffplay
findmnt
less
pipx
```

---

## What Was Removed From Factory

SMCUT does NOT rely on:

* REKEY normalization
* CRF calibration loops
* Keyframe suitability gating
* Concat/stitch pipelines
* info.csv ledger systems
* Large-scale preprocessing before routine cuts

These tools remain available for rescue and repair workflows but are no longer part of the standard processing path.

---

## Safety Features

Factory emphasizes validation and recoverability throughout the workflow.

### Pilot Validation

* Validate timing before full batches
* Review outputs before committing
* Accept, reject, or retain pilot files

### Processing Protection

* Skip existing outputs
* Pre-run confirmations
* Batch success/fail reporting
* OEM-first workflow
* Archive-before-replace behavior

---

## Usage Flow

### Build Templates

```text
create_template
```

### Generate Intro Maps

```text
run_introfind_phash_batch
```

### Generate Outro Maps

```text
run_outrofind_selected_files
```

### Run SmartCut

```text
smartcut_from_csv
```

Or:

```text
IntroFind
→ OutroFind
→ SmartCut
```

---

## Design Status

* ✔ IntroFind batch working
* ✔ OutroFind batch working
* ✔ CSV generation stable
* ✔ SmartCut batch successful
* ✔ Intro + Outro map integration
* ✔ Pilot validation mode
* ✔ Tip/Tail trimming integrated
* ✔ Rolling session defaults implemented
* ✔ Barfix Lite integration

## Recently Completed Enhancements

### ✔ Pilot-Run Validation Mode

Factory now supports Pilot Mode validation before committing to a full SmartCut batch.

Pilot runs process either the first file or first few files from a batch and pause for manual review.

This allows verification of IntroFind matches, OutroFind matches, SmartCut cut plans, subtitle behavior, playback defaults, title-bar display, and overall output quality before processing the entire collection.

Pilot review is the stage where timing adjustments are refined. If cuts consistently start or end slightly early or late, users can adjust offsets, padding, tip snips, or tail tucks before committing to a full batch run.

Pilot outputs are tracked independently from production runs and can be accepted, discarded, or retained for further inspection. This dramatically reduces the risk of discovering mapping errors or template issues after a large batch has already completed.

---

### ✔ OutroFind With Short Outro Templates

OutroFind now uses the same perceptual hash engine that powers IntroFind, allowing automatic detection of episode credits and outros using short template clips.

Unlike intro templates, outro templates are intentionally kept short, typically 10–30 seconds, because only a unique signature is needed to locate the beginning of the credits sequence.

Recent enhancements added independent outro tuning controls, including custom anchor positions, hash thresholds, scan step size, and tail scan depth.

These controls have proven especially useful for difficult content such as animated series, where credits may contain repetitive black screens, changing cast cards, or highly variable visual patterns.

---

### ✔ SmartCut Intro + Outro Integration

SmartCut (SMC) now supports unified intro and outro trimming in a single operation.

IntroFind generates `intro_map.csv`, OutroFind generates `outro_map.csv`, and SmartCut automatically merges both maps into a single cut plan.

This allows complete episode cleanup in one pass:

* Optional Tip Snip
* Remove Intro
* Keep Episode
* Remove Outro

The result is a cleaner and more reliable workflow than previous keyframe-normalization and concat-based approaches.

SmartCut performs localized re-encoding only where required while preserving stream-copy behavior across the majority of the file.

---

### ✔ Persistent Session Defaults

Factory now maintains session-level defaults for commonly adjusted settings, including:

* IntroFind tuning values
* OutroFind tuning values
* SmartCut trimming controls
* Barfix Lite preferences

Once a working configuration is discovered, similar content can be processed repeatedly without re-entering the same values for every run.

---

### ✔ Parallel SmartCut Batch Processing

SmartCut batch processing has matured into the primary cutting engine within Factory.

Combined with IntroFind and OutroFind automation, large episode collections can be processed rapidly while maintaining accurate frame-level cuts.

The modern workflow is:

```text
Detect
→ Build Maps
→ Pilot Validation
→ SmartCut Batch
→ Finalize
```

This approach reduces complexity while improving reliability across mixed source material.

---

### ✔ Barfix Lite Integration

Barfix Lite is now integrated directly into the SmartCut workflow.

After successful SMC processing, playback defaults and title-bar metadata can be updated automatically without requiring a separate repair pass.

This allows finished files to inherit improved playback behavior, cleaner title presentation, preferred subtitle defaults, and other metadata refinements while remaining fully compatible with the advanced Barfix tools available for manual correction and rescue work.

The result is a smoother end-to-end workflow where most files receive metadata cleanup automatically while still preserving access to full manual control whenever special handling is required.

---

## Current Workflow

Factory now follows a SmartCut-first workflow.

Media is inspected, repaired if necessary, mapped using IntroFind and OutroFind, validated through Pilot Mode, processed with SmartCut, and finally finalized into the finished library.

Most routine processing no longer requires global normalization, keyframe preparation, or large-scale re-encoding. Those tools remain available for rescue and repair scenarios but are no longer part of the normal processing path.

### Standard Workflow

1. Inspect / Prepare Sources
2. Repair Or Pack External Subtitles (If Needed)
3. Build Intro / Outro Templates
4. Generate Intro / Outro Maps
5. Pilot Validation
6. SmartCut Batch Processing
7. CSV Authority Rename (Optional)
8. Finalize

---

## Summary

SMCUT represents a shift from:

```text
Heavy Preprocessing + Safe Cutting
```

to:

```text
Smart Cutting With Minimal Preprocessing
```

It achieves equivalent visual results with drastically reduced complexity, fewer processing stages, and significantly shorter turnaround times.

SmartCut is now the primary cutting engine within Factory and serves as the foundation for modern IntroFind, OutroFind, Pilot Validation, and automated episode cleanup workflows.
