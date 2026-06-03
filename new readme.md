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

```
IntroFind (pHash) → intro_map.csv → SmartCut batch → SMC_* outputs
```

This approach eliminates the need for global re-encoding, keyframe normalization, and concat-based stitching.

## That Makes GAPMAN Old And Not The Tool Of Choice

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
* `smc.app` (AppImage) SmartMediaCutter-2.3.4-x86_64.AppImage

🔹 OUTRO DETECTION + SMARTCUT (SMC) WORKFLOW
Overview

Factory now supports automatic outro (credits) detection using the same perceptual hash engine as IntroFind.

This enables a full episode trim in one pass:

[ optional tip snip ] +
remove intro +
keep main content +
remove outro (credits)

All without manual timing or guesswork.

🔹 Trigger Conditions (IMPORTANT)

Outro detection is auto-enabled only when:

intro_template/outro.mkv exists

If outro.mkv is NOT present:

→ IntroFind runs normally (intro only)
→ SmartCut performs intro removal + optional tail tuck

If outro.mkv IS present:

→ IntroFind runs (intro detection)
→ OutroFind runs automatically (end-window scan)
→ outro_map.csv is generated
→ SmartCut uses BOTH intro_map.csv AND outro_map.csv
🔹 How Outro Detection Works

Factory does NOT invent a new engine.

Instead it reuses IntroFind with a different scan window:

Scan Start = file_duration - OUTRO_SCAN_BACK_SECONDS (default: 240)
Scan Limit = file_duration
Template   = intro_template/outro.mkv

So detection occurs only in the last ~4 minutes of the file.

🔹 Outro Template Requirements

Unlike intro templates:

intro_template.mkv → full intro length (e.g. 106s)

Outro templates should be:

SHORT (recommended: 10–30 seconds)

Why:

We only need a unique visual/audio signature to FIND the start of credits.
We do NOT use template duration for cutting.
🔹 Cut Behavior (CRITICAL DIFFERENCE)
Intro:
cut intro_start → intro_end (uses template duration)
Outro:
cut outro_start → END OF FILE

SmartCut uses:

--cut "intro_start,intro_end,outro_start,end"

The outro_end value is informational only.

🔹 New SmartCut (SMC) System
Replacement for GAPMAN
OLD: GAPMAN (CSV concat / stream copy)
NEW: SMC (SmartCut engine)

SMC advantages:

✔ Keyframe-aware cutting (no large timing drift)
✔ Minimal re-encode only when needed
✔ No concat stage required
✔ Handles intro + outro in one command
✔ More accurate on imperfect sources
🔹 Why GAPMAN Is No Longer Preferred

GAPMAN relies on:

- strict keyframe alignment
- normalized GOP structure
- concat stitching

Which leads to:

✖ 6–10 second timing drift on bad sources
✖ fragile behavior across mixed encodes
✖ extra pipeline complexity

SMC replaces this with:

✔ adaptive micro re-encode at cut boundaries
✔ accurate frame-level cuts
✔ simpler pipeline
🔹 SmartCut Pipeline (Current)
1) IntroFind → intro_map.csv
2) OutroFind (if outro.mkv exists) → outro_map.csv
3) SmartCut reads BOTH maps
4) Builds unified cut plan:
   intro_start,intro_end,outro_start,end
5) Produces SMC_<file>
🔹 Optional Controls

Available in SmartCut menu:

Tip Snip Seconds        → trims from beginning

Tail Tuck Seconds      → trims from end (fallback if no outro)

Intro Pre/Post Pads    → fine tune intro cut

Outro Pre-Pad          → adjust outro start earlier/later

Global Offset          → shifts intro window

🔹 Fallback Behavior

If OutroFind fails or is not present:

SMC falls back to:
intro removal + tail tuck (fixed seconds)
🔹 Key Design Philosophy
Reuse proven tools instead of building new ones.

OutroFind is not a new system:

