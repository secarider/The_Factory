# SMCUT — SmartCut-Based Intro Removal System

inspired and powered by 'https://github.com/skeskinen/smartcut'

---

## Overview

**SMCUT** is a lightweight, modern replacement pipeline for intro removal and episode trimming.

It replaces large portions of the legacy Factory workflow with a simpler, faster model:

```
IntroFind (pHash) → intro_map.csv → SmartCut batch → SMC_* outputs
```

This approach eliminates the need for global re-encoding, keyframe normalization, and concat-based stitching.

---

## Core Philosophy

### Old Model (Factory)

```
Normalize (REKEY) → Ensure Keyframes → Cut → Stitch → Verify
```

### New Model (SMCUT)

```
Detect → Cut (SmartCut handles seams)
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

### 1. IntroFind (pHash Engine)

* Scans video files using perceptual hashing
* Matches against templates in `intro_template/`
* Writes results to `intro_map.csv`

**Output format:**

```
filename,start,end,start_hms,end_hms,template_used,diff
```

---

### 2. intro_map.csv

Acts as the central instruction file for batch cutting.

Example:

```
Star_Trek_TNG_S05E03_Ensign_Ro.mkv,128,234,00:02:08,00:03:54,intro_template.mkv,10
```

Only the first three columns are required for cutting:

```
filename,start,end
```

---

### 3. SmartCut Engine

Uses either:

* `smartcut` (pipx installed), or
* `smc.app` (AppImage)

Command pattern:

```
--cut start,end,-tail,end
```

Examples:

```
Intro only:
--cut 128,234

Intro + tail:
--cut 128,234,-72,end

Tip + intro + tail:
--cut 0,10,128,234,-72,end
```

---

## Prefix System

All outputs are prefixed:

```
SMC_<original_filename>
```

Example:

```
SMC_Star_Trek_TNG_S05E03_Ensign_Ro.mkv
```

Filtered out during processing:

```
SMC_
SUTURED_
intro_template
```

---

## Template System

Current method:

* Full intro clip stored in `intro_template/`
* Used for matching and duration

Future direction (not implemented yet):

```
Short key clip (~15s) + stored duration metadata
```

---

## Trimming Controls

### Tip Snip

Removes seconds from the beginning of the file

```
0,10
```

### Intro Cut

From IntroFind CSV

```
128,234
```

### Tail Tuck

Removes seconds from the end

```
-72,end
```

---

## Rolling Defaults

Tip and tail values persist during the session:

```
Run 1: Tip=10 Tail=72
Run 2: Press Enter → Tip=10 Tail=72
Run 3: Change Tip=5 → new default becomes 5
```

---

## Dependency Model

### Required

```
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

```
opencv-python (cv2)
pillow (PIL)
imagehash
```

### Optional

```
ffplay
findmnt
less
pipx
```

---

## What Was Removed from Factory

SMCUT does NOT use:

* REKEY normalization
* CRF calibration loops
* keyframe suitability gating
* concat/stitch pipelines
* info.csv ledger system

---

## Safety Features (Recommended)

* Dry-run mode (preview cuts)
* Skip existing outputs
* Pre-run summary confirmation
* Batch success/fail counters

---

## Usage Flow

1. Build template:

```
create_template
```

2. Run IntroFind:

```
run_introfind_phash_batch
```

3. Run SmartCut:

```
smartcut_from_csv
```

or combined:

```
IntroFind → SmartCut
```

---

## Design Status

```
✔ IntroFind batch working
✔ CSV generation stable
✔ SmartCut batch successful
✔ Tip/Tail trimming integrated
✔ Rolling defaults implemented

⚠ Template system still full-length
⚠ No dry-run toggle yet
⚠ No persistent config file yet
```

---

## Future Enhancements (Planned)

* Key-clip template system (15s keys)
* Persistent config (save defaults)
* Dry-run / preview mode
* Parallel SmartCut batch mode
* Engine selection (Factory vs SMCUT)
* Pilot-run validation mode

---

## Summary

SMCUT represents a shift from:

```
heavy preprocessing + safe cutting
```

to:

```
smart cutting with minimal preprocessing
```

It achieves equivalent visual results with drastically reduced complexity and processing time.

---

End of document.

