![The_Factory Logo](TheFactory.png)
# THE_FACTORY

# SMCUT — SmartCut-Based Intro Removal System

The Factory Runs On SmartCut

Inspired and Powered by `https://github.com/skeskinen/smartcut`

Support Them Here `https://smartmediacutter.com/`

Inspired by `https://github.com/mifi/lossless-cut`

---

## Overview

COMPLETE WORKFLOW (MODERN FACTORY)
STEP 0 — (OPTIONAL) SIZE REDUCTION / PRE-PROCESS
Archival Array (Archie)

Use Archival Array when:

Files are too large
You want storage reduction first
You have messy dump folders (dashcam / bulk media)

Capabilities:

Multi-level compression (L1–L4)
Keeps only smaller outputs
Optional tarball archiving
Smart filename shortening (for chaotic folders)
Can be disabled for episode workflows

Outputs:

ARCHIVE_Lx_<file>.mkv

Use Cases:

Scenario	Recommendation
Raw dump folder	Enable smart shortening
TV episodes	Disable shortening
Storage reduction	Run BEFORE Factory
Archive finished work	Run AFTER Factory
STEP 1 — ORGANIZE & RENAME (episodes.csv)
Why This Matters

Consistent naming is critical for:

Matching CSV operations
Subtitle alignment
Metadata correctness
Automation reliability
episodes.csv Format
S03E01,The Best of Both Worlds
S03E02,Family
Resulting Filename
S03E01_The_Best_of_Both_Worlds.mkv
Why Underscores?
Shell-safe
No quoting issues
Cross-platform stable
Clean parsing in scripts
Why SxxExx?
Absolute episode identity
Sorting correctness
Metadata alignment
Required for automation consistency
STEP 2 — TEMPLATE SETUP

Create:

intro_template/intro_template.mkv

Optional (for full automation):

intro_template/outro.mkv
Template Rules
Type	Length	Purpose
Intro	Full intro	Defines cut duration
Outro	10–30 sec	Detects start of credits
STEP 3 — INTRO + OUTRO DETECTION
Engine: IntroFind (pHash)

Produces:

intro_map.csv
outro_map.csv (if outro.mkv exists)
Detection Logic

Intro

Scans early portion of file
Matches template
Outputs exact start/end

Outro

Scans last ~4 minutes
Finds start of credits
Cuts to end of file
Trigger Condition

Outro detection activates ONLY if:

intro_template/outro.mkv exists
STEP 4 — SMARTCUT EXECUTION

SmartCut reads:

intro_map.csv
+ outro_map.csv (if present)
Cut Plan
intro_start → intro_end
outro_start → END
Example
--cut "128,234,1800,end"
Output
SMC_<original_filename>.mkv
Optional Controls
Control	Purpose
Tip Snip	Remove seconds from start
Tail Tuck	Fallback if no outro
Intro Pads	Fine tune intro
Outro Pre-Pad	Adjust credits start
Global Offset	Shift detection
Fallback Behavior

If no outro:

Intro removal + Tail Tuck
STEP 5 — TITLE / METADATA / PLAYBACK FIX (BARFIX)
What BARFIX Does
Sets player-visible title
Sets default audio track
Disables/enables subtitles
Cleans metadata inconsistencies
Example Result

Filename:

S03E01_The_Best_of_Both_Worlds.mkv

Title Bar (Player View):

Star Trek TNG - S03E01 - The Best of Both Worlds
Why This Matters
Plex / Jellyfin compatibility
Clean playback experience
Consistent library appearance
STEP 6 — SUBTITLES (SUBTOX)

Capabilities:

Embed .srt into video
Extract internal subtitles
Align with episodes.csv
Output
SUBTOX_<file>.mkv
STEP 7 — FINALIZATION
Promote SMC outputs to final
Clean temp files
Handle OEM backups:

Options:

Keep
Delete
Archive (tar)
FILE PREFIX SYSTEM
Prefix	Meaning
SMC_	SmartCut output
ARCHIVE_	Compressed files
SUBTOX_	Subtitle processed
BARFIX_	Metadata fixed
OEM_	Original protected copy
KEY ADVANTAGES OF MODERN FACTORY
Compared to Old Workflow
Feature	Old	SmartCut
Full Re-encode	Required	Not required
Keyframe Dependency	Strict	None
Drift Issues	Common	Eliminated
Complexity	High	Low
Speed	Slow	Fast
DESIGN PRINCIPLES
Non-destructive (originals preserved)
CSV-driven automation
Deterministic results
Batch-safe processing
Minimal re-encoding philosophy
WHAT CAN BE RETIRED (ROADMAP INSIGHT)

Based on current workflow:

No Longer Core
Full REKEY normalization (optional only)
Keyframe gating systems
Concat-based stitching (GAPMAN)
Heavy preprocessing stages
Still Valuable
IntroFind (core detection engine)
CSV systems
BARFIX / SUBTOX
Archival Array
RECOMMENDED FLOW (SUMMARY)
[Optional] Archival Array (reduce size)

→ episodes.csv rename
→ create templates
→ IntroFind (+OutroFind)
→ SmartCut (SMC)
→ BARFIX
→ SUBTOX
→ Finalize
→ [Optional] Archive outputs
BOTTOM LINE

If you:

Have outro.mkv → fully automated episode trimming
Do not → intro removal still works

SmartCut delivers:

Cleaner cuts
Faster processing
Simpler workflow
More reliable results
