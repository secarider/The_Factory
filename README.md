![The_Factory Logo](TheFactory.png)
THE_FACTORY

A terminal-driven video processing pipeline designed for non-destructive, batch-safe, intro-aware media preparation.

Built around real-world workflows, THE_FACTORY automates common but complex tasks such as intro detection, clean cutting, subtitle handling, metadata repair, and batch normalization — all while preserving original files.

What It Does

1. Source Preparation (Non-Destructive)
THE_FACTORY Creates OEM backups of original files
If you allow, THE_FACTORY builds cut-friendly versions
(REKEY_) using controlled GOP structure
Ensures consistent:
frame rate (CFR)
keyframe spacing (~1 second)
codec alignment for safe stream-copy operations

Outputs:
OEM_original.*

3. Batch Normalizer (REKEY Pipeline)
Converts source files into cut-safe format
Standardizes:
keyframe intervals
encoding structure
Supports concurrency levels:
light (1 job)
medium (3 jobs)
thrash (max parallel)

Outputs:
REKEY_original.mkv

5. Template Builder
Using our nice rekey sources The_Factory 
Creates reusable intro templates from any source
manual time selection clean extraction + normalization to mkv 
As it makes all future processing consistent and it is the hottest container
Automatically creates and stores templates in:

Outputs:
intro_template.mkv

6. Intro Detection (IntroFind Engine)
Uses perceptual hashing (pHash) for visual matching
Multi-anchor detection model (e.g., 3s, 5s, 7s offsets)
Scans across early timeline for best match
Produces:
intro_map.csv (start/end per episode) calculated from key lenght
Displays:
confidence scoring
ranked candidates
debug insight into detection quality

Outputs:
intro_map.csv

7. GAPMAN (Intro Removal Engine)
CSV-driven batch processing (intro_map.csv)
Removes intros using:
stream-copy concat (no re-encode)
Supports:
global offset adjustment
pre-trim (logos)
post-trim (credits)

Outputs:
SUTURED_original.mkv

8. Subtitle Processing (SUBTOX)
Pack external .srt into video
Extract internal subtitle tracks
Rename files using:
episodes.csv mapping
automatic title cleanup

Outputs:
SUBPACKED_original.mkv

9. Metadata & Playback Fix (BARFIX)
Fix title metadata (MKV in-place when possible)
Set playback defaults:
preferred audio (English if available)
disable subtitles by default
Supports:
metadata-only mode
playback-only mode
combined mode

Outputs:
BARFIX_original.mkv (if remux required)

10. Cleanup / Finalization
Promotes:
SUTURED_ → final filenames
Handles OEM backups:
archive
delete
retain
Removes temporary artifacts
Marks processed directories
Key Design Principles
Non-Destructive Workflow
Original files are never modified directly.
Pipeline-Based Processing
Typical flow:
Inspect → Prepare → Template/Detect → GAPMAN → Title/Sub → Cleanup
Stream-Copy First
Where possible:
no re-encoding
no quality loss
fast processing
Human-Readable Feedback
color-coded output
clear status indicators
verbose progress and diagnostics
File-Based State Tracking

11. Manual Tools
Custom segment cutting
Clip joining
File inspection tools
ffprobe-based diffing

Outputs:
custom_cut.mkv

Uses:
intro_map.csv,
episodes.csv,
info.csv,
to maintain workflow continuity and caching.

Requirements:

Core:
ffmpeg / ffprobe,
bc,
awk / sed / grep,
coreutils

Optional:
mkvtoolnix (mkvpropedit),
pipx + scenedetect (OpenCV),
python3 (IntroFind engine),

Typical Use Case
Processing a full TV season:

Drop factory.sh into episodes folder
run it do stuff
Run Template Builder (once) make one really good key and usually one per 
season as the intros often change per season 

Run Intro Detection
Run GAPMAN
Apply Title / Subtitle fixes
Finalize outputs
