![The_Factory Logo](TheFactory.png)
# THE_FACTORY

A terminal-driven video processing pipeline designed for non-destructive, batch-safe, intro-aware media preparation.

THE_FACTORY automates complex, repetitive workflows such as intro detection, clean cutting, subtitle handling, metadata repair, and batch normalization—while preserving original files at every stage.

---

## PURPOSE

THE_FACTORY exists to:

- process full media sets (e.g., TV seasons) safely  
- automate intro detection and removal  
- normalize sources for reliable downstream operations  
- maintain continuity across runs using file-based state  

---

## CORE DESIGN

### Non-Destructive Workflow

- Original files are never modified directly  
- OEM backups are created and protected  
- All processing occurs on derived files  

---

### Pipeline-Based Processing

THE_FACTORY is structured as a staged pipeline:

Each stage builds on the previous, ensuring consistent and predictable results.

---

### File-Based State Tracking

THE_FACTORY uses persistent CSV files to maintain continuity:

- `intro_map.csv` — detected intro boundaries  
- `episodes.csv` — episode naming and mapping  
- `info.csv` — processing cache and REKEY validation  

This enables:
- resume-safe operation  
- caching of expensive operations  
- consistent file identity across runs  

---

## KEY DESIGN PRINCIPLES

### Stream-Copy First

- Prefer stream copy wherever possible  
- Avoid re-encoding unless required  
- Preserve quality and maximize speed  

---

### Human-Readable Feedback

- Color-coded terminal output  
- Clear status indicators  
- Verbose progress and diagnostics  

---

### Safe Interaction Model

- 10-key friendly input  
- Time formats supported:
  - seconds (`120`)
  - `hh:mm:ss`
  - decimal (`2.20`)
- Exit tokens:
  - `0`
  - `q`

---

### Dependency Awareness

- Built-in dependency checks  
- Clear reporting of missing tools  
- Optional enhancements supported  

---

## REQUIREMENTS

### Core

- ffmpeg / ffprobe  
- bc  
- awk / sed / grep  
- coreutils  

### Optional

- mkvtoolnix (`mkvpropedit`)  
- python3  
- pipx  
- scenedetect (OpenCV backend)  

---

## TYPICAL USE CASE

Processing a full TV season:

1. Place `factory.sh` inside the episode folder  
2. Launch the script  
3. Follow guided pipeline stages  

Typical flow:

- OEM_Backups  →  Copy Eligible Targets To `OEM dir` and Prefix the name with `OEM_filename` 
- Check Sources suitability for clean cuts and if "Risky"
- Allow `REKEY_rebuild` of files for perfect cuts and joins thanks to a 1 second keyframe rate
- Everything comes out MKV no matter what it was going in That Is All. exception is OEM_backups they are whatever they were
- Build Template → create example of the intro reference, hopefully from `REKEY_ Sources`
- Detect Intros → `This Is Magic Right Here Folks` IntroFind finds the intro and enters times into generated `intro_map.csv`  
- Run GAPMAN → remove intros cleanly, make minor adjustments of cut times "if needed" with ( pre , post , overall drift, start of, end of ) intro cut padding
- Apply Title / Subtitle fixes and set what you see in the titlebar of your player not just filenames
- Finalize outputs → cleanup and rename files, dump temps, originals, and decide what to do with protected OEM_backups, option to tar them up 

---

## WHAT THE_FACTORY DOES

### 1. Source Preparation (OEM Protection)

- Creates protected backups of originals  
- Applies prefix-based shielding to prevent reprocessing  
- Displays disk usage and warnings  

**Outputs:**

---

### 2. Batch Normalizer (REKEY Pipeline)

- Converts sources into cut-friendly format  
- Enforces controlled GOP structure (~1s keyframes)  
- Aligns encoding for safe downstream operations  
- Uses rolling output evaluation to detect unexpected growth or shrink behavior  
- Can adapt CRF strategy based on real file results during a batch  

Throughput is safety-driven rather than purely speed-driven.  
When adaptive normalization logic is active, parallelism may be reduced so each completed file can inform later decisions.

---

### 3. Template Builder

- Extracts clean intro templates from sources  
- Uses manual time selection for precision  
- Normalizes output to MKV  

Templates stored in: working_dir/intro_template

---

### 4. Intro Detection (IntroFind Engine)

- Uses perceptual hashing (pHash)  
- Multi-anchor matching (e.g., 3s, 5s, 7s)  
- Scans timeline for best match  

Produces:

- `intro_map.csv` (start/end per episode)

Displays:

- confidence scoring  
- ranked candidates  
- diagnostic insight  

---

### 5. GAPMAN (Intro Removal Engine)

- CSV-driven batch processing  
- Removes intros using stream-copy concat  

Supports:

- global offset adjustment  
- pre-trim (logos)  
- post-trim (credits)  

**Outputs:** SUTURED_file_name.mkv

---

### 6. Subtitle Processing (SUBTOX)

- Pack external `.srt` into video  
- Extract internal subtitle tracks  
- Rename using `episodes.csv` mapping  

**Outputs:**

---

### 7. Metadata & Playback Fix (BARFIX)

- Fix title metadata (player-visible titles)  
- Set playback defaults:
  - preferred audio (English if available)  
  - subtitles disabled by default  

Modes:

- metadata-only  
- playback-only  
- combined  

**Outputs:**

---

### 8. Cleanup / Finalization

- Promotes `SUTURED_` files to final outputs  
- Handles OEM backups:
  - archive  
  - delete  
  - retain  
- Removes temporary artifacts  
- Marks completed directories  

---

### 9. Manual Tools

- Custom segment cutting  
- Clip joining  
- File inspection tools  
- ffprobe-based comparison  

**Outputs:**

---

## FILE NAMING & NORMALIZATION

- Enforces underscore-based naming  
- Aligns with `SxxExx` conventions  
- Supports user-selected title segment offsets  
- Removes illegal or problematic characters  

---

## PHILOSOPHY

THE_FACTORY is designed to be:

- non-destructive  
- deterministic  
- scalable  
- interruption-safe  
- transparent  

> Complex work, made repeatable.  
> Destructive operations, made deliberate.  
> Results you can trust.
