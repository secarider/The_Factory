### Minimal Install

```sudo apt update && sudo apt install ffmpeg bc pipx mkvtoolnix -y && pipx install "scenedetect[opencv]" && pipx install smartcut```

Full Install (Recommended)

```sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]" && pipx install smartcut```

# Core SmartCut Features

# IntroFind

Perceptual-hash based intro detection using configurable:

* Scan depth
* Anchor positions
* Step sizes
* Match thresholds

Supports difficult animated and drift-prone content through multi-anchor matching.

# OutroFind

Template-based outro detection using short key clips.

Features:

* Multi-anchor matching
* Adjustable outro scan windows
* Independent intro/outro detection
* CSV logging integration

# SmartCut

Automated commercial and segment removal based on IntroFind and OutroFind results.

Features:

* Intro removal
* Outro removal
* Tip snip / tail tuck controls
* Pilot validation mode
* Batch processing
* Single-file workflows

# Pilot Validation Mode

Pilot mode allows users to validate processing results before committing an entire batch.

Features:

* First-file testing
* First-three-file testing
* Review checkpoints
* OEM preservation safeguards

# Persistent Session Configuration

Factory remembers workflow settings through dedicated configuration controls.

Examples include:

* IntroFind defaults
* OutroFind defaults
* SmartCut offsets
* Tip/Tail settings
* BARFIX Lite preferences

# Parallel SmartCut Batch Processing

Factory supports batch SmartCut operations while maintaining OEM safety protections.

Features:

* Pilot-first workflow
* Resume support
* Batch execution
* Consistent cut plans

# BARFIX Lite Integration

SmartCut outputs can automatically receive lightweight metadata cleanup.

Features:

* Title-bar repair
* Preferred audio selection
* Preferred subtitle selection
* Playback default management
* Repair And Preparation Tools

# SUBTOX

Filename cleanup and episode normalization system.

Features:

* SxxExx detection
* 5x## conversion support
* CSV-assisted naming
* Batch rename workflows

# Audio Sync Rescue

Tools for correcting synchronization issues between audio and video streams.

# Video Rescue

Repair workflows for:

* AVI sources
* Damaged timestamps
* Broken indexing
* Difficult editing sources

# Normalize / REKEY

Cut-friendly rebuilding and compatibility preparation tools.

Used when problematic source material requires normalization before further processing.

Archival Array

Multi-level archival processing designed for long-term storage.

# Archive Levels:

* L1 Fast Archive
* L2 Balanced Archive
* L3 Deep Archive
* L4 Maximum Compression

Audio policy is selected independently from archive level.

# Metadata Sidecar Protection

Archival processing can preserve source metadata before encoding.

Available modes:

* Sidecar Strip
* Restore Common
* Minimal Skip

Metadata sidecars are stored separately for future reference and recovery.

# Diagnostics And Utilities

Probes

Information-only inspection tools including:

* Video Truth Probe
* Stream inspection
* Metadata review
* Subtitle inspection
* Duration verification

# Clip And Join Workshop

Manual editing utilities including:

* Join two clips
* Custom cut workflows
* Normalization before joining
* One-off editing operations

# Twisted Color Menu

Theme and appearance controls for Factory's terminal interface.

Semantic warning colors remain protected regardless of theme selection.

Notes
* Factory prefers MKV workflows whenever practical.
* OEM backups are preserved whenever possible.
* SmartCut is the primary processing workflow.
* Repair tools remain available for exceptional cases.
* IntroFind and OutroFind are designed to be tuned per series when necessary.