It is IntroFind applied to the end of the file.
🔹 Bottom Line
If you have outro.mkv → full automatic episode trimming
If you don’t → intro-only trimming still works

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
additional text.

🔹 OUTRO DETECTION + SMARTCUT (SMC) WORKFLOW
Overview

Factory now supports automatic outro (credits) detection using the same perceptual hash engine as IntroFind.

This enables a full episode trim in one pass:

[ optional tip snip ] +
remove intro +
keep main content +
remove outro (credits)

All without manual timing or guesswork.

🔹 Trigger Conditions (IMPORTANT)

Outro detection is auto-enabled only when:

intro_template/outro.mkv exists

If outro.mkv is NOT present:

→ IntroFind runs normally (intro only)
→ SmartCut performs intro removal + optional tail tuck

If outro.mkv IS present:

→ IntroFind runs (intro detection)
→ OutroFind runs automatically (end-window scan)
→ outro_map.csv is generated
→ SmartCut uses BOTH intro_map.csv AND outro_map.csv
🔹 How Outro Detection Works

Factory does NOT invent a new engine.

Instead it reuses IntroFind with a different scan window:

Scan Start = file_duration - OUTRO_SCAN_BACK_SECONDS (default: 240)
Scan Limit = file_duration
Template   = intro_template/outro.mkv

So detection occurs only in the last ~4 minutes of the file.

🔹 Outro Template Requirements

Unlike intro templates:

intro_template.mkv → full intro length (e.g. 106s)

Outro templates should be:

SHORT (recommended: 10–30 seconds)

Why:

We only need a unique visual/audio signature to FIND the start of credits.
We do NOT use template duration for cutting.
🔹 Cut Behavior (CRITICAL DIFFERENCE)
Intro:
cut intro_start → intro_end (uses template duration)
Outro:
cut outro_start → END OF FILE

SmartCut uses:

--cut "intro_start,intro_end,outro_start,end"

The outro_end value is informational only.

🔹 New SmartCut (SMC) System
Replacement for GAPMAN
OLD: GAPMAN (CSV concat / stream copy)
NEW: SMC (SmartCut engine)

SMC advantages:

✔ Keyframe-aware cutting (no large timing drift)
✔ Minimal re-encode only when needed
✔ No concat stage required
✔ Handles intro + outro in one command
✔ More accurate on imperfect sources
🔹 Why GAPMAN Is No Longer Preferred

GAPMAN relies on:

- strict keyframe alignment
- normalized GOP structure
- concat stitching

Which leads to:

✖ 6–10 second timing drift on bad sources
✖ fragile behavior across mixed encodes
✖ extra pipeline complexity

SMC replaces this with:

✔ adaptive micro re-encode at cut boundaries
✔ accurate frame-level cuts
✔ simpler pipeline
🔹 SmartCut Pipeline (Current)
1) IntroFind → intro_map.csv
2) OutroFind (if outro.mkv exists) → outro_map.csv
3) SmartCut reads BOTH maps
4) Builds unified cut plan:
   intro_start,intro_end,outro_start,end
5) Produces SMC_<file>
🔹 Optional Controls

Available in SmartCut menu:

Tip Snip Seconds        → trims from beginning
Tail Tuck Seconds      → trims from end (fallback if no outro)
Intro Pre/Post Pads    → fine tune intro cut
Outro Pre-Pad          → adjust outro start earlier/later
Global Offset          → shifts intro window
🔹 Fallback Behavior

If OutroFind fails or is not present:

SMC falls back to:
intro removal + tail tuck (fixed seconds)
🔹 Key Design Philosophy
Reuse proven tools instead of building new ones.

OutroFind is not a new system:

It is IntroFind applied to the end of the file.
🔹 Bottom Line
If you have outro.mkv → full automatic episode trimming
If you don’t → intro-only trimming still works

SMC is now the primary cutting engine going forward.

