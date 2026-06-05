![The_Factory Logo](TheFactory.png)
# THE_FACTORY

![SmartCut_Logo](logo_small.png)
# SMCUT — SmartCut-Based Intro Removal System
### Minimal Install

```text
sudo apt update && sudo apt install ffmpeg bc pipx mkvtoolnix -y && pipx install "scenedetect[opencv]" && pipx install smartcut
```

Full Install (Recommended)

```text
sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]" && pipx install smartcut
```

## Dependencies

### ffmpeg

The primary media engine used throughout Factory.

Used for:
- Remuxing
- Rebuilding
- Joining clips
- Archival encoding
- Rescue workflows
- Audio repair
- Custom cuts

---

### ffprobe

Factory's media inspection tool.

Used for:
- Duration detection
- Stream analysis
- Codec discovery
- Resolution reporting
- General media verification

---

### smartcut

Inspired and Powered by 
```text
https://github.com/skeskinen/smartcut
```

Factory's primary cutting engine.

Used by:
- SmartCut (SMC)
- Intro removal
- Outro removal
- Pilot validation workflows
- CSV-driven batch cutting

Provides frame-accurate cuts while minimizing re-encoding.

Factory can use either:

- A pipx-installed `smartcut` command
- The standalone `SMC.App` SmartCut AppImage
- Support Them Here
```text
https://smartmediacutter.com/
```


The AppImage should be renamed to:

`SMC.App` and kept alongside Factory

---

### scenedetect

Scene analysis utility installed through Pipx.

Used by:
- Detection workflows
- Template generation workflows
- Diagnostic utilities

---

### bc

Decimal math engine used for:
- Timing calculations
- Percentages
- Duration comparisons
- Offset calculations

---

### awk

Factory's primary text-processing tool.

Used for:
- CSV handling
- Reporting
- Parsing
- Workflow automation

---

### sed

Stream editor used for:
- Text cleanup
- Normalization
- Replacement operations
- Configuration editing

---

### grep

Pattern matching utility used for:
- Filtering
- Decision making
- Workflow control
- Validation checks

---

### python3

Required for:
- IntroFind
- Detection engines
- Helper scripts
- Various Factory subsystems

---

### pipx

Safe Python application installer.

Used for:
- SmartCut
- SceneDetect

Keeps Factory dependencies isolated from the system Python environment.

---

### mkvtoolnix / mkvpropedit

MKV metadata utilities used by:
- BARFIX
- BARFIX Lite
- Title repair
- Playback-default management

Provides fast metadata editing without rebuilding media files.

---

### iconv

Character conversion helper used during:
- SUBTOX operations
- Filename cleanup
- Text normalization

---

### ffplay

Lightweight playback utility useful for:
- Pilot review
- Sanity checks
- Quick validation

---

### findmnt

Used to display:
- Drive labels
- Mount points
- Storage information

---

### df

Disk-space reporting utility.

Used to:
- Check free space
- Warn before large operations
- Verify storage availability

---

### less

Scrollable pager used for:
- Notes
- Reports
- Logs
- Long information screens

---

## Notes

- ffprobe and ffplay normally ship with ffmpeg.
- df is normally provided by coreutils.
- findmnt is normally provided by util-linux.
- mkvpropedit is included with mkvtoolnix.
- SmartCut is now a primary Factory dependency.
- SceneDetect remains useful for selected workflows and diagnostics.
- Most Factory workflows prefer MKV whenever practical.
