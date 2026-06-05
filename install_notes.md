### Minimal Install

```text
sudo apt update && sudo apt install ffmpeg bc pipx mkvtoolnix -y && pipx install "scenedetect[opencv]" && pipx install smartcut
```

Full Install (Recommended)

```text
sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]" && pipx install smartcut
```

# -----------------------------------------------------------------------------------------

# !!! SYSTEM CHECKLIST - INSTALL THESE FIRST !!!

# -----------------------------------------------------------------------------------------

# Copy And Run One Of These Commands To Install The Tools Used Throughout Factory.

# -----------------------------------------------------------------------------------------

#

# MINIMAL INSTALL

#

# sudo apt update && sudo apt install ffmpeg bc pipx mkvtoolnix -y && pipx install "scenedetect[opencv]" && pipx install smartcut

#

# -----------------------------------------------------------------------------------------

#

# FULL INSTALL (RECOMMENDED)

#

# sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]" && pipx install smartcut

#

# -----------------------------------------------------------------------------------------

# DEPENDENCY DESCRIPTIONS

# -----------------------------------------------------------------------------------------

#

# ffmpeg:

# The Main Engine.

# Used For Remuxing, Rebuilding, Joining, Archiving, Rescue Work,

# Audio Repair, Custom Cuts, And Countless Internal Operations.

#

# -----------------------------------------------------------------------------------------

#

# ffprobe:

# Factory's Eyes.

# Used To Determine Duration, Streams, Codecs, Bitrates, Resolution,

# And General Media Truth.

#

# -----------------------------------------------------------------------------------------

#

# smartcut:

# Factory's Scalpel.

# Performs Intro And Outro Removal With Minimal Re-encoding.

# Primary Engine Behind Modern SMC Workflows.

#

# -----------------------------------------------------------------------------------------

#

# scenedetect:

# Scene Analysis Helper.

# Used By Selected Detection And Template Workflows.

# Installed Via Pipx.

#

# -----------------------------------------------------------------------------------------

#

# bc:

# Factory's Calculator.

# Handles Decimal Math, Timing Math, Percentages, And Comparisons.

#

# -----------------------------------------------------------------------------------------

#

# awk:

# Text Surgery Assistant.

# Used For CSV Processing, Parsing, Formatting, Reporting,

# And Workflow Automation.

#

# -----------------------------------------------------------------------------------------

#

# sed:

# Stream Editor.

# Used For Cleanup, Normalization, Replacement, And Text Repair.

#

# -----------------------------------------------------------------------------------------

#

# grep:

# Pattern Hunter.

# Used To Locate Matches, Filter Results, And Drive Decisions.

#

# -----------------------------------------------------------------------------------------

#

# python3:

# Required For IntroFind, Detection Engines, Helpers,

# And Various Factory Subsystems.

#

# -----------------------------------------------------------------------------------------

#

# pipx:

# Safe Application Sandbox.

# Used To Install SmartCut And SceneDetect Without Polluting

# The System Python Environment.

#

# -----------------------------------------------------------------------------------------

#

# mkvtoolnix:

# MKV Toolbox Collection.

# Provides mkvpropedit And Other MKV Utilities Used Throughout Factory.

#

# -----------------------------------------------------------------------------------------

#

# mkvpropedit:

# Fast In-Place Metadata Editor.

# Powers BARFIX And BARFIX Lite Without Rebuilding Files.

#

# -----------------------------------------------------------------------------------------

#

# iconv:

# Character Translation Helper.

# Used During SUBTOX, Cleanup, And Filename Repair Operations.

#

# -----------------------------------------------------------------------------------------

#

# ffplay:

# Quick Playback Viewer.

# Useful For Sanity Checks, Pilot Validation, And Manual Review.

#

# -----------------------------------------------------------------------------------------

#

# findmnt:

# Mount And Drive Information Helper.

# Used To Display Friendly Storage And Device Information.

#

# -----------------------------------------------------------------------------------------

#

# df:

# Disk Space Reporter.

# Allows Factory To Warn About Low Free Space Before Large Jobs.

#

# -----------------------------------------------------------------------------------------

#

# less:

# Scrollable Pager.

# Used For Notes, Reports, Logs, And Long Information Screens.

#

# -----------------------------------------------------------------------------------------

#

# NOTES

#

# - ffprobe and ffplay normally ship with ffmpeg.

# - df is normally provided by coreutils.

# - findmnt is normally provided by util-linux.

# - mkvpropedit is part of mkvtoolnix.

# - SmartCut is now a primary Factory dependency.

# - SceneDetect remains useful for selected workflows and diagnostics.

# - Most Factory workflows prefer MKV whenever practical.

#

# -----------------------------------------------------------------------------------------
