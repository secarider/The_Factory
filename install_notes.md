#                 !!! SYSTEM CHECKLIST - INSTALL THESE FIRST !!!
-----------------------------------------------------------------------------------------
Copy And Run One Of These Lines In Your Terminal To Install The Tools Needed To Run The Script:
-----------------------------------------------------------------------------------------
  OLD Setup Command Or Minimal If You Are On Any Of The New *NixZ This Will Likely Be Enough
sudo apt update && sudo apt install ffmpeg bc pipx mkvtoolnix -y && pipx install "scenedetect[opencv]"
-----------------------------------------------------------------------------------------
  NEW Setup Command no word wrap with this baby,it installs the bathroom sink and all
sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]"
-------------------------DEPENDENCY DESCRIPTIONS INSTALL THESE---------------------------
ffmpeg:       The Main Engine For Remuxing, Trimming, Joining, Rebuilding, And More.
-----------------------------------------------------------------------------------------
ffprobe:      The "Eyes" Used To Calculate Duration, Streams, FPS, And Probe Details.
-----------------------------------------------------------------------------------------
bc:           The "Brain" For Decimal Math And Timing Comparisons.
-----------------------------------------------------------------------------------------
awk:          Text Surgery Helper Used For Parsing, Formatting, And Field Work.
-----------------------------------------------------------------------------------------
sed:          Stream Editor Used For Cleanup, Input Normalization, And Text Fixups.
-----------------------------------------------------------------------------------------
grep:         Pattern Hunter Used For Matching, Filtering, And Decision Logic.
-----------------------------------------------------------------------------------------
df:           Disk Space Reporter So The Script Can Warn About Free Space.
-----------------------------------------------------------------------------------------
python3:      Needed For Python-Based Helper Paths And Related Tooling.
-----------------------------------------------------------------------------------------
pipx:         The Safe "Bubble" Environment For Python Apps Like Scenedetect.
-----------------------------------------------------------------------------------------
scenedetect:  The "Orbital Laser" For Automatic Intro Finding (Installed Via Pipx).
-----------------------------------------------------------------------------------------
iconv:        Character Transliteration Helper Used In Some Title Cleanup Paths.
-----------------------------------------------------------------------------------------
ffplay:       Quick Playback Checker For Manual Review / Sanity Checks.
-----------------------------------------------------------------------------------------
findmnt:      Friendly Drive Label / Mount Source Lookup Helper.
-----------------------------------------------------------------------------------------
less:         Scrollable Pager For Long Notes / Explain Screens.
-----------------------------------------------------------------------------------------
mkvpropedit:  Fast In-Place MKV Metadata Editor (Title Repair Without Remux).
-----------------------------------------------------------------------------------------
mkvpropedit:  Is part of mkvtoolnix. [mkvtoolnix.download](https://mkvtoolnix.download/)
-----------------------------------------------------------------------------------------
INSTALL COMMAND:
sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]"
-----------------------------------------------------------------------------------------
NOTES:
- ffprobe and ffplay normally come with the ffmpeg package.
- df is part of coreutils on Debian/Ubuntu/Mint systems.
- findmnt is usually provided by util-linux on Debian/Ubuntu/Mint systems.
- mkvpropedit comes from mkvtoolnix.
- scenedetect is OPTIONAL but automatic intro detection is the star of the show.
- less is OPTIONAL; note screens can fall back to plain cat behavior.
- iconv is OPTIONAL; some detox/transliteration behavior may be reduced without it.
-----------------------------------------------------------------------------------------
