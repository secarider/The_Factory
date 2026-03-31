![The_Factory Logo](TheFactory.png)
THE_FACTORY

A terminal-driven video processing pipeline designed for non-destructive, batch-safe, intro-aware media preparation.
Uses: intro_map.csv--episodes.csv--info.csv-- To maintain workflow continuity, caching, and Rekey file integrity plus much more.
Non-Destructive Workflow -- Original files are never modified directly. -- Pipeline-Based Processing
THE_FACTORY automates common but complex tasks such as intro detection, clean cutting, subtitle handling, metadata repair, and batch normalization — all while preserving original files.
Filename detox of illegal characters and alignment with SxxExx naming convention. underscore enforcement for segmented file sections, user selects segment number to start title bar fix

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
pipx + scenedetect (OpenCV),
python3 (IntroFind engine),

Typical flow:
Inspect → Prepare → Template/Detect → GAPMAN → Title/Sub → Cleanup

Key Design Principles:
Where possible:

Stream-Copy First,
no re-encoding,
no quality loss,
fast processing,
Human-Readable Feedback,
color-coded output,
clear status indicators,
verbose progress and diagnostics,
Onboard dependency checks,
File-Based State Tracking,
10 key friendly input with accepted
input as (sec), (hh:mm:ss), (0.00) <---10 key time input,
10 key exits instead of q


Typical Use Case: Processing a full TV season:   Drop factory.sh into episodes folder

Explore menus for goodies   Run Template Builder: Make one excellent key and usually one per season as intros often change per season 
Run Intro Detection: This is magic right here if you made a good key     Run GAPMAN: He does the Cut-n-Gut Snip-n-Clip Apply Title / Subtitle fixes      Finalize outputs


What It Does

1. Source Preparation (Non-Destructive)
THE_FACTORY Creates OEM backups of original files
then protects them from furter processing by prefix_filename.* obfuscation
Disk space displays and warnings as a complete copy of a season might be multi gigs
THE_FACTORY protects and/or discovers other files by Prefix_

Outputs:
OEM_original.*

2. Batch Normalizer (REKEY Pipeline)
Converts source files into cut-safe format
using controlled GOP structure
Ensures consistent:
keyframe spacing (~1 second)
encoding structure
codec alignment for safe stream-copy operations
Supports concurrency levels:
Light (1 job)
Medium (3 jobs)
Thrash (max parallel)

Outputs:
REKEY_original.mkv

3. Template Builder
Using our nice rekey sources The_Factory 
Creates reusable intro templates from any source
manual time selection clean extraction + normalization to mkv 
As it makes all future processing consistent, and mkv is the hottest container around
Automatically creates and stores templates in: intro_template/intro_template.mkv
intro_templates are protected from processing by folder obfuscation until cleanup

Outputs:
intro_template.mkv

4. Intro Detection (IntroFind Engine)
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

5. GAPMAN (Intro Removal Engine)
CSV-driven batch processing (intro_map.csv)
Removes intros using:
stream-copy concat (no re-encode)
Supports:
global offset adjustment
pre-trim (logos)
post-trim (credits)

Outputs:
SUTURED_original.mkv

6. Subtitle Processing (SUBTOX)
Pack external .srt into video
Extract internal subtitle tracks
Rename files using:
episodes.csv mapping
automatic title cleanup

Outputs:
SUBPACKED_original.mkv

7. Metadata & Playback Fix (BARFIX)
Fix title metadata (MKV in-place when possible)
Not filename title but the title that shows in your players title bar BARFIX
Set playback defaults:
preferred audio (English if available)
disable subtitles by default
Supports:
metadata-only mode
playback-only mode
combined mode

Outputs:
BARFIX_original.mkv (if remux required)

8. Cleanup / Finalization
Promotes:
SUTURED_ → final filenames
Handles OEM backups:
archive
delete
retain
Removes temporary artifacts
Marks processed directories

10. Manual Tools
Custom segment cutting
Clip joining
File inspection tools
ffprobe-based diffing

Outputs:
custom_cut.mkv


