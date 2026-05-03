THE_FACTORY — Full Guided Workflow (SmartCut Era)
OVERVIEW

This document walks through a complete real-world workflow using THE_FACTORY with the SmartCut system.

It assumes:

Unorganized media
Mixed quality files
No prior setup

Goal:

Clean filenames
Remove intros
Remove credits (if possible)
Fix metadata
Produce consistent outputs
Preserve originals
STARTING POINT

You have:

A season of episodes (~2GB each)
Messy or inconsistent names
Intros and credits intact
GLOBAL CONCEPTS
Non-Destructive Design

Original files are never modified directly.

Flow:

Original → OEM backup → Working files → Final outputs
Prefix System
Prefix	Meaning
OEM_	Original backup
SMC_	SmartCut output
SUBTOX_	Subtitle processed
BARFIX_	Metadata fixed
ARCHIVE_	Compressed
CSV-Driven System

Files that control behavior:

episodes.csv
intro_map.csv
outro_map.csv (optional)
STEP 0 — OPTIONAL SIZE REDUCTION
Archival Array (Archie)

Use BEFORE Factory if:

Files are too large

Use AFTER Factory if:

Archiving final results

Features:

Compression levels (L1–L4)
Keeps only smaller outputs
Optional tarball creation
Smart Filename Shortening
Mode	Use
Enabled	Messy dump folders
Disabled	TV episodes

For episodes: disable it.

STEP 1 — FILE NAMING (episodes.csv)
Why This Matters

All automation depends on consistent naming.

Example episodes.csv
S03E01,The Best of Both Worlds
S03E02,Family
Result
S03E01_The_Best_of_Borlds.mkv
Why Underscores
Shell-safe
No quoting issues
Script-friendly
Why SxxExx
Correct sorting
Episode identity
Required for automation
STEP 2 — OEM BACKUPS

Factory creates:

./oem/OEM_<filename>

Purpose:

Protect originals
Allow rollback

Do not modify these files.

STEP 3 — TEMPLATE CREATION

Required:

intro_template/intro_template.mkv

Optional:

intro_template/outro.mkv
Template Rules

Intro:

Full intro length

Outro:

10–30 seconds
Only used to detect start of credits
STEP 4 — INTRO / OUTRO DETECTION

Engine: IntroFind

Outputs:

intro_map.csv
outro_map.csv (if outro exists)
Behavior

Intro:

Scans beginning of file
Finds intro start/end

Outro:

Scans last ~240 seconds
Finds credits start
Important Trigger

Outro detection only runs if:

intro_template/outro.mkv exists
STEP 5 — SMARTCUT

Reads:

intro_map.csv
outro_map.csv (if present)
Cut Logic
[Tip Snip] + Intro Removal + Outro Removal
Example
--cut "0,10,128,234,1800,end"
Output
SMC_<filename>.mkv
Optional Controls
Tip Snip
Tail Tuck
Intro Pads
Outro Pre-Pad
Global Offset
Fallback

If no outro:

Intro removal + Tail Tuck
STEP 6 — SUBTITLES (SUBTOX)

Features:

Embed external .srt
Extract internal subtitles

Output:

SUBTOX_<file>.mkv
STEP 7 — METADATA (BARFIX)

Fixes:

Title bar display
Default audio
Subtitle behavior
Example

Filename:

S03E01_The_Best_of_Both_Worlds.mkv

Player Title:

Star Trek TNG - S03E01 - The Best of Both Worlds
STEP 8 — FINALIZATION
Promote final outputs
Clean temp files
Handle OEM backups
OEM Options
Keep
Delete
Archive (tar)
Completion Marker
factory_wuz_here
FULL PIPELINE
[Optional] Archival Array

→ episodes.csv naming
→ OEM backup
→ template creation
→ IntroFind (+OutroFind)
→ SmartCut
→ SUBTOX
→ BARFIX
→ Finalize
→ [Optional] Archive
COMMON ISSUES
Bad Naming

Fix: correct episodes.csv

Missing Template

Ensure intro_template exists

Outro Not Running

Ensure outro.mkv exists

Bad Detection

Adjust template or settings

MINIMAL WORKFLOW
episodes.csv
→ template
→ IntroFind
→ SmartCut
→ done
