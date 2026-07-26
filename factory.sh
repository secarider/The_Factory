#!/usr/bin/env bash

# -----------------------------------------------------------------------------------------
# !!! CRITICAL:  THE #!/bin/bash SEEN ABOVE MUST BE LEFT THERE AND BE TOP FIRST
# !!! CRITICAL:  This is the 'Shebang'. Do NOT Remove Or Comment It Out. 
# !!! CRITICAL:   It Tells Linux To Use The Modern Bash 'Brain' To Run This Script.
# -----------------------------------------------------------------------------------------
#                  !!! FRESH SYSTEM CHECKLIST - INSTALL THESE FIRST !!!
# -----------------------------------------------------------------------------------------
# Copy -Without the # and space- And Run One Of These Lines In Your Terminal To Install The Tools Needed To Run The Script:
# -----------------------------------------------------------------------------------------
#   OLD Setup Command Or Minimal If You Are On Any Of The New *NixZ This Will Likely Be Enough
# sudo apt update && sudo apt install ffmpeg bc pipx mkvtoolnix -y && pipx install "scenedetect[opencv]"
# =========================================================================================
# !!! FACTORY SETUP / DEPENDENCY CHECKLIST !!!
# =========================================================================================
# PURPOSE:
# - Install the normal Linux-side tools Factory uses.
# - Smart Media Cutter itself is NOT installed by apt or pipx.
# - Factory prefers a portable Smart Media Cutter AppImage named:
# TOOLBOX/smc.app
#
# QUICK INSTALL:
# Copy the next command WITHOUT the leading "# " and run it in a terminal:
#
# sudo apt update && sudo apt install -y ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less && pipx install "scenedetect[opencv]"
#
# =========================================================================================
# SMART MEDIA CUTTER / SMC.APP  https://smartmediacutter.com/
# =========================================================================================
# Factory needs ONE usable SmartCut engine for SmartCut-driven trimming
# and template creation:
#
# Preferred:
# TOOLBOX/smc.app
#
# Temporary emergency fallback:
# ./smc.app
#
# Older fallback:
# smartcut command available through pipx / PATH
#
# PORTABLE APPIMAGE SETUP:
# 1) Obtain the Smart Media Cutter AppImage.
# 2) Rename it exactly:
# smc.app
# 3) Place it inside TOOLBOX:
# TOOLBOX/smc.app
# 4) Make it executable:
# chmod +x TOOLBOX/smc.app
#
# Factory will report a clear missing-engine warning if no usable SMC engine is found.
#
# =========================================================================================
# TOOL DESCRIPTIONS
# =========================================================================================
# ffmpeg:
# Core media engine used throughout Factory for decoding, probing support,
# REKEY, rescue/normalize paths, joining, fallback trims, frame extraction,
# and other workflows. Smart Media Cutter is the preferred primary cutter
# for SmartCut-driven trims and template creation.
#
# ffprobe:
# Installed with ffmpeg. Reads duration, streams, FPS, codecs, and media facts.
#
# ffplay:
# Installed with ffmpeg. Quick playback / sanity-check tool.
#
# bc
# Decimal math helper for timing comparisons and cut calculations.
#
# gawk / awk:
# Text parsing, CSV handling, reports, filename work, and field processing.
#
# sed:
# Text cleanup and controlled substitutions.
#
# grep:
# Pattern matching, filtering, and discovery.
#
# coreutils:
# Supplies common Linux tools including df, sort, head, tail, and more.
#
# python3:
# Runs Factory's local xHash / pHash IntroFind engine.
#
# python3-pip:
# Supports Python package tooling when needed.
#
# pipx:
# Isolated installer / runner for optional Python command-line tools.
#
# scenedetect[opencv]:
# Optional  support for scene-analysis workflows.
# Factory's normal xHash / pHash IntroFind engine is local and does not require
# SceneDetect for ordinary template matching.                                       this isnt true anymore
#
# mkvpropedit:  Is part of mkvtoolnix. [mkvtoolnix.download](https://mkvtoolnix.download/)
# mkvtoolnix:
# Provides mkvpropedit for fast in-place MKV metadata repair, Barfix Lite,
# and template title metadata without remuxing.
#
# util-linux:
# Provides tools such as findmnt for friendly mount / drive reporting.
#
# less:
# Optional scrollable viewer for long reports and notes.
#
# iconv:
# Usually already present on Linux systems. Used by some filename cleanup /
# transliteration paths when available.
#
# =========================================================================================
# FACTORY PORTABLE TOOLBOX LAYOUT
# =========================================================================================
# TOOLBOX/
# factory.sh
# smc.app
# factory.conf
# intro_template/
# .phash_engine.py
# .phash_engine.stderr.log
#
# NOTES:
# - TOOLBOX holds Factory infrastructure and reusable tools.
# - Season/media folders hold the actual show files, maps, reports, and OEM backups.
# - intro_template/ inside TOOLBOX is the preferred template repository.
# - Factory may detect a working-folder intro_template/ and ask which repository
# should be authoritative if both locations contain real template media.
# - Most Factory workflows prefer MKV whenever practical.
# =========================================================================================
# INSTALL COMMAND:
# sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]"
# -----------------------------------------------------------------------------------------
# NOTES:
# - ffprobe and ffplay normally come with the ffmpeg package.
# - df is part of coreutils on Debian/Ubuntu/Mint systems.
# - findmnt is usually provided by util-linux on Debian/Ubuntu/Mint systems.
# - mkvpropedit comes from mkvtoolnix.
# - SceneDetect automatic intro detection is the star of the show.
# - less is OPTIONAL; note screens can fall back to plain cat behavior.
# - iconv is OPTIONAL; some detox/transliteration behavior may be reduced without it.
# - SmartCut is now a primary Factory dependency.
# - Most Factory workflows prefer MKV whenever practical and will warn when working with avi and some hevc
# - although smartcut has eliminated most of that concern https://smartmediacutter.com/
# -----------------------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob

# ================================================================
# MARKER: COLOR DEFINITIONS
# ================================================================

RED=$'\033[1;31m'        # Twistable Red
RE=$'\033[1;31m'         # Solid Bold Red / Stable Error
REB=$'\033[5;31m'        # Blinking Bold Red
REDD=$'\033[0;31m'       # Dim / Normal Red
REBD=$'\033[5;2;31m'     # Blinking Dim Red

GREEN=$'\033[1;32m'      # Twistable Green
GR=$'\033[1;32m'         # Solid Bold Green / Stable Success
GRB=$'\033[5;32m'        # Blinking Bold Green
GREEND=$'\033[0;32m'     # Dim / Normal Green
GRBD=$'\033[5;2;32m'     # Blinking Dim Green

YELLOW=$'\033[1;33m'     # Twistable Yellow
YE=$'\033[1;33m'         # Solid Bold Yellow / Stable Warning
YEB=$'\033[5;33m'        # Blinking Bold Yellow
YELLOWD=$'\033[0;33m'    # Dim / Normal Yellow
YEBD=$'\033[5;2;33m'     # Blinking Dim Yellow

CYAN=$'\033[1;36m'       # Twistable Cyan
CY=$'\033[1;36m'         # Solid Bold Cyan / Stable Info
CYB=$'\033[5;36m'        # Blinking Bold Cyan
CYAND=$'\033[0;36m'      # Dim / Normal Cyan
CYBD=$'\033[5;2;36m'     # Blinking Dim Cyan

BLUE=$'\033[1;34m'       # Twistable Blue
BLUEB=$'\033[5;34m'      # Blinking Bold Blue
BLUED=$'\033[0;34m'      # Dim / Normal Blue
BLUEBD=$'\033[5;2;34m'   # Blinking Dim Blue

MAGENTA=$'\033[1;35m'    # Twistable Magenta
MAGENTAB=$'\033[5;35m'   # Blinking Bold Magenta
MAGENTAD=$'\033[0;35m'   # Dim / Normal Magenta
MAGENTABD=$'\033[5;2;35m' # Blinking Dim Magenta

PURPLE=$'\033[1;35m'     # Twistable Purple Alias
PURPLEB=$'\033[5;35m'    # Blinking Bold Purple Alias
PURPLED=$'\033[0;35m'    # Dim / Normal Purple Alias
PURPLEBD=$'\033[5;2;35m' # Blinking Dim Purple Alias

TEAL=$'\033[1;36m'       # Twistable Teal Alias
TEALB=$'\033[5;36m'      # Blinking Bold Teal Alias
TEALD=$'\033[0;36m'      # Dim / Normal Teal Alias
TEALBD=$'\033[5;2;36m'   # Blinking Dim Teal Alias

ORANGE=$'\033[38;5;208m' # Twistable Orange
ORANGEB=$'\033[5;38;5;208m' # Blinking Orange
ORANGED=$'\033[2;38;5;208m' # Dim Orange
ORANGEBD=$'\033[5;2;38;5;208m' # Blinking Dim Orange

WHITE=$'\033[1;37m'      # Twistable Bright White
BWHITE=$'\033[1;37m'     # Bright White Alias
BW=$'\033[1;37m'         # Stable Bright White
WHITEB=$'\033[5;37m'     # Blinking Bright White
WHITED=$'\033[0;37m'     # Dim / Normal White
WHITEBD=$'\033[5;2;37m'  # Blinking Dim White

GRAY=$'\033[0;37m'       # Gray / Normal White
GRAYB=$'\033[5;37m'      # Blinking Gray
GRAYD=$'\033[2;37m'      # Dim Gray
GRAYBD=$'\033[5;2;37m'   # Blinking Dim Gray

DIM=$'\033[2m'           # General Dim Style
UNDER=$'\033[4m'         # Underline Style
REV=$'\033[7m'           # Reverse Video Style

NC=$'\033[0m'            # Reset / No Color
# MARKER: COLOR DEFINITIONS END =============================================

# ========================================================
# #MARKER: FACTORY PORTABLE HOME / WORKDIR ROOTS
# ========================================================
# SCRIPT_DIR:
# - Directory containing factory.sh itself.
# - May be TOOLBOX, or may be a loose working-folder copy.
#
# FACTORY_HOME:
# - Resolved Factory resource root.
# - Normally the TOOLBOX directory when one is available.
# - Holds portable Factory resources such as:
#     smc.app
#     factory.conf
#     intro_template/
#
# FACTORY_WORKDIR:
# - Directory where the user launched Factory.
# - Remains the media / season working folder.
# - May contain a temporary smc.app or a working intro_template link.
#
# RESOLUTION:
# - Prefer an explicit FACTORY_HOME override.
# - Otherwise use TOOLBOX beside factory.sh or beside the working folder.
# - Otherwise fall back to the directory containing factory.sh.
# ========================================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FACTORY_WORKDIR="${FACTORY_WORKDIR:-$PWD}"
STARTUP_HOME_OVERRIDE="${FACTORY_HOME:-}"

resolve_factory_home() {
	local d

	# 1) Explicit user override wins.
	if [[ -n "${FACTORY_HOME:-}" && -d "${FACTORY_HOME:-}" ]]; then
		printf '%s\n' "$FACTORY_HOME"
		return 0
	fi

	# 2) Prefer a real TOOLBOX beside factory.sh or in the launch folder.
	for d in "$SCRIPT_DIR/TOOLBOX" "$FACTORY_WORKDIR/TOOLBOX" "$PWD/TOOLBOX"; do
		if [[ -d "$d" ]]; then
			printf '%s\n' "$d"
			return 0
		fi
	done

	# 3) Standalone / lightweight fallback.
	# Factory still runs from the working directory using system tools,
	# pipx SmartCut, and any local resources that are available.
	printf '%s\n' "$SCRIPT_DIR"
}

FACTORY_HOME="$(resolve_factory_home)"
FACTORY_CONFIG_FILE="${FACTORY_CONFIG_FILE:-$FACTORY_HOME/factory.conf}"

# ========================================================
# #MARKER: OPERATING MODE DETECTION
# ========================================================
HOME_WAS_OVERRIDDEN=0
[[ -n "${STARTUP_HOME_OVERRIDE:-}" ]] && HOME_WAS_OVERRIDDEN=1

detect_operating_mode() {
	local script_real home_real work_toolbox_real script_toolbox_real

	script_real="$(realpath -m -- "$SCRIPT_DIR" 2>/dev/null || printf '%s\n' "$SCRIPT_DIR")"
	home_real="$(realpath -m -- "$FACTORY_HOME" 2>/dev/null || printf '%s\n' "$FACTORY_HOME")"
	work_toolbox_real="$(realpath -m -- "$FACTORY_WORKDIR/TOOLBOX" 2>/dev/null || printf '%s\n' "$FACTORY_WORKDIR/TOOLBOX")"
	script_toolbox_real="$(realpath -m -- "$SCRIPT_DIR/TOOLBOX" 2>/dev/null || printf '%s\n' "$SCRIPT_DIR/TOOLBOX")"

	if (( HOME_WAS_OVERRIDDEN == 1 )); then
		OPERATING_MODE="OVERRIDE"
	elif [[ "$home_real" == "$script_real" ]]; then
		if [[ "$(basename "$home_real")" == "TOOLBOX" ]]; then
			OPERATING_MODE="PORTABLE_TOOLBOX"
		else
			OPERATING_MODE="STANDALONE"
		fi
	elif [[ "$home_real" == "$work_toolbox_real" || "$home_real" == "$script_toolbox_real" ]]; then
		OPERATING_MODE="LOCAL_TOOLBOX"
	else
		OPERATING_MODE="EXTERNAL_HOME"
	fi

	export OPERATING_MODE
}

detect_operating_mode

# ========================================================
# #MARKER: LEGACY STICKY WRITE FILES / SAFE BRIDGE MODE
# ========================================================
# PURPOSE:
# - factory.conf is now the central config/read target.
# - Old Twisted and SmartCut save helpers still rewrite whole files.
# - Keep their write targets separate until factory_conf_set_var exists.
#
TWISTED_CONFIG_FILE="${TWISTED_CONFIG_FILE:-$FACTORY_HOME/factory_twisted.conf}"
SMARTCUT_SESSION_CONFIG_FILE="${SMARTCUT_SESSION_CONFIG_FILE:-$FACTORY_HOME/.factory_smartcut_session.conf}"

# ===== COLOR SYSTEM / TWISTED THEME ENGINE ===================================
# PURPOSE:
# Centralize all standard display colors in one place so the script can:
#   1) keep a stable default color layout
#   2) remap the normal display palette on demand
#   3) preserve warning semantics no matter what theme is active
#
# DESIGN:
# - STANDARD DISPLAY COLORS:
#     RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BWHITE NC
#   These are cosmetic / display-facing colors and may be remapped by twisted().
#
# - FIXED SEMANTIC WARNING COLORS:
#     RE REB YE YEB GR BW
#   These are reserved for true meaning-based warnings / verdicts and must NOT
#   be remapped by twisted(). Use these for:
#     GR = SAFE / PASS / OK
#     YE = CAUTION / NOTICE / WARNING
#    YEB = Yellow Blinking
#     RE = RISK / FAIL / DANGER / DESTRUCTIVE
#    REB = Red Blinking
#     BW = wording or effects or reserved for future
# RULE:
# - Use ${RED}/${YELLOW}/${GREEN}/etc for decorative or general display output
# - Use ${RE}/${REB}/${YE}/${YEB}/${GR}/${BW} for any output where the actual meaning of the color
#   must remain trustworthy even if a theme or random twist is active
# ==============================================================================

init_base_colors() {
	# ----- STANDARD DISPLAY COLORS (TWISTABLE) -------------------------------
	RED=$'\033[1;31m'
	GREEN=$'\033[1;32m'
	YELLOW=$'\033[1;33m'
	BLUE=$'\033[1;34m'
	MAGENTA=$'\033[1;35m'
	CYAN=$'\033[1;36m'
	WHITE=$'\033[1;37m'
	BWHITE=$'\033[1;37m'
	NC=$'\033[0m'

	# ----- FIXED SEMANTIC WARNING COLORS (DO NOT TWIST) ----------------------
	# KEEP SEMANTIC WARNING COLORS STABLE NO MATTER WHAT THEME IS ACTIVE
    # Add '5;' after the bracket for the blinking effect
    RE=$'\033[1;1;31m'  # Solid Bold Red
    REB=$'\033[5;1;31m'  # Blinking Bold Red
    YE=$'\033[1;1;33m'    # Solid Bold Yellow (Stable Warning)
    YEB=$'\033[5;1;33m'    # Blinking Bold Yellow (Stable Warning)
    GR=$'\033[1;32m'    # Solid Bold Green (All Clear)
    BW=$'\033[1;37m'    # Bright White
}

ansi_color() {
	case "$1" in
		0)  printf '\033[0m' ;;
		30) printf '\033[1;30m' ;;
		31) printf '\033[1;31m' ;;
		32) printf '\033[1;32m' ;;
		33) printf '\033[1;33m' ;;
		34) printf '\033[1;34m' ;;
		35) printf '\033[1;35m' ;;
		36) printf '\033[1;36m' ;;
		37) printf '\033[1;37m' ;;
		90) printf '\033[1;30m' ;;
		91) printf '\033[1;31m' ;;
		92) printf '\033[1;32m' ;;
		93) printf '\033[1;33m' ;;
		94) printf '\033[1;34m' ;;
		95) printf '\033[1;35m' ;;
		96) printf '\033[1;36m' ;;
		97) printf '\033[1;97m' ;;
		*)  printf '\033[0m' ;;
	esac
}

set_color_var() {
	local var_name="$1"
	local ansi_num="$2"
	printf -v "$var_name" '%s' "$(ansi_color "$ansi_num")"
}

apply_color_map() {
    printf '\033[0m'
	local red_code="$1"
	local green_code="$2"
	local yellow_code="$3"
	local blue_code="$4"
	local magenta_code="$5"
	local cyan_code="$6"
	local white_code="$7"
	local bwhite_code="$8"

	set_color_var RED     "$red_code"
	set_color_var GREEN   "$green_code"
	set_color_var YELLOW  "$yellow_code"
	set_color_var BLUE    "$blue_code"
	set_color_var MAGENTA "$magenta_code"
	set_color_var CYAN    "$cyan_code"
	set_color_var WHITE   "$white_code"
	set_color_var BWHITE  "$bwhite_code"

	# KEEP RESET STABLE
	NC=$'\033[0m'

	# KEEP SEMANTIC WARNING COLORS STABLE NO MATTER WHAT THEME IS ACTIVE
    # Add '5;' after the bracket for the blinking effect
    RE=$'\033[1;1;31m'  # Solid Bold Red
    REB=$'\033[5;1;31m'  # Blinking Bold Red
    YE=$'\033[1;1;33m'    # Solid Bold Yellow (Stable Warning)
    YEB=$'\033[5;1;33m'    # Blinking Bold Yellow (Stable Warning)
    GR=$'\033[1;32m'    # Solid Bold Green (All Clear)
    BW=$'\033[1;37m'    # Bright White

}

is_bad_palette() {
	local c0="${1:-0}" c1="${2:-0}" c2="${3:-0}" c3="${4:-0}"
	local c4="${5:-0}" c5="${6:-0}" c6="${7:-0}" c7="${8:-0}"

	# INDEX MAP:
	# c0=RED c1=GREEN c2=YELLOW c3=BLUE
	# c4=MAGENTA c5=CYAN  c6=WHITE  c7=BWHITE

	# ----- BLOCK HARD-TO-READ OR MUDDY PAIRS -------------------------------
	[[ "$c2" == 33 && "$c6" == 37 ]] && return 0   # YELLOW / WHITE
	[[ "$c2" == 33 && "$c7" == 97 ]] && return 0   # YELLOW / BWHITE
	[[ "$c6" == 37 && "$c5" == 36 ]] && return 0   # WHITE / CYAN
	[[ "$c1" == 32 && "$c5" == 36 ]] && return 0   # GREEN / CYAN
	[[ "$c0" == 31 && "$c4" == 35 ]] && return 0   # RED / MAGENTA

	return 1
}

twisted_randomize() {
	local i j tmp attempt=0 max_attempts=20
	local codes

	# ----- CONTRAST-GUARDED RANDOM PALETTE -----------------------------------
	# PURPOSE:
	# Shuffle the 8 twistable display colors, but reject known bad / muddy
	# combinations that reduce readability.
	#
	# IMPORTANT:
	# - This function is called by: twisted random
	# - This is NOT the semantic warning block; RE / YE / GR / BW stay fixed
	# - We reset the candidate palette on each attempt, shuffle it, then test it
	# - If a bad palette is detected, we try again up to max_attempts
	#
	# SET -e / SET -u SAFETY:
	# - Use ${codes[n]:-0} in the guard call to avoid unbound crashes
	# - Use ((attempt+=1)) instead of ((attempt++)) so set -e does not pop out
	# -------------------------------------------------------------------------

	while (( attempt < max_attempts )); do
		# ----- RESET TO BASE ORDER EACH ATTEMPT ------------------------------
		# KEEP 8 SLOTS:
		#   RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BWHITE
		codes=(31 32 33 34 35 36 37 97)

		# ----- FISHER-YATES SHUFFLE -----------------------------------------
		for (( i=${#codes[@]}-1; i>0; i-- )); do
			j=$(( RANDOM % (i + 1) ))
			tmp="${codes[i]}"
			codes[i]="${codes[j]}"
			codes[j]="$tmp"
		done

		# ----- CONTRAST GUARD -----------------------------------------------
		# If palette is acceptable, stop trying and apply it
		if ! is_bad_palette \
			"${codes[0]:-0}" "${codes[1]:-0}" "${codes[2]:-0}" "${codes[3]:-0}" \
			"${codes[4]:-0}" "${codes[5]:-0}" "${codes[6]:-0}" "${codes[7]:-0}"; then
			break
		fi

		# ----- TRY AGAIN -----------------------------------------------------
		((attempt+=1))
	done

	# ----- FALLBACK NOTICE ---------------------------------------------------
	# Very unlikely, but if every attempt was rejected, last shuffle still gets
	# applied so the feature never appears frozen.
	if (( attempt == max_attempts )); then
		echo -e "${YE} = = > Contrast Guard Fallback: Using Last Shuffle.${NC}"
	fi

	# ----- APPLY ACCEPTED PALETTE -------------------------------------------
	apply_color_map \
		"${codes[0]}" "${codes[1]}" "${codes[2]}" "${codes[3]}" \
		"${codes[4]}" "${codes[5]}" "${codes[6]}" "${codes[7]}"
}

twisted_theme() {
	local theme_name="${1,,}"

	case "$theme_name" in
		classic)
			# STANDARD / EXPECTED LAYOUT
			apply_color_map 31 32 33 34 35 36 37 97
			;;

		mellow)
			# SOFTER / FRIENDLIER LOOK
			apply_color_map 35 36 33 34 95 96 37 97
			;;

		danger)
			# HOT / AGGRESSIVE / ALERT-HEAVY LOOK
			apply_color_map 91 31 93 35 95 33 37 97
			;;

		ice)
			# COOL / TECH / FROSTED LOOK
			apply_color_map 94 96 97 34 95 36 37 97
			;;

		twisted)
			# PURPOSEFULLY OFF-KILTER BUT STILL CURATED
			apply_color_map 36 35 31 33 32 94 97 93
			;;

		mono)
			# MINIMAL / ALMOST MONOCHROME
			apply_color_map 37 97 37 90 37 97 37 97
			;;

		*)
			echo -e "${YE} = = > Unknown twisted theme: $theme_name${NC}"
			echo -e "${WHITE} = = > Available themes: classic mellow danger ice twisted mono${NC}"
			return 1
			;;
	esac
}

twisted_manual() {
	local red_code green_code yellow_code blue_code
	local magenta_code cyan_code white_code bwhite_code

	echo
	echo -e "${WHITE} = = > Enter ANSI color numbers for the TWISTABLE display palette.${NC}"
	echo -e "${WHITE} = = > Common values: 31 32 33 34 35 36 37 91 92 93 94 95 96 97${NC}"
	echo -e "${WHITE} = = > Semantic warning colors RE/YE/GR will remain fixed.${NC}"
	echo

	read -r -p " = = > RED ansi number      : " red_code
	read -r -p " = = > GREEN ansi number    : " green_code
	read -r -p " = = > YELLOW ansi number   : " yellow_code
	read -r -p " = = > BLUE ansi number     : " blue_code
	read -r -p " = = > MAGENTA ansi number  : " magenta_code
	read -r -p " = = > CYAN ansi number     : " cyan_code
	read -r -p " = = > WHITE ansi number    : " white_code
	read -r -p " = = > BWHITE ansi number   : " bwhite_code

	apply_color_map \
		"$red_code" "$green_code" "$yellow_code" "$blue_code" \
		"$magenta_code" "$cyan_code" "$white_code" "$bwhite_code"
}

show_current_color_map() {
	echo
	echo -e "${WHITE} = = > Current Twisted Display Palette Preview:${NC}"
	echo -e "     ${RED}RED${NC}  ${GREEN}GREEN${NC}  ${YELLOW}YELLOW${NC}  ${BLUE}BLUE${NC}"
	echo -e "     ${MAGENTA}MAGENTA${NC}  ${CYAN}CYAN${NC}  ${WHITE}WHITE${NC}  ${BWHITE}BWHITE${NC}"
	echo
	echo -e "${WHITE} = = > Fixed Semantic Warning Palette Preview:${NC}"
	echo -e "     ${GR}GR = SAFE / OK${NC}"
	echo -e "     ${YE}YE = CAUTION / NOTICE${NC}"
	echo -e "     ${YEB}YEB = Blinking CAUTION / NOTICE${NC}"
	echo -e "     ${RE}RE = RISK / FAIL / DANGER${NC}"
	echo -e "     ${REB}REB = Blinking RISK / FAIL / DANGER${NC}"
	echo
}

twisted() {
	local mode="${1,,}"

	case "$mode" in
		random)
			twisted_randomize
			;;
		theme)
			twisted_theme "$2"
			;;
		manual)
			twisted_manual
			;;
		show|preview)
			show_current_color_map
			return 0
			;;
		reset|default|classic)
			twisted_theme classic
			;;
		*)
			echo -e "${YE} = = > Invalid Twisted Mode.${NC}"
			return 1
			;;
	esac
}

# ----- INITIALIZE DEFAULT COLORS AT STARTUP -----------------------------------
init_base_colors

# ===== TWISTED MENU ===========================================================
# PURPOSE:
# Small menu wrapper for the twisted color/theme engine.
#
# REQUIRES:
# - twisted()
# - twisted_theme()
# - show_current_color_map()
# - pause()
#
# NOTES:
# - Standard display colors may be remapped
# - Semantic warning colors RE/YE/GR remain fixed
# - This menu is cosmetic-facing and safe to expose under Advanced Tools
# ==============================================================================

run_twisted_menu() {
	local choice theme_name

	while true; do
		clear
		echo -e "${CYAN}========================================================================${NC}"
		echo -e "${CYAN}                          TWISTED COLOR MENU                            ${NC}"
		echo -e "${CYAN}========================================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Randomize Display Palette${NC}"
		echo -e "${YELLOW}     2) Choose Theme Preset${NC}"
		echo -e "${YELLOW}     3) Manual Per-Color ANSI Input${NC}"
		echo -e "${YELLOW}     4) Show Current Color Preview${NC}"
		echo -e "${YELLOW}     5) Reset To Classic${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo
        echo -ne "${YELLOW}"
		read -r -p " = = > Select option [1-5 | 0.=return]: ${NC}${GREEN}" choice
        echo -e "${NC}"

        if is_exit_token "$choice"; then
            return 0
        fi

		case "$choice" in

			1)
				echo
				echo -e "${YELLOW} = = > Randomizing display palette...${NC}"
				twisted random
				pause
				;;

			2)
				echo
				echo -e "${WHITE}Available themes:${NC}"
				echo -e "${WHITE}  1) ${CYAN}classic${NC}"
				echo -e "${WHITE}  2) ${CYAN}mellow${NC}"
				echo -e "${WHITE}  3) ${CYAN}danger${NC}"
				echo -e "${WHITE}  4) ${CYAN}ice${NC}"
				echo -e "${WHITE}  5) ${CYAN}twisted${NC}"
				echo -e "${WHITE}  6) ${CYAN}mono${NC}"
				echo -e "${WHITE}  0.) Return${NC}"
				echo

				read -r -p " = = > Select theme [1-6 | 0.=return]: " theme_name
				theme_name="${theme_name,,}"
				theme_name="${theme_name//[[:space:]]/}"

				case "$theme_name" in
					1)
						twisted theme classic
						twisted_save_theme "classic"
						;;
					2)
						twisted theme mellow
						twisted_save_theme "mellow"
						;;
					3)
						twisted theme danger
						twisted_save_theme "danger"
						;;
					4)
						twisted theme ice
						twisted_save_theme "ice"
						;;
					5)
						twisted theme twisted
						twisted_save_theme "twisted"
						;;
					6)
						twisted theme mono
						twisted_save_theme "mono"
						;;
					0.|q|Q)
						echo -e "${YE} = = > Theme selection canceled.${NC}"
						pause
						continue
						;;
					*)
						echo -e "${YE} = = > Invalid theme selection.${NC}"
						pause
						continue
						;;
				esac

				pause
				;;

			3)
				echo
				echo -e "${YELLOW} = = > Manual ANSI mapping selected.${NC}"
				twisted manual
				pause
				;;

			4)
				show_current_color_map
				pause
				;;

			5)
				echo
				echo -e "${YELLOW} = = > Resetting display palette to classic...${NC}"
				twisted reset
				pause
				;;


			*)
				echo
				echo -e "${YE} = = > Invalid selection.${NC}"
				pause
				;;
		esac
	done
}

# END OF COLOR SYSTEM / TWISTED THEME ENGINE ===================================

# ========================================================
# #MARKER: SAFE SHARED FACTORY CONFIG WRITER
# ========================================================
# PURPOSE:
# - Update only the requested variables inside factory.conf.
# - Preserve unrelated settings, comments, blank lines, and future additions.
# - Replace duplicate assignments for an updated variable with one canonical line.
# - Write atomically so an interrupted save does not leave a partial config.
#
# USAGE:
#   factory_conf_set_many KEY value [KEY value ...]
#
# STANDALONE RULE:
# - Merely launching Factory does not create factory.conf.
# - The parent directory and config file are created only when the user
#   explicitly saves a persistent setting.
# ========================================================
factory_conf_set_many() {
	local config_file="${FACTORY_CONFIG_FILE:-${FACTORY_HOME}/factory.conf}"
	local config_dir temp_file updates_file
	local key value quoted

	if (( $# == 0 || $# % 2 != 0 )); then
		echo -e "${REB} = = > Internal Config Save Error: Expected KEY / VALUE Pairs.${NC}" >&2
		return 1
	fi

	config_dir="$(dirname -- "$config_file")"
	mkdir -p -- "$config_dir"

	temp_file="$(mktemp "${config_file}.tmp.XXXXXX")" || return 1
	updates_file="$(mktemp "${config_file}.updates.XXXXXX")" || {
		rm -f -- "$temp_file"
		return 1
	}

	while (( $# >= 2 )); do
		key="$1"
		value="$2"
		shift 2

		if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
			echo -e "${REB} = = > Refusing Invalid Config Variable Name:${NC} ${YELLOW}$key${NC}" >&2
			rm -f -- "$temp_file" "$updates_file"
			return 1
		fi

		printf -v quoted '%q' "$value"
		printf '%s\t%s\n' "$key" "$quoted" >> "$updates_file"
	done

	if [[ -f "$config_file" ]]; then
		awk -v updates_file="$updates_file" '
			BEGIN {
				FS = "\t"
				while ((getline < updates_file) > 0) {
					update[$1] = $2
					order[++count] = $1
				}
				close(updates_file)
			}

			{
				line = $0
				if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/) {
					key = line
					sub(/^[[:space:]]*/, "", key)
					sub(/[[:space:]]*=.*/, "", key)
					if (key in update) {
						if (!(key in written)) {
							print key "=" update[key]
							written[key] = 1
						}
						next
					}
				}
				print line
			}

			END {
				for (i = 1; i <= count; i++) {
					key = order[i]
					if (!(key in written)) {
						print key "=" update[key]
						written[key] = 1
					}
				}
			}
		' "$config_file" > "$temp_file"
	else
		awk -F '\t' '{ print $1 "=" $2 }' "$updates_file" > "$temp_file"
	fi

	chmod --reference="$config_file" "$temp_file" 2>/dev/null || chmod 600 "$temp_file" 2>/dev/null || true
	mv -f -- "$temp_file" "$config_file"
	rm -f -- "$updates_file"
}

# ========================================================
# #MARKER: TWISTED STICKY SETTINGS
# ========================================================
TWISTED_CONFIG_FILE="$FACTORY_CONFIG_FILE"

twisted_save_theme() {
	local theme_name="$1"

	factory_conf_set_many \
		TWISTED_THEME "$theme_name"

	echo -e "${GR} = = > Twisted Theme Saved:${NC} ${YELLOW}$theme_name${NC}"
	echo -e "${CYAN} = = > Shared Config:${NC} ${YELLOW}$(factory_display_path "$TWISTED_CONFIG_FILE")${NC}"
}

twisted_load_sticky_theme() {
	local saved_theme=""

	[[ -f "$TWISTED_CONFIG_FILE" ]] || return 0

	# shellcheck disable=SC1090
	source "$TWISTED_CONFIG_FILE" 2>/dev/null || return 0

	saved_theme="${TWISTED_THEME:-}"

	[[ -n "$saved_theme" ]] || return 0

	if twisted theme "$saved_theme" 2>/dev/null; then
		echo -e "${CYAN} = = > Twisted Theme Loaded:${NC} ${YELLOW}$saved_theme${NC}"
	fi
}
# ----- LOAD SAVED TWISTED THEME AFTER STICKY HELPERS EXIST --------------------
twisted_load_sticky_theme

# ========================================================
# #MARKER: SMARTCUT STICKY SESSION SETTINGS
# ========================================================
SMARTCUT_SESSION_CONFIG_FILE="$FACTORY_CONFIG_FILE"

smartcut_save_sticky_session() {
	factory_conf_set_many \
		INTRO_SCAN_START "${INTRO_SCAN_START:-${DEFAULT_SCAN_START:-30}}" \
		INTRO_MAX_SCAN "${INTRO_MAX_SCAN:-${DEFAULT_MAX_SCAN:-601}}" \
		INTRO_HASH_DIFF "${INTRO_HASH_DIFF:-${DEFAULT_HASH_DIFF:-16}}" \
		INTRO_STEP_SIZE "${INTRO_STEP_SIZE:-1}" \
		INTRO_ANCHOR_SECONDS "${INTRO_ANCHOR_SECONDS:-3,5,7}" \
		INTRO_HASH_MODE "${INTRO_HASH_MODE:-phash}" \
		OUTRO_TAIL_SCAN_SECONDS "${OUTRO_TAIL_SCAN_SECONDS:-auto}" \
		OUTRO_TAIL_SCAN_PAD_SECONDS "${OUTRO_TAIL_SCAN_PAD_SECONDS:-10}" \
		OUTRO_TAIL_SCAN_MIN_SECONDS "${OUTRO_TAIL_SCAN_MIN_SECONDS:-45}" \
		OUTRO_TAIL_SCAN_MAX_SECONDS "${OUTRO_TAIL_SCAN_MAX_SECONDS:-160}" \
		OUTRO_HASH_DIFF "${OUTRO_HASH_DIFF:-${DEFAULT_HASH_DIFF:-16}}" \
		OUTRO_STEP_SIZE "${OUTRO_STEP_SIZE:-1}" \
		OUTRO_ANCHOR_SECONDS "${OUTRO_ANCHOR_SECONDS:-8,12,16}" \
		OUTRO_HASH_MODE "${OUTRO_HASH_MODE:-dhash}" \
		TIP_TRIM_SECONDS "${TIP_TRIM_SECONDS:-0}" \
		TAIL_TRIM_SECONDS "${TAIL_TRIM_SECONDS:-0}" \
		TIP_OFFSET_SECONDS "${TIP_OFFSET_SECONDS:-0}" \
		INTRO_PAD_BEFORE_SECONDS "${INTRO_PAD_BEFORE_SECONDS:-0}" \
		INTRO_PAD_AFTER_SECONDS "${INTRO_PAD_AFTER_SECONDS:-0}" \
		OUTRO_PAD_BEFORE_SECONDS "${OUTRO_PAD_BEFORE_SECONDS:-0}" \
		SMC_BARFIX_LITE_ENABLED "${SMC_BARFIX_LITE_ENABLED:-1}" \
		SMC_BARFIX_AUDIO_LANG "${SMC_BARFIX_AUDIO_LANG:-eng}" \
		SMC_BARFIX_SUBS_OFF "${SMC_BARFIX_SUBS_OFF:-1}" \
		SMC_BARFIX_TITLE_MODE "${SMC_BARFIX_TITLE_MODE:-after_sxxexx}" \
		SMC_BARFIX_TITLE_SEGMENT "${SMC_BARFIX_TITLE_SEGMENT:-3}" \
		REKEY_CRF "${REKEY_CRF:-24}"

	echo -e "${GR} = = > SmartCut Session VarZ Saved:${NC} ${YELLOW}$(factory_display_path "$SMARTCUT_SESSION_CONFIG_FILE")${NC}"
	echo -e "${GREEN} = = > Support Them Here: ${RE}https://${BW}smartmediacutter${CY}.com/${NC}"
}

smartcut_load_sticky_session() {
	[[ -f "$SMARTCUT_SESSION_CONFIG_FILE" ]] || return 0

	# shellcheck disable=SC1090
	source "$SMARTCUT_SESSION_CONFIG_FILE" 2>/dev/null || return 0

	echo -e "${CYAN} = = > SmartCut Session VarZ Loaded:${NC} ${YELLOW}$(factory_display_path "$SMARTCUT_SESSION_CONFIG_FILE")${NC}"
	echo -e "${GREEN} = = > Support Them Here: ${RE}https://${BW}smartmediacutter${CY}.com/${NC}"
}

# ------------------ DEFAULTS ------------------
# ========================================================
# ARCHIVE TEMP WORKDIR (SAFE WRITE AREA)
# ========================================================
ARCHIVE_TMPDIR=""
# ------------------ DEFAULTS ------------------
DEFAULT_SCAN_START=30
DEFAULT_HASH_DIFF=16
DEFAULT_MAX_SCAN=601
STEP_SIZE="${STEP_SIZE:-1}"
ANCHOR_SECONDS="${ANCHOR_SECONDS:-3,5,7}"
DEFAULT_BLACK_DURATION=0.5
DEFAULT_BLACK_PIXTH=0.10

INTRO_MAP="intro_map.csv"
output="intro_template.mkv"
INFO_MAP="info.csv"

PHASH_ENGINE="${FACTORY_HOME}/.phash_engine.py"
PHASH_STDERR_LOG="${PHASH_STDERR_LOG:-${FACTORY_HOME}/.phash_engine.stderr.log}"
INTRO_TEMPLATE_DIR="${INTRO_TEMPLATE_DIR:-${FACTORY_HOME}/intro_template}"
OUTRO_TEMPLATE="${OUTRO_TEMPLATE:-${INTRO_TEMPLATE_DIR}/outro.mkv}"
OUTRO_TEMPLATE_GLOB="${OUTRO_TEMPLATE_GLOB:-${INTRO_TEMPLATE_DIR}/outro*.mkv}"
OUTRO_MULTIKEY_DURATION_TOLERANCE_SECONDS="${OUTRO_MULTIKEY_DURATION_TOLERANCE_SECONDS:-1.0}"

# =========================
# #MARKER: REKEY BATCH DEFAULTS / SANITY BAND
# =========================
# PURPOSE:
# - One clear place to tune REKEY video quality for testing / calibration.
# - Hold The Default Quality Knob For REKEY Production
# - Hold The Acceptable Size-Movement Sanity Band For The
#    First-File Calibration Check In Batch Mode
#
# DESIGN INTENT:
# - REKEY is a QUALITY-FIRST, CUT-FRIENDLY working source.
# - The 1-second GOP structure stays fixed.
# - This knob only adjusts x264 quality pressure.
# - Audio Copy-Through
# - Avoid Unnecessary Size Movement Either Way
#
# GUIDANCE:
# - 18 = conservative / quality-leaning
# - 19 = slight size relief from 18
# - 20 = balanced default
# - 21 = slight additional size reduction
# - 22 = stronger reduction, inspect more carefully
#
# BAND RULE:
# - Growth Beyond REKEY_GROWTH_WARN_PERCENT  => Worth User Attention
# - Shrink Beyond REKEY_SHRINK_WARN_PERCENT  => Worth User Attention
#
# TARGET RULE:
# - TARGET_MAX_GROWTH / TARGET_MAX_SHRINK are the tighter "auto-try" band
# - The warn band can stay looser so the report still communicates drift
#
# NOTE:
# - These Are CLUE / HINT Thresholds, Not Absolute Truth Detectors.
# - They Exist To Pull Human Eyes To Suspicious Outcomes Early.
# - Change this ONLY when deliberately testing or re-tuning REKEY behavior.
# - Audio policy for REKEY is copy-through; we are not here to "improve" audio.
# =========================
REKEY_GROWTH_WARN_PERCENT=25
REKEY_SHRINK_WARN_PERCENT=15
TARGET_MAX_GROWTH=10
TARGET_MAX_SHRINK=5
REKEY_CRF=24
ARRAY_MAX_JOBS=2
smartcut_load_sticky_session

# - Helpers

# Safe Pause Function With Color
pause() {
    echo -e "${GR}>->->->-> = = > Review Above Carefully.....${NC}"
    echo -e "${BW}>->->->-> = = > Screen Will Clear When You ${NC}"
    echo -e "${YE}>->->->-> = = > Press Enter To Continue....${NC}"
    read -r _
}

# - Canonicalize names everywhere helper
canonical_factory_path() {
	local p="$1"

	# collapse leading ./ only
	while [[ "$p" == ./* ]]; do
		p="${p#./}"
	done

	printf '%s\n' "$p"
}

factory_display_path() {
	local p="${1:-}"

	[[ -z "$p" ]] && return 0

	case "$p" in
		"$FACTORY_HOME"/*)
			printf 'TOOLBOX/%s\n' "${p#"$FACTORY_HOME"/}"
			return 0
			;;
		"$FACTORY_WORKDIR"/*)
			printf './%s\n' "${p#"$FACTORY_WORKDIR"/}"
			return 0
			;;
	esac

	printf '%s\n' "$p"
}

# ================================================================
# #MARKER: TEMPLATE PATH DISPLAY / MAP NORMALIZER
# ================================================================
factory_template_map_path() {
	local p="${1:-}"
	local base

	[[ -z "$p" ]] && return 0

	base="$(basename "$p")"

	case "$p" in
		"${INTRO_TEMPLATE_DIR:-${FACTORY_HOME}/intro_template}"/*)
			printf 'intro_template/%s\n' "$base"
			return 0
			;;
		"${FACTORY_HOME}/intro_template"/*)
			printf 'intro_template/%s\n' "$base"
			return 0
			;;
		*/TOOLBOX/intro_template/*)
			printf 'intro_template/%s\n' "$base"
			return 0
			;;
		intro_template/*)
			printf '%s\n' "$p"
			return 0
			;;
	esac

	printf '%s\n' "$p"
}

# ================================================================
# #MARKER: INTRO TEMPLATE AUTHORITY RESOLVER
# ================================================================
# PURPOSE:
# - Decide which intro_template directory is authoritative.
# - Prefer TOOLBOX / FACTORY_HOME templates.
# - Do NOT silently ignore working-folder templates if they contain real media.
#
# DESIGN RULE:
# - TOOLBOX/intro_template is the preferred repo.
# - Working-folder intro_template is allowed as a bridge/cache only when empty.
# - If both locations contain intro/outro template media, ask the user.
#
# SETS:
# - INTRO_TEMPLATE_DIR
# - OUTRO_TEMPLATE
# - OUTRO_TEMPLATE_GLOB
# - INTRO_TEMPLATE_AUTHORITY
# ================================================================

factory_count_template_media() {
	local dir="${1:-}"
	local count=0
	local f

	[[ -d "$dir" ]] || {
		printf '0\n'
		return 0
	}

	shopt -s nullglob nocaseglob
	for f in "$dir"/intro*.mkv "$dir"/outro*.mkv; do
		[[ -f "$f" ]] || continue
		((count+=1)) || :
	done
	shopt -u nullglob nocaseglob

	printf '%s\n' "$count"
}

factory_print_template_location_summary() {
	local label="$1"
	local dir="$2"
	local count="$3"

	echo -e "${CYAN} = = > ${label}:${NC} ${YELLOW}$(factory_display_path "$dir")${NC}"
	echo -e "${CYAN}       Template Media:${NC} ${GREEN}${count}${NC}"
}

factory_set_intro_template_authority() {
	local dir="$1"
	local authority="$2"

	INTRO_TEMPLATE_DIR="$dir"
	OUTRO_TEMPLATE="${INTRO_TEMPLATE_DIR}/outro.mkv"
	OUTRO_TEMPLATE_GLOB="${INTRO_TEMPLATE_DIR}/outro*.mkv"
	INTRO_TEMPLATE_AUTHORITY="$authority"

	export INTRO_TEMPLATE_DIR OUTRO_TEMPLATE OUTRO_TEMPLATE_GLOB INTRO_TEMPLATE_AUTHORITY
}

resolve_intro_template_authority() {
	local toolbox_dir="${FACTORY_HOME}/intro_template"
	local work_dir="${FACTORY_WORKDIR}/intro_template"

	local toolbox_real=""
	local work_real=""

	toolbox_real="$(realpath -m "$toolbox_dir" 2>/dev/null || printf '%s\n' "$toolbox_dir")"
	work_real="$(realpath -m "$work_dir" 2>/dev/null || printf '%s\n' "$work_dir")"

	if [[ "$toolbox_real" == "$work_real" ]]; then
		mkdir -p "$toolbox_dir"
		factory_set_intro_template_authority "$toolbox_dir" "TOOLBOX_LINKED"
		echo -e "${CYAN} = = > Intro Template Authority:${NC} ${YELLOW}TOOLBOX_LINKED${NC} ${GREEN}$(factory_display_path "$INTRO_TEMPLATE_DIR")${NC}"
		return 0
	fi

	local toolbox_count=0
	local work_count=0
	local choice

	toolbox_count="$(factory_count_template_media "$toolbox_dir")"
	work_count="$(factory_count_template_media "$work_dir")"

	# ------------------------------------------------------------
	# If user already forced INTRO_TEMPLATE_DIR, honor it.
	# ------------------------------------------------------------
	if [[ -n "${INTRO_TEMPLATE_DIR_USER_OVERRIDE:-}" && -d "${INTRO_TEMPLATE_DIR_USER_OVERRIDE:-}" ]]; then
	INTRO_TEMPLATE_DIR="$INTRO_TEMPLATE_DIR_USER_OVERRIDE"
		factory_set_intro_template_authority "$INTRO_TEMPLATE_DIR" "USER_OVERRIDE"
		echo -e "${CYAN} = = > Intro Template Authority:${NC} ${YELLOW}USER_OVERRIDE${NC} ${GREEN}$(factory_display_path "$INTRO_TEMPLATE_DIR")${NC}"
		return 0
	fi

	# ------------------------------------------------------------
	# Neither location has template media.
	# Create/use TOOLBOX repo as the empty authority.
	# ------------------------------------------------------------
	if (( toolbox_count == 0 && work_count == 0 )); then
		mkdir -p "$toolbox_dir"
		factory_set_intro_template_authority "$toolbox_dir" "TOOLBOX_EMPTY"
		echo -e "${CYAN} = = > Intro Template Authority:${NC} ${YELLOW}TOOLBOX_EMPTY${NC} ${GREEN}$(factory_display_path "$INTRO_TEMPLATE_DIR")${NC}"
		return 0
	fi

	# ------------------------------------------------------------
	# Only TOOLBOX has real templates.
	# ------------------------------------------------------------
	if (( toolbox_count > 0 && work_count == 0 )); then
		factory_set_intro_template_authority "$toolbox_dir" "TOOLBOX"
		echo -e "${CYAN} = = > Intro Template Authority:${NC} ${YELLOW}TOOLBOX${NC} ${GREEN}$(factory_display_path "$INTRO_TEMPLATE_DIR")${NC}"
		return 0
	fi

	# ------------------------------------------------------------
	# Only working folder has real templates.
	# Ask before using them because templates are show/season specific.
	# ------------------------------------------------------------
	if (( toolbox_count == 0 && work_count > 0 )); then
		echo
		echo -e "${YE}================================================${NC}"
		echo -e "${YE}        WORKING TEMPLATE REPO DETECTED          ${NC}"
		echo -e "${YE}================================================${NC}"
		factory_print_template_location_summary "TOOLBOX Template Repo" "$toolbox_dir" "$toolbox_count"
		factory_print_template_location_summary "Working Template Dir" "$work_dir" "$work_count"
		echo
		echo -e "${YELLOW}     1) Use Working-Folder Templates For This Run${NC}"
		echo -e "${YELLOW}     2) Move Working-Folder Templates Into TOOLBOX, Then Use TOOLBOX${NC}"
		echo -e "${YELLOW}     0.) Return / Cancel${NC}"
		echo

		prompt_menu_choice " = = > Choose Template Authority [1-2 | 0.=return]: " choice

		case "$choice" in
			1)
				factory_set_intro_template_authority "$work_dir" "WORKDIR"
				return 0
				;;
			2)
				mkdir -p "$toolbox_dir"
				shopt -s nullglob nocaseglob
				mv -n -- "$work_dir"/intro*.mkv "$work_dir"/outro*.mkv "$toolbox_dir"/ 2>/dev/null || true
				shopt -u nullglob nocaseglob

				factory_set_intro_template_authority "$toolbox_dir" "TOOLBOX_IMPORTED"
				return 0
				;;
			0.|q)
				return 1
				;;
			*)
				echo -e "${REB} = = > Invalid Template Authority Selection.${NC}"
				return 1
				;;
		esac
	fi

	# ------------------------------------------------------------
	# Both locations contain real templates.
	# This is a conflict and must not be guessed.
	# ------------------------------------------------------------
	echo
	echo -e "${REB}================================================${NC}"
	echo -e "${REB}        TEMPLATE AUTHORITY CONFLICT DETECTED    ${NC}"
	echo -e "${REB}================================================${NC}"
	factory_print_template_location_summary "TOOLBOX Template Repo" "$toolbox_dir" "$toolbox_count"
	factory_print_template_location_summary "Working Template Dir" "$work_dir" "$work_count"
	echo
	echo -e "${YELLOW} = = > Both locations contain intro/outro template media.${NC}"
	echo -e "${YELLOW} = = > Factory will not silently choose between season/show templates.${NC}"
	echo
	echo -e "${YELLOW}     1) Use TOOLBOX Templates${NC}"
	echo -e "${YELLOW}     2) Use Working-Folder Templates For This Run${NC}"
	echo -e "${YELLOW}     0.) Return / Cancel${NC}"
	echo

	prompt_menu_choice " = = > Choose Template Authority [1-2 | 0.=return]: " choice

	case "$choice" in
		1)
			factory_set_intro_template_authority "$toolbox_dir" "TOOLBOX_CONFLICT_CHOSEN"
			;;
		2)
			factory_set_intro_template_authority "$work_dir" "WORKDIR_CONFLICT_CHOSEN"
			;;
		0.|q)
			return 1
			;;
		*)
			echo -e "${REB} = = > Invalid Template Authority Selection.${NC}"
			return 1
			;;
	esac

	return 0
}

# ================================================================
# #MARKER: RESCUED SOURCE ARCHIVE HELPER
# ================================================================
archive_rescued_source_file() {
	local src="$1"
	local run_dir="${2:-OEM/RESCUED/run_$(date '+%Y%m%d_%H%M%S')}"
	local target_dir base target stem ext n

	[[ -f "$src" ]] || {
		echo -e "${YE} = = > Rescue Archive Skipped, Source Missing:${NC} ${YELLOW}$src${NC}"
		return 0
	}

	target_dir="$run_dir"
	mkdir -p "$target_dir"

	base="$(basename "$src")"
	target="$target_dir/$base"

	if [[ -e "$target" ]]; then
		stem="${base%.*}"
		ext="${base##*.}"

		if [[ "$stem" == "$ext" ]]; then
			ext=""
		else
			ext=".$ext"
		fi

		n=1
		while [[ -e "$target_dir/${stem}_$n${ext}" ]]; do
			((n+=1)) || :
		done

		target="$target_dir/${stem}_$n${ext}"
	fi

	mv -- "$src" "$target"

	echo -e "${CYAN} = = > Archived Rescued Source:${NC} ${YELLOW}$src${NC}"
	echo -e "${CYAN} = = > RESCUED Location:${NC} ${GREEN}$target${NC}"
}

# ================================================================
# #MARKER: OEM STAGE ARCHIVE HELPERS
# ================================================================
# PURPOSE:
# - Keep only the current working product in the working directory.
# - Move replaced / previous-stage files into .OEM run folders.
# - Prevent workflow prefix stacking.
# - Give every process stage its own clean archive lane.
#
# LAYOUT:
#   .OEM/
#     day_DD/
#       ORIGINAL/
#       REKEY/
#       SMC/
#       BARFIX/
#       SUBTOX/
#       ARCHIVE/
#       ETC/
#
# RULE:
# - Working dir gets the newest active output.
# - Old active file gets moved to .OEM/<run>/<stage>/
# - New output name is built from clean base name + one current prefix.
# ================================================================

OEM_ROOT="${OEM_ROOT:-OEM}"
OEM_RUN_DIR=""

init_oem_run_dir() {
	if [[ -n "${OEM_RUN_DIR:-}" && -d "$OEM_RUN_DIR" ]]; then
		printf '%s\n' "$OEM_RUN_DIR"
		return 0
	fi

	OEM_RUN_DIR="$OEM_ROOT/$(date '+%m-%d')"

	mkdir -p \
		"$OEM_RUN_DIR/ORIGINAL" \
		"$OEM_RUN_DIR/REKEY" \
		"$OEM_RUN_DIR/SMC" \
		"$OEM_RUN_DIR/BARFIX" \
		"$OEM_RUN_DIR/SUBTOX" \
		"$OEM_RUN_DIR/ARCHIVE" \
		"$OEM_RUN_DIR/ETC"

	printf '%s\n' "$OEM_RUN_DIR"
}

# ================================================================
# #MARKER: WORKFLOW PREFIX STRIPPER (NEUTRAL)
# ================================================================
# PURPOSE:
# - Strip ALL known workflow prefixes repeatedly until clean
# - Prevent prefix stacking across stages
# - Each stage re-applies ONLY its own prefix
#
# DESIGN:
# - Loop until no changes (handles stacked prefixes)
# - Safe for reuse anywhere
# IMPORTANT:
# - ARCHIVE_ / ARRAY_ are intentionally NOT stripped here by default.
# - Those represent intentional archival identity.
# - Finalize may optionally offer archival rename cleanup separately.
#
# - OEM_ is NOT treated as a normal workflow prefix.
# - OEM handling belongs exclusively to Finalize safety logic.
# ================================================================

strip_workflow_prefixes() {
	local name="$1"
	local old

	while :; do
		old="$name"

		name="${name#REKEY_}"
		name="${name#SMC_}"

		name="${name#SUBTOX_}"
		name="${name#SUBPACKED_}"
		name="${name#BARFIX_}"

		name="${name#RESCUE_}"
		name="${name#PILOT_RESCUE_}"
		name="${name#REMUX_}"
		name="${name#AUDIOFIX_}"
		name="${name#TIMEPRESS_}"
		name="${name#AUDIOLEVEL_}"

		name="${name#TIPSNIP_}"
		name="${name#TAILTUCK_}"

		[[ "$name" == "$old" ]] && break
	done

	printf '%s\n' "$name"
}

build_stage_output_name() {
	local stage_prefix="$1"
	local src="$2"
	local clean

	clean="$(strip_workflow_prefixes "$(basename "$src")")"

	printf '%s_%s\n' "$stage_prefix" "$clean"
}

stage_archive_file() {
	local src="$1"
	local stage="$2"
	local run_dir stage_dir base target stem ext n

	[[ -f "$src" ]] || return 0

	init_oem_run_dir >/dev/null
	run_dir="$OEM_RUN_DIR"
	stage_dir="$run_dir/$stage"
	mkdir -p "$stage_dir"

	base="$(basename "$src")"
	target="$stage_dir/$base"

	if [[ -e "$target" ]]; then
		stem="${base%.*}"
		ext="${base##*.}"

		if [[ "$stem" == "$ext" ]]; then
			ext=""
		else
			ext=".$ext"
		fi

		n=1
		while [[ -e "$stage_dir/${stem}_$n${ext}" ]]; do
			((n+=1)) || :
		done

		target="$stage_dir/${stem}_$n${ext}"
	fi

	mv -- "$src" "$target"

	echo -e "${CYAN} = = > Archived Previous Stage File:${NC} ${YELLOW}$src${NC}"
	echo -e "${CYAN} = = > OEM Location:${NC} ${GREEN}$target${NC}"
}

prepare_stage_output_path() {
	local src="$1"
	local stage="$2"
	local prefix="$3"
	local out

	out="$(build_stage_output_name "$prefix" "$src")"

	stage_archive_file "$src" "$stage"

	printf '%s\n' "$out"
}

# =========================
# #INDIVIDUAL-FACTORY EXIT TOKEN (TEN-KEY FRIENDLY)
# =========================
# PURPOSE:
# - Provide A Universal One-Hand Numpad Exit / Cancel Token
#
# RULE:
# - "0." = cancel / back / exit
# - q/Q  = normal keyboard exit
#
# IMPORTANT:
# - Plain "0" is NOT a universal exit token anymore.
# - Some menus use 0 as a real selectable option.
#
is_exit_token() {
    local v="${1:-}"
    [[ "$v" == "0." || "$v" == "q" || "$v" == "Q" ]]
}

#need to fill these in 

# =========================================================================================
# #MARKER: CORE MATH HELPERS THIS IS A GROUP TITLE NOT AN INDIVIDUAL ONE
# =========================================================================================

# Safe float math
fadd() { echo "scale=3; ($1)+($2)" | bc; }
fsub() { echo "scale=3; ($1)-($2)" | bc; }
fmax0() { echo "scale=3; if(($1)<0) 0 else ($1)" | bc; }

# =========================================================================================
# #MARKER: TIME / PARSE HELPERS THIS IS A GROUP TITLE NOT AN INDIVIDUAL ONE
# =========================================================================================

smc_explain_cut_plan() {
	local cut_args="$1"
	local token n=0

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              SMARTCUT CUT PLAN REVIEW          ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${YE} = = >     ${CYAN}= = = = = = ${NC}${YELLOW}Review Decimal Points Carefully ${CYAN}= = = = = = ${NC}"
	echo -e "${YE} = = > Example: ${GREEN}24.5 = 24.5 Seconds, But 2.20 = 2 Minutes 20 Seconds.${NC}"
	echo -e "${YE} = = > For Fractional Seconds After Minutes Use Colon Format:${GREEN} 2:20.5 = 2 Minutes 20.5 Seconds.${NC}"
	echo
	echo -e "${CYAN} = = > Raw Cut Plan:${NC} ${YELLOW}$cut_args${NC}"
	echo

	IFS=',' read -r -a tokens <<< "$cut_args"

	for ((i=0; i<${#tokens[@]}; i+=2)); do
		local start="${tokens[$i]:-}"
		local end="${tokens[$((i+1))]:-}"

		((n+=1)) || :

		echo -e "${YELLOW} [$n] REMOVE SEGMENT${NC}"
		echo -e "${CYAN}     Start:${NC} ${GREEN}$start${NC}"
		echo -e "${CYAN}     End:  ${NC} ${GREEN}$end${NC}"

		if [[ "$start" != "end" && "$start" != -* ]]; then
			echo -e "${CYAN}     Start HMS:${NC} ${YELLOW}$(format_seconds_hms "$start")${NC}"
		fi

		if [[ "$end" != "end" && "$end" != -* ]]; then
			echo -e "${CYAN}     End HMS:  ${NC} ${YELLOW}$(format_seconds_hms "$end")${NC}"
		fi

		echo
	done

}

# ================================================================
# #INDIVIDUAL-NORMALIZED TIME PROMPT HELPER
# ================================================================
prompt_time_seconds() {
	local prompt="$1"
	local __var_name="$2"
	local raw normalized

	prompt_read "$prompt" raw

	if is_exit_token "$raw"; then
		printf -v "$__var_name" '%s' "EXIT"
		return 1
	fi

	if [[ -z "$raw" ]]; then
		printf -v "$__var_name" '%s' ""
		return 0
	fi

	normalized="$(to_seconds "$raw" 2>/dev/null || true)"

	if [[ -z "${normalized:-}" ]]; then
		echo -e "${REB} = = > Invalid Time Entry:${NC} ${YELLOW}$raw${NC}"
		return 1
	fi

	printf -v "$__var_name" '%s' "$normalized"
	return 0
}

# =========================
# #MARKER: HMS DISPLAY HELPER
# =========================
# PURPOSE:
# - Convert decimal seconds into HH:MM:SS.mmm for friendly display
#
# EXAMPLE:
# - 2592.616 -> 00:43:12.616
# =========================
format_seconds_hms() {
	local total="${1:-0}"

	awk -v t="$total" 'BEGIN {
		if (t < 0) t = 0

		h = int(t / 3600)
		m = int((t - (h * 3600)) / 60)
		s = t - (h * 3600) - (m * 60)

		printf "%02d:%02d:%06.3f", h, m, s
	}'
}

# ========================================================
# MARKER: GLOBAL ARRAY HEARTBEAT (PARENT-ONLY)
# ========================================================
archival_array_heartbeat() {
	local result_file="${1:-}"
	local total_files="${2:-0}"
	local start_ts="${3:-$(date +%s)}"

	local interval=0.2
	local tick=0
	local spin='|/-\'
	local spin_len=${#spin}

	local done_count=0
	local now_ts elapsed avg_seconds eta_seconds eta_human

	while true; do
		sleep "$interval"

		if [[ -n "$result_file" && -f "$result_file" ]]; then
			done_count="$(wc -l < "$result_file" 2>/dev/null || echo 0)"
		else
			done_count=0
		fi

		now_ts="$(date +%s)"
		elapsed=$(( now_ts - start_ts ))
		(( elapsed < 0 )) && elapsed=0

		eta_human="gathering timing data"
		if (( done_count >= 2 && total_files > done_count )); then
			avg_seconds=$(( elapsed / done_count ))
			eta_seconds=$(( avg_seconds * (total_files - done_count) ))
			eta_human="$(format_seconds_hms "$eta_seconds")"
		fi

		printf '\r\033[2K%b' \
			"${YEB} = = = > ${NC}${YELLOW}${spin:tick%spin_len:1} Factory Array Running ${spin:tick%spin_len:1}${NC} ${CYAN}Done:${NC} ${GREEN}${done_count}/${total_files}${NC} ${CYAN}Elapsed:${NC} ${YELLOW}$(format_seconds_hms "$elapsed")${NC} ${CYAN}ETA:${NC} ${YELLOW}$eta_human${NC}"

		((tick+=1)) || :
	done
}

# =========================
# #MARKER: IO / DISPLAY HELPERS
# =========================

ask_yes_no() {
    local prompt="$1"
    local ans

	echo -ne "${YELLOW}${prompt}${NC}${GREEN}"
	read -r ans
	echo -e "${NC}"

    ans="${ans,,}"
    ans="${ans//[[:space:]]/}"

	# ========================================================
	# TEN-KEY FRIENDLY YES/NO RULE
	# ========================================================
	# YES:
	#   y / yes / 1
	#
	# NO:
	#   n / no / 2 / blank
	#
	# PURPOSE:
	# - Keep classic keyboard yes/no support
	# - Add simple 10-key friendly 1/2 support
	# - Treat blank as safe default NO
	# ========================================================

    case "${ans:-2}" in
        y|yes|1)
            return 0
            ;;
        n|no|2|"")
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# =========================
# #MARKER: GENERIC PROMPT READ HELPER
# =========================
# PURPOSE:
# - Standardize ALL user input prompts across THE_FACTORY ecosystem
# - Enforce:
#     - echo -ne style
#     - color control
#     - consistent prompt formatting
#
# DESIGN:
# - Prints prompt using echo -ne (no newline)
# - Reads input safely with read -r
# - Assigns value to caller variable by name
#
# USAGE:
#   prompt_read " = = > Enter Value: " var_name
#
# NOTES:
# - Caller controls prompt text (including spacing and prefix)
# - Color is applied centrally here for consistency
# =========================
prompt_read() {
	local prompt="$1"
	local __var_name="$2"
	local __input

	echo -ne "${YELLOW}${prompt}${NC}${GREEN}"
	read -r __input
	echo -e "${NC}"

	printf -v "$__var_name" '%s' "$__input"
}

# =========================
# #MARKER: MENU CHOICE HELPER
# =========================
# PURPOSE:
# - Standardize menu selection input
# - Normalize spacing
# - Support ten-key exit
# - Avoid repeated parsing logic everywhere
#
# USAGE:
#   prompt_menu_choice " = = > Choose [1-3 | 0.=return]: " choice
#
prompt_menu_choice() {
	local prompt="$1"
	local __var_name="$2"
	local __input

	echo -ne "${YELLOW}${prompt}${NC}${GREEN}"
	read -r __input
	echo -e "${NC}"

	# normalize: strip whitespace + lowercase
	__input="${__input//[[:space:]]/}"
	__input="${__input,,}"

	printf -v "$__var_name" '%s' "$__input"
}

# ========================================================
# #MARKER: FACTORY TARGET LIMITER / MANUAL FILE PICKER
# ========================================================
# PURPOSE:
# - Let A Batch Run Use:
#     1) Full Target List
#     2) Manual Numbered File Picks
#     3) First-N Smoke Test
#
# DESIGN:
# - Accepts An Array Name By Reference
# - Rewrites That Array In Place
# - Keeps The Caller In Control Of What Files Are Eligible
#
# INPUT STYLE:
# - Single File:       1
# - Multiple Files:    1 4 7
# - Comma Style:       1,4,7
#
# EXIT RULE:
# - 0. or q cancels
# - Plain 0 is NOT an exit token
# ========================================================
limit_targets_interactive() {
	local -n _targets_ref=$1
	local mode how_many total
	local raw_choices choice clean_choice idx
	local -a picked_targets=()
	local -A seen_choice=()

	total="${#_targets_ref[@]}"
	(( total == 0 )) && return 0

	echo -e "${CYAN} = = > Targets Found:${NC} ${YELLOW}$total${NC}"
	echo -e "${CYAN} = = > Batch Selection Mode:${NC}"
	echo -e "${CYAN}     1) Use Full Batch${NC}"
	echo -e "${CYAN}     2) Pick Files Manually${NC}"
	echo -e "${CYAN}     3) Limit To First N Files${NC}"
	echo -e "${CYAN}     0.) Return / Cancel${NC}"
	echo

	echo -ne "${YELLOW} = = > Select option [1-3 | 0.=cancel | q] (Default: Full Batch):${NC}${GREEN}"
	read -r mode
	echo -e "${NC}"

	mode="${mode//[[:space:]]/}"

	if is_exit_token "$mode"; then
		return 1
	fi

	case "${mode:-1}" in
		1)
			echo -e "${GREEN} = = > Using Full Batch:${NC} ${YELLOW}${#_targets_ref[@]} file(s)${NC}"
			echo
			return 0
			;;

		2)
			echo
			echo -e "${CYAN}================================================${NC}"
			echo -e "${CYAN}             FACTORY MANUAL FILE PICKER         ${NC}"
			echo -e "${CYAN}================================================${NC}"
			echo

			for idx in "${!_targets_ref[@]}"; do
				printf '%b%5d)%b %b%s%b\n' \
					"$YELLOW" "$((idx + 1))" "$NC" "$GREEN" "${_targets_ref[$idx]}" "$NC"
			done

			echo
			echo -e "${CYAN} = = > Enter file number(s) to process.${NC}"
			echo -e "${CYAN} = = > Examples:${NC} ${YELLOW}1${NC} ${CYAN}or${NC} ${YELLOW}1 4 7${NC} ${CYAN}or${NC} ${YELLOW}1,4,7${NC}"
			echo -e "${CYAN} = = > Cancel:${NC} ${YELLOW}0.${NC} ${CYAN}or${NC} ${YELLOW}q${NC}"
			echo

			echo -ne "${YELLOW} = = > Pick File Number(s):${NC}${GREEN}"
			read -r raw_choices
			echo -e "${NC}"

			raw_choices="${raw_choices//,/ }"

			if is_exit_token "${raw_choices//[[:space:]]/}"; then
				return 1
			fi

			# ========================================================
			# #MARKER: MANUAL PICKER SPLIT FIX
			# ========================================================
			# Global IFS is newline/tab only, so force space-splitting here.
			# Allows:
			#   1
			#   1 4 7
			#   1,4,7
			# ========================================================
			local -a choice_list=()
			local old_ifs="$IFS"

			IFS=' '
			read -r -a choice_list <<< "$raw_choices"
			IFS="$old_ifs"

			for choice in "${choice_list[@]}"; do
				clean_choice="${choice//[[:space:]]/}"

				if is_exit_token "$clean_choice"; then
					return 1
				fi

				if [[ ! "$clean_choice" =~ ^[0-9]+$ ]]; then
					echo -e "${YE} = = > Ignoring Invalid Picker Entry:${NC} ${YELLOW}$clean_choice${NC}"
					continue
				fi

				if (( clean_choice < 1 || clean_choice > total )); then
					echo -e "${YE} = = > Ignoring Out-Of-Range Entry:${NC} ${YELLOW}$clean_choice${NC}"
					continue
				fi

				if [[ -n "${seen_choice[$clean_choice]:-}" ]]; then
					echo -e "${YE} = = > Ignoring Duplicate Entry:${NC} ${YELLOW}$clean_choice${NC}"
					continue
				fi

				seen_choice[$clean_choice]=1
				picked_targets+=("${_targets_ref[$((clean_choice - 1))]}")
			done

			if (( ${#picked_targets[@]} == 0 )); then
				echo -e "${REB} = = > No Valid File Selections Were Made.${NC}"
				echo -e "${YELLOW} = = > Batch Selection Cancelled.${NC}"
				echo
				return 1
			fi

			_targets_ref=("${picked_targets[@]}")

			echo
			echo -e "${GREEN} = = > Manual Pick Accepted:${NC} ${YELLOW}${#_targets_ref[@]} file(s)${NC}"
			echo
			return 0
			;;

		3)
			echo -ne "${YELLOW} = = > Enter How Many Files To Process:${NC}${GREEN}"
			read -r how_many
			echo -e "${NC}"

			how_many="${how_many//[[:space:]]/}"

			if is_exit_token "$how_many"; then
				return 1
			fi

			if [[ "$how_many" =~ ^[0-9]+$ ]] && (( how_many > 0 )); then
				if (( how_many < total )); then
					_targets_ref=("${_targets_ref[@]:0:how_many}")
				fi

				echo -e "${GREEN} = = > Batch Limited To:${NC} ${YELLOW}${#_targets_ref[@]}${NC} file(s)"
				echo
				return 0
			fi

			echo -e "${YELLOW} = = > Invalid Count. Using Full Batch Instead.${NC}"
			echo
			return 0
			;;

		*)
			echo -e "${YELLOW} = = > Invalid Selection. Using Full Batch Instead.${NC}"
			echo
			return 0
			;;
	esac
}

# =========================
# #MARKER: INTRO_MAP LAZY CREATE
# =========================
# WHY:
# - Prevents empty intro_map.csv files from being dropped in every directory.
# - File will only be created when a mode actually writes to it.
#
# CSV SCHEMA:
# - filename,start,end,start_hms,end_hms,template_used
#
# IMPORTANT:
# - start/end stay machine-safe numeric seconds
# - *_hms are human-readable only
# - template_used may be blank for manual entries
#
        # 7-column CSV:
        # filename,start,end,start_hms,end_hms,template_used,diff
        #
        # Manual rows intentionally leave template_used and diff blank.
ensure_intro_map() {
	if [[ ! -f "$INTRO_MAP" ]]; then
		printf '%s\n' "filename,start,end,start_hms,end_hms,template_used,diff" > "$INTRO_MAP"
	fi
}

# =========================
# #MARKER: HUMAN SIZE DISPLAY HELPER
# =========================
# PURPOSE:
# - Convert raw byte counts into friendly KB / MB / GB text
# - Keep reporting readable without losing exact values
#
# EXAMPLES:
# - 584194734  -> 557.1 MB
# - 1073741824 -> 1.00 GB
# =========================
format_bytes_human() {
	local bytes="${1:-0}"

	awk -v b="$bytes" 'BEGIN {
		if (b < 1024) {
			printf "%d B", b
		} else if (b < 1048576) {
			printf "%.1f KB", b / 1024
		} else if (b < 1073741824) {
			printf "%.1f MB", b / 1048576
		} else {
			printf "%.2f GB", b / 1073741824
		}
	}'
}

# start new rekey helpers all rekey related
# start new rekey builder and rekey-validation skipped scheme helpers

# =========================
# #MARKER: REKEY SIZE SANITY HELPERS
# =========================
# PURPOSE:
# - Give Batch REKEY A Lightweight "Eyes Open" Calibration Check
# - Compare Original vs REKEY Output On The FIRST FILE ONLY
# - Flag Suspicious Growth OR Suspicious Shrink For Human Review
#
# IMPORTANT:
# - This is NOT a tell-all quality detector.
# - It is an early-warning clue system that stays within bash-script scope.
# =========================
rekey_percent_change() {
	local orig_size="$1"
	local new_size="$2"

	awk -v o="$orig_size" -v n="$new_size" 'BEGIN {
		if (o <= 0) {
			print 0
		} else {
			printf "%.0f", ((n - o) / o) * 100
		}
	}'
}

rekey_size_sanity_bucket() {
	local delta_percent="$1"
	local grow_warn="${2:-$REKEY_GROWTH_WARN_PERCENT}"
	local shrink_warn="${3:-$REKEY_SHRINK_WARN_PERCENT}"

	if (( delta_percent > grow_warn )); then
		printf '%s\n' "GROWTH_WARN"
		return 0
	fi

	if (( delta_percent < -shrink_warn )); then
		printf '%s\n' "SHRINK_WARN"
		return 0
	fi

	printf '%s\n' "OK"
}

# =========================
# #MARKER: REKEY AUTO-STEP CRF HELPER
# =========================
# PURPOSE:
# - On First-File Calibration, Automatically Try The Next Logical CRF Step
#   Before Interrupting The User
#
# DESIGN:
# - If File Grew Too Much  -> Raise CRF By 1
# - If File Shrunk Too Much -> Lower CRF By 1
# - Keep The Search Narrow / Conservative
# - Stay Inside A Sane Working Range
#
# WHY:
# - We Already Know WHICH WAY The First File Missed
# - So We Can Nudge The CRF One Click In The Correct Direction
# - This avoids needless prompting for obvious near-misses
# =========================
rekey_auto_step_crf() {
	local current_crf="$1"
	local bucket="$2"
	local next_crf="$current_crf"

	case "$bucket" in
		GROWTH_WARN)
			# Too big -> increase CRF -> reduce size
			((next_crf+=1))
			;;
		SHRINK_WARN)
			# Too small -> decrease CRF -> allow more bitrate / size
			((next_crf-=1))
			;;
		*)
			printf '%s\n' "$current_crf"
			return 0
			;;
	esac

	# Keep The Search In A Conservative REKEY Window
	(( next_crf < 18 )) && next_crf=18
	(( next_crf > 26 )) && next_crf=26

	printf '%s\n' "$next_crf"
}

rekey_print_size_sanity_report() {
	local src="$1"
	local out="$2"
	local orig_size="$3"
	local new_size="$4"
	local delta_percent="$5"
	local bucket="$6"

	local bucket_color="$GR"
	case "$bucket" in
		GROWTH_WARN|SHRINK_WARN) bucket_color="$YE" ;;
		OK) bucket_color="$GR" ;;
		*) bucket_color="$NC" ;;
	esac

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        REKEY ROLLING SIZE SANITY CHECK         ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	echo -e "${CYAN} = = > Original Size:${NC} ${YELLOW}$(format_bytes_human "$orig_size")${NC} ${WHITE}(${orig_size} bytes)${NC}"
	echo -e "${CYAN} = = > REKEY Size:${NC} ${YELLOW}$(format_bytes_human "$new_size")${NC} ${WHITE}(${new_size} bytes)${NC}"

	if (( delta_percent >= 0 )); then
		echo -e "${CYAN} = = > Percent Change:${NC} ${YELLOW}+${delta_percent}%${NC}"
	else
		echo -e "${CYAN} = = > Percent Change:${NC} ${YELLOW}${delta_percent}%${NC}"
	fi

	case "$bucket" in
		GROWTH_WARN)
			echo -e "${bucket_color} = = > Sanity Band Result:${NC} ${bucket_color}GROWTH WARN${NC}"
			echo -e "${YE} = = > This REKEY Grew Beyond The Current Warning Band.${NC}"
			;;
		SHRINK_WARN)
			echo -e "${bucket_color} = = > Sanity Band Result:${NC} ${bucket_color}SHRINK WARN${NC}"
			echo -e "${YE} = = > This REKEY Shrunk Beyond The Current Warning Band.${NC}"
			;;
		OK)
			echo -e "${bucket_color} = = > Sanity Band Result:${NC} ${bucket_color}WITHIN EXPECTED RANGE${NC}"
			;;
		*)
			echo -e "${bucket_color} = = > Sanity Band Result:${NC} ${bucket_color}UNKNOWN${NC}"
			;;
	esac
	echo
}

# =========================
# #MARKER: REKEY ROLLING WINNER SELECTOR
# =========================
# PURPOSE:
# - Decide Which Rolling REKEY Attempt Wins
#
# INPUT:
# - $1 = bucket1
# - $2 = delta1
# - $3 = size1
# - $4 = bucket2
# - $5 = delta2
# - $6 = size2
#
# OUTPUT:
# - Prints 1 Or 2
# =========================
rekey_choose_rolling_winner() {
	local bucket1="$1"
	local delta1="$2"
	local size1="$3"
	local bucket2="$4"
	local delta2="$5"
	local size2="$6"

	# Clean landing beats warned result
	if [[ "$bucket2" == "OK" && "$bucket1" != "OK" ]]; then
		printf '2\n'
		return 0
	fi

	if [[ "$bucket1" == "OK" && "$bucket2" != "OK" ]]; then
		printf '1\n'
		return 0
	fi

	# Both too big -> choose smaller file / less growth
	if [[ "$bucket1" == "GROWTH_WARN" && "$bucket2" == "GROWTH_WARN" ]]; then
		if (( size2 < size1 )); then
			printf '2\n'
		else
			printf '1\n'
		fi
		return 0
	fi

	# Both too small -> choose larger file / less shrink
	if [[ "$bucket1" == "SHRINK_WARN" && "$bucket2" == "SHRINK_WARN" ]]; then
		if (( size2 > size1 )); then
			printf '2\n'
		else
			printf '1\n'
		fi
		return 0
	fi

	# Mixed warning fallback -> choose smaller absolute drift
	if (( ${delta2#-} < ${delta1#-} )); then
		printf '2\n'
	else
		printf '1\n'
	fi
}

# =========================
# #MARKER: REKEY ROLLING CRF ENGINE
# =========================
# PURPOSE:
# - Replace First-File Calibration With Per-File Rolling Calibration
#
# DESIGN RULES:
# - Each file starts from the last known good CRF
# - No blocking prompts
# - Up to 2 total tries per file
# - No reverse-direction ping-pong
# - Safety bias: prefer the larger candidate if neither lands cleanly
#
# OUTPUT:
# - Prints: chosen_crf|chosen_output|chosen_bucket|chosen_delta|orig_size|new_size
# - Returns 0 on success
# - Returns 1 on failure
# =========================
rekey_process_with_rolling_crf() {
	local src="$1"
	local starting_crf="$2"

	local orig_size
	local try1_crf try2_crf
	local out1 out2
	local delta1 delta2
	local bucket1 bucket2
	local new_size1 new_size2

	orig_size="$(stat -c '%s' -- "$src" 2>/dev/null || printf '0\n')"
	if [[ ! "$orig_size" =~ ^[0-9]+$ ]] || (( orig_size <= 0 )); then
		return 1
	fi

	try1_crf="$starting_crf"
	out1="REKEY_$(basename "${src%.*}").mkv"

	rm -f -- "$out1"
	if ! normalize_cut_friendly_file "$src" "$try1_crf"; then
		rm -f -- "$out1"
		return 1
	fi

	new_size1="$(stat -c '%s' -- "$out1" 2>/dev/null || printf '0\n')"
	delta1="$(rekey_percent_change "$orig_size" "$new_size1")"
	bucket1="$(rekey_size_sanity_bucket "$delta1" "$TARGET_MAX_GROWTH" "$TARGET_MAX_SHRINK")"

	if [[ "$bucket1" == "OK" ]]; then
		printf '%s|%s|%s|%s|%s|%s\n' \
			"$try1_crf" "$out1" "$bucket1" "$delta1" "$orig_size" "$new_size1"
		return 0
	fi

	try2_crf="$(rekey_auto_step_crf "$try1_crf" "$bucket1")"

	# No second try possible -> keep first result
	if [[ "$try2_crf" == "$try1_crf" ]]; then
		printf '%s|%s|%s|%s|%s|%s\n' \
			"$try1_crf" "$out1" "$bucket1" "$delta1" "$orig_size" "$new_size1"
		return 0
	fi

	out2="${out1%.mkv}.try2.mkv"
	rm -f -- "$out2"

	if ! normalize_cut_friendly_file "$src" "$try2_crf" "$out2"; then
		rm -f -- "$out2"
		printf '%s|%s|%s|%s|%s|%s\n' \
			"$try1_crf" "$out1" "$bucket1" "$delta1" "$orig_size" "$new_size1"
		return 0
	fi

	new_size2="$(stat -c '%s' -- "$out2" 2>/dev/null || printf '0\n')"
	delta2="$(rekey_percent_change "$orig_size" "$new_size2")"
	bucket2="$(rekey_size_sanity_bucket "$delta2" "$TARGET_MAX_GROWTH" "$TARGET_MAX_SHRINK")"

	local winner

	winner="$(rekey_choose_rolling_winner \
		"$bucket1" "$delta1" "$new_size1" \
		"$bucket2" "$delta2" "$new_size2")"

	if [[ "$winner" == "2" ]]; then
		rm -f -- "$out1"
		mv -f -- "$out2" "$out1"
		printf '%s|%s|%s|%s|%s|%s\n' \
			"$try2_crf" "$out1" "$bucket2" "$delta2" "$orig_size" "$new_size2"
		return 0
	fi

	rm -f -- "$out2"
	printf '%s|%s|%s|%s|%s|%s\n' \
		"$try1_crf" "$out1" "$bucket1" "$delta1" "$orig_size" "$new_size1"
	return 0
}

# =========================
# #MARKER: REKEY BATCH MODE SELECTOR
# =========================
# PURPOSE:
# - Let Batch Normalizer Run In One Of Two Honest Modes:
#     1) Adaptive Mode   -> sequential rolling evaluation
#     2) Throughput Mode -> concurrency presets
#
# DESIGN INTENT:
# - Adaptive Mode is for "learn as you go" behavior.
# - Throughput Mode is for "go fast with a fixed batch CRF" behavior.
# - Do NOT mix cross-file rolling CRF with concurrent execution.
#
# OUTPUT:
# - Prints ADAPTIVE or THROUGHPUT
# - Returns 0 on a real selection
# - Returns 1 on cancel / return
# =========================
rekey_choose_batch_execution_mode() {
	local mode_choice

	clear >&2
	echo -e "${CYAN}==========================================================${NC}" >&2
	echo -e "${CYAN}            REKEY BATCH EXECUTION MODE SELECT              ${NC}" >&2
	echo -e "${CYAN}==========================================================${NC}" >&2
	echo >&2
	echo -e "${CYAN}     1) Adaptive Mode   (Rolling Evaluation / Sequential)${NC}" >&2
	echo -e "${YELLOW}     2) Throughput Mode (Concurrency Presets)${NC}" >&2
	echo >&2
	echo -e "${YELLOW}     0.) Return${NC}" >&2
	echo >&2
	echo -e "${CYAN} = = > Adaptive:${NC} ${YELLOW}Each Finished File Can Influence The Next CRF.${NC}" >&2
	echo -e "${CYAN} = = > Throughput:${NC} ${YELLOW}Fixed Batch CRF, Faster Parallel Processing.${NC}" >&2
	echo >&2

	echo -ne "${YELLOW} = = > Choose Execution Mode [1-2 | 0.=return]: ${NC}${GREEN}" >&2
	read -r mode_choice # < dont change this one
    echo -e "${NC}" >&2

	if is_exit_token "$mode_choice"; then
		return 1
	fi

	case "$mode_choice" in
		1)
			printf '%s\n' "ADAPTIVE"
			return 0
			;;
		2)
			printf '%s\n' "THROUGHPUT"
			return 0
			;;
		*)
			echo -e "${REB} = = > Invalid Execution Mode.${NC}" >&2
			return 1
			;;
	esac
}

# =========================
# #MARKER: REKEY THROUGHPUT LOAD PRESET SELECTOR
# =========================
# PURPOSE:
# - Restore The Old Light / Medium / Thrash Intent
# - But ONLY For Throughput Mode Where Concurrency Actually Makes Sense
#
# OUTPUT:
# - Prints max_jobs as an integer
# - Returns 0 on success
# - Returns 1 on cancel / return
#
# RULE:
# - Light  = 1
# - Medium = 3
# - Thrash = user-chosen positive integer
# =========================
rekey_choose_throughput_job_count() {
	local load_choice
	local custom_jobs
	local cpu_count

	cpu_count="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1\n')"
	[[ -n "$cpu_count" ]] || cpu_count=1
	(( cpu_count < 1 )) && cpu_count=1

	echo >&2
	echo -e "${CYAN}==========================================================${NC}" >&2
	echo -e "${CYAN}          THROUGHPUT MODE :: CONCURRENCY PRESETS           ${NC}" >&2
	echo -e "${CYAN}==========================================================${NC}" >&2
	echo >&2
	echo -e "${YELLOW}     1) Light   (1 Job)${NC}" >&2
	echo -e "${YELLOW}     2) Medium  (3 Jobs)${NC}" >&2
	echo -e "${YELLOW}     3) Thrash  (Max Parallel / Custom)${NC}" >&2
	echo >&2
	echo -e "${YELLOW}     0.) Return${NC}" >&2
	echo >&2
	echo -e "${CYAN} = = > Host CPU Threads Seen:${NC} ${GREEN}$cpu_count${NC}" >&2
	echo >&2

	echo -ne "${YELLOW} = = > Choose Load [1-3 | 0.=return]: ${NC}${GREEN}" >&2
	read -r load_choice
	echo -e "${NC}" >&2

	load_choice="${load_choice//[[:space:]]/}"
	load_choice="${load_choice,,}"

	if is_exit_token "$load_choice"; then
		return 1
	fi

	case "$load_choice" in
		1)
			printf '%s\n' "1"
			return 0
			;;
		2)
			printf '%s\n' "3"
			return 0
			;;
		3)
			echo -ne "${YELLOW} = = > Enter Max Parallel Jobs [Default ${cpu_count}]: ${NC}${GREEN}" >&2
			read -r custom_jobs
			echo -e "${NC}" >&2

			custom_jobs="${custom_jobs:-$cpu_count}"
			custom_jobs="${custom_jobs//[[:space:]]/}"

			if [[ ! "$custom_jobs" =~ ^[0-9]+$ ]] || (( custom_jobs < 1 )); then
				echo -e "${REB} = = > Invalid Job Count.${NC}" >&2
				return 1
			fi

			printf '%s\n' "$custom_jobs"
			return 0
			;;
		*)
			echo -e "${REB} = = > Invalid Load Selection.${NC}" >&2
			return 1
			;;
	esac
}

# =========================
# #MARKER: REKEY ADAPTIVE MODE RUNNER
# =========================
# PURPOSE:
# - Hold The Current Rolling-CRF Sequential Behavior In One Honest Helper
#
# DESIGN:
# - Start From REKEY_CRF
# - Process Files In Order
# - Let Each Winning File Adjust The Next Starting CRF
# - Keep Existing Skip / Report / Summary Behavior
#
# INPUT:
# - One Or More Source Files As Positional Arguments
#
# RETURNS:
# - 0 after summary / registration pass
# =========================
run_batch_normalizer_adaptive() {
	local -a norm_sources=("$@")
	local total idx f
	local success_count=0
	local fail_count=0
	local skip_count=0
	local rolling_crf
	local result
	local chosen_crf chosen_out chosen_bucket chosen_delta
	local chosen_orig_size chosen_new_size

	total="${#norm_sources[@]}"
	rolling_crf="$REKEY_CRF"

	echo
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN}        ADAPTIVE MODE :: ROLLING EVALUATION ACTIVE        ${NC}"
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN} = = > Mode:${NC} Sequential"
	echo -e "${CYAN} = = > Starting CRF:${NC} ${YELLOW}$rolling_crf${NC}"
	echo -e "${CYAN} = = > Files In Scope:${NC} ${YELLOW}$total${NC}"
	echo -e "${CYAN} = = > Cross-File Learning:${NC} ${GREEN}Enabled${NC}"
	echo

	for ((idx=0; idx<total; idx++)); do
		f="${norm_sources[$idx]}"

		echo -e "${CYAN}==========================================================${NC}"
		echo -e "${CYAN} = = > File $((idx+1)) Of $total${NC}"
		echo -e "${CYAN} = = > Source:${NC} ${GREEN}$f${NC}"
		echo -e "${CYAN} = = > Starting Rolling CRF:${NC} ${YELLOW}$rolling_crf${NC}"
		echo -e "${CYAN}==========================================================${NC}"

		if is_valid_video_file "REKEY_$(basename "${f%.*}").mkv"; then
			echo -e "${YELLOW} = = > Skip Existing Rebuilt File:${NC} ${GREEN}REKEY_$(basename "${f%.*}").mkv${NC}"
			echo
			((skip_count+=1)) || :
			continue
		fi

		if result="$(rekey_process_with_rolling_crf "$f" "$rolling_crf")"; then
			chosen_crf="${result%%|*}"
			result="${result#*|}"

			chosen_out="${result%%|*}"
			result="${result#*|}"

			chosen_bucket="${result%%|*}"
			result="${result#*|}"

			chosen_delta="${result%%|*}"
			result="${result#*|}"

			chosen_orig_size="${result%%|*}"
			chosen_new_size="${result##*|}"

			rekey_print_size_sanity_report \
				"$f" \
				"$chosen_out" \
				"$chosen_orig_size" \
				"$chosen_new_size" \
				"$chosen_delta" \
				"$chosen_bucket"

			echo -e "${GREEN} = = > Created:${NC} ${CYAN}$chosen_out${NC}"
			echo -e "${CYAN} = = > Winning CRF:${NC} ${YELLOW}$chosen_crf${NC}"

			rolling_crf="$chosen_crf"
			echo -e "${CYAN} = = > Rolling CRF Updated To:${NC} ${YELLOW}$rolling_crf${NC}"
			echo

			((success_count+=1)) || :
		else
			echo -e "${REB} = = > Failed:${NC} ${GREEN}$f${NC}"
			echo -e "${YELLOW} = = > Rolling CRF Unchanged:${NC} ${YELLOW}$rolling_crf${NC}"
			echo
			((fail_count+=1)) || :
		fi
	done

	echo
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${GREEN} = = > Adaptive Batch Normalization Pass Complete.${NC}"
	echo -e "${CYAN} = = > Successful New REKEY Files:${NC} $success_count"
	echo -e "${CYAN} = = > Skipped Existing REKEY Files:${NC} $skip_count"
	echo -e "${CYAN} = = > Failed Normalizations:${NC} $fail_count"
	echo -e "${CYAN} = = > Final Rolling CRF:${NC} ${YELLOW}$rolling_crf${NC}"
	echo -e "${CYAN} = = > Outputs:${NC} REKEY_*.mkv"
	echo -e "${CYAN}==========================================================${NC}"

	register_new_rekeys_after_batch_normalizer
	pause
	return 0
}

# =========================
# #MARKER: REKEY THROUGHPUT MODE WORKER
# =========================
# PURPOSE:
# - Normalize One File In Throughput Mode With A Fixed Batch CRF
# - Report Result Into A Small Temp Status File So The Parent Can Tally It
#
# INPUT:
# - $1 = source file
# - $2 = batch_rekey_crf
# - $3 = status_dir
# - $4 = slot_id
#
# STATUS FILE FORMAT:
# - status_dir/slot_id.status
# - OK|source|output
# - SKIP|source|output
# - FAIL|source|
# =========================
run_batch_normalizer_throughput_worker() {
	local src="$1"
	local batch_rekey_crf="$2"
	local status_dir="$3"
	local slot_id="$4"

	local out
	local status_file

	out="REKEY_$(basename "${src%.*}").mkv"
	status_file="${status_dir}/${slot_id}.status"

	if is_valid_video_file "$out"; then
		printf '%s|%s|%s\n' "SKIP" "$src" "$out" > "$status_file"
		return 0
	fi

	if normalize_cut_friendly_file "$src" "$batch_rekey_crf" "$out" "1"; then
		printf '%s|%s|%s\n' "OK" "$src" "$out" > "$status_file"
		return 0
	fi

	printf '%s|%s|\n' "FAIL" "$src" > "$status_file"
	return 1
}

# =========================
# #MARKER: REKEY THROUGHPUT MODE RUNNER
# =========================
# PURPOSE:
# - Restore Concurrency Presets For A Fast Fixed-CRF Batch Pass
#
# DESIGN RULES:
# - Every file starts from the SAME batch CRF
# - No cross-file rolling updates
# - Throughput is controlled by max_jobs
# - Parent tallies results after all workers finish
#
# INPUT:
# - $1 = max_jobs
# - remaining args = source files
#
# RETURNS:
# - 0 after summary / registration pass
# =========================
run_batch_normalizer_throughput() {
	local max_jobs="$1"
	shift
	local -a norm_sources=("$@")

	local total idx f
	local batch_rekey_crf="$REKEY_CRF"
	local success_count=0
	local fail_count=0
	local skip_count=0

	local status_dir
	local slot_id=0
	local running_jobs=0
	local running=0
	local status_file
	local line state src out

	# ========================================================
	# THROUGHPUT STATUS HEARTBEAT COUNTERS
	# --------------------------------------------------------
	# PURPOSE:
	# - Give Thrash / concurrent mode one calm parent-only sign of life
	# - Avoid spinner collisions and per-worker terminal fights
	#
	# NOTES:
	# - finished_count advances as child jobs complete
	# - fail_count still becomes authoritative during final status-file tally
	# - heartbeat is informational, not the final truth source
	# ========================================================
	local finished_count=0
	local last_status_ts=0
	local status_interval=2
	local now_ts
	local queued_count=0

	status_dir="$(mktemp -d)"

	total="${#norm_sources[@]}"

	echo
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN}        THROUGHPUT MODE :: FIXED-CRF CONCURRENCY          ${NC}"
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN} = = > Mode:${YELLOW} Parallel${NC}"
	echo -e "${CYAN} = = > Fixed Batch CRF:${NC} ${YELLOW}$batch_rekey_crf${NC}"
	echo -e "${CYAN} = = > Max Parallel Jobs:${NC} ${YELLOW}$max_jobs${NC}"
	echo -e "${CYAN} = = > Files In Scope:${NC} ${YELLOW}$total${NC}"
	echo -e "${CYAN} = = > Cross-File Learning:${NC} ${YELLOW}Disabled${NC}"
	echo

	for ((idx=0; idx<total; idx++)); do
		f="${norm_sources[$idx]}"
		slot_id=$((idx + 1))
		queued_count=$((idx + 1))

		echo -e "${CYAN} = = > Processing File $slot_id Of $total:${NC} ${GREEN}$f${NC}"

		run_batch_normalizer_throughput_worker "$f" "$batch_rekey_crf" "$status_dir" "$slot_id" &
		((running_jobs+=1)) || :

		# ====================================================
		# THROTTLE LOOP
		# ----------------------------------------------------
		# When we hit max_jobs, wait for at least one worker
		# to finish before queueing more. Parent prints a
		# periodic heartbeat only; workers stay quiet.
		# ====================================================
		running="$(jobs -pr | wc -l)"

		while (( running >= max_jobs )); do
			sleep 2

			running="$(jobs -pr | wc -l)"
			finished_count=$(( queued_count - running ))

			printf '\r\033[2K%b' "${YEB} = = > ${NC}${YELLOW} Max-Jobs Array Running...${NC} ${CYAN}${queued_count} queued | ${running} active | ${finished_count} finished${NC}"
		done
	done

	# ========================================================
	# FINAL DRAIN LOOP
	# --------------------------------------------------------
	# After queueing is done, keep waiting until all remaining
	# background workers finish. Parent heartbeat continues.
	# ========================================================
	while (( running_jobs > 0 )); do
		sleep 2

		running_jobs="$(jobs -pr | wc -l)"
		finished_count=$(( queued_count - running_jobs ))

		printf '\r\033[2K%b' "${YEB} = = >${NC}${REB} Thrash${NC}${YEB} Mode Running...${NC} ${CYAN}${queued_count} queued | ${running_jobs} active | ${finished_count} finished | ${fail_count} failed${NC}"
	done

	wait || :
	printf '\r\033[2K' >&2
	echo >&2

	for status_file in "$status_dir"/*.status; do
		[[ -f "$status_file" ]] || continue

		line="$(<"$status_file")"
		state="${line%%|*}"
		line="${line#*|}"

		src="${line%%|*}"
		out="${line#*|}"

		case "$state" in
			OK)
				echo -e "${GREEN} = = > Created:${NC} ${CYAN}$out${NC}"
				((success_count+=1)) || :
				;;
			SKIP)
				echo -e "${YELLOW} = = > Skip Existing Rebuilt File:${NC} ${GREEN}$out${NC}"
				((skip_count+=1)) || :
				;;
			FAIL)
				echo -e "${REB} = = > Failed:${NC} ${GREEN}$src${NC}"
				((fail_count+=1)) || :
				;;
			*)
				echo -e "${YE} = = > Unknown Worker Status:${NC} $status_file"
				((fail_count+=1)) || :
				;;
		esac
	done

	rm -rf -- "$status_dir"

	echo
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${GREEN} = = > Throughput Batch Normalization Pass Complete.${NC}"
	echo -e "${CYAN} = = > Successful New REKEY Files:${NC} $success_count"
	echo -e "${CYAN} = = > Skipped Existing REKEY Files:${NC} $skip_count"
	echo -e "${CYAN} = = > Failed Normalizations:${NC} $fail_count"
	echo -e "${CYAN} = = > Fixed Batch CRF Used:${NC} ${YELLOW}$batch_rekey_crf${NC}"
	echo -e "${CYAN} = = > Outputs:${NC} REKEY_*.mkv"
	echo -e "${CYAN}==========================================================${NC}"

	register_new_rekeys_after_batch_normalizer
	pause
	return 0
}

# ================================================================
# #MARKER: GENERIC MEDIA AUDIO HELPERS / AUDIO TRIAGE
# ================================================================
# PURPOSE:
# - Reusable audio-stream inspection and remux helpers.
# - Keep container surgery separate from waveform/audio-editor work.
# - Prefer stream copy; do not re-encode video.
# ================================================================

media_pick_video_file() {
	local -n _out_ref=$1
	local label="${2:-SELECT VIDEO FILE}"
	local -a files=()
	local choice

	shopt -s nullglob nocaseglob
	files=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv,lrv})
	shopt -u nullglob nocaseglob

	(( ${#files[@]} > 0 )) || {
		echo -e "${YE} = = > No Video Files Found.${NC}"
		return 1
	}

	mapfile -t files < <(printf '%s\n' "${files[@]}" | LC_ALL=C sort -fV)

	echo
	echo -e "${CYAN} = = > ${label}:${NC}"
	echo
	local i
	for ((i=0; i<${#files[@]}; i++)); do
		printf '  %3d) %s\n' "$((i+1))" "${files[i]}"
	done
	echo
	prompt_read " = = > Select File [number | 0.=cancel]: " choice
	choice="${choice//[[:space:]]/}"
	is_exit_token "$choice" && return 1
	[[ "$choice" =~ ^[0-9]+$ ]] || return 1
	(( choice >= 1 && choice <= ${#files[@]} )) || return 1
	_out_ref="${files[choice-1]}"
}

media_pick_audio_file() {
	local -n _out_ref=$1
	local label="${2:-SELECT AUDIO FILE}"
	local -a files=()
	local choice

	shopt -s nullglob nocaseglob
	files=(*.{wav,flac,mp3,aac,m4a,ac3,eac3,dts,opus,ogg,oga,mka,wma,aiff,aif,alac,thd})
	shopt -u nullglob nocaseglob

	(( ${#files[@]} > 0 )) || {
		echo -e "${YE} = = > No Standalone Audio Files Found.${NC}"
		return 1
	}

	mapfile -t files < <(printf '%s\n' "${files[@]}" | LC_ALL=C sort -fV)

	echo
	echo -e "${CYAN} = = > ${label}:${NC}"
	echo
	local i
	for ((i=0; i<${#files[@]}; i++)); do
		printf '  %3d) %s\n' "$((i+1))" "${files[i]}"
	done
	echo
	prompt_read " = = > Select Audio File [number | 0.=cancel]: " choice
	choice="${choice//[[:space:]]/}"
	is_exit_token "$choice" && return 1
	[[ "$choice" =~ ^[0-9]+$ ]] || return 1
	(( choice >= 1 && choice <= ${#files[@]} )) || return 1
	_out_ref="${files[choice-1]}"
}

media_audio_stream_count() {
	local file="$1"
	ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$file" 2>/dev/null | awk 'NF{c++} END{print c+0}'
}

media_show_audio_streams() {
	local file="$1"
	local count
	count="$(media_audio_stream_count "$file")"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}               AUDIO STREAM INSPECT             ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > File:${NC} ${GREEN}$file${NC}"
	echo -e "${CYAN} = = > Audio Tracks:${NC} ${YELLOW}$count${NC}"
	echo

	if (( count == 0 )); then
		echo -e "${YE} = = > No Audio Streams Found.${NC}"
		return 1
	fi

	ffprobe -v error -select_streams a \
		-show_entries stream=index,codec_name,channels,channel_layout,bit_rate:stream_tags=language,title:stream_disposition=default \
		-of compact=p=0:nk=0 "$file" 2>/dev/null | nl -w2 -s') '
	echo
}

media_choose_audio_track() {
	local file="$1"
	local -n _track_ref=$2
	local count choice
	count="$(media_audio_stream_count "$file")"
	(( count > 0 )) || return 1
	media_show_audio_streams "$file" || return 1
	prompt_read " = = > Select Audio Track [1-$count | 0.=cancel]: " choice
	choice="${choice//[[:space:]]/}"
	is_exit_token "$choice" && return 1
	[[ "$choice" =~ ^[0-9]+$ ]] || return 1
	(( choice >= 1 && choice <= count )) || return 1
	_track_ref=$((choice-1))
}

media_audio_extract_extension() {
	case "${1,,}" in
		aac) printf 'm4a\n' ;;
		ac3) printf 'ac3\n' ;;
		eac3) printf 'eac3\n' ;;
		dts) printf 'dts\n' ;;
		flac) printf 'flac\n' ;;
		mp3) printf 'mp3\n' ;;
		opus) printf 'opus\n' ;;
		vorbis) printf 'ogg\n' ;;
		pcm_*|adpcm_*) printf 'wav\n' ;;
		alac) printf 'm4a\n' ;;
		truehd) printf 'thd\n' ;;
		*) printf 'mka\n' ;;
	esac
}

run_media_audio_inspect() {
	local file
	media_pick_video_file file "AUDIO STREAM INSPECT" || return 0
	media_show_audio_streams "$file" || true
	pause
}

run_media_audio_extract() {
	local file mode track count i codec ext stem out
	media_pick_video_file file "EXTRACT AUDIO FROM VIDEO" || return 0
	count="$(media_audio_stream_count "$file")"
	(( count > 0 )) || { echo -e "${YE} = = > No Audio Streams Found.${NC}"; pause; return 0; }
	media_show_audio_streams "$file" || true

	echo -e "${YELLOW}     1) Extract One Track${NC}"
	echo -e "${YELLOW}     2) Extract All Tracks${NC}"
	echo -e "${YELLOW}     0.) Return${NC}"
	prompt_menu_choice " = = > Choose [1-2 | 0.=return]: " mode
	is_exit_token "$mode" && return 0

	stem="${file%.*}"
	case "$mode" in
		1)
			media_choose_audio_track "$file" track || return 0
			codec="$(ffprobe -v error -select_streams "a:$track" -show_entries stream=codec_name -of csv=p=0 "$file" 2>/dev/null | head -n1)"
			ext="$(media_audio_extract_extension "$codec")"
			out="${stem}.audio$((track+1)).${ext}"
			ffmpeg -hide_banner -loglevel error -y -i "$file" -map "0:a:$track" -vn -sn -dn -c:a copy "$out" && \
				echo -e "${GR} = = > Extracted:${NC} ${GREEN}$out${NC}" || \
				echo -e "${REB} = = > Audio Extraction Failed.${NC}"
			;;
		2)
			for ((i=0; i<count; i++)); do
				codec="$(ffprobe -v error -select_streams "a:$i" -show_entries stream=codec_name -of csv=p=0 "$file" 2>/dev/null | head -n1)"
				ext="$(media_audio_extract_extension "$codec")"
				out="${stem}.audio$((i+1)).${ext}"
				if ffmpeg -hide_banner -loglevel error -y -i "$file" -map "0:a:$i" -vn -sn -dn -c:a copy "$out"; then
					echo -e "${GR} = = > Extracted:${NC} ${GREEN}$out${NC}"
				else
					echo -e "${REB} = = > Failed:${NC} ${YELLOW}audio track $((i+1))${NC}"
				fi
			done
			;;
		*) echo -e "${REB} = = > Invalid Selection.${NC}" ;;
	esac
	pause
}

media_read_optional_offset() {
	local -n _offset_ref=$1
	local raw
	prompt_read " = = > Audio Offset Seconds (blank = 0; negative = earlier; positive = later): " raw
	raw="${raw//[[:space:]]/}"
	[[ -z "$raw" ]] && raw="0"
	if [[ ! "$raw" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
		echo -e "${REB} = = > Invalid Offset.${NC}"
		return 1
	fi
	_offset_ref="$raw"
}

run_media_audio_replace() {
	local video audio track offset out stem
	media_pick_video_file video "VIDEO WHOSE AUDIO WILL BE REPLACED" || return 0
	media_choose_audio_track "$video" track || return 0
	media_pick_audio_file audio "REPLACEMENT AUDIO FILE" || return 0
	media_read_optional_offset offset || { pause; return 0; }
	stem="${video%.*}"
	out="MEDIAEDIT_${stem}.mkv"

	echo
	echo -e "${CYAN} = = > Video:${NC} ${GREEN}$video${NC}"
	echo -e "${CYAN} = = > Replace Audio Track:${NC} ${YELLOW}$((track+1))${NC}"
	echo -e "${CYAN} = = > Replacement:${NC} ${GREEN}$audio${NC}"
	echo -e "${CYAN} = = > Offset:${NC} ${YELLOW}${offset}s${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	echo -e "${YE} = = > Video And Unchanged Streams Are Stream-Copied.${NC}"
	ask_yes_no " = = > Proceed? (y/n or 1/2): " || return 0

	if ffmpeg -hide_banner -loglevel error -y \
		-i "$video" -itsoffset "$offset" -i "$audio" \
		-map 0 -map "-0:a:$track" -map 1:a:0 \
		-map_metadata 0 -map_chapters 0 -c copy "$out"; then
		echo -e "${GR} = = > Audio Track Replaced:${NC} ${GREEN}$out${NC}"
	else
		rm -f -- "$out"
		echo -e "${REB} = = > Audio Replace Failed.${NC}"
	fi
	pause
}

run_media_audio_add() {
	local video audio offset lang title default_choice default_flag=0 out stem
	media_pick_video_file video "VIDEO TO RECEIVE AN AUDIO TRACK" || return 0
	media_pick_audio_file audio "AUDIO TRACK TO ADD" || return 0
	media_read_optional_offset offset || { pause; return 0; }
	prompt_read " = = > Language Code (blank = und): " lang
	lang="${lang//[[:space:]]/}"; [[ -z "$lang" ]] && lang="und"
	prompt_read " = = > Track Name / Title (blank = none): " title
	if ask_yes_no " = = > Make Added Track Default? (y/n or 1/2): "; then default_flag=1; fi
	stem="${video%.*}"
	out="MEDIAEDIT_${stem}.mkv"

	if ffmpeg -hide_banner -loglevel error -y \
		-i "$video" -itsoffset "$offset" -i "$audio" \
		-map 0 -map 1:a:0 -map_metadata 0 -map_chapters 0 -c copy \
		-metadata:s:a:"$(media_audio_stream_count "$video")" language="$lang" \
		-metadata:s:a:"$(media_audio_stream_count "$video")" title="$title" \
		-disposition:a:"$(media_audio_stream_count "$video")" "$([[ $default_flag == 1 ]] && printf default || printf 0)" \
		"$out"; then
		echo -e "${GR} = = > Audio Track Added:${NC} ${GREEN}$out${NC}"
	else
		rm -f -- "$out"
		echo -e "${REB} = = > Add Audio Track Failed.${NC}"
	fi
	pause
}

run_media_audio_remove() {
	local video raw out stem count token idx
	local -a maps=()
	local -A remove=()
	media_pick_video_file video "VIDEO TO REMOVE AUDIO TRACK(S) FROM" || return 0
	count="$(media_audio_stream_count "$video")"
	(( count > 0 )) || { echo -e "${YE} = = > No Audio Streams Found.${NC}"; pause; return 0; }
	media_show_audio_streams "$video" || true
	prompt_read " = = > Track Number(s) To Remove (example: 2 or 1,3 | 0.=cancel): " raw
	is_exit_token "$raw" && return 0
	local -a requested_tracks=()
	IFS=',' read -r -a requested_tracks <<< "$raw"
	for token in "${requested_tracks[@]}"; do
		token="${token//[[:space:]]/}"
		[[ "$token" =~ ^[0-9]+$ ]] || { echo -e "${REB} = = > Invalid Track List.${NC}"; pause; return 0; }
		(( token >= 1 && token <= count )) || { echo -e "${REB} = = > Track Out Of Range:${NC} $token"; pause; return 0; }
		remove[$((token-1))]=1
	done
	(( ${#remove[@]} < count )) || { echo -e "${REB} = = > Refusing To Remove Every Audio Track Here.${NC}"; pause; return 0; }

	stem="${video%.*}"
	out="MEDIAEDIT_${stem}.mkv"
	maps=(-map 0)
	for idx in "${!remove[@]}"; do maps+=(-map "-0:a:$idx"); done

	if ffmpeg -hide_banner -loglevel error -y -i "$video" "${maps[@]}" -map_metadata 0 -map_chapters 0 -c copy "$out"; then
		echo -e "${GR} = = > Audio Track(s) Removed:${NC} ${GREEN}$out${NC}"
	else
		rm -f -- "$out"
		echo -e "${REB} = = > Remove Audio Track Failed.${NC}"
	fi
	pause
}


# ================================================================
# #MARKER: AUDIO LEVEL / LOUDNESS NORMALIZATION
# ================================================================
# PURPOSE:
# - Normalize perceived loudness inside a video without re-encoding video.
# - Normalize standalone extracted audio directly.
# - Apply a known manual gain change in dB.
# - Analyze loudness / peak facts without changing the source.
#
# NORMALIZATION POLICY:
# - Two-pass EBU R128 loudnorm for accurate integrated loudness targeting.
# - General / speech preset: -16 LUFS, -1.5 dBTP, LRA 11.
# - Music preset:            -14 LUFS, -1.5 dBTP, LRA 11.
# - Video: selected audio track rebuilt to AAC 256k; video and other streams copy.
# - Standalone audio: practical same-family output codec when supported.
# ================================================================

audiolevel_safe_tag() {
	local value="$1"
	value="${value#-}"
	value="${value//./p}"
	printf '%s\n' "$value"
}

audiolevel_extract_json_value() {
	local key="$1"
	local file="$2"
	sed -nE 's/^[[:space:]]*"'"$key"'"[[:space:]]*:[[:space:]]*"?([^",]+)"?,?[[:space:]]*$/\1/p' "$file" | tail -n1
}

audiolevel_two_pass_filter() {
	local file="$1"
	local track="$2"
	local target_i="$3"
	local target_tp="${4:--1.5}"
	local target_lra="${5:-11}"
	local log_file
	local input_i input_tp input_lra input_thresh target_offset

	log_file="$(mktemp /tmp/factory_loudnorm.XXXXXX.log)" || return 1

	if ! ffmpeg -hide_banner -nostats -loglevel info -i "$file" \
		-map "0:a:$track" -vn -sn -dn \
		-af "loudnorm=I=${target_i}:TP=${target_tp}:LRA=${target_lra}:print_format=json" \
		-f null - > /dev/null 2>"$log_file"; then
		rm -f -- "$log_file"
		return 1
	fi

	input_i="$(audiolevel_extract_json_value input_i "$log_file")"
	input_tp="$(audiolevel_extract_json_value input_tp "$log_file")"
	input_lra="$(audiolevel_extract_json_value input_lra "$log_file")"
	input_thresh="$(audiolevel_extract_json_value input_thresh "$log_file")"
	target_offset="$(audiolevel_extract_json_value target_offset "$log_file")"
	rm -f -- "$log_file"

	if [[ -z "$input_i" || -z "$input_tp" || -z "$input_lra" || -z "$input_thresh" || -z "$target_offset" ]]; then
		return 1
	fi

	printf 'loudnorm=I=%s:TP=%s:LRA=%s:measured_I=%s:measured_TP=%s:measured_LRA=%s:measured_thresh=%s:offset=%s:linear=true:print_format=summary\n' \
		"$target_i" "$target_tp" "$target_lra" \
		"$input_i" "$input_tp" "$input_lra" "$input_thresh" "$target_offset"
}

audiolevel_standalone_codec_args() {
	local file="$1"
	local -n _ext_ref=$2
	local -n _codec_ref=$3
	local ext="${file##*.}"
	ext="${ext,,}"

	case "$ext" in
		flac)
			_ext_ref="flac"
			_codec_ref=(-c:a flac)
			;;
		wav|wave)
			_ext_ref="wav"
			_codec_ref=(-c:a pcm_s24le)
			;;
		mp3)
			_ext_ref="mp3"
			_codec_ref=(-c:a libmp3lame -b:a 256k)
			;;
		opus)
			_ext_ref="opus"
			_codec_ref=(-c:a libopus -b:a 192k)
			;;
		ogg|oga)
			_ext_ref="ogg"
			_codec_ref=(-c:a libvorbis -q:a 7)
			;;
		m4a|aac|alac)
			_ext_ref="m4a"
			_codec_ref=(-c:a aac -b:a 256k)
			;;
		ac3)
			_ext_ref="ac3"
			_codec_ref=(-c:a ac3 -b:a 448k)
			;;
		*)
			_ext_ref="flac"
			_codec_ref=(-c:a flac)
			;;
	esac
}

# Analysis results retained for the optional recommended-repair path.
AUDIOLEVEL_ANALYZED_I=""
AUDIOLEVEL_REPAIR_ADVISED=0

audiolevel_print_verdict() {
	local loud_log="$1"
	local peak_log="$2"
	local integrated true_peak lra max_volume
	local overall overall_color loudness loudness_color
	local headroom headroom_color dynamics dynamics_color
	local clipping clipping_color recommendation correction direction

	integrated="$(awk '/Input Integrated:/ {print $(NF-1); exit}' "$loud_log" 2>/dev/null)"
	true_peak="$(awk '/Input True Peak:/ {print $(NF-1); exit}' "$loud_log" 2>/dev/null)"
	lra="$(awk '/Input LRA:/ {print $(NF-1); exit}' "$loud_log" 2>/dev/null)"
	max_volume="$(awk '/mean_volume:|max_volume:/ {if ($0 ~ /max_volume:/) {print $(NF-1); exit}}' "$peak_log" 2>/dev/null)"

	[[ "$integrated" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || integrated=""
	[[ "$true_peak" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || true_peak=""
	[[ "$lra" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || lra=""
	[[ "$max_volume" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || max_volume=""

	# ----- LOUDNESS GRADE ----------------------------------------------------
	if [[ -z "$integrated" ]]; then
		loudness="UNKNOWN"
		loudness_color="$YE"
	elif awk -v v="$integrated" 'BEGIN {exit !(v > -10)}'; then
		loudness="VERY LOUD"
		loudness_color="$RE"
	elif awk -v v="$integrated" 'BEGIN {exit !(v > -14)}'; then
		loudness="LOUD"
		loudness_color="$YE"
	elif awk -v v="$integrated" 'BEGIN {exit !(v >= -18)}'; then
		loudness="GOOD"
		loudness_color="$GR"
	elif awk -v v="$integrated" 'BEGIN {exit !(v >= -22)}'; then
		loudness="QUIET"
		loudness_color="$YE"
	else
		loudness="VERY QUIET"
		loudness_color="$RE"
	fi

	# ----- HEADROOM / CLIPPING GRADE ----------------------------------------
	if [[ -n "$true_peak" ]] && awk -v v="$true_peak" 'BEGIN {exit !(v >= 0)}'; then
		headroom="NONE"
		headroom_color="$RE"
		clipping="HIGH"
		clipping_color="$RE"
	elif [[ -n "$max_volume" ]] && awk -v v="$max_volume" 'BEGIN {exit !(v >= 0)}'; then
		headroom="NONE"
		headroom_color="$RE"
		clipping="HIGH"
		clipping_color="$RE"
	elif [[ -n "$true_peak" ]] && awk -v v="$true_peak" 'BEGIN {exit !(v > -1.5)}'; then
		headroom="LOW"
		headroom_color="$YE"
		clipping="MODERATE"
		clipping_color="$YE"
	else
		headroom="GOOD"
		headroom_color="$GR"
		clipping="LOW"
		clipping_color="$GR"
	fi

	# ----- DYNAMICS GRADE ----------------------------------------------------
	if [[ -z "$lra" ]]; then
		dynamics="UNKNOWN"
		dynamics_color="$YE"
	elif awk -v v="$lra" 'BEGIN {exit !(v < 3)}'; then
		dynamics="COMPRESSED"
		dynamics_color="$YE"
	elif awk -v v="$lra" 'BEGIN {exit !(v <= 18)}'; then
		dynamics="GOOD"
		dynamics_color="$GR"
	else
		dynamics="VERY WIDE"
		dynamics_color="$YE"
	fi

	# ----- OVERALL VERDICT / RECOMMENDATION ---------------------------------
	if [[ "$clipping" == "HIGH" ]]; then
		overall="TOO HOT / CLIPPING RISK"
		overall_color="$RE"
	elif [[ "$loudness" == "VERY LOUD" || "$loudness" == "VERY QUIET" ]]; then
		overall="LEVEL NEEDS CORRECTION"
		overall_color="$RE"
	elif [[ "$clipping" == "MODERATE" || "$loudness" == "LOUD" || "$loudness" == "QUIET" ]]; then
		overall="USABLE — ADJUSTMENT ADVISED"
		overall_color="$YE"
	else
		overall="GOOD"
		overall_color="$GR"
	fi

	if [[ -n "$integrated" ]]; then
		correction="$(awk -v v="$integrated" 'BEGIN {printf "%.1f", -16-v}')"
		if awk -v v="$correction" 'BEGIN {exit !(v < -0.05)}'; then
			direction="Reduce By $(awk -v v="$correction" 'BEGIN {printf "%.1f", -v}') dB"
		elif awk -v v="$correction" 'BEGIN {exit !(v > 0.05)}'; then
			direction="Increase By ${correction} dB"
		else
			direction="No Meaningful Change Needed"
		fi
	else
		direction="Measurement Unavailable"
	fi

	if [[ "$overall_color" == "$GR" ]]; then
		recommendation="No correction needed."
		AUDIOLEVEL_REPAIR_ADVISED=0
	else
		recommendation="Target Depends On Content Type."
		AUDIOLEVEL_REPAIR_ADVISED=1
	fi
	AUDIOLEVEL_ANALYZED_I="$integrated"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              AUDIO HEALTH VERDICT              ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${BW} Overall:${NC}       ${overall_color}${overall}${NC}"
	echo -e "${BW} Loudness:${NC}      ${loudness_color}${loudness}${NC}"
	echo -e "${BW} Headroom:${NC}      ${headroom_color}${headroom}${NC}"
	echo -e "${BW} Dynamics:${NC}      ${dynamics_color}${dynamics}${NC}"
	echo -e "${BW} Clipping Risk:${NC} ${clipping_color}${clipping}${NC}"
	echo
	echo -e "${BW} Recommendation:${NC} ${overall_color}${recommendation}${NC}"
}

audiolevel_choose_recommended_target() {
	local -n _target_ref=$1
	local -n _label_ref=$2
	local choice custom correction direction

	_target_ref=""
	_label_ref=""

	if (( AUDIOLEVEL_REPAIR_ADVISED == 0 )); then
		echo
		echo -e "${GR} = = > No Repair Recommended.${NC}"
		return 1
	fi

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             FACTORY RECOMMENDATION             ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${YE} = = > A Loudness Correction Is Recommended.${NC}"
	echo
	echo -e "${YELLOW}     1) Perform Recommended Repair${NC}"
	echo -e "${YELLOW}     2) Return Without Repair${NC}"
	echo
	echo -e "${YELLOW}     0.) Cancel${NC}"
	echo
	prompt_menu_choice " = = > Choose [1-2 | 0.=cancel]: " choice
	[[ "$choice" == "1" ]] || return 1

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                  CONTENT TYPE                  ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) TV / Movies / Dialogue (-16 LUFS)${NC}"
	echo -e "${YELLOW}     2) Music (-14 LUFS)${NC}"
	echo -e "${YELLOW}     3) Manual Target${NC}"
	echo
	echo -e "${YELLOW}     0.) Cancel${NC}"
	echo
	prompt_menu_choice " = = > Choose [1-3 | 0.=cancel]: " choice
	case "$choice" in
		1) _target_ref="-16"; _label_ref="TV / Movies / Dialogue" ;;
		2) _target_ref="-14"; _label_ref="Music" ;;
		3)
			prompt_read " = = > Target LUFS (example: -15 | 0.=cancel): " custom
			custom="${custom//[[:space:]]/}"
			is_exit_token "$custom" && return 1
			[[ "$custom" =~ ^-[0-9]+([.][0-9]+)?$ ]] || {
				echo -e "${REB} = = > Invalid LUFS Target.${NC}"
				return 1
			}
			_target_ref="$custom"
			_label_ref="Custom Target"
			;;
		*) return 1 ;;
	esac

	if [[ -n "$AUDIOLEVEL_ANALYZED_I" ]]; then
		correction="$(awk -v target="$_target_ref" -v current="$AUDIOLEVEL_ANALYZED_I" 'BEGIN {printf "%.1f", target-current}')"
		if awk -v v="$correction" 'BEGIN {exit !(v < -0.05)}'; then
			direction="Reduce Approximately $(awk -v v="$correction" 'BEGIN {printf "%.1f", -v}') dB"
		elif awk -v v="$correction" 'BEGIN {exit !(v > 0.05)}'; then
			direction="Increase Approximately ${correction} dB"
		else
			direction="No Meaningful Level Change"
		fi
	else
		direction="Measurement Unavailable"
	fi

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                 READY TO REPAIR                ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${BW} Current Loudness:${NC} ${YELLOW}${AUDIOLEVEL_ANALYZED_I:-Unknown} LUFS${NC}"
	echo -e "${BW} Selected Target:${NC}  ${YELLOW}${_label_ref} (${_target_ref} LUFS)${NC}"
	echo -e "${BW} Estimated Change:${NC} ${YELLOW}${direction}${NC}"
	echo
	echo -e "${YELLOW}     1) Proceed${NC}"
	echo -e "${YELLOW}     2) Return Without Repair${NC}"
	echo
	echo -e "${YELLOW}     0.) Cancel${NC}"
	echo
	prompt_menu_choice " = = > Choose [1-2 | 0.=cancel]: " choice
	[[ "$choice" == "1" ]]
}

audiolevel_analyze_file() {
	local file="$1"
	local track="${2:-0}"
	local loud_log peak_log

	AUDIOLEVEL_ANALYZED_I=""
	AUDIOLEVEL_REPAIR_ADVISED=0

	loud_log="$(mktemp /tmp/factory_loudness.XXXXXX.log)" || return 1
	peak_log="$(mktemp /tmp/factory_peak.XXXXXX.log)" || { rm -f -- "$loud_log"; return 1; }

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              AUDIO LEVEL ANALYSIS              ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > File:${NC} ${GREEN}$file${NC}"
	echo -e "${CYAN} = = > Audio Track:${NC} ${YELLOW}$((track+1))${NC}"
	echo

	ffmpeg -hide_banner -nostats -loglevel info -i "$file" \
		-map "0:a:$track" -vn -sn -dn \
		-af "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=summary" \
		-f null - > /dev/null 2>"$loud_log" || true

	ffmpeg -hide_banner -nostats -loglevel info -i "$file" \
		-map "0:a:$track" -vn -sn -dn \
		-af volumedetect -f null - > /dev/null 2>"$peak_log" || true

	grep -E 'Input Integrated:|Input True Peak:|Input LRA:|Input Threshold:' "$loud_log" || \
		echo -e "${YE} = = > Loudness Measurement Was Not Available.${NC}"
	grep -E 'mean_volume:|max_volume:' "$peak_log" || \
		echo -e "${YE} = = > Peak Measurement Was Not Available.${NC}"

	audiolevel_print_verdict "$loud_log" "$peak_log"
	rm -f -- "$loud_log" "$peak_log"
}

audiolevel_build_video() {
	local video="$1"
	local track="$2"
	local filter="$3"
	local out="$4"
	local count i lang title default_disposition
	local -a cmd=()

	count="$(media_audio_stream_count "$video")"
	(( count > 0 && track >= 0 && track < count )) || return 1

	lang="$(ffprobe -v error -select_streams "a:$track" -show_entries stream_tags=language -of default=nw=1:nk=1 "$video" 2>/dev/null | head -n1)"
	title="$(ffprobe -v error -select_streams "a:$track" -show_entries stream_tags=title -of default=nw=1:nk=1 "$video" 2>/dev/null | head -n1)"
	default_disposition="$(ffprobe -v error -select_streams "a:$track" -show_entries stream_disposition=default -of default=nw=1:nk=1 "$video" 2>/dev/null | head -n1)"

	cmd=(ffmpeg -hide_banner -nostats -loglevel error -y -i "$video" \
		-filter_complex "[0:a:${track}]${filter}[leveled]" \
		-map "0:v?" )

	for ((i=0; i<count; i++)); do
		if (( i == track )); then
			cmd+=(-map "[leveled]")
		else
			cmd+=(-map "0:a:$i")
		fi
	done

	cmd+=(-map "0:s?" -map "0:t?" -map "0:d?" \
		-map_metadata 0 -map_chapters 0 \
		-c copy -c:a:"$track" aac -b:a:"$track" 256k)

	[[ -n "$lang" ]] && cmd+=(-metadata:s:a:"$track" language="$lang")
	[[ -n "$title" ]] && cmd+=(-metadata:s:a:"$track" title="$title")
	[[ "$default_disposition" == "1" ]] && cmd+=(-disposition:a:"$track" default)

	cmd+=("$out")
	"${cmd[@]}"
}

audiolevel_build_standalone() {
	local audio="$1"
	local filter="$2"
	local out="$3"
	shift 3
	local -a codec_args=("$@")

	ffmpeg -hide_banner -nostats -loglevel error -y \
		-i "$audio" -map 0:a:0 -map_metadata 0 \
		-af "$filter" "${codec_args[@]}" "$out"
}

run_audiolevel_video() {
	local video track mode target_i target_label filter gain tag clean out choice recommended_flow=0

	media_pick_video_file video "VIDEO WHOSE AUDIO LEVEL WILL CHANGE" || return 0
	case "$video" in
		AUDIOLEVEL_*|TIMEPRESS_*|AUDIOFIX_*|MEDIAEDIT_*)
			echo -e "${REB} = = > Refusing Generated Output As Source.${NC}"
			pause
			return 0
			;;
	esac
	media_choose_audio_track "$video" track || return 0

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          VIDEO AUDIO LEVEL OPERATION           ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Loudness Normalize — General / Speech (-16 LUFS)${NC}"
	echo -e "${YELLOW}     2) Loudness Normalize — Music (-14 LUFS)${NC}"
	echo -e "${YELLOW}     3) Manual Gain (+/- dB)${NC}"
	echo -e "${YELLOW}     4) Analyze / Recommended Repair${NC}"
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo
	prompt_menu_choice " = = > Choose [1-4 | 0.=return]: " mode
	is_exit_token "$mode" && return 0

	case "$mode" in
		1|2)
			[[ "$mode" == "1" ]] && target_i="-16" || target_i="-14"
			echo -e "${CYAN} = = > Measuring Full Track For Two-Pass Loudness Normalization...${NC}"
			filter="$(audiolevel_two_pass_filter "$video" "$track" "$target_i")" || {
				echo -e "${REB} = = > Loudness Measurement Failed.${NC}"
				pause
				return 0
			}
			tag="LUFS$(audiolevel_safe_tag "$target_i")"
			;;
		3)
			prompt_read " = = > Gain In dB (examples: -4, 2.5 | 0.=cancel): " gain
			gain="${gain//[[:space:]]/}"
			is_exit_token "$gain" && return 0
			[[ "$gain" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || {
				echo -e "${REB} = = > Invalid Gain Value.${NC}"
				pause
				return 0
			}
			filter="volume=${gain}dB"
			if [[ "$gain" == -* ]]; then
				tag="DOWN$(audiolevel_safe_tag "$gain")dB"
			else
				tag="UP$(audiolevel_safe_tag "$gain")dB"
			fi
			;;
		4)
			audiolevel_analyze_file "$video" "$track"
			if ! audiolevel_choose_recommended_target target_i target_label; then
				pause
				return 0
			fi
			echo -e "${CYAN} = = > Measuring Full Track For Two-Pass Loudness Normalization...${NC}"
			filter="$(audiolevel_two_pass_filter "$video" "$track" "$target_i")" || {
				echo -e "${REB} = = > Loudness Measurement Failed.${NC}"
				pause
				return 0
			}
			tag="LUFS$(audiolevel_safe_tag "$target_i")"
			recommended_flow=1
			;;
		*) echo -e "${REB} = = > Invalid Selection.${NC}"; pause; return 0 ;;
	esac

	clean="$(strip_workflow_prefixes "$(basename "$video")")"
	clean="${clean%.*}"
	out="AUDIOLEVEL_${tag}_${clean}.mkv"

	echo
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$video${NC}"
	echo -e "${CYAN} = = > Audio Track:${NC} ${YELLOW}$((track+1))${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	echo -e "${YE} = = > Video, Other Audio Tracks, Subtitles, And Attachments Are Stream-Copied.${NC}"
	echo -e "${YE} = = > Only The Selected Audio Track Is Rebuilt To AAC 256k.${NC}"
	(( recommended_flow == 1 )) || ask_yes_no " = = > Proceed? (y/n or 1/2): " || return 0

	rm -f -- "$out"
	if audiolevel_build_video "$video" "$track" "$filter" "$out" && [[ -s "$out" ]]; then
		echo -e "${GR} = = > AUDIO LEVEL OUTPUT CREATED:${NC} ${GREEN}$out${NC}"
		echo
		echo -e "${YELLOW}     1) Accept And Archive Original Video${NC}"
		echo -e "${YELLOW}     2) Delete AUDIOLEVEL Output And Keep Original${NC}"
		echo -e "${YELLOW}     3) Keep Both${NC}"
		echo
		echo -e "${YELLOW}     0.) Return / Do Nothing${NC}"
		prompt_menu_choice " = = > Choose Result [1-3 | 0.=return]: " choice
		case "$choice" in
			1) archive_rescued_source_file "$video" "OEM/AUDIO_LEVEL/$(date '+%Y-%m')" ;;
			2) rm -f -- "$out"; echo -e "${GR} = = > Output Deleted; Original Kept.${NC}" ;;
			3) echo -e "${YE} = = > Keeping Both Files.${NC}" ;;
			*) echo -e "${YE} = = > Nothing Changed.${NC}" ;;
		esac
	else
		rm -f -- "$out"
		echo -e "${REB} = = > Audio Level Operation Failed.${NC}"
	fi
	pause
}

run_audiolevel_standalone() {
	local audio mode target_i target_label filter gain tag stem ext out choice recommended_flow=0
	local -a codec_args=()

	media_pick_audio_file audio "STANDALONE AUDIO WHOSE LEVEL WILL CHANGE" || return 0
	case "$audio" in
		AUDIOLEVEL_*) echo -e "${REB} = = > Refusing Existing AUDIOLEVEL Output As Source.${NC}"; pause; return 0 ;;
	esac

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        STANDALONE AUDIO LEVEL OPERATION        ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Loudness Normalize — General / Speech (-16 LUFS)${NC}"
	echo -e "${YELLOW}     2) Loudness Normalize — Music (-14 LUFS)${NC}"
	echo -e "${YELLOW}     3) Manual Gain (+/- dB)${NC}"
	echo -e "${YELLOW}     4) Analyze / Recommended Repair${NC}"
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo
	prompt_menu_choice " = = > Choose [1-4 | 0.=return]: " mode
	is_exit_token "$mode" && return 0

	case "$mode" in
		1|2)
			[[ "$mode" == "1" ]] && target_i="-16" || target_i="-14"
			echo -e "${CYAN} = = > Measuring Full Track For Two-Pass Loudness Normalization...${NC}"
			filter="$(audiolevel_two_pass_filter "$audio" 0 "$target_i")" || {
				echo -e "${REB} = = > Loudness Measurement Failed.${NC}"
				pause
				return 0
			}
			tag="LUFS$(audiolevel_safe_tag "$target_i")"
			;;
		3)
			prompt_read " = = > Gain In dB (examples: -4, 2.5 | 0.=cancel): " gain
			gain="${gain//[[:space:]]/}"
			is_exit_token "$gain" && return 0
			[[ "$gain" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || {
				echo -e "${REB} = = > Invalid Gain Value.${NC}"
				pause
				return 0
			}
			filter="volume=${gain}dB"
			if [[ "$gain" == -* ]]; then
				tag="DOWN$(audiolevel_safe_tag "$gain")dB"
			else
				tag="UP$(audiolevel_safe_tag "$gain")dB"
			fi
			;;
		4)
			audiolevel_analyze_file "$audio" 0
			if ! audiolevel_choose_recommended_target target_i target_label; then
				pause
				return 0
			fi
			echo -e "${CYAN} = = > Measuring Full Track For Two-Pass Loudness Normalization...${NC}"
			filter="$(audiolevel_two_pass_filter "$audio" 0 "$target_i")" || {
				echo -e "${REB} = = > Loudness Measurement Failed.${NC}"
				pause
				return 0
			}
			tag="LUFS$(audiolevel_safe_tag "$target_i")"
			recommended_flow=1
			;;
		*) echo -e "${REB} = = > Invalid Selection.${NC}"; pause; return 0 ;;
	esac

	audiolevel_standalone_codec_args "$audio" ext codec_args
	stem="$(basename "${audio%.*}")"
	stem="${stem#AUDIOLEVEL_}"
	out="AUDIOLEVEL_${tag}_${stem}.${ext}"

	echo
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$audio${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	(( recommended_flow == 1 )) || ask_yes_no " = = > Proceed? (y/n or 1/2): " || return 0

	rm -f -- "$out"
	if audiolevel_build_standalone "$audio" "$filter" "$out" "${codec_args[@]}" && [[ -s "$out" ]]; then
		echo -e "${GR} = = > AUDIO LEVEL OUTPUT CREATED:${NC} ${GREEN}$out${NC}"
		echo -e "${YE} = = > Original Standalone Audio Remains In Place.${NC}"
	else
		rm -f -- "$out"
		echo -e "${REB} = = > Standalone Audio Level Operation Failed.${NC}"
	fi
	pause
}


# ================================================================
# PLAYLIST LOUDNESS GROUP ANALYSIS / APPROVED NORMALIZATION
# ================================================================

playlist_select_file() {
	local -n _playlist_ref=$1
	local title="${2:-PLAYLIST}"
	local -a files=()
	local file choice i

	while IFS= read -r -d '' file; do
		files+=("$file")
	done < <(find . -maxdepth 3 -type f \( -iname '*.m3u' -o -iname '*.m3u8' \) -print0 2>/dev/null | sort -z)

	(( ${#files[@]} > 0 )) || {
		echo -e "${YE} = = > No .m3u Or .m3u8 Playlist Found Within Three Levels.${NC}"
		pause
		return 1
	}

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                  ${title}${NC}"
	echo -e "${CYAN}================================================${NC}"
	for i in "${!files[@]}"; do
		printf ' %3d) %s\n' "$((i+1))" "${files[$i]}"
	done
	echo
	echo -e "${YELLOW}     0.) Cancel${NC}"
	echo
	prompt_menu_choice " = = > Choose Playlist [1-${#files[@]} | 0.=cancel]: " choice
	is_exit_token "$choice" && return 1
	[[ "$choice" =~ ^[0-9]+$ ]] || return 1
	(( choice >= 1 && choice <= ${#files[@]} )) || return 1
	_playlist_ref="${files[$((choice-1))]}"
}

playlist_media_kind() {
	local file="$1"
	local video_count audio_count
	video_count="$(ffprobe -v error -select_streams v -show_entries stream=index -of csv=p=0 "$file" 2>/dev/null | wc -l)"
	audio_count="$(ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$file" 2>/dev/null | wc -l)"
	if (( audio_count < 1 )); then
		printf '%s\n' 'UNSUPPORTED'
	elif (( video_count > 0 )); then
		printf '%s\n' 'VIDEO'
	else
		printf '%s\n' 'AUDIO'
	fi
}

playlist_loudness_measure() {
	local file="$1"
	local track="${2:-0}"
	local log_file integrated true_peak lra threshold
	log_file="$(mktemp /tmp/factory_playlist_loudness.XXXXXX.log)" || return 1

	ffmpeg -hide_banner -nostats -loglevel info -i "$file" \
		-map "0:a:$track" -vn -sn -dn \
		-af 'loudnorm=I=-16:TP=-1.5:LRA=11:print_format=summary' \
		-f null - > /dev/null 2>"$log_file" || true

	integrated="$(awk '/Input Integrated:/ {print $(NF-1); exit}' "$log_file")"
	true_peak="$(awk '/Input True Peak:/ {print $(NF-1); exit}' "$log_file")"
	lra="$(awk '/Input LRA:/ {print $(NF-1); exit}' "$log_file")"
	threshold="$(awk '/Input Threshold:/ {print $(NF-1); exit}' "$log_file")"
	rm -f -- "$log_file"

	[[ "$integrated" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || return 1
	[[ "$true_peak" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || true_peak=""
	[[ "$lra" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || lra=""
	[[ "$threshold" =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]] || threshold=""
	printf '%s|%s|%s|%s\n' "$integrated" "$true_peak" "$lra" "$threshold"
}

playlist_loudness_recommendation() {
	local integrated="$1"
	local true_peak="$2"
	local target="$3"
	local correction abs_correction verdict action
	correction="$(awk -v t="$target" -v i="$integrated" 'BEGIN {printf "%.1f", t-i}')"
	abs_correction="$(awk -v v="$correction" 'BEGIN {if (v<0) v=-v; printf "%.1f", v}')"

	if [[ -n "$true_peak" ]] && awk -v v="$true_peak" 'BEGIN {exit !(v >= 0)}'; then
		verdict='CLIPPING_RISK'
		action='NORMALIZE_RECOMMENDED'
	elif awk -v v="$abs_correction" 'BEGIN {exit !(v < 1.0)}'; then
		verdict='GOOD'
		action='NO_REPAIR'
	elif awk -v v="$abs_correction" 'BEGIN {exit !(v < 2.0)}'; then
		verdict='BORDERLINE'
		action='OPTIONAL'
	else
		verdict='LEVEL_MISMATCH'
		action='NORMALIZE_RECOMMENDED'
	fi
	printf '%s|%s|%s\n' "$correction" "$verdict" "$action"
}

playlist_loudness_write_summary() {
	local report_file="$1"
	local summary_file="$2"
	local total=0 resolved=0 missing=0 unsupported=0 measured=0 good=0 optional=0 recommended=0 clipping=0 failed=0
	local index entry path kind status integrated true_peak lra threshold target label correction verdict action approved result output notes

	while IFS='|' read -r index entry path kind status integrated true_peak lra threshold target label correction verdict action approved result output notes; do
		[[ "$index" == 'INDEX' ]] && continue
		[[ -z "$index" ]] && continue
		((total+=1)) || :
		case "$status" in
			READY) ((resolved+=1, measured+=1)) || : ;;
			MISSING) ((missing+=1)) || : ;;
			UNSUPPORTED|REMOTE) ((unsupported+=1)) || : ;;
			*) ((failed+=1)) || : ;;
		esac
		case "$action" in
			NO_REPAIR) ((good+=1)) || : ;;
			OPTIONAL) ((optional+=1)) || : ;;
			NORMALIZE_RECOMMENDED) ((recommended+=1)) || : ;;
		esac
		[[ "$verdict" == 'CLIPPING_RISK' ]] && ((clipping+=1)) || :
	done < "$report_file"

	{
		echo '================================================'
		echo '      PLAYLIST LOUDNESS GROUP SUMMARY'
		echo '================================================'
		echo "Generated: $(date)"
		echo
		echo "Playlist Entries:       $total"
		echo "Resolved / Measured:    $measured"
		echo "Missing:                $missing"
		echo "Remote / Unsupported:   $unsupported"
		echo "Measurement Failed:     $failed"
		echo
		echo "No Repair Needed:       $good"
		echo "Optional Adjustment:    $optional"
		echo "Repair Recommended:     $recommended"
		echo "Clipping Risk:          $clipping"
		echo
		echo "Detailed Report:"
		echo " $report_file"
	} > "$summary_file"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      PLAYLIST LOUDNESS GROUP SUMMARY           ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Playlist Entries:${NC}       ${YELLOW}$total${NC}"
	echo -e "${CYAN} = = > Resolved / Measured:${NC}    ${YELLOW}$measured${NC}"
	echo -e "${CYAN} = = > Missing:${NC}                ${YELLOW}$missing${NC}"
	echo -e "${CYAN} = = > Remote / Unsupported:${NC}   ${YELLOW}$unsupported${NC}"
	echo -e "${CYAN} = = > Measurement Failed:${NC}     ${YELLOW}$failed${NC}"
	echo
	echo -e "${GR} = = > No Repair Needed:${NC}       ${YELLOW}$good${NC}"
	echo -e "${YE} = = > Optional Adjustment:${NC}    ${YELLOW}$optional${NC}"
	echo -e "${RE} = = > Repair Recommended:${NC}     ${YELLOW}$recommended${NC}"
	echo -e "${RE} = = > Clipping Risk:${NC}          ${YELLOW}$clipping${NC}"
	echo
	echo -e "${CYAN} = = > Report:${NC} ${GREEN}$report_file${NC}"
	echo -e "${CYAN} = = > Summary:${NC} ${GREEN}$summary_file${NC}"
}

playlist_loudness_scan() {
	local playlist="$1"
	local target="$2"
	local target_label="$3"
	local run_dir="$4"
	local -n _report_ref=$5
	local report_file="$run_dir/playlist_loudness_report.csv"
	local summary_file="$run_dir/playlist_loudness_summary.txt"
	local line entry path kind metrics rec integrated true_peak lra threshold correction verdict action
	local index=0

	mkdir -p "$run_dir"
	printf '%s\n' 'INDEX|PLAYLIST_ENTRY|RESOLVED_PATH|MEDIA_KIND|STATUS|INTEGRATED_LUFS|TRUE_PEAK_DBTP|LRA_LU|THRESHOLD_LUFS|TARGET_LUFS|TARGET_LABEL|ESTIMATED_CHANGE_DB|VERDICT|RECOMMENDED_ACTION|APPROVED|RESULT|OUTPUT_PATH|NOTES' > "$report_file"

	PROGRESS_TOTAL_FILES="$(awk 'BEGIN{n=0} /^[[:space:]]*($|#)/{next} {n++} END{print n}' "$playlist")"
	PROGRESS_CURRENT_INDEX=0
	PROGRESS_DONE_COUNT=0
	PROGRESS_TOTAL_SECONDS=0

	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line%$'\r'}"
		[[ -z "$line" || "$line" == \#* ]] && continue
		((index+=1)) || :
		PROGRESS_CURRENT_INDEX="$index"
		entry="$line"

		if playlist_reference_is_remote "$entry"; then
			printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
				"$index" "$entry" '' '' 'REMOTE' '' '' '' '' "$target" "$target_label" '' '' 'SKIP' 'NO' 'NOT_RUN' '' 'remote reference' >> "$report_file"
			continue
		fi

		path="$(playlist_resolve_reference "$playlist" "$entry")"
		if [[ ! -f "$path" ]]; then
			printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
				"$index" "$entry" "$path" '' 'MISSING' '' '' '' '' "$target" "$target_label" '' '' 'SKIP' 'NO' 'NOT_RUN' '' 'file not found' >> "$report_file"
			continue
		fi

		kind="$(playlist_media_kind "$path")"
		if [[ "$kind" == 'UNSUPPORTED' ]]; then
			printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
				"$index" "$entry" "$path" "$kind" 'UNSUPPORTED' '' '' '' '' "$target" "$target_label" '' '' 'SKIP' 'NO' 'NOT_RUN' '' 'no audio stream' >> "$report_file"
			continue
		fi

		metrics="$(run_with_progress "Playlist Audio Scan [$index/$PROGRESS_TOTAL_FILES]: $(basename "$path")" playlist_loudness_measure "$path" 0)" || metrics=""
		if [[ -z "$metrics" ]]; then
			printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
				"$index" "$entry" "$path" "$kind" 'MEASURE_FAILED' '' '' '' '' "$target" "$target_label" '' '' 'SKIP' 'NO' 'NOT_RUN' '' 'measurement failed' >> "$report_file"
			continue
		fi
		IFS='|' read -r integrated true_peak lra threshold <<< "$metrics"
		rec="$(playlist_loudness_recommendation "$integrated" "$true_peak" "$target")"
		IFS='|' read -r correction verdict action <<< "$rec"
		printf '%s|%s|%s|%s|READY|%s|%s|%s|%s|%s|%s|%s|%s|%s|NO|NOT_RUN||\n' \
			"$index" "$entry" "$path" "$kind" "$integrated" "$true_peak" "$lra" "$threshold" "$target" "$target_label" "$correction" "$verdict" "$action" >> "$report_file"
	done < "$playlist"

	playlist_loudness_write_summary "$report_file" "$summary_file"
	_report_ref="$report_file"
}

playlist_loudness_output_path() {
	local source="$1"
	local kind="$2"
	local target="$3"
	local dir base stem ext tag
	dir="$(dirname "$source")"
	base="$(basename "$source")"
	tag="LUFS$(audiolevel_safe_tag "$target")"
	if [[ "$kind" == 'VIDEO' ]]; then
		stem="${base%.*}"
		stem="$(strip_workflow_prefixes "$stem")"
		printf '%s/AUDIOLEVEL_%s_%s.mkv\n' "$dir" "$tag" "$stem"
	else
		stem="${base%.*}"
		stem="${stem#AUDIOLEVEL_}"
		ext="${base##*.}"
		printf '%s/AUDIOLEVEL_%s_%s.%s\n' "$dir" "$tag" "$stem" "$ext"
	fi
}

playlist_loudness_execute() {
	local report_file="$1"
	local scope="$2"
	local exec_log="${report_file%.csv}_execute_log.csv"
	local index entry path kind status integrated true_peak lra threshold target label correction verdict action approved result output notes
	local filter out ext done_count=0 skipped=0 failed=0
	local -a codec_args=()

	printf '%s\n' 'INDEX|SOURCE|ACTION|TARGET_LUFS|STATUS|OUTPUT_PATH|NOTES' > "$exec_log"
	PROGRESS_TOTAL_FILES="$(awk -F'|' -v scope="$scope" 'NR>1 && $5=="READY" && ((scope=="ALL" && $14=="NORMALIZE_RECOMMENDED") || (scope=="CLIPPING" && $13=="CLIPPING_RISK")) {n++} END{print n+0}' "$report_file")"
	PROGRESS_CURRENT_INDEX=0
	PROGRESS_DONE_COUNT=0
	PROGRESS_TOTAL_SECONDS=0

	while IFS='|' read -r index entry path kind status integrated true_peak lra threshold target label correction verdict action approved result output notes; do
		[[ "$index" == 'INDEX' ]] && continue
		[[ "$status" == 'READY' ]] || continue
		if [[ "$scope" == 'ALL' ]]; then
			[[ "$action" == 'NORMALIZE_RECOMMENDED' ]] || continue
		else
			[[ "$verdict" == 'CLIPPING_RISK' ]] || continue
		fi
		((PROGRESS_CURRENT_INDEX+=1)) || :

		if [[ ! -f "$path" ]]; then
			printf '%s|%s|NORMALIZE|%s|SKIPPED_MISSING||source missing\n' "$index" "$path" "$target" >> "$exec_log"
			((skipped+=1)) || :
			continue
		fi

		filter="$(audiolevel_two_pass_filter "$path" 0 "$target")" || {
			printf '%s|%s|NORMALIZE|%s|FAILED_MEASURE||two-pass measurement failed\n' "$index" "$path" "$target" >> "$exec_log"
			((failed+=1)) || :
			continue
		}
		out="$(playlist_loudness_output_path "$path" "$kind" "$target")"
		if [[ -e "$out" ]]; then
			printf '%s|%s|NORMALIZE|%s|SKIPPED_OUTPUT_EXISTS|%s|output already exists\n' "$index" "$path" "$target" "$out" >> "$exec_log"
			((skipped+=1)) || :
			continue
		fi

		if [[ "$kind" == 'VIDEO' ]]; then
			if run_with_progress "Playlist Normalize [$PROGRESS_CURRENT_INDEX/$PROGRESS_TOTAL_FILES]: $(basename "$path")" audiolevel_build_video "$path" 0 "$filter" "$out" && [[ -s "$out" ]]; then
				printf '%s|%s|NORMALIZE|%s|CREATED|%s|video copied; audio track 1 rebuilt\n' "$index" "$path" "$target" "$out" >> "$exec_log"
				((done_count+=1)) || :
			else
				rm -f -- "$out"
				printf '%s|%s|NORMALIZE|%s|FAILED_BUILD|%s|build failed\n' "$index" "$path" "$target" "$out" >> "$exec_log"
				((failed+=1)) || :
			fi
		else
			codec_args=()
			audiolevel_standalone_codec_args "$path" ext codec_args
			# Rebuild the output suffix from the codec decision, not merely the source suffix.
			out="${out%.*}.${ext}"
			if run_with_progress "Playlist Normalize [$PROGRESS_CURRENT_INDEX/$PROGRESS_TOTAL_FILES]: $(basename "$path")" audiolevel_build_standalone "$path" "$filter" "$out" "${codec_args[@]}" && [[ -s "$out" ]]; then
				printf '%s|%s|NORMALIZE|%s|CREATED|%s|standalone audio rebuilt\n' "$index" "$path" "$target" "$out" >> "$exec_log"
				((done_count+=1)) || :
			else
				rm -f -- "$out"
				printf '%s|%s|NORMALIZE|%s|FAILED_BUILD|%s|build failed\n' "$index" "$path" "$target" "$out" >> "$exec_log"
				((failed+=1)) || :
			fi
		fi
	done < "$report_file"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}       PLAYLIST NORMALIZATION SUMMARY           ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${GR} = = > Outputs Created:${NC} ${YELLOW}$done_count${NC}"
	echo -e "${YE} = = > Skipped:${NC}         ${YELLOW}$skipped${NC}"
	echo -e "${RE} = = > Failed:${NC}          ${YELLOW}$failed${NC}"
	echo -e "${CYAN} = = > Execution Log:${NC} ${GREEN}$exec_log${NC}"
}

run_playlist_loudness_group() {
	local playlist content_choice target target_label run_dir report_file choice scope
	playlist_select_file playlist 'PLAYLIST AUDIO GROUP' || return 0

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             GROUP CONTENT TARGET               ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${YELLOW}     1) TV / Movies / Dialogue (-16 LUFS)${NC}"
	echo -e "${YELLOW}     2) Music (-14 LUFS)${NC}"
	echo -e "${YELLOW}     3) Podcast / Voice (-16 LUFS)${NC}"
	echo -e "${YELLOW}     4) Custom Target${NC}"
	echo
	echo -e "${YELLOW}     0.) Cancel${NC}"
	echo
	prompt_menu_choice " = = > Choose [1-4 | 0.=cancel]: " content_choice
	case "$content_choice" in
		1) target='-16'; target_label='TV / Movies / Dialogue' ;;
		2) target='-14'; target_label='Music' ;;
		3) target='-16'; target_label='Podcast / Voice' ;;
		4)
			prompt_read " = = > Target LUFS (example: -15 | 0.=cancel): " target
			target="${target//[[:space:]]/}"
			is_exit_token "$target" && return 0
			[[ "$target" =~ ^-[0-9]+([.][0-9]+)?$ ]] || { echo -e "${REB} = = > Invalid Target.${NC}"; pause; return 0; }
			target_label='Custom Target'
			;;
		*) return 0 ;;
	esac

	run_dir="./AUDIOLEVEL_PLAYLIST_REPORTS/$(date '+%Y-%m-%d_%H-%M-%S')_$(basename "${playlist%.*}")"
	playlist_loudness_scan "$playlist" "$target" "$target_label" "$run_dir" report_file
	[[ -f "$report_file" ]] || { echo -e "${REB} = = > Playlist Report Was Not Created.${NC}"; pause; return 0; }

	while true; do
		echo
		echo -e "${YELLOW}     1) Normalize All Recommended Files${NC}"
		echo -e "${YELLOW}     2) Normalize Clipping-Risk Files Only${NC}"
		echo -e "${YELLOW}     3) View Detailed CSV Report${NC}"
		echo -e "${YELLOW}     4) Save Report And Return${NC}"
		echo
		echo -e "${YELLOW}     0.) Cancel / Return${NC}"
		echo
		prompt_menu_choice " = = > Choose [1-4 | 0.=return]: " choice
		case "$choice" in
			1) scope='ALL' ;;
			2) scope='CLIPPING' ;;
			3) less "$report_file"; continue ;;
			4|0|q|Q) return 0 ;;
			*) echo -e "${REB} = = > Invalid Selection.${NC}"; continue ;;
		esac

		echo
		echo -e "${YE} = = > Sources Will Remain Untouched.${NC}"
		echo -e "${YE} = = > New AUDIOLEVEL_ Outputs Will Be Written Beside Their Sources.${NC}"
		if ask_yes_no ' = = > Execute Approved Playlist Normalization? (y/n or 1/2): '; then
			playlist_loudness_execute "$report_file" "$scope"
			pause
			return 0
		fi
	done
}

run_audiolevel_menu() {
	local choice
	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}          NORMALIZE / ADJUST AUDIO VOLUME       ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Normalize / Adjust Audio Inside Video${NC}"
		echo -e "${YELLOW}     2) Normalize / Adjust Standalone Audio File${NC}"
		echo -e "${YELLOW}     3) Playlist Group Analysis / Normalization${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo
		prompt_menu_choice " = = > Select Option [1-3 | 0.=return]: " choice
		is_exit_token "$choice" && return 0
		case "$choice" in
			1) run_audiolevel_video ;;
			2) run_audiolevel_standalone ;;
			3) run_playlist_loudness_group ;;
			*) echo -e "${REB} = = > Invalid Selection.${NC}"; pause ;;
		esac
	done
}

run_audio_triage_menu() {
	local choice
	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}              AUDIO / TIME TRIAGE CENTER        ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Audio Sync / Constant Offset Repair${NC}"
		echo -e "${YELLOW}     2) Time-Compress Video + Audio${NC}"
		echo -e "${YELLOW}     3) Match Video To Modified External Audio${NC}"
		echo -e "${YELLOW}     4) Normalize / Adjust Audio Volume${NC}"
		echo -e "${YELLOW}     5) Extract Audio Track(s)${NC}"
		echo -e "${YELLOW}     6) Replace Audio Track${NC}"
		echo -e "${YELLOW}     7) Add Audio Track${NC}"
		echo -e "${YELLOW}     8) Remove Audio Track(s)${NC}"
		echo -e "${YELLOW}     9) Inspect Audio Tracks${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo
		prompt_menu_choice " = = > Select Option [1-9 | 0.=return]: " choice
		is_exit_token "$choice" && return 0
		case "$choice" in
			1) run_audio_sync_rescue ;;
			2) run_timepress_video_audio ;;
			3) run_timepress_match_external_audio ;;
			4) run_audiolevel_menu ;;
			5) run_media_audio_extract ;;
			6) run_media_audio_replace ;;
			7) run_media_audio_add ;;
			8) run_media_audio_remove ;;
			9) run_media_audio_inspect ;;
			*) echo -e "${REB} = = > Invalid Selection.${NC}"; pause ;;
		esac
	done
}

# ================================================================
# #MARKER: AUDIO SYNC RESCUE
# ================================================================
run_audio_sync_rescue() {
	local offset direction mode
	local -a targets=()
	local -a full_targets=()
	local -a pilot_outputs=()
	local file out_file
	local rescued_run_dir
	local ff_offset
	local total current
	local choice

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             AUDIO SYNC RESCUE                  ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Constant Audio Offset Repair.${NC}"
	echo -e "${YELLOW} = = > Stream-Copy Remux Only (No Reencode).${NC}"
	echo -e "${YELLOW} = = > Pilot Mode Leaves Originals In Place For Review.${NC}"
	echo -e "${YELLOW} = = > Return / Cancel Token: 0.${NC}"
	echo

	shopt -s nullglob nocaseglob
	full_targets=(*.mkv)
	shopt -u nullglob nocaseglob

	if (( ${#full_targets[@]} == 0 )); then
		echo -e "${REB} = = > No MKV Targets Found.${NC}"
		echo
		return 0
	fi

	# ------------------------------------------------------------
	# FILTER GENERATED / INTERNAL FILES
	# ------------------------------------------------------------
	targets=()
	for file in "${full_targets[@]}"; do
		case "$file" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*|RESCUE_*|PILOT_RESCUE_*|AUDIOFIX_*|TIMEPRESS_*|AUDIOLEVEL_*|intro_template*|custom_cut*)
				continue
				;;
		esac
		targets+=("$file")
	done

	if (( ${#targets[@]} == 0 )); then
		echo -e "${REB} = = > No Eligible MKV Source Targets Found.${NC}"
		echo
		return 0
	fi

	echo -ne "${YELLOW} = = > Audio Offset Seconds (example: 0.5 | 0.=return): ${NC}${GREEN}"
	read -r offset
	echo -e "${NC}"

	offset="${offset//[[:space:]]/}"

	if is_exit_token "$offset" || [[ -z "$offset" ]]; then
		echo -e "${YE} = = > Audio Sync Rescue Cancelled.${NC}"
		return 0
	fi

	echo
	echo -e "${CYAN}     1) Audio Is Late / Behind Video${NC}"
	echo -e "${CYAN}     2) Audio Is Early / Ahead Of Video${NC}"
	echo -e "${YELLOW}     0.) Return${NC}"
	echo

	echo -ne "${YELLOW} = = > Choose Direction [1-2 | 0.=return]: ${NC}${GREEN}"
	read -r direction
	echo -e "${NC}"

	direction="${direction//[[:space:]]/}"

	if is_exit_token "$direction"; then
		echo -e "${YE} = = > Audio Sync Rescue Cancelled.${NC}"
		return 0
	fi

	case "$direction" in
		1) ff_offset="-$offset" ;;
		2) ff_offset="$offset" ;;
		*)
			echo -e "${REB} = = > Invalid Direction.${NC}"
			return 0
			;;
	esac

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          AUDIO SYNC RESCUE TARGET MODE          ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Pilot First File Only${NC}"
	echo -e "${YELLOW}     2) Pilot First 3 Files${NC}"
	echo -e "${YELLOW}     3) Full Batch${NC}"
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo

	prompt_menu_choice " = = > Choose Mode [1-3 | 0.=return]: " mode

	if is_exit_token "$mode"; then
		echo -e "${YE} = = > Audio Sync Rescue Cancelled.${NC}"
		return 0
	fi

	case "$mode" in
		1)
			targets=("${targets[@]:0:1}")
			;;
		2)
			targets=("${targets[@]:0:3}")
			;;
		3)
			:
			;;
		*)
			echo -e "${REB} = = > Invalid Mode.${NC}"
			return 0
			;;
	esac

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                PREVIEW PLAN                    ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	local f
	for f in "${targets[@]}"; do
		echo -e "${YELLOW}$f${NC}"
		echo -e "${CYAN}  -->${NC} ${GREEN}AUDIOFIX_$f${NC}"
	done

	echo
	echo -e "${CYAN} = = > Targets:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo -e "${CYAN} = = > Audio Offset:${NC} ${YELLOW}${ff_offset}${NC}"

	if [[ "$mode" == "1" || "$mode" == "2" ]]; then
		echo -e "${YE} = = > PILOT MODE:${NC} ${YELLOW}Originals Will Stay In Working Folder Until Accepted.${NC}"
	else
		echo -e "${YE} = = > FULL BATCH:${NC} ${YELLOW}Successful Originals Will Be Archived Immediately.${NC}"
	fi
	echo

	if ! ask_yes_no " = = > Proceed With Audio Rescue? (y/n or 1/2): "; then
		echo -e "${YE} = = > Audio Rescue Cancelled.${NC}"
		echo
		return 0
	fi

	rescued_run_dir="OEM/AUDIO_SYNC/$(date '+%Y-%m')"
	mkdir -p "$rescued_run_dir"

	total="${#targets[@]}"
	current=0

	for file in "${targets[@]}"; do
		((current+=1)) || :

		out_file="AUDIOFIX_$file"

		echo
		echo -e "${CYAN}[${current} / ${total}] TARGET:${NC} ${GREEN}$file${NC}"
		echo -e "${CYAN} = = > Output:${NC} ${YELLOW}$out_file${NC}"

		rm -f -- "$out_file"

		if ffmpeg \
			-hide_banner \
			-nostats \
			-loglevel error \
			-y \
			-itsoffset "$ff_offset" -i "$file" \
			-i "$file" \
			-map 1:v \
			-map 0:a \
			-map "1:s?" \
			-c copy \
			"$out_file"
		then
			pilot_outputs+=("$out_file")

			if [[ "$mode" == "3" ]]; then
				mv -- "$file" "$rescued_run_dir/"
				echo -e "${GR} = = > AUDIO SYNC RESCUE COMPLETE:${NC} ${GREEN}$out_file${NC}"
				echo -e "${CYAN} = = > OEM AUDIO_SYNC Archive:${NC} ${YELLOW}$rescued_run_dir${NC}"
			else
				echo -e "${GR} = = > PILOT AUDIOFIX CREATED:${NC} ${GREEN}$out_file${NC}"
				echo -e "${YE} = = > Original Kept For Review:${NC} ${YELLOW}$file${NC}"
			fi
		else
			echo -e "${REB} = = > AUDIO SYNC RESCUE FAILED:${NC} ${YELLOW}$file${NC}"
			rm -f -- "$out_file"
		fi
	done

	# ------------------------------------------------------------
	# PILOT REVIEW GATE
	# ------------------------------------------------------------
	if [[ "$mode" == "1" || "$mode" == "2" ]]; then
		if (( ${#pilot_outputs[@]} == 0 )); then
			echo
			echo -e "${REB} = = > No Pilot Outputs Were Created.${NC}"
			return 0
		fi

		while true; do
			echo
			echo -e "${CYAN}============================================================${NC}"
			echo -e "${ORANGE}              AUDIO SYNC PILOT REVIEW ${NC}"
			echo -e "${YEB}        GO CHECK THE AUDIOFIX FILE(S) RIGHT NOW! ${NC}"
			echo -e "${CYAN}============================================================${NC}"
			echo
			echo -e "${CYAN} = = > Offset Used:${NC} ${YELLOW}${ff_offset}${NC}"
			echo -e "${CYAN} = = > Pilot Output(s):${NC}"
			for out_file in "${pilot_outputs[@]}"; do
				echo -e "${GREEN}     $out_file${NC}"
			done
			echo
			echo -e "${YELLOW}     1) Accept Pilot And Archive Original(s)${NC}"
			echo -e "${YELLOW}     2) Delete AUDIOFIX Output(s), Keep Original(s), Return For Redo${NC}"
			echo -e "${YELLOW}     3) Keep Both For Manual Review${NC}"
			echo
			echo -e "${YELLOW}     0.) Return / Do Nothing${NC}"
			echo

			prompt_menu_choice " = = > Choose Pilot Result [1-3 | 0.=return]: " choice

			if is_exit_token "$choice"; then
				echo -e "${YE} = = > Audio Sync Pilot Review Skipped. Nothing Changed.${NC}"
				return 0
			fi

			case "$choice" in
				1)
					echo
					echo -e "${CYAN} = = > Accepting Audio Sync Pilot Result(s)...${NC}"
					for file in "${targets[@]}"; do
						if [[ -f "$file" ]]; then
							mv -- "$file" "$rescued_run_dir/"
							echo -e "${CYAN} = = > Archived Original:${NC} ${YELLOW}$file${NC}"
						fi
					done
					echo -e "${GR} = = > Audio Sync Pilot Accepted.${NC}"
					echo -e "${CYAN} = = > OEM AUDIO_SYNC Archive:${NC} ${YELLOW}$rescued_run_dir${NC}"
					return 0
					;;

				2)
					echo
					echo -e "${CYAN} = = > Deleting AudioFix Pilot Output(s)...${NC}"
					for out_file in "${pilot_outputs[@]}"; do
						if [[ -f "$out_file" ]]; then
							rm -f -- "$out_file"
							echo -e "${YE} = = > Deleted:${NC} ${YELLOW}$out_file${NC}"
						fi
					done
					echo -e "${GR} = = > Originals Remain In Working Folder For Redo.${NC}"
					return 0
					;;

				3)
					echo
					echo -e "${YE} = = > Keeping Both Original(s) And AUDIOFIX Output(s).${NC}"
					echo -e "${YE} = = > No Originals Archived.${NC}"
					return 0
					;;

				*)
					echo -e "${REB} = = > Invalid Selection.${NC}"
					;;
			esac
		done
	fi

	echo
	echo -e "${GR} = = > Audio Rescue Pass Complete.${NC}"
	echo
	return 0
}

# ================================================================
# #MARKER: TIMEPRESS / VIDEO + AUDIO TIME COMPRESSION
# ================================================================
# PURPOSE:
# - Speed video and audio together for time-compressed viewing.
# - Natural Voice mode preserves pitch with atempo.
# - Tape Speed mode raises pitch with speed using asetrate + aresample.
# - Match video duration exactly to a previously modified external audio file.
# - Keep pilot originals until review; archive accepted/full-batch originals monthly.
# ================================================================

media_duration_seconds() {
	local file="$1"
	ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$file" 2>/dev/null | head -n1
}

media_audio_sample_rate() {
	local file="$1"
	ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=nw=1:nk=1 "$file" 2>/dev/null | head -n1
}

timepress_percent_tag() {
	local percent="$1"
	awk -v p="$percent" 'BEGIN {
		printf "%.3f", p
	}' | sed -E 's/0+$//; s/\.$//; s/\./p/g'
}

timepress_collect_targets() {
	local -n _targets_ref=$1
	local f
	local -a all_files=()

	_targets_ref=()
	shopt -s nullglob nocaseglob
	all_files=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv,lrv})
	shopt -u nullglob nocaseglob

	for f in "${all_files[@]}"; do
		case "$f" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*|RESCUE_*|PILOT_RESCUE_*|AUDIOFIX_*|TIMEPRESS_*|AUDIOLEVEL_*|MEDIAEDIT_*|intro_template*|custom_cut*)
				continue
				;;
		esac
		_targets_ref+=("$f")
	done

	if (( ${#_targets_ref[@]} > 0 )); then
		mapfile -t _targets_ref < <(printf '%s\n' "${_targets_ref[@]}" | LC_ALL=C sort -fV)
	fi
}

timepress_choose_percent() {
	local -n _percent_ref=$1
	local choice raw

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              TIME COMPRESSION SPEED            ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) 105%${NC}"
	echo -e "${YELLOW}     2) 110%${NC}"
	echo -e "${YELLOW}     3) 111%${NC}"
	echo -e "${YELLOW}     4) 115%${NC}"
	echo -e "${YELLOW}     5) 125%${NC}"
	echo -e "${YELLOW}     6) 150%${NC}"
	echo -e "${YELLOW}     7) Custom Percent${NC}"
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo
	prompt_menu_choice " = = > Choose Speed [1-7 | 0.=return]: " choice
	is_exit_token "$choice" && return 1

	case "$choice" in
		1) _percent_ref="105" ;;
		2) _percent_ref="110" ;;
		3) _percent_ref="111" ;;
		4) _percent_ref="115" ;;
		5) _percent_ref="125" ;;
		6) _percent_ref="150" ;;
		7)
			prompt_read " = = > Custom Percent (example 108.5): " raw
			raw="${raw//[[:space:]]/}"
			[[ "$raw" =~ ^[0-9]+([.][0-9]+)?$ ]] || {
				echo -e "${REB} = = > Invalid Speed Percent.${NC}"
				return 1
			}
			if ! awk -v p="$raw" 'BEGIN { exit !(p >= 50 && p <= 400) }'; then
				echo -e "${REB} = = > Allowed Range Is 50% Through 400%.${NC}"
				return 1
			fi
			_percent_ref="$raw"
			;;
		*)
			echo -e "${REB} = = > Invalid Speed Selection.${NC}"
			return 1
			;;
	esac
}

timepress_choose_sound_mode() {
	local -n _mode_ref=$1
	local choice

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}               TIMEPRESS SOUND MODE             ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Natural Voice / Preserve Pitch${NC}"
	echo -e "${YELLOW}     2) Tape Speed / Raise Pitch With Speed${NC}"
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo
	prompt_menu_choice " = = > Choose Sound Mode [1-2 | 0.=return]: " choice
	is_exit_token "$choice" && return 1

	case "$choice" in
		1) _mode_ref="natural" ;;
		2) _mode_ref="tape" ;;
		*) echo -e "${REB} = = > Invalid Sound Mode.${NC}"; return 1 ;;
	esac
}

timepress_build_file() {
	local src="$1"
	local percent="$2"
	local sound_mode="$3"
	local out="$4"
	local factor sample_rate audio_filter

	factor="$(awk -v p="$percent" 'BEGIN { printf "%.10f", p / 100.0 }')"

	if (( $(media_audio_stream_count "$src") == 0 )); then
		ffmpeg -hide_banner -nostats -loglevel error -y \
			-i "$src" \
			-filter:v "setpts=PTS/${factor}" \
			-map 0:v:0 -map "0:s?" \
			-map_metadata 0 -map_chapters 0 \
			-c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p \
			-c:s copy \
			"$out"
		return $?
	fi

	case "$sound_mode" in
		natural)
			audio_filter="atempo=${factor}"
			;;
		tape)
			sample_rate="$(media_audio_sample_rate "$src")"
			[[ "$sample_rate" =~ ^[0-9]+$ ]] || sample_rate="48000"
			audio_filter="asetrate=${sample_rate}*${factor},aresample=${sample_rate}"
			;;
		*) return 1 ;;
	esac

	ffmpeg -hide_banner -nostats -loglevel error -y \
		-i "$src" \
		-filter_complex "[0:v:0]setpts=PTS/${factor}[v];[0:a:0]${audio_filter}[a]" \
		-map "[v]" -map "[a]" -map "0:s?" \
		-map_metadata 0 -map_chapters 0 \
		-c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p \
		-c:a aac -b:a 192k \
		-c:s copy \
		-disposition:a:0 default \
		-shortest \
		"$out"
}

timepress_review_pilot() {
	local archive_dir="$1"
	local label="$2"
	local -n _sources_ref=$3
	local -n _outputs_ref=$4
	local choice file out_file

	while true; do
		echo
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${ORANGE}                 TIMEPRESS PILOT REVIEW ${NC}"
		echo -e "${YEB}          GO CHECK THE OUTPUT FILE(S) RIGHT NOW! ${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo
		echo -e "${CYAN} = = > Mode:${NC} ${YELLOW}$label${NC}"
		echo -e "${CYAN} = = > Pilot Output(s):${NC}"
		for out_file in "${_outputs_ref[@]}"; do
			echo -e "${GREEN}     $out_file${NC}"
		done
		echo
		echo -e "${YELLOW}     1) Accept Pilot And Archive Original(s)${NC}"
		echo -e "${YELLOW}     2) Delete TIMEPRESS Output(s), Keep Original(s), Return For Redo${NC}"
		echo -e "${YELLOW}     3) Keep Both For Manual Review${NC}"
		echo
		echo -e "${YELLOW}     0.) Return / Do Nothing${NC}"
		echo
		prompt_menu_choice " = = > Choose Pilot Result [1-3 | 0.=return]: " choice

		if is_exit_token "$choice"; then
			echo -e "${YE} = = > TIMEPRESS Pilot Review Skipped. Nothing Changed.${NC}"
			return 0
		fi

		case "$choice" in
			1)
				mkdir -p "$archive_dir"
				for file in "${_sources_ref[@]}"; do
					[[ -f "$file" ]] || continue
					archive_rescued_source_file "$file" "$archive_dir"
				done
				echo -e "${GR} = = > TIMEPRESS Pilot Accepted.${NC}"
				return 0
				;;
			2)
				for out_file in "${_outputs_ref[@]}"; do
					[[ -f "$out_file" ]] && rm -f -- "$out_file"
				done
				echo -e "${GR} = = > Originals Remain In Working Folder For Redo.${NC}"
				return 0
				;;
			3)
				echo -e "${YE} = = > Keeping Both Original(s) And TIMEPRESS Output(s).${NC}"
				return 0
				;;
			*) echo -e "${REB} = = > Invalid Selection.${NC}" ;;
		esac
	done
}

run_timepress_video_audio() {
	local percent sound_mode factor percent_tag mode choice file clean out_file
	local archive_dir total current
	local -a targets=()
	local -a selected=()
	local -a outputs=()

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          TIME-COMPRESS VIDEO + AUDIO           ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Speeds The Complete Program Up Or Down Together.${NC}"
	echo -e "${YELLOW} = = > Video Is Re-Encoded; First Audio Track Is Rebuilt.${NC}"
	echo -e "${YELLOW} = = > Subtitle Streams Are Copied When Compatible.${NC}"

	timepress_collect_targets targets
	(( ${#targets[@]} > 0 )) || { echo -e "${REB} = = > No Eligible Video Sources Found.${NC}"; pause; return 0; }
	timepress_choose_percent percent || return 0
	timepress_choose_sound_mode sound_mode || return 0
	factor="$(awk -v p="$percent" 'BEGIN { printf "%.6f", p / 100.0 }')"
	percent_tag="$(timepress_percent_tag "$percent")"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             TIMEPRESS TARGET MODE              ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Pick One File${NC}"
	echo -e "${YELLOW}     2) Pilot First File${NC}"
	echo -e "${YELLOW}     3) Pilot First 3 Files${NC}"
	echo -e "${YELLOW}     4) Full Batch${NC}"
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo
	prompt_menu_choice " = = > Choose Mode [1-4 | 0.=return]: " mode
	is_exit_token "$mode" && return 0

	case "$mode" in
		1)
			media_pick_video_file file "TIMEPRESS ONE FILE" || return 0
			case "$file" in TIMEPRESS_*|AUDIOLEVEL_*|AUDIOFIX_*|MEDIAEDIT_*) echo -e "${REB} = = > Refusing Generated Output As Source.${NC}"; pause; return 0 ;; esac
			selected=("$file")
			;;
		2) selected=("${targets[0]}") ;;
		3) selected=("${targets[@]:0:3}") ;;
		4) selected=("${targets[@]}") ;;
		*) echo -e "${REB} = = > Invalid Mode.${NC}"; pause; return 0 ;;
	esac

	echo
	echo -e "${CYAN} = = > Speed:${NC} ${YELLOW}${percent}% (${factor}x)${NC}"
	echo -e "${CYAN} = = > Sound:${NC} ${YELLOW}$sound_mode${NC}"
	echo -e "${CYAN} = = > Targets:${NC} ${YELLOW}${#selected[@]}${NC}"
	echo
	for file in "${selected[@]}"; do
		clean="$(strip_workflow_prefixes "$(basename "$file")")"
		clean="${clean%.*}"
		out_file="TIMEPRESS_${percent_tag}_${clean}.mkv"
		echo -e "${YELLOW}$file${NC}"
		echo -e "${CYAN}  -->${NC} ${GREEN}$out_file${NC}"
	done
	echo
	ask_yes_no " = = > Proceed With TIMEPRESS? (y/n or 1/2): " || return 0

	archive_dir="OEM/TIME_COMPRESSION/$(date '+%Y-%m')"
	total="${#selected[@]}"
	current=0

	for file in "${selected[@]}"; do
		((current+=1)) || :
		clean="$(strip_workflow_prefixes "$(basename "$file")")"
		clean="${clean%.*}"
		out_file="TIMEPRESS_${percent_tag}_${clean}.mkv"
		rm -f -- "$out_file"
		echo
		echo -e "${CYAN}[${current} / ${total}] TARGET:${NC} ${GREEN}$file${NC}"
		if timepress_build_file "$file" "$percent" "$sound_mode" "$out_file" && [[ -s "$out_file" ]]; then
			outputs+=("$out_file")
			echo -e "${GR} = = > TIMEPRESS COMPLETE:${NC} ${GREEN}$out_file${NC}"
			if [[ "$mode" == "4" ]]; then
				archive_rescued_source_file "$file" "$archive_dir"
			fi
		else
			rm -f -- "$out_file"
			echo -e "${REB} = = > TIMEPRESS FAILED:${NC} ${YELLOW}$file${NC}"
		fi
	done

	if [[ "$mode" != "4" && ${#outputs[@]} -gt 0 ]]; then
		timepress_review_pilot "$archive_dir" "${percent}% / ${sound_mode}" selected outputs
	fi

	echo
	echo -e "${GR} = = > TIMEPRESS Pass Complete.${NC}"
	pause
}

run_timepress_match_external_audio() {
	local video audio keep_choice sound_choice
	local video_duration audio_duration factor percent percent_tag clean out_file
	local original_audio_count audio_filter sample_rate
	local archive_dir choice

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      MATCH VIDEO TO MODIFIED EXTERNAL AUDIO    ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Reads Exact Durations And Calculates The Video Speed.${NC}"
	echo -e "${YELLOW} = = > External Audio Is Muxed Without Altering Its Timing.${NC}"
	echo

	media_pick_video_file video "ORIGINAL VIDEO" || return 0
	media_pick_audio_file audio "MODIFIED / TIME-COMPRESSED AUDIO" || return 0

	video_duration="$(media_duration_seconds "$video")"
	audio_duration="$(media_duration_seconds "$audio")"

	if [[ ! "$video_duration" =~ ^[0-9]+([.][0-9]+)?$ || ! "$audio_duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
		echo -e "${REB} = = > Could Not Read Both Durations.${NC}"
		pause
		return 0
	fi
	if ! awk -v d="$audio_duration" 'BEGIN { exit !(d > 0) }'; then
		echo -e "${REB} = = > External Audio Duration Is Invalid.${NC}"
		pause
		return 0
	fi

	factor="$(awk -v v="$video_duration" -v a="$audio_duration" 'BEGIN { printf "%.10f", v / a }')"
	percent="$(awk -v f="$factor" 'BEGIN { printf "%.3f", f * 100.0 }')"
	percent_tag="$(timepress_percent_tag "$percent")"
	clean="$(strip_workflow_prefixes "$(basename "$video")")"
	clean="${clean%.*}"
	out_file="TIMEPRESS_${percent_tag}_${clean}.mkv"
	original_audio_count="$(media_audio_stream_count "$video")"

	echo
	echo -e "${CYAN} = = > Video Duration:${NC} ${YELLOW}${video_duration}s${NC}"
	echo -e "${CYAN} = = > External Audio:${NC} ${YELLOW}${audio_duration}s${NC}"
	echo -e "${CYAN} = = > Required Video Speed:${NC} ${GR}${percent}% (${factor}x)${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out_file${NC}"
	echo
	echo -e "${YELLOW}     1) Replace Original Audio With External Audio${NC}"
	if (( original_audio_count > 0 )); then
		echo -e "${YELLOW}     2) Add External Audio + Keep A Time-Matched Original Track${NC}"
	fi
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo
	prompt_menu_choice " = = > Choose Audio Layout [1-2 | 0.=return]: " keep_choice
	is_exit_token "$keep_choice" && return 0
	[[ "$keep_choice" == "1" || ( "$keep_choice" == "2" && "$original_audio_count" -gt 0 ) ]] || {
		echo -e "${REB} = = > Invalid Audio Layout.${NC}"
		pause
		return 0
	}

	if [[ "$keep_choice" == "2" ]]; then
		timepress_choose_sound_mode sound_choice || return 0
		case "$sound_choice" in
			natural) audio_filter="atempo=${factor}" ;;
			tape)
				sample_rate="$(media_audio_sample_rate "$video")"
				[[ "$sample_rate" =~ ^[0-9]+$ ]] || sample_rate="48000"
				audio_filter="asetrate=${sample_rate}*${factor},aresample=${sample_rate}"
				;;
		esac
	fi

	ask_yes_no " = = > Build This Matched Video? (y/n or 1/2): " || return 0
	rm -f -- "$out_file"

	if [[ "$keep_choice" == "1" ]]; then
		if ffmpeg -hide_banner -nostats -loglevel error -y \
			-i "$video" -i "$audio" \
			-filter_complex "[0:v:0]setpts=PTS/${factor}[v]" \
			-map "[v]" -map 1:a:0 -map "0:s?" \
			-map_metadata 0 -map_chapters 0 \
			-c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p \
			-c:a copy -c:s copy \
			-disposition:a:0 default \
			-shortest \
			"$out_file" && [[ -s "$out_file" ]]; then
			:
		else
			rm -f -- "$out_file"
			echo -e "${REB} = = > External Audio Match Failed.${NC}"
			pause
			return 0
		fi
	else
		if ffmpeg -hide_banner -nostats -loglevel error -y \
			-i "$video" -i "$audio" \
			-filter_complex "[0:v:0]setpts=PTS/${factor}[v];[0:a:0]${audio_filter}[orig]" \
			-map "[v]" -map 1:a:0 -map "[orig]" -map "0:s?" \
			-map_metadata 0 -map_chapters 0 \
			-c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p \
			-c:a:0 copy -c:a:1 aac -b:a:1 192k -c:s copy \
			-metadata:s:a:0 title="Modified External Audio" \
			-metadata:s:a:1 title="Time-Matched Original Audio" \
			-disposition:a:0 default -disposition:a:1 0 \
			-shortest \
			"$out_file" && [[ -s "$out_file" ]]; then
			:
		else
			rm -f -- "$out_file"
			echo -e "${REB} = = > External Audio Match Failed.${NC}"
			pause
			return 0
		fi
	fi

	echo
	echo -e "${GR} = = > MATCHED TIMEPRESS CREATED:${NC} ${GREEN}$out_file${NC}"
	echo -e "${YE} = = > Original Video Remains In Working Folder Until Review.${NC}"
	echo
	echo -e "${YELLOW}     1) Accept And Archive Original Video${NC}"
	echo -e "${YELLOW}     2) Delete TIMEPRESS Output And Keep Original${NC}"
	echo -e "${YELLOW}     3) Keep Both${NC}"
	echo
	echo -e "${YELLOW}     0.) Return / Do Nothing${NC}"
	echo
	prompt_menu_choice " = = > Choose Result [1-3 | 0.=return]: " choice

	case "$choice" in
		1)
			archive_dir="OEM/TIME_COMPRESSION/$(date '+%Y-%m')"
			archive_rescued_source_file "$video" "$archive_dir"
			;;
		2)
			rm -f -- "$out_file"
			echo -e "${GR} = = > TIMEPRESS Output Deleted; Original Kept.${NC}"
			;;
		3) echo -e "${YE} = = > Keeping Both Files.${NC}" ;;
		*) echo -e "${YE} = = > Nothing Changed.${NC}" ;;
	esac
	pause
}


# =========================
# #MARKER: INFO CSV LEDGER / REKEY CACHE STATE
# =========================
# PURPOSE:
# - Hold Cheap Persistent State About Source Selection / Validation Work.
# - Prevent Re-Checking The Same REKEY Friendliness Over And Over.
# - Keep This Knowledge OUT Of The Filename Itself.
#
# WHY THIS EXISTS:
# - intro_map.csv Answers:
#     "Has Intro Mapping Already Been Written For This File?"
# - It Does NOT Answer:
#     "Have We Already Validated A Trusted Working Source For This Raw File?"
#
# CURRENT PAIN:
# - In The Detection Loop, normalize_to_mkv + get_preferred_source_file happen
#   BEFORE the already_processed() skip check.
# - That Means A File Can Still Pay The REKEY/Validation Tax Even When It Is
#   Going To Be Skipped As Already Mapped.
#
# DESIGN INTENT:
# - intro_map.csv stays the authority for "already mapped"
# - info.csv becomes the authority for "already validated / already has a
#   trusted working source"
#
#
# CSV SCHEMA:
# raw_name,working_name,auth_rekey,validated_once,keyframe_verdict,source_sig
#
# FIELD NOTES:
# - raw_name         = original file seen in scan
# - working_name     = file actually chosen for downstream work
# - auth_rekey       = 1 if working_name is a trusted REKEY for raw_name
# - validated_once   = 1 if cut-friendliness was already checked and recorded
# - keyframe_verdict = SAFE / CAUTION / RISKY / UNKNOWN
# - source_sig       = cheap invalidation signature (size + mtime)
#
ensure_info_map() {
    if [[ ! -f "$INFO_MAP" ]]; then
        printf '%s\n' "raw_name,working_name,auth_rekey,validated_once,keyframe_verdict,source_sig,keyframe_checked_path" > "$INFO_MAP"
    fi
}

# =========================
# #MARKER: CHEAP FILE SIGNATURE
# =========================
# PURPOSE:
# - Give The Ledger A Quick Way To Notice When A Source Changed.
# - We Do NOT Need A Heavy Hash Here.
# - Size + mtime Is Good Enough For This Workflow Cache.
#
# OUTPUT EXAMPLE:
# - 123456789:1711412345
#
make_source_sig() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        printf '%s\n' "MISSING"
        return 0
    fi

    stat -c '%s:%Y' -- "$file" 2>/dev/null || printf '%s\n' "UNKNOWN"
}

# =========================
# #MARKER: CSV ESCAPE HELPER
# =========================
# PURPOSE:
# - Keep Commas / Quotes In Filenames From Mangling The Ledger.
# - Factory Usually Has Simple Names, But Future-Me Does Weird Things.
#
csv_escape() {
    local s="$1"
    s="${s//\"/\"\"}"
    printf '"%s"' "$s"
}

pilot_cleanup_session_dir() {
	local session_dir="${1:-${PILOT_SESSION_DIR:-}}"

	[[ -n "$session_dir" ]] || return 0
	[[ -d "$session_dir" ]] || return 0

	case "$session_dir" in
		OEM/PILOT_SESSION_*|./OEM/PILOT_SESSION_*)
			rm -rf -- "$session_dir"
			echo -e "${CYAN} = = > Pilot Session Folder Removed:${NC} ${YELLOW}$session_dir${NC}"
			;;
		*)
			echo -e "${YE} = = > Pilot Session Cleanup Skipped, Unsafe Path:${NC} ${YELLOW}$session_dir${NC}"
			;;
	esac
}

pilot_delete_registered_outputs() {
	local history="${1:-pilot_history.csv}"
	local deleted_count=0
	local skipped_count=0
	local output_file

	[[ -f "$history" ]] || {
		echo -e "${YE} = = > Missing Pilot History:${NC} ${YELLOW}$history${NC}"
		return 0
	}

	while IFS= read -r output_file; do
		[[ -n "$output_file" ]] || continue

		if [[ -f "$output_file" ]]; then
			rm -f -- "$output_file"
			echo -e "${GR} = = > Deleted Current Pilot Output:${NC} ${YELLOW}$output_file${NC}"
			((deleted_count+=1)) || :
		else
			echo -e "${YE} = = > Pilot Output Already Missing / Skipped:${NC} ${YELLOW}$output_file${NC}"
			((skipped_count+=1)) || :
		fi
	done < <(
		awk -F',' '
			function unquote(s) {
				gsub(/^"/, "", s)
				gsub(/"$/, "", s)
				gsub(/""/, "\"", s)
				return s
			}

			{
				event=unquote($3)
				path=unquote($4)
				detail=unquote($5)

				if (event == "REGISTER_OUTPUT" && detail ~ /PILOT_OUTPUT|SMC_CSV_PILOT_OUTPUT/) {
					if (path != "" && !seen[path]++) {
						print path
					}
				}
			}
		' "$history"
	)

	echo
	echo -e "${CYAN} = = > Pilot Outputs Deleted:${NC} ${YELLOW}$deleted_count${NC}"
	echo -e "${CYAN} = = > Pilot Outputs Skipped:${NC} ${YELLOW}$skipped_count${NC}"
}

# ================================================================
# #MARKER: PILOT SESSION RESTORE LEDGER HELPERS
# ================================================================
# PURPOSE:
# - Give pilot runs a real undo / redo safety layer.
# - Keep Ctrl-C recovery deterministic and non-interactive.
# - Avoid making info.csv carry short-term transaction state.
#
# DESIGN:
# - pilot_restore.csv = active session restore map
# - pilot_outputs.csv = active session output cleanup list
# - pilot_temps.csv   = active session temp cleanup list
# - pilot_history.csv = permanent audit trail of pilot actions
#
# RULE:
# - Pilot recovery only touches files registered during this pilot session.
# - Full runs and normal OEM archives are not touched.
# ================================================================

PILOT_SESSION_DIR=""
PILOT_RESTORE_CSV=""
PILOT_OUTPUTS_CSV=""
PILOT_TEMPS_CSV=""
PILOT_CUTS_TXT=""
PILOT_HISTORY_CSV="${PILOT_HISTORY_CSV:-pilot_history.csv}"

pilot_is_active() {
	[[ "${PILOT_MODE:-0}" == "1" && -n "${PILOT_SESSION_DIR:-}" && -d "${PILOT_SESSION_DIR:-}" ]]
}

pilot_begin_session() {
	local label="${1:-PILOT}"
	local stamp safe_label

	[[ "${PILOT_MODE:-0}" == "1" ]] || return 0

	if [[ -n "${PILOT_SESSION_DIR:-}" && -d "$PILOT_SESSION_DIR" ]]; then
		return 0
	fi

	stamp="$(date '+%Y%m%d_%H%M%S')"
	safe_label="${label//[^A-Za-z0-9_]/_}"

	PILOT_SESSION_DIR="${OEM_ROOT:-OEM}/PILOT_SESSION_${stamp}_${safe_label}"
	PILOT_RESTORE_CSV="$PILOT_SESSION_DIR/pilot_restore.csv"
	PILOT_OUTPUTS_CSV="$PILOT_SESSION_DIR/pilot_outputs.csv"
	PILOT_TEMPS_CSV="$PILOT_SESSION_DIR/pilot_temps.csv"
	PILOT_CUTS_TXT="$PILOT_SESSION_DIR/pilot_cut_plans.txt"

	mkdir -p "$PILOT_SESSION_DIR/BACKUPS"

	printf '%s\n' "live_file,backup_path,reason,source_sig,registered_at" > "$PILOT_RESTORE_CSV"
	printf '%s\n' "output_file,profile,registered_at" > "$PILOT_OUTPUTS_CSV"
	printf '%s\n' "temp_file,reason,registered_at" > "$PILOT_TEMPS_CSV"
	printf '%s\n' "SMC PILOT CUT PLAN REVIEW" > "$PILOT_CUTS_TXT"

	if [[ ! -f "$PILOT_HISTORY_CSV" ]]; then
		printf '%s\n' "time,session,action,target,detail,status" > "$PILOT_HISTORY_CSV"
	fi

	echo -e "${CYAN} = = > Pilot Session Started:${NC} ${GREEN}$PILOT_SESSION_DIR${NC}"
}

pilot_history_log() {
	local action="${1:-UNKNOWN}"
	local target="${2:-}"
	local detail="${3:-}"
	local status="${4:-OK}"

	[[ -f "$PILOT_HISTORY_CSV" ]] || printf '%s\n' "time,session,action,target,detail,status" > "$PILOT_HISTORY_CSV"

	printf '%s,%s,%s,%s,%s,%s\n' \
		"$(csv_escape "$(date '+%Y-%m-%d_%H%M%S')")" \
		"$(csv_escape "${PILOT_SESSION_DIR:-NO_SESSION}")" \
		"$(csv_escape "$action")" \
		"$(csv_escape "$target")" \
		"$(csv_escape "$detail")" \
		"$(csv_escape "$status")" >> "$PILOT_HISTORY_CSV"
}

pilot_register_restore_point() {
	local live_file="$1"
	local reason="${2:-PILOT_RESTORE_POINT}"
	local base backup stem ext n source_sig

	pilot_is_active || return 0
	[[ -f "$live_file" ]] || return 0

	live_file="$(canonical_factory_path "$live_file")"

	if awk -F',' -v q="\"$live_file\"" 'NR>1 && $1==q { found=1 } END { exit found ? 0 : 1 }' "$PILOT_RESTORE_CSV"; then
		return 0
	fi

	base="$(basename "$live_file")"
	backup="$PILOT_SESSION_DIR/BACKUPS/$base"

	if [[ -e "$backup" ]]; then
		stem="${base%.*}"
		ext="${base##*.}"
		[[ "$stem" == "$ext" ]] && ext="" || ext=".$ext"

		n=1
		while [[ -e "$PILOT_SESSION_DIR/BACKUPS/${stem}_$n${ext}" ]]; do
			((n+=1)) || :
		done

		backup="$PILOT_SESSION_DIR/BACKUPS/${stem}_$n${ext}"
	fi

	cp -p -- "$live_file" "$backup"
	source_sig="$(make_source_sig "$live_file")"

	printf '%s,%s,%s,%s,%s\n' \
		"$(csv_escape "$live_file")" \
		"$(csv_escape "$backup")" \
		"$(csv_escape "$reason")" \
		"$(csv_escape "$source_sig")" \
		"$(csv_escape "$(date '+%Y-%m-%d_%H%M%S')")" >> "$PILOT_RESTORE_CSV"

	pilot_history_log "REGISTER_RESTORE" "$live_file" "$backup" "OK"
}

pilot_register_output() {
	local output_file="$1"
	local profile="${2:-PILOT_OUTPUT}"

	pilot_is_active || return 0
	[[ -n "$output_file" ]] || return 0

	output_file="$(canonical_factory_path "$output_file")"

	printf '%s,%s,%s\n' \
		"$(csv_escape "$output_file")" \
		"$(csv_escape "$profile")" \
		"$(csv_escape "$(date '+%Y-%m-%d_%H%M%S')")" >> "$PILOT_OUTPUTS_CSV"

	pilot_history_log "REGISTER_OUTPUT" "$output_file" "$profile" "OK"
}

# ================================================================
# #MARKER: PILOT SMC CUT PLAN REPORT HELPER
# ================================================================
pilot_register_smc_cut_plan() {
	local source_file="${1:-}"
	local output_file="${2:-}"
	local cut_args="${3:-}"

	pilot_is_active || return 0
	[[ -n "${PILOT_CUTS_TXT:-}" ]] || return 0

	source_file="$(canonical_factory_path "$source_file")"
	output_file="$(canonical_factory_path "$output_file")"

	{
		echo
		echo "============================================================"
		echo "SOURCE : $source_file"
		echo "OUTPUT : $output_file"
		echo "CUTS   : $cut_args"
		echo "------------------------------------------------------------"

		IFS=',' read -r -a tokens <<< "$cut_args"

		local n=0
		local i start end

		for ((i=0; i<${#tokens[@]}; i+=2)); do
			start="${tokens[$i]:-}"
			end="${tokens[$((i+1))]:-}"

			((n+=1)) || :

			echo "[$n] REMOVE SEGMENT"
			echo "    Start : $start"
			echo "    End   : $end"

			if [[ "$start" != "end" && "$start" != -* ]]; then
				echo "    Start HMS : $(format_seconds_hms "$start")"
			fi

			if [[ "$end" != "end" && "$end" != -* ]]; then
				echo "    End HMS   : $(format_seconds_hms "$end")"
			fi

			echo
		done
	} >> "$PILOT_CUTS_TXT"

	pilot_history_log "REGISTER_SMC_CUT_PLAN" "$output_file" "$cut_args" "OK"
}

# ================================================================
# #MARKER: SMC PILOT REVIEW HANDLER
# ================================================================
# PURPOSE:
# - Consume The Active Pilot Session After User Review.
# - Let User Accept, Redo, Or Keep Both.
#
# OPTIONS:
#   1) Accept Pilot And Archive Original(s)
#   2) Delete Pilot Output(s), Keep Original(s), Return For Redo
#   3) Keep Both For Manual Review
#
# DESIGN:
# - Pilot Runs Leave Originals In The Working Directory Until Accepted.
# - Accept Moves Originals To OEM/SMC Using The Normal Stage Archive Helper.
# - Redo Deletes Only Registered Pilot Outputs And Leaves Originals Alone.
# - Keep Both Does Nothing Except Log The Choice.
# ================================================================
handle_smc_pilot_review() {
	local choice
	local live_file output_file
	local archived_count=0
	local deleted_count=0
	local skipped_count=0

	if ! pilot_is_active; then
		echo -e "${YE} = = > No Active Pilot Session Found.${NC}"
		return 0
	fi

	clear

	echo
	echo -e "${CYAN} = = > Pilot Session:${NC} ${GREEN}${PILOT_SESSION_DIR}${NC}"

	if [[ -f "${PILOT_CUTS_TXT:-}" ]]; then
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN}              PILOT CUT PLAN SUMMARY                       ${NC}"
		echo -e "${GREEN} = = > Support Them Here: ${RE}https://${BW}smartmediacutter${CY}.com/${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${YELLOW}"
		cat "$PILOT_CUTS_TXT"
		echo -e "${NC}"
		echo -e "${CYAN}==========${ORANGEB} Scroll Up To See What Was The Cut Plan ${NC}${CYAN}==========${NC}"
	fi

	echo -e "${CYAN}============================================================${NC}"
	echo -e "${ORANGE}                  SMC PILOT REVIEW ${NC}"
	echo -e "${YEB}                GO Look At Your Files Right Now ! ${NC}"
	echo -e "${CYAN}          This Window Is Waiting For Your${NC}${ORANGEB} Decision ${NC}"
	echo -e "${CYAN}              Come Back Here And Make A${NC}${ORANGEB}   Choice DO IT NOW! ${NC}"
	echo -e "${ORANGE}                  SMC PILOT REVIEW ${NC}"
	echo -e "${CYAN}============================================================${NC}"

	echo -e "${YELLOW}     1) Accept Pilot And Archive Original(s)${NC}"
	echo -e "${YELLOW}     2) Delete Pilot Output(s), Keep Original(s), Return For Redo${NC}"
	echo -e "${YELLOW}     3) Keep Both For Manual Review${NC}"
	echo
	echo -e "${YELLOW}     0.) Return / Do Nothing${NC}"
	echo

	prompt_menu_choice " = = > Choose Pilot Result [1-3 | 0.=return]: " choice

	if is_exit_token "$choice"; then
		echo -e "${YE} = = > Pilot Review Skipped. Nothing Changed.${NC}"
		pilot_history_log "PILOT_REVIEW_SKIPPED" "$PILOT_SESSION_DIR" "user_returned" "OK"
		return 0
	fi

	case "$choice" in
		1)
			echo
			echo -e "${CYAN} = = > Accepting Pilot Result(s)...${NC}"
			echo -e "${TEAL} = = > Original source file(s) will move to OEM/SMC.${NC}"
			echo

			if [[ ! -f "$PILOT_RESTORE_CSV" ]]; then
				echo -e "${YE} = = > Missing Pilot Restore CSV:${NC} ${YELLOW}$PILOT_RESTORE_CSV${NC}"
				pilot_history_log "PILOT_ACCEPT_FAILED" "$PILOT_SESSION_DIR" "missing_restore_csv" "WARN"
				return 0
			fi

			while IFS= read -r live_file; do
				[[ -n "$live_file" ]] || continue

				if [[ -f "$live_file" ]]; then
					stage_archive_file "$live_file" "SMC"
					((archived_count+=1)) || :
					pilot_history_log "PILOT_ACCEPT_ARCHIVED_SOURCE" "$live_file" "$PILOT_SESSION_DIR" "OK"
				else
					echo -e "${YE} = = > Source Already Missing / Skipped:${NC} ${YELLOW}$live_file${NC}"
					((skipped_count+=1)) || :
					pilot_history_log "PILOT_ACCEPT_SOURCE_MISSING" "$live_file" "$PILOT_SESSION_DIR" "WARN"
				fi
			done < <(
				awk '
					NR == 1 { next }

					{
						line = $0
						if (substr(line,1,1) == "\"") {
							line = substr(line,2)
							out = ""
							for (i=1; i<=length(line); i++) {
								c = substr(line,i,1)
								n = substr(line,i+1,1)

								if (c == "\"" && n == "\"") {
									out = out "\""
									i++
									continue
								}

								if (c == "\"") {
									print out
									next
								}

								out = out c
							}
						} else {
							split(line,a,",")
							print a[1]
						}
					}
				' "$PILOT_RESTORE_CSV"
			)

			echo
			echo -e "${GR} = = > Pilot Accepted.${NC}"
			echo -e "${CYAN} = = > Archived Original(s):${NC} ${YELLOW}$archived_count${NC}"
			echo -e "${CYAN} = = > Skipped / Missing:${NC} ${YELLOW}$skipped_count${NC}"
			pilot_history_log "PILOT_ACCEPT_COMPLETE" "$PILOT_SESSION_DIR" "archived=$archived_count skipped=$skipped_count" "OK"
			rm -f pilot_history.csv
			pilot_cleanup_session_dir "$PILOT_SESSION_DIR"
			;;

		2)
			echo
			echo -e "${CYAN} = = > Deleting Pilot Output(s) For Redo...${NC}"
			echo -e "${CYAN} = = > Original source file(s) stay in the working directory.${NC}"
			echo

			pilot_delete_registered_outputs "pilot_history.csv"
			rm -f pilot_history.csv
			pilot_cleanup_session_dir "$PILOT_SESSION_DIR"

			echo
			echo -e "${GR} = = > Pilot Redo Prep Complete.${NC}"
			echo -e "${CYAN} = = > Original Source(s):${NC} ${GREEN}Still In Working Directory${NC}"
			pilot_history_log "PILOT_REDO_COMPLETE" "$PILOT_SESSION_DIR" "history_driven_cleanup" "OK"
			;;

		3)
			echo
			echo -e "${YE} = = > Keeping Both Pilot Output(s) And Original Source(s).${NC}"
			echo -e "${YELLOW} = = > No archive or delete action was performed.${NC}"
			pilot_history_log "PILOT_KEEP_BOTH" "$PILOT_SESSION_DIR" "manual_review" "OK"
			;;

		*)
			echo
			echo -e "${YE} = = > Invalid Pilot Review Choice. Nothing Changed.${NC}"
			pilot_history_log "PILOT_REVIEW_INVALID" "$PILOT_SESSION_DIR" "choice=$choice" "WARN"
			;;
	esac

	echo
}

pilot_register_temp() {
	local temp_file="$1"
	local reason="${2:-PILOT_TEMP}"

	pilot_is_active || return 0
	[[ -n "$temp_file" ]] || return 0

	temp_file="$(canonical_factory_path "$temp_file")"

	printf '%s,%s,%s\n' \
		"$(csv_escape "$temp_file")" \
		"$(csv_escape "$reason")" \
		"$(csv_escape "$(date '+%Y-%m-%d_%H%M%S')")" >> "$PILOT_TEMPS_CSV"

	pilot_history_log "REGISTER_TEMP" "$temp_file" "$reason" "OK"
}

pilot_restore_registered_originals() {
	local row live_file backup_path

	pilot_is_active || return 0
	[[ -f "$PILOT_RESTORE_CSV" ]] || return 0

	tail -n +2 "$PILOT_RESTORE_CSV" | while IFS= read -r row; do
		[[ -n "$row" ]] || continue

		live_file="$(printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $1); gsub(/""/, "\"", $1); print $1}')"
		backup_path="$(printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $2); gsub(/""/, "\"", $2); print $2}')"

		if [[ -f "$backup_path" ]]; then
			cp -p -- "$backup_path" "$live_file"
			echo -e "${GREEN} = = > Restored Pilot Source:${NC} ${YELLOW}$live_file${NC}"
			pilot_history_log "RESTORE_SOURCE" "$live_file" "$backup_path" "OK"
		else
			echo -e "${YE} = = > Missing Pilot Backup:${NC} ${YELLOW}$backup_path${NC}"
			pilot_history_log "RESTORE_SOURCE" "$live_file" "$backup_path" "MISSING_BACKUP"
		fi
	done || true
}

pilot_remove_registered_outputs() {
	local row output_file

	pilot_is_active || return 0
	[[ -f "$PILOT_OUTPUTS_CSV" ]] || return 0

	tail -n +2 "$PILOT_OUTPUTS_CSV" | while IFS= read -r row; do
		[[ -n "$row" ]] || continue

		output_file="$(printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $1); gsub(/""/, "\"", $1); print $1}')"

		if [[ -e "$output_file" ]]; then
			rm -f -- "$output_file"
			echo -e "${GREEN} = = > Removed Pilot Output:${NC} ${YELLOW}$output_file${NC}"
			pilot_history_log "REMOVE_OUTPUT" "$output_file" "" "OK"
		fi
	done || true
}

pilot_remove_registered_temps() {
	local row temp_file

	pilot_is_active || return 0
	[[ -f "$PILOT_TEMPS_CSV" ]] || return 0

	tail -n +2 "$PILOT_TEMPS_CSV" | while IFS= read -r row; do
		[[ -n "$row" ]] || continue

		temp_file="$(printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $1); gsub(/""/, "\"", $1); print $1}')"

		if [[ -e "$temp_file" ]]; then
			rm -rf -- "$temp_file"
			echo -e "${GREEN} = = > Removed Pilot Temp:${NC} ${YELLOW}$temp_file${NC}"
			pilot_history_log "REMOVE_TEMP" "$temp_file" "" "OK"
		fi
	done || true
}

pilot_restore_intro_map_if_needed() {
	if [[ -f "GOOD_intro_map.csv" ]]; then
		rm -f -- "intro_map.csv"
		mv -f -- "GOOD_intro_map.csv" "intro_map.csv"
		echo -e "${GREEN} = = > Restored: intro_map.csv${NC}"
		pilot_history_log "RESTORE_MAP" "intro_map.csv" "GOOD_intro_map.csv" "OK"
	else
		echo -e "${YELLOW} = = > No GOOD_intro_map.csv Found (Nothing To Restore).${NC}"
	fi
}

pilot_abort_recovery() {
	[[ "${PILOT_MODE:-0}" == "1" ]] || return 0

	echo -e "${YELLOW} = = > Pilot Abort Detected. Restoring State...${NC}"

	pilot_restore_intro_map_if_needed
	pilot_remove_registered_outputs
	pilot_remove_registered_temps
	pilot_restore_registered_originals

	# Legacy fallback for older SMARTGAP pilot outputs not yet registered.
	if declare -F remove_all_pilot_outputs >/dev/null 2>&1; then
		remove_all_pilot_outputs
	fi

	pilot_history_log "ABORT_RECOVERY" "${PILOT_SESSION_DIR:-NO_SESSION}" "Ctrl-C / SIGTERM" "DONE"
}

pilot_commit_session() {
	pilot_is_active || return 0

	pilot_history_log "COMMIT_SESSION" "$PILOT_SESSION_DIR" "Pilot accepted / kept" "OK"

	echo -e "${GREEN} = = > Pilot Session Committed:${NC} ${YELLOW}$PILOT_SESSION_DIR${NC}"
	echo -e "${CYAN} = = > Pilot History Updated:${NC} ${YELLOW}$PILOT_HISTORY_CSV${NC}"
}

pilot_redo_session() {
	pilot_abort_recovery
	echo -e "${GREEN} = = > Pilot Session Restored For Redo.${NC}"
}

# =========================
# #MARKER: INFO CSV LOOKUP BY RAW NAME
# =========================
# PURPOSE:
# - Return The Matching Ledger Row For One Raw Source Name.
# - Most Recent Match Wins If Duplicates Somehow Exist.
#
# OUTPUT:
# - Full CSV Row On Stdout
# - Empty If No Match
#
info_lookup_raw_row() {
    local raw="$1"
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	# WHY:
	# - info.csv should treat:
	#     Episode.mkv
	#     ./Episode.mkv
	#   as the same logical source identity.
	# - We canonicalize BEFORE lookup so the ledger has one stable key style.
	raw="$(canonical_factory_path "$raw")"
    ensure_info_map

    awk -F',' -v q="\"$raw\"" '
        NR==1 { next }
        $1 == q { row=$0 }
        END { if(row!="") print row }
    ' "$INFO_MAP"
}

# =========================
# #MARKER: INFO CSV FIELD GETTERS
# =========================
# PURPOSE:
# - Small Readers So Main Logic Does Not Become A Quoting Swamp.
#
# NOTE:
# - These assume our own writer format:
#     "raw","working","1","1","SAFE","123:456"
#
info_get_working_name() {
    local raw="$1"

	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"

    local row
    row="$(info_lookup_raw_row "$raw")"
    [[ -z "$row" ]] && return 1

    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $2); gsub(/""/, "\"", $2); print $2}'
}

info_get_auth_rekey() {
    local raw="$1"
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
    local row
    row="$(info_lookup_raw_row "$raw")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $3); print $3}'
}

info_get_validated_once() {
    local raw="$1"
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
    local row
    row="$(info_lookup_raw_row "$raw")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $4); print $4}'
}

info_get_keyframe_verdict() {
    local raw="$1"
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
    local row
    row="$(info_lookup_raw_row "$raw")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $5); print $5}'
}

info_get_source_sig() {
    local raw="$1"
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
    local row
    row="$(info_lookup_raw_row "$raw")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $6); print $6}'
}


info_get_keyframe_checked_path() {
    local raw="$1"
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
    local row
    row="$(info_lookup_raw_row "$raw")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $7); gsub(/""/, "\"", $7); print $7}'
}


# =========================
# #MARKER: INFO CSV CACHE VALIDITY CHECK
# =========================
# PURPOSE:
# - Decide Whether A Cached Row Still Matches The Current Raw File.
# - If File Changed Since Ledger Write, Cache Is Considered Stale.
#
info_cache_is_current() {
    local raw="$1"
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
    local saved_sig live_sig

    saved_sig="$(info_get_source_sig "$raw" 2>/dev/null || true)"
    [[ -z "$saved_sig" ]] && return 1

    live_sig="$(make_source_sig "$raw")"
    [[ "$saved_sig" == "$live_sig" ]]
}

# =========================
# #MARKER: INFO CSV UPSERT
# =========================
# PURPOSE:
# - Insert Or Replace One Ledger Row For A Raw File.
# - Keep Only One Authoritative Row Per raw_name.
#
# IMPORTANT:
# - We Rewrite Through A Temp File Because sed -i Quoting With CSV Is Gross.
#
info_upsert_row() {
    local raw="$1"
    local working="$2"
	# ========================================================
	# CANONICALIZE LEDGER KEYS BEFORE WRITE
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
	working="$(canonical_factory_path "$working")"
    local auth_rekey="$3"
    local validated_once="$4"
    local keyframe_verdict="$5"
    local source_sig="$6"
    local keyframe_checked_path="${7:-}"
    local tmp

    ensure_info_map
    tmp="$(mktemp)"

    awk -F',' -v q="\"$raw\"" '
        NR==1 { print; next }
        $1 == q { next }
        { print }
    ' "$INFO_MAP" > "$tmp"

    printf '%s,%s,%s,%s,%s,%s,%s\n' \
        "$(csv_escape "$raw")" \
        "$(csv_escape "$working")" \
        "$(csv_escape "$auth_rekey")" \
        "$(csv_escape "$validated_once")" \
        "$(csv_escape "$keyframe_verdict")" \
        "$(csv_escape "$source_sig")" \
        "$(csv_escape "$keyframe_checked_path")" >> "$tmp"

    mv -f -- "$tmp" "$INFO_MAP"
}

# =========================
# #MARKER: TRUSTED WORKING SOURCE CACHE CHECK
# =========================
# PURPOSE:
# - Return Cached Working Source If We Already Trust It For This Raw File.
# - This Is The Main Speed Win For Repeated IntroFind Passes.
#
# SUCCESS RETURNS:
# - Prints working_name
# - return 0
#
# FAILURE RETURNS:
# - Prints nothing
# - return 1
#
get_cached_working_source_if_trusted() {
    local raw="$1"
    local working auth validated verdict
	# ========================================================
	# CANONICALIZE RAW KEY ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"

    info_cache_is_current "$raw" || return 1

    working="$(info_get_working_name "$raw" 2>/dev/null || true)"
	# ========================================================
	# CANONICALIZE RETURNED WORKING NAME
	# ========================================================
	# WHY:
	# - The ledger may return a path with ./ prefix style differences.
	working="$(canonical_factory_path "$working")"
    auth="$(info_get_auth_rekey "$raw" 2>/dev/null || true)"
    validated="$(info_get_validated_once "$raw" 2>/dev/null || true)"
    verdict="$(info_get_keyframe_verdict "$raw" 2>/dev/null || true)"

    [[ -n "$working" ]] || return 1
    [[ -f "$working" ]] || return 1

    # IMPORTANT:
    # - We Only Trust Cached Working Source If It Was Already Validated.
    # - SAFE Is The Best Normal Case.
    # - CAUTION Can Still Be Reused If User Already Accepted That Tradeoff.
    #
    if [[ "$validated" == "1" && ( "$verdict" == "SAFE" || "$verdict" == "CAUTION" || "$verdict" == "RISKY" || "$verdict" == "UNKNOWN" ) ]]; then
        printf '%s\n' "$working"
        return 0
    fi

    return 1
}

# =========================
# #MARKER: RECORD TRUSTED WORKING SOURCE
# =========================
# PURPOSE:
# - Save The Chosen Working Source After Validation/Selection Has Happened.
# - auth_rekey=1 Means:
#     "This Working File Is A Deliberately Trusted REKEY For This Raw File."
#
record_working_source_state() {
    local raw="$1"
    local working="$2"
	# ========================================================
	# CANONICALIZE RAW + WORKING BEFORE RECORDING
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
	working="$(canonical_factory_path "$working")"
    local auth_rekey="$3"
    local validated_once="$4"
    local keyframe_verdict="$5"
    local keyframe_checked_path="${6:-}"
    local sig

    sig="$(make_source_sig "$raw")"

    info_upsert_row "$raw" "$working" "$auth_rekey" "$validated_once" "$keyframe_verdict" "$sig" "$keyframe_checked_path"
}

#end of new rekey validation skipped scheme helpers
# but more rekey helpers below

# ============================================================
# #MARKER: PREPARE SOURCES :: VERIFIED REKEY HANDOFF HELPERS
# ============================================================
# PURPOSE:
# - After OEM backup creation + Batch Normalizer run, verify that each
#   eligible original source now has BOTH:
#     1) its OEM safety copy in ./OEM/OEM_<original>
#     2) its rebuilt REKEY_<basename>.mkv working copy
#
# WHY THIS EXISTS:
# - Batch Normalizer itself is intentionally NON-DESTRUCTIVE.
# - That is still correct.
# - But once BOTH safety conditions are proven true, future-me may want
#   a one-time controlled handoff where the now-replaced originals are
#   deleted from the working folder to reduce clutter and save space.
#
# IMPORTANT SAFETY RULE:
# - Do NOT trust raw folder counts alone.
# - Counts are only a HUMAN sanity summary.
# - Actual delete eligibility is decided PER TARGET.
#
# DELETE ELIGIBLE MEANS:
# - source file is in the prepare/rekey scope
# - matching OEM backup exists
# - matching REKEY output exists
#
# NON-ELIGIBLE MEANS:
# - if either OEM backup or REKEY output is missing, do NOT delete original
#
# DESIGN:
# - Verification and deletion are split on purpose.
# - First verify.
# - Then ask user.
# - Then delete ONLY the verified originals.
#
# NOTE:
# - OEM copies remain the safety net.
# - This step removes only working-folder originals that were successfully
#   handed off into OEM + REKEY state.
#

prepare_collect_rekey_scope_targets() {
    # OUTPUT CONTRACT:
    # - Prints one eligible original source file per line.
    #
    # RULES:
    # - Exclude generated / workflow-prefixed files
    # - Exclude subtitle-packed outputs and already-processed outputs
    # - Exclude REKEY outputs themselves
    # - Exclude OEM-prefixed names if any are present in the working folder
    #
    shopt -s nullglob nocaseglob
    local -a vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
    shopt -u nullglob nocaseglob

    local f
    for f in "${vids[@]}"; do
        [[ "$f" =~ ^(REKEY_|SMC_|BARFIX_|SUBPACKED_|OEM_|OEM_) ]] && continue
        printf '%s\n' "$f"
    done
}

prepare_count_existing_targets() {
    local count=0
    local f
    for f in "$@"; do
        [[ -e "$f" ]] || continue
        ((count+=1)) || :
    done
    printf '%s\n' "$count"
}

prepare_verify_OEM_and_rekey_parity() {
    # OUTPUT VARIABLES:
    # - PREP_SCOPE_TOTAL
    # - PREP_OEM_MATCH_COUNT
    # - PREP_REKEY_MATCH_COUNT
    # - PREP_DELETE_ELIGIBLE_COUNT
    # - PREP_DELETE_BLOCKED_COUNT
    #
    # ARRAYS:
    # - PREP_DELETE_ELIGIBLE[@]
    # - PREP_DELETE_BLOCKED[@]
    #
    local -a targets=()
    local f base rekey backup
    local has_OEM has_rekey

    PREP_SCOPE_TOTAL=0
    PREP_OEM_MATCH_COUNT=0
    PREP_REKEY_MATCH_COUNT=0
    PREP_DELETE_ELIGIBLE_COUNT=0
    PREP_DELETE_BLOCKED_COUNT=0
    PREP_DELETE_ELIGIBLE=()
    PREP_DELETE_BLOCKED=()

    mapfile -t targets < <(prepare_collect_rekey_scope_targets)

    for f in "${targets[@]}"; do
        [[ -f "$f" ]] || continue
        ((PREP_SCOPE_TOTAL+=1)) || :

        base="${f%.*}"
        rekey="REKEY_${base}.mkv"
        backup="OEM/OEM_${f}"

        has_OEM=0
        has_rekey=0

        if [[ -f "$backup" ]]; then
            has_OEM=1
            ((PREP_OEM_MATCH_COUNT+=1)) || :
        fi

        if [[ -f "$rekey" ]]; then
            has_rekey=1
            ((PREP_REKEY_MATCH_COUNT+=1)) || :
        fi

        if (( has_OEM == 1 && has_rekey == 1 )); then
            PREP_DELETE_ELIGIBLE+=("$f")
            ((PREP_DELETE_ELIGIBLE_COUNT+=1)) || :
        else
            PREP_DELETE_BLOCKED+=("$f")
            ((PREP_DELETE_BLOCKED_COUNT+=1)) || :
        fi
    done
}

prepare_print_verified_rekey_handoff_summary() {
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}   PREPARE SOURCES :: VERIFIED REKEY HANDOFF    ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${CYAN} = = > Rekey Scope Targets:${NC} $PREP_SCOPE_TOTAL"
    echo -e "${CYAN} = = > Matching OEM Backups:${NC} $PREP_OEM_MATCH_COUNT"
    echo -e "${CYAN} = = > Matching REKEY Outputs:${NC} $PREP_REKEY_MATCH_COUNT"
    echo -e "${GREEN} = = > Delete-Eligible Originals:${NC} $PREP_DELETE_ELIGIBLE_COUNT"
    echo -e "${YELLOW} = = > Blocked / Incomplete Targets:${NC} $PREP_DELETE_BLOCKED_COUNT"
    echo

    if (( PREP_DELETE_ELIGIBLE_COUNT > 0 )); then
        echo -e "${GREEN} = = > Originals Safe To Hand Off Right Now:${NC}"
        local f
        for f in "${PREP_DELETE_ELIGIBLE[@]}"; do
            echo -e "  ${GREEN}-${NC} $f"
        done
        echo
    fi

    if (( PREP_DELETE_BLOCKED_COUNT > 0 )); then
        echo -e "${YELLOW} = = > Originals NOT Safe To Delete Yet:${NC}"
        local f base rekey backup
        for f in "${PREP_DELETE_BLOCKED[@]}"; do
            base="${f%.*}"
            rekey="REKEY_${base}.mkv"
            backup="OEM/OEM_${f}"

            echo -e "  ${YELLOW}-${NC} $f"

            if [[ ! -f "$backup" ]]; then
                echo -e "      ${REB}missing OEM backup:${NC} $backup"
            fi

            if [[ ! -f "$rekey" ]]; then
                echo -e "      ${REB}missing REKEY output:${NC} $rekey"
            fi
        done
        echo
    fi
}

prepare_delete_verified_originals() {
    # PURPOSE:
    # - Delete ONLY originals already verified as protected by:
    #     OEM/OEM_<original>
    #     REKEY_<basename>.mkv
    #
    # IMPORTANT:
    # - This does NOT touch OEM backups.
    # - This does NOT touch REKEY outputs.
    # - This does NOT touch blocked/incomplete targets.
    #
    local removed=0
    local failed=0
    local f

    if (( PREP_DELETE_ELIGIBLE_COUNT == 0 )); then
        echo -e "${YELLOW} = = > No Verified Originals Are Eligible For Deletion.${NC}"
        echo
        return 0
    fi

    echo -e "${RED}================================================${NC}"
    echo -e "${RED} = = > CONTROLLED ORIGINAL HANDOFF / DELETE STEP${NC}"
    echo -e "${RED}================================================${NC}"
    echo -e "${YELLOW} = = > Only Verified Originals Listed Above Will Be Deleted.${NC}"
    echo -e "${YELLOW} = = > OEM Safety Copies Remain In ./OEM With OEM_ Prefix.${NC}"
    echo -e "${YELLOW} = = > REKEY Working Files Remain In Place.${NC}"
    echo

	if ! ask_yes_no " = = > Delete Verified Originals Now? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Verified Original Deletion Cancelled.${NC}"
		echo
		return 0
	fi

	for f in "${PREP_DELETE_ELIGIBLE[@]}"; do
		# ========================================================
		# DEFENSIVE CHECK:
		# - File may have been moved/deleted between verification
		#   and this final delete step (rare, but possible).
		# - Skip cleanly instead of counting as a failure.
		# ========================================================
		if [[ ! -f "$f" ]]; then
			echo -e "${YELLOW} = = > [SKIP MISSING ORIGINAL]${NC} $f"
			continue
		fi

		if rm -f -- "$f"; then
			echo -e "${GREEN} = = > [DELETED ORIGINAL]${NC} $f"
			((removed+=1)) || :
		else
			echo -e "${REB} = = > [FAILED DELETE]${NC} $f"
			((failed+=1)) || :
		fi
	done

    echo
    echo -e "${CYAN} = = > Originals Deleted:${NC} $removed"
    echo -e "${CYAN} = = > Delete Failures:${NC} $failed"
    echo
}

prepare_offer_delete_originals_after_verified_rekey() {
    prepare_verify_OEM_and_rekey_parity
    prepare_print_verified_rekey_handoff_summary
    prepare_delete_verified_originals
}

#==========================================================================================================

rebuild_rekey_auth_ledger() {
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}     REKEY AUTH SYSTEM :: LEDGER REBUILD PASS   ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}PURPOSE:${NC}"
	echo -e " = = > Rebuild info.csv by validating matching REKEY files"
	echo -e " = = > Re-authorize raw -> REKEY trust relationships from scratch"
	echo
	echo -e "${YELLOW}WHAT THIS DOES:${NC}"
	echo -e " = = > Clears current info.csv ledger"
	echo -e " = = > Scans eligible original/raw source files in this folder"
	echo -e " = = > Looks for matching REKEY_<name>.mkv files"
	echo -e " = = > Validates each REKEY once and records the result"
	echo -e " = = > Rebuilds cached trust / reject knowledge into info.csv"
	echo
	echo -e "${YELLOW}WHAT THIS DOES NOT DO:${NC}"
	echo -e " = = > Does NOT create new REKEY files"
	echo -e " = = > Does NOT delete REKEY files"
	echo -e " = = > Does NOT delete OEM backups"
	echo -e " = = > Does NOT change intro_map.csv"
	echo
	echo -e "${RED} = = > This is a real ledger rebuild, not just a reset.${NC}"
	echo

	if ! ask_yes_no " = = > Proceed with FULL REKEY auth ledger rebuild? (y/n or 1/2): "; then
		echo
		echo -e "${YELLOW} = = > REKEY Auth Ledger Rebuild Cancelled.${NC}"
		echo
		pause
		return 0
	fi

	local -a targets=()
	local raw base rekey verdict
	local total=0
	local found_rekey=0
	local safe_count=0
	local risky_count=0
	local missing_rekey_count=0

	# --------------------------------------------------------
	# START CLEAN
	# --------------------------------------------------------
	rm -f -- "$INFO_MAP"
	ensure_info_map

	# --------------------------------------------------------
	# COLLECT ELIGIBLE RAW / ORIGINAL TARGETS
	# --------------------------------------------------------
	mapfile -t targets < <(prepare_collect_rekey_scope_targets)
	total="${#targets[@]}"

	echo
	echo -e "${CYAN} = = > Eligible Raw Targets Found:${NC} $total"
	echo -e "${CYAN} = = > Rebuilding Ledger...${NC}"
	echo

	for raw in "${targets[@]}"; do
		[[ -f "$raw" ]] || continue

		base="${raw%.*}"
		rekey="REKEY_${base}.mkv"

		if [[ ! -f "$rekey" ]]; then
			echo -e "${YELLOW} = = > [NO MATCHING REKEY]${NC} $raw"
			((missing_rekey_count+=1)) || :
			continue
		fi

		((found_rekey+=1)) || :
		echo -e "${CYAN} = = > [CHECKING]${NC} RAW: ${GREEN}$raw${NC}"
		echo -e "${CYAN} = = > [MATCHED] ${NC} REKEY: ${GREEN}$rekey${NC}"

		# ----------------------------------------------------
		# PAY THE EXPENSIVE PROBE ONCE, THEN RECORD RESULT
		# ----------------------------------------------------
		if is_cut_friendly_rekey_file "$rekey"; then
			verdict="SAFE"
			record_working_source_state "$raw" "$rekey" "1" "1" "$verdict" "$rekey"
			echo -e "${GREEN} = = > [AUTHORIZED]${NC} $rekey"
			((safe_count+=1)) || :
		else
			verdict="RISKY"
			record_working_source_state "$raw" "$rekey" "0" "1" "$verdict" "$rekey"
			echo -e "${YELLOW} = = > [RECORDED REJECT]${NC} $rekey"
			((risky_count+=1)) || :
		fi

		echo
	done

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        REKEY AUTH LEDGER REBUILD SUMMARY       ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Raw Targets Scanned:${NC} $total"
	echo -e "${CYAN} = = > Matching REKEY Files Found:${NC} $found_rekey"
	echo -e "${GREEN} = = > SAFE / AUTHORIZED REKEY Rows:${NC} $safe_count"
	echo -e "${YELLOW} = = > RISKY / REJECTED REKEY Rows:${NC} $risky_count"
	echo -e "${YELLOW} = = > Raw Targets With No Matching REKEY:${NC} $missing_rekey_count"
	echo -e "${CYAN} = = > Ledger Rebuilt:${NC} $INFO_MAP"
	echo
	pause
}

refresh_rekey_auth_system() {
	# ========================================================
	# PURPOSE:
	# - Keep the menu option name stable while upgrading the
	#   behavior from simple reset into a true ledger rebuild.
	#
	# WHY THIS WRAPPER EXISTS:
	# - The menu wording is already wired and user-facing.
	# - Future internal changes can still route through one
	#   stable entry point from the Prepare Sources submenu.
	# ========================================================
	rebuild_rekey_auth_ledger
}

# more rekey helpers below
#=====================================================================================
# wrapper helper whose whole job is to redirect the workflow in the right order

# =========================
# #MARKER: SOURCE RESOLUTION WITH EARLY SKIP / CACHE
# =========================
# PURPOSE:
# - Stop Paying REKEY Validation Cost For Files Already Mapped.
# - Reuse Trusted Cached Working Sources Across Repeated IntroFind Passes.
#
# ORDER OF OPERATIONS:
# 1) Cheapest skip first -> intro_map.csv on RAW name
# 2) Cache lookup next   -> info.csv trusted working source
# 3) Only then do normalize / prefer / validate work
#
# OUTPUT CONTRACT:
# - Prints chosen working source path
# - return 0 on normal path
# - return 10 if raw file is already mapped and caller should skip immediately
#
resolve_working_source_for_detection() {
    local raw="$1"
    local file cached verdict auth_rekey

    # ========================================================
    # FIRST GATE: RAW-NAME INTRO MAP SKIP
    # ========================================================
    # WHY THIS MUST BE FIRST:
    # - If The File Is Already In intro_map.csv, Nothing Else Matters.
    # - Do NOT Normalize It.
    # - Do NOT Probe Keyframes.
    # - Do NOT Go Shopping For REKEY.
    #
    if already_processed "$raw"; then
        echo -e "${YELLOW} = = > Already Mapped By RAW Name. Skipping Early.${NC}" >&2
        return 10
    fi

    # ========================================================
    # SECOND GATE: TRUSTED CACHE REUSE
    # ========================================================
    # WHY:
    # - Repeated IntroFind Passes Should Reuse Prior Validation Knowledge.
    # - If We Already Trust A Working File For This Raw File, Use It.
    #
    if cached="$(get_cached_working_source_if_trusted "$raw" 2>/dev/null)"; then
        echo -e "${GREEN} = = > Working Source Used:${NC} $(basename "$cached")" >&2

        # Defensive alias skip:
        # If The Cached Working File Itself Was Already Mapped, Caller Can Skip.
        if already_processed "$cached"; then
            echo -e "${YELLOW} = = > Working Source Already Mapped. Skipping.${NC}" >&2
            return 10
        fi

        printf '%s\n' "$cached"
        return 0
    fi

    # ========================================================
    # FALLBACK: NORMAL PATH
    # ========================================================
    # Only reach this point if:
    # - raw file was NOT already mapped
    # - no trusted cache row was reusable
    #

    file="$(get_preferred_source_file "$raw")"

    if [[ "$file" != "$raw" ]]; then
        echo -e "${CYAN} = = > Working Source Selected:${NC} $file" >&2
    fi

    # Alias skip still matters after source redirection.
    if already_processed "$file"; then
        echo -e "${YELLOW} = = > Already Mapped By Working Source Alias. Skipping.${NC}" >&2
        return 10
    fi

    printf '%s\n' "$file"
    return 0
}

#    end of wrapper helper whose whole job is to redirect the workflow in the right order

# ================================================================
# #INDIVIDUAL-TEMPLATE OUTPUT NAME INCREMENTER
# ================================================================
next_template_output_path() {
	local base="$1"
	local dir stem ext candidate n

	dir="$(dirname "$base")"
	stem="$(basename "$base")"
	ext="${stem##*.}"
	stem="${stem%.*}"

	candidate="$base"
	n=1

	while [[ -e "$candidate" ]]; do
		candidate="${dir}/${stem}_${n}.${ext}"
		((n+=1)) || :
	done

	printf '%s\n' "$candidate"
}


log_looker() {

	local choice file idx ext color
	local -a log_files=()

	while true; do
		clear
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN}      = = > LOG LOOKER${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo

		log_files=()

		while IFS= read -r file; do
			log_files+=("$file")
		done < <(
			find . -maxdepth 1 -type f \
				\( -iname "*.log" -o -iname "*.txt" -o -iname "*.csv" -o -iname "*.tsv" -o -iname "*.json" -o -iname "*.md" \) \
				-printf '%f\n' \
				| awk '
					{
						name=$0
						ext=name
						sub(/^.*\./,"",ext)
						print tolower(ext) "|" name
					}
				' \
				| sort -t'|' -k1,1 -k2,2 \
				| cut -d'|' -f2-
		)

		if (( ${#log_files[@]} == 0 )); then
			echo -e "${YE} = = > No log/text/csv-style files found in working dir.${NC}"
			pause
			return 0
		fi

		for idx in "${!log_files[@]}"; do
			file="${log_files[$idx]}"
			ext="${file##*.}"
			ext="${ext,,}"

			case "$ext" in
				csv|tsv)  color="$GREEN" ;;
				log)      color="$YELLOW" ;;
				txt|md)   color="$CYAN" ;;
				json)     color="$MAGENTA" ;;
				*)        color="$WHITE" ;;
			esac

			printf '%b%5d)%b %b%s%b\n' \
				"$YELLOW" "$((idx + 1))" "$NC" "$color" "$file" "$NC"
		done

		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo

		prompt_menu_choice " = = > Select File To View [number | 0.=return]: " choice

		if is_exit_token "$choice"; then
			return 0
		fi

		if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#log_files[@]} )); then
			echo -e "${YE} = = > Invalid Selection.${NC}"
			pause
			continue
		fi

		file="${log_files[$((choice - 1))]}"

		if command -v less >/dev/null 2>&1; then
			less -S -- "$file"
		else
			cat -- "$file"
			pause
		fi
	done
}

# start of EXTRACT TEMPLATES that were a match for archival purposes FROM INTRO_MAP
# =========================
# #MARKER: EXTRACT USED TEMPLATES FROM INTRO_MAP
# =========================
get_templates_from_intro_map() {
	local map="${1:-$INTRO_MAP}"

	[[ -f "$map" ]] || return 0

	awk -F',' 'NR>1 && $6 != "" {print $6}' "$map" | sort -u
}

# end of EXTRACT TEMPLATES that were a match for archival purposes FROM INTRO_MAP
#====================================================================================
# more helpers

# =========================
# #MARKER: MEDIA TRUTH PROBE (VIDEO / AUDIO / SUBTITLE / DECODE DIAGNOSTICS)
# =========================
# PURPOSE:
# - Quickly inspect what a media file actually contains
# - Show container, video, audio, and subtitle facts
# - Highlight codec / profile / pixel-format facts that often explain
#   playback weirdness immediately
# - Compare default video decode path vs software-decode playback path
# - Check audio decode viability
# - Help separate:
#     bad file
#     bad player path
#     bad hardware decode path
#     audio policy / stream preservation issue
#
# USAGE:
# - run_media_truth_probe "file.mkv"
# - run_video_truth_probe "file.mkv"   # compatibility wrapper
#
# DESIGN:
# - Non-destructive
# - Informational only
# - Safe to run from Utility / Advanced Tools

# =========================
# #MARKER: MEDIA TRUTH PROBE (VIDEO / AUDIO / SUBTITLE / DECODE DIAGNOSTICS)
# =========================
run_media_truth_probe() {
	local f="$1"
	local codec_name profile pix_fmt width height level
	local duration size_bytes bit_rate size_human
	local profile_color="$GR"
	local pix_color="$GR"

	if [[ ! -f "$f" ]]; then
		echo -e "${REB} = = > File Not Found:${NC} ${GREEN}$f${NC}"
		return 1
	fi

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                 MEDIA TRUTH PROBE              ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > File:${NC} ${GREEN}$f${NC}"

	duration="$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
	size_bytes="$(stat -c '%s' -- "$f" 2>/dev/null || printf '0')"
	bit_rate="$(ffprobe -v error -show_entries format=bit_rate -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
	size_human="$(format_bytes_human "$size_bytes")"

	echo
	echo -e "${CYAN} = = > Container:${NC}"
	echo -e "${CYAN}     Duration:${NC} ${YELLOW}${duration:-unknown}${NC}"
	echo -e "${CYAN}     Size:${NC} ${YELLOW}${size_human:-unknown}${NC}"
	echo -e "${CYAN}     Bitrate:${NC} ${YELLOW}${bit_rate:-unknown}${NC}"

	codec_name="$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
	profile="$(ffprobe -v error -select_streams v:0 -show_entries stream=profile -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
	pix_fmt="$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
	width="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
	height="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"
	level="$(ffprobe -v error -select_streams v:0 -show_entries stream=level -of default=nw=1:nk=1 "$f" 2>/dev/null || true)"

	case "${profile,,}" in
		*"high 10"*) profile_color="$YE" ;;
		*) profile_color="$GR" ;;
	esac

	case "${pix_fmt,,}" in
		*yuv420p10le*|*10le*|*p10*) pix_color="$YE" ;;
		*yuv420p*) pix_color="$GR" ;;
		*) pix_color="$CYAN" ;;
	esac

	echo
	echo -e "${CYAN} = = > Video Stream 0:${NC}"
	echo -e "${CYAN}     Codec:${NC} ${GREEN}${codec_name:-unknown}${NC}"
	echo -e "${CYAN}     Profile:${NC} ${profile_color}${profile:-unknown}${NC}"
	echo -e "${CYAN}     Pixel Format:${NC} ${pix_color}${pix_fmt:-unknown}${NC}"
	echo -e "${CYAN}     Resolution:${NC} ${GREEN}${width:-?}x${height:-?}${NC}"
	echo -e "${CYAN}     Level:${NC} ${GREEN}${level:-unknown}${NC}"

	if [[ "${profile,,}" == *"high 10"* ]] || [[ "${pix_fmt,,}" == *"10le"* ]] || [[ "${pix_fmt,,}" == *"p10"* ]]; then
		echo -e "${YE} = = > Attention:${NC} ${YE}10-bit video path detected.${NC}"
		echo -e "${YE} = = > Some players / GPU decode paths may garble this even when the file is valid.${NC}"
	fi

	echo
	echo -e "${CYAN} = = > Audio Streams:${NC}"
	ffprobe -v error \
		-select_streams a \
		-show_entries stream=index,codec_name,channels,channel_layout:stream_tags=language,title \
		-of csv=p=0 "$f" 2>/dev/null |
		awk -F',' -v CYAN="$CYAN" -v GREEN="$GREEN" -v YELLOW="$YELLOW" -v WHITE="$WHITE" -v NC="$NC" '
		BEGIN { count=0 }
		{
			count++
			idx=$1; codec=$2; channels=$3; layout=$4; lang=$5; title=$6
			if (lang == "") lang="und"
			if (title == "") title="-"
			printf "%s     #%s%s %scodec=%s%s%s %slang=%s%s%s %stitle=%s%s%s\n", CYAN, idx, NC, WHITE, GREEN, codec, NC, WHITE, GREEN, lang, NC, WHITE, GREEN, title, NC
		}
		END {
			if (count == 0) printf "%s     No audio streams found.%s\n", YELLOW, NC
		}
	'

	echo
	echo -e "${CYAN} = = > Subtitle Streams:${NC}"
	ffprobe -v error \
		-select_streams s \
		-show_entries stream=index,codec_name:stream_tags=language,title \
		-of csv=p=0 "$f" 2>/dev/null |
		awk -F',' -v CYAN="$CYAN" -v GREEN="$GREEN" -v YELLOW="$YELLOW" -v WHITE="$WHITE" -v NC="$NC" '
		BEGIN { count=0 }
		{
			count++
			idx=$1; codec=$2; lang=$3; title=$4
			if (lang == "") lang="und"
			if (title == "") title="-"
			printf "%s     #%s%s %scodec=%s%s%s %schannels=%s%s%s %slayout=%s%s%s %slang=%s%s%s %stitle=%s%s%s\n", CYAN, idx, NC, WHITE, GREEN, codec, NC, WHITE, YELLOW, channels, NC, WHITE, YELLOW, layout, NC, WHITE, GREEN, lang, NC, WHITE, GREEN, title, NC
		}
		END {
			if (count == 0) printf "%s     No subtitle streams found.%s\n", YELLOW, NC
		}
	'

	echo
	echo -e "${CYAN} = = > Summary:${NC}"
	echo -e "${GR} = = > Media stream inventory complete.${NC}"
	echo -e "${CYAN} = = > Container, video, audio, subtitle, and decode checks were inspected.${NC}"
	echo -e "${CYAN} = = > For GPU / player-path diagnostics, use Dependency Status.${NC}"

	return 0
}

run_video_truth_probe() {
	run_media_truth_probe "$@"
}

# =========================
# #MARKER: VIDEO TRUTH PROBE MENU WRAPPER
# =========================
# PURPOSE:
# - Provide a Factory-style file picker for the Video Truth Probe
# - Keep the probe itself simple and reusable
# - Avoid requiring manual path typing for routine diagnostics
# =========================
run_video_truth_probe_menu() {
	local -a vids=()
	local chosen=""

	shopt -s nullglob nocaseglob
	vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	if ((${#vids[@]} == 0)); then
		echo
		echo -e "${YE} = = > No Eligible Video Files Found In Current Folder.${NC}"
		echo
		pause
		return 0
	fi

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}             VIDEO TRUTH PROBE PICKER           ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${CYAN} = = > Select A Video To Inspect:${NC}${GREEN}"
		echo

		select chosen in "${vids[@]}"; do
			if [[ -n "${chosen:-}" ]]; then
				echo -e "${NC}"
				run_video_truth_probe "$chosen"
				pause
				return 0
			fi

			echo
			echo -e "${REB} = = > Invalid Selection.${NC}"
			echo
			break
		done
	done
}

# ================================================================
# #MARKER: AVI / DIRTY VIDEO RESCUE HELPERS
# ================================================================
# PURPOSE:
# - Give old AVI / dirty MKV sources a controlled repair ladder.
# - Avoid pretending there is one magic FFmpeg repair switch.
# - Let user test short pilot samples before committing a full rebuild.
#
# MODES:
# - REMUX       : container / timestamp rebuild, stream copy
# - DECODE      : dirty decode rebuild to H.264 MKV
# - BWDIF       : deinterlace / field-order rescue
# - DENOISE     : mild analog/noise cleanup
# - LASTCHANCE  : deinterlace + denoise + quality-leaning rebuild
#
# RULE:
# - Never overwrite original.
# - Outputs use RESCUE_* or PILOT_RESCUE_* prefixes.
# ================================================================

avi_rescue_collect_sources() {
	local -n _out_ref=$1
	local f

	_out_ref=()

	shopt -s nullglob nocaseglob
	for f in *.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv}; do
		[[ -f "$f" ]] || continue

		case "$f" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*|RESCUE_*|PILOT_RESCUE_*|AUDIOFIX_*|TIMEPRESS_*|AUDIOLEVEL_*|intro_template*|custom_cut*)
				continue
				;;
		esac

		_out_ref+=("$f")
	done
	shopt -u nocaseglob
	shopt -s nullglob
}

avi_rescue_profile_label() {
	case "${1:-}" in
		REMUX)      printf '%s\n' "Fast Remux / Timestamp Rebuild" ;;
		DECODE)     printf '%s\n' "Dirty Decode Rebuild" ;;
		BWDIF)      printf '%s\n' "Deinterlace / Field Rescue" ;;
		DENOISE)    printf '%s\n' "Mild Noise Cleanup" ;;
		LASTCHANCE) printf '%s\n' "Last-Chance Combo Rescue" ;;
		*)          printf '%s\n' "Unknown Rescue Profile" ;;
	esac
}

avi_rescue_output_name() {
	local src="$1"
	local profile="$2"
	local pilot="${3:-0}"
	local base stem prefix

	base="$(basename "$src")"
	stem="${base%.*}"

	if [[ "$pilot" == "1" ]]; then
		prefix="PILOT_RESCUE_${profile}_"
	else
		prefix="RESCUE_${profile}_"
	fi

	printf '%s%s.mkv\n' "$prefix" "$stem"
}

avi_rescue_run_profile() {
	local src="$1"
	local profile="$2"
	local out="$3"
	local start="${4:-}"
	local dur="${5:-}"
	local -a trim_args=()

	[[ -f "$src" ]] || {
		echo -e "${REB} = = > Source Missing:${NC} ${YELLOW}$src${NC}"
		return 1
	}

	rm -f -- "$out"

	if [[ -n "$start" ]]; then
		trim_args+=(-ss "$start")
	fi

	if [[ -n "$dur" ]]; then
		trim_args+=(-t "$dur")
	fi

	echo
	echo -e "${CYAN} = = > Rescue Profile:${NC} ${YELLOW}$(avi_rescue_profile_label "$profile")${NC}"
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	echo

	case "$profile" in
		REMUX)
			run_with_progress "Rescue REMUX: $(basename "$src")" \
				ffmpeg -y -hide_banner -nostats -loglevel error \
					-fflags +genpts+discardcorrupt \
					-err_detect ignore_err \
					"${trim_args[@]}" \
					-i "$src" \
					-map 0 \
					-c copy \
					"$out"
			;;

		DECODE)
			run_with_progress "Rescue DECODE: $(basename "$src")" \
				ffmpeg -y -hide_banner -nostats -loglevel error \
					-fflags +genpts+discardcorrupt \
					-err_detect ignore_err \
					"${trim_args[@]}" \
					-i "$src" \
					-map 0 \
					-c:v libx264 -preset slow -crf 20 \
					-pix_fmt yuv420p \
					-c:a copy \
					-c:s copy \
					"$out"
			;;

		BWDIF)
			run_with_progress "Rescue BWDIF: $(basename "$src")" \
				ffmpeg -y -hide_banner -nostats -loglevel error \
					-fflags +genpts+discardcorrupt \
					-err_detect ignore_err \
					"${trim_args[@]}" \
					-i "$src" \
					-map 0 \
					-vf "bwdif,format=yuv420p" \
					-c:v libx264 -preset slow -crf 20 \
					-c:a copy \
					-c:s copy \
					"$out"
			;;

		DENOISE)
			run_with_progress "Rescue DENOISE: $(basename "$src")" \
				ffmpeg -y -hide_banner -nostats -loglevel error \
					-fflags +genpts+discardcorrupt \
					-err_detect ignore_err \
					"${trim_args[@]}" \
					-i "$src" \
					-map 0 \
					-vf "hqdn3d=1.5:1.5:6:6,format=yuv420p" \
					-c:v libx264 -preset slow -crf 20 \
					-c:a copy \
					-c:s copy \
					"$out"
			;;

		LASTCHANCE)
			run_with_progress "Rescue LASTCHANCE: $(basename "$src")" \
				ffmpeg -y -hide_banner -nostats -loglevel error \
					-fflags +genpts+discardcorrupt \
					-err_detect ignore_err \
					"${trim_args[@]}" \
					-i "$src" \
					-map 0 \
					-vf "bwdif,hqdn3d=1.5:1.5:6:6,format=yuv420p" \
					-c:v libx264 -preset slow -crf 18 \
					-g 24 -keyint_min 24 -sc_threshold 0 \
					-c:a copy \
					-c:s copy \
					"$out"
			;;

		*)
			echo -e "${REB} = = > Unknown Rescue Profile:${NC} ${YELLOW}$profile${NC}"
			return 1
			;;
	esac

	if [[ -s "$out" ]]; then
		echo -e "${GR} = = > Rescue Output Created:${NC} ${GREEN}$out${NC}"

		if [[ "${PILOT_MODE:-0}" == "1" ]]; then
			pilot_register_output "$out" "RESCUE_${profile}"
		fi

		return 0
	fi

	rm -f -- "$out"
	echo -e "${REB} = = > Rescue Failed:${NC} ${YELLOW}$src${NC}"
	return 1
}

avi_rescue_pick_one_source() {
	local __var_name="$1"
	local -a sources=()
	local pick idx

	avi_rescue_collect_sources sources

	if ((${#sources[@]} == 0)); then
		echo
		echo -e "${YE} = = > No Eligible Dirty Video / Rescue Sources Found.${NC}"
		echo
		printf -v "$__var_name" '%s' ""
		return 1
	fi

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          LEGACY / DIRTY VIDEO PICKER           ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	for idx in "${!sources[@]}"; do
		printf '%b%5d)%b %b%s%b\n' \
			"$YELLOW" "$((idx + 1))" "$NC" "$GREEN" "${sources[$idx]}" "$NC"
	done

	echo
	prompt_menu_choice " = = > Pick File Number [0.=return]: " pick

	if is_exit_token "$pick"; then
		printf -v "$__var_name" '%s' ""
		return 1
	fi

	if [[ ! "$pick" =~ ^[0-9]+$ ]] || (( pick < 1 || pick > ${#sources[@]} )); then
		echo -e "${REB} = = > Invalid Selection.${NC}"
		printf -v "$__var_name" '%s' ""
		return 1
	fi

	printf -v "$__var_name" '%s' "${sources[$((pick - 1))]}"
	return 0
}

avi_rescue_pick_profile() {
	local __var_name="$1"
	local choice selected_profile=""

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}           LEGACY RESCUE PROFILE MENU           ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) REMUX      - Fast Container / Timestamp Rebuild${NC}"
	echo -e "${YELLOW}     2) DECODE     - Full Decode Rebuild${NC}"
	echo -e "${YELLOW}     3) BWDIF      - Deinterlace / Field Rescue${NC}"
	echo -e "${YELLOW}     4) DENOISE    - Mild Noise Cleanup Rebuild${NC}"
	echo -e "${YELLOW}     5) LASTCHANCE - Heavy Combo Recovery${NC}"
	echo -e "${YE} = = 2 Thru 5 ==== Are ==== SmartCut Friendly Rescue Options${NC}"
	echo
	echo -e "${YELLOW}     0.) Return${NC}"
	echo

	prompt_menu_choice " = = > Choose Profile [1-5 | 0.=return]: " choice

	if is_exit_token "$choice"; then
		printf -v "$__var_name" '%s' ""
		return 1
	fi

	case "$choice" in
		1) selected_profile="REMUX" ;;
		2) selected_profile="DECODE" ;;
		3) selected_profile="BWDIF" ;;
		4) selected_profile="DENOISE" ;;
		5) selected_profile="LASTCHANCE" ;;
		*)
			echo -e "${REB} = = > Invalid Profile.${NC}"
			printf -v "$__var_name" '%s' ""
			return 1
			;;
	esac

	printf -v "$__var_name" '%s' "$selected_profile"
	return 0
}

run_avi_rescue_one_file_full() {
	local src profile out

	if ! avi_rescue_pick_one_source src; then
		pause
		return 0
	fi

	if ! avi_rescue_pick_profile profile; then
		pause
		return 0
	fi

	out="$(avi_rescue_output_name "$src" "$profile" 0)"

	echo
	echo -e "${YE} = = > This Will Create A New Rescue Output And Leave Original Untouched.${NC}"
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	echo

	if ! ask_yes_no " = = > Run This Rescue Profile Now? (y/n or 1/2): "; then
		echo -e "${YE} = = > Rescue Cancelled.${NC}"
		pause
		return 0
	fi

	avi_rescue_run_profile "$src" "$profile" "$out"
	pause
}

run_avi_rescue_pilot_samples() {
	local src start dur
	local profile out
	local -a profiles=(REMUX DECODE BWDIF DENOISE LASTCHANCE)

	if ! avi_rescue_pick_one_source src; then
		pause
		return 0
	fi

	echo
	echo -e "${CYAN} = = > Pilot sample creates short test outputs for all rescue profiles.${NC}"
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	echo

	prompt_time_seconds " = = > Sample Start Time (blank = beginning): " start
	if [[ "${start:-}" == "EXIT" ]]; then
		return 0
	fi

	prompt_time_seconds " = = > Sample Length Seconds (default 20): " dur
	if [[ "${dur:-}" == "EXIT" ]]; then
		return 0
	fi

	dur="${dur:-20}"

	echo
	echo -e "${YE} = = > This Creates PILOT_RESCUE_* Sample Files Only.${NC}"
	echo

	if ! ask_yes_no " = = > Create Rescue Pilot Samples? (y/n or 1/2): "; then
		echo -e "${YE} = = > Rescue Pilot Cancelled.${NC}"
		pause
		return 0
	fi

	PILOT_MODE=1
	pilot_begin_session "RESCUE"
	pilot_register_restore_point "$src" "RESCUE_PILOT_SOURCE"

	for profile in "${profiles[@]}"; do
		out="$(avi_rescue_output_name "$src" "$profile" 1)"
		avi_rescue_run_profile "$src" "$profile" "$out" "$start" "$dur" || true
	done

	echo
	echo -e "${GR} = = > Rescue Pilot Samples Complete.${NC}"
	echo -e "${CYAN} = = > Review PILOT_RESCUE_* files in your player.${NC}"
	echo

	if ask_yes_no " = = > Keep Pilot Samples For Review? (y/n or 1/2): "; then
		pilot_commit_session
	else
		pilot_redo_session
	fi

	PILOT_MODE=0
	pause
}

run_avi_rescue_batch_same_profile() {
	local -a targets=()
	local profile total current file out
	local rescue_run_dir

	avi_rescue_collect_sources targets

	if ((${#targets[@]} == 0)); then
		echo
		echo -e "${YE} = = > No Eligible LEGACY / Dirty Video Rescue Targets Found.${NC}"
		echo
		pause
		return 0
	fi

	if ! limit_targets_interactive targets; then
		echo -e "${YE} = = > Rescue Batch Cancelled.${NC}"
		pause
		return 0
	fi

	if ! avi_rescue_pick_profile profile; then
		pause
		return 0
	fi

	echo
	echo -e "${YE} = = > Batch Rescue Creates RESCUE_${profile}_*.mkv Outputs.${NC}"
	echo -e "${YE} = = > Originals Are Left In Place.${NC}"
	echo -e "${CYAN} = = > Targets:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo

	if ! ask_yes_no " = = > Run Batch Rescue Now? (y/n or 1/2): "; then
		echo -e "${YE} = = > Rescue Batch Cancelled.${NC}"
		pause
		return 0
	fi

	rescue_run_dir="OEM/RESCUE/run_$(date '+%Y%m%d_%H%M%S')"
	mkdir -p "$rescue_run_dir"

	total="${#targets[@]}"
	current=0

	for file in "${targets[@]}"; do
		((current+=1)) || :
		out="$(avi_rescue_output_name "$file" "$profile" 0)"

		echo
		echo -e "${CYAN}[${current} / ${total}] RESCUE TARGET:${NC} ${GREEN}$file${NC}"

		if avi_rescue_run_profile "$file" "$profile" "$out"; then
			printf '%s,%s,%s,%s,%s\n' \
				"$(csv_escape "$(date '+%Y-%m-%d_%H%M%S')")" \
				"$(csv_escape "$file")" \
				"$(csv_escape "$profile")" \
				"$(csv_escape "$out")" \
				"$(csv_escape "OK")" >> "$rescue_run_dir/avi_rescue_history.csv"
		else
			printf '%s,%s,%s,%s,%s\n' \
				"$(csv_escape "$(date '+%Y-%m-%d_%H%M%S')")" \
				"$(csv_escape "$file")" \
				"$(csv_escape "$profile")" \
				"$(csv_escape "$out")" \
				"$(csv_escape "FAILED")" >> "$rescue_run_dir/avi_rescue_history.csv"
		fi
	done

	echo
	echo -e "${GR} = = > Batch Rescue Pass Complete.${NC}"
	echo -e "${CYAN} = = > Run Ledger:${NC} ${YELLOW}$rescue_run_dir/avi_rescue_history.csv${NC}"
	echo
	pause
}


# ================================================================
# #MARKER: VIDEO RESCUE PROFILES
# ================================================================
# PURPOSE:
# - Repair Difficult Video Sources.
# - Rebuild Containers, Timestamps, Or Streams.
# - Recover Files That Refuse Normal Processing.
# - Create SmartCut-Friendly Sources When Needed.
#
# COMMON RECOVERY TARGETS:
# - Broken AVI Containers
# - Problematic HEVC Sources
# - Timestamp Damage
# - Field Order Issues
# - Decoder Compatibility Problems
# ================================================================


run_avi_rescue_menu() {
	local choice

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}       LEGACY / DIRTY VIDEO RESCUE MENU         ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YE} = = > Repair Difficult Video Sources Or Decoder Compatibility Problems${NC}"
		echo -e "${YE} = = > Rebuild Containers, Timestamps, Or Streams.${NC}"
		echo -e "${YE} = = > Recover Files That Refuse Normal Processing.${NC}"
		echo -e "${YE} = = > Create SmartCut-Friendly Sources When Needed.${NC}"
		echo -e "${YE} = = > SMC-Opz needs 200ish second clip for a 3 cut test.${NC}"
		echo -e "${YE} = = > No Miracle Switch. This is a Controlled Attempt Ladder.${NC}"
		echo -e "${YE} = = > Try x-Second Pilot Samples First. For Direct Comparison  ${NC}"
		echo
		echo -e "${YELLOW}     1) One File Rescue — Choose One Profile${NC}"
		echo -e "${YELLOW}     2) Pilot Samples — One File / All Profiles${NC}"
		echo -e "${YELLOW}     3) Batch Rescue — Same Profile On Picked Files${NC}"
		echo -e "${YELLOW}     4) Video Truth Probe${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo

		prompt_menu_choice " = = > Select Rescue Option [1-4 | 0.=return]: " choice

		if is_exit_token "$choice"; then
			return 0
		fi

		case "$choice" in
			1) run_avi_rescue_one_file_full ;;
			2) run_avi_rescue_pilot_samples ;;
			3) run_avi_rescue_batch_same_profile ;;
			4) run_video_truth_probe_menu ;;
			*)
				echo -e "${REB} = = > Invalid Rescue Selection.${NC}"
				pause
				;;
		esac
	done
}

	remove_pilot_outputs_for_current_map() {
		local map="${1:-$INTRO_MAP}"
		local raw working out_raw out_working

		[[ -f "$map" ]] || return 0

		echo -e "${CYAN} = = > Cleaning Pilot Outputs For Current Map...${NC}"

		while IFS=',' read -r raw _rest; do
			[[ -z "${raw:-}" ]] && continue
			[[ "$raw" == "filename" ]] && continue

			# ========================================================
			# RAW-NAME OUTPUT
			# --------------------------------------------------------
			# Pilot outputs may have been built directly from the raw
			# filename if no preferred working-source redirection was
			# used during the prior run.
			# ========================================================
			out_raw="$(safe_out_name "$raw")"

			if [[ -f "$out_raw" ]]; then
				rm -f -- "$out_raw"
				echo -e "${GREEN} = = > Removed:${NC} $out_raw"
			fi

			# ========================================================
			# WORKING-SOURCE / REKEY OUTPUT
			# --------------------------------------------------------
			# SMARTGAP may internally switch from raw file identity to a
			# preferred working source such as REKEY_<name>.mkv before
			# output naming happens.
			#
			# If so, the existing pilot output may be named from that
			# working source, not from the raw filename in intro_map.
			# ========================================================
			working="$(get_preferred_source_file "$raw" 2>/dev/null || printf '%s\n' "$raw")"

			if [[ -n "${working:-}" && "$working" != "$raw" ]]; then
				out_working="$(safe_out_name "$working")"

				if [[ -f "$out_working" ]]; then
					rm -f -- "$out_working"
					echo -e "${GREEN} = = > Removed:${NC} $out_working"
				fi
			fi
		done < "$map"

		echo
	}

# ========================================================
# #MARKER: GENERIC PLAYLIST RESOLUTION / REPAIR FOUNDATION
# ========================================================
# PURPOSE:
# - Shared local .m3u / .m3u8 reader and repair planner
# - Preserve playlist order, comments, blank lines, and path style
# - Build a report before any playlist is changed
# - Apply only exact SAFE rows approved by the user
# - Remain neutral so rename, AudioLevel, and future tools can reuse it
# ========================================================

playlist_is_supported_file() {
	local file="${1:-}"
	local ext="${file##*.}"
	ext="${ext,,}"
	[[ "$ext" == "m3u" || "$ext" == "m3u8" ]]
}

playlist_reference_is_remote() {
	local ref="${1:-}"
	[[ "$ref" =~ ^[A-Za-z][A-Za-z0-9+.-]*:// ]]
}

playlist_resolve_reference() {
	local playlist="$1"
	local ref="$2"
	local playlist_dir

	playlist_dir="$(dirname "$playlist")"

	if [[ "$ref" == /* ]]; then
		if have_cmd realpath; then
			realpath -m -- "$ref" 2>/dev/null || printf '%s\n' "$ref"
		else
			printf '%s\n' "$ref"
		fi
	else
		if have_cmd realpath; then
			realpath -m -- "$playlist_dir/$ref" 2>/dev/null || printf '%s/%s\n' "$playlist_dir" "$ref"
		else
			printf '%s/%s\n' "$playlist_dir" "$ref"
		fi
	fi
}

playlist_relative_reference() {
	local playlist="$1"
	local target="$2"
	local playlist_dir

	playlist_dir="$(dirname "$playlist")"

	if have_cmd realpath; then
		realpath --relative-to="$playlist_dir" -- "$target" 2>/dev/null || printf '%s\n' "$(basename "$target")"
	else
		printf '%s\n' "$(basename "$target")"
	fi
}

playlist_backup_path() {
	local scan_root="$1"
	local run_dir="$2"
	local playlist="$3"
	local rel backup

	rel="${playlist#"$scan_root"/}"
	[[ "$rel" == "$playlist" ]] && rel="$(basename "$playlist")"

	backup="$run_dir/OLD_PLAYLISTS/$rel"
	mkdir -p "$(dirname "$backup")"
	printf '%s\n' "$backup"
}

playlist_build_repair_plan() {
	local scan_root="$1"
	local run_dir="$2"
	local mapping_file="$3"
	local plan_file="$run_dir/playlist_repair_plan.csv"
	local playlist line clean_ref resolved_ref old_path new_path
	local new_ref match_type status notes line_number
	local safe_count=0 review_count=0 playlist_count=0

	printf '%s\n' 'PLAYLIST|LINE|MATCH_TYPE|OLD_REF|NEW_REF|STATUS|NOTES' > "$plan_file"
	[[ -f "$mapping_file" ]] || return 0

	while IFS= read -r -d '' playlist; do
		playlist_is_supported_file "$playlist" || continue
		((playlist_count+=1)) || :
		line_number=0

		while IFS= read -r line || [[ -n "$line" ]]; do
			((line_number+=1)) || :
			line="${line%$'\r'}"
			clean_ref="$line"

			[[ -z "$clean_ref" || "$clean_ref" == \#* ]] && continue
			playlist_reference_is_remote "$clean_ref" && continue
			resolved_ref="$(playlist_resolve_reference "$playlist" "$clean_ref")"

			while IFS='|' read -r old_path new_path; do
				[[ -z "${old_path:-}" || -z "${new_path:-}" ]] && continue

				match_type=""
				status=""
				notes=""

				if [[ "$clean_ref" == "$old_path" || "$resolved_ref" == "$old_path" ]]; then
					match_type="EXACT_PATH"
					status="SAFE"
					notes="exact old path mapping"
				elif [[ "$clean_ref" == "$(basename "$old_path")" ]]; then
					match_type="EXACT_BASENAME"
					status="SAFE"
					notes="playlist entry is exact old basename"
				else
					continue
				fi

				if [[ "$clean_ref" == /* ]]; then
					new_ref="$new_path"
				else
					new_ref="$(playlist_relative_reference "$playlist" "$new_path")"
				fi

				if [[ "$new_ref" == "$clean_ref" ]]; then
					continue
				fi

				printf '%s|%s|%s|%s|%s|%s|%s\n' \
					"$playlist" "$line_number" "$match_type" "$clean_ref" "$new_ref" "$status" "$notes" >> "$plan_file"
				((safe_count+=1)) || :
			done < "$mapping_file"
		done < "$playlist"
	done < <(find "$scan_root" -type f \( -iname '*.m3u' -o -iname '*.m3u8' \) -print0 2>/dev/null)

	echo -e "${CYAN} = = > Playlist Files Examined:${NC} ${YELLOW}$playlist_count${NC}"
	echo -e "${CYAN} = = > Safe Playlist Repairs:${NC} ${YELLOW}$safe_count${NC}"
	echo -e "${CYAN} = = > Playlist Repair Plan:${NC} ${GREEN}$(trim_working_path_display "$plan_file" 3)${NC}"
}

playlist_write_repair_report() {
	local run_dir="$1"
	local plan_file="$run_dir/playlist_repair_plan.csv"
	local report_file="$run_dir/playlist_repair_report.txt"
	local playlist line_number match_type old_ref new_ref status notes
	local safe_count=0 review_count=0

	{
		echo '================================================'
		echo '        PLAYLIST REPAIR REVIEW REPORT'
		echo '================================================'
		echo "Generated: $(date)"
		echo
		echo "Repair Plan:"
		echo " $plan_file"
		echo
	} > "$report_file"

	if [[ ! -f "$plan_file" ]]; then
		echo 'No playlist repair plan found.' >> "$report_file"
		return 0
	fi

	while IFS='|' read -r playlist line_number match_type old_ref new_ref status notes; do
		[[ "$playlist" == 'PLAYLIST' ]] && continue
		[[ -z "${playlist:-}" ]] && continue

		[[ "$status" == 'SAFE' ]] && ((safe_count+=1)) || ((review_count+=1))

		{
			echo "PLAYLIST: $playlist"
			echo "LINE:     $line_number"
			echo "MATCH:    $match_type"
			echo "STATUS:   $status"
			echo "OLD REF:  $old_ref"
			echo "NEW REF:  $new_ref"
			echo "NOTES:    $notes"
			echo '------------------------------------------------'
		} >> "$report_file"
	done < "$plan_file"

	{
		echo
		echo '================================================'
		echo 'SUMMARY'
		echo '================================================'
		echo "Safe Repairs:   $safe_count"
		echo "Needs Review:   $review_count"
		echo
		echo 'Original playlists are not changed during planning.'
		echo 'Execution backs up each touched playlist first.'
	} >> "$report_file"

	echo -e "${CYAN} = = > Playlist Repair Report:${NC} ${GREEN}$report_file${NC}"
}

playlist_apply_repair_plan() {
	local scan_root="$1"
	local run_dir="$2"
	local plan_file="$run_dir/playlist_repair_plan.csv"
	local exec_log="$run_dir/playlist_repair_execute_log.csv"
	local undo_map="$run_dir/playlist_repair_undo_map.csv"
	local playlist line_number match_type old_ref new_ref status notes
	local backup tmp_file current_line replacement_done
	local repaired=0 skipped=0 failed=0
	local -A touched_playlists=()

	[[ -f "$plan_file" ]] || {
		echo -e "${YE} = = > No Playlist Repair Plan Found.${NC}"
		pause
		return 0
	}

	echo
	echo -e "${YE} = = > Only Rows Marked SAFE Will Be Applied.${NC}"
	echo -e "${YE} = = > Original Playlists Will Be Backed Up First.${NC}"
	echo

	if ! ask_yes_no ' = = > Execute Safe Playlist Repairs? (y/n or 1/2): '; then
		echo -e "${YE} = = > Playlist Repair Cancelled.${NC}"
		pause
		return 0
	fi

	printf '%s\n' 'STATUS|PLAYLIST|LINE|BACKUP|MATCH_TYPE|OLD_REF|NEW_REF|NOTES' > "$exec_log"
	: > "$undo_map"

	while IFS='|' read -r playlist line_number match_type old_ref new_ref status notes; do
		[[ "$playlist" == 'PLAYLIST' ]] && continue
		[[ -z "${playlist:-}" ]] && continue
		[[ "$status" == 'SAFE' ]] || { ((skipped+=1)) || :; continue; }

		if [[ ! -f "$playlist" ]]; then
			printf '%s|%s|%s|%s|%s|%s|%s|%s\n' 'SKIPPED_MISSING_PLAYLIST' "$playlist" "$line_number" '' "$match_type" "$old_ref" "$new_ref" 'playlist missing' >> "$exec_log"
			((skipped+=1)) || :
			continue
		fi

		if [[ -z "${touched_playlists[$playlist]:-}" ]]; then
			backup="$(playlist_backup_path "$scan_root" "$run_dir" "$playlist")"
			if ! cp -- "$playlist" "$backup"; then
				printf '%s|%s|%s|%s|%s|%s|%s|%s\n' 'FAILED_BACKUP' "$playlist" "$line_number" "$backup" "$match_type" "$old_ref" "$new_ref" 'backup failed' >> "$exec_log"
				((failed+=1)) || :
				continue
			fi
			printf '%s|%s\n' "$playlist" "$backup" >> "$undo_map"
			touched_playlists["$playlist"]="$backup"
		fi

		tmp_file="${playlist}.repair_tmp_$$"
		replacement_done=0
		current_line=0
		: > "$tmp_file"

		while IFS= read -r line || [[ -n "$line" ]]; do
			((current_line+=1)) || :
			line="${line%$'\r'}"
			if (( current_line == line_number )) && [[ "$line" == "$old_ref" ]]; then
				printf '%s\n' "$new_ref" >> "$tmp_file"
				replacement_done=1
			else
				printf '%s\n' "$line" >> "$tmp_file"
			fi
		done < "$playlist"

		if (( replacement_done == 1 )); then
			if mv -- "$tmp_file" "$playlist"; then
				printf '%s|%s|%s|%s|%s|%s|%s|%s\n' 'REPAIRED' "$playlist" "$line_number" "${touched_playlists[$playlist]}" "$match_type" "$old_ref" "$new_ref" 'ok' >> "$exec_log"
				((repaired+=1)) || :
			else
				rm -f -- "$tmp_file"
				((failed+=1)) || :
			fi
		else
			rm -f -- "$tmp_file"
			printf '%s|%s|%s|%s|%s|%s|%s|%s\n' 'SKIPPED_LINE_CHANGED' "$playlist" "$line_number" "${touched_playlists[$playlist]}" "$match_type" "$old_ref" "$new_ref" 'planned line no longer matches' >> "$exec_log"
			((skipped+=1)) || :
		fi
	done < "$plan_file"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        PLAYLIST REPAIR SUMMARY                 ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Repaired References:${NC} ${YELLOW}$repaired${NC}"
	echo -e "${CYAN} = = > Skipped:${NC} ${YELLOW}$skipped${NC}"
	echo -e "${CYAN} = = > Failed:${NC} ${YELLOW}$failed${NC}"
	echo -e "${CYAN} = = > Backups:${NC} ${GREEN}$run_dir/OLD_PLAYLISTS${NC}"
	echo -e "${CYAN} = = > Execute Log:${NC} ${GREEN}$exec_log${NC}"
	echo
	pause
}

playlist_undo_repairs() {
	local run_dir="$1"
	local undo_map="$run_dir/playlist_repair_undo_map.csv"
	local playlist backup
	local restored=0 skipped=0

	[[ -f "$undo_map" ]] || {
		echo -e "${YE} = = > No Playlist Repair Undo Map Found.${NC}"
		pause
		return 0
	}

	if ! ask_yes_no ' = = > Restore Playlists From Backups? (y/n or 1/2): '; then
		return 0
	fi

	while IFS='|' read -r playlist backup; do
		[[ -z "${playlist:-}" || -z "${backup:-}" ]] && continue
		if [[ -f "$backup" ]]; then
			cp -- "$backup" "$playlist"
			((restored+=1)) || :
		else
			((skipped+=1)) || :
		fi
	done < "$undo_map"

	echo -e "${GR} = = > Playlist Undo Complete.${NC}"
	echo -e "${CYAN} = = > Restored:${NC} ${YELLOW}$restored${NC}"
	echo -e "${CYAN} = = > Skipped:${NC} ${YELLOW}$skipped${NC}"
	pause
}

# ========================================================
# #MARKER: COLLECTION DETOX PLAYLIST REPAIR EXECUTION
# ========================================================
collection_detox_playlist_backup_path() {
	playlist_backup_path "$@"
}

collection_detox_write_playlist_repair_report() {
	playlist_write_repair_report "$@"
}

collection_detox_execute_playlist_repairs() {
	playlist_apply_repair_plan "$@"
}

collection_detox_undo_playlist_repairs() {
	playlist_undo_repairs "$@"
}


collection_detox_execute_plan() {
	local run_dir="$1"
	local scan_root="$2"
	local plan_file="$run_dir/detox_plan.csv"
	local exec_log="$run_dir/detox_execute_log.csv"
	local success_map="$run_dir/detox_successful_renames.map"

	local status old_path new_path source reason notes
	local total_pending=0 executed=0 skipped=0 failed=0
	local dir folder_count=0 recommended_mode="NORMAL"
	local choice folder_choice remaining_no_pause=0
	local current_dir="" row_dir
	local -A folder_counts=()
	local -a folder_order=()

	[[ -f "$plan_file" ]] || {
		echo -e "${REB} = = > Missing Plan:${NC} ${YELLOW}$plan_file${NC}"
		pause
		return 1
	}

	# --------------------------------------------------------
	# ANALYZE PLAN SCOPE
	# --------------------------------------------------------
	while IFS='|' read -r status old_path new_path source reason notes; do
		[[ "$status" == "STATUS" ]] && continue
		[[ "$status" == "PENDING" ]] || continue

		((total_pending+=1)) || :

		dir="$(dirname "$old_path")"

		if [[ -z "${folder_counts[$dir]:-}" ]]; then
			folder_order+=("$dir")
			folder_counts["$dir"]=0
		fi

		((folder_counts["$dir"]+=1)) || :
	done < "$plan_file"

	folder_count="${#folder_order[@]}"

	if (( total_pending == 0 )); then
		echo -e "${YE} = = > No Pending Renames Found In Plan.${NC}"
		pause
		return 0
	fi

	if (( total_pending > 75 && folder_count > 1 )); then
		recommended_mode="COLLECTION"
	elif (( total_pending > 50 && folder_count > 1 )); then
		recommended_mode="LARGE"
	else
		recommended_mode="NORMAL"
	fi

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}        COLLECTION DETOX :: EXECUTE PLAN        ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${CYAN} = = > Plan:${NC} ${GREEN}$(trim_working_path_display "$plan_file" 3)${NC}"
		echo -e "${CYAN} = = > Pending Renames:${NC} ${YELLOW}$total_pending${NC}"
		echo -e "${CYAN} = = > Folders With Renames:${NC} ${YELLOW}$folder_count${NC}"
		echo -e "${CYAN} = = > Recommended Mode:${NC} ${YELLOW}$recommended_mode${NC}"
		echo
		echo -e "${CYAN} = = > Folder Groups:${NC}"
		for dir in "${folder_order[@]}"; do
			echo -e "${YELLOW}     ${folder_counts[$dir]}${NC} ${GREEN}$(trim_working_path_display "$dir" 3)${NC}"
		done
		echo
		echo -e "  ${YELLOW}1)= = > Execute Recommended Mode${NC}"
		echo -e "  ${YELLOW}2)= = > Execute All Pending Renames Now${NC}"
		echo -e "  ${YELLOW}3)= = > Execute Folder-By-Folder${NC}"
		echo -e "  ${YELLOW}4)= = > Undo Successful Renames From This Run${NC}"
		echo -e "  ${YELLOW}0.) Return${NC}"
		echo
		echo -ne "${YELLOW} = = > Select Option: ${NC}${GREEN}"
		read -r choice
		echo -e "${NC}"

		if is_exit_token "$choice"; then
			return 0
		fi

		case "$choice" in
			1)
				if [[ "$recommended_mode" == "NORMAL" ]]; then
					choice="2"
				else
					choice="3"
				fi
				;;

			2|3|4)
				:
				;;

			*)
				echo -e "${YE} = = > Invalid Selection.${NC}"
				pause
				continue
				;;
		esac

		break
	done

	# --------------------------------------------------------
	# UNDO MODE
	# --------------------------------------------------------
	if [[ "$choice" == "4" ]]; then
		[[ -f "$success_map" ]] || {
			echo -e "${YE} = = > No Successful Rename Map Found For This Run.${NC}"
			pause
			return 0
		}

		echo
		echo -e "${YE} = = > This Will Rename Files Back Using:${NC}"
		echo -e "${GREEN} $(trim_working_path_display "$success_map" 3)${NC}"
		echo

		if ! ask_yes_no " = = > Undo Successful Renames From This Run? (y/n or 1/2): "; then
			echo -e "${YE} = = > Undo Cancelled.${NC}"
			pause
			return 0
		fi

		while IFS='|' read -r old_path new_path; do
			[[ -z "${old_path:-}" || -z "${new_path:-}" ]] && continue

			if [[ ! -e "$new_path" ]]; then
				echo -e "${YE} = = > [UNDO SKIP MISSING]${NC} ${YELLOW}$(trim_working_path_display "$new_path" 3)${NC}"
				continue
			fi

			if [[ -e "$old_path" ]]; then
				echo -e "${YE} = = > [UNDO SKIP EXISTS]${NC} ${YELLOW}$(trim_working_path_display "$old_path" 3)${NC}"
				continue
			fi

			echo -e "${GREEN} = = > [UNDO]${NC} ${YELLOW}$(trim_working_path_display "$new_path" 3)${NC}"
			echo -e "${CYAN}        -->${NC} ${GREEN}$(trim_working_path_display "$old_path" 3)${NC}"
			mv -- "$new_path" "$old_path"
		done < "$success_map"

		echo
		echo -e "${GR} = = > Undo Complete.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${YE} = = > Playlist Files Are Not Modified During Rename Execution.${NC}"
	echo -e "${YE} = = > Execute Log And Undo Map Will Be Written In Run Folder.${NC}"
	echo

	if ! ask_yes_no " = = > Begin Rename Execution? (y/n or 1/2): "; then
		echo -e "${YE} = = > Execute Cancelled.${NC}"
		pause
		return 0
	fi

	printf '%s\n' "STATUS|OLD_PATH|NEW_PATH|SOURCE|REASON|NOTES" > "$exec_log"
	: > "$success_map"

	# --------------------------------------------------------
	# FULL EXECUTE MODE
	# --------------------------------------------------------
	if [[ "$choice" == "2" ]]; then
		while IFS='|' read -r status old_path new_path source reason notes; do
			[[ "$status" == "STATUS" ]] && continue
			[[ "$status" == "PENDING" ]] || continue

			if [[ ! -e "$old_path" ]]; then
				printf '%s|%s|%s|%s|%s|%s\n' \
					"SKIPPED_MISSING_SOURCE" "$old_path" "$new_path" "$source" "SOURCE_MISSING" "$notes" >> "$exec_log"
				((skipped+=1)) || :
				continue
			fi

			if [[ -e "$new_path" ]]; then
				printf '%s|%s|%s|%s|%s|%s\n' \
					"SKIPPED_TARGET_EXISTS" "$old_path" "$new_path" "$source" "TARGET_EXISTS" "$notes" >> "$exec_log"
				((skipped+=1)) || :
				continue
			fi

			echo -e "${GREEN} = = > [RENAMING]${NC} ${YELLOW}$(trim_working_path_display "$old_path" 3)${NC}"
			echo -e "${CYAN}        -->${NC} ${GREEN}$(trim_working_path_display "$new_path" 3)${NC}"

			if mv -- "$old_path" "$new_path"; then
				printf '%s|%s|%s|%s|%s|%s\n' \
					"RENAMED" "$old_path" "$new_path" "$source" "OK" "$notes" >> "$exec_log"
				printf '%s|%s\n' "$old_path" "$new_path" >> "$success_map"
				((executed+=1)) || :
			else
				printf '%s|%s|%s|%s|%s|%s\n' \
					"FAILED" "$old_path" "$new_path" "$source" "MV_FAILED" "$notes" >> "$exec_log"
				((failed+=1)) || :
			fi
		done < "$plan_file"
	fi

	# --------------------------------------------------------
	# FOLDER-BY-FOLDER EXECUTE MODE
	# --------------------------------------------------------
	if [[ "$choice" == "3" ]]; then
		for current_dir in "${folder_order[@]}"; do
			if (( remaining_no_pause == 0 )); then
				clear
				echo -e "${CYAN}================================================${NC}"
				echo -e "${CYAN}      COLLECTION DETOX :: FOLDER EXECUTION      ${NC}"
				echo -e "${CYAN}================================================${NC}"
				echo
				echo -e "${CYAN} = = > Folder:${NC}"
				echo -e "${GREEN}$(trim_working_path_display "$current_dir" 3)${NC}"
				echo
				echo -e "${CYAN} = = > Pending In Folder:${NC} ${YELLOW}${folder_counts[$current_dir]}${NC}"
				echo
				echo -e "  ${YELLOW}1)= = > Execute This Folder${NC}"
				echo -e "  ${YELLOW}2)= = > Skip This Folder${NC}"
				echo -e "  ${YELLOW}3)= = > Execute This And All Remaining Folders Without Pauses${NC}"
				echo -e "  ${YELLOW}0.) Stop Execution${NC}"
				echo
				echo -ne "${YELLOW} = = > Select Option: ${NC}${GREEN}"
				read -r folder_choice
				echo -e "${NC}"

				if is_exit_token "$folder_choice"; then
					break
				fi

				case "$folder_choice" in
					1)
						:
						;;
					2)
						echo -e "${YE} = = > Folder Skipped:${NC} ${YELLOW}$current_dir${NC}"
						pause
						continue
						;;
					3)
						remaining_no_pause=1
						;;
					*)
						echo -e "${YE} = = > Invalid Selection. Folder Skipped.${NC}"
						pause
						continue
						;;
				esac
			fi

			while IFS='|' read -r status old_path new_path source reason notes; do
				[[ "$status" == "STATUS" ]] && continue
				[[ "$status" == "PENDING" ]] || continue

				row_dir="$(dirname "$old_path")"
				[[ "$row_dir" == "$current_dir" ]] || continue

				if [[ ! -e "$old_path" ]]; then
					printf '%s|%s|%s|%s|%s|%s\n' \
						"SKIPPED_MISSING_SOURCE" "$old_path" "$new_path" "$source" "SOURCE_MISSING" "$notes" >> "$exec_log"
					((skipped+=1)) || :
					continue
				fi

				if [[ -e "$new_path" ]]; then
					printf '%s|%s|%s|%s|%s|%s\n' \
						"SKIPPED_TARGET_EXISTS" "$old_path" "$new_path" "$source" "TARGET_EXISTS" "$notes" >> "$exec_log"
					((skipped+=1)) || :
					continue
				fi

				echo -e "${GREEN} = = > [RENAMING]${NC} ${YELLOW}$(trim_working_path_display "$old_path" 3)${NC}"
				echo -e "${CYAN}        -->${NC} ${GREEN}$(trim_working_path_display "$new_path" 3)${NC}"

				if mv -- "$old_path" "$new_path"; then
					printf '%s|%s|%s|%s|%s|%s\n' \
						"RENAMED" "$old_path" "$new_path" "$source" "OK" "$notes" >> "$exec_log"
					printf '%s|%s\n' "$old_path" "$new_path" >> "$success_map"
					((executed+=1)) || :
				else
					printf '%s|%s|%s|%s|%s|%s\n' \
						"FAILED" "$old_path" "$new_path" "$source" "MV_FAILED" "$notes" >> "$exec_log"
					((failed+=1)) || :
				fi
			done < "$plan_file"

			if (( remaining_no_pause == 0 )); then
				echo
				echo -e "${GR} = = > Folder Complete:${NC} ${YELLOW}$(trim_working_path_display "$current_dir" 3)${NC}"
				pause
			fi
		done
	fi

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        COLLECTION DETOX EXECUTION SUMMARY      ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Renamed:${NC} ${YELLOW}$executed${NC}"
	echo -e "${CYAN} = = > Skipped:${NC} ${YELLOW}$skipped${NC}"
	echo -e "${CYAN} = = > Failed:${NC} ${YELLOW}$failed${NC}"
	echo -e "${CYAN} = = > Execute Log:${NC} ${GREEN}$(trim_working_path_display "$exec_log" 3)${NC}"
	echo -e "${CYAN} = = > Undo Map:${NC} ${GREEN}$(trim_working_path_display "$success_map" 3)${NC}"
	echo

	collection_detox_build_playlist_repair_plan "$scan_root" "$run_dir" "$success_map"

	pause
}

collection_detox_titlecase_words() {
	local raw="${1:-}"

	printf '%s\n' "$raw" \
		| awk -F'_' '{
			out=""
			for (i=1; i<=NF; i++) {
				if ($i == "") continue

				word=$i
				upper=toupper(word)

				# Preserve Factory workflow prefix tokens.
				if ((i == 1 || (i == 2 && out == "PILOT")) &&
					upper ~ /^(SMC|REKEY|BARFIX|SUBTOX|SUBPACKED|ARCHIVE|RESCUE|PILOT|TIPSNIP|TAILTUCK|OEM)$/) {
					word=upper

				# Preserve / normalize episode tokens.
				} else if (word ~ /^[Ss][0-9][0-9][Ee][0-9][0-9](-[Ee]?[0-9][0-9])*$/) {
					gsub(/^s/, "S", word)
					gsub(/e/, "E", word)

				# Preserve Part tokens.
				} else if (word ~ /^[Pp][Aa][Rr][Tt](-?[0-9]+|[IVXivx]+)$/) {
					suffix=toupper(substr(word,5))
					word="Part" suffix

				} else if (word ~ /^[Ee][0-9][0-9]$/) {
					gsub(/^e/, "E", word)

				} else {
					word=tolower(word)
					word=toupper(substr(word,1,1)) substr(word,2)
				}

				out = (out == "" ? word : out "_" word)
			}
			print out
		}' \
		| sed -E \
			-e 's/-[Pp][Aa][Rr][Tt]-?([0-9]+)/-Part\1/g' \
			-e 's/-[Pp][Aa][Rr][Tt]-?(i|ii|iii|iv|I|II|III|IV)(_|$)/-Part\U\1\E\2/g'
}

# ========================================================
# #MARKER: COLLECTION DETOX ENGINE V1
# ========================================================
# PURPOSE:
# - Recursive large-folder filename naming/detox scanner
# - Uses existing detox_title()
# - Recognizes and normalizes SxxExx
# - Uses exact-name episodes.csv as optional naming authority
# - Detects playlist impact
# - Writes plan + human report
# - DOES NOT RENAME FILES YET
# ========================================================

collection_detox_make_run_dir() {
	local root="${1:-COLLECTION_DETOX}"
	local run_id

	run_id="$(date '+%Y%m%d_%H%M%S')"

	mkdir -p "$root/$run_id"

	printf '%s\n' "$root/$run_id"
}

collection_detox_find_files() {
	local scan_root="$1"

	find "$scan_root" \
		\( -path "$scan_root/reports/COLLECTION_DETOX" -o \
		   -path "$scan_root/reports/COLLECTION_DETOX/*" -o \
		   -path "$scan_root/TOOLBOX" -o \
		   -path "$scan_root/TOOLBOX/*" \) -prune -o \
		-type f -print0 \
		| LC_ALL=C sort -z
}

collection_detox_is_supported_media_file() {
	local f="${1:-}"
	local ext="${f##*.}"
	ext="${ext,,}"

	case "$ext" in
		mkv|mp4|avi|m4v|mov|webm|mpg|mpeg|ts|ogv|flv|3gp|divx|xvid|wmv|lrv|srt|ass|ssa|sub|idx|nfo|txt)
			return 0
			;;
	esac

	return 1
}

collection_detox_is_playlist_file() {
	local f="${1:-}"
	local ext="${f##*.}"
	ext="${ext,,}"

	case "$ext" in
		m3u|m3u8)
			return 0
			;;
	esac

	return 1
}

collection_detox_extract_epcode() {
	local s="${1:-}"
	local season episode

	if [[ "$s" =~ [sS]([0-9]{1,2})[eE]([0-9]{1,3}) ]]; then
		season="$((10#${BASH_REMATCH[1]}))"
		episode="$((10#${BASH_REMATCH[2]}))"
		printf 'S%02dE%02d\n' "$season" "$episode"
		return 0
	fi

	return 1
}

collection_detox_normalize_sxxexx_in_stem() {
	local stem="${1:-}"
	local prefix suffix season episode ep_code

	if [[ "$stem" =~ ^(.*)[sS]([0-9]{1,2})[eE]([0-9]{1,3})(.*)$ ]]; then
		prefix="${BASH_REMATCH[1]}"
		season="$((10#${BASH_REMATCH[2]}))"
		episode="$((10#${BASH_REMATCH[3]}))"
		suffix="${BASH_REMATCH[4]}"

		printf -v ep_code 'S%02dE%02d' "$season" "$episode"
		printf '%s%s%s\n' "$prefix" "$ep_code" "$suffix"
		return 0
	fi

	printf '%s\n' "$stem"
}

collection_detox_build_show_prefix() {
	local stem="${1:-}"
	local prefix

	prefix="$stem"

	if [[ "$prefix" =~ ^(.*)[sS][0-9]{1,2}[eE][0-9]{1,3}.*$ ]]; then
		prefix="${BASH_REMATCH[1]}"
	fi

	prefix="${prefix%"${prefix##*[!_ .-]}"}"
	prefix="$(detox_title "$prefix")"
	prefix="$(collection_detox_titlecase_words "$prefix")"
	prefix="${prefix%_}"

	if [[ -z "$prefix" ]]; then
		prefix="$(basename "$PWD")"
		prefix="$(detox_title "$prefix")"
		prefix="$(collection_detox_titlecase_words "$prefix")"
	fi

	printf '%s\n' "$prefix"
}

collection_detox_parse_episode_authority_row() {
	local line="$1"
	local __ep_var="$2"
	local __title_var="$3"

	local raw_ep="" raw_title=""
	local -a fields=()
	local old_ifs field clean_field ep_code idx title_start

	line="${line//$'\r'/}"
	line="$(printf '%s\n' "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

	[[ -z "${line//[[:space:]]/}" ]] && return 1

	# Header / comment skip
	case "${line,,}" in
		episode,*|ep,*|sxxexx,*|code,*|"#"?*)
			return 1
			;;
	esac

	# Dot-separated direct form:
	# S02E01.In.My.Time.Of.Dying
	if [[ "$line" =~ ^[Ss][0-9]{1,2}[Ee][0-9]{1,2}\. ]]; then
		raw_ep="${line%%.*}"
		raw_title="${line#*.}"
		raw_title="${raw_title//./ }"
	else
		# Prefer comma, then pipe, then tab.
		if [[ "$line" == *","* ]]; then
			old_ifs="$IFS"; IFS=','; read -r -a fields <<< "$line"; IFS="$old_ifs"
		elif [[ "$line" == *"|"* ]]; then
			old_ifs="$IFS"; IFS='|'; read -r -a fields <<< "$line"; IFS="$old_ifs"
		elif [[ "$line" == *$'\t'* ]]; then
			old_ifs="$IFS"; IFS=$'\t'; read -r -a fields <<< "$line"; IFS="$old_ifs"
		else
			return 1
		fi

		# Find first field containing SxxExx.
		idx=-1
		for i in "${!fields[@]}"; do
			clean_field="${fields[$i]//\"/}"
			clean_field="${clean_field//[[:space:]]/}"

			if collection_detox_extract_epcode "$clean_field" >/dev/null 2>&1; then
				idx="$i"
				break
			fi
		done

		(( idx >= 0 )) || return 1

		raw_ep="${fields[$idx]}"
		title_start=$((idx + 1))

		# Title is everything after the episode field, rejoined with comma.
		raw_title=""
		for ((i=title_start; i<${#fields[@]}; i++)); do
			if [[ -z "$raw_title" ]]; then
				raw_title="${fields[$i]}"
			else
				raw_title="${raw_title},${fields[$i]}"
			fi
		done
	fi

	raw_ep="${raw_ep//\"/}"
	raw_ep="${raw_ep//[[:space:]]/}"

	raw_title="${raw_title%\"}"
	raw_title="${raw_title#\"}"
	raw_title="$(printf '%s\n' "$raw_title" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

	[[ -n "$raw_title" ]] || return 1

	ep_code="$(collection_detox_extract_epcode "$raw_ep" 2>/dev/null)" || return 1

	printf -v "$__ep_var" '%s' "$ep_code"
	printf -v "$__title_var" '%s' "$raw_title"
	return 0
}

collection_detox_load_episodes_csv() {
	local csv_file="$1"
	local -n _title_ref="$2"
	local -n _season_ref="$3"
	local -n _loaded_ref="$4"
	local -n _invalid_ref="$5"

	local line raw_title ep_code season
	local loaded=0 invalid=0 line_num=0

	[[ -f "$csv_file" ]] || return 1

	while IFS= read -r line || [[ -n "$line" ]]; do
		((line_num+=1)) || :

		line="${line//$'\r'/}"
		[[ -z "${line//[[:space:]]/}" ]] && continue

		if ! collection_detox_parse_episode_authority_row "$line" ep_code raw_title; then
			((invalid+=1)) || :
			continue
		fi

		season="${ep_code%%E*}"

		_title_ref["$ep_code"]="$raw_title"
		_season_ref["$season"]=1

		((loaded+=1)) || :
	done < "$csv_file"

	_loaded_ref="$loaded"
	_invalid_ref="$invalid"
	(( loaded > 0 ))
}

collection_detox_scan_build_plan() {
	local scan_root="$1"
	local run_dir="$2"
	local plan_file="$run_dir/detox_plan.csv"
	local report_file="$run_dir/detox_report.txt"
	local playlist_report="$run_dir/detox_playlist_impact.txt"

	local file dir base stem ext new_stem new_base new_path
	local ep_code season show_prefix raw_title detoxed_title
	local status reason notes source rules
	local csv_file csv_status="NOT_FOUND"
	local detected_show_prefix=""
	local scanned=0 unsupported=0 pending=0 exists_count=0 collision_count=0 detox_only=0 csv_matches=0 sxxexx_found=0
	local playlists_found=0 playlist_ref_hits=0
	local report_version="1"

	local csv_rows_loaded=0
	local csv_rows_rejected=0
	local -A csv_titles=()
	local -A csv_seasons=()
	local -A file_seasons=()
	local -A planned_targets=()
	local -A basename_rewrite_map=()

	local -a plan_rows=()
	local -a playlist_files=()
	local -a unsupported_files=()

	csv_file="$scan_root/episodes.csv"

	if [[ -f "$csv_file" ]]; then
		if collection_detox_load_episodes_csv \
			"$csv_file" \
			csv_titles \
			csv_seasons \
			csv_rows_loaded \
			csv_rows_rejected; then
			csv_status="ACCEPTED"
		else
			csv_status="REJECTED"
		fi
	fi

	printf '%s\n' "STATUS|OLD_PATH|NEW_PATH|SOURCE|REASON|NOTES" > "$plan_file"

	# --------------------------------------------------------
	# PASS 1: SCAN FILES AND BUILD SEASON SET
	# --------------------------------------------------------
	while IFS= read -r -d '' file; do
		collection_detox_is_playlist_file "$file" && {
			playlist_files+=("$file")
			((playlists_found+=1)) || :
			continue
		}

		collection_detox_is_supported_media_file "$file" || {
			((unsupported+=1)) || :
			unsupported_files+=("$file")
			continue
		}

		((scanned+=1)) || :

		base="$(basename "$file")"
		stem="${base%.*}"
		if [[ -z "$detected_show_prefix" ]]; then
			detected_show_prefix="$(collection_detox_build_show_prefix "$stem")"
		fi

		if ep_code="$(collection_detox_extract_epcode "$stem" 2>/dev/null)"; then
			season="${ep_code%%E*}"
			file_seasons["$season"]=1
			((sxxexx_found+=1)) || :
		fi
	done < <(collection_detox_find_files "$scan_root")

	# --------------------------------------------------------
	# PASS 2: BUILD PLAN
	# --------------------------------------------------------
	while IFS= read -r -d '' file; do
		collection_detox_is_playlist_file "$file" && continue
		collection_detox_is_supported_media_file "$file" || continue

		dir="$(dirname "$file")"
		base="$(basename "$file")"
		ext="${base##*.}"
		stem="${base%.*}"

		ep_code=""
		source="DETOX_ONLY"
		rules="detox applied"
		new_stem=""

		if ep_code="$(collection_detox_extract_epcode "$stem" 2>/dev/null)"; then
			season="${ep_code%%E*}"

			if [[ "$csv_status" == "ACCEPTED" && -n "${csv_titles[$ep_code]:-}" && -n "${file_seasons[$season]:-}" ]]; then
				show_prefix="$(collection_detox_build_show_prefix "$stem")"
				raw_title="${csv_titles[$ep_code]}"

				# episodes.csv supplies title authority.
				# Factory detox still supplies filename style:
				# - safe characters
				# - underscores
				# - Title Case
				detoxed_title="$(detox_title "$raw_title")"
				detoxed_title="$(collection_detox_titlecase_words "$detoxed_title")"

				new_stem="${show_prefix}_${ep_code}_${detoxed_title}"
				source="EPISODES_CSV"
				rules="SxxExx normalized; title applied from episodes.csv; detox applied; title case applied"
				((csv_matches+=1)) || :
			else
				new_stem="$(collection_detox_normalize_sxxexx_in_stem "$stem")"
				new_stem="$(detox_title "$new_stem")"
				new_stem="$(collection_detox_titlecase_words "$new_stem")"
				source="DETOX_ONLY"
				rules="SxxExx normalized if present; detox applied; title case applied"
				((detox_only+=1)) || :
			fi
		else
			new_stem="$(detox_title "$stem")"
			new_stem="$(collection_detox_titlecase_words "$new_stem")"
			source="DETOX_ONLY"
			rules="detox applied; title case applied"
			((detox_only+=1)) || :
		fi

		new_base="${new_stem}.${ext}"
		new_path="$dir/$new_base"

		[[ "$file" == "$new_path" ]] && continue

		status="PENDING"
		reason="READY"
		notes="$rules"

		if [[ -e "$new_path" ]]; then
			status="SKIPPED_EXISTS"
			reason="TARGET_EXISTS"
			notes="Target already exists"
			((exists_count+=1)) || :
		elif [[ -n "${planned_targets[$new_path]:-}" ]]; then
			status="SKIPPED_COLLISION"
			reason="PLAN_COLLISION"
			notes="Another planned rename already targets this path"
			((collision_count+=1)) || :
		else
			planned_targets["$new_path"]="$file"
			basename_rewrite_map["$base"]="$new_base"
			((pending+=1)) || :
		fi

		printf '%s|%s|%s|%s|%s|%s\n' \
			"$status" "$file" "$new_path" "$source" "$reason" "$notes" >> "$plan_file"

		plan_rows+=("$status|$file|$new_path|$source|$reason|$notes")

	done < <(collection_detox_find_files "$scan_root")

	# --------------------------------------------------------
	# PASS 3: PLAYLIST IMPACT SCAN
	# --------------------------------------------------------
	{
		echo "================================================"
		echo "          PLAYLIST IMPACT REPORT"
		echo "================================================"
		echo
		echo "Root:"
		echo " $scan_root"
		echo
		echo "NOTE:"
		echo " This report only detects possible references."
		echo " No playlist files are modified by V1."
		echo
	} > "$playlist_report"

	for file in "${playlist_files[@]}"; do
		local plist_hits=0 old_base

		for old_base in "${!basename_rewrite_map[@]}"; do
			if grep -Fq -- "$old_base" "$file" 2>/dev/null; then
				((plist_hits+=1)) || :
				((playlist_ref_hits+=1)) || :
			fi
		done

		{
			echo "PLAYLIST:"
            echo " $(trim_working_path_display "$file" 3)"
			echo "Possible References:"
			echo " $plist_hits"
			echo "------------------------------------------------"
		} >> "$playlist_report"
	done

	# --------------------------------------------------------
	# HUMAN REPORT
	# --------------------------------------------------------
	{
		echo "================================================"
		echo "          COLLECTION DETOX REPORT"
		echo "================================================"
		echo "Version: $report_version"
		echo "Generated: $(date)"
		echo
		echo "Root:"
		echo " $scan_root"
		echo
		echo "Run Folder:"
		echo " $run_dir"
		echo
		echo "================================================"
		echo "          AUTHORITY SUMMARY"
		echo "================================================"
		echo
		echo "episodes.csv:"
		echo " $csv_status"

		echo
		echo "CSV Rows Loaded:"
		echo " $csv_rows_loaded"

		echo
		echo "CSV Rows Rejected:"
		echo " $csv_rows_rejected"
		if [[ "$csv_status" == "ACCEPTED" ]]; then
			echo
			echo "CSV Seasons Found:"
			printf ' %s\n' "${!csv_seasons[@]}" | sort
		fi
		echo
		echo "Detected Show Prefix:"
		echo " $detected_show_prefix"
		echo
		echo "File Seasons Found:"
		if (( ${#file_seasons[@]} > 0 )); then
			printf ' %s\n' "${!file_seasons[@]}" | sort
		else
			echo " NONE"
		fi
		echo
		echo "CSV Authority Matches:"
		echo " $csv_matches"
		echo
		echo "Detox-Only Candidates:"
		echo " $detox_only"
		echo
		echo "================================================"
		echo "          RENAME PLAN"
		echo "================================================"
		echo
	} > "$report_file"

	for row in "${plan_rows[@]}"; do
		IFS='|' read -r status file new_path source reason notes <<< "$row"

		{
			echo "STATUS:"
			echo " $status"
			echo
			echo "OLD:"
			echo " $(trim_working_path_display "$file" 3)"
			echo
			echo "NEW:"
			echo " $(trim_working_path_display "$new_path" 3)"
			echo
			echo "SOURCE:"
			echo " $source"
			echo
			echo "REASON:"
			echo " $reason"
			echo
			echo "NOTES:"
			echo " $notes"
			echo
			echo "------------------------------------------------"
		} >> "$report_file"
	done

	{

		echo
		echo "================================================"
		echo "NON-MEDIA / NOT RENAMED FILES"
		echo "================================================"
		echo

		if (( ${#unsupported_files[@]} > 0 )); then
			for file in "${unsupported_files[@]}"; do
				printf '%s\n' "$(factory_display_path "$file")"
			done
		else
			echo "NONE"
		fi
		echo
		echo "================================================"
		echo "SUMMARY"
		echo "================================================"
		echo "Files Scanned:          $scanned"
		echo "Unsupported Skipped:    $unsupported"
		echo "SxxExx Tokens Found:    $sxxexx_found"
		echo "Pending Renames:        $pending"
		echo "Skipped Exists:         $exists_count"
		echo "Skipped Collisions:     $collision_count"
		echo "CSV Authority Matches:  $csv_matches"
		echo "Detox-Only Changes:     $detox_only"
		echo "Playlist Files Found:   $playlists_found"
		echo "Playlist Ref Hits:      $playlist_ref_hits"
		echo
		echo "Plan:"
		echo " $plan_file"
		echo
		echo "Report:"
		echo " $report_file"
		echo
		echo "Playlist Impact Report:"
		echo " $playlist_report"
		echo
		echo "================================================"
		echo "NOTICE"
		echo "================================================"
		echo
		echo "Collection Detox Plans Filename Changes."
		echo
		echo "Any existing multimedia playlists created with the"
		echo "previous filenames may require regeneration or repair"
		echo "after rename execution."
		echo
		echo "Examples include:"
		echo "  *.m3u"
		echo "  *.m3u8"
		echo "  Plex / Kodi / Jellyfin / Emby custom playlists"
		echo
		echo "V1 does NOT modify playlists or media files."
		echo "It only reports possible impact."
	} >> "$report_file"

	echo -e "${GREEN} = = > Collection Detox Scan Complete.${NC}"
	echo -e "${CYAN} = = > Files Scanned:${NC} ${YELLOW}$scanned${NC}"
	echo -e "${CYAN} = = > Pending Renames:${NC} ${YELLOW}$pending${NC}"
	echo -e "${CYAN} = = > CSV Matches:${NC} ${YELLOW}$csv_matches${NC}"
	echo -e "${CYAN} = = > Playlist Files:${NC} ${YELLOW}$playlists_found${NC}"
	echo -e "${CYAN} = = > Plan:${NC} ${GREEN}$(trim_working_path_display "$plan_file" 3)${NC}"
	echo -e "${CYAN} = = > Report:${NC} ${GREEN}$(trim_working_path_display "$report_file" 3)${NC}"
	echo -e "${CYAN} = = > Playlist Impact:${NC} ${GREEN}$(trim_working_path_display "$playlist_report" 3)${NC}"
}

# ========================================================
# #MARKER: COLLECTION DETOX REVIEW MENU
# ========================================================
# PURPOSE:
# - After scan/plan/report completes, keep user inside Factory
# - Let user review the generated files without hunting manually
# - No rename execution yet
# ========================================================

collection_detox_review_menu() {
	local run_dir="$1"
	local scan_root="${2:-$PWD}"
	local choice
	local plan_file report_file playlist_report
	local playlist_repair_plan playlist_repair_report

	plan_file="$run_dir/detox_plan.csv"
	report_file="$run_dir/detox_report.txt"
	playlist_report="$run_dir/detox_playlist_impact.txt"
	playlist_repair_plan="$run_dir/playlist_repair_plan.csv"
	playlist_repair_report="$run_dir/playlist_repair_report.txt"

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}        COLLECTION DETOX :: REVIEW RESULTS      ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${CYAN} = = > Run Folder:${NC}"
		echo -e "${GREEN} $(trim_working_path_display "$run_dir" 3)${NC}"
		echo
		echo -e "  ${YELLOW}1)= = > View Human Report q To Exit${NC}"
		echo -e "  ${YELLOW}2)= = > View Plan CSV q To Exit${NC}"
		echo -e "  ${YELLOW}3)= = > View Playlist Impact Report q To Exit${NC}"
		echo -e "  ${YELLOW}4)= = > Print Report Folder Path${NC}"
		echo -e "  ${YELLOW}5)= = > Show Quick Summary Files${NC}"
		echo -e "  ${YELLOW}6)= = > Execute Rename Plan-Adaptive Mode / Undo Menu${NC}"
		echo -e "  ${YELLOW}7)= = > View Playlist Repair Plan CSV${NC}"
		echo -e "  ${YELLOW}8)= = > View Playlist Repair Report${NC}"
		echo -e "  ${YELLOW}9)= = > Execute Playlist Repairs${NC}"
		echo -e "  ${YELLOW}10)= = > Undo Playlist Repairs${NC}"
		echo -e "  ${YELLOW}0.) Return${NC}"
		echo
		echo -ne "${YELLOW} = = > Select Option: ${NC}${GREEN}"
		read -r choice
		echo -e "${NC}"

		if is_exit_token "$choice"; then
			return 0
		fi

		case "$choice" in
			1)
				clear
				if [[ -f "$report_file" ]]; then
					echo
					echo -e "${CYAN} = = > Viewer Opens Next. Press 'q' To Exit Viewer.${NC}"
					echo -e "${YE} = = > Press Enter To Open Viewer...${NC}"
					read -r _
					less "$report_file"
				else
					echo -e "${REB} = = > Missing Report:${NC} ${YELLOW}$report_file${NC}"
					pause
				fi
				;;

			2)
				clear
				if [[ -f "$plan_file" ]]; then
					echo
					echo -e "${CYAN} = = > Viewer Opens Next. Press 'q' To Exit Viewer.${NC}"
					echo -e "${YE} = = > Press Enter To Open Viewer...${NC}"
					read -r _
					less "$plan_file"
				else
					echo -e "${REB} = = > Missing Plan:${NC} ${YELLOW}$plan_file${NC}"
					pause
				fi
				;;

			3)
				clear
				if [[ -f "$playlist_report" ]]; then
					echo
					echo -e "${CYAN} = = > Viewer Opens Next. Press 'q' To Exit Viewer.${NC}"
					echo -e "${YE} = = > Press Enter To Open Viewer...${NC}"
					read -r _
					less "$playlist_report"
				else
					echo -e "${REB} = = > Missing Playlist Report:${NC} ${YELLOW}$playlist_report${NC}"
					pause
				fi
				;;

			4)
				echo
				echo -e "${CYAN} = = > Report Folder:${NC}"
				echo -e "${GREEN}$run_dir${NC}"
				echo
				pause
				;;

			5)
				echo
				echo -e "${CYAN} = = > Files Created:${NC}"
				[[ -f "$plan_file" ]] && echo -e "${GREEN} $plan_file${NC}"
				[[ -f "$report_file" ]] && echo -e "${GREEN} $report_file${NC}"
				[[ -f "$playlist_report" ]] && echo -e "${GREEN} $playlist_report${NC}"
				echo
				pause
				;;

			6)
				collection_detox_execute_plan "$run_dir" "$scan_root"
				;;

			7)
				clear
				if [[ -f "$playlist_repair_plan" ]]; then
					echo
					echo -e "${CYAN} = = > Viewer Opens Next. Press 'q' To Exit Viewer.${NC}"
					echo -e "${YE} = = > Press Enter To Open Viewer...${NC}"
					read -r _
					less "$playlist_repair_plan"
				else
					echo -e "${YE} = = > Playlist Repair Plan Not Found Yet.${NC}"
					pause
				fi
				;;

			8)
				clear
				collection_detox_write_playlist_repair_report "$run_dir"
				if [[ -f "$playlist_repair_report" ]]; then
					echo
					echo -e "${CYAN} = = > Viewer Opens Next. Press 'q' To Exit Viewer.${NC}"
					echo -e "${YE} = = > Press Enter To Open Viewer...${NC}"
					read -r _
					less "$playlist_repair_report"
				else
					echo -e "${YE} = = > Playlist Repair Report Not Found.${NC}"
					pause
				fi
				;;

			9)
				collection_detox_execute_playlist_repairs "$scan_root" "$run_dir"
				;;

			10)
				collection_detox_undo_playlist_repairs "$run_dir"
				;;

			*)
				echo -e "${YE} = = > Invalid Selection.${NC}"
				pause
				;;
		esac
	done
}

# ========================================================
# #MARKER: COLLECTION DETOX EXECUTE MODE V1
# ========================================================
# PURPOSE:
# - Execute PENDING rows from detox_plan.csv
# - Pilot first N renames before full execution
# - Log every action
# - Build playlist repair plan only from successful renames
# - Playlist changes remain a separate report-first approval step
# ========================================================

collection_detox_build_playlist_repair_plan() {
	playlist_build_repair_plan "$@"
}


run_collection_detox_scan_only() {
	local scan_root run_root run_dir choice dir_choice picked_dir
	local -a dirs=()

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}          COLLECTION DETOX :: SCAN / PLAN       ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${CYAN} = = > Current Working Folder:${NC}"
		echo -e "${GREEN} $(trim_working_path_display "$PWD" 3)${NC}"
		echo
		echo -e "  ${YELLOW}1)= = > Scan Current Folder Recursively${NC}"
		echo -e "  ${YELLOW}2)= = > Pick Folder From Current Location${NC}"
		echo -e "  ${YELLOW}0.) Return${NC}"
		echo
		echo -ne "${YELLOW} = = > Select Option: ${NC}${GREEN}"
		read -r choice
		echo -e "${NC}"

		if is_exit_token "$choice"; then
			return 0
		fi

		case "$choice" in
			1|"")
				scan_root="$PWD"
				break
				;;

			2)
				while true; do
					dirs=()
					dirs+=(".")
					dirs+=("..")

					shopt -s nullglob
					for picked_dir in */; do
						[[ -d "$picked_dir" ]] || continue
						dirs+=("${picked_dir%/}")
					done
					shopt -u nullglob

					clear
					echo -e "${CYAN}================================================${NC}"
					echo -e "${CYAN}          COLLECTION DETOX :: FOLDER PICKER     ${NC}"
					echo -e "${CYAN}================================================${NC}"
					echo
					echo -e "${CYAN} = = > Pick Folder To Scan Recursively:${NC}"
					echo

					for i in "${!dirs[@]}"; do
						echo -e "  ${YELLOW}$((i+1)))${NC} ${GREEN}${dirs[$i]}${NC}"
					done

					echo
					echo -e "  ${YELLOW}0.) Return${NC}"
					echo
					echo -ne "${YELLOW} = = > Folder Number: ${NC}${GREEN}"
					read -r dir_choice
					echo -e "${NC}"

					dir_choice="${dir_choice//[[:space:]]/}"

					if is_exit_token "$dir_choice"; then
						break
					fi

					if ! [[ "$dir_choice" =~ ^[0-9]+$ ]] || \
					   (( dir_choice < 1 || dir_choice > ${#dirs[@]} )); then
						echo -e "${REB} = = > Invalid Folder Selection.${NC}"
						pause
						continue
					fi

					scan_root="${dirs[$((dir_choice-1))]}"

					if [[ "$scan_root" == "." ]]; then
						scan_root="$PWD"
					else
						scan_root="$(cd -- "$scan_root" && pwd)"
					fi

					break 2
				done
				;;

			*)
				echo -e "${YE} = = > Invalid Selection.${NC}"
				pause
				;;
		esac
	done

	[[ -d "$scan_root" ]] || {
		echo -e "${REB} = = > Folder Not Found:${NC} ${YELLOW}$scan_root${NC}"
		pause
		return 1
	}

	run_root="${COLLECTION_DETOX_ROOT:-${FACTORY_HOME:-.}/reports/COLLECTION_DETOX}"
	run_dir="$(collection_detox_make_run_dir "$run_root")"

	collection_detox_scan_build_plan "$scan_root" "$run_dir"

	if ask_yes_no " = = > Review Collection Detox Reports Now? (y/n or 1/2): "; then
		collection_detox_review_menu "$run_dir" "$scan_root"
	else
		pause
	fi
}

detox_title() {
	local raw="$1"
	local cleaned

	# ========================================================
	# PHASE 1–4: CLEAN + SANITIZE
	# ========================================================
	# DIRECT DETOX RULES:
	# - Preserve existing capitalization
	# - Preserve existing underscores
	# - Preserve hyphens for meaningful episode/title joins
	# - Convert whitespace to underscores
	# - Remove apostrophes instead of turning them into "_"
	# - Collapse common episode-part labels:
	#     Part_1   -> Part1
	#     Part-1   -> Part1
	#     Part 1   -> Part1
	#     Part_I   -> PartI
	#     Part II  -> PartII
	#     Part-III -> PartIII
	#     Part IV  -> PartIV
	# - If Part1/Part2/PartI/PartII/etc is the trailing title suffix:
	#     Equinox_Part2  -> Equinox-Part2
	#     Equinox_PartII -> Equinox-PartII
	# ========================================================

	if have_cmd iconv; then
		cleaned="$(
			printf '%s\n' "$raw" \
				| sed "s/[’']//g" \
				| sed 's/[[:space:]]\+/_/g' \
				| sed 's/&/And/g' \
				| iconv -f utf8 -t ascii//TRANSLIT 2>/dev/null \
				| sed 's/[^A-Za-z0-9_-]/_/g' \
				| sed -E 's/([Pp][Aa][Rr][Tt])[_-]*([0-9]+)/Part\2/g' \
				| sed -E 's/([Pp][Aa][Rr][Tt])[_-]*(I|II|III|IV|i|ii|iii|iv)([^A-Za-z0-9]|$)/Part\2\3/g' \
				| sed -E 's/_+Part([0-9]+|I|II|III|IV|i|ii|iii|iv)$/-Part\1/g' \
				| sed 's/__\+/_/g' \
				| sed 's/^_//; s/_$//'
		)"
	else
		cleaned="$(
			printf '%s\n' "$raw" \
				| sed "s/[’']//g" \
				| sed 's/[[:space:]]\+/_/g' \
				| sed 's/&/And/g' \
				| sed 's/[^A-Za-z0-9_-]/_/g' \
				| sed -E 's/([Pp][Aa][Rr][Tt])[_-]*([0-9]+)/Part\2/g' \
				| sed -E 's/([Pp][Aa][Rr][Tt])[_-]*(I|II|III|IV|i|ii|iii|iv)([^A-Za-z0-9]|$)/Part\2\3/g' \
				| sed -E 's/_+Part([0-9]+|I|II|III|IV|i|ii|iii|iv)$/-Part\1/g' \
				| sed 's/__\+/_/g' \
				| sed 's/^_//; s/_$//'
		)"
	fi

	printf '%s\n' "$cleaned"
}

# start of recovery mode for filename mutilated, need filenames rebuilt proper============================================
# rename by good episodes.csv and/or rebuild episodes.csv from good filenames in working dir

match_normalize_title() {
	local raw="$1"
	local cleaned

	if have_cmd iconv; then
		cleaned=$(printf '%s\n' "$raw" \
			| iconv -f utf8 -t ascii//TRANSLIT 2>/dev/null \
			| tr '[:upper:]' '[:lower:]' \
			| sed 's/[^a-z0-9]/_/g' \
			| sed 's/__\+/_/g' \
			| sed 's/^_//; s/_$//')
	else
		cleaned=$(printf '%s\n' "$raw" \
			| tr '[:upper:]' '[:lower:]' \
			| sed 's/[^a-z0-9]/_/g' \
			| sed 's/__\+/_/g' \
			| sed 's/^_//; s/_$//')
	fi

	printf '%s\n' "$cleaned"
}


# =========================
# #MARKER: GENERIC RECOVERY PLAN PREVIEW + APPLY
# =========================
# PURPOSE:
# - Read old|new plan rows from any recovery planner
# - Preview
# - Confirm
# - Apply renames safely
#
# INPUT:
# - old_filename|new_filename
#
# OUTPUT:
# - Return 0 on success / clean cancel
# - Return 1 on malformed or runtime failure
# =========================
preview_and_apply_plan_rows() {

	local -a plan_rows=("$@")
	local plan_line
	local old_name new_name
	local applied=0
	local failed=0
	local already_ok=0

	if (( ${#plan_rows[@]} == 0 )); then
		echo -e "${REB} = = > [NO RENAME PLAN FOUND]${NC}"
		return 1
	fi

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}           RECOVERY RENAME PREVIEW              ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	for plan_line in "${plan_rows[@]}"; do
		if [[ "$plan_line" != *"|"* ]]; then
			echo -e "${REB} = = > [MALFORMED PLAN ROW]${NC} $plan_line"
			return 1
		fi

		old_name="${plan_line%%|*}"
		new_name="${plan_line#*|}"

		if [[ -z "$old_name" || -z "$new_name" ]]; then
			echo -e "${REB} = = > [MALFORMED PLAN ROW]${NC} $plan_line"
			return 1
		fi

		if [[ "$old_name" == "$new_name" ]]; then
			echo -e "  ${CYAN}${old_name}${NC} ${YELLOW}-->${NC} ${CYAN}${new_name}${NC} ${GREEN}[ALREADY CORRECT]${NC}"
			continue
		fi

		echo -e "  ${GREEN}${old_name}${NC} ${YELLOW}-->${NC} ${GREEN}${new_name}${NC}"
	done
	echo

	if ! ask_yes_no " = = > Apply Recovery Renames Now? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Recovery Rename Apply Cancelled.${NC}"
		echo
		return 0
	fi

	for plan_line in "${plan_rows[@]}"; do
		old_name="${plan_line%%|*}"
		new_name="${plan_line#*|}"

		if [[ "$old_name" == "$new_name" ]]; then
			echo -e "${GREEN} = = > [ALREADY CORRECT]${NC} $old_name"
			((already_ok+=1)) || :
			continue
		fi

		if [[ ! -f "$old_name" ]]; then
			echo -e "${REB} = = > [SOURCE MISSING]${NC} $old_name"
			((failed+=1)) || :
			break
		fi

		if [[ -e "$new_name" && "$new_name" != "$old_name" ]]; then
			echo -e "${REB} = = > [TARGET EXISTS AT APPLY TIME]${NC} $new_name"
			((failed+=1)) || :
			break
		fi

		if mv -- "$old_name" "$new_name"; then
			echo -e "${GREEN} = = > [RENAMED]${NC} $old_name ${YELLOW}-->${NC} $new_name"
			((applied+=1)) || :
		else
			echo -e "${REB} = = > [RENAME FAILED]${NC} $old_name"
			((failed+=1)) || :
			break
		fi
	done

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             RECOVERY APPLY SUMMARY             ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Renames Applied:${NC} $applied"
	echo -e "${CYAN} = = > Already Correct:${NC} $already_ok"
	echo -e "${CYAN} = = > Failures       :${NC} $failed"
	echo

	(( failed == 0 ))
}


# =========================
# #MARKER: RECOVERY MODE FILE COLLECTION (FRONT NUMBER TAG)
# =========================
# PURPOSE:
# - Identify files prepared for Recovery Mode
# - Extract leading numeric token ONLY
# - Validate strict format
# - Return clean, ordered list for pairing with episodes.csv
#
# OUTPUT:
# - Prints: number|filename
# - Sorted numerically
# - Return 0 on success
# - Return 1 on ANY validation failure
# =========================
collect_front_number_tagged_files() {

	local -a vids=()
	local -a parsed_lines=()
	local -A seen_numbers=()

	local f number raw_number
	local min_num="" max_num=""
	local expected current

	# --------------------------------------------------------
	# COLLECT VIDEO FILES (REUSE FACTORY PATTERN)
	# --------------------------------------------------------
	shopt -s nullglob nocaseglob
	vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	# --------------------------------------------------------
	# FILTER + PARSE
	# --------------------------------------------------------
	for f in "${vids[@]}"; do
		[[ -f "$f" ]] || continue

		# Skip factory-generated files
		case "${f^^}" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|OEM_*)
				continue
				;;
		esac

		# ----------------------------------------------------
		# STRICT PREFIX MATCH: ^[0-9]+[_-]
		# ----------------------------------------------------
		if [[ "$f" =~ ^([0-9]+)[_-] ]]; then
			raw_number="${BASH_REMATCH[1]}"

			# Strip leading zeros safely
			number="$((10#$raw_number))"

			# Duplicate detection
			if [[ -n "${seen_numbers[$number]:-}" ]]; then
				echo -e "${REB} = = > [DUPLICATE INDEX]${NC} $raw_number (${seen_numbers[$number]} and $f)"
				return 1
			fi

			seen_numbers[$number]="$f"

			parsed_lines+=("${number}|${f}")

		else
			echo -e "${REB} = = > [INVALID PREFIX]${NC} $f"
			return 1
		fi
	done

	# --------------------------------------------------------
	# NO VALID FILES
	# --------------------------------------------------------
	if (( ${#parsed_lines[@]} == 0 )); then
		echo -e "${REB} = = > No Recovery-Tagged Files Detected.${NC}"
		return 1
	fi

	# --------------------------------------------------------
	# SORT NUMERICALLY
	# --------------------------------------------------------
	mapfile -t parsed_lines < <(
		printf '%s\n' "${parsed_lines[@]}" | sort -t'|' -k1,1n
	)

	# --------------------------------------------------------
	# GAP CHECK
	# --------------------------------------------------------
	min_num="$(printf '%s\n' "${parsed_lines[0]}" | cut -d'|' -f1)"
	max_num="$(printf '%s\n' "${parsed_lines[-1]}" | cut -d'|' -f1)"

	expected="$min_num"

	for current_line in "${parsed_lines[@]}"; do
		current="$(printf '%s\n' "$current_line" | cut -d'|' -f1)"

		if (( current != expected )); then
			printf -v missing "%03d" "$expected"
			echo -e "${REB} = = > [MISSING INDEX]${NC} $missing"
			return 1
		fi

		((expected+=1))
	done

	# --------------------------------------------------------
	# SUMMARY OUTPUT
	# --------------------------------------------------------
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      RECOVERY MODE FILE DETECTION SUMMARY      ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Valid Tagged Files:${NC} ${#parsed_lines[@]}"
	printf -v min_fmt "%03d" "$min_num"
	printf -v max_fmt "%03d" "$max_num"
	echo -e "${CYAN} = = > Index Range:${NC} $min_fmt → $max_fmt"
	echo

	# Optional preview
	for line in "${parsed_lines[@]}"; do
		echo -e "  ${GREEN}- ${NC}${line#*|}"
	done
	echo

	# --------------------------------------------------------
	# FINAL OUTPUT CONTRACT
	# --------------------------------------------------------
	printf '%s\n' "${parsed_lines[@]}"

	return 0
}

# =========================
# #MARKER: RECOVERY MODE CSV READER (EPISODES.CSV)
# =========================
# PURPOSE:
# - Read episodes.csv
# - Validate row structure for Recovery Mode
# - Preserve CSV row order as the pairing authority
#
# ACCEPTED ROW SHAPE:
# - S01E01,The_Bonding
# - S01E02,Another_Title
#
# OPTIONAL HEADER:
# - episode_code,title
#
# OUTPUT:
# - Prints: row_number|episode_code|title
# - Return 0 on success
# - Return 1 on ANY validation failure
# =========================
read_episodes_csv_rows() {
	local file="${1:-episodes.csv}"
	local -a parsed_rows=()
	local -A seen_codes=()

	local line row_num=0
	local row_key ep_code title
	local first_code="" last_code=""
	local header_skipped=0

	if [[ ! -f "$file" ]]; then
		echo -e "${REB} = = > [MISSING EPISODE CSV]${NC} ${YELLOW}$file${NC}" >&2
		return 1
	fi

	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line%$'\r'}"
		[[ -z "${line//[[:space:]]/}" ]] && continue

		if (( header_skipped == 0 )); then
			case "${line,,}" in
				episode_code,title|code,title|episode,title|sxxexx,title|id,title)
					header_skipped=1
					continue
					;;
			esac
			header_skipped=1
		fi

		row_key="${line%%,*}"
		title="${line#*,}"

		row_key="$(printf '%s' "$row_key" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
		title="$(printf '%s' "$title" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

		ep_code="$(printf '%s\n' "$row_key" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 | tr '[:lower:]' '[:upper:]' || true)"

		if [[ -z "$ep_code" ]]; then
			echo -e "${REB} = = > [NO SxxExx IN CSV KEY]${NC} ${YELLOW}$row_key${NC}" >&2
			return 1
		fi

		if [[ -z "${title//[[:space:]]/}" ]]; then
			echo -e "${REB} = = > [BLANK TITLE]${NC} ${YELLOW}$ep_code${NC}" >&2
			return 1
		fi

		if [[ -n "${seen_codes[$ep_code]:-}" ]]; then
			echo -e "${REB} = = > [DUPLICATE EPISODE CODE]${NC} ${YELLOW}$ep_code${NC}" >&2
			return 1
		fi
		seen_codes[$ep_code]=1

		((row_num+=1)) || :

		[[ -z "$first_code" ]] && first_code="$ep_code"
		last_code="$ep_code"

		parsed_rows+=("${row_num}|${ep_code}|${title}")
	done < "$file"

	if (( ${#parsed_rows[@]} == 0 )); then
		echo -e "${REB} = = > [NO EPISODE CSV ROWS AVAILABLE]${NC}" >&2
		return 1
	fi

	echo -e "${CYAN}================================================${NC}" >&2
	echo -e "${CYAN}        RECOVERY MODE CSV READER SUMMARY        ${NC}" >&2
	echo -e "${CYAN}================================================${NC}" >&2
	echo -e "${CYAN} = = > CSV File:${NC} ${YELLOW}$file${NC}" >&2
	echo -e "${CYAN} = = > Episode Rows Loaded:${NC} ${YELLOW}${#parsed_rows[@]}${NC}" >&2
	echo -e "${CYAN} = = > First Episode Code:${NC} ${YELLOW}$first_code${NC}" >&2
	echo -e "${CYAN} = = > Last Episode Code:${NC} ${YELLOW}$last_code${NC}" >&2
	echo >&2

	printf '%s\n' "${parsed_rows[@]}"
	return 0
}

# =========================
# #MARKER: RECOVERY MODE RENAME PLAN BUILDER
# =========================
# PURPOSE:
# - Join Recovery-Tagged Files With episodes.csv Rows
# - Build Safe Old|New Rename Plan
# - Reuse Existing detox_title() For Final Filename Safety
#
# INPUT:
# - collect_front_number_tagged_files() output:
#     row_number|old_filename
# - read_episodes_csv_rows() output:
#     row_number|episode_code|title
#
# OUTPUT:
# - Prints: old_filename|new_filename
# - Return 0 on success
# - Return 1 on ANY validation failure
# =========================
build_recovery_rename_plan() {

	local -a file_rows=()
	local -a csv_rows=()
	local -a plan_rows=()
	local -A planned_targets=()

	local file_line csv_line
	local file_row old_name
	local csv_row ep_code raw_title
	local detoxed_title ext new_name
	local csv_file="${1:-episodes.csv}"

	local idx
	local file_count csv_count
	local old_base old_ext

	# --------------------------------------------------------
	# COLLECT BOTH ORDERED STREAMS
	# --------------------------------------------------------
	mapfile -t file_rows < <(collect_front_number_tagged_files)
	if (( ${#file_rows[@]} == 0 )); then
		echo -e "${REB} = = > [NO TAGGED FILE ROWS AVAILABLE]${NC}"
		return 1
	fi

	mapfile -t csv_rows < <(read_episodes_csv_rows "$csv_file")
	if (( ${#csv_rows[@]} == 0 )); then
		echo -e "${REB} = = > [NO EPISODE CSV ROWS AVAILABLE]${NC}"
		return 1
	fi

	file_count="${#file_rows[@]}"
	csv_count="${#csv_rows[@]}"

	# --------------------------------------------------------
	# COUNT MATCH CHECK
	# --------------------------------------------------------
	if (( file_count != csv_count )); then
		echo -e "${REB} = = > [COUNT MISMATCH]${NC} files=$file_count csv_rows=$csv_count"
		return 1
	fi

	# --------------------------------------------------------
	# JOIN ROW-BY-ROW
	# --------------------------------------------------------
	for ((idx=0; idx<file_count; idx++)); do
		file_line="${file_rows[$idx]}"
		csv_line="${csv_rows[$idx]}"

		file_row="${file_line%%|*}"
		old_name="${file_line#*|}"

		csv_row="${csv_line%%|*}"
		ep_code="${csv_line#*|}"
		ep_code="${ep_code%%|*}"
		raw_title="${csv_line#*|*|}"

		# ----------------------------------------------------
		# ROW ALIGNMENT CHECK
		# ----------------------------------------------------
		if [[ "$file_row" != "$csv_row" ]]; then
			echo -e "${REB} = = > [ROW ALIGNMENT ERROR]${NC} file_row=$file_row csv_row=$csv_row"
			return 1
		fi

		# ----------------------------------------------------
		# PRESERVE ORIGINAL EXTENSION
		# ----------------------------------------------------
		old_ext="${old_name##*.}"
		if [[ "$old_ext" == "$old_name" ]]; then
			echo -e "${REB} = = > [MISSING EXTENSION]${NC} $old_name"
			return 1
		fi

		# ----------------------------------------------------
		# DETOX TITLE THROUGH EXISTING SHARED HELPER
		# ----------------------------------------------------
		detoxed_title="$(detox_title "$raw_title")"

		if [[ -z "${detoxed_title//[[:space:]]/}" ]]; then
			echo -e "${REB} = = > [INVALID TARGET NAME]${NC} $old_name"
			return 1
		fi

		new_name="${ep_code}_${detoxed_title}.${old_ext}"

		# ----------------------------------------------------
		# BASIC TARGET SANITY
		# ----------------------------------------------------
		if [[ -z "${new_name//[[:space:]]/}" ]]; then
			echo -e "${REB} = = > [INVALID TARGET NAME]${NC} $old_name"
			return 1
		fi

		# ----------------------------------------------------
		# DUPLICATE TARGET INSIDE PLAN
		# ----------------------------------------------------
		if [[ -n "${planned_targets[$new_name]:-}" ]]; then
			echo -e "${REB} = = > [DUPLICATE TARGET]${NC} $new_name"
			return 1
		fi
		planned_targets[$new_name]=1

		# ----------------------------------------------------
		# EXISTING TARGET COLLISION
		# ----------------------------------------------------
		if [[ -e "$new_name" && "$new_name" != "$old_name" ]]; then
			echo -e "${REB} = = > [TARGET EXISTS]${NC} $new_name"
			return 1
		fi

		plan_rows+=("${old_name}|${new_name}")
	done

	# --------------------------------------------------------
	# SUMMARY OUTPUT
	# --------------------------------------------------------
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}       RECOVERY MODE RENAME PLAN SUMMARY        ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Tagged Files Loaded :${NC} $file_count"
	echo -e "${CYAN} = = > Episode Rows Loaded :${NC} $csv_count"
	echo -e "${CYAN} = = > Planned Renames     :${NC} ${#plan_rows[@]}"
	echo

	for file_line in "${plan_rows[@]}"; do
		old_name="${file_line%%|*}"
		new_name="${file_line#*|}"
		echo -e "  ${GREEN}${old_name}${NC} ${YELLOW}-->${NC} ${GREEN}${new_name}${NC}"
	done
	echo

	# --------------------------------------------------------
	# FINAL OUTPUT CONTRACT
	# --------------------------------------------------------
	printf '%s\n' "${plan_rows[@]}"

	return 0
}

# =========================
# #MARKER: RECOVERY MODE PREVIEW + APPLY RENAME PLAN
# =========================
# PURPOSE:
# - Read old|new rename plan from build_recovery_rename_plan()
# - Show a clear preview
# - Ask for confirmation
# - Apply renames safely
#
# INPUT:
# - build_recovery_rename_plan() output:
#     old_filename|new_filename
#
# OUTPUT:
# - Applies mv only after confirmation
# - Return 0 on success / clean cancel
# - Return 1 on malformed or runtime failure
# =========================
preview_and_apply_recovery_rename_plan() {

	local -a plan_rows=()
	local plan_line
	local old_name new_name

	local applied=0
	local failed=0

	# --------------------------------------------------------
	# BUILD / CAPTURE PLAN
	# --------------------------------------------------------
	mapfile -t plan_rows < <(build_recovery_rename_plan)

	if (( ${#plan_rows[@]} == 0 )); then
		echo -e "${REB} = = > [NO RENAME PLAN FOUND]${NC}"
		return 1
	fi

	# --------------------------------------------------------
	# PREVIEW
	# --------------------------------------------------------
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        RECOVERY MODE RENAME PREVIEW            ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	for plan_line in "${plan_rows[@]}"; do
		if [[ "$plan_line" != *"|"* ]]; then
			echo -e "${REB} = = > [MALFORMED PLAN ROW]${NC} $plan_line"
			return 1
		fi

		old_name="${plan_line%%|*}"
		new_name="${plan_line#*|}"

		if [[ -z "$old_name" || -z "$new_name" || "$old_name" == "$new_name" && ! -e "$old_name" ]]; then
			echo -e "${REB} = = > [MALFORMED PLAN ROW]${NC} $plan_line"
			return 1
		fi

		echo -e "  ${GREEN}${old_name}${NC} ${YELLOW}-->${NC} ${GREEN}${new_name}${NC}"
	done
	echo

	# --------------------------------------------------------
	# CONFIRM
	# --------------------------------------------------------
	if ! ask_yes_no " = = > Apply Recovery Renames Now? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Recovery Rename Apply Cancelled.${NC}"
		echo
		return 0
	fi

	# --------------------------------------------------------
	# APPLY
	# --------------------------------------------------------
	for plan_line in "${plan_rows[@]}"; do
		old_name="${plan_line%%|*}"
		new_name="${plan_line#*|}"

		# Source must still exist right now
		if [[ ! -f "$old_name" ]]; then
			echo -e "${REB} = = > [SOURCE MISSING]${NC} $old_name"
			((failed+=1)) || :
			break
		fi

		# Target must not now exist unless it is the same path
		if [[ -e "$new_name" && "$new_name" != "$old_name" ]]; then
			echo -e "${REB} = = > [TARGET EXISTS AT APPLY TIME]${NC} $new_name"
			((failed+=1)) || :
			break
		fi

		if mv -- "$old_name" "$new_name"; then
			echo -e "${GREEN} = = > [RENAMED]${NC} $old_name ${YELLOW}-->${NC} $new_name"
			((applied+=1)) || :
		else
			echo -e "${REB} = = > [RENAME FAILED]${NC} $old_name"
			((failed+=1)) || :
			break
		fi
	done

	# --------------------------------------------------------
	# APPLY SUMMARY
	# --------------------------------------------------------
	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}         RECOVERY MODE APPLY SUMMARY            ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Renames Applied:${NC} $applied"
	echo -e "${CYAN} = = > Failures       :${NC} $failed"
	echo

	(( failed == 0 ))
}

# =========================
# #MARKER: RECOVERY TAIL-MATCH RENAME PLAN BUILDER
# =========================
# PURPOSE:
# - Recover Filenames By Matching Surviving Filename Tail
#   Against episodes.csv Titles
# - Build Safe old|new Rename Plan
# - Do NOT Rename Yet
#
# INPUT:
# - Video filenames passed in as args
# - episodes.csv present in working dir
#
# MATCH RULE:
# - Normalize filename stem with detox_title()
# - Normalize CSV title with detox_title()
# - Accept ONLY unique suffix-style matches
#
# OUTPUT:
# - Prints: old_filename|new_filename
# - Return 0 on success
# - Return 1 on any validation failure
# =========================
build_recovery_tail_match_plan() {
	local csv_file="${1:-episodes.csv}"
	shift || true
	local -a vids=("$@")
	local -a filtered=()
	local -a csv_rows=()
	local -a plan_rows=()
	local -A planned_targets=()
	local full_cmp tail_cmp candidate_cmp csv_cmp
	local f stem ext
	local tail_candidate tail_key full_key
	local line ep_code raw_title csv_key csv_out_key new_name
	local match_count matched_code matched_key
	local old_name
	local best_suffix suffix candidate_suffix found_unique
	local max_parts

	if [[ ${#vids[@]} -eq 0 ]]; then
		echo -e "${REB} = = > [NO VIDEO TARGETS PASSED IN]${NC}" >&2
		return 1
	fi

	for f in "${vids[@]}"; do
		[[ -f "$f" ]] || continue
		[[ "$f" =~ ^(SMC_|SUBPACKED_) ]] && continue
		filtered+=("$f")
	done

	if (( ${#filtered[@]} == 0 )); then
		echo -e "${REB} = = > [NO ELIGIBLE FILES FOR TAIL MATCH]${NC}" >&2
		return 1
	fi

	mapfile -t csv_rows < <(read_episodes_csv_rows "$csv_file")
	if (( ${#csv_rows[@]} == 0 )); then
		echo -e "${REB} = = > [NO EPISODE CSV ROWS AVAILABLE]${NC}" >&2
		return 1
	fi

	# --------------------------------------------------------
	# HELPER: COUNT UNDERSCORE SEGMENTS
	# --------------------------------------------------------
	count_segments() {
		local text="$1"
		local IFS='_'
		local -a parts=()
		read -r -a parts <<< "$text"
		printf '%s\n' "${#parts[@]}"
	}

	# --------------------------------------------------------
	# HELPER: RETURN LAST N UNDERSCORE SEGMENTS
	# --------------------------------------------------------
	last_n_segments() {
		local text="$1"
		local n="$2"
		local IFS='_'
		local -a parts=()
		local start i out=""

		read -r -a parts <<< "$text"

		(( ${#parts[@]} == 0 )) && { printf '%s\n' ""; return 0; }

		if (( n >= ${#parts[@]} )); then
			printf '%s\n' "$text"
			return 0
		fi

		start=$(( ${#parts[@]} - n ))

		for (( i=start; i<${#parts[@]}; i++ )); do
			if [[ -z "$out" ]]; then
				out="${parts[$i]}"
			else
				out="${out}_${parts[$i]}"
			fi
		done

		printf '%s\n' "$out"
	}

	for f in "${filtered[@]}"; do
		ext="${f##*.}"
		stem="${f%.*}"

		full_key="$(match_normalize_title "$stem")"
		full_cmp="${full_key,,}"

		tail_candidate="$stem"

		# strip obvious archive / level prefix chunks
		tail_candidate="$(printf '%s\n' "$tail_candidate" | sed -E 's/^[Aa][Rr][Cc][Hh][Ii][Vv][Ee](_|-)?//')"
		tail_candidate="$(printf '%s\n' "$tail_candidate" | sed -E 's/^[Ll][0-9]+(_|-)?//')"

		# strip leading numeric chunks repeatedly
		while [[ "$tail_candidate" =~ ^[0-9]+[_-](.+)$ ]]; do
			tail_candidate="${BASH_REMATCH[1]}"
		done

		# strip leftover leading separators
		tail_candidate="$(printf '%s\n' "$tail_candidate" | sed -E 's/^[_-]+//')"

		tail_key="$(match_normalize_title "$tail_candidate")"
		tail_cmp="${tail_key,,}"

		match_count=0
		matched_code=""
		matched_key=""
		best_suffix=""
		found_unique=0

		# ----------------------------------------------------
		# PASS 1: FULL / SIMPLE SUFFIX MATCHES
		# ----------------------------------------------------
		for line in "${csv_rows[@]}"; do
			ep_code="${line#*|}"
			ep_code="${ep_code%%|*}"
			raw_title="${line#*|*|}"
			csv_out_key="$(detox_title "$raw_title")"
			csv_key="$(match_normalize_title "$raw_title")"
			csv_cmp="${csv_key,,}"

			if [[ \
				"$full_cmp" == "$csv_cmp" || \
				"$tail_cmp" == "$csv_cmp" \
			 ]]; then
				((match_count+=1)) || :
				matched_code="$ep_code"
				matched_key="$csv_out_key"
			fi
		done

		if (( match_count == 1 )); then
			new_name="${matched_code}_${matched_key}.${ext}"

			if [[ -z "${new_name//[[:space:]]/}" ]]; then
				echo -e "${REB} = = > [INVALID TARGET NAME]${NC} $f" >&2
				return 1
			fi

			if [[ -n "${planned_targets[$new_name]:-}" ]]; then
				echo -e "${REB} = = > [DUPLICATE TARGET]${NC} $new_name" >&2
				return 1
			fi
			planned_targets[$new_name]=1

			if [[ -e "$new_name" && "$new_name" != "$f" ]]; then
				echo -e "${REB} = = > [TARGET EXISTS]${NC} $new_name" >&2
				return 1
			fi

			plan_rows+=("${f}|${new_name}")
			continue
		fi

		if (( match_count > 1 )); then
			echo -e "${REB} = = > [AMBIGUOUS FULL/TAIL MATCH]${NC} $f" >&2
			echo -e "${YE} = = > Full Key:${NC} $full_key" >&2
			echo -e "${YE} = = > Tail Key:${NC} $tail_key" >&2
			return 1
		fi

		# ----------------------------------------------------
		# PASS 2: LONGEST UNIQUE RIGHT-SIDE SUFFIX
		# ----------------------------------------------------
		max_parts="$(count_segments "$tail_key")"

		for (( suffix=max_parts; suffix>=1; suffix-- )); do
			candidate_suffix="$(last_n_segments "$tail_key" "$suffix")"
			candidate_cmp="${candidate_suffix,,}"
			match_count=0
			matched_code=""
			matched_key=""

			for line in "${csv_rows[@]}"; do
				ep_code="${line#*|}"
				ep_code="${ep_code%%|*}"
				raw_title="${line#*|*|}"
				csv_key="$(detox_title "$raw_title")"
				csv_cmp="${csv_key,,}"

				if [[ "$csv_cmp" == "$candidate_cmp" || "$csv_cmp" == *"$candidate_cmp" ]]; then
					((match_count+=1)) || :
					matched_code="$ep_code"
					matched_key="$csv_key"
				fi
			done

			if (( match_count == 1 )); then
				best_suffix="$candidate_suffix"
				found_unique=1
				break
			fi
		done

		if (( found_unique == 0 )); then
			echo -e "${REB} = = > [NO TAIL MATCH]${NC} $f" >&2
			echo -e "${YE} = = > Full Key:${NC} $full_key" >&2
			echo -e "${YE} = = > Tail Key:${NC} $tail_key" >&2
						echo -e "${YE} = = > Candidate Suffixes Tried:${NC}" >&2
			for (( suffix=max_parts; suffix>=1; suffix-- )); do
				candidate_suffix="$(last_n_segments "$tail_key" "$suffix")"
				echo -e "  ${YE}-${NC} $candidate_suffix" >&2
			done
			echo >&2

			echo -e "${YE} = = > CSV Keys Containing 'command':${NC}" >&2
			for line in "${csv_rows[@]}"; do
				raw_title="${line#*|*|}"
				csv_key="$(match_normalize_title "$raw_title")"
				if [[ "$csv_key" == *"command"* ]]; then
					echo -e "  ${YE}-${NC} $csv_key" >&2
				fi
			done
			return 1
		fi

		new_name="${matched_code}_${matched_key}.${ext}"

		if [[ -z "${new_name//[[:space:]]/}" ]]; then
			echo -e "${REB} = = > [INVALID TARGET NAME]${NC} $f" >&2
			return 1
		fi

		if [[ -n "${planned_targets[$new_name]:-}" ]]; then
			echo -e "${REB} = = > [DUPLICATE TARGET]${NC} $new_name" >&2
			return 1
		fi
		planned_targets[$new_name]=1

		if [[ -e "$new_name" && "$new_name" != "$f" ]]; then
			echo -e "${REB} = = > [TARGET EXISTS]${NC} $new_name" >&2
			return 1
		fi

		plan_rows+=("${f}|${new_name}")
	done

	echo -e "${CYAN}================================================${NC}" >&2
	echo -e "${CYAN}     RECOVERY TAIL-MATCH RENAME PLAN SUMMARY    ${NC}" >&2
	echo -e "${CYAN}================================================${NC}" >&2
	echo -e "${CYAN} = = > Eligible Files:${NC} ${#filtered[@]}" >&2
	echo -e "${CYAN} = = > CSV Rows Loaded:${NC} ${#csv_rows[@]}" >&2
	echo -e "${CYAN} = = > Planned Renames:${NC} ${#plan_rows[@]}" >&2
	echo >&2

	for line in "${plan_rows[@]}"; do
		old_name="${line%%|*}"
		new_name="${line#*|}"
		echo -e "  ${GREEN}${old_name}${NC} ${YELLOW}-->${NC} ${GREEN}${new_name}${NC}" >&2
	done
	echo >&2

	printf '%s\n' "${plan_rows[@]}"
	return 0
}

# =========================================================
# MARKER: OEM FINALIZE CHOICE STATE
# =========================================================
# Stores the user's OEM disposition choice during the
# finalize flow. We PROMPT early, but EXECUTE later only
# after parity + promotion have succeeded.
#
# VALUES:
#   archive
#   leave
#   dump
#   mark
# =========================================================
OEM_FINALIZE_CHOICE=""

# start of Show How Much Space Current Working Directory And OEM Folder Are Using

ui_show_folder_state_snapshot() {
	local cwd cwd_display drive_display
	local free_gb free_color free total
	local OEM_size="0"

	cwd="$(pwd)"
	drive_display="$(get_drive_display "$cwd")"
	cwd_display="$(trim_working_path_display "$cwd" 3)"

	echo -e "${GREEN} = = > Working Drive/Folder:${NC} [${YELLOW}$drive_display${NC}] ${YELLOW}$cwd_display${NC}"

	free_gb=$(df -BG . | awk 'NR==2 {gsub("G","",$4); print $4}')

	if (( free_gb < 20 )); then
		free_color=$RED
	elif (( free_gb < 50 )); then
		free_color=$YELLOW
	else
		free_color=$GREEN
	fi

	read -r free total <<< "$(df -h . | awk 'NR==2 {print $4, $2}')"

	echo -e "${free_color} = = > $free${NC} ${YELLOW}<-- Total${NC}"
	echo -e "${free_color} = = >  ^ Free Space${NC}"
	echo

	shopt -s nullglob nocaseglob

	local -a all_videos=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	local -a smc_files=(SMC_*.mkv)
	local -a rekey_files=(REKEY_*.mkv)
	local -a barfix_files=(BARFIX_*.mkv)
	local -a subpacked_files=(SUBPACKED_*)
	local -a csv_files=(*.csv)

	local -a original_videos=()
	local f

	for f in "${all_videos[@]}"; do
		[[ -f "$f" ]] || continue

		case "${f^^}" in
			SMC_*|REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*)
				continue
				;;
		esac

		original_videos+=("$f")
	done

	shopt -u nullglob nocaseglob

	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > WORKING DIRECTORY SNAPSHOT${NC}"
	echo -e "${CYAN}============================================================${NC}"

	echo -e "${CYAN} = = > Video Files Total:${NC} ${YELLOW}${#all_videos[@]}${NC}"
	echo -e "${CYAN} = = > Original-Looking Videos:${NC} ${YELLOW}${#original_videos[@]}${NC}"
	echo -e "${CYAN} = = > SMC_* Outputs:${NC} ${YELLOW}${#smc_files[@]}${NC}"
	echo -e "${CYAN} = = > REKEY_* Outputs:${NC} ${YELLOW}${#rekey_files[@]}${NC}"
	echo -e "${CYAN} = = > BARFIX_* Outputs:${NC} ${YELLOW}${#barfix_files[@]}${NC}"
	echo -e "${CYAN} = = > SUBPACKED_* Outputs:${NC} ${YELLOW}${#subpacked_files[@]}${NC}"
	echo -e "${CYAN} = = > CSV Files:${NC} ${YELLOW}${#csv_files[@]}${NC}"
	echo

	if [[ -d OEM ]]; then
		local oem_total_files oem_smc_files oem_rekey_files
		local oem_barfix_files oem_subtox_files latest_oem_run

		OEM_size="$(du -sh OEM 2>/dev/null | awk '{print $1}')"

		oem_total_files="$(find OEM -type f 2>/dev/null | wc -l)"
		oem_smc_files="$(find OEM -path '*/SMC/*' -type f 2>/dev/null | wc -l)"
		oem_rekey_files="$(find OEM -path '*/REKEY/*' -type f 2>/dev/null | wc -l)"
		oem_barfix_files="$(find OEM -path '*/BARFIX/*' -type f 2>/dev/null | wc -l)"
		oem_subtox_files="$(find OEM -path '*/SUBTOX/*' -type f 2>/dev/null | wc -l)"

		latest_oem_run="$(
			find OEM -maxdepth 1 -type d -name 'run_*' -printf '%f\n' 2>/dev/null \
			| sort \
			| tail -1
		)"

		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN} = = > OEM ARCHIVE SNAPSHOT${NC}"
		echo -e "${CYAN}============================================================${NC}"

		echo -e "${GREEN} = = > OEM Directory Present:${NC} ${YELLOW}${OEM_size}${NC}"
		echo -e "${CYAN} = = > OEM Archived Files Total:${NC} ${YELLOW}${oem_total_files}${NC}"
		echo -e "${CYAN} = = > OEM SMC Archived Files:${NC} ${YELLOW}${oem_smc_files}${NC}"
		echo -e "${CYAN} = = > OEM REKEY Archived Files:${NC} ${YELLOW}${oem_rekey_files}${NC}"
		echo -e "${CYAN} = = > OEM BARFIX Archived Files:${NC} ${YELLOW}${oem_barfix_files}${NC}"
		echo -e "${CYAN} = = > OEM SUBTOX Archived Files:${NC} ${YELLOW}${oem_subtox_files}${NC}"
		echo -e "${CYAN} = = > Latest OEM Run:${NC} ${YELLOW}${latest_oem_run:-none}${NC}"
	else
		echo -e "${YELLOW} = = > OEM/ Directory Not Present${NC}"
	fi

	echo

	if [[ -d intro_template ]]; then
		echo -e "${GREEN} = = > intro_template/ Directory Present${NC}"
	else
		echo -e "${YELLOW} = = > intro_template/ Directory Not Present${NC}"
	fi

	if [[ -f "$INTRO_MAP" ]]; then
		echo -e "${GREEN} = = > ${INTRO_MAP} Present${NC}"
	else
		echo -e "${YELLOW} = = > ${INTRO_MAP} Not Present Yet${NC}"
	fi
pause
}

ui_show_cleanup_target_snapshot() {
	local -a temp_targets=()
	local -a template_targets=()
	local -a detect_targets=()
	local -a finished_targets=()

	mapfile -t temp_targets < <(cleanup_collect_temp_targets)
	mapfile -t template_targets < <(cleanup_collect_template_targets)
	mapfile -t detect_targets < <(cleanup_collect_detection_targets)
	mapfile -t finished_targets < <(cleanup_collect_finished_targets)

	echo
	echo -e "${CYAN} = = > Temp / junk targets:${NC} ${YELLOW}${#temp_targets[@]}${NC}"
	echo -e "${CYAN} = = > Template targets:${NC} ${YELLOW}${#template_targets[@]}${NC}"
	echo -e "${CYAN} = = > Detection map / CSV targets:${NC} ${YELLOW}${#detect_targets[@]}${NC}"
	echo -e "${CYAN} = = > Finished SMC outputs:${NC} ${YELLOW}${#finished_targets[@]}${NC}"
}


# =========================
# #MARKER: FOLDER SIZE HELPERS
# =========================
# PURPOSE:
# - Show How Much Space Current Working Directory And OEM Folder Are Using
# - Help User Decide Whether To Archive Or Delete Before Cleanup
#
# WHY THIS EXISTS:
# - Video Workflows Expand Fast (REKEY + SMC + OEM Copies)
# - User Needs Immediate Visibility Into Disk Impact Before Destructive Steps
#
# OUTPUT:
# - Human-readable sizes (du -sh style)
#
get_folder_size_human() {
	local path="${1:-.}"

	if [[ -d "$path" ]]; then
		du -sh -- "$path" 2>/dev/null | awk '{print $1}'
	else
		printf '%s\n' "N/A"
	fi
}

# =========================
# #MARKER: WORKING DIR + OEM SIZE DISPLAY
# =========================
# PURPOSE:
# - Show Current Disk Free + Working Dir Size + OEM Folder Size Together
# - Called Before Finalize / Destructive Operations
#
show_space_overview() {
	local cwd wd_size OEM_size drive_display
	local free total free_color free_gb

	cwd="$(pwd)"
	drive_display="$(get_drive_display "$cwd")"
    cwd_display="$(trim_working_path_display "$cwd" 3)"

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        SPACE OVERVIEW / WORKING CONTEXT         ${NC}"
	echo -e "${CYAN}================================================${NC}"

	# Working folder path
	echo -e "${GREEN} = = > Working Drive/Folder:${NC} [${YELLOW}$drive_display${NC}] ${YELLOW}$cwd_display${NC}"

	# Disk free (reuse existing logic style)
	free_gb=$(df -BG . | awk 'NR==2 {gsub("G","",$4); print $4}')

	if (( free_gb < 20 )); then
		free_color=$RED
	elif (( free_gb < 50 )); then
		free_color=$YELLOW
	else
		free_color=$GREEN
	fi

	read -r free total <<< "$(df -h . | awk 'NR==2 {print $4, $2}')"

    echo -e "${free_color} = = > $free${NC} ${YELLOW}<-- Total${NC}"
    echo -e "${free_color} = = >  ^ Free Space${NC}"

	# Working dir size
	wd_size="$(get_folder_size_human ".")"
	echo -e "${CYAN} = = > Working Dir Size:${NC} ${YELLOW}$wd_size${NC}"

	# OEM folder size
	OEM_size="$(get_folder_size_human "./OEM")"
	echo -e "${CYAN} = = > OEM Folder Size:${NC} ${YELLOW}$OEM_size${NC}"

	echo
}

# end of Show How Much Space Current Working Directory And OEM Folder

# =========================
# #MARKER: INFO CSV LOOKUP BY WORKING NAME
# =========================
# PURPOSE:
# - Allow Reverse Lookup When We Already Know The Candidate Working File
#   (Example: REKEY_My_Show_S01E01.mkv) And Want To See Whether info.csv
#   Already Trusts It.
#
# WHY THIS EXISTS:
# - get_preferred_source_file() Naturally Thinks In Terms Of:
#     current source -> candidate REKEY path
# - But The Ledger Is Anchored By raw_name.
# - This helper lets us search by working_name without guessing wrong.
#
# OUTPUT:
# - Full CSV Row On Stdout
# - Empty If No Match
#
info_lookup_working_row() {
    local working="$1"
    ensure_info_map

    awk -F',' -v q="\"$working\"" '
        NR==1 { next }
        $2 == q { row=$0 }
        END { if(row!="") print row }
    ' "$INFO_MAP"
}

# =========================
# #MARKER: INFO CSV FIELD GETTERS BY WORKING NAME
# =========================
# PURPOSE:
# - Read Ledger State Using working_name As The Anchor.
# - This Is Useful For Cache-Aware REKEY Reuse Decisions.
#
info_get_raw_name_by_working() {
    local working="$1"
	# ========================================================
	# CANONICALIZE WORKING KEY ON ENTRY
	# ========================================================
	working="$(canonical_factory_path "$working")"
    local row
    row="$(info_lookup_working_row "$working")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $1); gsub(/""/, "\"", $1); print $1}'
}

info_get_auth_rekey_by_working() {
    local working="$1"
	# ========================================================
	# CANONICALIZE WORKING KEY ON ENTRY
	# ========================================================
	working="$(canonical_factory_path "$working")"
    local row
    row="$(info_lookup_working_row "$working")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $3); print $3}'
}

info_get_validated_once_by_working() {
    local working="$1"
	# ========================================================
	# CANONICALIZE WORKING KEY ON ENTRY
	# ========================================================
	working="$(canonical_factory_path "$working")"
    local row
    row="$(info_lookup_working_row "$working")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $4); print $4}'
}

info_get_keyframe_verdict_by_working() {
    local working="$1"
	# ========================================================
	# CANONICALIZE WORKING KEY ON ENTRY
	# ========================================================
	working="$(canonical_factory_path "$working")"
    local row
    row="$(info_lookup_working_row "$working")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $5); print $5}'
}

info_get_keyframe_checked_path_by_working() {
    local working="$1"
	# ========================================================
	# CANONICALIZE WORKING KEY ON ENTRY
	# ========================================================
	working="$(canonical_factory_path "$working")"
    local row
    row="$(info_lookup_working_row "$working")"
    [[ -z "$row" ]] && return 1
    printf '%s\n' "$row" | awk -F',' '{gsub(/^"|"$/, "", $7); gsub(/""/, "\"", $7); print $7}'
}



# =========================
# #MARKER: TRUST CHECK FOR CACHED REKEY CANDIDATE
# =========================
# PURPOSE:
# - Decide Whether A Candidate REKEY File Can Be Trusted Immediately
#   From info.csv Without Running Another Expensive Validation Probe.
#
# TRUST RULE:
# - working_name must match the candidate REKEY path
# - auth_rekey must be 1
# - validated_once must be 1
# - raw_name row must still match current raw-file signature
#
# IMPORTANT:
# - This Is A SPEED CACHE, Not A Blind Faith Machine.
# - If The Raw File Changed, The Cache Is Stale And Must Be Ignored.
#
cached_rekey_is_trusted_for_raw() {
    local raw="$1"
    local rekey="$2"
    local cached_raw auth validated verdict
	# ========================================================
	# CANONICALIZE BOTH COMPARISON SIDES ON ENTRY
	# ========================================================
	# WHY:
	# - Trust checks compare raw source identity and working REKEY identity.
	# - Both must be normalized before any exact-match tests.
	raw="$(canonical_factory_path "$raw")"
	rekey="$(canonical_factory_path "$rekey")"

    [[ -f "$rekey" ]] || return 1

    cached_raw="$(info_get_raw_name_by_working "$rekey" 2>/dev/null || true)"
	# ========================================================
	# CANONICALIZE CACHED RAW NAME BEFORE COMPARISON
	# ========================================================
	cached_raw="$(canonical_factory_path "$cached_raw")"
    auth="$(info_get_auth_rekey_by_working "$rekey" 2>/dev/null || true)"
    validated="$(info_get_validated_once_by_working "$rekey" 2>/dev/null || true)"
    verdict="$(info_get_keyframe_verdict_by_working "$rekey" 2>/dev/null || true)"

    [[ -n "$cached_raw" ]] || return 1
    [[ "$cached_raw" == "$raw" ]] || return 1
    [[ "$auth" == "1" ]] || return 1
    [[ "$validated" == "1" ]] || return 1

    # Cache row must still be current for the raw file.
    info_cache_is_current "$raw" || return 1

    # IMPORTANT:
    # - SAFE is ideal.
    # - CAUTION may still be trusted if future-you already accepted it once.
    # - RISKY / UNKNOWN are allowed here only because validated_once means
    #   the expensive verdict has already been deliberately recorded.
    #
    case "$verdict" in
        SAFE|CAUTION|RISKY|UNKNOWN)
            return 0
            ;;
    esac

    return 1
}

# end of INFO CSV LOOKUP BY WORKING NAME

# ============================================================
# #MARKER: GLOBAL TEXT / COMMAND HELPERS
# ============================================================
# PURPOSE:
# - Hold Small Reusable Helpers Shared Across Multiple Missions.
# - Keep One Authoritative Copy To Avoid Drift And Shadowing.
#
# IMPORTANT:
# - Do NOT Redefine These Later In The Script.
# - If Behavior Changes, Update Here Only.
# ============================================================
# #MARKER: COMMAND EXISTENCE HELPER (have_cmd)
# ============================================================
# PURPOSE:
# - Provide A Clean, Readable Way To Check If A Command Exists.
# - Replace Repeated, Noisy Patterns Like:
#     command -v foo >/dev/null 2>&1
#
# WHY THIS EXISTS:
# - The Script Checks For Many Tools Across Multiple Missions.
# - Repeating command -v Everywhere Makes Logic Harder To Read.
# - This Helper Standardizes The Check Into A Single, Readable Call.
#
# DESIGN:
# - Returns Success (0) If Command Exists
# - Returns Failure (Non-Zero) If Command Is Missing
# - Silent (No Output) So It Can Be Safely Used In Conditionals
#
# USAGE EXAMPLES:
# - if have_cmd ffmpeg; then ...
# - if ! have_cmd mkvpropedit; then fallback...
#
# IMPORTANT:
# - This Helper MUST Be Defined Before Any Function That Uses It.
# - Safe To Use In All Script Sections (Global + Functions).
#
have_cmd() {
	command -v "$1" >/dev/null 2>&1
}
# have_cmd ends here


    # =========================
    # #MARKER: ENSURE intro_template WORKDIR
    # =========================
ensure_intro_template_dir() {
	local repo="${INTRO_TEMPLATE_DIR:-${FACTORY_HOME}/intro_template}"
	local work_link="${FACTORY_WORKDIR}/intro_template"
	local work_count=0

	mkdir -p "$repo"

	work_count="$(factory_count_template_media "$work_link")"

	if [[ "$repo" == "$work_link" ]]; then
		mkdir -p "$work_link"
		return 0
	fi

	if [[ -e "$work_link" && ! -L "$work_link" ]]; then
		if (( work_count > 0 )); then
			echo -e "${YE} = = > Working intro_template/ Contains Real Templates. Leaving It In Place.${NC}"
			return 0
		fi

		rmdir "$work_link" 2>/dev/null || {
			echo -e "${YE} = = > Empty Working intro_template/ Could Not Be Removed. Leaving It In Place.${NC}"
			return 0
		}
	fi

	if [[ -L "$work_link" ]]; then
		rm -f "$work_link"
	fi

	ln -s "$repo" "$work_link" 2>/dev/null || {
		echo -e "${YE} = = > Could Not Link intro_template -> Template Authority.${NC}"
		echo -e "${YE} = = > Template Authority Still Is:${NC} ${YELLOW}$(factory_display_path "$repo")${NC}"
	}
}

# ============================================================
# #MARKER: TITLECASE WORDS HELPER
# ============================================================
# PURPOSE:
# - Convert Space-Separated Words Into Display-Friendly Title Case.
# - Used For Human-Readable Metadata / Title-Bar Style Output.
#
# INPUT:
# - Plain Text On Stdin
#
# OUTPUT:
# - Same Text With Each Word Uppercased On First Letter And Lowercased After
#
titlecase_words() {
  awk '{
    for(i=1;i<=NF;i++){
      w=$i
      if(length(w)>0){
        w=toupper(substr(w,1,1)) tolower(substr(w,2))
      }
      $i=w
    }
    print
  }'
}

# Make Displayed TitleBar Title that ur player shows up in the titlebar 

# ============================================================
# #MARKER: TITLE FROM FILENAME HELPER
# ============================================================
# PURPOSE:
# - Build A Clean Display Title From Underscore-Based Filenames.
# - Drop SxxExx Tokens From The Title-Bar Result.
# - Start From User-Chosen Underscore Segment.
#
# EXAMPLE:
# - File: My_Show_S01E01_The_Beginning.mkv
# - Segment Start: 3
# - Result: The Beginning
#
# IMPORTANT:
# - Filename Itself Is NOT Changed Here.
# - This Helper Is For Metadata/Display-Title Generation Only.
#
make_title_from_filename() {
	local file="${1:-}"
	local seg="${2:-3}"
	local base="${file%.*}"
	local sliced

	# ========================================================
	# SAFETY:
	# - This helper may be called from multiple missions.
	# - Under set -u, a missing $2 would hard-crash if we used:
	#     local seg="$2"
	# - Default to segment 3, which matches the most common
	#   "show_prefix + SxxExx + title..." filename layout.
	#
	# TWO-PART / JOINED EPISODE SUPPORT:
	# - S04E08andE09_Title
	# - S04E08-S04E09_Title
	# - S04E08-E09_Title
	# - S04E18_E19_Title
	# ========================================================

	base="$(basename "$base")"
	base="$(strip_workflow_prefixes "$base")"
	base="$(echo "$base" | sed -E 's/_+/_/g; s/^_+//; s/_+$//')"

	# Prefer the explicit after-episode-block parser when an SxxExx token exists.
	if [[ "$base" =~ [Ss][0-9]{2}[Ee][0-9]{2} ]]; then
		barfix_title_after_episode_block "$base" | titlecase_words
		return 0
	fi

	# Fallback for non-SxxExx names: old segment-based behavior.
	sliced="$(echo "$base" | awk -v s="$seg" -F'_' '
		BEGIN{ IGNORECASE=1 }
		{
			if(s<1) s=1
			out=""
			for(i=s;i<=NF;i++){
				if($i ~ /^S[0-9]{2}E[0-9]{2}$/) continue
				out = out (out=="" ? "" : "_") $i
			}
			print out
		}')"

	echo "$sliced" | tr '_' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//' | titlecase_words
}
# End Of make_title_from_filename

show_working_folder_and_disk_free() {
    local cwd cwd_display drive_display
    local free_gb free_color free total

    cwd="$(pwd)"
    drive_display="$(get_drive_display "$cwd")"
    cwd_display="$(trim_working_path_display "$cwd" 3)"

    echo -e "${GREEN} = = > Working Drive/Folder:${NC} [${YELLOW}$drive_display${NC}] ${YELLOW}$cwd_display${NC}"

    # Disk space (important due to copy/processing growth)
    free_gb=$(df -BG . | awk 'NR==2 {gsub("G","",$4); print $4}')

    if (( free_gb < 20 )); then
        free_color=$RED
    elif (( free_gb < 50 )); then
        free_color=$YELLOW
    else
        free_color=$GREEN
    fi

    read -r free total <<< "$(df -h . | awk 'NR==2 {print $4, $2}')"

    echo -e "${CYAN} = = > Disk Free:${NC} ${free_color}$free${NC} Free / ${YELLOW}$total${NC} Total"
}

trim_mount_source_display() {
	local src="$1"

	# Split on /
	IFS='/' read -r -a parts <<< "$src"

	# If 3 or more segments, drop first 2
	if (( ${#parts[@]} >= 3 )); then
		printf '%s\n' "${parts[@]:2}" | paste -sd '/'
	else
		printf '%s\n' "$src"
	fi
}

# =========================
# #MARKER: DRIVE LABEL HELPER
# =========================
# PURPOSE:
# - Always show human-readable drive label first
# - Fallback to mount source if label not available
# - Centralized so all menus display consistently
#
get_drive_display() {
	local path="${1:-.}"
	local mount_src="" mount_label=""

	if have_cmd findmnt; then
		mount_src=$(findmnt -no SOURCE --target "$path" 2>/dev/null || true)
		mount_label=$(findmnt -no LABEL --target "$path" 2>/dev/null || true)
	fi

	if [[ -n "$mount_label" ]]; then
		printf '%s\n' "$mount_label"
    elif [[ -n "$mount_src" ]]; then
    	local trimmed
    	trimmed="$(trim_mount_source_display "$mount_src")"
	    printf '%s\n' "$trimmed"
	else
		printf '%s\n' "unknown-drive"
	fi
}

trim_working_path_display() {
	local path="${1:-}"
	local start_seg="${2:-3}"

	[[ -z "$path" ]] && return 0

	# Prefer meaningful Factory-relative paths first.
	case "$path" in
		"$FACTORY_WORKDIR"/*)
			printf './%s\n' "${path#"$FACTORY_WORKDIR"/}"
			return 0
			;;
		"$FACTORY_HOME"/*)
			printf 'TOOLBOX/%s\n' "${path#"$FACTORY_HOME"/}"
			return 0
			;;
		"$HOME"/*)
			printf '~/%s\n' "${path#"$HOME"/}"
			return 0
			;;
	esac

	# Trim Linux mount UUID / device root noise:
	# /mnt/<uuid>/MEDIA/MOVIES/... -> MEDIA/MOVIES/...
	case "$path" in
		/mnt/*/*)
			printf '%s\n' "${path#/mnt/*/}"
			return 0
			;;
		/media/*/*)
			printf '%s\n' "${path#/media/*/}"
			return 0
			;;
	esac

	# Fallback: old segment-based trimmer.
	local -a parts=()
	IFS='/' read -r -a parts <<< "$path"

	if [[ -z "${parts[0]:-}" ]]; then
		parts=("${parts[@]:1}")
	fi

	if (( ${#parts[@]} >= start_seg )); then
		printf '/%s\n' "$(printf '%s/' "${parts[@]:$((start_seg-1))}" | sed 's:/$::')"
	else
		printf '%s\n' "$path"
	fi
}

# =========================
# #MARKER: SECONDS → HH:MM:SS
# =========================
# PURPOSE:
# - Convert float seconds into HH:MM:SS (rounded down)
#
# - mainly for exporting to csv in human quick read format
#
seconds_to_hms() {
	local s="${1%.*}"  # strip decimals

	local h=$(( s / 3600 ))
	local m=$(( (s % 3600) / 60 ))
	local sec=$(( s % 60 ))

	printf "%02d:%02d:%02d\n" "$h" "$m" "$sec"
}

# ================================================================
# #MARKER: FILE DURATION SECONDS
# ================================================================
get_file_duration_seconds() {
	local file="$1"

	ffprobe -v error \
		-show_entries format=duration \
		-of default=noprint_wrappers=1:nokey=1 \
		"$file" 2>/dev/null |
	awk '{printf "%.3f", $1}'
}

# ================================================================
# #MARKER: INTRO STRUCTURAL FINGERPRINT LOADER
# ================================================================
# PURPOSE:
# - Locate and read an existing intro fingerprint report.
# - Expose report values for display only.
#
# IMPORTANT:
# - Does NOT alter IntroFind anchors, steps, hash mode, or scan range.
# - Does NOT make the fingerprint authoritative.
#
# SETS:
# - INTRO_FINGERPRINT_FILE
# - INTRO_FINGERPRINT_VERSION
# - INTRO_FINGERPRINT_AUTO_A
# - INTRO_FINGERPRINT_AUTO_B
# - INTRO_FINGERPRINT_LOADED
# ================================================================
load_intro_template_fingerprint() {
	local report=""
	local temporal_usable=""
	local structural_usable=0
	local -a reports=()

	INTRO_FINGERPRINT_FILE=""
	INTRO_FINGERPRINT_VERSION=""
	INTRO_FINGERPRINT_AUTO_A=""
	INTRO_FINGERPRINT_AUTO_B=""
	INTRO_FINGERPRINT_SCOUT_MODE=""
	INTRO_FINGERPRINT_LOADED=0

	resolve_intro_template_authority >/dev/null 2>&1 || return 1

	shopt -s nullglob nocaseglob
	reports=(
		"$INTRO_TEMPLATE_DIR"/intro*.fingerprint.txt
	)
	shopt -u nullglob nocaseglob

	if (( ${#reports[@]} == 0 )); then
		return 1
	fi

	report="${reports[0]}"

	INTRO_FINGERPRINT_VERSION="$(
		sed -n 's/^Analysis Version:[[:space:]]*//p' "$report" |
			head -n 1
	)"

	INTRO_FINGERPRINT_AUTO_A="$(
		sed -n 's/^auto-a:[[:space:]]*//p' "$report" |
			head -n 1
	)"

	INTRO_FINGERPRINT_AUTO_B="$(
		sed -n 's/^auto-b:[[:space:]]*//p' "$report" |
			head -n 1
	)"

	if grep -E \
		'^(natural|sensitive|dark-vision|content-vision): .*weak=NO' \
		"$report" \
		>/dev/null 2>&1
	then
		structural_usable=1
	fi

	temporal_usable="$(
		sed -n \
			'/^TEMPORAL VISUAL QUALITY$/,/^TEMPORAL VISUAL SIGNATURE$/p' \
			"$report" |
			sed -n 's/.*usable=\(YES\|NO\).*/\1/p' |
			head -n 1
	)"

	if (( structural_usable == 1 )); then
		INTRO_FINGERPRINT_SCOUT_MODE="structural"
	elif [[ "$temporal_usable" == "YES" ]]; then
		INTRO_FINGERPRINT_SCOUT_MODE="temporal"
	else
		INTRO_FINGERPRINT_SCOUT_MODE="none"
	fi

	if [[ -z "$INTRO_FINGERPRINT_VERSION" ||
	      -z "$INTRO_FINGERPRINT_AUTO_A" ||
	      -z "$INTRO_FINGERPRINT_AUTO_B" ]]; then
		return 1
	fi

	INTRO_FINGERPRINT_FILE="$report"
	INTRO_FINGERPRINT_LOADED=1

	export \
		INTRO_FINGERPRINT_FILE \
		INTRO_FINGERPRINT_VERSION \
		INTRO_FINGERPRINT_AUTO_A \
		INTRO_FINGERPRINT_AUTO_B \
		INTRO_FINGERPRINT_SCOUT_MODE \
		INTRO_FINGERPRINT_LOADED

	return 0
}

# ================================================================
# #MARKER: AUDIO WAVEFORM FINGERPRINT / SHADOW WITNESS
# ================================================================
# PURPOSE:
# - Build a compact normalized audio-energy fingerprint beside an intro template.
# - Compare that fingerprint near an already-confirmed visual IntroFind result.
# - Report audio agreement and timing offset without changing the visual result.
#
# OUTPUT:
# - intro_template.audiofp.csv
# - intro_template_1.audiofp.csv
# - etc.
#
# CURRENT POLICY:
# - SHADOW / REPORT-ONLY.
# - Audio cannot approve, reject, or move an IntroFind result yet.
# ================================================================

build_audio_waveform_fingerprint() {
	local template="$1"
	local fingerprint="${template%.*}.audiofp.csv"
	local tmp_raw=""

	if (( "$(media_audio_stream_count "$template" 2>/dev/null || printf '0')" == 0 )); then
		echo -e "${YE} = = > Audio Fingerprint Skipped: Template Has No Audio.${NC}"
		rm -f -- "$fingerprint"
		return 0
	fi

	tmp_raw="$(mktemp "${TMPDIR:-/tmp}/factory_audio_template.XXXXXX.raw")" || return 1

	echo -e "${CYAN} = = > Fingerprint Pass 6:${NC} ${YELLOW}Audio Waveform Signature...${NC}"

	if ! ffmpeg \
		-hide_banner \
		-loglevel error \
		-nostdin \
		-y \
		-i "$template" \
		-map 0:a:0 \
		-vn \
		-sn \
		-dn \
		-ac 1 \
		-ar 8000 \
		-f s16le \
		"$tmp_raw"
	then
		rm -f -- "$tmp_raw" "$fingerprint"
		echo -e "${YE} = = > Audio Fingerprint Could Not Decode Template Audio.${NC}"
		return 0
	fi

	if ! python3 - "$tmp_raw" "$fingerprint" <<'PY'
import array
import csv
import math
import statistics
import sys
from pathlib import Path

raw_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])

sample_rate = 8000
bucket_seconds = 0.1
bucket_samples = int(sample_rate * bucket_seconds)

samples = array.array("h")
with raw_path.open("rb") as handle:
    samples.frombytes(handle.read())

if sys.byteorder != "little":
    samples.byteswap()

energies = []

for offset in range(0, len(samples), bucket_samples):
    block = samples[offset:offset + bucket_samples]

    if len(block) < bucket_samples // 2:
        break

    rms = math.sqrt(
        sum(float(value) * float(value) for value in block) / len(block)
    )

    energies.append(math.log1p(rms))

if len(energies) < 10:
    raise SystemExit(1)

median = statistics.median(energies)
deviations = [abs(value - median) for value in energies]
mad = statistics.median(deviations)

if mad < 1e-9:
    mad = 1.0

normalized = [
    max(-6.0, min(6.0, (value - median) / mad))
    for value in energies
]

with output_path.open("w", newline="") as handle:
    writer = csv.writer(handle)
    writer.writerow([
        "time",
        "normalized_energy",
        "delta_from_previous",
    ])

    previous = normalized[0]

    for index, value in enumerate(normalized):
        delta = 0.0 if index == 0 else value - previous

        writer.writerow([
            f"{index * bucket_seconds:.3f}",
            f"{value:.6f}",
            f"{delta:.6f}",
        ])

        previous = value
PY
	then
		rm -f -- "$tmp_raw" "$fingerprint"
		echo -e "${YE} = = > Audio Fingerprint Could Not Build A Usable Signature.${NC}"
		return 0
	fi

	rm -f -- "$tmp_raw"

	echo -e "${GR} = = > Audio Fingerprint Created:${NC} ${GREEN}$(factory_display_path "$fingerprint")${NC}"
	return 0
}


run_audio_waveform_witness() {
	local episode="$1"
	local visual_start="$2"
	local template="$3"

	local fingerprint="${template%.*}.audiofp.csv"
	local template_duration=""
	local window_start=""
	local window_duration=""
	local tmp_raw=""
	local witness_result=""

	if [[ ! -f "$fingerprint" ]]; then
		echo -e "${YE} = = > Audio Witness Skipped: No Audio Fingerprint For Winning Key.${NC}"
		return 0
	fi

	if (( "$(media_audio_stream_count "$episode" 2>/dev/null || printf '0')" == 0 )); then
		echo -e "${YE} = = > Audio Witness Skipped: Episode Has No Audio.${NC}"
		return 0
	fi

	template_duration="$(get_file_duration_seconds "$template" 2>/dev/null || true)"

	if [[ -z "$template_duration" ||
	      ! "$template_duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
		echo -e "${YE} = = > Audio Witness Skipped: Template Duration Unavailable.${NC}"
		return 0
	fi

	window_start="$(awk -v s="$visual_start" 'BEGIN {
		v=s-1.5
		if (v < 0) v=0
		printf "%.3f", v
	}')"

	window_duration="$(awk -v d="$template_duration" 'BEGIN {
		printf "%.3f", d+3.0
	}')"

	tmp_raw="$(mktemp "${TMPDIR:-/tmp}/factory_audio_witness.XXXXXX.raw")" || return 0

	if ! ffmpeg \
		-hide_banner \
		-loglevel error \
		-nostdin \
		-y \
		-ss "$window_start" \
		-i "$episode" \
		-t "$window_duration" \
		-map 0:a:0 \
		-vn \
		-sn \
		-dn \
		-ac 1 \
		-ar 8000 \
		-f s16le \
		"$tmp_raw"
	then
		rm -f -- "$tmp_raw"
		echo -e "${YE} = = > Audio Witness Skipped: Episode Audio Could Not Be Decoded.${NC}"
		return 0
	fi

	witness_result="$(
		python3 - \
			"$fingerprint" \
			"$tmp_raw" \
			"$window_start" \
			"$visual_start" <<'PY'
import array
import csv
import math
import statistics
import sys
from pathlib import Path

fingerprint_path = Path(sys.argv[1])
raw_path = Path(sys.argv[2])
window_start = float(sys.argv[3])
visual_start = float(sys.argv[4])

sample_rate = 8000
bucket_seconds = 0.1
bucket_samples = int(sample_rate * bucket_seconds)

template = []

with fingerprint_path.open(newline="", errors="replace") as handle:
    reader = csv.DictReader(handle)

    for row in reader:
        try:
            template.append(float(row["normalized_energy"]))
        except (KeyError, TypeError, ValueError):
            pass

samples = array.array("h")

with raw_path.open("rb") as handle:
    samples.frombytes(handle.read())

if sys.byteorder != "little":
    samples.byteswap()

episode_energy = []

for offset in range(0, len(samples), bucket_samples):
    block = samples[offset:offset + bucket_samples]

    if len(block) < bucket_samples // 2:
        break

    rms = math.sqrt(
        sum(float(value) * float(value) for value in block) / len(block)
    )

    episode_energy.append(math.log1p(rms))

if len(template) < 10 or len(episode_energy) < len(template):
    print("AUDIO_WITNESS|status=UNAVAILABLE")
    raise SystemExit(0)

median = statistics.median(episode_energy)
deviations = [abs(value - median) for value in episode_energy]
mad = statistics.median(deviations)

if mad < 1e-9:
    mad = 1.0

episode_normalized = [
    max(-6.0, min(6.0, (value - median) / mad))
    for value in episode_energy
]


def correlation(left, right):
    count = min(len(left), len(right))

    if count < 10:
        return -1.0

    left = left[:count]
    right = right[:count]

    left_mean = sum(left) / count
    right_mean = sum(right) / count

    numerator = sum(
        (a - left_mean) * (b - right_mean)
        for a, b in zip(left, right)
    )

    left_power = sum((a - left_mean) ** 2 for a in left)
    right_power = sum((b - right_mean) ** 2 for b in right)

    denominator = math.sqrt(left_power * right_power)

    if denominator <= 1e-12:
        return -1.0

    return numerator / denominator


best_score = -1.0
best_index = 0

maximum_start = len(episode_normalized) - len(template)

for index in range(maximum_start + 1):
    candidate = episode_normalized[index:index + len(template)]
    score = correlation(template, candidate)

    if score > best_score:
        best_score = score
        best_index = index

audio_start = window_start + best_index * bucket_seconds
offset = audio_start - visual_start
score_percent = max(0.0, min(100.0, best_score * 100.0))

if score_percent >= 90.0 and abs(offset) <= 0.35:
    status = "STRONG"
elif score_percent >= 75.0 and abs(offset) <= 0.75:
    status = "SUPPORTS"
elif score_percent >= 55.0:
    status = "WEAK"
else:
    status = "DISAGREES"

print(
    "AUDIO_WITNESS"
    f"|status={status}"
    f"|score={score_percent:.1f}"
    f"|offset={offset:+.3f}"
    f"|audio_start={audio_start:.3f}"
)
PY
	)"

	rm -f -- "$tmp_raw"

	local status=""
	local score=""
	local offset=""
	local audio_start=""

	status="$(printf '%s\n' "$witness_result" |
		sed -nE 's/.*status=([^|]+).*/\1/p')"
	score="$(printf '%s\n' "$witness_result" |
		sed -nE 's/.*score=([^|]+).*/\1/p')"
	offset="$(printf '%s\n' "$witness_result" |
		sed -nE 's/.*offset=([^|]+).*/\1/p')"
	audio_start="$(printf '%s\n' "$witness_result" |
		sed -nE 's/.*audio_start=([^|]+).*/\1/p')"

	echo
	echo -e "${CYAN} = = > Audio Waveform Witness:${NC}"

	case "$status" in
		STRONG)
			echo -e "${GR}       Verdict:${NC} ${GREEN}STRONG${NC}"
			;;
		SUPPORTS)
			echo -e "${GR}       Verdict:${NC} ${GREEN}SUPPORTS${NC}"
			;;
		WEAK)
			echo -e "${YE}       Verdict:${NC} ${YELLOW}WEAK${NC}"
			;;
		DISAGREES)
			echo -e "${REB}       Verdict: DISAGREES${NC}"
			;;
		*)
			echo -e "${YE}       Verdict:${NC} ${YELLOW}UNAVAILABLE${NC}"
			echo -e "${CYAN}       Mode:${NC} ${YELLOW}Shadow / Report Only${NC}"
			return 0
			;;
	esac

	echo -e "${CYAN}       Score:${NC} ${YELLOW}${score}%${NC}"
	echo -e "${CYAN}       Audio Start:${NC} ${YELLOW}${audio_start}s${NC}"
	echo -e "${CYAN}       Visual Offset:${NC} ${YELLOW}${offset}s${NC}"
	echo -e "${CYAN}       Mode:${NC} ${YELLOW}Shadow / Report Only${NC}"
}

# ================================================================
# #MARKER: INTRO TEMPLATE STRUCTURAL FINGERPRINT REPORT
# ================================================================
# PURPOSE:
# - Analyze one intro template without changing IntroFind behavior.
# - Record scene layout and black/fade layout.
# - Suggest two different anchor families:
#     auto-a = broad, well-spaced stable scene anchors
#     auto-b = alternate anchors from different scene positions
#
# IMPORTANT:
# - This is report-only.
# - It does not yet control IntroFind.
# - Hash verification will be added only after reports are tested.
# ================================================================
run_intro_template_fingerprint_report() {
	local template=""
	local duration=""
	local template_base=""
	local report=""
	local tmpdir=""
	local scene_csv=""
	local sensitive_scene_csv=""
	local dark_scene_csv=""
	local content_scene_csv=""
	local dark_vision_file=""
	local temporal_signature=""
	local black_log=""
	local scene_status=0
	local -a templates=()

	resolve_intro_template_authority || return 1

	shopt -s nullglob nocaseglob
	templates=(
		"$INTRO_TEMPLATE_DIR"/intro*.mkv
	)
	shopt -u nullglob nocaseglob

	if (( ${#templates[@]} == 0 )); then
		echo -e "${YE} = = > No Intro Template Found In:${NC} ${YELLOW}$(factory_display_path "$INTRO_TEMPLATE_DIR")${NC}"
		pause
		return 0
	fi

	if (( ${#templates[@]} == 1 )); then
		template="${templates[0]}"
	else
		echo
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN}             INTRO TEMPLATE FINGERPRINT PICKER              ${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo

		local i choice

		for i in "${!templates[@]}"; do
			printf '%b%5d)%b %b%s%b\n' \
				"$YELLOW" "$((i + 1))" "$NC" \
				"$GREEN" "$(factory_display_path "${templates[$i]}")" "$NC"
		done

		echo
		prompt_menu_choice \
			" = = > Select Template [1-${#templates[@]} | 0.=return]: " \
			choice

		if is_exit_token "$choice"; then
			return 0
		fi

		if [[ ! "$choice" =~ ^[0-9]+$ ]] ||
		   (( choice < 1 || choice > ${#templates[@]} )); then
			echo -e "${REB} = = > Invalid Template Selection.${NC}"
			pause
			return 0
		fi

		template="${templates[$((choice - 1))]}"
	fi

	duration="$(get_file_duration_seconds "$template" 2>/dev/null || true)"

	if [[ -z "$duration" || ! "$duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
		echo -e "${REB} = = > Could Not Read Template Duration.${NC}"
		pause
		return 0
	fi

	template_base="$(basename "${template%.*}")"
	report="${INTRO_TEMPLATE_DIR}/${template_base}.fingerprint.txt"

	tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/factory_intro_fingerprint.XXXXXX")"
	scene_csv="$tmpdir/scenes.csv"
	sensitive_scene_csv="$tmpdir/scenes_sensitive.csv"
	dark_scene_csv="$tmpdir/scenes_dark.csv"
	content_scene_csv="$tmpdir/scenes_content.csv"
	dark_vision_file="$tmpdir/dark_vision.mkv"
	temporal_signature="$tmpdir/temporal_signature.csv"
	black_log="$tmpdir/blackdetect.log"

	trap '[[ -n "${tmpdir:-}" ]] && rm -rf -- "$tmpdir"; trap - RETURN' RETURN

	clear
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}          INTRO TEMPLATE STRUCTURAL FINGERPRINT             ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${CYAN} = = > Template:${NC} ${GREEN}$(factory_display_path "$template")${NC}"
	echo -e "${CYAN} = = > Duration:${NC} ${YELLOW}${duration}s${NC}"
	echo -e "${CYAN} = = > Press ${YEB}-> Q <-${NC}${CYAN} To Get Out Of The Reader:${NC}"
	echo

	# ------------------------------------------------------------
	# BLACK / FADE STRUCTURE
	# ------------------------------------------------------------
	echo -e "${CYAN} = = > Mapping Black / Near-Black Ranges...${NC}"

	ffmpeg \
		-hide_banner \
		-loglevel info \
		-nostdin \
		-i "$template" \
		-vf "blackdetect=d=0.20:pix_th=0.10" \
		-an \
		-f null - \
		2>&1 |
			sed -nE '
				s/.*black_start:([0-9.]+)[[:space:]]+black_end:([0-9.]+)[[:space:]]+black_duration:([0-9.]+).*/\1,\2,\3/p
			' > "$black_log"

	# ------------------------------------------------------------
	# CASCADING SCENE STRUCTURE
	# ------------------------------------------------------------
	if command -v scenedetect >/dev/null 2>&1; then
		echo -e "${CYAN} = = > Fingerprint Pass 1:${NC} ${YELLOW}Natural Scene Vision...${NC}"

		if scenedetect \
			-q \
			-i "$template" \
			-o "$tmpdir" \
			detect-adaptive \
			list-scenes \
				--skip-cuts \
				--filename "scenes.csv"
		then
			scene_status=0
		else
			scene_status=1
		fi

		echo -e "${CYAN} = = > Fingerprint Pass 2:${NC} ${YELLOW}Sensitive Scene Vision...${NC}"

		scenedetect \
			-q \
			-i "$template" \
			-o "$tmpdir" \
			detect-adaptive \
				--threshold 2.0 \
				--min-content-val 8.0 \
			list-scenes \
				--skip-cuts \
				--filename "scenes_sensitive.csv" \
			>/dev/null 2>&1 || :

		echo -e "${CYAN} = = > Fingerprint Pass 3:${NC} ${YELLOW}Dark Vision Gamma Expansion...${NC}"

		if ffmpeg \
			-hide_banner \
			-loglevel error \
			-nostdin \
			-y \
			-i "$template" \
			-vf "eq=gamma=1.8" \
			-an \
			-c:v ffv1 \
			"$dark_vision_file"
		then
			scenedetect \
				-q \
				-i "$dark_vision_file" \
				-o "$tmpdir" \
				detect-adaptive \
					--threshold 2.0 \
					--min-content-val 8.0 \
				list-scenes \
					--skip-cuts \
					--filename "scenes_dark.csv" \
				>/dev/null 2>&1 || :
		fi

		echo -e "${CYAN} = = > Fingerprint Pass 4:${NC} ${YELLOW}Content Change Vision...${NC}"

		scenedetect \
			-q \
			-i "$template" \
			-o "$tmpdir" \
			detect-content \
			list-scenes \
				--skip-cuts \
				--filename "scenes_content.csv" \
			>/dev/null 2>&1 || :

	else
		scene_status=1
		echo -e "${YE} = = > SceneDetect Not Available. Black Map Only.${NC}"
	fi

	# ------------------------------------------------------------
	# TEMPORAL VISUAL SIGNATURE
	# ------------------------------------------------------------
	# PURPOSE:
	# - Build a cheap time-ordered visual-change fingerprint.
	# - Does not depend on scene boundaries.
	# - Samples the real template at 3-second intervals.
	# - Records dHash distance between each sample and the prior sample.
	#
	# IMPORTANT:
	# - This is fingerprint evidence only.
	# - It does not yet change IntroFind behavior.
	# ------------------------------------------------------------
	echo -e "${CYAN} = = > Fingerprint Pass 5:${NC} ${YELLOW}Temporal Visual Signature...${NC}"

	python3 - \
		"$template" \
		"$duration" \
		"$temporal_signature" <<'PY'
import subprocess
import sys

import imagehash
from PIL import Image

template = sys.argv[1]
duration = float(sys.argv[2])
output_path = sys.argv[3]

SAMPLE_STEP = 3
FRAME_WIDTH = 9
FRAME_HEIGHT = 8
FRAME_BYTES = FRAME_WIDTH * FRAME_HEIGHT

ffmpeg_cmd = [
    "ffmpeg",
    "-hide_banner",
    "-loglevel",
    "error",
    "-nostdin",
    "-i",
    template,
    "-t",
    str(duration),
    "-an",
    "-sn",
    "-dn",
    "-vf",
    "fps=1,scale=9:8:flags=fast_bilinear,format=gray",
    "-f",
    "rawvideo",
    "-pix_fmt",
    "gray",
    "pipe:1",
]

try:
    process = subprocess.Popen(
        ffmpeg_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
except OSError:
    raise SystemExit(1)

all_hashes = []
frame_index = 0

while True:
    frame_data = process.stdout.read(FRAME_BYTES)

    if not frame_data:
        break

    if len(frame_data) != FRAME_BYTES:
        break

    image = Image.frombytes(
        "L",
        (FRAME_WIDTH, FRAME_HEIGHT),
        frame_data,
    )

    all_hashes.append(
        (
            float(frame_index),
            imagehash.dhash(image),
        )
    )

    frame_index += 1

stderr_data = process.stderr.read()
return_code = process.wait()

if return_code != 0:
    raise SystemExit(1)

samples = [
    (sample_time, frame_hash)
    for sample_time, frame_hash in all_hashes
    if int(sample_time) % SAMPLE_STEP == 0
]

with open(output_path, "w") as handle:
    handle.write(
        "time,dhash,delta_from_previous\n"
    )

    previous_hash = None

    for sample_time, frame_hash in samples:
        if previous_hash is None:
            delta = 0
        else:
            delta = frame_hash - previous_hash

        handle.write(
            f"{sample_time:.3f},"
            f"{frame_hash},"
            f"{delta}\n"
        )

        previous_hash = frame_hash
PY

	# ------------------------------------------------------------
	# AUDIO WAVEFORM SIGNATURE
	# ------------------------------------------------------------
	build_audio_waveform_fingerprint "$template"

	# ------------------------------------------------------------
	# BUILD HUMAN REPORT + CASCADING STRUCTURAL SELF-GRADE
	# ------------------------------------------------------------
	python3 - \
		"$template" \
		"$duration" \
		"$scene_csv" \
		"$sensitive_scene_csv" \
		"$dark_scene_csv" \
		"$content_scene_csv" \
		"$temporal_signature" \
		"$black_log" \
		"$report" <<'PY'
import csv
import sys
from pathlib import Path

template = sys.argv[1]
duration = float(sys.argv[2])
scene_csv = Path(sys.argv[3])
sensitive_scene_csv = Path(sys.argv[4])
dark_scene_csv = Path(sys.argv[5])
content_scene_csv = Path(sys.argv[6])
temporal_signature_path = Path(sys.argv[7])
black_log = Path(sys.argv[8])
report_path = Path(sys.argv[9])


# ------------------------------------------------------------
# BLACK / NEAR-BLACK STRUCTURE
# ------------------------------------------------------------
black_ranges = []

if black_log.exists():
    for raw in black_log.read_text(errors="replace").splitlines():
        parts = raw.strip().split(",")

        if len(parts) != 3:
            continue

        try:
            start, end, length = map(float, parts)
        except ValueError:
            continue

        black_ranges.append((start, end, length))


# ------------------------------------------------------------
# SCENE MAP LOADER
# ------------------------------------------------------------
def load_scenes(path):
    loaded = []

    if not path.exists():
        return loaded

    with path.open(newline="", errors="replace") as handle:
        reader = csv.DictReader(handle)

        for row in reader:
            try:
                start = float(row.get("Start Time (seconds)", ""))
                end = float(row.get("End Time (seconds)", ""))
            except (TypeError, ValueError):
                continue

            if end > start:
                loaded.append((start, end))

    return loaded


# ------------------------------------------------------------
# STRUCTURAL PASS GRADER
# ------------------------------------------------------------
def grade_scenes(items):
    if not items:
        return {
            "scene_count": 0,
            "usable_count": 0,
            "largest_ratio": 1.0,
            "tiny_count": 0,
            "weak": True,
            "score": -1000.0,
        }

    lengths = [
        end - start
        for start, end in items
    ]

    scene_count = len(items)

    usable_count = sum(
        1
        for length in lengths
        if length >= 1.25
    )

    tiny_count = sum(
        1
        for length in lengths
        if length < 0.50
    )

    largest_ratio = (
        max(lengths) / duration
        if duration > 0
        else 1.0
    )

    weak = (
        scene_count <= 1
        or largest_ratio > 0.85
        or usable_count < 2
    )

    score = (
        usable_count * 4.0
        + min(scene_count, 40) * 0.50
        - largest_ratio * 20.0
        - tiny_count * 0.75
    )

    return {
        "scene_count": scene_count,
        "usable_count": usable_count,
        "largest_ratio": largest_ratio,
        "tiny_count": tiny_count,
        "weak": weak,
        "score": score,
    }


# ------------------------------------------------------------
# LOAD + GRADE ALL STRUCTURAL VIEWS
# ------------------------------------------------------------
natural_scenes = load_scenes(scene_csv)
sensitive_scenes = load_scenes(sensitive_scene_csv)
dark_scenes = load_scenes(dark_scene_csv)
content_scenes = load_scenes(content_scene_csv)

natural_grade = grade_scenes(natural_scenes)
sensitive_grade = grade_scenes(sensitive_scenes)
dark_grade = grade_scenes(dark_scenes)
content_grade = grade_scenes(content_scenes)

selected_pass = "natural"
scenes = natural_scenes
selected_grade = natural_grade

if natural_grade["weak"]:
    candidate_passes = [
        ("sensitive", sensitive_scenes, sensitive_grade),
        ("dark-vision", dark_scenes, dark_grade),
        ("content-vision", content_scenes, content_grade),
    ]

    for pass_name, pass_scenes, pass_grade in candidate_passes:
        if not pass_scenes:
            continue

        if pass_grade["score"] > selected_grade["score"]:
            selected_pass = pass_name
            scenes = pass_scenes
            selected_grade = pass_grade

# SceneDetect absent or every pass empty.
if not scenes:
    scenes = [(0.0, duration)]
    selected_pass = "broad-fallback"
    selected_grade = grade_scenes(scenes)

# ------------------------------------------------------------
# TEMPORAL VISUAL SIGNATURE
# ------------------------------------------------------------
temporal_samples = []

if temporal_signature_path.exists():
    with temporal_signature_path.open(
        newline="",
        errors="replace"
    ) as handle:
        reader = csv.DictReader(handle)

        for row in reader:
            try:
                sample_time = float(row.get("time", ""))
                dhash_value = row.get("dhash", "").strip()
                delta = int(
                    row.get("delta_from_previous", "")
                )
            except (TypeError, ValueError):
                continue

            if not dhash_value:
                continue

            temporal_samples.append(
                (
                    sample_time,
                    dhash_value,
                    delta
                )
            )


temporal_deltas = [
    sample[2]
    for sample in temporal_samples[1:]
]

temporal_peak = (
    max(temporal_deltas)
    if temporal_deltas
    else 0
)

temporal_average = (
    sum(temporal_deltas) / len(temporal_deltas)
    if temporal_deltas
    else 0.0
)

temporal_active_count = sum(
    1
    for delta in temporal_deltas
    if delta >= 8
)

temporal_usable = (
    len(temporal_samples) >= 5
    and temporal_peak > 0
)

# ------------------------------------------------------------
# SAFE VISUAL WITNESS / ANCHOR SELECTION
# ------------------------------------------------------------
EDGE_MARGIN = min(2.0, max(0.5, duration * 0.03))
CUT_MARGIN = 0.65
BLACK_MARGIN = 0.50
MIN_SCENE_LENGTH = 1.25


def near_black(t):
    for start, end, _ in black_ranges:
        if (start - BLACK_MARGIN) <= t <= (end + BLACK_MARGIN):
            return True

    return False


def safe_time(t):
    if t < EDGE_MARGIN or t > duration - EDGE_MARGIN:
        return False

    return not near_black(t)


candidates_a = []
candidates_b = []

for start, end in scenes:
    scene_len = end - start

    if scene_len < MIN_SCENE_LENGTH:
        continue

    safe_start = start + CUT_MARGIN
    safe_end = end - CUT_MARGIN

    if safe_end <= safe_start:
        continue

    point_a = safe_start + ((safe_end - safe_start) * 0.35)
    point_b = safe_start + ((safe_end - safe_start) * 0.68)

    if safe_time(point_a):
        candidates_a.append(
            (point_a, scene_len, start, end)
        )

    if safe_time(point_b):
        candidates_b.append(
            (point_b, scene_len, start, end)
        )


def spread_pick(candidates, wanted):
    if not candidates:
        return []

    ordered = sorted(
        candidates,
        key=lambda item: (-item[1], item[0])
    )

    chosen = []

    min_gap = max(
        2.0,
        duration / max(wanted * 1.8, 1.0)
    )

    for item in ordered:
        t = item[0]

        if all(
            abs(t - existing[0]) >= min_gap
            for existing in chosen
        ):
            chosen.append(item)

        if len(chosen) >= wanted:
            break

    if len(chosen) < wanted:
        for item in sorted(
            candidates,
            key=lambda value: value[0]
        ):
            if item not in chosen:
                chosen.append(item)

            if len(chosen) >= wanted:
                break

    return sorted(
        chosen,
        key=lambda item: item[0]
    )


if duration < 30:
    wanted = 3
elif duration < 90:
    wanted = 5
else:
    wanted = 7


auto_a = spread_pick(candidates_a, wanted)

used_a_scenes = {
    (round(item[2], 3), round(item[3], 3))
    for item in auto_a
}

alternate_b = [
    item
    for item in candidates_b
    if (
        round(item[2], 3),
        round(item[3], 3)
    ) not in used_a_scenes
]

if len(alternate_b) < wanted:
    alternate_b = candidates_b

auto_b = spread_pick(alternate_b, wanted)


def times_csv(items):
    return ",".join(
        f"{item[0]:.3f}"
        for item in items
    ) or "NONE"


# ------------------------------------------------------------
# HUMAN FINGERPRINT REPORT
# ------------------------------------------------------------
lines = []

lines.append(
    "FACTORY INTRO TEMPLATE STRUCTURAL FINGERPRINT"
)
lines.append("=" * 60)
lines.append(f"Template: {template}")
lines.append(f"Duration: {duration:.3f}")
lines.append("Analysis Version: structural-temporal-cascade-v4")
lines.append(f"Selected Scene Pass: {selected_pass}")
lines.append("")

lines.append("STRUCTURAL PASS QUALITY")
lines.append("-" * 60)

lines.append(
    "natural: "
    f"scenes={natural_grade['scene_count']} "
    f"usable={natural_grade['usable_count']} "
    f"largest_ratio={natural_grade['largest_ratio']:.3f} "
    f"tiny={natural_grade['tiny_count']} "
    f"weak={'YES' if natural_grade['weak'] else 'NO'} "
    f"score={natural_grade['score']:.3f}"
)

lines.append(
    "sensitive: "
    f"scenes={sensitive_grade['scene_count']} "
    f"usable={sensitive_grade['usable_count']} "
    f"largest_ratio={sensitive_grade['largest_ratio']:.3f} "
    f"tiny={sensitive_grade['tiny_count']} "
    f"weak={'YES' if sensitive_grade['weak'] else 'NO'} "
    f"score={sensitive_grade['score']:.3f}"
)

lines.append(
    "dark-vision: "
    f"scenes={dark_grade['scene_count']} "
    f"usable={dark_grade['usable_count']} "
    f"largest_ratio={dark_grade['largest_ratio']:.3f} "
    f"tiny={dark_grade['tiny_count']} "
    f"weak={'YES' if dark_grade['weak'] else 'NO'} "
    f"score={dark_grade['score']:.3f}"
)

lines.append(
    "content-vision: "
    f"scenes={content_grade['scene_count']} "
    f"usable={content_grade['usable_count']} "
    f"largest_ratio={content_grade['largest_ratio']:.3f} "
    f"tiny={content_grade['tiny_count']} "
    f"weak={'YES' if content_grade['weak'] else 'NO'} "
    f"score={content_grade['score']:.3f}"
)

lines.append(f"selected: {selected_pass}")
lines.append("")

lines.append("TEMPORAL VISUAL QUALITY")
lines.append("-" * 60)
lines.append(
    f"samples={len(temporal_samples)} "
    f"step=3.000 "
    f"peak_delta={temporal_peak} "
    f"average_delta={temporal_average:.3f} "
    f"active_transitions={temporal_active_count} "
    f"usable={'YES' if temporal_usable else 'NO'}"
)
lines.append("")

lines.append("TEMPORAL VISUAL SIGNATURE")
lines.append("-" * 60)

if temporal_samples:
    for sample_time, dhash_value, delta in temporal_samples:
        lines.append(
            f"time={sample_time:.3f} "
            f"dhash={dhash_value} "
            f"delta={delta}"
        )
else:
    lines.append("NONE")

lines.append("")

lines.append("BLACK / NEAR-BLACK RANGES")
lines.append("-" * 60)

if black_ranges:
    for start, end, length in black_ranges:
        lines.append(
            f"{start:.3f} -> {end:.3f}  "
            f"duration={length:.3f}"
        )
else:
    lines.append("NONE DETECTED")

lines.append("")

lines.append("SCENE STRUCTURE")
lines.append("-" * 60)

for number, (start, end) in enumerate(
    scenes,
    start=1
):
    lines.append(
        f"{number:03d}: "
        f"{start:.3f} -> {end:.3f}  "
        f"duration={end - start:.3f}"
    )

lines.append("")

lines.append("SUGGESTED REPORT-ONLY ANCHORS")
lines.append("-" * 60)
lines.append(f"auto-a: {times_csv(auto_a)}")
lines.append(f"auto-b: {times_csv(auto_b)}")
lines.append("")

lines.append("AUTO-A DETAILS")
lines.append("-" * 60)

for t, scene_len, start, end in auto_a:
    lines.append(
        f"anchor={t:.3f} "
        f"scene={start:.3f}->{end:.3f} "
        f"scene_duration={scene_len:.3f}"
    )

lines.append("")

lines.append("AUTO-B DETAILS")
lines.append("-" * 60)

for t, scene_len, start, end in auto_b:
    lines.append(
        f"anchor={t:.3f} "
        f"scene={start:.3f}->{end:.3f} "
        f"scene_duration={scene_len:.3f}"
    )

lines.append("")

lines.append("STATUS")
lines.append("-" * 60)
lines.append(
    "REPORT ONLY — IntroFind behavior was not changed."
)

report_path.write_text(
    "\n".join(lines) + "\n"
)

print(times_csv(auto_a))
print(times_csv(auto_b))
PY

	local py_status=$?

	if (( py_status != 0 )) || [[ ! -s "$report" ]]; then
		echo -e "${REB} = = > Fingerprint Report Build Failed.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${GR} = = > Structural Fingerprint Report Created:${NC}"
	echo -e "${GREEN}       $(factory_display_path "$report")${NC}"
	echo

	if command -v less >/dev/null 2>&1; then
		less -R "$report"
	else
		cat "$report"
	fi

	pause
}

# ================================================================
# #MARKER: AUTO HASH ANCHORS FROM TEMPLATE DURATION
# ================================================================
# PURPOSE:
# - Allow IntroFind / OutroFind anchor input to be "auto".
# - Derive stable, spread-out anchor seconds from template duration.
# - Keep Python hash engine simple: it still receives normal CSV seconds.
#
# DESIGN:
# - Deterministic, not random.
# - Avoids the first/last edge of the template when practical.
# - Uses 3 anchors for intro-style matching.
# - Uses 5 anchors for outro/full-credit matching.
#
# INPUT:
#   $1 = template path or glob
#   $2 = intro | outro
#   $3 = requested anchors value
#
# OUTPUT:
#   CSV anchor seconds
# ================================================================
auto_anchor_csv_from_duration() {
	local template_ref="$1"
	local mode="${2:-outro}"
	local requested="${3:-auto}"
	local template_file=""
	local duration=""
	local count=5
	local csv=""

	# ========================================================
	# INTRO STRUCTURAL FINGERPRINT ANCHOR PROFILES
	# ========================================================
	# Accepted intro aliases:
	#   auto-a / auto.a
	#   auto-b / auto.b
	#
	# Plain "auto" keeps the existing duration-based math.
	# Manual CSV anchor lists still pass through unchanged.
	# Outro behavior remains unchanged.
	# ========================================================

	requested="${requested,,}"
	requested="${requested//./-}"

	if [[ "$mode" == "intro" ]]; then
		case "$requested" in
			auto-a|auto-b)
				load_intro_template_fingerprint >/dev/null 2>&1 || :

				if (( ${INTRO_FINGERPRINT_LOADED:-0} == 1 )); then
					case "$requested" in
						auto-a)
							if [[ -n "${INTRO_FINGERPRINT_AUTO_A:-}" &&
							      "${INTRO_FINGERPRINT_AUTO_A:-}" != "NONE" ]]; then
								echo -e "${CYAN} = = > Intro Anchor Profile:${NC} ${YELLOW}auto-a${NC} ${CYAN}from structural fingerprint${NC}" >&2
								printf '%s\n' "$INTRO_FINGERPRINT_AUTO_A"
								return 0
							fi
							;;

						auto-b)
							if [[ -n "${INTRO_FINGERPRINT_AUTO_B:-}" &&
							      "${INTRO_FINGERPRINT_AUTO_B:-}" != "NONE" ]]; then
								echo -e "${CYAN} = = > Intro Anchor Profile:${NC} ${YELLOW}auto-b${NC} ${CYAN}from structural fingerprint${NC}" >&2
								printf '%s\n' "$INTRO_FINGERPRINT_AUTO_B"
								return 0
							fi
							;;
					esac
				fi

				echo -e "${YE} = = > Requested ${requested} Fingerprint Anchors Were Not Available.${NC}" >&2
				echo -e "${YE} = = > Falling Back To Plain Duration-Based AUTO Anchors.${NC}" >&2
				requested="auto"
				;;
		esac
	fi

	# Manual CSV passes through unchanged.
	if [[ "$requested" != "auto" ]]; then
		printf '%s\n' "$requested"
		return 0
	fi

	case "$mode" in
		intro)
			count="${INTRO_AUTO_ANCHOR_COUNT:-3}"
			;;
		outro|*)
			count="${OUTRO_AUTO_ANCHOR_COUNT:-5}"
			;;
	esac

	# Resolve first matching template from either a direct file or glob.
	if [[ -f "$template_ref" ]]; then
		template_file="$template_ref"
	else
		shopt -s nullglob
		local -a matches=( $template_ref )
		shopt -u nullglob
		if (( ${#matches[@]} > 0 )); then
			template_file="${matches[0]}"
		fi
	fi

	if [[ -z "$template_file" || ! -f "$template_file" ]]; then
		echo -e "${YE} = = > AUTO Anchors Could Not Find Template. Falling Back.${NC}" >&2
		if [[ "$mode" == "intro" ]]; then
			printf '%s\n' "${ANCHOR_SECONDS:-3,5,7}"
		else
			printf '%s\n' "8,12,16"
		fi
		return 0
	fi

	duration="$(get_file_duration_seconds "$template_file" 2>/dev/null || true)"

	if [[ -z "$duration" || ! "$duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
		echo -e "${YE} = = > AUTO Anchors Could Not Read Template Duration. Falling Back.${NC}" >&2
		if [[ "$mode" == "intro" ]]; then
			printf '%s\n' "${ANCHOR_SECONDS:-3,5,7}"
		else
			printf '%s\n' "8,12,16"
		fi
		return 0
	fi

	# ----- DURATION-AWARE AUTO ANCHOR COUNT -------------------------------
	# Short templates get fewer anchors.
	# Longer templates get more spread anchors.
	count="$(awk -v d="$duration" 'BEGIN {
		if (d < 30) print 3;
		else if (d < 90) print 5;
		else print 7;
	}')"

	case "$count" in
		3)
			csv="$(awk -v d="$duration" -v m="$mode" 'BEGIN {
				if (m == "outro") {
					a[1]=0.45; a[2]=0.70; a[3]=0.90
				} else {
					a[1]=0.20; a[2]=0.50; a[3]=0.80
				}

				for (i=1; i<=3; i++) {
					v=int((d*a[i]) + 0.5)
					if (d > 6 && v < 2) v=2
					if (d > 6 && v > d-2) v=int(d-2)
					if (i > 1) printf ","
					printf "%d", v
				}
			}')"
			;;
		5)
			csv="$(awk -v d="$duration" -v m="$mode" 'BEGIN {
				if (m == "outro") {
					a[1]=0.35; a[2]=0.50; a[3]=0.65; a[4]=0.80; a[5]=0.92
				} else {
					a[1]=0.12; a[2]=0.30; a[3]=0.50; a[4]=0.70; a[5]=0.88
				}

				for (i=1; i<=5; i++) {
					v=int((d*a[i]) + 0.5)
					if (d > 6 && v < 2) v=2
					if (d > 6 && v > d-2) v=int(d-2)
					if (i > 1) printf ","
					printf "%d", v
				}
			}')"
			;;
		7|*)
			csv="$(awk -v d="$duration" -v m="$mode" 'BEGIN {
				if (m == "outro") {
					a[1]=0.25; a[2]=0.38; a[3]=0.51; a[4]=0.64; a[5]=0.76; a[6]=0.88; a[7]=0.95
				} else {
					a[1]=0.10; a[2]=0.23; a[3]=0.36; a[4]=0.50; a[5]=0.64; a[6]=0.77; a[7]=0.90
				}

				for (i=1; i<=7; i++) {
					v=int((d*a[i]) + 0.5)
					if (d > 6 && v < 2) v=2
					if (d > 6 && v > d-2) v=int(d-2)
					if (i > 1) printf ","
					printf "%d", v
				}
			}')"
			;;
	esac

	echo -e "${CYAN} = = > AUTO Anchors:${NC} ${YELLOW}$csv${NC} ${CYAN}count=${NC}${YELLOW}$count${NC} ${CYAN}duration=${NC}${YELLOW}$duration${NC} ${CYAN}from${NC} ${GREEN}$(factory_display_path "$template_file")${NC}" >&2
	printf '%s\n' "$csv"
}

# ================================================================
# #MARKER: AUTO OUTRO TAIL SCAN DEPTH FROM TEMPLATE DURATION
# ================================================================
auto_outro_tail_scan_seconds() {
	local template_file="${1:-$OUTRO_TEMPLATE}"
	local requested="${2:-${OUTRO_TAIL_SCAN_SECONDS:-auto}}"
	local duration=""
	local pad="${OUTRO_TAIL_SCAN_PAD_SECONDS:-10}"
	local min_scan="${OUTRO_TAIL_SCAN_MIN_SECONDS:-45}"
	local max_scan="${OUTRO_TAIL_SCAN_MAX_SECONDS:-160}"
	local result=""

	if [[ "${requested,,}" != "auto" ]]; then
		printf '%s\n' "$requested"
		return 0
	fi

	if [[ ! -f "$template_file" ]]; then
		echo -e "${YE} = = > AUTO Outro Tail Scan Could Not Find Template. Falling Back To 120.${NC}" >&2
		printf '%s\n' "120"
		return 0
	fi

	duration="$(get_file_duration_seconds "$template_file" 2>/dev/null || true)"

	if [[ -z "$duration" || ! "$duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
		echo -e "${YE} = = > AUTO Outro Tail Scan Could Not Read Template Duration. Falling Back To 120.${NC}" >&2
		printf '%s\n' "120"
		return 0
	fi

	result="$(awk -v d="$duration" -v p="$pad" -v mn="$min_scan" -v mx="$max_scan" 'BEGIN {
		v = d + p
		if (v < mn) v = mn
		if (v > mx) v = mx
		printf "%.3f", v
	}')"

	echo -e "${CYAN} = = > AUTO Outro Tail Scan:${NC} ${YELLOW}$result${NC} ${CYAN}= template ${duration}s + pad ${pad}s${NC}" >&2
	printf '%s\n' "$result"
}

# ================================================================
# #MARKER: OUTRO MULTIKEY TEMPLATE HELPERS
# ================================================================
outro_template_list() {
	local pattern="${1:-${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}}"

	compgen -G "$pattern" | sort
}

outro_template_primary() {
	local pattern="${1:-${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}}"
	local first=""

	first="$(outro_template_list "$pattern" | head -n 1 || true)"

	if [[ -n "$first" ]]; then
		printf '%s\n' "$first"
		return 0
	fi

	if [[ -f "${OUTRO_TEMPLATE:-intro_template/outro.mkv}" ]]; then
		printf '%s\n' "$OUTRO_TEMPLATE"
		return 0
	fi

	return 1
}

outro_template_count() {
	local pattern="${1:-${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}}"

	outro_template_list "$pattern" | wc -l
}

auto_anchor_csv_from_seconds() {
	local duration="$1"
	local mode="${2:-outro}"
	local fallback="${3:-8,12,16}"
	local count csv

	if [[ -z "$duration" || ! "$duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
		printf '%s\n' "$fallback"
		return 0
	fi

	count="$(awk -v d="$duration" 'BEGIN {
		if (d < 30) print 3;
		else if (d < 90) print 5;
		else print 7;
	}')"

	case "$count" in
		3)
			csv="$(awk -v d="$duration" -v m="$mode" 'BEGIN {
				if (m == "outro") {
					a[1]=0.45; a[2]=0.70; a[3]=0.90
				} else {
					a[1]=0.20; a[2]=0.50; a[3]=0.80
				}

				for (i=1; i<=3; i++) {
					v=int((d*a[i]) + 0.5)
					if (d > 6 && v < 2) v=2
					if (d > 6 && v > d-2) v=int(d-2)
					if (i > 1) printf ","
					printf "%d", v
				}
			}')"
			;;
		5)
			csv="$(awk -v d="$duration" -v m="$mode" 'BEGIN {
				if (m == "outro") {
					a[1]=0.35; a[2]=0.50; a[3]=0.65; a[4]=0.80; a[5]=0.92
				} else {
					a[1]=0.12; a[2]=0.30; a[3]=0.50; a[4]=0.70; a[5]=0.88
				}

				for (i=1; i<=5; i++) {
					v=int((d*a[i]) + 0.5)
					if (d > 6 && v < 2) v=2
					if (d > 6 && v > d-2) v=int(d-2)
					if (i > 1) printf ","
					printf "%d", v
				}
			}')"
			;;
		*)
			csv="$(awk -v d="$duration" -v m="$mode" 'BEGIN {
				if (m == "outro") {
					a[1]=0.25; a[2]=0.38; a[3]=0.51; a[4]=0.64; a[5]=0.76; a[6]=0.88; a[7]=0.95
				} else {
					a[1]=0.10; a[2]=0.23; a[3]=0.36; a[4]=0.50; a[5]=0.64; a[6]=0.77; a[7]=0.90
				}

				for (i=1; i<=7; i++) {
					v=int((d*a[i]) + 0.5)
					if (d > 6 && v < 2) v=2
					if (d > 6 && v > d-2) v=int(d-2)
					if (i > 1) printf ","
					printf "%d", v
				}
			}')"
			;;
	esac

	echo -e "${CYAN} = = > AUTO ${mode^} Global Anchors:${NC} ${YELLOW}$csv${NC} ${CYAN}From Average Template Duration ${duration}s${NC}" >&2
	printf '%s\n' "$csv"
}

auto_outro_multikey_anchor_csv() {
	local pattern="${1:-${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}}"
	local fallback="${2:-${OUTRO_ANCHOR_SECONDS:-8,12,16}}"
	local tolerance="${OUTRO_MULTIKEY_DURATION_TOLERANCE_SECONDS:-1.0}"

	local -a templates=()
	local template duration
	local stats count min_d max_d avg_d spread

	mapfile -t templates < <(outro_template_list "$pattern")

	if (( ${#templates[@]} == 0 )); then
		echo -e "${YE} = = > AUTO Outro Anchors: No Outro Templates Found For:${NC} ${YELLOW}$pattern${NC}" >&2
		printf '%s\n' "$fallback"
		return 0
	fi

	if (( ${#templates[@]} == 1 )); then
		auto_anchor_csv_from_duration "${templates[0]}" "outro" "$fallback"
		return 0
	fi

	stats="$(
		for template in "${templates[@]}"; do
			duration="$(get_file_duration_seconds "$template" 2>/dev/null || true)"
			[[ "$duration" =~ ^[0-9]+([.][0-9]+)?$ ]] || continue
			printf '%s\n' "$duration"
		done | awk '
			NR == 1 {
				min = $1
				max = $1
				sum = 0
			}
			{
				if ($1 < min) min = $1
				if ($1 > max) max = $1
				sum += $1
				count += 1
			}
			END {
				if (count < 1) {
					exit 1
				}
				printf "%d|%.3f|%.3f|%.3f|%.3f", count, min, max, sum/count, max-min
			}
		'
	)" || {
		echo -e "${YE} = = > AUTO Outro Anchors: Could Not Read MultiKey Durations. Falling Back.${NC}" >&2
		printf '%s\n' "$fallback"
		return 0
	}

	IFS='|' read -r count min_d max_d avg_d spread <<< "$stats"

	if awk -v s="$spread" -v t="$tolerance" 'BEGIN { exit !(s <= t) }'; then
		echo -e "${CYAN} = = > Outro MultiKey Templates:${NC} ${YELLOW}${#templates[@]}${NC}" >&2
		echo -e "${CYAN} = = > Outro Duration Spread:${NC} ${YELLOW}${spread}s${NC} ${CYAN}(tolerance ${tolerance}s)${NC}" >&2
		auto_anchor_csv_from_seconds "$avg_d" "outro" "$fallback"
		return 0
	fi

	echo -e "${YE} = = > Outro MultiKey Duration Spread Too Wide:${NC} ${YELLOW}${spread}s${NC} ${YE}> ${tolerance}s${NC}" >&2
	echo -e "${YE} = = > Falling Back To Primary Outro Template Anchors.${NC}" >&2

	template="$(outro_template_primary "$pattern" 2>/dev/null || true)"
	if [[ -n "$template" ]]; then
		auto_anchor_csv_from_duration "$template" "outro" "$fallback"
	else
		printf '%s\n' "$fallback"
	fi
}

# =========================
# #MARKER: GLOBAL TIME INPUT NORMALIZER
# =========================
# PURPOSE:
# - Make Time Entry Fast And Ten-Key Friendly
# - Accept Raw Seconds, Keypad Time, Or Decimal Seconds
# - Normalize Everything Into Decimal Seconds For Internal Use
#
# ACCEPTED INPUT EXAMPLES:
#
# RAW SECONDS
#     120          -> 120.000
#     120.5        -> 120.500
#     .5           -> 0.500
#
# KEYPAD FRIENDLY TIME
#     2:20         -> 140.000
#     2.20         -> 140.000
#
#     1:02:30      -> 3750.000
#     1.02.30      -> 3750.000
#
# DECIMAL TIME
#     1:14.5       -> 74.500
#     00:01:14.5   -> 74.500
#     00:01:14.750 -> 74.750
#
# DESIGN:
# - "." And ":" Are Equivalent For Traditional Keypad Entry
# - No Separator = Raw Seconds
# - One Separator = mm:ss
# - Two Separators = hh:mm:ss
# - Fractional Seconds Are Preserved
#
# COMPATIBILITY RULE:
# - Legacy Factory Entries Continue To Work:
#       2.20      = 2 minutes 20 seconds
#       1.02.30   = 1 hour 2 minutes 30 seconds
#
# - Decimal Seconds Are Intended To Use:
#       24.5
#       .5
#       24.750
#
# WHY:
# - SmartCut Already Accepts Fractional Cut Points
# - IntroFind And OutroFind Already Produce Fractional Times
# - Allows Fine Trim Adjustments For Audio Sync, Intro Boundaries,
#   Outro Boundaries, And SmartCut Drift Compensation
#
# OUTPUT:
# - Returns Decimal Seconds
# - Examples:
#       24      -> 24.000
#       24.5    -> 24.500
#       2.20    -> 140.000
#       1:14.5  -> 74.500
#
# IMPORTANT:
# - This Helper Lives In Global Scope.
# - Used By SmartCut, IntroFind, OutroFind, Template Builder,
#   Audio Rescue, And Future Timing Tools.
# =========================
to_seconds() {
	local input="$1"
	local h=0 m=0 s=0
	local p1 p2 p3
	local old_ifs

	input="$(printf '%s\n' "$input" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

	[[ -z "$input" ]] && { printf '0\n'; return 0; }

	if [[ "$input" =~ ^[0-9]+$ ]]; then
		printf '%.3f\n' "$input"
		return 0
	fi

	if [[ "$input" =~ ^[0-9]*\.[0-9]+$ ]]; then
		local frac="${input#*.}"
		if (( ${#frac} == 2 )); then
			input="${input//./:}"
		else
			awk -v v="$input" 'BEGIN { printf "%.3f\n", v + 0 }'
			return 0
		fi
	fi

	if [[ "$input" != *:* ]]; then
		input="${input//./:}"
	fi

	old_ifs="$IFS"
	IFS=':'
	read -r p1 p2 p3 <<< "$input"
	IFS="$old_ifs"

	if [[ -n "${p1:-}" && -n "${p2:-}" && -z "${p3:-}" ]]; then
		m="$p1"
		s="$p2"
	elif [[ -n "${p1:-}" && -n "${p2:-}" && -n "${p3:-}" ]]; then
		h="$p1"
		m="$p2"
		s="$p3"
	else
		printf '0\n'
		return 0
	fi

	awk -v h="${h:-0}" -v m="${m:-0}" -v s="${s:-0}" 'BEGIN {
		printf "%.3f\n", (h * 3600) + (m * 60) + s
	}'
}

# #MARKER: END GLOBAL TEXT / COMMAND HELPERS

    # ------------------ DEP CHECK ------------------

    # ============================================================
    # #MARKER: GLOBAL DEPENDENCY CHECK / TOOL AVAILABILITY WALL
    # ============================================================
    # PURPOSE:
    # - Detect Required And Optional Tools Early.
    # - Fail Fast On True Hard Requirements.
    # - Explain Clearly What Each Missing Tool Is For.
    # - Give The User A Copyable Install Command Instead Of A Dead-End Error.
    #
    # DESIGN:
    # - HARD REQUIRED Tools Stop The Script If Missing.
    # - OPTIONAL Tools Do NOT Stop The Script Globally.
    # - OPTIONAL Tool Presence Is Recorded In Feature Flags For Later Missions.
    # - Mission-Specific Checks May Still Happen Later For Better Guidance.
    #
    # WHY BOTH GLOBAL + LOCAL CHECKS EXIST:
    # - Global Check Prevents Confusing Half-Starts On Machines Missing Basics.
    # - Local Checks Let Specialized Missions Explain Exactly What They Need.
    # - This Keeps The Script Friendly On Mixed / Partial Installs.
    #
    # OFFLINE / FRESH-INSTALL THOUGHT:
    # - Most Of These Tools Are Standard Package-Manager Installs On Mint/Ubuntu.
    # - Carrying Installers Inside intro_template/ Is Usually NOT Necessary.
    # - If Desired, A Separate Toolbox Folder Can Still Hold:
    #     * a plain-text dependency note
    #     * a copy/paste install command
    #     * offline setup notes for python/scenedetect if ever needed
    # - But For Normal Use, Package-Manager Install Instructions Are Enough.
    #
    # IMPORTANT:
    # - This Block Should Live BEFORE Main Menu / Workflow Dispatch.
    # - Function Definitions Above It Are Fine; They Do Not Execute Yet.
    # ============================================================

    # ============================================================
    # #MARKER: OPTIONAL TOOL FEATURE FLAGS
    # ============================================================
    # PURPOSE:
    # - Record Whether Optional Helpers Are Available.
    # - Later Missions Can Branch Cleanly Without Repeated Guesswork.
    # ============================================================

# #MARKER: these are for the dep check only 
HAS_SCENEDETECT=0
HAS_PIPX=0
HAS_MKVPROPEDIT=0
HAS_PYTHON3=0
HAS_FINDMNT=0
HAS_FFPLAY=0
HAS_LESS=0
HAS_ICONV=0

    # ============================================================
    # #MARKER: GLOBAL DEP HELP WALL
    # ============================================================
    # PURPOSE:
    # - Print A Large Readable Explanation Wall When Dependencies Are Missing.
    # - Use A Single-Quoted Heredoc So Special Characters Print Literally.
    # - Keep Install Command Easy To Copy/Paste.
    # ============================================================
show_global_dependency_help_wall() {
	cat <<'EOF'

	INSTALL COMMAND:
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
	- scenedetect is OPTIONAL unless using automatic intro detection features.
	- less is OPTIONAL; note screens can fall back to plain cat behavior.
	- iconv is OPTIONAL; some detox/transliteration behavior may be reduced without it.
	-----------------------------------------------------------------------------------------
EOF
}

    # ============================================================
    # #MARKER: DEP CHECK PRINTER HELPERS
    # ============================================================
    # PURPOSE:
    # - Keep dependency output consistent and readable.
    # - Separate hard-fail reporting from optional-warning reporting.
    # ============================================================
print_missing_required_dep() {
	local dep="$1"
	echo -e "${RE}============================================================${NC}"
	echo -e "${REB} = = > MISSING REQUIRED DEPENDENCY${NC}"
	echo -e "${RE}------------------------------------------------------------${NC}"
	echo -e "${YELLOW} = = > $dep${NC}"
	echo -e "${YELLOW} = = > Factory Cannot Run Until This Is Installed${NC}"
	echo -e "${RE}============================================================${NC}"
	echo

	# --------------------------------------------------------
	# Only ask once per run
	# --------------------------------------------------------
	if [[ -z "${_DEP_HELP_SHOWN:-}" ]]; then
		if ask_yes_no " = = > Show Install / Help Wall? (y/n or 1/2): "; then
			show_global_dependency_help_wall
			_DEP_HELP_SHOWN=1
		fi
	fi
}

print_missing_optional_dep() {
	local dep="$1"
	local why="$2"
	echo -e "${REB}------------------------------------------------------------${NC}"
	echo -e "${YELLOW} = = > Optional Tool Missing: $dep${NC}"
	echo -e "${YELLOW} = = > Related Feature Impact: $why${NC}"
	echo -e "${YELLOW} = = > Use Install / Help Wall For Fix Commands${NC}"
	echo -e "${REB}------------------------------------------------------------${NC}"
	echo

	# --------------------------------------------------------
	# Only ask once per run
	# --------------------------------------------------------
	if [[ -z "${_DEP_HELP_SHOWN:-}" ]]; then
		if ask_yes_no " = = > Show Install / Help Wall? (y/n or 1/2): "; then
			show_global_dependency_help_wall
			_DEP_HELP_SHOWN=1
		fi
	fi
}

    # ============================================================
    # #MARKER: HARD REQUIRED GLOBAL DEPENDENCY CHECK
    # ============================================================
    # PURPOSE:
    # - These are required for the general factory experience to behave correctly.
    # - If any are missing, stop immediately and show the install/help wall.
    #
    # NOTE:
    # - Keep this list focused on tools broadly relied on across the factory.
    # - Optional helpers belong in the optional discovery pass below.
    # ============================================================
check_required_dependencies_or_die() {
	local missing_any=0
	local dep

	for dep in ffmpeg ffprobe bc awk sed grep df; do
		if ! have_cmd "$dep"; then
			print_missing_required_dep "$dep"
			missing_any=1
		fi
	done

	if (( missing_any != 0 )); then
		echo
		echo -e "${YELLOW}================ DEPENDENCY HELP WALL ================${NC}"
		show_global_dependency_help_wall
		echo -e "${YELLOW}======================================================${NC}"
		echo
		echo -e "${YELLOW} = = > Install The Missing Tools, Then Run thefactory.sh Again.${NC}"
		exit 1
	fi
}

    # ============================================================
    # #MARKER: OPTIONAL TOOL DISCOVERY / FEATURE FLAGS
    # ============================================================
    # PURPOSE:
    # - Record tools that unlock extra missions but should not kill startup.
    # - Warn clearly so the user knows why a feature may be unavailable.
    # ============================================================
detect_optional_tools() {
	if have_cmd python3; then
		HAS_PYTHON3=1
	else
		print_missing_optional_dep "python3" "Python-based helper paths will be unavailable."
	fi

	if have_cmd pipx; then
		HAS_PIPX=1
	else
		print_missing_optional_dep "pipx" "Easy isolated installation of scenedetect is unavailable."
	fi

	if have_cmd scenedetect; then
		HAS_SCENEDETECT=1
	else
		print_missing_optional_dep "scenedetect" "Automatic intro detection missions will be unavailable."
	fi

	if have_cmd mkvpropedit; then
		HAS_MKVPROPEDIT=1
	else
		print_missing_optional_dep "mkvpropedit" "Fast in-place MKV title/default-track edits will fall back to slower remux paths or no-op behavior, depending on mission."
	fi

	if have_cmd findmnt; then
		HAS_FINDMNT=1
	else
		print_missing_optional_dep "findmnt" "Drive label display will fall back to mount source or unknown-drive."
	fi

	if have_cmd ffplay; then
		HAS_FFPLAY=1
	else
		print_missing_optional_dep "ffplay" "Quick preview / review playback helpers will be unavailable."
	fi

	if have_cmd less; then
		HAS_LESS=1
	else
		print_missing_optional_dep "less" "Long-form notes screens will fall back to plain non-scrollable output."
	fi

	if have_cmd iconv; then
		HAS_ICONV=1
	else
		print_missing_optional_dep "iconv" "Some title detox transliteration behavior may be reduced."
	fi
		#resolve_smc_bin
}

# ========================================================
# #MARKER: STARTUP DIAGNOSTICS / OPERATING MODE REPORT
# ========================================================
path_state() {
	local path="$1"

	if [[ -L "$path" ]]; then
		local target
		target="$(readlink "$path" 2>/dev/null || printf '?')"
		printf 'LINK -> %s\n' "$(trim_working_path_display "$target" 3)"
	elif [[ -d "$path" ]]; then
		printf 'DIRECTORY\n'
	elif [[ -f "$path" ]]; then
		printf 'FILE\n'
	else
		printf 'NOT PRESENT\n'
	fi
}

find_active_phash_engine() {
	local candidate
	for candidate in \
		"${FACTORY_WORKDIR}/.phash_engine.py" \
		"${FACTORY_HOME}/.phash_engine.py" \
		"${SCRIPT_DIR}/.phash_engine.py"
	do
		[[ -f "$candidate" ]] || continue
		printf '%s\n' "$candidate"
		return 0
	done
	return 1
}

find_active_phash_log() {
	local candidate
	for candidate in \
		"${FACTORY_WORKDIR}/.phash_engine.stderr.log" \
		"${FACTORY_HOME}/.phash_engine.stderr.log" \
		"${SCRIPT_DIR}/.phash_engine.stderr.log"
	do
		[[ -f "$candidate" ]] || continue
		printf '%s\n' "$candidate"
		return 0
	done
	return 1
}

show_startup_diagnostics() {
	local smc_display template_repo template_state working_template working_state
	local phash_active phash_log_active phash_status config_state authority_display
	local target_real active_real

	detect_operating_mode
	resolve_smc_bin >/dev/null 2>&1 || true
	smc_display="${SMC_BIN:-NOT FOUND}"
	template_repo="${INTRO_TEMPLATE_DIR:-${FACTORY_HOME}/intro_template}"
	working_template="${FACTORY_WORKDIR}/intro_template"
	template_state="$(path_state "$template_repo")"
	working_state="$(path_state "$working_template")"
	authority_display="${INTRO_TEMPLATE_AUTHORITY:-UNRESOLVED}"
	if [[ "${OPERATING_MODE:-}" == "STANDALONE" && "$authority_display" == TOOLBOX* ]]; then
		authority_display="STANDALONE_LOCAL"
	fi

	if [[ -f "$FACTORY_CONFIG_FILE" ]]; then
		config_state="PRESENT"
	else
		config_state="NOT PRESENT YET"
	fi

	phash_active="$(find_active_phash_engine 2>/dev/null || true)"
	phash_log_active="$(find_active_phash_log 2>/dev/null || true)"

	if [[ -n "$phash_active" ]]; then
		target_real="$(realpath -m -- "$PHASH_ENGINE" 2>/dev/null || printf '%s\n' "$PHASH_ENGINE")"
		active_real="$(realpath -m -- "$phash_active" 2>/dev/null || printf '%s\n' "$phash_active")"
		if [[ "$active_real" == "$target_real" ]]; then
			phash_status="ACTIVE AT TARGET"
		else
			phash_status="ACTIVE PATH MISMATCH"
		fi
	else
		phash_status="NOT ACTIVE"
	fi

	clear
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}                  STARTUP DIAGNOSTICS                       ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > Operating Mode :${NC} ${YELLOW}${OPERATING_MODE}${NC}"
	echo -e "${CYAN} = = > Script Location:${NC} ${YELLOW}$(trim_working_path_display "$SCRIPT_DIR" 3)${NC}"
	echo -e "${CYAN} = = > Factory Home   :${NC} ${YELLOW}$(trim_working_path_display "$FACTORY_HOME" 3)${NC}"
	echo -e "${CYAN} = = > Working Folder :${NC} ${YELLOW}$(trim_working_path_display "$FACTORY_WORKDIR" 3)${NC}"
	echo
	echo -e "${CYAN} = = > Shared Config  :${NC} ${YELLOW}$(trim_working_path_display "$FACTORY_CONFIG_FILE" 3)${NC}"
	echo -e "${CYAN}       Config State  :${NC} ${GREEN}${config_state}${NC}"
	echo -e "${CYAN} = = > SmartCut       :${NC} ${YELLOW}$(trim_working_path_display "$smc_display" 3)${NC}"
	echo
	echo -e "${CYAN} = = > Template Repo  :${NC} ${YELLOW}$(trim_working_path_display "$template_repo" 3)${NC}"
	echo -e "${CYAN}       Repo State    :${NC} ${GREEN}${template_state}${NC}"
	echo -e "${CYAN} = = > Working Link   :${NC} ${YELLOW}$(trim_working_path_display "$working_template" 3)${NC}"
	echo -e "${CYAN}       Link State    :${NC} ${GREEN}${working_state}${NC}"
	echo -e "${CYAN}       Authority     :${NC} ${YELLOW}${authority_display}${NC}"
	echo
	echo -e "${CYAN} = = > pHash Target   :${NC} ${YELLOW}$(trim_working_path_display "$PHASH_ENGINE" 3)${NC}"
	if [[ -n "$phash_active" ]]; then
		echo -e "${CYAN} = = > pHash Active   :${NC} ${YELLOW}$(trim_working_path_display "$phash_active" 3)${NC}"
	else
		echo -e "${CYAN} = = > pHash Active   :${NC} ${YELLOW}Not Built / Not Active${NC}"
	fi
	if [[ "$phash_status" == "ACTIVE PATH MISMATCH" ]]; then
		echo -e "${REB} = = > pHash Status   : ${phash_status}${NC}"
	else
		echo -e "${CYAN} = = > pHash Status   :${NC} ${GREEN}${phash_status}${NC}"
	fi
	if [[ -n "$phash_log_active" ]]; then
		echo -e "${CYAN} = = > pHash Log      :${NC} ${YELLOW}$(trim_working_path_display "$phash_log_active" 3)${NC}"
	else
		echo -e "${CYAN} = = > pHash Log      :${NC} ${YELLOW}Not Present${NC}"
	fi
	echo -e "${CYAN}============================================================${NC}"
	echo
}

    # ============================================================
    # #MARKER: STARTUP DEP CHECK ENTRY POINT
    # ============================================================
    # PURPOSE:
    # - Single call site for startup dependency handling.
    # - Keeps the top-level runtime path obvious.
    # ============================================================
run_startup_dependency_checks() {

	resolve_intro_template_authority || {
		echo -e "${REB} = = > Template Authority Was Not Resolved.${NC}"
		echo -e "${YELLOW} = = > Factory Cannot Safely Continue Template-Based Missions.${NC}"
		pause
		return 1
	}

	ensure_intro_template_dir
	check_required_dependencies_or_die
	detect_optional_tools
	show_startup_diagnostics
	pause
}

    # ============================================================
    # #MARKER: RUN STARTUP DEP CHECKS NOW
    # ============================================================
    # IMPORTANT:
    # - This is the actual trigger.
    # - Not the banner above.
    # - Not the line number.
    # - Execution reaches this call, so dependency checks happen here.
    # ============================================================
run_startup_dependency_checks  # - This is the actual trigger. first trigger of the startup right here

# End of dep_check auto run at all starts


# start of dep_check manual 
# initiated from menu by user
# ============================================================
# #MARKER: MANUAL DEPENDENCY STATUS / SYSTEM READINESS REPORT
# ============================================================
# PURPOSE:
# - Allow user to manually inspect dependency readiness at any time.
# - Show BOTH required and optional tools in one report.
# - Provide a troubleshooting view without aborting the script.
#
# DESIGN:
# - NON-DESTRUCTIVE
# - INFORMATIONAL ONLY
# - Does NOT exit the script
# - Safe to run from Utility / Advanced Tools menu
#
# WHY THIS EXISTS:
# - Startup dependency checks are strict because they protect the script.
# - But sometimes user just wants to inspect current system state.
# - This gives a "how ready is this machine?" report on demand.
#
# OUTPUT RULES:
# - Required tools show as OK or MISSING
# - Optional tools show as OK or MISSING plus feature impact
# - User may optionally view the install/help wall afterward
#
# Helper function for dependency checking but global
check_opt() {
	local dep="$1"
	local note="$2"

	if have_cmd "$dep"; then
		echo -e "${GREEN}[ OK ]${NC} $dep"
	else
		echo -e "${YELLOW}[MISS]${NC} $dep  -> $note"
	fi
}

inspect_dependencies() {
	local dep
	local sample_file=""
	local -a probe_candidates=()

	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > DEPENDENCY STATUS REPORT${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo

	echo -e "${YELLOW}--- REQUIRED CORE TOOLS ---${NC}"

	for dep in ffmpeg ffprobe bc awk sed grep df; do
		if have_cmd "$dep"; then
			echo -e "${GREEN}[ OK ]${NC} $dep"
		else
			echo -e "${REB}[MISS]${NC} $dep"
		fi
	done

	echo
	echo -e "${YELLOW}--- OPTIONAL / FEATURE TOOLS ---${NC}"

	check_opt python3     "Python-Based Helper Paths Unavailable"
	check_opt pipx        "Easy Scenedetect Install Path Unavailable"
	check_opt scenedetect "Automatic Intro Detection Unavailable"
	check_opt mkvpropedit "Fast In-Place MKV Metadata Edits Unavailable"
	check_opt ffplay      "Quick Preview / Review Playback Unavailable"
	check_opt findmnt     "Drive Label Display Will Fallback"
	check_opt less        "Long Notes Will Fallback To Plain Output"
	check_opt iconv       "Some Title Transliteration Behavior Reduced"
	check_opt tee         "Some logging / transcript capture helpers will be unavailable."

	if command -v pipx >/dev/null && \
	   [[ -x "$HOME/.local/bin/scenedetect" ]] && \
	   ! command -v scenedetect >/dev/null; then

		echo
		echo -e "${YE}------------------------------------------------------------${NC}"
		echo -e "${YEB} = = > scenedetect Installed But Not On PATH${NC}"
		echo -e "${CYAN} = = > Run:${NC} ${GREEN}pipx ensurepath${NC}"
		echo -e "${YE}------------------------------------------------------------${NC}"
	fi

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}        PLAYBACK / DIAGNOSTIC CAPABILITY        ${NC}"
	echo -e "${CYAN}============================================================${NC}"

	echo
	echo -e "${CYAN} = = > GPU / Decode Stack:${NC}"
	if have_cmd vainfo; then
		vainfo 2>/dev/null | sed -n '1,20p' || true
	else
		echo -e "${YELLOW} = = > vainfo Not Found.${NC}"
	fi

	echo
	have_cmd ffplay && echo -e "${GR} = = > ffplay Available (Playback Testing)${NC}" \
	                  || echo -e "${YE} = = > ffplay Missing (Cannot Test Playback)${NC}"

	have_cmd vainfo && echo -e "${GR} = = > vainfo Available (GPU Decode Info)${NC}" \
	                  || echo -e "${YE} = = > vainfo Missing (No HW Decode Visibility)${NC}"

	have_cmd mpv && echo -e "${GR} = = > mpv Available (Alt Playback Engine)${NC}" \
	               || echo -e "${YE} = = > mpv Missing${NC}"

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}        OPTIONAL SAMPLE DECODE TEST              ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${CYAN} = = > This checks FFmpeg decode ability against one real local media file.${NC}"
	echo -e "${CYAN} = = > For detailed file inventory, use Media Truth Probe.${NC}"
	echo

	shopt -s nullglob nocaseglob
	probe_candidates=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,webm,wmv})
	shopt -u nullglob nocaseglob

	if ((${#probe_candidates[@]} == 0)); then
		echo -e "${YE} = = > No local media file found for sample decode test.${NC}"
	else
		sample_file="${probe_candidates[0]}"
		echo -e "${CYAN} = = > Sample File:${NC} ${GREEN}$sample_file${NC}"
		echo

		echo -e "${YELLOW} = = > FFmpeg Video Decode Check (first 10 seconds, no preview window)...${NC}"
		if ffmpeg -v error -xerror -t 10 -i "$sample_file" -map 0:v:0 -f null - >/dev/null 2>&1; then
			echo -e "${GR} = = > Video Decode Check: PASS${NC}"
		else
			echo -e "${REB} = = > Video Decode Check: WARN / FAIL${NC}"
		fi

		echo -e "${YELLOW} = = > FFmpeg Software Video Decode Check (first 10 seconds, no preview window)...${NC}"
		if ffmpeg -v error -xerror -hwaccel none -t 10 -i "$sample_file" -map 0:v:0 -f null - >/dev/null 2>&1; then
			echo -e "${GR} = = > Software Video Decode Check: PASS${NC}"
		else
			echo -e "${REB} = = > Software Video Decode Check: WARN / FAIL${NC}"
		fi

		echo -e "${YELLOW} = = > FFmpeg Audio Decode Check (first 10 seconds, all audio streams)...${NC}"
		if ffmpeg -v error -xerror -t 10 -i "$sample_file" -map 0:a -f null - >/dev/null 2>&1; then
			echo -e "${GR} = = > Audio Decode Check: PASS${NC}"
		else
			echo -e "${YE} = = > Audio Decode Check: WARN / FAIL / NO AUDIO${NC}"
		fi
	fi

	echo
	echo -e "${CYAN} = = > Use 'Media Truth Probe' For File-Level Diagnostics${NC}"

	echo
	if ask_yes_no " = = > Show Install / Help Wall? (y/n or 1/2): "; then
		show_global_dependency_help_wall
	fi

	echo
	pause
}
# = = = = = = = = = = = = End of dep_check manual

# =========================
# #MARKER: MAIN MENU (WORKFLOW ENTRYPOINT)
# =========================
# PURPOSE:
# - Replace wrapper + missions dual-menu system
# - Present workflow-driven entry instead of tool-driven navigation
# - All tools must return here (or parent menu) instead of exiting script
#
# DESIGN:
# - No engines modified here
# - Only routing layer changed
# - Detection submenu may deliberately return a special code to launch the
#   legacy detection/file-processing engine below this menu layer
#
run_main_menu() {
  local main_status
  local cwd cwd_display drive_display

  while true; do
    clear

    echo -e "${RED}============================================================================${NC}"
    echo -e "${BWHITE}                           THE_FACTORY${NC}"
    echo -e "${CYAN}----------THE UNIVERSAL VIDEO SANITIZER & TRIMMER & META TITLE FIXER${NC}"
    echo -e "${CYAN}----Systematically Prepare And Process Episodes To Remove Tips Tails And The Intro${NC}"
    echo -e "${YEB}-------------IntroFind-v2.1- ${NC}${BWHITE}https://github.com/secarider/The_Factory${NC}"
    echo -e "${YEB}--------Video SmartCut-v1.7- ${NC}${BWHITE}https://github.com/skeskinen/smartcut${NC}"
    echo -e "${RED}============================================================================${NC}"
    cwd="$(pwd)"
    drive_display="$(get_drive_display "$cwd")"
    cwd_display="$(trim_working_path_display "$cwd" 3)"
    echo -e "${GREEN} = = > Working Drive/Folder:${NC} [${YELLOW}$drive_display${NC}] ${YELLOW}$cwd_display${NC}"
	resolve_smc_bin >/dev/null 2>&1 || true
	echo -e "${CYAN} = = > SmartCut:${NC} ${YELLOW}$(trim_working_path_display "${SMC_BIN:-not found}" 3)${NC}"
	echo -e "${GREEN} = = > Support Them Here: ${RE}https://${BW}smartmediacutter${CY}.com/${NC}"
	echo -e "${CYAN} = = > Template Link:${NC} ${YELLOW}intro_template -> $(trim_working_path_display "${INTRO_TEMPLATE_DIR:-${FACTORY_HOME}/intro_template}" 3)${NC}"

    # Disk space (important due to normalization expansion)
	local free_gb free_color free total

	free_gb=$(df -BG . | awk 'NR==2 {gsub("G","",$4); print $4}')

	if (( free_gb < 20 )); then
		free_color=$RED
	elif (( free_gb < 50 )); then
		free_color=$YELLOW
	else
		free_color=$GREEN
	fi

	read -r free total <<< "$(df -h . | awk 'NR==2 {print $4, $2}')"

    echo -e "${free_color} = = > $free${NC} ${YELLOW}<-- Total${NC}"
    echo -e "${free_color} = = >  ^ Free Space${NC}"

    # ------------------ WORKFLOW ------------------

    echo
    echo -e "${YELLOW}"
    echo "     1) Inspect / Explain Folder State"
    echo "     2) Prepare / Backup Sources"
    echo "     3) Subtitlez And Filename Repair"
    echo "     4) Create Intro / Outro Templates by SmartCut"
    echo "     5) Detect Intro / Outro by IntroFind-v2.1"
    echo "     6) Run SMARTGAP by Video SmartCut-v1.7"
    echo "     7) Run BARFIX Set Player Defaults,Title Bar Display"
    echo "     8) Cleanup / Finalize Folder"
    echo "     9) Utility / Advanced Tools"
    echo
    echo "     10-key exit > 0. (or q) Enter to quit"
    echo

	prompt_menu_choice "     Choice: " MAIN_CHOICE

    # ========================================================
    # TEN-KEY EXIT HOOK
    # ========================================================
    # IMPORTANT:
    # - In The MAIN MENU, 0. Means True Program Exit
    # - It Must Behave Like q, Not Like "Return From Function"
    # - If We Only return 0 Here, Control Falls Through Into The
    #   Legacy IntroFind Processing Tail Below run_main_menu
    #
    if is_exit_token "$MAIN_CHOICE"; then
    	echo -e "${YELLOW} = = > Exiting.${NC}"
    	exit 0
    fi

    case "$MAIN_CHOICE" in

      1)
        run_inspect
        ;;

      2)
        run_prepare_sources
        ;;

      3)
        run_title_subtitle_menu
        ;;

      4)
        create_template_smc
        ;;

      5)
        while true; do
          clear
          echo -e "${CYAN}================================================${NC}"
          echo -e "${CYAN}           INTRO DETECTION WORKFLOW             ${NC}"
          echo -e "${CYAN}================================================${NC}"
          echo
          echo -e "${YELLOW}     1) Set Intro/Outro Detection VarZ${NC}"
          echo -e "${CYAN}     2) Run Intro Detection Menu${NC}"
          echo -e "${CYAN}     3) Run OutroFind On Selected Files${NC}"
		  echo -e "${CYAN}     4) Outro Hash Compare Test${NC}"
          echo
          echo -e "${YELLOW}     0.) Return${NC}"
          echo

          prompt_menu_choice " = = > Select Option [1-4 | 0.=return]: " detect_choice

          if is_exit_token "$detect_choice"; then
            break
          fi

          case "$detect_choice" in
            1)
              smartcut_session_varz_menu introfind
              ;;

            2)
              main_status=0
              run_intro_detection_menu || main_status=$?

              # IMPORTANT:
              # - Special return code 10 means:
              #     "leave main menu now and continue into legacy detection engine"
              # - We must capture that without tripping set -e.
              if [[ "$main_status" -eq 10 ]]; then
                return 0
              fi
              ;;

            3)
              run_outrofind_selected_files
              ;;

			4)
			  run_outro_hash_compare_test
			  ;;

            *)
              echo -e "${REB} = = > Invalid.${NC}"
              pause
              ;;
          esac
        done
        ;;

      6)
        run_smartcut_menu
        ;;

      7)
        run_barfix
        ;;

      8)
        run_finalize_menu
        ;;

      9)
        run_utility_menu
        ;;

      [Qq])
        echo -e "${YELLOW} = = > Exiting.${NC}"
        exit 0
        ;;

      *)
        echo -e "${REB} = = > Invalid.${NC}"
        pause
        ;;
    esac
  done
}

    # =========================
    # #MARKER: BARFIX LOCAL HELPERS
    # =========================
    count_streams_of_type() {
      local file="$1"
      local stype="$2"

      ffprobe -v error -select_streams "${stype}" \
        -show_entries stream=index \
        -of csv=p=0 "$file" 2>/dev/null | wc -l
    }

find_audio_lang_ordinal() {
	local file="$1"
	local wanted_lang="${2:-eng}"
	local ord=0
	local lang

	wanted_lang="${wanted_lang,,}"
	wanted_lang="${wanted_lang// /}"

	while IFS= read -r lang; do
		lang="${lang,,}"
		lang="${lang// /}"

		case "$wanted_lang" in
			eng)
				[[ "$lang" == "eng" || "$lang" == "en" || "$lang" == "english" ]] && echo "$ord" && return 0
				;;
			jpn)
				[[ "$lang" == "jpn" || "$lang" == "ja" || "$lang" == "japanese" ]] && echo "$ord" && return 0
				;;
			spa)
				[[ "$lang" == "spa" || "$lang" == "es" || "$lang" == "spanish" ]] && echo "$ord" && return 0
				;;
			fra)
				[[ "$lang" == "fra" || "$lang" == "fre" || "$lang" == "fr" || "$lang" == "french" ]] && echo "$ord" && return 0
				;;
			deu)
				[[ "$lang" == "deu" || "$lang" == "ger" || "$lang" == "de" || "$lang" == "german" ]] && echo "$ord" && return 0
				;;
		esac

		((ord+=1)) || :
	done < <(
		ffprobe -v error -select_streams a \
			-show_entries stream_tags=language \
			-of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null
	)

	echo "-1"
}

    # =========================
    # #MARKER: BARFIX PLAYBACK DEFAULT ARG BUILDER
    # =========================
    # PURPOSE:
    # - Build safe ffmpeg disposition flags without reordering streams.
    # - Keep mapping simple: -map 0, preserve original stream order.
    # - Clear subtitle default behavior by clearing subtitle dispositions.
    # - Prefer first English-tagged audio as default if one is tagged.
    #
    # IMPORTANT:
    # - This does NOT duplicate streams.
    # - This does NOT physically reorder streams.
    # - Output audio/subtitle ordinal numbering here follows ffmpeg output
    #   stream-type order because we keep -map 0 in source order.
    #
build_playback_fix_args() {
	local file="$1"
	local audio_count sub_count lang_ord chosen_audio i
	local preferred_audio_lang="${SMC_BARFIX_AUDIO_LANG:-eng}"

	BARFIX_PLAYBACK_ARGS=()
	BARFIX_AUDIO_COUNT=0
	BARFIX_SUB_COUNT=0
	BARFIX_AUDIO_DEFAULT="NONE"
	BARFIX_AUDIO_REASON="No Audio Streams Found"

	audio_count="$(count_streams_of_type "$file" a)"
	sub_count="$(count_streams_of_type "$file" s)"

	BARFIX_AUDIO_COUNT="$audio_count"
	BARFIX_SUB_COUNT="$sub_count"

	if (( audio_count > 0 )); then
		lang_ord="$(find_audio_lang_ordinal "$file" "$preferred_audio_lang")"

		for ((i=0; i<audio_count; i++)); do
			BARFIX_PLAYBACK_ARGS+=(-disposition:a:${i} 0)
		done

		if [[ "$preferred_audio_lang" != "skip" ]] && [[ "$lang_ord" =~ ^[0-9]+$ ]] && (( lang_ord >= 0 )); then
			chosen_audio="$lang_ord"
			BARFIX_AUDIO_REASON="Preferred Audio (${preferred_audio_lang})"
		else
			chosen_audio="0"

			if [[ "$preferred_audio_lang" == "skip" ]]; then
				BARFIX_AUDIO_REASON="Audio Preference Skipped"
			else
				BARFIX_AUDIO_REASON="Preferred Language Not Found; Using First Audio"
			fi
		fi

		BARFIX_PLAYBACK_ARGS+=(-disposition:a:${chosen_audio} default)
		BARFIX_AUDIO_DEFAULT="$chosen_audio"
	fi

	if (( sub_count > 0 )); then
		for ((i=0; i<sub_count; i++)); do
			BARFIX_PLAYBACK_ARGS+=(-disposition:s:${i} 0)
		done
	fi
}

# ================================================================
# #MARKER: DETOX LITE FILENAME CONFORMANCE WARNING HELPER
# ================================================================
# PURPOSE:
# - Report-only filename conformance checker.
# - Does NOT rename files.
# - Used during BARFIX Lite / normal workflow so naming problems
#   do not silently become metadata titles.
#
# CURRENT WARNINGS:
# - _Part_1 / _Part_2 / _Part_I / _Part_II / _Part_III / _Part_IV
#   should become -Part1 / -Part2 / -PartI / -PartII / etc.
# - S04E18_E19 should become S04E18-E19.
# - S04E08andE09 should become S04E08-E09.
# ================================================================
detox_lite_suggest_filename() {
	local file="${1:-}"
	local dir base stem ext suggested

	dir="$(dirname -- "$file")"
	base="$(basename -- "$file")"

	if [[ "$base" == *.* ]]; then
		stem="${base%.*}"
		ext=".${base##*.}"
	else
		stem="$base"
		ext=""
	fi

	suggested="$stem"

	# Normalize trailing Part suffix:
	#   Title_Part_2   -> Title-Part2
	#   Title_Part_II  -> Title-PartII
	#   Title-Part-2   -> Title-Part2
	#   Title Part 2   -> Title-Part2
	suggested="$(printf '%s\n' "$suggested" | sed -E 's/[ _-]+[Pp][Aa][Rr][Tt][ _-]*(1|2|3|4|I|II|III|IV|i|ii|iii|iv)$/-Part\1/')"

	# Normalize roman part suffix case only for the known small set.
	suggested="$(printf '%s\n' "$suggested" \
		| sed -E 's/-Parti$/-PartI/; s/-Partii$/-PartII/; s/-Partiii$/-PartIII/; s/-Partiv$/-PartIV/')"

	# Normalize joined episode forms:
	#   S04E18_E19     -> S04E18-E19
	#   S04E18 E19     -> S04E18-E19
	#   S04E08andE09   -> S04E08-E09
	suggested="$(printf '%s\n' "$suggested" \
		| sed -E 's/(S[0-9]{2}E[0-9]{2})[ _]+(E[0-9]{2})/\1-\2/I' \
		| sed -E 's/(S[0-9]{2}E[0-9]{2})[ _-]*and[ _-]*(E[0-9]{2})/\1-\2/I')"

	if [[ "$suggested" != "$stem" ]]; then
		if [[ "$dir" == "." ]]; then
			printf '%s%s\n' "$suggested" "$ext"
		else
			printf '%s/%s%s\n' "$dir" "$suggested" "$ext"
		fi
		return 0
	fi

	return 1
}

detox_lite_warn_filename() {
	local file="${1:-}"
	local suggested=""

	suggested="$(detox_lite_suggest_filename "$file" 2>/dev/null || true)"

	[[ -n "$suggested" ]] || return 0
	[[ "$suggested" != "$file" ]] || return 0

	echo -e "${YE} = = > DETOX LITE Filename Warning:${NC} ${YELLOW}$(basename -- "$file")${NC}"
	echo -e "${CYAN} = = > Suggested Filename:${NC} ${GREEN}$(basename -- "$suggested")${NC}"
	echo -e "${YE} = = > Report Only: No Rename Was Performed.${NC}"
}

# ================================================================
# #MARKER: BARFIX TITLE EXTRACTION HELPER
# ================================================================
# PURPOSE:
# - Build player title metadata from filenames.
# - Support ordinary SxxExx and joined / two-part episode naming.
#
# SUPPORTED EPISODE BLOCKS:
# - S04E08_Title
# - S04E08andE09_Title
# - S04E08-S04E09_Title
# - S04E08-E09_Title
# - S04E18_E19_Title
#
# RULE:
# - In after_sxxexx mode, the title begins after the whole episode block,
#   not merely after the first SxxExx token.
# ================================================================
barfix_title_after_episode_block() {
	local name="$1"

	name="${name%.*}"
	name="$(strip_workflow_prefixes "$name")"

	# Full range: S04E08-S04E09_Title
	name="$(printf '%s\n' "$name" | sed -E 's/^.*S[0-9]{2}E[0-9]{2}[-_ .]+S[0-9]{2}E[0-9]{2}[_ .-]*(.*)$/\1/I')"

	# Short range: S04E08-E09_Title
	name="$(printf '%s\n' "$name" | sed -E 's/^.*S[0-9]{2}E[0-9]{2}[-_ .]+E[0-9]{2}[_ .-]*(.*)$/\1/I')"

	# Word join: S04E08andE09_Title
	name="$(printf '%s\n' "$name" | sed -E 's/^.*S[0-9]{2}E[0-9]{2}[[:space:]_.-]*and[[:space:]_.-]*E[0-9]{2}[_ .-]*(.*)$/\1/I')"

	# Plain single: S04E08_Title
	name="$(printf '%s\n' "$name" | sed -E 's/^.*S[0-9]{2}E[0-9]{2}[_ .-]*(.*)$/\1/I')"

	name="${name//_/ }"
	name="$(printf '%s\n' "$name" | sed -E 's/^[[:space:]-]+//; s/[[:space:]-]+$//; s/[[:space:]]+/ /g')"

	printf '%s\n' "$name"
}

# ================================================================
# #MARKER: BARFIX LITE FOR SMC OUTPUTS
# ================================================================
run_barfix_lite_on_file() {
	local file="$1"
	local title tmp ext start i
	local -a BARFIX_PLAYBACK_ARGS=()
	local -a parts=()

	[[ -f "$file" ]] || return 1

	detox_lite_warn_filename "$file"

	ext="${file##*.}"
	ext="${ext,,}"

	case "${SMC_BARFIX_TITLE_MODE:-skip}" in
		after_sxxexx)
			title="$(barfix_title_after_episode_block "$(basename "$file")")"
			;;
		full_filename)
			title="$(basename "$file")"
			title="${title%.*}"
			title="$(strip_workflow_prefixes "$title")"
			title="${title//_/ }"
			;;
		segment)
			title="$(basename "$file")"
			title="${title%.*}"
			title="$(strip_workflow_prefixes "$title")"

			IFS='_' read -ra parts <<< "$title"
			start="${SMC_BARFIX_TITLE_SEGMENT:-1}"

			title=""
			for ((i=start-1; i<${#parts[@]}; i++)); do
				title+="${parts[$i]} "
			done

			title="${title%% }"
			;;
		*)
			title=""
			;;
	esac

	if [[ -n "$title" && "$ext" == "mkv" && "$(command -v mkvpropedit 2>/dev/null)" ]]; then
		mkvpropedit "$file" --edit info --set "title=$title" >/dev/null 2>&1 || :
		echo -e "${GR} = = > BARFIX LITE TITLE-BAR Set TO --->:${NC} ${YELLOW}$title${NC}"
	fi

	if [[ "${SMC_BARFIX_AUDIO_LANG:-skip}" == "skip" && "${SMC_BARFIX_SUBS_OFF:-1}" != "1" ]]; then
		return 0
	fi

	build_playback_fix_args "$file"

	tmp="${file%.*}.barfix_lite_tmp.mkv"

	if ffmpeg -hide_banner -loglevel error -nostdin -i "$file" \
		-map 0 -c copy "${BARFIX_PLAYBACK_ARGS[@]}" \
		"$tmp" -y; then
		mv -f -- "$tmp" "$file"
		echo -e "${GR} = = > BARFIX LITE PLAYBACK DEFAULTS UPDATED:${NC} ${GREEN}$file${NC}"
	else
		rm -f -- "$tmp"
		echo -e "${YE} = = > BARFIX LITE PLAYBACK DEFAULTS FAILED:${NC} ${GREEN}$file${NC}"
	fi
}

# ================================================================
# #MARKER: BARFIX DEFAULTS DISPLAY / SESSION KNOBS
# ================================================================
# PURPOSE:
# - Give Full BARFIX The Same User-Facing Defaults Used By BARFIX Lite.
# - Keep Audio, Subtitle, And Title Preferences In One Shared Place.
# - Let SmartCut, BARFIX Lite, And Full BARFIX All Use The Same Brain.
#
# DESIGN:
# - BARFIX Lite stays silent and one-file-at-a-time.
# - Full BARFIX stays preview-first and batch-facing.
# - These helpers only manage shared defaults.
#
# SHARED VARS:
# - SMC_BARFIX_AUDIO_LANG
# - SMC_BARFIX_SUBS_OFF
# - SMC_BARFIX_TITLE_MODE
# - SMC_BARFIX_TITLE_SEGMENT
# ================================================================
show_barfix_current_defaults() {
	echo
	echo -e "${CYAN}=====================================================${NC}"
	echo -e "${CYAN}             CURRENT BARFIX DEFAULTS                 ${NC}"
	echo -e "${CYAN}=====================================================${NC}"
	echo -e "${CYAN} = = > Audio Language:${NC} ${YELLOW}${SMC_BARFIX_AUDIO_LANG:-eng}${NC}"
	echo -e "${CYAN} = = > Subtitles Off:${NC}  ${YELLOW}${SMC_BARFIX_SUBS_OFF:-1}${NC}"
	echo -e "${CYAN} = = > Title Mode:${NC}     ${YELLOW}${SMC_BARFIX_TITLE_MODE:-after_sxxexx}${NC}"
	echo -e "${CYAN} = = > Title Segment:${NC}  ${YELLOW}${SMC_BARFIX_TITLE_SEGMENT:-3}${NC}"
	echo
}

configure_barfix_defaults() {
	local choice

	echo
	echo -e "${CYAN}=====================================================${NC}"
	echo -e "${CYAN}              BARFIX DEFAULTS SETUP                  ${NC}"
	echo -e "${CYAN}=====================================================${NC}"
	echo

	echo -e "${YELLOW} = = > Preferred Audio Language Default${NC}"
	echo -e "${YELLOW} = = > If Available In Audio Streams${NC}"
	echo -e "${CYAN}     1) English${NC}"
	echo -e "${CYAN}     2) Japanese${NC}"
	echo -e "${CYAN}     3) Spanish${NC}"
	echo -e "${CYAN}     4) French${NC}"
	echo -e "${CYAN}     5) German${NC}"
	echo -e "${CYAN}     6) Keep Existing / No Audio Change${NC}"
	prompt_menu_choice " = = > Select [1-6 | blank=keep current]: " choice
	case "$choice" in
		"") ;;
		1) SMC_BARFIX_AUDIO_LANG="eng" ;;
		2) SMC_BARFIX_AUDIO_LANG="jpn" ;;
		3) SMC_BARFIX_AUDIO_LANG="spa" ;;
		4) SMC_BARFIX_AUDIO_LANG="fra" ;;
		5) SMC_BARFIX_AUDIO_LANG="deu" ;;
		6) SMC_BARFIX_AUDIO_LANG="skip" ;;
		*) echo -e "${YE} = = > Invalid Audio Choice. Keeping:${NC} ${YELLOW}${SMC_BARFIX_AUDIO_LANG:-eng}${NC}" ;;
	esac
	echo

	echo -e "${YELLOW} = = > Disable Subtitles By Default?${NC}"
	echo -e "${CYAN}     1) Yes${NC}"
	echo -e "${CYAN}     2) No / Leave Subtitle Defaults Alone${NC}"
	prompt_menu_choice " = = > Select [1/2 | blank=keep current]: " choice
	case "$choice" in
		"") ;;
		1) SMC_BARFIX_SUBS_OFF=1 ;;
		2) SMC_BARFIX_SUBS_OFF=0 ;;
		*) echo -e "${YE} = = > Invalid Subtitle Choice. Keeping:${NC} ${YELLOW}${SMC_BARFIX_SUBS_OFF:-1}${NC}" ;;
	esac
	echo

	echo -e "${YELLOW} = = > Title Naming Mode${NC}"
	echo -e "${CYAN}     1) After SxxExx${NC}"
	echo -e "${CYAN}     2) Full Filename${NC}"
	echo -e "${CYAN}     3) Skip Title Set${NC}"
	echo -e "${CYAN}     4) Choose Segment Number${NC}"
	prompt_menu_choice " = = > Select [1-4 | blank=keep current]: " choice
	case "$choice" in
		"") ;;
		1) SMC_BARFIX_TITLE_MODE="after_sxxexx" ;;
		2) SMC_BARFIX_TITLE_MODE="full_filename" ;;
		3) SMC_BARFIX_TITLE_MODE="skip" ;;
		4)
			SMC_BARFIX_TITLE_MODE="segment"
			prompt_read " = = > Start Title At Segment Number (current ${SMC_BARFIX_TITLE_SEGMENT:-3}): " choice
			[[ -n "$choice" ]] && SMC_BARFIX_TITLE_SEGMENT="$choice"
			;;
		*) echo -e "${YE} = = > Invalid Title Mode. Keeping:${NC} ${YELLOW}${SMC_BARFIX_TITLE_MODE:-after_sxxexx}${NC}" ;;
	esac

	echo
	echo -e "${GR} = = > BARFIX Defaults Updated.${NC}"
}

run_barfix() {

    clear
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${CYAN}      BARFIX v3 — TITLE + PLAYBACK DEFAULT TOOLS     ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${CYAN}======= Title Bar: ${NC}${GREEN}Name In Your Player Bar ==========${NC}"
    echo -e "${CYAN}======= Player Defaults: ${NC}${GREEN}Audio Language =============${NC}"
    echo -e "${CYAN}==== Subtitles Defaults: ${NC}${GREEN}On or Off and Language =====${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo
    echo -e "${YELLOW}"
    echo "     1) Title Metadata Only        (fast path)"
    echo "     2) Playback Defaults Only     (safe remux)"
    echo "     3) Title + Playback Defaults  (safe remux)"
    echo

    echo "     10-key exit > 0. (or q) Enter to quit"
    read -r -p "     Select BARFIX mode [1/2/3/q]: ${NC}${GREEN}" BARFIX_MODE
    echo -e "${NC}"
    if is_exit_token "$BARFIX_MODE"; then
        return 0
    fi

    if [[ "$BARFIX_MODE" != "1" && "$BARFIX_MODE" != "2" && "$BARFIX_MODE" != "3" ]]; then
      echo -e "${REB} = = > Invalid BARFIX Mode.${NC}"
      pause
      return 1
    fi

	# ================================================================
	# #MARKER: BARFIX FULL MODE DEFAULTS GATE
	# ================================================================
	# PURPOSE:
	# - Let Full BARFIX Use The Same Defaults As BARFIX Lite.
	# - Avoid Hidden Audio / Subtitle Choices.
	# - Keep One Shared BARFIX Brain Across Full BARFIX And SMC Post-Process.
	# ================================================================
	show_barfix_current_defaults

	echo -e "${YELLOW}     1) Use Current BARFIX Defaults${NC}"
	echo -e "${YELLOW}     2) Change BARFIX Defaults First${NC}"
	echo -e "${YELLOW}     0.) Return${NC}"
	echo
	prompt_menu_choice " = = > Select [1-2 | 0.=return | blank=use current]: " choice

	if is_exit_token "$choice"; then
		return 0
	fi

	case "${choice:-1}" in
		1)
			;;
		2)
			configure_barfix_defaults
			show_barfix_current_defaults
			;;
		*)
			echo -e "${YE} = = > Invalid Choice. Using Current BARFIX Defaults.${NC}"
			;;
	esac

	local SEG="${SMC_BARFIX_TITLE_SEGMENT:-3}"

    # Use SUBTOX's vids list (already collected) if available, else collect here.
    # NOTE: SUBTOX uses local-scoped vids, so BARFIX will usually scan the folder.
    # This is intentional for portable use: BARFIX should work standalone anywhere.
    local targets=()
    if declare -p vids >/dev/null 2>&1 && [[ ${#vids[@]} -gt 0 ]]; then
        for f in "${vids[@]}"; do
            [[ "$f" =~ ^(BARFIX_|SMC_|SUBPACKED_|REKEY_) ]] && continue
            targets+=("$f")
        done
    else
        shopt -s nullglob nocaseglob
        local -a files_local=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
        shopt -u nullglob nocaseglob
        for f in "${files_local[@]}"; do
            [[ "$f" =~ ^(BARFIX_|SMC_|SUBPACKED_|REKEY_) ]] && continue
            targets+=("$f")
        done
    fi

    if [[ ${#targets[@]} -eq 0 ]]; then
      echo -e "${RE} = = > No Video Targets Found (Or Only Internal/Generated Files).${NC}"
      pause
      return 1
    fi

    echo
    case "$BARFIX_MODE" in
      1)
        echo -e "${YELLOW} = = > BARFIX Mode: Title-Bar Seen Inur Player metadata only${NC}"
        if have_cmd mkvpropedit; then
          echo -e "${GREEN} = = > Fast In-Place MKV Edit Available.${NC}"
        else
          echo -e "${YELLOW} = = > mkvpropedit Not Found; Non-Destructive Remux Fallback Will Be Used.${NC}"
        fi
        ;;
      2)
        echo -e "${YELLOW} = = > BARFIX Mode: Playback Defaults Only. Subz Off,Eng Lang On As DefaultZ${NC}"
        echo -e "${CYAN} = = > Behavior: Safe Remux, Preserve Stream Order, Subtitles Off By Default, Prefer English Audio${NC}"
        ;;
      3)
        echo -e "${YELLOW} = = > BARFIX Mode: Title-Bar Seen Inur Player,Subz Off,Eng Lang On As DefaultZ${NC}"
        echo -e "${CYAN} = = > Behavior: Safe Remux, Preserve Stream Order, Subtitles Off By Default, Prefer English Audio${NC}"
        ;;
    esac

	echo
	echo -e "${CYAN}=====================================================${NC}"
	echo -e "${CYAN}          BARFIX TITLE / PLAYBACK PREVIEW             ${NC}"
	echo -e "${CYAN}=====================================================${NC}"
	echo

	if [[ "$BARFIX_MODE" == "1" || "$BARFIX_MODE" == "3" ]]; then
		echo -e "${CYAN} = = > Title Segment Start:${NC} ${YELLOW}$SEG${NC}"
		echo
	fi

	for f in "${targets[@]}"; do
		if [[ "$BARFIX_MODE" == "1" || "$BARFIX_MODE" == "3" ]]; then
			local t
			t="$(make_title_from_filename "$f" "$SEG")"
			printf '  %b%s%b  ->  %b%s%b\n' \
				"$GREEN" "$f" "$NC" \
				"$YELLOW" "$t" "$NC"
		else
			printf '  %b%s%b\n' "$GREEN" "$f" "$NC"
		fi
	done

	echo
	if ! ask_yes_no " = = > Proceed With BARFIX? (y/n or 1/2): "; then
		echo -e "${REB} = = > Aborted.${NC}"
		pause
		return 0
	fi

    echo
    local total=${#targets[@]}
    local current=1

    for f in "${targets[@]}"; do
      local t ext name out
      local -a BARFIX_PLAYBACK_ARGS
      local BARFIX_AUDIO_COUNT BARFIX_SUB_COUNT BARFIX_AUDIO_DEFAULT BARFIX_AUDIO_REASON

      ext="${f##*.}"

      echo -e "${YELLOW}[$current / $total]${NC} ${CYAN}Fixing:${NC} ${GREEN}$f${NC}"

      if [[ "$BARFIX_MODE" == "1" || "$BARFIX_MODE" == "3" ]]; then
        t="$(make_title_from_filename "$f" "$SEG")"
        echo -e "${CYAN} = = > Title:${NC}${GREEN} $t${NC}"
      fi
#-----------------------------------------------------------------------------------------------
      # =========================
      # #MARKER: BARFIX MODE 1 FAST TITLE-ONLY PATH
      # =========================
      # Keep this path as close as possible to the current known-good BARFIX.
      if [[ "$BARFIX_MODE" == "1" ]]; then
        if [[ "${ext,,}" == "mkv" ]] && have_cmd mkvpropedit; then
          if mkvpropedit "$f" --edit info --set "title=$t" >/dev/null 2>&1; then
            echo -e "  ${GREEN} = = > Updated In-Place:${NC} ${YELLOW}$f${NC}"
          else
            echo -e "  ${REB} = = > FAILED In-Place:${NC} ${YELLOW}$f${NC}"
          fi
        else
          name="${f%.*}"
          out="$(build_stage_output_name "BARFIX" "$f")"

          if ffmpeg -hide_banner -loglevel error -nostdin -i "$f" \
            -map 0 -c copy -metadata title="$t" \
            "$out" -y; then
            echo -e "  ${GREEN} = = > Created:${NC} ${YELLOW}$out${NC}"
            stage_archive_file "$f" "BARFIX"
            f="$out"
          else
            echo -e "  ${REB} = = > FAILED:${NC} ${YELLOW}$f${NC}"
            rm -f "$out"
          fi
        fi

        ((current+=1)) || :
        continue
      fi

      # =========================
      # #MARKER: BARFIX PLAYBACK REMUX PATH
      # =========================
      build_playback_fix_args "$f"

      if [[ "$BARFIX_AUDIO_DEFAULT" == "NONE" ]]; then
        echo -e "${YELLOW} = = > Audio Default:${NC} ${GREEN}None Available${NC}"
      else
        echo -e "${CYAN} = = > Audio Streams:${NC} ${GREEN}$BARFIX_AUDIO_COUNT${NC}"
        echo -e "${CYAN} = = > Subtitle Streams:${NC} ${GREEN}$BARFIX_SUB_COUNT${NC}"
        echo -e "${CYAN} = = > Default Audio Output Stream:${NC} ${GREEN}$((BARFIX_AUDIO_DEFAULT + 1))${NC}"
        echo -e "${CYAN} = = > Audio Choice Reason:${NC} ${GREEN}$BARFIX_AUDIO_REASON${NC}"
      fi

      name="${f%.*}"
      out="$(build_stage_output_name "BARFIX" "$f")"

      if [[ "$BARFIX_MODE" == "2" ]]; then
        if ffmpeg -hide_banner -loglevel error -nostdin -i "$f" \
          -map 0 -c copy \
          "${BARFIX_PLAYBACK_ARGS[@]}" \
          "$out" -y; then
          echo -e "  ${GR} = = > Created:${NC} ${YELLOW}$out${NC}"
          stage_archive_file "$f" "BARFIX"
          f="$out"
        else
          echo -e "  ${RE} = = > FAILED:${NC} ${YELLOW}$f${NC}"
          rm -f "$out"
        fi
      else
        if ffmpeg -hide_banner -loglevel error -nostdin -i "$f" \
          -map 0 -c copy \
          "${BARFIX_PLAYBACK_ARGS[@]}" \
          -metadata title="$t" \
          "$out" -y; then
          echo -e "  ${GR} = = > Created:${NC} ${YELLOW}$out${NC}"
          stage_archive_file "$f" "BARFIX"
          f="$out"
        else
          echo -e "  ${RE} = = > FAILED:${NC} ${YELLOW}$f${NC}"
          rm -f "$out"
        fi
      fi

      ((current+=1)) || :
    done

    echo
    echo -e "${GREEN} = = > BARFIX DONE${NC}"
    pause
    return 0
}
#  -------------------barfix end ------------------------------------------

# ================================================================
# #MARKER: CSV PREFIX SEGMENT SELECTOR
# ================================================================
# PURPOSE:
# - Allow user to interactively choose which underscore
#   segments should become the authority show prefix.
#
# EXAMPLE:
#   INPUT:
#       SG_Atlantis
#
#   SEGMENTS:
#       1) SG
#       2) Atlantis
#
#   USER INPUT:
#       1,2   -> SG_Atlantis
#       1     -> SG
#       2     -> Atlantis
#       2,1   -> Atlantis_SG
#
# RETURNS:
#   Selected underscore-joined prefix on STDOUT.
# ================================================================
declare -A CSV_PREFIX_CHOICE_CACHE=()


csv_choose_prefix_segments() {
	local prefix="$1"
	local __out_var="$2"
	local sample_old="${3:-}"
	local sample_code="${4:-}"
	local sample_title="${5:-}"
	local selection result idx
	local -a segs=()
	local -a chosen=()

	IFS='_' read -ra segs <<< "$prefix"

	if (( ${#segs[@]} <= 1 )); then
		printf -v "$__out_var" '%s' "$prefix"
		return 0
	fi

	{
		echo
		echo -e "${CYAN}------------------------------------------------------------${NC}"
		echo -e "${CYAN} = = > CSV PREFIX LAYOUT REVIEW${NC}"
		echo -e "${CYAN}------------------------------------------------------------${NC}"
		echo -e "${CYAN} = = > Sample Row:${NC} ${YELLOW}$sample_old${NC}"
		echo -e "${CYAN} = = > Episode Code:${NC} ${YELLOW}$sample_code${NC}"
		echo -e "${CYAN} = = > Episode Title:${NC} ${YELLOW}$sample_title${NC}"
		echo
		echo -e "${CYAN} = = > Current Prefix:${NC} ${GREEN}$prefix${NC}"
		echo

		for (( idx=0; idx<${#segs[@]}; idx++ )); do
			echo -e "${YELLOW}     $((idx+1))) ${segs[$idx]}${NC}"
		done

		echo
		echo -e "${CYAN} = = > Examples:${NC}"
		echo -e "${YELLOW}     blank = keep ${prefix}${NC}"
		echo -e "${YELLOW}     1     = ${segs[0]}${NC}"
		(( ${#segs[@]} >= 2 )) && echo -e "${YELLOW}     2     = ${segs[1]}${NC}"
		echo -e "${YELLOW}     1,2   = ${prefix}${NC}"
		echo
		echo -ne "${YELLOW} = = > Choose Prefix Segment Layout Once For This Prefix: ${NC}${GREEN}"
	} >/dev/tty

	read -r selection </dev/tty
	echo -e "${NC}" >/dev/tty

	selection="${selection//[[:space:]]/}"

	if [[ -z "$selection" ]]; then
		result="$prefix"
	else
		IFS=',' read -ra chosen <<< "$selection"
		result=""

		for idx in "${chosen[@]}"; do
			[[ "$idx" =~ ^[0-9]+$ ]] || continue
			if (( idx >= 1 && idx <= ${#segs[@]} )); then
				[[ -n "$result" ]] && result+="_"
				result+="${segs[$((idx-1))]}"
			fi
		done

		[[ -z "$result" ]] && result="$prefix"
	fi

	CSV_PREFIX_CHOICE_CACHE[$prefix]="$result"
	printf -v "$__out_var" '%s' "$result"

	{
		echo
		echo -e "${GR} = = > Selected Prefix For Matching Rows:${NC} ${GREEN}$result${NC}"
		echo
	} >/dev/tty

	return 0
}

# ================================================================
# #MARKER: CSV AUTHORITY PREP / NORMALIZER
# ================================================================
# PURPOSE:
# - Prepare episodes.csv for Factory authority use.
# - Convert legacy two-column CSV into headered authority CSV.
# - Detox filename-facing fields before they are trusted.
# - Preview before writing.
# - Backup before writing.
#
# CANONICAL SCHEMA:
#   series,show,episode_code,episode_title,air_date,overall_episode,notes
#
# FACTORY NAMING RULE:
# - episode_code and episode_title are authority fields.
# - episode_title should be filename-safe, not pretty prose.
# - extra imported metadata is preserved only when safely understood.
#
# LEGACY SUPPORTED:
#   S01E01,Episode Title
#   SG_Atlantis_S01E01,Episode Title
#
# SAFETY:
# - No blind writes.
# - Original episodes.csv gets timestamp backup.
# ================================================================
csv_auth_prep() {
	local csv="episodes.csv"
	local tmp_new tmp_preview backup
	local line first_line
	local col1 col2 rest
	local series show episode_code episode_title air_date overall_episode notes
	local changed_count=0 skipped_count=0 row_count=0
	local default_show input

	clear
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}              CSV AUTHORITY PREP / NORMALIZER               ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${CYAN} = = > This prepares episodes.csv for Factory authority use.${NC}"
	echo -e "${CYAN} = = > It writes a headered, filename-safe authority CSV.${NC}"
	echo -e "${YE} = = > Preview First. Backup Before Write.${NC}"
	echo

	[[ -f "$csv" ]] || {
		echo -e "${REB} = = > Missing:${NC} ${YELLOW}$csv${NC}"
		pause
		return 1
	}

	default_show=""

	tmp_new="$(mktemp)"
	tmp_preview="$(mktemp)"

	printf '%s\n' "series,show,episode_code,episode_title,air_date,overall_episode,notes" > "$tmp_new"

	first_line="$(head -n 1 "$csv" 2>/dev/null || true)"
	first_line="${first_line//$'\r'/}"

	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line//$'\r'/}"
		[[ -z "$line" ]] && continue

		# Skip known header rows.
		if printf '%s\n' "$line" | grep -qiE '^(series,show,episode_code|episode_code,episode_title|filename,title)'; then
			continue
		fi

		((row_count+=1)) || :

		col1="${line%%,*}"

		if [[ "$line" == *,* ]]; then
			rest="${line#*,}"
			col2="${rest%%,*}"
		else
			col2=""
			rest=""
		fi

		col1="${col1%\"}"
		col1="${col1#\"}"
		col2="${col2%\"}"
		col2="${col2#\"}"

		episode_code="$(printf '%s\n' "$col1" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 | tr '[:lower:]' '[:upper:]' || true)"

		if [[ -z "$episode_code" ]]; then
			echo -e "${YE} = = > Skipping Row With No SxxExx:${NC} ${YELLOW}$line${NC}"
			printf 'SKIP|NO_CODE|%s|\n' "$line" >> "$tmp_preview"
			((skipped_count+=1)) || :
			continue
		fi

		show="$default_show"

		if [[ -z "$show" ]]; then
			show="$(printf '%s\n' "$col1" | sed -E "s/${episode_code}.*//I")"
			show="${show%_}"
			show="${show%-}"
			show="${show%.}"

		if [[ -n "${CSV_PREFIX_CHOICE_CACHE[$show]:-}" ]]; then
			show="${CSV_PREFIX_CHOICE_CACHE[$show]}"
		else
			csv_choose_prefix_segments "$show" show "$line" "$episode_code" "$col2"
		fi
		fi

		series=""
		episode_title="$col2"

		# ------------------------------------------------------------
		# DETOX FILENAME-FACING AUTHORITY FIELDS
		# ------------------------------------------------------------
		# Remove apostrophes instead of creating ugly _s splits.
		# Convert spacing/punctuation to underscores.
		# Collapse repeated underscores.
		# Trim leading/trailing underscores.
		# ------------------------------------------------------------
		show="${show//\'/}"
		show="${show//’/}"
		show="$(printf '%s\n' "$show" | sed -E 's/[[:space:]]+/_/g; s/[^A-Za-z0-9._-]+/_/g; s/_+/_/g; s/^_+//; s/_+$//')"

		series="${series//\'/}"
		series="${series//’/}"
		series="$(printf '%s\n' "$series" | sed -E 's/[[:space:]]+/_/g; s/[^A-Za-z0-9._-]+/_/g; s/_+/_/g; s/^_+//; s/_+$//')"

		episode_title="${episode_title//\'/}"
		episode_title="${episode_title//’/}"
		episode_title="$(printf '%s\n' "$episode_title" | sed -E 's/[[:space:]]+/_/g; s/[^A-Za-z0-9._-]+/_/g; s/_+/_/g; s/^_+//; s/_+$//')"

		air_date=""
		overall_episode=""
		notes=""

		printf '"%s","%s","%s","%s","%s","%s","%s"\n' \
			"$series" "$show" "$episode_code" "$episode_title" "$air_date" "$overall_episode" "$notes" >> "$tmp_new"

		printf 'CHANGE|NORMALIZED|%s|%s,%s,%s,%s\n' \
			"$line" "$series" "$show" "$episode_code" "$episode_title" >> "$tmp_preview"

		((changed_count+=1)) || :

	done < "$csv"

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}                 CSV AUTHORITY PREP PREVIEW                 ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo

	while IFS='|' read -r status reason old new; do
		case "$status" in
			CHANGE)
				echo -e "${GR} = = > NORMALIZED:${NC}"
				echo -e "${CYAN}     OLD:${NC} ${YELLOW}$old${NC}"
				echo -e "${CYAN}     NEW:${NC} ${GREEN}$new${NC}"
				;;
			SKIP)
				echo -e "${YE} = = > SKIPPED:${NC} ${YELLOW}$old${NC} ${CYAN}($reason)${NC}"
				;;
		esac
	done < "$tmp_preview"

	echo
	echo -e "${CYAN} = = > Rows Seen:${NC} ${YELLOW}$row_count${NC}"
	echo -e "${CYAN} = = > Rows Prepared:${NC} ${GREEN}$changed_count${NC}"
	echo -e "${CYAN} = = > Rows Skipped:${NC} ${YELLOW}$skipped_count${NC}"
	echo

	if (( changed_count == 0 )); then
		echo -e "${YE} = = > No Prepared Rows Available. Nothing Written.${NC}"
		rm -f -- "$tmp_new" "$tmp_preview"
		pause
		return 0
	fi

	if ! ask_yes_no " = = > Write Prepared episodes.csv Authority File? [1=yes | 2=no]: "; then
		echo -e "${YE} = = > CSV Authority Prep Canceled. Nothing Written.${NC}"
		rm -f -- "$tmp_new" "$tmp_preview"
		pause
		return 0
	fi

	backup="${csv}.bak_$(date '+%Y%m%d_%H%M%S')"
	cp -p -- "$csv" "$backup"
	mv -f -- "$tmp_new" "$csv"
	rm -f -- "$tmp_preview"

	echo
	echo -e "${GR} = = > episodes.csv Authority Prep Complete.${NC}"
	echo -e "${CYAN} = = > Backup:${NC} ${GREEN}$backup${NC}"
	echo -e "${CYAN} = = > Prepared Rows:${NC} ${YELLOW}$changed_count${NC}"
	echo

	pause
	return 0
}

# ================================================================
# #MARKER: REPAIR INTRO_MAP/OUTRO_MAP FILENAMES FROM EPISODES AUTHORITY
# ================================================================

repair_intro_map() {
	repair_timing_map_filenames "intro_map.csv" "INTRO_MAP"

	if [[ -f "outro_map.csv" ]]; then
		echo
		if ask_yes_no " = = > outro_map.csv Found. Repair It Too? [1=yes | 2=no]: "; then
			repair_timing_map_filenames "outro_map.csv" "OUTRO_MAP"
		fi
	fi
}

repair_timing_map_filenames() {
	local map_csv="${1:-intro_map.csv}"
	local map_label="${2:-TIMING_MAP}"
	local auth_csv="episodes.csv"
	local tmp_plan tmp_new backup
	local line filename rest ep_code new_file
	local changed_count=0 skipped_count=0 missing_count=0 ambiguous_count=0

	clear
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}        REPAIR ${map_label} FILENAMES USING EPISODES.CSV       ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${CYAN} = = > This repairs ONLY column 1 of ${map_csv}.${NC}"
	echo -e "${CYAN} = = > Timing columns are preserved exactly as-is.${NC}"
	echo -e "${YE} = = > Preview First. Backup Before Write. No Blind CSV Surgery.${NC}"
	echo

	[[ -f "$map_csv" ]] || {
		echo -e "${REB} = = > Missing:${NC} ${YELLOW}$map_csv${NC}"
		pause
		return 1
	}

	[[ -f "$auth_csv" ]] || {
		echo -e "${REB} = = > Missing:${NC} ${YELLOW}$auth_csv${NC}"
		echo -e "${YE} = = > episodes.csv is needed as the naming authority.${NC}"
		pause
		return 1
	}

	tmp_plan="$(mktemp)"
	tmp_new="$(mktemp)"

	# Build repaired intro_map preview/new file.
	while IFS= read -r line || [[ -n "$line" ]]; do
		line="${line//$'\r'/}"

		if [[ -z "$line" ]]; then
			printf '\n' >> "$tmp_new"
			continue
		fi

		if [[ "$line" == filename,* ]]; then
			printf '%s\n' "$line" >> "$tmp_new"
			continue
		fi

		filename="${line%%,*}"
		rest="${line#*,}"

		ep_code="$(printf '%s\n' "$filename" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 | tr '[:lower:]' '[:upper:]' || true)"

		if [[ -z "$ep_code" ]]; then
			printf '%s\n' "$line" >> "$tmp_new"
			printf 'SKIP|NO_CODE|%s|\n' "$filename" >> "$tmp_plan"
			((skipped_count+=1)) || :
			continue
		fi

		# Confirm this code exists in episodes.csv authority.
		if ! awk -F',' -v code="$ep_code" '
			BEGIN { found=0 }
			{
				row=toupper($0)
				if (row ~ code) found=1
			}
			END { exit !found }
		' "$auth_csv"; then
			printf '%s\n' "$line" >> "$tmp_new"
			printf 'SKIP|NO_AUTH|%s|\n' "$filename" >> "$tmp_plan"
			((skipped_count+=1)) || :
			continue
		fi

		# Find current working-dir video with matching SxxExx.
		mapfile -t matches < <(
			find . -maxdepth 1 -type f \
				\( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.m4v" -o -iname "*.webm" \) \
				-printf '%f\n' 2>/dev/null \
				| grep -iE "$ep_code" \
				| grep -viE '^(intro_template|PILOT_|OEM_)' \
				| sort
		)

		if (( ${#matches[@]} == 0 )); then
			printf '%s\n' "$line" >> "$tmp_new"
			printf 'MISS|NO_FILE|%s|\n' "$filename" >> "$tmp_plan"
			((missing_count+=1)) || :
			continue
		fi

		if (( ${#matches[@]} > 1 )); then
			printf '%s\n' "$line" >> "$tmp_new"
			printf 'AMBIG|MULTIPLE|%s|%s\n' "$filename" "${matches[*]}" >> "$tmp_plan"
			((ambiguous_count+=1)) || :
			continue
		fi

		new_file="${matches[0]}"

		if [[ "$new_file" == "$filename" ]]; then
			printf '%s\n' "$line" >> "$tmp_new"
			printf 'OK|UNCHANGED|%s|%s\n' "$filename" "$new_file" >> "$tmp_plan"
			continue
		fi

		printf '%s,%s\n' "$new_file" "$rest" >> "$tmp_new"
		printf 'CHANGE|REPAIR|%s|%s\n' "$filename" "$new_file" >> "$tmp_plan"
		((changed_count+=1)) || :

	done < "$map_csv"

	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}                    ${map_label} REPAIR PREVIEW             ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo

	while IFS='|' read -r status reason old new; do
		case "$status" in
			CHANGE)
				echo -e "${GR} = = > CHANGE:${NC}"
				echo -e "${CYAN}     OLD:${NC} ${YELLOW}$old${NC}"
				echo -e "${CYAN}     NEW:${NC} ${GREEN}$new${NC}"
				;;
			AMBIG)
				echo -e "${YE} = = > AMBIGUOUS:${NC} ${YELLOW}$old${NC}"
				echo -e "${YE}     Matches:${NC} ${YELLOW}$new${NC}"
				;;
			MISS)
				echo -e "${YE} = = > MISSING CURRENT FILE:${NC} ${YELLOW}$old${NC}"
				;;
			SKIP)
				echo -e "${YE} = = > SKIPPED:${NC} ${YELLOW}$old${NC} ${CYAN}($reason)${NC}"
				;;
		esac
	done < "$tmp_plan"

	echo
	echo -e "${CYAN} = = > Proposed Repairs:${NC} ${YELLOW}$changed_count${NC}"
	echo -e "${CYAN} = = > Missing Files:${NC} ${YELLOW}$missing_count${NC}"
	echo -e "${CYAN} = = > Ambiguous Rows:${NC} ${YELLOW}$ambiguous_count${NC}"
	echo -e "${CYAN} = = > Skipped Rows:${NC} ${YELLOW}$skipped_count${NC}"
	echo

	if (( changed_count == 0 )); then
		echo -e "${YE} = = > No Safe ${map_csv} Repairs Available.${NC}"
		rm -f -- "$tmp_plan" "$tmp_new"
		pause
		return 0
	fi

	if ! ask_yes_no " = = > Apply These intro_map.csv Filename Repairs? [1=yes | 2=no]: "; then
		echo -e "${YE} = = > Repair Canceled. Nothing Written.${NC}"
		rm -f -- "$tmp_plan" "$tmp_new"
		pause
		return 0
	fi

	backup="${map_csv}.bak_$(date '+%Y%m%d_%H%M%S')"
	cp -p -- "$map_csv" "$backup"
	mv -f -- "$tmp_new" "$map_csv"
	rm -f -- "$tmp_plan"

	echo
	echo -e "${GR} = = > ${map_csv} Repaired.${NC}"
	echo -e "${CYAN} = = > Backup:${NC} ${GREEN}$backup${NC}"
	echo -e "${CYAN} = = > Repairs Applied:${NC} ${YELLOW}$changed_count${NC}"
	echo

	pause
	return 0
}

# ================================================================
# #MARKER: RUN EPISODES CSV AUTH UPGRADE
# ================================================================
run_episodes_csv_auth_upgrade() {

	local csv_file

	if ! csv_file="$(pick_episode_csv_file)"; then
		echo -e "${YE} = = > CSV Upgrade Canceled.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${CYAN} = = > Selected CSV:${NC} ${GREEN}$csv_file${NC}"
	echo

	if ! ask_yes_no " = = > Create Non-Destructive AUTH_v2 Copy? (y/n or 1/2): "; then
		echo -e "${YE} = = > Upgrade Canceled.${NC}"
		pause
		return 0
	fi

	upgrade_episodes_csv_to_auth_v2 "$csv_file"

	pause
	return 0
}

# ================================================================
# #MARKER: EPISODES CSV HEADER AUTH UPGRADE HELPER
# ================================================================
# PURPOSE:
# - Safely Upgrade Older Headerless episodes.csv Files
# - Preserve Original CSV Untouched
# - Generate New Headered Authority CSV
#
# INPUT SUPPORT:
#
# OLD 2-COLUMN:
#   S05E01,Well_Follow_The_Sun
#
# OLD 5-COLUMN:
#   S05E01,Series,Raw Title,Detox_Title,Full_Name
#
# NEW OUTPUT:
#   episode,title,series,full_name
#
# SAFETY:
# - Original CSV Is NEVER Modified
# - Timestamped Backup Copy Is Created
# - New CSV Written Beside Original
# ================================================================
upgrade_episodes_csv_to_auth_v2() {

	local src_csv="$1"

	local backup_csv
	local out_csv
	local timestamp

	local line_count=0
	local converted_count=0

	local ep title series full_name
	local c1 c2 c3 c4 c5

	[[ -f "$src_csv" ]] || {
		echo -e "${REB} = = > CSV Not Found:${NC} ${YELLOW}$src_csv${NC}"
		return 1
	}

	timestamp="$(date '+%Y%m%d_%H%M%S')"

	backup_csv="${src_csv}.ORIGINAL_${timestamp}"
	out_csv="${src_csv%.csv}.AUTH_v2.csv"

	cp -- "$src_csv" "$backup_csv"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      EPISODES CSV AUTH V2 UPGRADE START        ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src_csv${NC}"
	echo -e "${CYAN} = = > Backup:${NC} ${YELLOW}$backup_csv${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out_csv${NC}"
	echo

	printf 'episode,title,series,full_name\n' > "$out_csv"

	while IFS= read -r line || [[ -n "$line" ]]; do

		((line_count+=1)) || :

		# Skip blank lines
		[[ -z "${line//[[:space:]]/}" ]] && continue

		# Skip existing header rows
		if [[ "${line,,}" =~ ^episode, ]]; then
			continue
		fi

		IFS=',' read -r c1 c2 c3 c4 c5 _ <<< "$line"

		ep=""
		title=""
		series=""
		full_name=""

		# ------------------------------------------------
		# OLD 5-COLUMN FORMAT
		# ------------------------------------------------
		if [[ -n "${c5:-}" ]]; then

			ep="$c1"
			series="$c2"
			title="$c4"
			full_name="$c5"

		# ------------------------------------------------
		# OLD 2-COLUMN FORMAT
		# ------------------------------------------------
		else

			ep="$c1"
			title="$c2"
			series=""
			full_name=""

		fi

		# Skip invalid rows
		[[ -z "$ep" || -z "$title" ]] && continue

		printf '%s,%s,%s,%s\n' \
			"$ep" \
			"$title" \
			"$series" \
			"$full_name" >> "$out_csv"

		((converted_count+=1)) || :

	done < "$src_csv"

	echo
	echo -e "${GR} = = > CSV Upgrade Complete.${NC}"
	echo -e "${CYAN} = = > Rows Converted:${NC} ${YELLOW}$converted_count${NC}"
	echo -e "${CYAN} = = > New Authority CSV:${NC} ${GREEN}$out_csv${NC}"
	echo
}

pick_episode_csv_file() {
	local -a csvs=()
	local choice

	shopt -s nullglob nocaseglob

	# --------------------------------------------------
	# PRIORITY ORDER:
	#   1) *episodes*.csv
	#   2) episodes.csv
	#   3) any remaining *.csv
	#
	# DEDUPE:
	# - avoid same file appearing multiple times
	# --------------------------------------------------
	local seen
	for seen in *episodes*.csv episodes.csv *.csv; do
		[[ -f "$seen" ]] || continue

		if [[ ! " ${csvs[*]} " =~ " ${seen} " ]]; then
			csvs+=("$seen")
		fi
	done

	shopt -u nullglob nocaseglob

	if (( ${#csvs[@]} == 0 )); then
		echo -e "${REB} = = > No CSV Files Found.${NC}" >&2
		return 1
	fi

	echo -e "${CYAN} = = > Episode CSV Candidates:${NC}" >&2
	local i
	for i in "${!csvs[@]}"; do
		printf '%b%5d)%b %b%s%b\n' "$YELLOW" "$((i+1))" "$NC" "$GREEN" "${csvs[$i]}" "$NC" >&2
	done
	echo >&2

	echo -ne "${YELLOW} = = > Select CSV [number | 0.=return]: ${NC}${GREEN}" >&2
	read -r choice
	echo -e "${NC}" >&2

	choice="${choice//[[:space:]]/}"
	choice="${choice,,}"

	if is_exit_token "$choice"; then
		return 1
	fi

	if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#csvs[@]} )); then
		echo -e "${REB} = = > Invalid CSV Selection.${NC}" >&2
		return 1
	fi

	printf '%s\n' "${csvs[$((choice-1))]}"
}

run_subtox_csv_authority_rename() {
	local -a vids=("$@")
	local csv_file
	local file ext ep_code csv_hit csv_key ep_title clean_title prefix new_name
	local changed=0 skipped=0
	local -a rename_old=()
	local -a rename_new=()

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          CSV AUTHORITY RENAME BY SxxExx        ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > This Mode Treats The Selected CSV As The Naming Authority.${NC}"
	echo -e "${CYAN} = = > It Finds SxxExx In Each Filename, Looks Up The CSV Key + Title,${NC}"
	echo -e "${CYAN}      Then Rebuilds The Filename And Drops Extra Tail Garbage.${NC}"
	echo

	csv_file="$(pick_episode_csv_file)" || {
		echo -e "${YE} = = > CSV Authority Rename Cancelled: No CSV Selected.${NC}"
		pause
		return 0
	}

	echo
	echo -e "${CYAN} = = > Selected CSV:${NC} ${GREEN}$csv_file${NC}"
	echo

	if ! ask_yes_no " = = > Build CSV-Authority Rename Plan Now? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > CSV Authority Rename Cancelled.${NC}"
		pause
		return 0
	fi

	for file in "${vids[@]}"; do
		[[ -f "$file" ]] || continue

		ep_code="$(printf '%s\n' "$file" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 | tr '[:lower:]' '[:upper:]' || true)"

		if [[ -z "$ep_code" ]]; then
			echo -e "${YE} = = > [SKIP NO SxxExx]${NC} ${YELLOW}$file${NC}"
			((skipped+=1)) || :
			continue
		fi

		csv_hit="$(
			awk -F',' -v code="$ep_code" '
				{
					row_key=$1
					title=$0
					sub(/^[^,]*,/, "", title)

					clean_key=row_key
					gsub(/\r/, "", clean_key)
					gsub(/^[ \t"]+|[ \t"]+$/, "", clean_key)

					clean_title=title
					gsub(/\r/, "", clean_title)
					gsub(/^[ \t"]+|[ \t"]+$/, "", clean_title)

					if (toupper(clean_key) ~ toupper(code)) {
						print clean_key "|" clean_title
						exit
					}
				}
			' "$csv_file" 2>/dev/null
		)"

		if [[ -z "${csv_hit//[[:space:]]/}" || "$csv_hit" != *"|"* ]]; then
			echo -e "${YE} = = > [SKIP NO CSV TITLE]${NC} ${YELLOW}$ep_code${NC} ${GREEN}$file${NC}"
			((skipped+=1)) || :
			continue
		fi

		csv_key="${csv_hit%%|*}"
		ep_title="${csv_hit#*|}"

		if [[ -z "${ep_title//[[:space:]]/}" ]]; then
			echo -e "${YE} = = > [SKIP BLANK CSV TITLE]${NC} ${YELLOW}$ep_code${NC} ${GREEN}$file${NC}"
			((skipped+=1)) || :
			continue
		fi

		ext="${file##*.}"
		clean_title="$(detox_title "$ep_title")"
		clean_title="$(collection_detox_titlecase_words "$clean_title")"

		prefix="${csv_key%%$ep_code*}"
		prefix="$(strip_workflow_prefixes "$prefix")"
		prefix="$(detox_title "$prefix")"
		prefix="$(collection_detox_titlecase_words "$prefix")"
		prefix="${prefix%_}"
		prefix="${prefix%-}"
		prefix="${prefix%.}"

		if [[ -n "$prefix" ]]; then
			new_name="${prefix}_${ep_code}_${clean_title}.${ext}"
		else
			new_name="${ep_code}_${clean_title}.${ext}"
		fi

		if [[ "$file" == "$new_name" ]]; then
			echo -e "${CYAN} = = > [ALREADY CSV-CORRECT]${NC} ${GREEN}$file${NC}"
			continue
		fi

		rename_old+=("$file")
		rename_new+=("$new_name")
	done

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        CSV AUTHORITY RENAME PREVIEW            ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	if (( ${#rename_old[@]} == 0 )); then
		echo -e "${GR} = = > No Rename Changes Needed.${NC}"
		echo
		pause
		return 0
	fi

	local i
	for i in "${!rename_old[@]}"; do
		echo -e "${YELLOW}[$((i+1))]${NC} ${GREEN}${rename_old[$i]}${NC}"
		echo -e "${CYAN}    -->${NC} ${YELLOW}${rename_new[$i]}${NC}"
	done

	echo
	echo -e "${CYAN} = = > Proposed Renames:${NC} ${YELLOW}${#rename_old[@]}${NC}"
	echo

	if ! ask_yes_no " = = > Apply These CSV Authority Renames? (y/n or 1/2): "; then
		echo -e "${YE} = = > CSV Authority Rename Cancelled. No Files Changed.${NC}"
		echo
		pause
		return 0
	fi

	for i in "${!rename_old[@]}"; do
		echo -e "${GREEN} = = > [CSV AUTH RENAMED]${NC} ${YELLOW}${rename_old[$i]}${NC} ${CYAN}-->${NC} ${GREEN}${rename_new[$i]}${NC}"
		mv -- "${rename_old[$i]}" "${rename_new[$i]}"
		((changed+=1)) || :
	done

	echo
	echo -e "${GR} = = > CSV Authority Rename Complete.${NC}"
	echo -e "${CYAN} = = > Renamed:${NC} ${YELLOW}$changed${NC}"
	echo -e "${CYAN} = = > Skipped:${NC} ${YELLOW}$skipped${NC}"
	echo
	pause
	return 0
}

# ==============================================================================
# --- FUNCTION X: SUBTOX (UNIFIED SUBTITLE + RENAME ENGINE) ---
# ==============================================================================
#
# IMPORTANT WORKFLOW WARNING:
#
# SUBTOX works safest on ORIGINAL / OEM episode files or on files whose runtime
# structure still matches the subtitle timing source.
#
# NORMALIZATION / REKEY WARNING:
# - A normalized REKEY file is usually still the same PROGRAM CONTENT as the
#   original episode, so subtitles may still be usable IF timing was originally
#   correct and IF the subtitle matches that exact release/runtime.
# - HOWEVER, normalization creates parallel identities (OEM vs REKEY), which can
#   make it easier to accidentally subtitle the wrong copy.
#
# SMARTGAP / SMC WARNING:
# - After SMARTGAP, especially when using global PRE-trim, intro removal, and/or
#   global POST-trim, the timeline no longer matches the original broadcast/
#   disc/file runtime.
# - External subtitles made for the original full-length episode will usually
#   become offset, structurally wrong, or completely unusable on SMC output.
# - In other words: once the file has been "cut-n-gutted", old external .srt
#   files are no longer trustworthy unless they are specifically retimed for the
#   new cut.
#
# PRACTICAL RULE:
# - Pack external subtitles BEFORE destructive timeline edits whenever possible.
# - Do NOT assume original .srt files will survive SMARTGAP trimming intact.
# - Be especially cautious after triple-cut style work:
#     1) pre-trim
#     2) intro removal
#     3) post-trim
#
# CURRENT DESIGN INTENT:
# - SUBTOX is best treated as an EARLIER-STAGE tool unless the user knows the
#   subtitle timing already matches the exact target file being processed.
#

run_subtox() {

    # =========================
    # #MARKER: SUBTOX LOCAL SCOPE
    # =========================
    local choice
    local -a vids filtered subs
    local total file EP_CODE EP_TITLE EXT RAW_FOR_DETOX BASE_NAME CLEAN_TITLE NEW_NAME
    local vid base i SUB_NAME
    local -a cmd

    clear

    echo -e "${CYAN}=======================================================================${NC}"
    echo -e "${ORANGE}                 SUBTOX: UNIFIED ENGINE                                 ${NC}"
    echo -e "${CYAN}=======================================================================${NC}"
    echo -e "${YELLOW}WARNING:= = External Subtitle Work Is Safest On ORIGINAL/OEM Files. = = ${NC}"
    echo -e "${ORANGE}WARNING:= = Better To Get All That Done Now Before You Do = = ${NC}"
    echo -e "${YELLOW}WARNING:= = Any Cuts Or Other Mods Because After You  Do= = = = = = = = ${NC}"
    echo -e "${ORANGE}WARNING: SMARTGAP / SMC Cuts, Old External SUB Files May = = = ${NC}"
    echo -e "${YELLOW}WARNING: Be Shifted, Structurally Wrong, Or Completely Unusable.= = = = ${NC}"
    echo -e "${ORANGE}WARNING: This Is Especially True After PRE-TRIM+INTRO-CUT+POST-TRIM.= = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${ORANGE}1)= = = = = = > Rename & Detox Video File Names < = = = = = = = = = = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${ORANGE}2)= = = = = = > Bulk Pack External .srt Into MKVs < = = = = = = = = = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${ORANGE}3)= = = = = = > Bulk Extract Subtitles / Codec-Aware < = = = = = = = =${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${ORANGE}4)= = = = = = > BARFIX: Title + Playback Default Tools <  = = = = = = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"

    echo -ne "${YELLOW} = = > Select Mission [1/2/3/4] or [q] to cancel: ${NC}${GREEN}"
    read -r choice
    echo -e "${NC}"

    if is_exit_token "$choice"; then
        return 0
    fi

    shopt -s nullglob nocaseglob
    vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
    shopt -u nullglob nocaseglob

    [[ ${#vids[@]} -eq 0 ]] && {
        echo -e "${RE} = = > ERROR: No Video Targets Found In This Folder!${NC}"
        pause
        return 1
    }
    
    # ------------------------------------------------------------------------------
	# 1 RENAME & DETOX / RECOVERY RENAME MENU
	# ------------------------------------------------------------------------------
	if [[ "$choice" == "1" ]]; then
		run_subtox_rename_menu "${vids[@]}"
		return 0
	fi

# ------------------------------------------------------------------------------
# 2 BULK PACK EXTERNAL SRT INTO MKV (EXTSUB LOGIC)
# ------------------------------------------------------------------------------

    if [[ "$choice" == "2" ]]; then

        echo
        echo -e "${RED} = = > =====EXTERNAL SUBTITLE PACKING WARNING =====${NC}"
        echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
        echo -e "${YELLOW} = = > This Works Best On ORIGINAL/OEM Episode Files.${NC}"
        echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
        echo -e "${YELLOW} = = > If You Use REKEY Files, Confirm The .srt Timing Still Matches.${NC}"
        echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
        echo -e "${RED} = = > If You Use SMC / SMARTGAP-Cut Files, Old External .srt Timing${NC}"
        echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
        echo -e "${RED} = = > May Be Broken By Pre-Trim, Intro Removal, And Post-Trim Edits.${NC}"
        echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
        echo -e "${RED} = = > Do NOT Trust Original External Subtitles On Triple-Cut Outputs${NC}"
        echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
        echo -e "${RED} = = > Unless They Were Retimed For That Exact Final File.${NC}"
        echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
        echo
        if ! ask_yes_no " = = > Continue With External Subtitle Packing? (y/n): "; then
            echo -e "${YELLOW} = = > External Subtitle Packing Canceled.${NC}"
            pause
            return 0
        fi

        for vid in "${vids[@]}"; do
            EP_CODE="$(printf '%s\n' "$vid" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 | tr '[:lower:]' '[:upper:]' || true)"

            if [[ -z "${EP_CODE:-}" ]]; then
                echo -e "${YE} = = > No SxxExx Found For:${NC} ${YELLOW}$vid${NC}"
                continue
            fi

            echo
            echo -e "${CYAN} = = > Video:${NC} ${GREEN}$vid${NC}"
            echo -e "${CYAN} = = > Subtitle Key:${NC} ${YELLOW}$EP_CODE${NC}"

            subs=()

            while IFS= read -r -d '' s; do
                if printf '%s\n' "$s" | grep -qiE "$EP_CODE"; then
                    subs+=("$s")
                fi
            done < <(
                find . -type f \
                    \( -iname "*.srt" -o -iname "*.ass" -o -iname "*.ssa" -o -iname "*.vtt" \) \
                    -print0 2>/dev/null
            )

            if (( ${#subs[@]} == 0 )); then
                echo -e "${YE} = = > No Matching External Subs Found.${NC}"
                continue
            fi

            echo -e "${GR} = = > Matching Subs Found:${NC} ${YELLOW}${#subs[@]}${NC}"

            cmd=(ffmpeg -hide_banner -loglevel error -nostdin -y -i "$vid")

            for s in "${subs[@]}"; do
                echo -e "${CYAN}     +${NC} ${GREEN}$s${NC}"
                cmd+=(-i "$s")
            done

            cmd+=(-map 0:v -map 0:a)

            for (( i=0; i<${#subs[@]}; i++ )); do
                SUB_NAME="$(basename "${subs[$i]%.*}")"
                cmd+=(-map "$((i+1)):0" -metadata:s:s:"$i" "title=$SUB_NAME")
            done

            out="$(build_stage_output_name "SUBPACKED" "$vid")"
			out="${out%.*}.mkv"

            cmd+=(-c copy -disposition:s 0 "$out" -y)

            if "${cmd[@]}"; then
                echo -e "${GR} = = > SUBPACKED CREATED:${NC} ${YELLOW}$out${NC}"
                stage_archive_file "$vid" "SUBTOX"
            else
                echo -e "${RE} = = > SUBPACK FAILED:${NC} ${YELLOW}$vid${NC}"
                rm -f -- "$out"
            fi
        done

        pause
        return 0
    fi

# ------------------------------------------------------------------------------
# 3 BULK EXTRACT INTERNAL SUBS
# ------------------------------------------------------------------------------

	if [[ "$choice" == "3" ]]; then

		mkdir -p "subs_extracted"

		for vid in "${vids[@]}"; do
			echo -e "${CYAN} = = > Extracting From:${NC} ${GREEN}$vid${NC}"

			EP_CODE="$(printf '%s\n' "$vid" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 | tr '[:lower:]' '[:upper:]' || true)"

			if [[ -z "${EP_CODE:-}" ]]; then
				EP_CODE="$(basename "${vid%.*}")"
				EP_CODE="$(strip_workflow_prefixes "$EP_CODE")"
				EP_CODE="${EP_CODE// /_}"
			fi

			base="${vid%.*}"
			outdir="subs_extracted/$(basename "$base")"
			mkdir -p "$outdir"

			sub_count="$(ffprobe -v error -select_streams s \
				-show_entries stream=index \
				-of csv=p=0 "$vid" 2>/dev/null | wc -l)"

			if (( sub_count == 0 )); then
				echo -e "${YE} = = > No Subtitle Streams Found:${NC} ${YELLOW}$vid${NC}"
				continue
			fi

			echo -e "${CYAN} = = > Subtitle Streams Found:${NC} ${GREEN}$sub_count${NC}"

			for ((sub_i=0; sub_i<sub_count; sub_i++)); do
				out_srt="$outdir/${EP_CODE}_track$(printf '%02d' "$sub_i").srt"

				if ffmpeg -hide_banner -loglevel error -nostdin -y \
					-i "$vid" \
					-map "0:s:$sub_i" \
					-c:s srt \
					"$out_srt"; then
					echo -e "${GR} = = > Extracted:${NC} ${YELLOW}$out_srt${NC}"
				else
					echo -e "${RE} = = > Extract Failed:${NC} ${YELLOW}$vid track $sub_i${NC}"
					rm -f -- "$out_srt"
				fi
			done

			echo -e "${GR} = = > Extracted Subs To:${NC} ${YELLOW}$outdir${NC}"
		done

		pause
		return 0
	fi

# ------------------------------------------------------------------------------
# 4 BARFIX: TITLE BAR METADATA ONLY
# ------------------------------------------------------------------------------

    if [[ "$choice" == "4" ]]; then
        run_barfix
        return 0
    fi

    echo -e "${REB} = = > Invalid Selection.${NC}"
    pause
    return 1
}
# ---End Of FUNCTION X: SUBTOX (UNIFIED SUBTITLE + RENAME ENGINE) ---

# =========================
# #MARKER: SUBTOX STANDARD RENAME WRAPPER
# =========================
# PURPOSE:
# - Hold The Existing Mission 1 Rename / Detox Logic
# - This Wrapper Lets SUBTOX Mission 1 Split Cleanly Into:
#     1) Standard Rename / Detox
#     2) Recovery Rename From episodes.csv + Front Number Tags Or Preen
#
# =========================
run_subtox_standard_rename() {
	local -a vids=("$@")
	local -a filtered=()
	local -a rename_old=()
	local -a rename_new=()
	local total i
	local f file
	local EP_CODE EP_TITLE EXT RAW_FOR_DETOX BASE_NAME CLEAN_TITLE NEW_NAME
	local prefix_part suffix_part
	local title_prefix title_suffix
	local csv_file="episodes.csv"
	local changed=0 skipped=0 already=0
	local TITLECASE_RAW EP_TOKEN SEASON_NUM EPISODE_NUM

	# ------------------------------------------------------------------------------
	# 1 RENAME & DETOX (FLEXIBLE SxxExx + CSV TITLE LOGIC)
	# ------------------------------------------------------------------------------

	for f in "${vids[@]}"; do
		[[ "$f" =~ ^(SMC_|SUBPACKED_) ]] || filtered+=("$f")
	done
	vids=("${filtered[@]}")

	total=${#vids[@]}
	[[ $total -eq 0 ]] && {
		echo -e "${RE}>->->->->->No Targets Found<-<-<-<-<-<${NC}"
		pause
		return 0
	}

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > SUBTOX STANDARD RENAME SETUP${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Existing SxxExx Pattern Will Be Detected Anywhere In Filename.${NC}"
	echo -e "${YELLOW} = = > Optional Text Can Be Kept/Added Before/After SxxExx.${NC}"
	echo -e "${YELLOW} = = > Preview Will Be Shown Before Any Rename Happens.${NC}"
	echo

	prompt_read " = = > Text To Put BEFORE SxxExx (blank = none): " title_prefix
	prompt_read " = = > Text To Put AFTER SxxExx Before Title (blank = underscore): " title_suffix

	[[ -z "$title_suffix" ]] && title_suffix="_"

	if [[ -f "$csv_file" ]]; then
		echo -e "${GREEN} = = > CSV Found:${NC} ${YELLOW}$csv_file${NC}"
	else
		echo -e "${YELLOW} = = > No episodes.csv found. Will Use Filename Text After SxxExx.${NC}"
	fi

	for (( i=0; i<total; i++ )); do
		file="${vids[$i]}"
		echo -e "\n${CYAN}[$((i+1)) / $total] TARGET:${NC} ${GREEN}$file${NC}"

		EP_CODE=""
		EP_TOKEN=""

		# Prefer proper SxxExx if already present.
		EP_TOKEN="$(printf '%s\n' "$file" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 || true)"

		if [[ -n "$EP_TOKEN" ]]; then
			EP_CODE="$(printf '%s\n' "$EP_TOKEN" | tr '[:lower:]' '[:upper:]')"
		else
			# Fallback detection for dirty TV patterns.
			if [[ "$file" =~ ([0-9]{1,2})[xX\.-]([0-9]{2}) ]]; then
				SEASON_NUM="${BASH_REMATCH[1]}"
				EPISODE_NUM="${BASH_REMATCH[2]}"

				printf -v EP_CODE 'S%02dE%02d' "$((10#$SEASON_NUM))" "$((10#$EPISODE_NUM))"
				EP_TOKEN="${BASH_REMATCH[0]}"
			fi
		fi

		if [[ -z "${EP_CODE:-}" ]]; then
			echo -e "${YELLOW} = = > [SKIP NO EPISODE TAG FOUND]${NC} ${GREEN}$file${NC}"
			((skipped+=1)) || :
			continue
		fi

		EP_TITLE=""

		if [[ -f "$csv_file" ]]; then
			EP_TITLE="$(
				awk -F',' -v code="$EP_CODE" '
					BEGIN { IGNORECASE=1 }
					NR == 1 {
						for (i=1; i<=NF; i++) {
							h=tolower($i)
							gsub(/^[ \t"]+|[ \t"]+$/, "", h)
							if (h ~ /^(episode|ep|code|sxxexx|id)$/) code_col=i
							if (h ~ /^(title|name|episode_title)$/) title_col=i
						}
					}
					{
						row_code=""
						row_title=""

						if (code_col) row_code=$code_col
						else row_code=$1

						gsub(/^[ \t"]+|[ \t"]+$/, "", row_code)

						if (toupper(row_code) == toupper(code)) {
							if (title_col) {
								row_title=$title_col
							} else {
								row_title=$0
								sub(/^[^,]*,/, "", row_title)
							}

							gsub(/\r/, "", row_title)
							gsub(/^[ \t"]+|[ \t"]+$/, "", row_title)
							print row_title
							exit
						}
					}
				' "$csv_file" 2>/dev/null
			)"
		fi

		EXT="${file##*.}"

		if [[ -n "$EP_TITLE" ]]; then
			RAW_FOR_DETOX="$EP_TITLE"
		else
			RAW_FOR_DETOX="${file%.*}"
			RAW_FOR_DETOX="${RAW_FOR_DETOX#*${EP_TOKEN:-$EP_CODE}}"
			RAW_FOR_DETOX="${RAW_FOR_DETOX#_}"
			RAW_FOR_DETOX="${RAW_FOR_DETOX#-}"
			RAW_FOR_DETOX="${RAW_FOR_DETOX#.}"
			RAW_FOR_DETOX="${RAW_FOR_DETOX# }"
		fi

		TITLECASE_RAW="$(
			printf '%s\n' "$RAW_FOR_DETOX" \
				| sed 's/_/ /g; s/[.-]/ /g' \
				| titlecase_words
		)"

		CLEAN_TITLE="$(detox_title "$TITLECASE_RAW")"

		prefix_part="$(detox_title "$title_prefix")"
		suffix_part="$title_suffix"

		if [[ -n "$prefix_part" ]]; then
			BASE_NAME="${prefix_part}_${EP_CODE}"
		else
			BASE_NAME="$EP_CODE"
		fi

		NEW_NAME="${BASE_NAME}${suffix_part}${CLEAN_TITLE}.${EXT}"

		if [[ "$file" != "$NEW_NAME" ]]; then
			rename_old+=("$file")
			rename_new+=("$NEW_NAME")
		else
			echo -e "${CYAN} = = > [ALREADY CORRECT]${NC} ${GREEN}$file${NC}"
			((already+=1)) || :
		fi
	done

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}          SUBTOX STANDARD RENAME PREVIEW                   ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo

	if (( ${#rename_old[@]} == 0 )); then
		echo -e "${GR} = = > No Rename Changes Needed.${NC}"
		echo -e "${CYAN} = = > Already Correct:${NC} ${YELLOW}$already${NC}"
		echo -e "${CYAN} = = > Skipped:${NC} ${YELLOW}$skipped${NC}"
		echo
		pause
		return 0
	fi

	for i in "${!rename_old[@]}"; do
		echo -e "${YELLOW}[$((i+1))]${NC} ${GREEN}${rename_old[$i]}${NC}"
		echo -e "${CYAN}    -->${NC} ${YELLOW}${rename_new[$i]}${NC}"
	done

	echo
	echo -e "${CYAN} = = > Proposed Renames:${NC} ${YELLOW}${#rename_old[@]}${NC}"
	echo -e "${CYAN} = = > Already Correct:${NC} ${YELLOW}$already${NC}"
	echo -e "${CYAN} = = > Skipped:${NC} ${YELLOW}$skipped${NC}"
	echo

	if ! ask_yes_no " = = > Apply These SUBTOX Renames? (y/n or 1/2): "; then
		echo -e "${YE} = = > SUBTOX Standard Rename Cancelled. No Files Changed.${NC}"
		echo
		pause
		return 0
	fi

	for i in "${!rename_old[@]}"; do
		if [[ -e "${rename_new[$i]}" ]]; then
			echo -e "${REB} = = > [SKIP EXISTS]${NC} ${YELLOW}${rename_new[$i]}${NC}"
			continue
		fi

		echo -e "${GREEN} = = > [RENAMING]${NC} ${YELLOW}${rename_old[$i]}${NC} ${CYAN}-->${NC} ${GREEN}${rename_new[$i]}${NC}"
		mv -- "${rename_old[$i]}" "${rename_new[$i]}"
		((changed+=1)) || :
	done

	echo
	echo -e "${GR} = = > SUBTOX Standard Rename Complete.${NC}"
	echo -e "${CYAN} = = > Renamed:${NC} ${YELLOW}$changed${NC}"
	echo -e "${CYAN} = = > Skipped:${NC} ${YELLOW}$skipped${NC}"
	echo -e "${CYAN} = = > Already Correct:${NC} ${YELLOW}$already${NC}"
	echo
	pause
	return 0
}

run_subtox_direct_detox() {

	local -a vids=("$@")
	local choice file new_name stem ext
	local -a plan=()
	local -a selected_plan=()

	# --------------------------------------------------------
	# BUILD DETOX PLAN FIRST
	# --------------------------------------------------------
	for file in "${vids[@]}"; do

		# Skip factory outputs
		[[ "$file" =~ ^(SMC_|SUBPACKED_) ]] && continue

		[[ -f "$file" ]] || continue

		ext="${file##*.}"
		stem="${file%.*}"

		new_name="$(detox_title "$stem")"
		new_name="$(collection_detox_titlecase_words "$new_name").${ext}"

		[[ "$file" == "$new_name" ]] && continue

		plan+=("${file}|${new_name}")
	done

	if (( ${#plan[@]} == 0 )); then
		echo -e "${GREEN} = = > Nothing To Change.${NC}"
		pause
		return 0
	fi

	# --------------------------------------------------------
	# PREVIEW IS THE MENU
	# --------------------------------------------------------
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}           DETOX PREVIEW                        ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	for i in "${!plan[@]}"; do

		IFS='|' read -r file new_name <<< "${plan[$i]}"

		echo -e "  ${CYAN}$((i+1)))${NC} ${GREEN}$file${NC}"
		echo -e "      ${YELLOW}-->${NC} ${GREEN}$new_name${NC}"
		echo
	done

	echo -e "  ${YELLOW}1) Apply ONE Selected Change${NC}"
	echo -e "  ${YELLOW}2) Apply ALL Changes${NC}"
	echo -e "  ${YELLOW}0.) Return${NC}"
	echo

	prompt_menu_choice " = = > Select Option [1-2 | 0.=return]: " choice

	if is_exit_token "$choice"; then
		return 0
	fi

	case "$choice" in
		1)
			echo
			prompt_menu_choice " = = > Enter File Number To Apply [1-${#plan[@]} | 0.=return]: " choice

			if is_exit_token "$choice"; then
				return 0
			fi

			if ! [[ "$choice" =~ ^[0-9]+$ ]] || \
			   (( choice < 1 || choice > ${#plan[@]} )); then
				echo -e "${REB} = = > Invalid File Selection.${NC}"
				pause
				return 1
			fi

			selected_plan=("${plan[$((choice-1))]}")
			;;

		2)
			selected_plan=("${plan[@]}")
			;;

		*)
			echo -e "${REB} = = > Invalid Selection.${NC}"
			pause
			return 1
			;;
	esac

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}         SELECTED DETOX CHANGES                 ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	for item in "${selected_plan[@]}"; do
		IFS='|' read -r file new_name <<< "$item"
		echo -e "  ${YELLOW}${file}${NC} ${CYAN}-->${NC} ${GREEN}${new_name}${NC}"
	done

	echo

	if ! ask_yes_no " = = > Apply Detox Renames? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Detox Cancelled.${NC}"
		pause
		return 0
	fi

	for item in "${selected_plan[@]}"; do

		IFS='|' read -r file new_name <<< "$item"

		if [[ -e "$new_name" ]]; then
			echo -e "${REB} = = > [SKIP EXISTS]${NC} ${YELLOW}$new_name${NC}"
			continue
		fi

		echo -e "${GREEN} = = > [RENAMING]${NC} ${YELLOW}$file${NC} ${CYAN}-->${NC} ${GREEN}$new_name${NC}"
		mv -- "$file" "$new_name"
	done

	echo
	echo -e "${GR} = = > Direct Detox Complete.${NC}"
	pause
	return 0
}

# =========================
# #MARKER: SUBTOX RECOVERY RENAME WRAPPER
# =========================
# PURPOSE:
# - Explain Recovery Mode Clearly
# - Require Front-Number-Tagged Files
# - Hand Off To The Recovery Rename Pipeline
# =========================
run_subtox_recovery_rename() {
	local -a vids=("$@")
	local recovery_choice

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}              RECOVERY RENAME MENU              ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW} = = > Choose Recovery Method:${NC}"
		echo
		echo -e "${YELLOW}     1) Recover By Matching Surviving Filename Tail To episodes.csv${NC}"
		echo -e "${YELLOW}     2) Recover By Front Number Tags${NC}"
		echo -e "${YELLOW}     3) CSV Authority Rename By SxxExx${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo
		echo -e "${YELLOW}"
		read -r -p " = = > Select option [1-3 | 0.=return]: ${NC}${GREEN}" recovery_choice
		echo -e "${NC}"

		recovery_choice="${recovery_choice//[[:space:]]/}"

		if is_exit_token "$recovery_choice"; then
			return 0
		fi

		case "$recovery_choice" in
			1)
				run_subtox_recovery_tail_match "${vids[@]}"
				;;
			2)
				run_subtox_recovery_number_tag "${vids[@]}"
				;;
			3)
				run_subtox_csv_authority_rename "${vids[@]}"
				;;
			*)
				echo -e "${REB} = = > Invalid Selection.${NC}"
				pause
				;;
		esac
	done
}

run_subtox_recovery_tail_match() {
	local -a vids=("$@")
	local -a plan_rows=()
	local csv_file

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}         RECOVERY BY SURVIVING TAIL MATCH       ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > This Path Uses A Selected Episode CSV File.${NC}"
	echo -e "${CYAN} = = > Factory Will Try To Match The Surviving Filename Tail${NC}"
	echo -e "${CYAN}      Against Detoxed Titles In The Selected CSV.${NC}"
	echo
	echo -e "${YELLOW} = = > This Is STRICT Recovery.${NC}"
	echo -e "${YELLOW} = = > Any Missing Or Ambiguous Match Will Abort The Plan.${NC}"
	echo

	csv_file="$(pick_episode_csv_file)" || {
		echo -e "${YE} = = > Tail-Match Recovery Cancelled: No CSV Selected.${NC}"
		pause
		return 0
	}

	echo
	echo -e "${CYAN} = = > Selected CSV:${NC} ${GREEN}$csv_file${NC}"
	echo

	if ! ask_yes_no " = = > Build Tail-Match Recovery Plan Now? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Tail-Match Recovery Cancelled.${NC}"
		echo
		return 0
	fi

	mapfile -t plan_rows < <(build_recovery_tail_match_plan "$csv_file" "${vids[@]}")
	if (( ${#plan_rows[@]} == 0 )); then
		echo -e "${REB} = = > Tail-Match Recovery Plan Could Not Be Built.${NC}"
		echo
		pause
		return 0
	fi

	if preview_and_apply_plan_rows "${plan_rows[@]}"; then
		echo -e "${GREEN} = = > Tail-Match Recovery Complete.${NC}"
	else
		echo -e "${REB} = = > Tail-Match Recovery Ended With An Error.${NC}"
	fi

	echo
	pause
	return 0
}

run_subtox_recovery_number_tag() {
	local -a vids=("$@")
	local -a plan_rows=()
	local csv_file

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          RECOVERY RENAME FROM CSV ORDER        ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > This Mode Is For Broken Filenames That Lost SxxExx.${NC}"
	echo -e "${CYAN} = = > Files Must Start With A Numeric Tag At The VERY Front.${NC}"
	echo -e "${CYAN} = = > Accepted Examples:${NC}"
	echo -e "${GREEN}      001_File.mkv${NC}"
	echo -e "${GREEN}      002-Whatever.mp4${NC}"
	echo
	echo -e "${CYAN} = = > Recovery Pairing Rule:${NC}"
	echo -e "${CYAN}      File Tag Order 001 / 002 / 003 ...${NC}"
	echo -e "${CYAN}      matches selected CSV row order 1 / 2 / 3 ...${NC}"
	echo
	echo -e "${YELLOW} = = > CSV Row Keys May Contain Extra Prefixes.${NC}"
	echo -e "${YELLOW} = = > Factory Will Extract SxxExx Anywhere In The CSV Key Column.${NC}"
	echo
	echo -e "${YELLOW} = = > Factory Will Preview Every Rename Before Applying Anything.${NC}"
	echo

	csv_file="$(pick_episode_csv_file)" || {
		echo -e "${YE} = = > Recovery Rename Cancelled: No CSV Selected.${NC}"
		pause
		return 0
	}

	echo
	echo -e "${CYAN} = = > Selected CSV:${NC} ${GREEN}$csv_file${NC}"
	echo

	if ! ask_yes_no " = = > Continue Into Recovery Rename Mode? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Recovery Rename Cancelled.${NC}"
		echo
		return 0
	fi

	mapfile -t plan_rows < <(build_recovery_rename_plan "$csv_file")

	if (( ${#plan_rows[@]} == 0 )); then
		echo -e "${REB} = = > Recovery Rename Plan Could Not Be Built.${NC}"
		echo
		pause
		return 0
	fi

	if preview_and_apply_plan_rows "${plan_rows[@]}"; then
		echo -e "${GREEN} = = > Recovery Rename Complete.${NC}"
	else
		echo -e "${REB} = = > Recovery Rename Ended With An Error.${NC}"
	fi

	echo
	pause
	return 0
}

# =========================
# #MARKER: SUBTOX RENAME MENU
# =========================
# PURPOSE:
# - Split Rename Mission Into Standard And Recovery Paths
# - Keep Old Behavior Available
# - Make Recovery Explicit Instead Of Hidden
# =========================
# =========================
# #MARKER: SUBTOX RENAME MENU
# =========================
# PURPOSE:
# - Split Rename Mission Into Standard And Recovery Paths
# - Keep Detox Operations Together
# - Give CSV / Naming Authority Work Its Own Honest Home
#
# IMPORTANT:
# - episodes.csv work belongs here now, not under Intro Detection
# - Reverse CSV rebuild gets a real menu slot even if still stubbed
# =========================
run_subtox_rename_menu() {
	local -a vids=("$@")
	local rename_choice

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}              SUBTOX RENAME MENU                ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Rename Using Detected Pattern In Filenames${NC}"
		echo -e "${YELLOW}     2) Recovery / Rebuild File Names${NC}"
		echo -e "${YELLOW}     3) Detox Existing File Names In This Folder${NC}"
		echo -e "${YELLOW}     4) CSV / Naming Authority Tools${NC}"
		echo -e "${YELLOW}     5) Repair intro_map.csv / outro_map.csv Filenames Using episodes.csv${NC}"
		echo -e "${YELLOW}     6) Full Collection Folder Recursive Filename Detox Scan${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo
		echo -ne "${YELLOW} = = > Select Option [1-6 | 0.=return]: ${NC}${GREEN}"
		read -r rename_choice
		rename_choice="${rename_choice//[[:space:]]/}"
		echo -e "${NC}"

		if is_exit_token "$rename_choice"; then
			return 0
		fi

		case "$rename_choice" in
			1)
				run_subtox_standard_rename "${vids[@]}"
				;;
			2)
				run_subtox_recovery_rename "${vids[@]}"
				;;
			3)
				run_subtox_direct_detox "${vids[@]}"
				;;
			4)
				run_subtox_csv_menu
				;;
			5)
				repair_intro_map
				;;
			6) 
				run_collection_detox_scan_only
				;;
			*)
				echo
				echo -e "${REB} = = > Invalid Selection.${NC}"
				pause
				;;
		esac
	done
}

# =========================
# #MARKER: TITLE / PLAYBACK RENAME WRAPPER UPGRADE
# =========================
# PURPOSE:
# - Replace The Old "Open SUBTOX" Banner For Rename
# - Route Directly Into The New Rename Split Menu
# - Tell The Truth About CSV / Naming Authority Living Here Too
# =========================
run_subtox_rename() {
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             RENAME / DETOX FILE TOOLS          ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > Standard Rename, Recovery Rename, Direct Detox,${NC}"
	echo -e "${CYAN} = = > And CSV / Naming Authority Tools Live Here Now.${NC}"
	echo

	if ask_yes_no " = = > Open Rename Menu Now? (y/n or 1/2): "; then
		run_subtox_rename_menu
	fi
}

# =========================
# #MARKER: SUBTOX CSV / NAMING AUTHORITY MENU
# =========================
# PURPOSE:
# - Keep episodes.csv authority tools near Rename / Detox workflows
# - Separate naming authority work from Intro Detection work
# - Provide one place for both:
#     1) manual append builder
#     2) future reverse rebuild from known-good filenames
#
# IMPORTANT:
# - Manual append builder exists now
# - Reverse rebuild writer is intentionally stubbed until implemented
# =========================
run_subtox_csv_menu() {
	local csv_choice

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}          CSV / NAMING AUTHORITY TOOLS          ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Prep / Normalize episodes.csv For Factory Authority${NC}"
		echo -e "${YELLOW}     2) Build / Append episodes.csv Manually${NC}"
		echo -e "${YELLOW}     3) Rebuild episodes.csv From Known Good Filenames${NC}"
		echo -e "${YELLOW}     4) CSV Authority Rename By SxxExx${NC}"
		echo -e "${YELLOW}     5) Upgrade Existing *episodes*.csv To Headered Auth Copy${NC}"
		echo -e "${YELLOW}     6) Repair intro_map.csv / outro_map.csv Filenames Using episodes.csv${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo
		echo -e "${YELLOW}"
		read -r -p " = = > Select option [1-6 | 0.=return]: ${NC}${GREEN}" csv_choice
		echo -e "${NC}"

		csv_choice="${csv_choice//[[:space:]]/}"

		if is_exit_token "$csv_choice"; then
			return 0
		fi

		case "$csv_choice" in
			1)
				csv_auth_prep
				;;
			2)
				run_build_episodes
				;;
			3)
				run_build_episodes_from_good_filenames
				;;
			4)
				run_subtox_csv_authority_rename "${vids[@]}"
				;;
			5)
				run_episodes_csv_auth_upgrade
				;;
			6)
				repair_intro_map
				;;
			*)
				echo
				echo -e "${REB} = = > Invalid Selection.${NC}"
				pause
				;;
		esac
	done
}


# =========================
# #MARKER: REBUILD EPISODES.CSV FROM KNOWN GOOD FILENAMES
# =========================
# PURPOSE:
# - Future reverse builder:
#   scan already-correct filenames in current folder
#   extract SxxExx + title portion
#   write / rebuild episodes.csv authority rows
#
# CURRENT STATUS:
# - Menu plumbing exists now
# - Writer / parser logic not implemented yet
#
# WHY THIS STUB EXISTS:
# - So the menu structure reflects the intended workflow honestly
# - So future-me has a clear landing zone for the real builder
# =========================
# =========================
# #MARKER: REBUILD EPISODES.CSV FROM KNOWN GOOD FILENAMES
# =========================
# PURPOSE:
# - Scan Current Folder For Known-Good Filenames
# - Extract:
#     SxxExx
#     Show Prefix
#     Detox Title
#     Raw Title (Spaces Version)
#     Full Filename (No Extension)
# - Write Full-Authority episodes.csv
#
# OUTPUT FORMAT:
# episode_code,show_prefix,raw_title,detox_title,full_filename_detox
#
# IMPORTANT:
# - DOES NOT modify files
# - ONLY builds CSV authority from already-correct filenames
# - Uses The Full Factory Extension Set, Including LRV
# =========================
run_build_episodes_from_good_filenames() {
	local outfile="episodes.csv"
	local tmpfile="episodes.tmp"
	local count=0

	local f stem
	local EP_CODE prefix rest detox_title raw_title full_name

	# --------------------------------------------------
	# Supported Video Extensions (Factory Standard)
	# --------------------------------------------------
	local -a exts=(lrv mkv mp4 avi mov mpg mpeg ts m4v ogv flv 3gp divx webm xvid webm wmv)

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}   REBUILD EPISODES.CSV FROM GOOD FILENAMES     ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	if ! ask_yes_no " = = > Scan Current Folder And Rebuild CSV? (y/n or 1/2): "; then
		return 0
	fi

	echo
	echo -e "${CYAN} = = > Scanning Files...${NC}"

	printf 'episode,title,series,full_name\n' > "$tmpfile"

	# ========================================================
	# CASE-INSENSITIVE EXTENSION MATCH
	# ========================================================
	# WHY:
	# - Factory sees mixed real-world extensions
	# - LRV especially may appear uppercase
	# - nocaseglob lets one list cover both .LRV and .lrv
	# ========================================================
	shopt -s nullglob nocaseglob

	for ext in "${exts[@]}"; do
		for f in *."$ext"; do
			[[ -f "$f" ]] || continue

			stem="${f%.*}"

			# --------------------------------------------------
			# Extract SxxExx
			# --------------------------------------------------
			EP_CODE="$(echo "$stem" | grep -oiP 'S\d{2}E\d{2}' | tr '[:lower:]' '[:upper:]' || true)"

			if [[ -z "$EP_CODE" ]]; then
				continue
			fi

			# --------------------------------------------------
			# Split Around Episode Code
			# --------------------------------------------------
			prefix="${stem%%${EP_CODE}*}"
			prefix="${prefix%_}"

			rest="${stem#*${EP_CODE}_}"

			# --------------------------------------------------
			# Defensive Skip:
			# If there is no title segment after SxxExx, do not
			# write a broken authority row.
			# --------------------------------------------------
			[[ -n "$rest" ]] || continue

			# --------------------------------------------------
			# Title Parts
			# --------------------------------------------------
			detox_title="$rest"
			raw_title="${detox_title//_/ }"

			full_name="$stem"

			# --------------------------------------------------
			# Write Row
			# --------------------------------------------------
			printf '%s,%s,%s,%s\n' \
				"$EP_CODE" \
				"$detox_title" \
				"$prefix" \
				"$full_name" >> "$tmpfile"

			((count+=1))
		done
	done

	shopt -u nullglob nocaseglob

	if [[ $count -eq 0 ]]; then
		echo
		echo -e "${REB} = = > No Valid SxxExx Files Found.${NC}"
		rm -f -- "$tmpfile"
		pause
		return 0
	fi

	# --------------------------------------------------
	# Sort And Deduplicate
	# --------------------------------------------------
	sort -u "$tmpfile" > "$outfile"
	rm -f -- "$tmpfile"

	echo
	echo -e "${GR} = = > CSV Rebuild Complete.${NC}"
	echo -e "${CYAN} = = > Rows Written: ${NC}$count"
	echo -e "${CYAN} = = > Output File: ${NC}$outfile"
	echo

	pause
	return 0
}


# ==============================================================================
# --- FUNCTION: BUILD_EPISODES_CSV (INTERACTIVE TITLE BUILDER) ---
# ==============================================================================
run_build_episodes() {

    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}      BUILD EPISODES.CSV (AUTO SxxEyy MODE)     ${NC}"
    echo -e "${CYAN}================================================${NC}"

    local FILE="episodes.csv"

    # ------------------------------------------------------------------
    # DETOX FUNCTION SUB-SYSTEM CALL used to be here we moved it higher up
    # ------------------------------------------------------------------


    # ------------------------------------------------------------------
    # SEASON INPUT
    # ------------------------------------------------------------------
    echo -ne "${YELLOW} = = > Enter Season Number (e.g. 1): ${NC}${GREEN}"
    read -r SEASON
    echo -e "${NC}"

    [[ -z "$SEASON" ]] && {
        echo -e "${YE} = = > Canceled.${NC}"
        return 1
    }

    printf -v SEASON_PAD "%02d" "$SEASON"

    # ------------------------------------------------------------------
    # START EPISODE NUMBER
    # ------------------------------------------------------------------
    echo -ne "${YELLOW} = = > Starting Episode Number (default 1): ${NC}${GREEN}"
    read -r EP_NUM
    echo -e "${NC}"

    EP_NUM=${EP_NUM:-1}

    printf -v EP_PAD "%02d" "$EP_NUM"

    echo
    echo -e "${YELLOW} = = > Enter Episode Titles One Per Line.${NC}"
    echo -e "${YELLOW} = = > Press ENTER On Empty Line To Finish.${NC}"
    echo

    while true; do


        echo -e "${YELLOW} Title For S${SEASON_PAD}E${EP_PAD}: ${NC}"
        read -r TITLE_RAW

        [[ -z "$TITLE_RAW" ]] && break

        TITLE_CLEAN=$(detox_title "$TITLE_RAW")

        EP_CODE="S${SEASON_PAD}E${EP_PAD}"

        echo "${EP_CODE},${TITLE_CLEAN}" >> "$FILE"

        echo -e "${GREEN} = = > Added: ${EP_CODE},${TITLE_CLEAN}${NC}"

        EP_NUM=$((EP_NUM + 1))
        printf -v EP_PAD "%02d" "$EP_NUM"

    done

    echo
    echo -e "${CYAN}================================================${NC}"
    echo -e "${GREEN} = = >   episodes.csv Updated Successfully.    ${NC}"
    echo -e "${CYAN}================================================${NC}"

    pause
    return 0
}
# End Of BUILD_EPISODES_CSV (INTERACTIVE TITLE BUILDER) ---
# -------------------------------------------------------------------------------------------------------


archival_percent_change() {
	local orig_size="${1:-0}"
	local new_size="${2:-0}"

	awk -v o="$orig_size" -v n="$new_size" 'BEGIN {
		if (o <= 0) print 0;
		else printf "%.0f", ((n - o) / o) * 100
	}'
}


# ============================================================
# #MARKER: ARRAY METADATA POLICY DEFAULTS
# ============================================================
# PURPOSE:
# - Save source metadata before archival processing.
# - Prevent archival outputs from being the only place metadata ever lived.
# - Keep this lightweight; no full Archie ledger port here.
# ============================================================
ARCHIVE_META_DIR="${ARCHIVE_META_DIR:-ARCHIVE_META}"
ARRAY_METADATA_LABEL="SIDECAR_STRIP"
ARRAY_METADATA_ARGS=(-map_metadata -1 -map_chapters -1)

archival_configure_audio_policy() {

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}               ARRAY AUDIO POLICY               ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Copy All Audio Streams (Recommended)${NC}"
	echo -e "${YELLOW}     2) AAC 192k${NC}"
	echo -e "${YELLOW}     3) AAC 128k${NC}"
	echo -e "${YELLOW}     4) AAC 96k${NC}"
	echo -e "${YELLOW}     5) Strip Audio${NC}"
	echo

	echo -ne "${YELLOW} = = > Select Audio Policy [1-5]: ${NC}${GREEN}"
	read -r choice
	echo -e "${NC}"

	case "${choice:-1}" in
		1)
			ARRAY_AUDIO_LABEL="COPY"
			ARRAY_AUDIO_ARGS=(-c:a copy)
			;;
		2)
			ARRAY_AUDIO_LABEL="AAC192"
			ARRAY_AUDIO_ARGS=(-c:a aac -b:a 192k)
			;;
		3)
			ARRAY_AUDIO_LABEL="AAC128"
			ARRAY_AUDIO_ARGS=(-c:a aac -b:a 128k)
			;;
		4)
			ARRAY_AUDIO_LABEL="AAC96"
			ARRAY_AUDIO_ARGS=(-c:a aac -b:a 96k)
			;;
		5)
			ARRAY_AUDIO_LABEL="NONE"
			ARRAY_AUDIO_ARGS=(-an)
			;;
		*)
			echo -e "${YE} = = > Invalid Choice. Using Audio Copy.${NC}"
			ARRAY_AUDIO_LABEL="COPY"
			ARRAY_AUDIO_ARGS=(-c:a copy)
			;;
	esac

	echo
	echo -e "${GR} = = > Audio Policy:${NC} ${YELLOW}$ARRAY_AUDIO_LABEL${NC}"
	echo
}

archival_safe_stem() {
	local name="$1"

	name="${name##*/}"
	name="${name%.*}"
	name="${name// /_}"
	name="${name//[^A-Za-z0-9._-]/_}"

	printf '%s\n' "$name"
}

archival_ensure_meta_dir() {
	mkdir -p -- "$ARCHIVE_META_DIR"
}

archival_capture_metadata_sidecar() {
	local src="$1"
	local stem meta_json meta_txt sha_file

	archival_ensure_meta_dir
	stem="$(archival_safe_stem "$src")"

	meta_json="$ARCHIVE_META_DIR/${stem}.ffprobe.json"
	meta_txt="$ARCHIVE_META_DIR/${stem}.stat.txt"
	sha_file="$ARCHIVE_META_DIR/${stem}.sha256.txt"

	if have_cmd ffprobe; then
		ffprobe -v quiet -print_format json -show_format -show_streams "$src" > "$meta_json" 2>/dev/null || true
	fi

	{
		echo "SOURCE_FILE=$src"
		echo "CAPTURED_UTC=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
		stat --printf='SIZE=%s\nMTIME_EPOCH=%Y\nATIME_EPOCH=%X\nCTIME_EPOCH=%Z\nMODE=%a\nUID=%u\nGID=%g\n' -- "$src" 2>/dev/null || true
	} > "$meta_txt"

	if have_cmd sha256sum; then
		sha256sum -- "$src" > "$sha_file" 2>/dev/null || true
	fi

	printf '%s\n' "$meta_json"
}

archival_configure_metadata_policy() {
	local choice

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              ARRAY METADATA POLICY             ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Sidecar Strip   Save metadata, strip output metadata${NC}"
	echo -e "${YELLOW}     2) Restore Common  Save metadata, keep common tags${NC}"
	echo -e "${YELLOW}     3) Minimal Skip    No metadata sidecar / no metadata args${NC}"
	echo

	echo -ne "${YELLOW} = = > Select Metadata Policy [1-3]: ${NC}${GREEN}"
	read -r choice
	echo -e "${NC}"

	case "${choice:-1}" in
		1)
			ARRAY_METADATA_LABEL="SIDECAR_STRIP"
			ARRAY_METADATA_ARGS=(-map_metadata -1 -map_chapters -1)
			;;
		2)
			ARRAY_METADATA_LABEL="RESTORE_COMMON"
			ARRAY_METADATA_ARGS=(-map_metadata 0 -map_chapters -1)
			;;
		3)
			ARRAY_METADATA_LABEL="MINIMAL_SKIP"
			ARRAY_METADATA_ARGS=()
			;;
		*)
			echo -e "${YE} = = > Invalid Choice. Using Sidecar Strip.${NC}"
			ARRAY_METADATA_LABEL="SIDECAR_STRIP"
			ARRAY_METADATA_ARGS=(-map_metadata -1 -map_chapters -1)
			;;
	esac

	echo
	echo -e "${GR} = = > Metadata Policy:${NC} ${YELLOW}$ARRAY_METADATA_LABEL${NC}"
	echo
}

# ============================================================
# #MARKER: ARCHIE FILENAME BUILDER (PLAIN FIRST / COLLISION SAFE)
# ============================================================
# PURPOSE:
# - Prefer clean, human-readable filenames.
# - Preserve original identity when already unique.
# - Only add sequence number if collision occurs.
#
# DESIGN:
# - First attempt: prefix + full (or trimmed) stem
# - Fallback: add incrementing suffix ONLY if needed
#
# OUTPUT EXAMPLES:
#   ARCHIVE_L2_MyUniqueFile.mkv
#   ARCHIVE_L2_MyUniqueFile_0001.mkv   (only if collision)
# ============================================================
archival_make_output_name() {
	local prefix="$1"
	local seq="$2"      # (kept for compatibility, not primary)
	local src="$3"

	local base stem candidate out
	local counter=1

	base="$(basename "$src")"
	stem="${base%.*}"

	# --------------------------------------------------------
	# OPTIONAL LENGTH CONTROL (keep your tail logic if desired)
	# --------------------------------------------------------
	if (( ${#stem} > 64 )); then
		stem="${stem: -64}"
	fi

	# --------------------------------------------------------
	# FIRST ATTEMPT (NO NUMBER)
	# --------------------------------------------------------
	out="${prefix}${stem}.mkv"

	if [[ ! -e "$out" ]]; then
		printf '%s\n' "$out"
		return 0
	fi

	# --------------------------------------------------------
	# COLLISION FALLBACK (NUMBERED)
	# --------------------------------------------------------
	while :; do
		printf -v suffix "%04d" "$counter"
		candidate="${prefix}${stem}_${suffix}.mkv"

		if [[ ! -e "$candidate" ]]; then
			printf '%s\n' "$candidate"
			return 0
		fi

		((counter++))
	done
}

# ============================================================
# #MARKER: ARCHIE'S ARCHIVAL ARRAY
# ============================================================
# PURPOSE:
# - Bulk re-encode large camera / evidence / archive-style footage
#   into smaller archival copies before optional tarball packaging.
#
# DESIGN:
# - NON-DESTRUCTIVE BY DEFAULT
# - Creates ARCHIVE_L1_ / L2 / L3 / L4 outputs
# - Optional tarball after successful encode pass
# - Optional original deletion only by explicit confirmation
#
# TIERS:
# - L1 = light archival shrink
# - L2 = balanced archive
# - L3 = aggressive storage-first archive
# - L4 = brute-force shrinkage priority
#
# IMPORTANT:
# - Any output that fails to come out smaller than its source is
#   treated as a NO-GAIN result and is removed automatically.
# - That protects the working directory from pointless archive copies.
# ============================================================

archival_collect_targets() {
	shopt -s nullglob nocaseglob
	local -a vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	local f
	for f in "${vids[@]}"; do
		[[ -f "$f" ]] || continue

		# --------------------------------------------------------
		# SKIP ANYTHING THAT IS ALREADY A GENERATED / PROCESSED
		# WORKFLOW OUTPUT.
		#
		# IMPORTANT:
		# - L4 MUST BE INCLUDED HERE NOW
		# - Otherwise future reruns could sweep ARCHIVE_L4_ files
		#   back up as fresh inputs
		# --------------------------------------------------------
		[[ "$f" =~ ^(ARCHIVE_L1_|ARCHIVE_L2_|ARCHIVE_L3_|ARCHIVE_L4_|REKEY_|SMC_|BARFIX_|SUBPACKED_|OEM_|PILOT_SMC_) ]] && continue

		printf '%s\n' "$f"
	done
}

archival_print_targets() {
	local title="$1"
	shift
	local items=("$@")

	echo -e "${CYAN} = = > ${title}: ${GREEN}${#items[@]}"
	if ((${#items[@]} > 0)); then
		printf "${GREEN}   - %s\n" "${items[@]}${NC}"
	fi
	echo
}

archival_get_prefix_for_level() {
	# --------------------------------------------------------
	# PURPOSE:
	# - Keep output naming aligned with the chosen archival tier.
	#
	# IMPORTANT:
	# - L4 was previously falling through to L2 naming.
	# - That made the file names lie about how they were encoded.
	# --------------------------------------------------------
	case "$1" in
		1) printf '%s\n' "ARCHIVE_L1_" ;;
		2) printf '%s\n' "ARCHIVE_L2_" ;;
		3) printf '%s\n' "ARCHIVE_L3_" ;;
		4) printf '%s\n' "ARCHIVE_L4_" ;;
		*) printf '%s\n' "ARCHIVE_L2_" ;;
	esac
}

archival_encode_one_file() {
	local level="$1"
	local in="$2"
	local out="$3"

	case "$level" in
		1)
			ffmpeg -y -hide_banner -nostats -loglevel error -i "$in" \
				-map 0 \
				"${ARRAY_METADATA_ARGS[@]}" \
				-c:v libx264 -preset slow -crf 21 \
				"${ARRAY_AUDIO_ARGS[@]}" \
				-c:s copy \
				"$out"
			;;
		2)
			ffmpeg -y -hide_banner -nostats -loglevel error -i "$in" \
				-map 0 \
				"${ARRAY_METADATA_ARGS[@]}" \
				-c:v libx264 -preset medium -crf 25 \
				"${ARRAY_AUDIO_ARGS[@]}" \
				-c:s copy \
				"$out"
			;;
		3)
			ffmpeg -y -hide_banner -nostats -loglevel error -i "$in" \
				-map 0 \
				"${ARRAY_METADATA_ARGS[@]}" \
				-c:v libx264 -preset medium -crf 29 \
				"${ARRAY_AUDIO_ARGS[@]}" \
				-c:s copy \
				"$out"
			;;
		4)
			ffmpeg -y -hide_banner -nostats -loglevel error -i "$in" \
				-map 0 \
				"${ARRAY_METADATA_ARGS[@]}" \
				-c:v libx264 -preset slow -crf 32 \
				"${ARRAY_AUDIO_ARGS[@]}" \
				-c:s copy \
				"$out"
			;;
		*)
			return 1
			;;
	esac
}

archival_build_tarball() {
	local tar_name="$1"
	shift
	local files=("$@")

	# --------------------------------------------------------
	# PURPOSE:
	# - Build a tarball only when we actually have kept outputs.
	#
	# RETURN CONTRACT:
	# - return 0 = tarball was built
	# - return 1 = no files supplied, nothing built
	# - non-zero from tar if tar itself fails
	# --------------------------------------------------------
	if [[ "${#files[@]}" -eq 0 ]]; then
		echo -e "${YELLOW} = = > No New Archival Outputs Were Kept. Tarball Step Skipped.${NC}"
		return 1
	fi

	run_with_progress "Building Archival Tarball..." tar -cf "$tar_name" "${files[@]}"
}

# ================================================================
# MARKER: ARCHIVAL PROCESS ONE TARGET
# ================================================================
archival_process_one_target() {

	local f="$1"
	local out pair src_from_pair out_from_pair
	local orig_size new_size

	out="$(archival_make_output_name "$prefix" "$((success_count + fail_count + no_gain_count + 1))" "$f")"
	if [[ -f "$out" ]] && ! is_valid_video_file "$out"; then
		rm -f -- "$out"
	fi

	echo -e "${CYAN} = = > Archiving:${NC} ${GREEN} $f${NC}"
	echo -e "${CYAN} = = > Output Name:${NC} ${YELLOW} $out${NC}"

	if run_with_progress "Archival Array: $(basename "$f")" archival_encode_one_file "$level" "$f" "$out"; then

		orig_size=$(stat -c%s "$f")
		new_size=$(stat -c%s "$out")

		if (( new_size >= orig_size )); then
			echo -e "${YELLOW} = = > No Size Gain. Removing Archival Copy:${NC} ${CYAN}$out${NC}"
			echo -e "${YELLOW} = = > Original Size:${NC} $orig_size bytes"
			echo -e "${YELLOW} = = > New Size:${NC} $new_size bytes"
			rm -f -- "$out"
			((no_gain_count+=1)) || :
		else
			echo -e "${GR} = = > Created:${NC} ${CYAN}$out${NC}"
			echo -e "${GREEN} = = > Size Reduced From:${NC} $orig_size ${GREEN}to${NC} $new_size bytes"
			outputs+=("$out")
			source_output_pairs+=("$f|$out")
			((success_count+=1)) || :
		fi
	else
		echo -e "${REB} = = > Failed:${NC} $f"
		((fail_count+=1)) || :
	fi

	echo
}

# ================================================================
# MARKER: ARCHIVAL PROCESS ONE TARGET (RESULT MODE)
# ================================================================
archival_process_one_target_result() {

	local f="$1"
	local result_file="$2"

	local out tmp_out
	local orig_size=0 new_size=0 elapsed_seconds=0 start_ts end_ts

	out="$(archival_make_output_name "$prefix" "$((success_count + fail_count + no_gain_count + 1))" "$f")"
	tmp_out="$ARCHIVE_TMPDIR/$(basename "$out")"

	if [[ -f "$out" ]] && ! is_valid_video_file "$out"; then
		rm -f -- "$out"
	fi

	echo -e "${CYAN} = = > Archiving:${NC} ${GREEN}$f${NC}"

	if [[ "${ARRAY_METADATA_LABEL:-SIDECAR_STRIP}" != "MINIMAL_SKIP" ]]; then
		archival_capture_metadata_sidecar "$f" >/dev/null || true
	fi

	start_ts="$(date +%s)"

	if archival_encode_one_file "$level" "$f" "$tmp_out"; then
		end_ts="$(date +%s)"
		elapsed_seconds=$(( end_ts - start_ts ))
		(( elapsed_seconds < 0 )) && elapsed_seconds=0

		mv -f -- "$tmp_out" "$out"

		orig_size="$(stat -c%s "$f" 2>/dev/null || echo 0)"
		new_size="$(stat -c%s "$out" 2>/dev/null || echo 0)"

		if (( new_size >= orig_size )); then
			rm -f -- "$out"
			echo "NO_GAIN|$f|$out|$orig_size|$new_size|$elapsed_seconds" >> "$result_file"
		else
			echo "SUCCESS|$f|$out|$orig_size|$new_size|$elapsed_seconds" >> "$result_file"
		fi
	else
		end_ts="$(date +%s)"
		elapsed_seconds=$(( end_ts - start_ts ))
		(( elapsed_seconds < 0 )) && elapsed_seconds=0

		rm -f -- "$tmp_out"
		echo "FAIL|$f||0|0|$elapsed_seconds" >> "$result_file"
	fi
}

run_archival_array() {
	local level prefix tar_name
	local orig_size new_size
	local -a targets=()
	local -a outputs=()
	local -a source_output_pairs=()
	local f out pair src_from_pair out_from_pair
	local success_count=0
	local fail_count=0
	local no_gain_count=0
	local delete_success_count=0

	local batch_source_total_bytes=0
	local batch_kept_total_bytes=0
	local batch_saved_bytes=0
	local batch_delta_percent=0
	local elapsed_total_seconds=0
	local start_ts

	clear
	show_space_overview

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                 ARCHIVAL ARRAY                 ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > PURPOSE: Re-encode large video collections into smaller archival copies.${NC}"
	echo -e "${YELLOW} = = > Originals remain untouched unless you explicitly delete them later.${NC}"
	echo -e "${YELLOW} = = > Outputs that fail to shrink will be discarded automatically.${NC}"
	echo
	echo -e "${CYAN} = = > Archival Levels:${NC}"
	echo -e "${CYAN}     1) Light Shrink   (Higher Quality / Larger Files)${NC}"
	echo -e "${CYAN}     2) Balanced       (Good Archive Default)${NC}"
	echo -e "${CYAN}     3) Aggressive     (Storage First / Smaller Files)${NC}"
	echo -e "${CYAN}     4) Brute Force    (Shrinkage Priority / Hard Squeeze)${NC}"
	echo

	mapfile -t targets < <(archival_collect_targets)
	if ! limit_targets_interactive targets; then
		echo -e "${YELLOW} = = > Archival Batch Selection Cancelled.${NC}"
		echo
		pause
		return 0
	fi

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      = = > Archival Run Mode${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}     1) Consecutive (Safe / One At A Time)${NC}"
	echo -e "${YELLOW}     2) Limited Parallel Jobs${NC}"
	echo -e "${YELLOW}     3) Thrash (Use CPU Thread Count)${NC}"
	echo -e "${YELLOW}     0.) Return${NC}"
	echo

	echo -ne "${CYAN}      = = > Select Mode:${GREEN}"
	read -r run_mode
	echo -ne "${NC}"

	if is_exit_token "$run_mode"; then
		return
	fi

	local max_jobs=1

	case "$run_mode" in
		1)
			max_jobs=1
			;;
		2)
			echo -ne "${YELLOW} = = > Enter Max Parallel Jobs:${GREEN}"
			read -r max_jobs
			echo -ne "${NC}"
			;;
		3)
			max_jobs="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
			;;
		*)
			echo -e "${RED}Invalid selection.${NC}"
			return
			;;
	esac

	if ((${#targets[@]} == 0)); then
		echo -e "${YELLOW} = = > No Eligible Source Videos Found In Current Folder.${NC}"
		echo
		pause
		return 0
	fi

	archival_print_targets "Eligible Archival Targets" "${targets[@]}"

	echo -e "${YELLOW}"
	read -r -p " = = > Choose Archival Level [1-4]:${NC}${GREEN}" level
	echo -e "${NC}"

	level="${level//[[:space:]]/}"

	case "$level" in
		1|2|3|4)
			;;
		*)
			echo -e "${YE} = = > Invalid Archival Level.${NC}"
			pause
			return 0
			;;
	esac

	prefix="$(archival_get_prefix_for_level "$level")"
	archival_configure_audio_policy
	archival_configure_metadata_policy

	echo
	echo -e "${CYAN} = = > Selected Level: ${GREEN}$level ${NC}"
	echo -e "${CYAN} = = > Output Prefix: ${GREEN}$prefix${NC}"
	echo

	if ! ask_yes_no " = = > Start Archival Encode Pass Now? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Archival Encode Pass Cancelled.${NC}"
		echo
		pause
		return 0
	fi

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}            ARCHIVAL ENCODE PASS NOW STARTING   ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	ARCHIVE_TMPDIR="$(mktemp -d)"

	result_file="$(mktemp)"
	pids=()
	running=0
	start_ts="$(date +%s)"
	archival_array_heartbeat "$result_file" "${#targets[@]}" "$start_ts" &
	heartbeat_pid=$!

	for f in "${targets[@]}"; do
		archival_process_one_target_result "$f" "$result_file" &

		pids+=($!)
		((running+=1)) || :

		if (( running >= max_jobs )); then
			wait -n || :
			((running-=1)) || :
		fi
	done

	for pid in "${pids[@]}"; do
		wait "$pid" 2>/dev/null || :
	done

	kill "$heartbeat_pid" 2>/dev/null || :
	wait "$heartbeat_pid" 2>/dev/null || :
	printf '\r\033[2K' >&2
	echo >&2

	while IFS='|' read -r status src out orig_size new_size elapsed_seconds; do
		case "$status" in
			SUCCESS)
				batch_source_total_bytes=$(( batch_source_total_bytes + orig_size ))
				batch_kept_total_bytes=$(( batch_kept_total_bytes + new_size ))
				elapsed_total_seconds=$(( elapsed_total_seconds + elapsed_seconds ))
				outputs+=("$out")
				source_output_pairs+=("$src|$out")
				((success_count+=1)) || :
				;;
			NO_GAIN)
				elapsed_total_seconds=$(( elapsed_total_seconds + elapsed_seconds ))
				((no_gain_count+=1)) || :
				;;
			FAIL)
				((fail_count+=1)) || :
				;;
		esac
	done < "$result_file"

	rm -f "$result_file"

			batch_saved_bytes=$(( batch_source_total_bytes - batch_kept_total_bytes ))
			batch_delta_percent="$(archival_percent_change "$batch_source_total_bytes" "$batch_kept_total_bytes")"

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              ARCHIVAL ENCODE SUMMARY           ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Source Total:${NC} ${YELLOW}$(format_bytes_human "$batch_source_total_bytes")${NC}"
	echo -e "${CYAN} = = > Kept Total:${NC} ${YELLOW}$(format_bytes_human "$batch_kept_total_bytes")${NC}"
	echo -e "${CYAN} = = > Saved Space:${NC} ${YELLOW}$(format_bytes_human "$batch_saved_bytes")${NC}"
	echo -e "${CYAN} = = > Batch Change:${NC} ${YELLOW}${batch_delta_percent}%${NC}"
	echo -e "${CYAN} = = > Encode Time:${NC} ${YELLOW}$(format_seconds_hms "$elapsed_total_seconds")${NC}"
	echo -e "${GREEN} = = > Successful Outputs Kept:${NC} $success_count"
	echo -e "${YELLOW} = = > No-Gain Outputs Removed:${NC} $no_gain_count"
	echo -e "${REB} = = > Failed Outputs:${NC} $fail_count"
	echo

	if ((${#outputs[@]} > 0)); then
		archival_print_targets "New Archival Outputs" "${outputs[@]}"
	else
		echo -e "${YELLOW} = = > No New Archival Outputs Survived The Size-Gain Filter.${NC}"
		echo
	fi

	# --------------------------------------------------------
	# OPTIONAL TARBALL STEP
	# --------------------------------------------------------
	# IMPORTANT:
	# - Ask only if there are real kept outputs.
	# - Prevent the old false-positive "Tarball Ready" message path.
	# --------------------------------------------------------
	if ((${#outputs[@]} > 0)); then
		if ask_yes_no " = = > Build Tarball From New Archival Outputs? (y/n or 1/2): "; then
			tar_name="${prefix}ARCHIVE_SET.tar"

			if archival_build_tarball "$tar_name" "${outputs[@]}"; then
				echo -e "${GR} = = > Tarball Ready:${NC} ${CYAN}$tar_name${NC}"
			else
				echo -e "${YELLOW} = = > Tarball Was Not Built.${NC}"
			fi
			echo
		else
			echo -e "${YELLOW} = = > Tarball Step Skipped.${NC}"
			echo
		fi
	else
		echo -e "${YELLOW} = = > Tarball Prompt Skipped Because No Outputs Were Kept.${NC}"
		echo
	fi

	# --------------------------------------------------------
	# OPTIONAL ORIGINAL DELETE STEP
	# --------------------------------------------------------
	# IMPORTANT:
	# - Only sources that have a surviving archival output pair
	#   are candidates for deletion.
	# - No surviving output = no delete pairing.
	# --------------------------------------------------------
	if ((${#source_output_pairs[@]} > 0)); then
		if ask_yes_no " = = > Delete Original Source Files After Successful Archival? (y/n or 1/2, default: n): "; then
			echo -e "${REB} = = > ORIGINAL DELETE PHASE ENABLED.${NC}"
			echo -e "${YELLOW} = = > Only sources with matching archival outputs will be removed.${NC}"
			echo

			for pair in "${source_output_pairs[@]}"; do
				src_from_pair="${pair%%|*}"
				out_from_pair="${pair#*|}"

				if [[ -f "$out_from_pair" && -f "$src_from_pair" ]]; then
					rm -f -- "$src_from_pair"
					echo -e "${GR} = = > Deleted Original:${NC} $src_from_pair"
					((delete_success_count+=1)) || :
				fi
			done

			echo
			echo -e "${CYAN} = = > Originals Deleted After Verified Archival:${NC} $delete_success_count"
			echo
		else
			echo -e "${YELLOW} = = > Original Sources Preserved.${NC}"
			echo
		fi
	else
		echo -e "${YELLOW} = = > Original Delete Prompt Skipped Because No Successful Output Pairs Exist.${NC}"
		echo
	fi

	pause
}

# ================================================================
# #MARKER: FINAL PRODUCT RESOLVER
# ================================================================
resolve_final_output() {
	local base="$1"

	local smc="SMC_${base}"
	local sut="SMC_${base}"

	if [[ -f "$smc" ]]; then
		echo "$smc"
		return 0
	elif [[ -f "$sut" ]]; then
		echo "$sut"
		return 0
	else
		return 1
	fi
}

# ================================================================
# #MARKER: FINALIZE PREFIX STRIPPER BY GROUP
# ================================================================
# PURPOSE:
# - Strip workflow prefixes only after user chooses a group.
# - Keep collision reports inside the menu flow.
# - Avoid treating archival / OEM identity as ordinary workflow noise.
#
# GROUPS:
# - NORMAL:  SMC_, SMC_, PILOT_SMC_, BARFIX_, SUBTOX_, SUBPACKED_
# - RESCUE:  REKEY_, PILOT_RESCUE_, RESCUE_, REMUX_, AUDIOFIX_, TIMEPRESS_, AUDIOLEVEL_
# - CUT:     TIPSNIP_, TAILTUCK_
# - ARCHIVE: ARCHIVE_, ARRAY_  (optional keeper/archival group)
#
# IMPORTANT:
# - OEM_ is intentionally NOT handled here.
# - OEM decisions belong to the Finalize OEM/parity routine only.
# ================================================================

finalize_strip_prefix_from_name_by_group() {
	local name="$1"
	local group="$2"
	local old

	while :; do
		old="$name"

		case "$group" in
			NORMAL)
				name="${name#SMC_}"
				name="${name#BARFIX_}"
				name="${name#SUBTOX_}"
				name="${name#SUBPACKED_}"
				;;

			RESCUE)
				name="${name#PILOT_RESCUE_}"
				name="${name#RESCUE_}"
				name="${name#REMUX_}"
				name="${name#AUDIOFIX_}"
				name="${name#TIMEPRESS_}"
				name="${name#AUDIOLEVEL_}"
				name="${name#REKEY_}"
				;;

			CUT)
				name="${name#TIPSNIP_}"
				name="${name#TAILTUCK_}"
				;;

			ARCHIVE)
				name="${name#ARCHIVE_}"
				name="${name#ARRAY_}"
				;;
		esac

		[[ "$name" == "$old" ]] && break
	done

	printf '%s\n' "$name"
}

finalize_strip_prefix_group() {
	local group="$1"
	local label="$2"
	local f clean target i
	local -a plan_from=()
	local -a plan_to=()
	local -a collisions=()
	local -A seen_targets=()

	shopt -s nullglob nocaseglob
	local files=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,webm,wmv})
	shopt -u nocaseglob
	shopt -s nullglob

	for f in "${files[@]}"; do
		[[ -f "$f" ]] || continue

		clean="$(finalize_strip_prefix_from_name_by_group "$f" "$group")"
		[[ "$clean" == "$f" ]] && continue

		target="$clean"

		if [[ -e "$target" || -n "${seen_targets[$target]:-}" ]]; then
			collisions+=("$f -> $target")
			continue
		fi

		seen_targets["$target"]=1
		plan_from+=("$f")
		plan_to+=("$target")
	done

	clear
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > FINALIZE PREFIX CLEANUP :: $label${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo

	if (( ${#plan_from[@]} == 0 && ${#collisions[@]} == 0 )); then
		echo -e "${YE} = = > No matching prefixed files found for this group.${NC}"
		pause
		return 0
	fi

	if (( ${#plan_from[@]} > 0 )); then
		echo -e "${GR} = = > Safe Renames:${NC}"
		for i in "${!plan_from[@]}"; do
			echo -e "${YELLOW}     ${plan_from[$i]}${NC} ${CYAN}->${NC} ${GREEN}${plan_to[$i]}${NC}"
		done
		echo
	fi

	if (( ${#collisions[@]} > 0 )); then
		echo -e "${REB} = = > COLLISIONS / SKIPPED:${NC}"
		for f in "${collisions[@]}"; do
			echo -e "${YE}     $f${NC}"
		done
		echo
		echo -e "${YE} = = > These were NOT added to the rename plan.${NC}"
		echo -e "${YE} = = > Move, archive, or finalize old blocking files first, then run this again.${NC}"
		echo
	fi

	if (( ${#plan_from[@]} == 0 )); then
		echo -e "${YE} = = > No safe renames available until collisions are cleared.${NC}"
		pause
		return 0
	fi

	if ! ask_yes_no " = = > Apply These Prefix Renames? (y/n or 1/2): "; then
		echo -e "${YE} = = > Prefix cleanup cancelled.${NC}"
		pause
		return 0
	fi

	for i in "${!plan_from[@]}"; do
		if [[ -e "${plan_to[$i]}" ]]; then
			echo -e "${REB} = = > [SKIP EXISTS]${NC} ${YELLOW}${plan_to[$i]}${NC}"
			continue
		fi

		mv -- "${plan_from[$i]}" "${plan_to[$i]}"
		echo -e "${GR} = = > [RENAMED]${NC} ${YELLOW}${plan_from[$i]}${NC} ${CYAN}->${NC} ${GREEN}${plan_to[$i]}${NC}"
	done

	echo
	echo -e "${GR} = = > Prefix Group Cleanup Complete.${NC}"
	pause
}

finalize_strip_workflow_prefixes() {
	local choice

	while true; do
		clear
		echo -e "${REB}================================================${NC}"
		echo -e "${REB}        FINALIZE / STRIP WORKFLOW PREFIXES       ${NC}"
		echo -e "${REB}================================================${NC}"
		echo
		echo -e "${YE} = = > This Is A FINAL FOLDER STEP.${NC}"
		echo -e "${YELLOW} = = > Do Not Run While Still Testing, Rescuing, Sampling, Or Comparing Outputs.${NC}"
		echo -e "${YELLOW} = = > Prefixes Are Workflow Identity Until You Are Truly Done With The Folder.${NC}"
		echo
		echo -e "${YELLOW}     1) Normal Workflow Prefixes${NC}"
		echo -e "${CYAN}        SMC_ / PILOT_ / BARFIX_ / SUBTOX_ / SUBPACKED_${NC}"
		echo
		echo -e "${YELLOW}     2) Rescue / Test Prefixes${NC}"
		echo -e "${CYAN}        REKEY_ / RESCUE_ / PILOT_RESCUE_ / REMUX_ / AUDIOFIX_ / TIMEPRESS_ / AUDIOLEVEL_${NC}"
		echo
		echo -e "${YELLOW}     3) Cut Helper Prefixes${NC}"
		echo -e "${CYAN}        TIPSNIP_ / TAILTUCK_${NC}"
		echo
		echo -e "${YE}     4) Archival Prefixes Usually Kept${NC}"
		echo -e "${CYAN}        ARCHIVE_ / ARRAY_${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo

		prompt_menu_choice " = = > Choose Prefix Group [1-4 | 0.=return]: " choice

		if is_exit_token "$choice"; then
			return 0
		fi

		case "$choice" in
			1)
				finalize_strip_prefix_group "NORMAL" "NORMAL WORKFLOW"
				;;
			2)
				finalize_strip_prefix_group "RESCUE" "RESCUE / TEST"
				;;
			3)
				finalize_strip_prefix_group "CUT" "CUT HELPERS"
				;;
			4)
				echo
				echo -e "${YE} = = > ARCHIVAL PREFIX NOTICE:${NC}"
				echo -e "${YELLOW} = = > ARCHIVE_ / ARRAY_ files are usually keeper archival outputs.${NC}"
				echo -e "${YELLOW} = = > Stripping these names can make archival products look like ordinary final media.${NC}"
				echo

				if ask_yes_no " = = > Strip Archival Prefixes Anyway? (y/n or 1/2): "; then
					finalize_strip_prefix_group "ARCHIVE" "ARCHIVAL / USUALLY KEEP"
				else
					echo -e "${YE} = = > Archival prefix cleanup skipped.${NC}"
					pause
				fi
				;;
			*)
				echo -e "${REB} = = > Invalid Prefix Group.${NC}"
				pause
				;;
		esac
	done
}

# =========================
# #MARKER: CSV / TEMPLATE ARCHIVE HELPER
# =========================

factory_slugify_name() {
	local s="$1"
	s="${s//[^A-Za-z0-9._-]/_}"
	s="$(echo "$s" | sed -E 's/_+/_/g; s/^_+//; s/_+$//')"
	[[ -z "$s" ]] && s="Unknown_Show"
	printf '%s\n' "$s"
}

factory_detect_archive_show_name() {
	local guess=""

	# Prefer current folder name for now. Later this can inspect CSV series column.
	guess="$(basename "$PWD")"
	guess="$(factory_slugify_name "$guess")"

	printf '%s\n' "$guess"
}

factory_collect_map_templates() {
	local mapfile="$1"
	[[ -f "$mapfile" ]] || return 0

	while IFS= read -r t; do
		[[ -f "$t" ]] && printf '%s\n' "$t"
	done < <(get_templates_from_intro_map "$mapfile")
}

factory_review_loose_archive_files() {
	local -n _loose_ref="$1"
	local -n _chosen_ref="$2"

	(( ${#_loose_ref[@]} == 0 )) && return 0

	echo
	echo -e "${CYAN} = = > Loose Files Detected:${NC}"
	printf '  %s\n' "${_loose_ref[@]}"
	echo
	echo -e "${YELLOW} = = > These Are Not Required Factory Archive Assets.${NC}"
	echo -e "${CYAN} = = > Include Loose Files In Archive?${NC}"
	echo -e "${GREEN}  1) Include All${NC}"
	echo -e "${YELLOW}  2) Skip Loose Files${NC}"
	echo
	echo -ne "${YELLOW} = = > Choice [2]: ${NC}"
	read -r loose_choice

	case "${loose_choice:-2}" in
		1)
			_chosen_ref+=("${_loose_ref[@]}")
			;;
		*)
			echo -e "${YELLOW} = = > Loose Files Skipped.${NC}"
			;;
	esac
}

# ================================================================
# #MARKER: SHOW / SEASON / TEMPLATE TITLE HELPERS
# ================================================================

factory_safe_slug() {
	local s="${1:-Unknown}"
	s="$(printf '%s\n' "$s" | sed -E 's/[^A-Za-z0-9]+/_/g; s/^_+//; s/_+$//; s/_+/_/g')"
	[[ -z "$s" ]] && s="Unknown"
	printf '%s\n' "$s"
}

factory_detect_show_season_slug() {
	local season=""
	local show=""

	season="$(find . -maxdepth 1 -type f \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' -o -iname '*.mov' \) -printf '%f\n' 2>/dev/null \
		| sed -nE 's/.*(S[0-9]{2})E[0-9]{2}.*/\1/p' \
		| head -n 1)"

	show="$(basename "$FACTORY_WORKDIR")"

	# If folder itself is just S07 / Season_07 style, use parent as show.
	if [[ "$show" =~ ^(S[0-9]{2}|Season[_ -]?[0-9]{1,2}|.*_S[0-9]{2})$ ]]; then
		show="$(basename "$(dirname "$FACTORY_WORKDIR")")"
	fi

	show="$(factory_safe_slug "$show")"
	season="$(factory_safe_slug "${season:-Sxx}")"

	printf '%s_%s\n' "$show" "$season"
}

factory_source_sxxexx() {
	local src="${1:-}"
	local base

	base="$(basename "$src")"

	if [[ "$base" =~ (S[0-9]{2}E[0-9]{2}(-E[0-9]{2})?) ]]; then
		printf '%s\n' "${BASH_REMATCH[1]}"
		return 0
	fi

	printf '%s\n' "SxxExx"
}

factory_template_title_from_source() {
	local kind="$1"
	local src="$2"
	local show_slug sxxexx

	show_slug="$(factory_safe_slug "$(basename "$(dirname "$FACTORY_WORKDIR")")")"
	sxxexx="$(factory_source_sxxexx "$src")"

	case "$kind" in
		intro) printf 'Intro_Template_%s_%s\n' "$show_slug" "$sxxexx" ;;
		outro) printf 'Outro_Template_%s_%s\n' "$show_slug" "$sxxexx" ;;
		*)     printf 'Template_%s_%s\n' "$show_slug" "$sxxexx" ;;
	esac
}

factory_set_mkv_title_if_possible() {
	local file="$1"
	local title="$2"

	[[ -f "$file" ]] || return 0

	if command -v mkvpropedit >/dev/null 2>&1; then
		mkvpropedit "$file" --edit info --set "title=$title" >/dev/null 2>&1 || {
			echo -e "${YE} = = > Template Title Write Failed:${NC} ${YELLOW}$(factory_display_path "$file")${NC}"
			return 0
		}

		echo -e "${GR} = = > Template MKV Title Set:${NC} ${YELLOW}$title${NC}"
	else
		echo -e "${YE} = = > mkvpropedit Not Found. Template Title Not Written.${NC}"
	fi
}

factory_archive_and_clear_template_repo() {
	local repo="${INTRO_TEMPLATE_DIR:-${FACTORY_HOME}/intro_template}"
	local archive_count=0
	local f

	[[ -d "$repo" ]] || {
		echo -e "${YE} = = > No Template Repo Found:${NC} ${YELLOW}$(factory_display_path "$repo")${NC}"
		return 0
	}

	build_csv_template_archive || return 1

	shopt -s nullglob nocaseglob
	for f in "$repo"/intro*.mkv "$repo"/outro*.mkv; do
		[[ -f "$f" ]] || continue
		rm -f -- "$f"
		((archive_count+=1)) || :
	done
	shopt -u nullglob nocaseglob

	echo -e "${GR} = = > Template Repo Cleared:${NC} ${YELLOW}$(factory_display_path "$repo")${NC}"
	echo -e "${CYAN} = = > Template Files Removed:${NC} ${YELLOW}$archive_count${NC}"
}

run_csv_template_archive() {
	echo -e "${CYAN} = = > Building CSV + Template Archive...${NC}"

	local show_name archive_root archive_dir tarname manifest
	local -a archive_files map_templates loose_files chosen_loose

	show_name="$(factory_detect_archive_show_name)"
	archive_root="${FACTORY_TEMPLATE_ARCHIVE_ROOT:-template_archive}"
	archive_dir="$archive_root/$show_name/$(date +%Y%m%d_%H%M%S)"

	mkdir -p "$archive_dir" || {
		echo -e "${RED} = = > Failed To Create Archive Folder:${NC} $archive_dir"
		return 1
	}

	tarname="csv_templates_$(factory_detect_show_season_slug)_$(date +%Y%m%d_%H%M%S).tar.gz"
	manifest="$archive_dir/manifest.txt"

	shopt -s nullglob nocaseglob

	archive_files=(
		"$INTRO_MAP"
		"${OUTRO_MAP:-outro_map.csv}"
		intro_map.csv
		outro_map.csv
		launcher.conf
		factory_session.conf
		.factory_session.conf
		*.episodes.csv
		*_episodes.csv
	)

	loose_files=(
		*.sh
		*.srt
		*.txt
		*.doc
		*.log
		*.conf
		.*.conf
	)

	shopt -u nullglob nocaseglob

	map_templates=()

	if [[ -f "$INTRO_MAP" ]]; then
		while IFS= read -r t; do
			map_templates+=("$t")
		done < <(factory_collect_map_templates "$INTRO_MAP")
	fi

	if [[ -f "${OUTRO_MAP:-outro_map.csv}" ]]; then
		while IFS= read -r t; do
			map_templates+=("$t")
		done < <(factory_collect_map_templates "${OUTRO_MAP:-outro_map.csv}")
	fi

	# Remove missing known files.
	local -a clean_archive_files=()
	local f
	for f in "${archive_files[@]}" "${map_templates[@]}"; do
		[[ -e "$f" ]] || continue
		clean_archive_files+=("$f")
	done

	# Remove duplicates.
	mapfile -t clean_archive_files < <(printf '%s\n' "${clean_archive_files[@]}" | awk '!seen[$0]++')
	mapfile -t loose_files < <(printf '%s\n' "${loose_files[@]}" | awk '!seen[$0]++')

	factory_review_loose_archive_files loose_files chosen_loose

	echo
	echo -e "${CYAN} = = > Archive Destination:${NC}"
	echo -e "${GREEN} $archive_dir${NC}"
	echo
	echo -e "${CYAN} = = > Known Factory Assets:${NC}"
	printf '  %s\n' "${clean_archive_files[@]}"
	echo
	if (( ${#chosen_loose[@]} > 0 )); then
		echo -e "${CYAN} = = > Loose Files Included:${NC}"
		printf '  %s\n' "${chosen_loose[@]}"
		echo
	fi

	{
		echo "Factory CSV / Template Archive"
		echo "Created: $(date)"
		echo "Show: $show_name"
		echo "Source Folder: $PWD"
		echo
		echo "Known Factory Assets:"
		printf '  %s\n' "${clean_archive_files[@]}"
		echo
		echo "Loose Files Included:"
		printf '  %s\n' "${chosen_loose[@]}"
	} > "$manifest"

	if tar -czf "$tarname" "${clean_archive_files[@]}" "${chosen_loose[@]}" "$manifest"; then
		echo -e "${GREEN} = = > Archive Created:${NC} $tarname"
		return 0
	else
		echo -e "${RED} = = > Archive Failed.${NC}"
		return 1
	fi
}

# =========================
# #MARKER: FINALIZE / CLEANUP MENU
# =========================
# PURPOSE:
# - Provide a controlled place for removing obvious workflow leftovers.
# - Separate harmless temp cleanup from more consequential artifact cleanup.
# - Keep destructive actions confirm-heavy and visible.
#
# SAFETY MODEL:
# - Show targets before deletion where practical.
# - Default to current-folder-only cleanup behavior.
# - Never touch OEM_ backups here.
#
# NOTES:
# - This menu focuses on temporary/generated workflow artifacts.
# - Final outputs such as SMC_, BARFIX_, SUBPACKED_, and REKEY_ are only
#   removed in their own dedicated actions with confirmation.
#
run_finalize_menu() {

	cleanup_print_targets() {
		local label="$1"
		shift
		local -a items=("$@")

		local count color status_label
		count=${#items[@]}

		if (( count == 0 )); then
			color=$GREEN
			status_label="CLEAN"
		elif (( count < 3 )); then
			color=$YELLOW
			status_label="NOTICE"
		else
			color=$RED
			status_label="BUSY"
		fi

		echo -e "${CYAN} = = > ${label}:${NC} ${color}${count}${NC} ${color}[${status_label}]${NC}"

		if (( count == 0 )); then
			echo -e " - ${color}none${NC}"
		else
			local f
			for f in "${items[@]}"; do
				echo -e " - ${color}$f${NC}"
			done
		fi

		echo
	}

	cleanup_collect_temp_targets() {
		shopt -s nullglob nocaseglob
		local -a temp_targets=(
			_smartgap_tmp
			_smartgap_preview
			_factory_tmp
			_factory_work
			_hb_temp
			_norm_tmp
			_rekey_tmp
			x265_2pass.log
			x265_2pass.log.cutree
			*.log
			*.log.cutree
			ffmpeg2pass-0.log
			ffmpeg2pass-0.log.mbtree
			custom_cut*.mkv
			custom_cut*.mp4
			custom_cut*.avi
			custom_cut*.mov
			./*.tmp
			./*.bak
		)
		shopt -u nullglob nocaseglob

		local t
		for t in "${temp_targets[@]}"; do
			[[ -e "$t" ]] || continue
			printf '%s\n' "$t"
		done
	}

	cleanup_collect_template_targets() {
		shopt -s nullglob nocaseglob
		local -a targets=(
			intro_template
			intro_template*.mkv
			intro_template*.mp4
			intro_template*.avi
			intro_template*.mov
		)
		shopt -u nullglob nocaseglob

		local t
		for t in "${targets[@]}"; do
			[[ -e "$t" ]] || continue
			printf '%s\n' "$t"
		done
	}

	cleanup_collect_detection_targets() {
		shopt -s nullglob nocaseglob
		local -a targets=(
			"$INTRO_MAP"
			*.csv
			*.tsv
		)
		shopt -u nullglob nocaseglob

		local t
		for t in "${targets[@]}"; do
			[[ -e "$t" ]] || continue
			printf '%s\n' "$t"
		done
	}

	cleanup_remove_targets() {
		local removed=0
		local failed=0
		local target

		for target in "$@"; do
			[[ -e "$target" ]] || continue

			if [[ -d "$target" ]]; then
				if rm -rf -- "$target"; then
					echo -e "${GR} = = > [REMOVED]${NC} $target"
					((removed+=1)) || :
				else
					echo -e "${REB} = = > [FAILED]${NC} $target"
					((failed+=1)) || :
				fi
			else
				if rm -f -- "$target"; then
					echo -e "${GR} = = > [REMOVED]${NC} $target"
					((removed+=1)) || :
				else
					echo -e "${REB} = = > [FAILED]${NC} $target"
					((failed+=1)) || :
				fi
			fi
		done

		echo
		echo -e "${RE} = = > Removed:${NC} $removed"
		echo -e "${REB} = = > Failed:${NC} $failed"
		echo
	}

cleanup_show_status() {
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              CLEANUP :: STATUS                 ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	ui_show_folder_state_snapshot
	ui_show_cleanup_target_snapshot

	echo
	echo -e "${YELLOW} = = > OEM Material Is Handled Through The Integrated SMC Finalizer.${NC}"
	echo
	pause
}

	cleanup_temp_junk() {
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}          CLEANUP :: TEMP / JUNK FILES          ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo

		local -a targets=()
		mapfile -t targets < <(cleanup_collect_temp_targets)

		cleanup_print_targets "Temp / Junk Targets Queued" "${targets[@]}"

		if ((${#targets[@]}==0)); then
			pause
			return 0
		fi

		if is_exit_token "$(read -r reply; echo "$reply")"; then
			echo -e "${YELLOW} = = > Cancelled.${NC}"
			echo
			return 0
		fi

		if ask_yes_no "${YELLOW} = = > Remove These Temp / Junk Targets? (y/n | 0.=cancel): ${NC}"; then
			cleanup_remove_targets "${targets[@]}"
		else
			echo -e "${YELLOW} = = > Temp Cleanup Cancelled.${NC}"
			echo
		fi

		pause
	}

	cleanup_templates() {
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}         CLEANUP :: TEMPLATE ARTIFACTS          ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo

		local -a targets=()
		mapfile -t targets < <(cleanup_collect_template_targets)

		cleanup_print_targets "Template Targets Queued" "${targets[@]}"

		if ((${#targets[@]}==0)); then
			pause
			return 0
		fi

		echo -ne "${YELLOW} = = > Your Keys Are In Here So Make Sure Your Done Before You Delete ${NC}"
		echo

		if ! ask_yes_no " = = > Remove Template Artifacts And intro_template Directory? (y/n or 1/2 | 0.=cancel): "; then
			echo -e "${YELLOW} = = > Template Cleanup Cancelled.${NC}"
			echo
			pause
			return 0
		fi

		cleanup_remove_targets "${targets[@]}"
		pause
	}

cleanup_collect_rekey_targets() {
	shopt -s nullglob nocaseglob
	local -a targets=(REKEY_*.mkv)
	shopt -u nullglob nocaseglob

	local f
	for f in "${targets[@]}"; do
		[[ -f "$f" ]] || continue
		printf '%s\n' "$f"
	done
}

# =========================================================
# MARKER: EXECUTE OEM FINALIZE CHOICE (POST-SUCCESS)
# =========================================================
# PURPOSE:
#   Carry out the OEM disposition that was chosen earlier,
#   but ONLY after parity checks and SMC promotion have
#   completed successfully.
#
# HOUSE RULE:
#   OEM remains safety material until finalize is truly done.
# =========================================================
cleanup_execute_OEM_finalize_choice() {
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}       EXECUTING SAVED OEM FINALIZE CHOICE      ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	case "${OEM_FINALIZE_CHOICE:-leave}" in
		archive)
			echo -e "${YELLOW} = = > Executing OEM Choice: Archive OEM Material${NC}"
			echo
			cleanup_archive_OEM_material
			;;
		leave)
			echo -e "${YELLOW} = = > Executing OEM Choice: Leave OEM Material Alone${NC}"
			echo
			;;
		dump)
			echo -e "${YELLOW} = = > Executing OEM Choice: Delete OEM Contents, Then Mark Folder Finished${NC}"
			echo
			cleanup_delete_OEM_contents
			cleanup_mark_OEM_folder_finished
			;;
		mark)
			echo -e "${YELLOW} = = > Executing OEM Choice: Mark OEM Folder Finished, But Keep Contents${NC}"
			echo
			cleanup_mark_OEM_folder_finished
			;;
		*)
			echo -e "${RE} = = > Unknown OEM Finalize Choice:${NC} ${OEM_FINALIZE_CHOICE}"
			echo -e "${YELLOW} = = > Leaving OEM Material Unchanged For Safety.${NC}"
			echo
			return 1
			;;
	esac

	echo -e "${GREEN} = = > OEM Finalize Choice Processing Complete.${NC}"
	echo
	return 0
}

cleanup_detection_maps() {
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}       CLEANUP :: DETECTION MAP / CSV FILES     ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo

		local -a targets=()
		mapfile -t targets < <(cleanup_collect_detection_targets)

		cleanup_print_targets "Detection / CSV Targets Queued" "${targets[@]}"

		if ((${#targets[@]}==0)); then
			pause
			return 0
		fi

	echo -e "${YELLOW} = = > Remove Detection-Map / CSV Style Artifacts? (y/n | 1/2 | 0.=cancel): ${NC}"
	read -r reply
	reply="${reply//[[:space:]]/}"

	if is_exit_token "$reply"; then
		echo -e "${YELLOW} = = > Cancelled.${NC}"
		echo
		return 0
	fi

	case "${reply,,}" in
		y|yes|1)
			cleanup_remove_targets "${targets[@]}"
			;;
		n|no|2|"")
			echo -e "${YELLOW} = = > Detection / CSV Cleanup Cancelled.${NC}"
			echo
			;;
		*)
			echo -e "${YELLOW} = = > Detection / CSV Cleanup Cancelled.${NC}"
			echo
			;;
	esac

	pause
}

	cleanup_run_all_safe() {
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}          CLEANUP :: SAFE CLEANUP PASS          ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
        echo -e "${YELLOW}"
		echo " = = > This safe cleanup pass removes:"
		echo " = = >  - obvious temp / junk files"
		echo " = = >  - template artifacts"
		echo " = = >  - detection maps / CSV files"
		echo
		echo " = = > It does NOT remove:"
		echo " = = >  - OEM backup material"
		echo " = = >  - finished SMC outputs"
		echo

		if ! ask_yes_no " = = > Run Safe Cleanup Pass Now? (y/n or 1/2): "; then
			echo -e "${YELLOW} = = > Safe Cleanup Pass Cancelled.${NC}"
			pause
			return 0
		fi

		local -a temp_targets=()
		local -a template_targets=()
		local -a detect_targets=()

		mapfile -t temp_targets < <(cleanup_collect_temp_targets)
		mapfile -t template_targets < <(cleanup_collect_template_targets)
		mapfile -t detect_targets < <(cleanup_collect_detection_targets)

		clear
		echo -e "${CYAN} = = > Removing Safe Cleanup Targets...${NC}"
		echo

		cleanup_remove_targets "${temp_targets[@]}" "${template_targets[@]}" "${detect_targets[@]}"
		pause
	}

cleanup_collect_final_targets() {
	shopt -s nullglob nocaseglob
	local -a targets=(SMC_*.mkv)
	shopt -u nullglob nocaseglob

	local f
	for f in "${targets[@]}"; do
		[[ -f "$f" ]] || continue
		printf '%s\n' "$f"
	done
}

cleanup_collect_finished_targets() {
	cleanup_collect_final_targets
}

cleanup_final_name_from_finished() {
	local file="$1"
	local custom_prefix="${2:-}"
	local rest

	rest="$file"
	rest="${rest#SMC_}"

	if [[ -n "$custom_prefix" ]]; then
		printf '%s\n' "${custom_prefix}${rest}"
	else
		printf '%s\n' "$rest"
	fi
}

	cleanup_collect_replaceable_originals() {
		local custom_prefix="${1:-}"
		local -a finished_targets=()
		local s final_name

		mapfile -t finished_targets < <(cleanup_collect_finished_targets)

		for s in "${finished_targets[@]}"; do
			final_name="$(cleanup_final_name_from_finished "$s" "$custom_prefix")"
			[[ -f "$final_name" ]] || continue
			printf '%s\n' "$final_name"
		done
	}

	cleanup_mark_OEM_folder_finished() {
		local target="Factory_WuZ_Here"

		if [[ ! -d "./OEM" ]]; then
			return 0
		fi

		if [[ -e "./$target" ]]; then
			echo -e "${YELLOW} = = > OEM Finished Folder Name Already Exists:${NC} $target"
			echo -e "${YELLOW} = = > Leaving ./OEM Name Unchanged To Avoid Collision.${NC}"
			echo
			return 0
		fi

		if mv -- "./OEM" "./$target"; then
			echo -e "${GR} = = > OEM Folder Marked Finished As:${NC}${ORANGE} $target${NC}"
		else
			echo -e "${REB} = = > Failed To Rename OEM Folder To:${NC}${ORANGE} $target${NC}"
		fi

		echo
	}

# =========================================================
# MARKER: FINALIZE OEM PARITY GUARD (SMC -> OEM)
# =========================================================
# PURPOSE:
#   Before destructive finalize steps, verify that every
#   finished SMC target still has its matching OEM backup.
#
# WHY THIS EXISTS:
#   Count-only parity is not strong enough here.
#   We do NOT merely care that "the numbers look right" —
#   we care that EACH finalized episode still has its own
#   recoverable OEM counterpart by base filename.
#
# SAFETY MODEL:
#   For every:
#       SMC_Episode_Name.mkv
#   require:
#       ./OEM/OEM_Episode_Name.mkv
#
# IMPORTANT:
#   OEM backups in this script live in:
#       ./OEM/
#   with filename pattern:
#       OEM_<original_filename>
#
# RESULT:
#   - PASS: finalize may continue
#   - FAIL: finalize must stop before destructive actions
#
# HOUSE RULE:
#   Feedback is king.
#   If parity fails, show exactly what is missing.
# =========================================================
cleanup_verify_OEM_parity_for_finished_targets() {
	local -a finished_targets=()
	local -a missing_OEM=()
	local finished_file base_name stem
	local matched_OEM=""
	local f oem_name oem_stem
	local ep_code legacy_code

	mapfile -t finished_targets < <(cleanup_collect_finished_targets)

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}       FINALIZE :: OEM PARITY SAFETY CHECK      ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Verifying That Every Finished SMC File Has A Matching OEM Backup...${NC}"
	echo

	if (( ${#finished_targets[@]} == 0 )); then
		echo -e "${YELLOW} = = > No SMC Targets Found. Nothing To Verify.${NC}"
		echo
		return 1
	fi

	echo -e "${CYAN} = = > OEM Folder Present:${NC} $([[ -d ./OEM ]] && echo YES || echo NO)"
	echo

	for finished_file in "${finished_targets[@]}"; do
		[[ -f "$finished_file" ]] || continue

		base_name="$finished_file"
		base_name="${base_name#SMC_}"
		stem="${base_name%.*}"
		matched_OEM=""
		ep_code=""
		legacy_code=""

		echo -e "${CYAN} = = > SMC Target:${NC} $finished_file"
		echo -e "${CYAN} = = > Expected OEM Stem:${NC} ./OEM/**/OEM_${stem}.*"

		# ---------------------------------------------------------
		# PASS 1: Exact Modern Stem Match Anywhere Under OEM
		# ---------------------------------------------------------
		while IFS= read -r f; do
			[[ -f "$f" ]] || continue

			oem_name="${f##*/}"
			oem_stem="${oem_name#OEM_}"
			oem_stem="${oem_stem%.*}"

			if [[ "$oem_stem" == "$stem" ]]; then
				matched_OEM="$f"
				break
			fi
		done < <(find ./OEM -type f -name 'OEM_*' 2>/dev/null | sort)

		# ---------------------------------------------------------
		# PASS 2: Episode Identity Match Anywhere Under OEM
		# ---------------------------------------------------------
		if [[ -z "$matched_OEM" ]]; then
			ep_code="$(printf '%s\n' "$finished_file" \
				| grep -oiE 'S[0-9]{2}E[0-9]{2}' \
				| head -1 \
				| tr '[:lower:]' '[:upper:]' || true)"

			if [[ -n "$ep_code" ]]; then
				legacy_code="$(printf '%s\n' "$ep_code" \
					| sed -E 's/^S0*([0-9]+)E0*([0-9]+)/\1x\2/I')"

				echo -e "${YE} = = > Exact OEM Name Match Missing.${NC}"
				echo -e "${CYAN} = = > Trying Episode Identity Match:${NC} ${YELLOW}$ep_code / $legacy_code${NC}"

				while IFS= read -r f; do
					[[ -f "$f" ]] || continue

					oem_name="${f##*/}"

					if printf '%s\n' "$oem_name" | grep -qiE "${ep_code}|${legacy_code}"; then
						matched_OEM="$f"
						break
					fi
				done < <(find ./OEM -type f 2>/dev/null | sort)
			fi
		fi

		if [[ -n "$matched_OEM" ]]; then
			echo -e "${GREEN} = = > OEM Match Found:${NC} $matched_OEM"
		else
			echo -e "${REB} = = > OEM Match Missing.${NC}"
			missing_OEM+=("./OEM/**/OEM_${stem}.*")
		fi

		echo
	done

	echo -e "${CYAN} = = > Finished SMC Targets:${NC} ${#finished_targets[@]}"
	echo -e "${CYAN} = = > Missing OEM Counterparts:${NC} ${#missing_OEM[@]}"
	echo

	if (( ${#missing_OEM[@]} == 0 )); then
		echo -e "${GREEN} = = > OEM Parity Check: PASS${NC}"
		echo -e "${GREEN} = = > Every Finished SMC File Has A Matching OEM Backup Somewhere Under ./OEM.${NC}"
		echo
		return 0
	fi

	echo -e "${REB} = = > OEM Parity Check: FAIL${NC}"
	echo -e "${RED} = = > Missing OEM Counterparts Were Found.${NC}"
	echo
	echo -e "${YELLOW} = = > Finalize Must Stop Before Any Destructive Promotion / Deletion.${NC}"
	echo

	cleanup_print_targets "Missing OEM Backup(s)" "${missing_OEM[@]}"
	echo

	return 1
}

cleanup_archive_OEM_folder() {
	local stamp tar_name
	local -a csv_files=()
	local -a map_templates=()

	# ========================================================
	# PURPOSE:
	# Archive OEM folder + related CSV + referenced templates
	# into a timestamped tar.gz bundle.
	#
	# NOTES:
	# - Uses run_with_progress for long-running tar operation
	# - Preserves user feedback during compression
	# ========================================================

	if [[ ! -d "./OEM" ]]; then
		echo -e "${YE} = = > OEM Folder Not Present. Nothing To Archive.${NC}"
		echo
		return 0
	fi

	# ----- COLLECT CSV FILES ---------------------------------

	shopt -s nullglob nocaseglob
	csv_files=( *.csv *.sh *.srt *.log )
	shopt -u nullglob nocaseglob

	# ----- COLLECT TEMPLATE FILES FROM INTRO MAP -------------
	# Only include files that actually exist
	while IFS= read -r t; do
		[[ -f "$t" ]] && map_templates+=("$t")
	done < <(get_templates_from_intro_map "$INTRO_MAP")

	# ----- BUILD ARCHIVE NAME --------------------------------
	stamp="$(date +%Y%m%d_%H%M%S)"
	tar_name="OEM_archive_${stamp}.tar.gz"

	echo -e "${CYAN} = = > Creating OEM Archive:${NC} $tar_name"

	# ========================================================
	# LONG-RUN OPERATION
	# Use run_with_progress wrapper instead of calling tar directly
	# ========================================================
	if run_with_progress "Archiving OEM Folder..." \
		tar -czf "$tar_name" \
			OEM/ \
			"${csv_files[@]}" \
			"${map_templates[@]}"; then

		echo -e "${GR} = = > OEM Archive Created:${NC} $tar_name"
	else
		echo -e "${REB} = = > OEM Archive FAILED:${NC} $tar_name"
	fi

	echo
}

	cleanup_delete_OEM_contents() {
		local reply

		if [[ ! -d "./OEM" ]]; then
			echo -e "${YE} = = > OEM Folder Not Present. Nothing To Delete.${NC}"
			echo
			return 0
		fi

		if ! ask_yes_no " = = > Delete OEM Folder Contents Only? (y/n or 1/2): "; then
			echo -e "${YELLOW} = = > OEM Content Deletion Cancelled.${NC}"
			pause
			return 0
		fi

		find "./OEM" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + 2>/dev/null || true

		echo -e "${GR} = = > OEM Folder Contents Removed.${NC}"
		echo
	}

# =========================================================
# MARKER: PROMPT OEM FINALIZE CHOICE (NO ACTION YET)
# =========================================================
# PURPOSE:
#   Ask the user what should happen to OEM material during
#   finalize, but DO NOT perform that action yet.
#
# WHY:
#   OEM parity may still be required for finalize safety.
#   So we capture the decision now and execute it only
#   after finalize succeeds.
# =========================================================
cleanup_handle_OEM_material() {
	local reply

	OEM_FINALIZE_CHOICE="leave"

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          OEM MATERIAL FINALIZE OPTIONS         ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}"
	echo "     1) Archive OEM Material"
	echo "     2) Leave OEM Material Alone"
	echo "     3) Delete OEM Contents Only, Then Mark Folder Finished"
	echo "     4) Mark OEM Folder Finished, But Keep Contents"
	echo
	read -r -p "     Choice: ${NC}${GREEN}" reply
	echo -e "${NC}"

	reply="${reply//[[:space:]]/}"

	# ========================================================
	# TEN-KEY EXIT HOOK
	# ========================================================
	if is_exit_token "$reply"; then
		echo -e "${YELLOW} = = > OEM Finalize Choice Cancelled.${NC}"
		echo
		return 1
	fi

	case "$reply" in
		1)
			OEM_FINALIZE_CHOICE="archive"
			echo -e "${GREEN} = = > OEM Finalize Choice Saved:${NC} Archive OEM Material"
			;;
		2)
			OEM_FINALIZE_CHOICE="leave"
			echo -e "${GREEN} = = > OEM Finalize Choice Saved:${NC} Leave OEM Material Alone"
			;;
		3)
			OEM_FINALIZE_CHOICE="dump"
			echo -e "${GREEN} = = > OEM Finalize Choice Saved:${NC} Delete OEM Contents, Then Mark Folder Finished"
			;;
		4)
			OEM_FINALIZE_CHOICE="mark"
			echo -e "${GREEN} = = > OEM Finalize Choice Saved:${NC} Mark OEM Folder Finished, But Keep Contents"
			;;
		*)
			echo -e "${RE} = = > Invalid OEM Finalize Choice.${NC}"
			echo
			return 1
			;;
	esac

	echo -e "${YELLOW} = = > OEM Action Will Be Performed Only After Successful Finalize.${NC}"
	echo
	return 0
}

	cleanup_delete_replaced_working_originals() {
		local custom_prefix="${1:-}"
		local -a originals=()
		local f
		local removed=0
		local failed=0
		local reply

		mapfile -t originals < <(cleanup_collect_replaceable_originals "$custom_prefix")

		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}      WORKING-ORIGINAL REPLACEMENT HANDOFF      ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo

		if (( ${#originals[@]} == 0 )); then
			echo -e "${GREEN} = = > No Working-Dir Originals Conflict With Final SMC Names.${NC}"
			echo
			return 0
		fi

		echo -e "${YELLOW} = = > The Following Working-Dir Originals Must Move Out Of The Way${NC}"
		echo -e "${YELLOW} = = > Before Finished SMC Files Can Become Their Final Names:${NC}"
		echo

		for f in "${originals[@]}"; do
			echo -e "  ${YELLOW}-${NC} $f"
		done

		echo
		if ! ask_yes_no " = = > Delete These Working-Dir Originals Now? (y/n): "; then
			echo -e "${YELLOW} = = > Working-Dir Original Deletion Cancelled.${NC}"
			echo
			return 1
		fi

		for f in "${originals[@]}"; do
			if [[ ! -f "$f" ]]; then
				echo -e "${YELLOW} = = > [SKIP MISSING ORIGINAL]${NC} $f"
				continue
			fi

			if rm -f -- "$f"; then
				echo -e "${GR} = = > [DELETED ORIGINAL]${NC} $f"
				((removed+=1)) || :
			else
				echo -e "${REB} = = > [FAILED DELETE]${NC} $f"
				((failed+=1)) || :
			fi
		done

		echo
		echo -e "${CYAN} = = > Originals Deleted:${NC} $removed"
		echo -e "${CYAN} = = > Delete Failures:${NC} $failed"
		echo

		if (( failed > 0 )); then
			return 1
		fi

		return 0
	}

	cleanup_promote_finished_outputs() {
		local custom_prefix="${1:-}"
		local -a finished_targets=()
		local s final_name
		local renamed=0
		local failed=0

		mapfile -t finished_targets < <(cleanup_collect_finished_targets)

		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}         PROMOTE SMC OUTPUTS TO FINAL       ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo

		if (( ${#finished_targets[@]} == 0 )); then
			echo -e "${YELLOW} = = > No FINISHED Files Found.${NC}"
			echo
			return 1
		fi

		echo -e "${CYAN} = = > Planned Renames:${NC}"
		for s in "${finished_targets[@]}"; do
			final_name="$(cleanup_final_name_from_finished "$s" "$custom_prefix")"
			echo -e "  ${GREEN}${s}${NC}  ->  ${YELLOW}${final_name}${NC}"
		done
		echo

		for s in "${finished_targets[@]}"; do
			final_name="$(cleanup_final_name_from_finished "$s" "$custom_prefix")"

			if [[ "$s" == "$final_name" ]]; then
				echo -e "${YE} = = > [SKIP SAME NAME] $s${NC}"
				continue
			fi

			if [[ -e "$final_name" ]]; then
				echo -e "${REB} = = > [NAME COLLISION] $final_name${NC}"
				((failed+=1)) || :
				continue
			fi

			if mv -- "$s" "$final_name"; then
				echo -e "${GR} = = > [PROMOTED]${NC}${YE} $final_name${NC}"
				((renamed+=1)) || :
			else
				echo -e "${REB} = = > [FAILED RENAME] $s${NC}"
				((failed+=1)) || :
			fi
		done

		echo
		echo -e "${CYAN} = = > Promoted:${NC}${GR} $renamed${NC}"
		echo -e "${CYAN} = = > Failures:${NC}${RE} $failed${NC}"
		echo

		if (( failed > 0 )); then
			return 1
		fi

		return 0
	}

cleanup_finalize_finished_replacements() {
	local rename_mode custom_prefix=""
	local delete_ok=0
	local -a _tmp_finished_check=()

	clear
	show_space_overview

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      FINALIZE FINISHED SMC_ REPLACEMENTS    ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > This Finalizer Treats SMC_ Files As The Goal.${NC}"
	echo -e "${YELLOW} = = > OEM Material Is Backup/Archive Material.${NC}"
	echo -e "${YELLOW} = = > Working-Dir Originals May Be Deleted Only By Confirmation.${NC}"
	echo

	mapfile -t _tmp_finished_check < <(cleanup_collect_finished_targets)
	if (( ${#_tmp_finished_check[@]} == 0 )); then
		echo -e "${YELLOW} = = > No SMC_ Files Found. Nothing To Finalize.${NC}"
		echo
		pause
		return 0
	fi
	unset _tmp_finished_check

	echo
	echo -e "${CYAN}     = = > Rename Mode For Finished SMC_ Outputs:${NC}"
	echo -e "${YELLOW}      1) Remove SMC_ Prefix Entirely${NC}"
	echo -e "${YELLOW}      2) Replace SMC_ With My Custom Prefix"
	echo
	read -r -p "     Choice: ${NC}${GREEN}" reply
	echo -e "${NC}"
	echo

	reply="${reply//[[:space:]]/}"

	# ========================================================
	# TEN-KEY EXIT HOOK
	# ========================================================
	if is_exit_token "$reply"; then
		return 0
	fi

	case "$reply" in
		1)
			custom_prefix=""
			;;
		2)
			read -r -p " = = > Enter Custom Replacement Prefix (example: FINAL_): " custom_prefix
			echo
			;;
		*)
			echo -e "${REB} = = > Invalid Rename Mode.${NC}"
			pause
			return 1
			;;
	esac

	# --------------------------------------------------------
	# PROMPT OEM DISPOSITION NOW (BUT DO NOT EXECUTE YET)
	# --------------------------------------------------------
	if ! cleanup_handle_OEM_material; then
		pause
		return 0
	fi

	# --------------------------------------------------------
	# SAFETY GUARD:
	# Before destructive finalize steps, verify that every
	# finished SMC target still has its matching OEM backup.
	# --------------------------------------------------------
	if ! cleanup_verify_OEM_parity_for_finished_targets; then
		echo -e "${REB} = = > Finalize Blocked: OEM Parity Safety Check Failed.${NC}"
		echo -e "${YELLOW} = = > Resolve Missing OEM Backup(s) Before Re-Running Finalize.${NC}"
		echo
		pause
		return 0
	fi

	if cleanup_delete_replaced_working_originals "$custom_prefix"; then
		delete_ok=1
	else
		delete_ok=0
	fi

	if (( delete_ok == 0 )); then
		echo -e "${YELLOW} = = > Final Rename Promotion Stopped Because Originals Still Block Final Names.${NC}"
		echo -e "${YELLOW} = = > Delete Or Move Those Originals First, Then Re-Run This Finalizer.${NC}"
		echo
		pause
		return 0
	fi

	if cleanup_promote_finished_outputs "$custom_prefix"; then

		# --------------------------------------------------------
		# OEM DISPOSITION HAPPENS ONLY AFTER SUCCESSFUL PROMOTE
		# --------------------------------------------------------
		cleanup_execute_OEM_finalize_choice

		# --------------------------------------------------------
		# POST-PROMOTION CLEANUP: REKEY INTERMEDIATES
		# Only runs after confirmed successful promotion
		# --------------------------------------------------------
		mapfile -t rekey_targets < <(cleanup_collect_rekey_targets)

		if (( ${#rekey_targets[@]} > 0 )); then
			echo -e "${CYAN}================================================${NC}"
			echo -e "${CYAN}     REKEY INTERMEDIATE CLEANUP (POST-PROMOTE)  ${NC}"
			echo -e "${CYAN}================================================${NC}"
			echo

			cleanup_print_targets "REKEY Targets Queued" "${rekey_targets[@]}"

			if ask_yes_no " = = > Remove REKEY_* Intermediate Files? (y/n): "; then
				cleanup_remove_targets "${rekey_targets[@]}"
			else
				echo -e "${YELLOW} = = > REKEY Cleanup Skipped.${NC}"
				echo
			fi
		fi

	else
		echo -e "${YELLOW} = = > Promotion did not complete. REKEY files preserved.${NC}"
		echo
	fi

	pause
}

	while true; do
		clear
		show_space_overview
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}                    CLEANUP                     ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}"
		echo "     1) Show Cleanup Status"
		echo "     2) Archive CSV + Referenced Templates Only"
		echo "     3) Remove Working Template Artifacts (intro_template/*)"
		echo "     4) Strip Workflow Prefixes by Group"
		echo "     5) Remove Detection Map / CSV Artifacts"
		echo "     6) Remove Temp / Junk Files"
		echo "     7) Safe Cleanup Pass"
		echo "     8) Finalize Finished SMC Replacements"
		echo
		echo "     10-key exit > 0. (or q) Enter to quit"
		echo

		read -r -p "     Choice: ${NC}${GREEN}" cleanup_choice
		echo -e "${NC}"
		cleanup_choice="${cleanup_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$cleanup_choice"; then
    	    return 0
        fi

		case "$cleanup_choice" in
			1)
				cleanup_show_status
				;;

			2)
				run_csv_template_archive
				pause
				;;

			3)
				cleanup_templates
				;;

			4)
				finalize_strip_workflow_prefixes
				pause
				;;

			5)
				cleanup_detection_maps
				;;

			6)
				cleanup_temp_junk
				;;

			7)
				cleanup_run_all_safe
				;;

			8)
				cleanup_finalize_finished_replacements
				;;

			[Qq])
				return 0
				;;
			*)
				echo -e "${REB} = = > Invalid.${NC}"
				pause
				;;
		esac
	done
}

# ============================================================
#  CORE FUNCTIONS
# ============================================================


# ============================================================
# #MARKER: NOTES VIEWER (PAGER-AWARE DISPLAY)
# ============================================================
# PURPOSE:
# - Display long-form notes in a scrollable, readable way.
# - Use pager (less) if available, otherwise fallback to plain output.
#
# DESIGN:
# - Respects $PAGER if user has defined one
# - Defaults to "less" if not set
# - Uses -R so ANSI color codes remain visible
#
# WHY WE USE have_cmd():
# - Cleaner than repeating command -v checks
# - Keeps logic readable and consistent across script
#
# FALLBACK BEHAVIOR:
# - If pager is missing:
#     * Use plain cat output
#     * Follow with pause() so user can read content
#
inspect_show_notes() {
	local pager="${PAGER:-less}"

	# Check if pager exists using our helper
	if have_cmd "$pager"; then
		# Use pager with raw color support
		"$pager" -R <<'EOF'
	================================================
	q to EXIT  THE_FACTORY :: NOTES / EXPLAIN
	================================================

	[SECTION 1 — OVERVIEW]
	- THIS SPACE IS INTENTIONALLY RESERVED FOR LONG-FORM NOTES.
	- USE IT TO DOCUMENT WORKFLOW DECISIONS, GOTCHAS, AND PATTERNS.

	[SECTION 2 — WORKFLOW REMINDERS]
	- INSPECT → PREPARE → DETECT/TEMPLATE → SMARTGAP → TITLEZ → CLEANUP
	- PREFER REKEY WHEN KEYFRAMES ARE POOR.

	[SECTION 3 — COMMON PITFALLS]
	- COPY-CUT ON BAD KEYFRAMES = TEARING.
	- MIXED SOURCES (OEM + REKEY) CAN CAUSE MISMATCH BEHAVIOR.
	- TEMPLATES MUST MATCH EPISODE STRUCTURE.

	==== PILOT RUN (STRONGLY RECOMMENDED) REASONS

	BEFORE PROCESSING AN ENTIRE SEASON, RUN SMARTGAP ON 2–3 EPISODES FIRST.

	WHY:
	MOST TIMING ISSUES REPEAT CONSISTENTLY ACROSS EPISODES.

	HOWEVER, THIS DEPENDS ON HOW INTROS WERE DETECTED:

	- IF ONE INTRO_TEMPLATE WAS USED CONSISTENTLY
        - BEHAVIOR WILL REPEAT RELIABLY
	- IF MULTIPLE TEMPLATES WERE USED
        - EACH TEMPLATE MATCH MAY INTRODUCE SLIGHTLY DIFFERENT TIMING

	THIS IS A MULTI-KEY DETECTION SYSTEM:
	- EACH TEMPLATE IS EFFECTIVELY ITS OWN "TIMING PROFILE"
	- DIFFERENT KEYS = POTENTIALLY DIFFERENT OFFSETS, PADS, OR TRIM NEEDS

	BEST PRACTICE:
	- BUILD ONE STRONG, CLEAN TEMPLATE WHENEVER POSSIBLE
	- ONLY INTRODUCE ADDITIONAL TEMPLATES IF ABSOLUTELY NECESSARY
	- IF MULTI KEY ARE NEEDED, CREATE SLIGHT VARIANTS
        - WITH +/-0.5 SECONDS TIMING DIFFERENCES

	==== WHAT TO LOOK FOR DURING PILOT ====

	1) INTRO CUT QUALITY

	CHECK:
	- DOES THE INTRO START TOO EARLY OR TOO LATE?
	- DOES THE INTRO END TOO EARLY OR TOO LATE?

	IF ALL FILES SHOW THE SAME SHIFT:
	  → USE GLOBAL OFFSET +/- (MOVES ENTIRE INTRO WINDOW TOGETHER)

	IF ONLY THE START IS OFF:
	  → ADJUST PAD START +/-

	IF ONLY THE END IS OFF:
	  → ADJUST PAD END +/-

	2) PRE-TRIM (BEGINNING OF EPISODE)

	EXAMPLES:
	- MGM LION
	- STUDIO LOGOS
	- NETWORK BUMPERS
	- PREVIOULY ON

	ASK:
	- DO I WANT THIS REMOVED FROM EVERY EPISODE?
	- IS IT STILL PRESENT AFTER SMARTGAP?

	IF YES:
	  → INCREASE PRE-TRIM

	3) POST-TRIM (END OF EPISODE)

	EXAMPLES:
	- END CREDITS
	- PREVIEW SCENES
	- NEXT EPISODE TEASERS

	ASK:
	- ARE ENDINGS LONGER THAN DESIRED?
	- DO I WANT TIGHTER EPISODE ENDINGS?

	IF YES:
	  → INCREASE POST-TRIM

	4) WHY THIS WORKS

	- INTROFIND GIVES A **BEST-MATCH POSITION**, NOT A PERFECT CUT
	- FINE-TUNING IS EXPECTED, NOT A FAILURE
	- OFFSET AND PAD ARE FASTER AND MORE RELIABLE THAN ADDING MORE TEMPLATES
	- 1-SECOND KEYFRAMES (FROM NORMALIZATION) ALLOW CLEAN CUTS WITHOUT RE-ENCODING

	5) CONSISTENCY CHECK

	AFTER PILOT RUN, COMPARE RESULTS:

	IF ALL FILES BEHAVE THE SAME:
	  → APPLY ONE CORRECTION (OFFSET / PAD / TRIM)
	  → THEN RUN FULL BATCH

	IF RESULTS DIFFER:
	  → LIKELY CAUSES:
	     - DIFFERENT TEMPLATE MATCHED
	     - SOURCE FILES ARE NOT IDENTICAL CUTS (BROADCAST VS DVD VS RIP DIFFERENCES)

	IN THIS CASE:
	  → YOU MAY NEED:
	     - MULTIPLE TEMPLATES (GROUPED BY BEHAVIOR)
	     - OR MANUAL MAPPING VIA INTRO_MAP.CSV

	6) WHEN AUTOMATION BREAKS DOWN

	IF RESULTS ARE INCONSISTENT OR MESSY:

	YOU MAY NEED TO:
	- MANUALLY RECORD INTRO START/END PER EPISODE
	- ENTER THEM DIRECTLY (MANUAL MODE)
	- OR BUILD A PRECISE INTRO_MAP.CSV

	THIS IS NORMAL FOR:
	- MIXED SOURCE SETS
	- EDITED/TRIMMED RELEASES
	- MULTI-VERSION SEASONS

	==== RULE OF THUMB ====

	PRE-TRIM   → REMOVES CONTENT BEFORE THE EPISODE (LOGOS, BUMPERS)

	POST-TRIM  → REMOVES CONTENT AFTER THE EPISODE (CREDITS, PREVIEWS)

	OFFSET     → SHIFTS THE ENTIRE DETECTED INTRO WINDOW

	PAD START  → ADJUSTS ONLY THE BEGINNING EDGE OF THE INTRO

	PAD END    → ADJUSTS ONLY THE ENDING EDGE OF THE INTRO

	==== PRACTICAL STRATEGY ====

	1) NORMALIZE SOURCES (REKEY) FOR CLEAN KEYFRAMES
	2) BUILD ONE STRONG TEMPLATE
	3) RUN PILOT (2–3 EPISODES)
	4) FIX USING OFFSET / PAD / TRIM
	5) VERIFY VISUALLY
	6) RUN FULL BATCH

	AVOID:
	- OVERUSING MULTIPLE TEMPLATES TOO EARLY
	- CHASING PERFECTION WITH DETECTION INSTEAD OF USING TRIM CONTROLS

	[SECTION 4 — USER NOTES]
	- ADD YOUR OWN COMMENTARY HERE.
	- KEEP SECTIONS STRUCTURED FOR READABILITY.
 q to EXIT

	[END OF NOTES]
EOF
	else
		# Fallback: plain output (no scrolling)
		# This ensures the script still works on minimal systems
		cat <<'EOF'
    ================================================
                THE_FACTORY :: NOTES / EXPLAIN
    ================================================
EOF
		# Give user time to read
		pause
	fi
}

# ================================================================
# #MARKER: INSPECT LEGACY NON MKV WARNING
# ================================================================
inspect_warn_non_mkv_sources() {
	local -a non_mkv_targets=()
	local f ext

	shopt -s nullglob nocaseglob
	for f in *.lrv *.mkv *.mp4 *.avi *.mov *.mpg *.mpeg *.ts *.m4v *.ogv *.flv *.3gp *.divx *.webm *.xvid *.wmv; do
		[[ -f "$f" ]] || continue

		case "$f" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*|intro_template*|custom_cut*)
				continue
				;;
		esac

		ext="${f##*.}"
		ext="${ext,,}"

		[[ "$ext" == "mkv" ]] && continue

		non_mkv_targets+=("$f")
	done
	shopt -u nullglob nocaseglob

	(( ${#non_mkv_targets[@]} == 0 )) && return 0

	echo
	echo -e "${REB}================================================${NC}"
	echo -e "${REB}        NON-MKV SOURCE CONTAINERS DETECTED       ${NC}"
	echo -e "${REB}================================================${NC}"
	echo
	echo -e "${YE} = = > Factory Works Best When Working Sources Are MKV.${NC}"
	echo -e "${YE} = = > MP4 / AVI / MOV / TS / WEBM Containers May Limit Metadata, Subtitle, Or Stream Handling.${NC}"
	echo -e "${YE} = = > SmartCut / BARFIX / SUBTOX May Behave Differently On Non-MKV Sources.${NC}"
	echo
	echo -e "${CYAN} = = > Non-MKV Targets Found:${NC} ${YELLOW}${#non_mkv_targets[@]}${NC}"
	echo -e "${CYAN} = = > First Target:${NC} ${YELLOW}${non_mkv_targets[0]}${NC}"

	if (( ${#non_mkv_targets[@]} > 1 )); then
		echo -e "${CYAN} = = > Last Target:${NC} ${YELLOW}${non_mkv_targets[-1]}${NC}"
	fi

	echo
	echo -e "${YEB} = = > Recommended Action:${NC} ${YELLOW}Normalize / Remux Sources To MKV Before Surgery${NC}"
	echo

	if ask_yes_no " = = > Run Batch Normalize To MKV Now? (y/n or 1/2): "; then
		run_batch_normalize_to_mkv_tool
		return 0
	fi

	return 0
}

# =========================
# #MARKER: INSPECT / EXPLAIN MENU
# =========================
# PURPOSE:
# - Give a safe read-only folder inspection area.
# - Help the user understand current working state before running prep/cut tools.
# - Keep these actions non-destructive: inspect, explain, summarize, probe.
#
# DESIGN NOTES:
# - This menu intentionally reuses existing helpers where possible.
# - Keyframe probing uses the same probe/verdict helpers already used elsewhere.
# - One numbered slot is intentionally left as an empty banner/pause placeholder
#   for future user-authored commentary notes.
#
inspect_print_group() {
	local title="$1"
	shift
	local items=("$@")

	local count color status_label

	count=${#items[@]}

    # =========================================================
    # #MARKER: INSPECT GROUP COLOR + STATUS (SCALED THRESHOLDS)
    # =========================================================
    # COLOR / STATUS RULE:
    # - 0 items        -> GREEN  / CLEAN
    # - 1–10 items     -> GREEN  / NORMAL
    # - 11–20 items    -> YELLOW / NOTICE
    # - 21+ items      -> RED    / BUSY
    #
    if (( count == 0 )); then
    	color=$GREEN
    	status_label="CLEAN"
    elif (( count <= 10 )); then
    	color=$GREEN
    	status_label="NORMAL"
    elif (( count <= 20 )); then
    	color=$YELLOW
    	status_label="NOTICE"
    else
    	color=$RED
    	status_label="BUSY"
    fi

	echo -e "${CYAN} = = > ${title}:${NC} ${color}${count}${NC} ${color}[${status_label}]${NC}"

	if (( count > 0 )); then
		local f
		for f in "${items[@]}"; do
			echo -e "  - ${color}$f${NC}"
		done
	fi

	echo
}

inspect_show_folder_snapshot() {
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          INSPECT :: FOLDER SNAPSHOT            ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	inspect_warn_non_mkv_sources

	ui_show_folder_state_snapshot

	echo

	# ------------------------------------------------
	# Skip redundant pause if AVI normalize handoff
	# already occurred inside warning helper.
	# ------------------------------------------------
	if [[ $? -eq 0 ]]; then
		return 0
	fi

	pause
}

inspect_show_file_groups() {
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}           INSPECT :: FILE GROUPS               ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	shopt -s nullglob nocaseglob

	local -a all_videos=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	local -a smc_files=(SMC_*)
	local -a rekey_files=(REKEY_*)
	local -a barfix_files=(BARFIX_*)
	local -a subpacked_files=(SUBPACKED_* SUBTOX_*)
	local -a csv_files=(*.csv)

	local -a plain_targets=()
	local f

	for f in "${all_videos[@]}"; do
		[[ -f "$f" ]] || continue

		case "${f^^}" in
			SMC_*|REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*)
				continue
				;;
		esac

		[[ "$f" == intro_template* ]] && continue
		[[ "$f" == custom_cut* ]] && continue

		plain_targets+=("$f")
	done

	shopt -u nullglob nocaseglob

	echo -e "${YELLOW} = = > This View Lists Files By Role.${NC}"
	echo -e "${CYAN} = = > Working Dir Shows Active Files; OEM/ Holds Archived Prior Stages.${NC}"
	echo

	inspect_print_group "Likely source / unprocessed working targets" "${plain_targets[@]}"
	inspect_print_group "SMC active outputs" "${smc_files[@]}"
	inspect_print_group "REKEY active outputs" "${rekey_files[@]}"
	inspect_print_group "BARFIX active outputs" "${barfix_files[@]}"
	inspect_print_group "SUBTOX / SUBPACKED outputs" "${subpacked_files[@]}"
	inspect_print_group "CSV / map files" "${csv_files[@]}"

	if [[ -d OEM ]]; then
		local -a oem_runs=()
		local latest_run

		while IFS= read -r f; do
			oem_runs+=("$f")
		done < <(find OEM -maxdepth 1 -type d -name 'run_*' -printf '%f\n' 2>/dev/null | sort)

		if (( ${#oem_runs[@]} > 0 )); then
			latest_run="${oem_runs[$((${#oem_runs[@]} - 1))]}"
		else
			latest_run=""
		fi

		echo
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}             OEM ARCHIVE GROUPS                 ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${CYAN} = = > OEM Run Folders:${NC} ${YELLOW}${#oem_runs[@]}${NC}"
		echo -e "${CYAN} = = > Latest Run:${NC} ${YELLOW}${latest_run:-none}${NC}"

		if [[ -n "${latest_run:-}" ]]; then
			inspect_print_group "Latest OEM/SMC archived inputs" OEM/"$latest_run"/SMC/*
			inspect_print_group "Latest OEM/REKEY archived inputs" OEM/"$latest_run"/REKEY/*
			inspect_print_group "Latest OEM/BARFIX archived inputs" OEM/"$latest_run"/BARFIX/*
			inspect_print_group "Latest OEM/SUBTOX archived inputs" OEM/"$latest_run"/SUBTOX/*
		fi
	else
		echo
		echo -e "${YELLOW} = = > OEM/ Archive Directory Not Present${NC}"
	fi

	pause
}

inspect_show_artifact_presence() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}        INSPECT :: TEMPLATE / CSV STATE         ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo

    shopt -s nullglob nocaseglob
    local -a template_files_root=(intro_template*.mkv)
    local -a template_files_dir=()
    local -a csv_files=(*.csv)
    shopt -u nullglob nocaseglob

    if [[ -d intro_template ]]; then
        shopt -s nullglob nocaseglob
        template_files_dir=(intro_template/*.mkv)
        shopt -u nullglob nocaseglob
    fi

    echo -e "${CYAN} = = > Template Directory:${NC} $([[ -d intro_template ]] && echo "Present" || echo "Missing")"
    echo -e "${CYAN} = = > Intro Map File:${NC} $([[ -f "$INTRO_MAP" ]] && echo "Present" || echo "Missing")"
    echo

    inspect_print_group "Templates In ./intro_template/" "${template_files_dir[@]}"
    inspect_print_group "Templates In Current Folder" "${template_files_root[@]}"
    inspect_print_group "CSV Files In Current Folder" "${csv_files[@]}"

    if [[ -f "$INTRO_MAP" ]]; then
        echo -e "${CYAN} = = > ${INTRO_MAP} Preview:${NC}${GREEN}"
        head -n 10 "$INTRO_MAP" 2>/dev/null || true
        echo -e "${NC}"
    fi

    pause
}

inspect_run_keyframe_probe() {
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      INSPECT :: KEYFRAME SUITABILITY PROBE     ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	shopt -s nullglob nocaseglob
	local -a probe_files=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	if ((${#probe_files[@]}==0)); then
		echo -e "${RE} = = > No Video Files Found.${NC}"
		pause
		return 0
	fi

	echo -e "${CYAN} = = > KEYFRAME SUITABILITY CHECK${NC}"
	echo -e "${CYAN} = = > Select File For Analysis:${NC}"
	local probe_target pick

	while true; do
		echo
		echo -e "${CYAN} = = > Select File:${NC} ${YELLOW}[number | q=cancel]${NC}${GREEN}"
		echo

		select probe_target in "${probe_files[@]}"; do
			pick="${REPLY//[[:space:]]/}"
        echo -e "${NC}"

			# ========================================================
			# TEN-KEY EXIT HOOK
			# ========================================================
			if is_exit_token "$pick"; then
				echo -e "${YELLOW} = = > Keyframe Check Cancelled.${NC}"
				pause
				return 0
			fi

			if [[ -n "${probe_target:-}" ]]; then
				echo -e "${GREEN} = = > Selected:${NC} ${BWHITE}$probe_target${NC}"
				break 2
			fi

			echo -e "${RE} = = > Invalid Selection. Enter A Listed Number, or q to cancel.${NC}"
			break
		done
	done

	echo
	if run_with_progress "Probing keyframe cut-friendliness: $(basename "$probe_target")" \
		probe_keyframe_suitability "$probe_target"; then
		:
	else
		echo
		echo -e "${REB} = = > Keyframe Probe Failed.${NC}"
	fi
	echo

	pause
}

run_inspect() {
    while true; do
        clear
        echo -e "${RED}================================================${NC}"
        echo -e "${BWHITE}================================================${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo -e "${RED}            INSPECT / EXPLAIN FOLDER STATE      ${NC}"
        echo -e "${BWHITE}================================================${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo -e "${RED}================================================${NC}"

        echo -e "${YELLOW}"
        echo "     1) Folder Snapshot"
        echo "     2) Show File Groups"
        echo "     3) Show Template / CSV / intro-map State"
        echo "     4) Probes / Diagnostics"
        echo "     5) Working Notes, New Factory Methods Smartcut SMC Workflow"
        echo "     6) Help File, Old Factory Methods, Best Practices Back Then"
        echo
        echo "     10-key exit > 0. (or q) Enter to quit"
        echo

        read -r -p "     Choice: ${NC}${GREEN}" inspect_choice
        echo -e "${NC}"
        inspect_choice="${inspect_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$inspect_choice"; then
    	    return 0
        fi

        case "$inspect_choice" in
            1)
                inspect_show_folder_snapshot
                ;;
            2)
                inspect_show_file_groups
                ;;
            3)
                inspect_show_artifact_presence
                ;;
            4)
                run_probes_menu
                ;;
            5)
                clear
                echo -e "${CYAN}================================================${NC}"
                echo -e "${CYAN}     INSPECT :: CURRENT WORKFLOW EXPLANATION    ${NC}"
                echo -e "${CYAN}================================================${NC}${GREEN}"
                echo
				echo " = = > Current broad state:"
				echo " = = >  - SmartCut is now the primary workflow engine."
				echo " = = >  - OEM/ archive staging is active for non-destructive processing."
				echo " = = >  - SMC_ outputs are now the primary finished cut products."
				echo " = = >  - Barfix Lite can auto-run after successful SmartCut operations."
				echo " = = >  - Intro/Outro detection supports adjustable scan depth, anchors, and step size."
				echo " = = >  - REKEY preference logic and normalized-source workflows remain active."
				echo
				echo " = = > Current workflow philosophy:"
				echo " = = >  - Working directory should contain current active products only."
				echo " = = >  - OEM/ stores prior-stage files and protected originals by run folder."
				echo " = = >  - Prefixes identify current workflow stage, not permanent identity."
				echo " = = >  - Finalize/Cleanup removes workflow noise after verification."
				echo
				echo " = = > Typical workflow:"
				echo " = = >  - Inspect folder state / grouped files"
				echo " = = >  - Prepare / normalize sources as needed"
				echo " = = >  - Build intro/outro templates"
				echo " = = >  - Detect intros/outros into CSV maps"
				echo " = = >  - Run SmartCut batch or manual plans"
				echo " = = >  - Optional Barfix Lite auto-applies playback/title defaults"
				echo " = = >  - Review outputs"
				echo " = = >  - Cleanup / finalize"
                echo -e "${NC}"
                pause
                ;;
            6)
                inspect_show_notes
                ;;
            [Qq])
                return 0
                ;;
            *)
                echo -e "${REB} = = > Invalid.${NC}"
                pause
                ;;
        esac
    done
}

# =========================
# #MARKER: PREPARE SOURCES MENU
# =========================
# PURPOSE:
# - Gather all "pre-cut" source conditioning tasks under one workflow stage.
# - Keep prep actions focused on source safety, normalization, and defaults.
# - Reuse existing engines where they already work well.
#
# SCOPE:
# - OEM backup copies
# - Batch normalization into REKEY_*.mkv
# - REKEY preference toggle for this shell session
# - BARFIX handoff for title/playback defaults when wanted
# - One combined prep pass for common setup flow
#
# IMPORTANT:
# - OEM backup here means a sidecar preserved copy named OEM_<originalname>.
# - This helper intentionally skips generated derivatives such as REKEY_, BARFIX_,
#   SMC_, SUBPACKED_, templates, and existing OEM_ files.
#
prepare_collect_source_candidates() {
	# OUTPUT CONTRACT:
	# - Prints one eligible source file per line.
	# - Intended for mapfile/readarray callers.
	#
	# ELIGIBLE:
	# - Plain source-ish videos in the current folder
	#
	# SKIPPED:
	# - OEM_ backups
	# - REKEY_ rebuilds
	# - SMC_ outputs
	# - BARFIX_ outputs
	# - SUBPACKED_ outputs
	# - intro_template artifacts
	#
	# IMPORTANT:
	# - THIS FUNCTION MUST STAY MACHINE-SAFE.
	# - Do NOT inject color codes here.
	# - mapfile callers (like OEM backup creation) consume this output as
	#   real filenames, not display text.
	#
	shopt -s nullglob nocaseglob
	local -a files=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	local f
	for f in "${files[@]}"; do
		[[ "$f" =~ ^OEM_ ]] && continue
		[[ "$f" =~ ^REKEY_ ]] && continue
		[[ "$f" =~ ^(SMC_|PILOT_SMC_) ]] && continue
		[[ "$f" =~ ^BARFIX_ ]] && continue
		[[ "$f" =~ ^SUBPACKED_ ]] && continue
		[[ "$f" == intro_template* ]] && continue
		[[ "$f" == custom_cut* ]] && continue
		[[ "$f" =~ ^SMC_ ]] && continue
		printf '%s\n' "$f"
	done
}

prepare_show_candidates() {
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}         PREPARE SOURCES :: SOURCE CANDIDATES   ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	local -a targets=()
	mapfile -t targets < <(prepare_collect_source_candidates)

	if ((${#targets[@]}==0)); then
		echo -e "${YELLOW} = = > No Eligible Source-Style Video Files Found.${NC}"
		echo
		pause
		return 0
	fi

	echo -e "${CYAN} = = > Eligible Working Sources:${NC}"
	printf "${GREEN}   - %s${NC}\n" "${GREEN}${targets[@]}${NC}"
	echo
	echo -e "${CYAN} = = > Count:${NC}${GREEN} ${#targets[@]}${NC}"
	echo
	pause
}

prepare_make_OEM_backups() {
    # =========================
    # #MARKER: OEM BACKUP PREP
    # =========================
    # PURPOSE:
    # - Create preserved copies of current source-style files
    # - Store them inside ./OEM/
    # - Prefix each preserved copy with OEM_
    #
    # RESULT EXAMPLE:
    #   source file in working dir:
    #       ./Episode01.mkv
    #
    #   preserved OEM copy:
    #       ./OEM/OEM_Episode01.mkv
    #
    # NOTES:
    # - Originals stay in place in working dir
    # - Existing OEM copies are skipped
    # - This is a copy operation, not a move
    #
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}          PREPARE SOURCES :: OEM BACKUPS        ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo

    show_working_folder_and_disk_free
    echo

    local -a targets=()
    local f backup made_count skip_count fail_count

    mapfile -t targets < <(prepare_collect_source_candidates)

    if ((${#targets[@]}==0)); then
        echo -e "${YELLOW} = = > No Eligible Source-Style Video Files Found.${NC}"
        echo
        pause
        return 0
    fi

    # =========================
    # #MARKER: OEM BACKUP DIR ENSURE
    # =========================
    # PURPOSE:
    # - OEM preserved copies must live in ./OEM/
    # - Create that directory before the copy pass begins
    #
    mkdir -p OEM

    echo -e "${YELLOW}This Creates Preserved Sidecar Copies In ./OEM As OEM_<filename>.${NC}"
    echo -e "${YELLOW}Existing OEM_ Copies In ./OEM Are Skipped, Not Overwritten.${NC}"
    echo
    if ! ask_yes_no "${YELLOW}Create OEM Backups For ${#targets[@]} Eligible File(s)? (y/n): ${NC}"; then
        echo -e "${YELLOW} = = > OEM Backup Pass Cancelled.${NC}"
        pause
        return 0
    fi

    made_count=0
    skip_count=0
    fail_count=0

    # =========================
    # #MARKER: OEM BACKUP COPY LOOP
    # =========================
    # PURPOSE:
    # - Copy each eligible source into ./OEM/
    # - Add OEM_ prefix while preserving original working file
    #
    # WHY run_with_progress LIVES HERE:
    # - OEM copy can take a while on large camera/bodycam files
    # - We want a visible "working" heartbeat during each copy
    # - We still keep per-file OK / FAIL / SKIP reporting afterward
    #
    for f in "${targets[@]}"; do
        backup="OEM/OEM_$(basename "$f")"

        if [[ -e "$backup" ]]; then
            echo -e "${YE} = = > [SKIP]${NC} ${CYAN}$backup${NC} ${YELLOW}Already Exists${NC}"
            ((skip_count+=1)) || :
            continue
        fi

        # cp -a preserves timestamps/mode where possible and avoids altering
        # the original source content.
        if run_with_progress "OEM Backup Copy: $(basename "$f")" cp -a -- "$f" "$backup"; then
            echo -e "${GR} = = > [OK]${NC} ${GREEN}$f${NC} ${CYAN}->${NC} ${GREEN}$backup${NC}"
            ((made_count+=1)) || :
        else
            echo -e "${REB} = = > [FAIL]${NC} ${GREEN}$f${NC}"
            ((fail_count+=1)) || :
        fi
    done

    # =========================
    # #MARKER: OEM BACKUP SUMMARY
    # =========================
    echo
    echo -e "${CYAN} = = > OEM Backups Created:${NC} $made_count"
    echo -e "${CYAN} = = > Existing OEM Backups Skipped:${NC} $skip_count"
    echo -e "${CYAN} = = > Backup Failures:${NC} $fail_count"
    echo
    pause
    return 0
}

prepare_set_rekey_preference() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}      PREPARE SOURCES :: REKEY PREFERENCE       ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo -e "${YEB}====THIS AREA IS NOT PART OF WORKFLOW ANYMORE====${NC}"
	echo -e "${YEB}====SO UNLESS YOU REALLY MEANT TO BE HERE====${NC}"
	echo -e "${YEB}====GO BACK AND USE SMARTCUT ENABLED OPTIONS====${NC}"
    echo

    echo -e "${CYAN} = = > Current Prefer_Rekey State:${NC} ${prefer_rekey:-0}"
    echo
    echo -e "${YELLOW}"
    echo "     1) Enable REKEY Preference For This Shell Session"
    echo "     2) Disable REKEY Preference For This Shell Session"
    echo "     3) Use Guided Normalize-First Prompt"
    echo "     4) Do All-Over REKEY Auth System Refresh"
    echo
    echo "     10-key exit > 0. (or q) Enter to quit"
    echo

    read -r -p "     Choice: ${NC}${GREEN}" pref_choice
    echo -e "${NC}"
    pref_choice="${pref_choice//[[:space:]]/}"

    # ========================================================
    # TEN-KEY EXIT HOOK
    # ========================================================
    if is_exit_token "$pref_choice"; then
    	return 0
    fi

    case "$pref_choice" in
        1)
            prefer_rekey="1"
            echo -e "${GREEN} REKEY Preference Enabled For This Shell Session.${NC}"
            echo -e "${CYAN} Existing Valid REKEY Files Will Be Preferred When Applicable.${NC}"
            ;;
        2)
            prefer_rekey="0"
            echo -e "${YELLOW} = = > REKEY Preference disabled For This Shell Session.${NC}"
            echo -e "${YEB} = = > WARNING: REKEY Preference Is OFF.${NC}"
            echo -e "${YELLOW} = = > Cutting From Originals Is Discouraged And May Produce Bad Cuts.${NC}"
            echo -e "${CYAN} = = > Original Source Files Remain The Preferred Working Source.${NC}"
            ;;
        3)
            prompt_normalize_first_workflow
            ;;
        4)
            refresh_rekey_auth_system
            return 0
            ;;
        [Qq])
            return 0
            ;;
        *)
            echo -e "${REB} = = > Invalid.${NC}"
            ;;
    esac

    echo
    pause
}

prepare_run_batch_normalizer_wrapper() {
    clear
    echo -e "     ${CYAN}================================================${NC}"
    echo -e "     ${CYAN}      PREPARE SOURCES :: BATCH NORMALIZER       ${NC}"
    echo -e "     ${CYAN}================================================${NC}"
    echo -e "     ${CYAN} This Rebuilds Eligible Source Videos Into REKEY_*.mkv Outputs.${NC}"
    echo -e "     ${YEB} = = >${NC}${YELLOW}Be Mindful Of Free Space Before Starting.${NC}${YEB}< = = ${NC}"
    echo -e "     ${YEB} = = >${NC}${YELLOW}This Will Double Folder Space.${NC}${YEB}< = = ${NC}"
    run_batch_normalizer
}

prepare_run_barfix_wrapper() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}    PREPARE SOURCES :: BARFIX / PLAYBACK HANDOFF${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${CYAN} = = > Handing Off Into BARFIX Title/Playback Tools...${NC}"
    echo
    pause
    run_barfix
}

prepare_run_combined_pass() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}      PREPARE SOURCES :: COMBINED PREP PASS     ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${YELLOW}"
    echo " = = > This combined pass does the following in order:"
    echo " = = >  - Create missing OEM backups for eligible source files"
    echo " = = >  - Run Batch Normalizer to build REKEY files"
    echo " = = >  - Verify OEM + REKEY parity for each source target"
    echo " = = >  - Offer controlled delete handoff for verified originals"
    echo " = = >  - Enable REKEY preference for this shell session"
    echo " = = >  - Offer BARFIX handoff at the end"
    echo

	if ! ask_yes_no " = = > Run Combined Prep Pass Now? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Combined Prep Pass Cancelled.${NC}"
		pause
		return 0
	fi

    prepare_make_OEM_backups
    prepare_run_batch_normalizer_wrapper
    prepare_offer_delete_originals_after_verified_rekey

    prefer_rekey="0"

    clear
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}        COMBINED PREP PASS CORE STEPS DONE      ${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo
    echo -e "${CYAN}REKEY Preference Is Now Enabled For This Shell Session.${NC}"
    echo

	if ask_yes_no " = = > Open BARFIX now? (y/n or 1/2): "; then
		run_barfix
	fi
}

run_prepare_sources() {
    while true; do
        clear
        echo -e "${CYAN}================================================${NC}"
        echo -e "${CYAN}                PREPARE SOURCES                 ${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo
        echo -e "${CYAN} = = > Current REKEY Preference:${NC} ${prefer_rekey:-0}"
        echo
        echo -e "${YELLOW}"
        echo "     1) Show Eligible Source Candidates"
        echo "     2) Create OEM Backup Copies"
        echo "     3) Batch Normalize Sources To REKEY"
        echo "     4) REKEY Preference / Normalize-First Controls"
        echo "     5) BARFIX Title + Playback Tools"
        echo "     6) Combined Prep Pass"
        echo
        echo "     10-key exit > 0. (or q) Enter to quit${NC}"
        echo

		prompt_menu_choice "      Choice: " prep_choice

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$prep_choice"; then
    	    return 0
        fi

        case "$prep_choice" in
            1)
                prepare_show_candidates
                ;;
            2)
                prepare_make_OEM_backups
                ;;
            3)
                prepare_run_batch_normalizer_wrapper
                ;;
            4)
                prepare_set_rekey_preference
                ;;
            5)
                prepare_run_barfix_wrapper
                ;;
            6)
                prepare_run_combined_pass
                ;;
            [Qq])
                return 0
                ;;
            *)
                echo -e "${REB} = = > Invalid.${NC}"
                pause
                ;;
        esac
    done
}

# ================================================================
# #MARKER: PREEN FILENAME / LINE RESCUE + SxxExx INJECTOR
# ================================================================
# PURPOSE:
# - Give messy filename piles and dirty text/CSV lists a preview-first rescue lane.
# - Remove / keep filename segments.
# - Remove / keep filename characters.
# - Insert text by character position or segment position.
# - Insert sequential SxxExx tags into filenames after user confirms file order.
# - Open .txt / .csv files and preen them line-by-line.
# - Remove blank lines from title lists.
# - Clean copied title/list garbage before episodes.csv work.
# - Insert sequential SxxExx tags at the beginning of text/CSV lines.
#
# FACTORY FLOOR NOTE:
# PREEN is the comb before the haircut.
# It does not detox, title-case, or get clever behind your back.
# It lines up the feathers, shows you the mirror, then asks before touching anything.
#
# RULES:
# - Filename mode protects extensions.
# - Line mode writes a .preen.bak backup before changing a file.
# - Preview is mandatory.
# - Existing destination filenames are skipped.
# - No automatic rename or line rewrite happens without user approval.
# - CSV files are handled by Line Preen, not filename-target Preen.
# ================================================================

preen_collect_targets() {
	local -n _out=$1
	local f

	_out=()

	shopt -s nullglob nocaseglob
	for f in *.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv,srt,ass,ssa,txt}; do
		[[ -f "$f" ]] || continue

		case "$f" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*|RESCUE_*|PILOT_RESCUE_*|AUDIOFIX_*|TIMEPRESS_*|AUDIOLEVEL_*|intro_template*|custom_cut*)
				continue
				;;
		esac

		_out+=("$f")
	done
	shopt -u nocaseglob
	shopt -s nullglob
}

preen_split_segments() {
	local s="$1"
	s="${s//_/ }"
	printf '%s\n' "$s"
}

preen_join_segments() {
	local -a arr=("$@")
	local out=""
	local x

	for x in "${arr[@]}"; do
		[[ -z "$x" ]] && continue

		if [[ -z "$out" ]]; then
			out="$x"
		else
			out="${out}_${x}"
		fi
	done

	printf '%s\n' "$out"
}

preen_preview_and_apply() {
	local -n old_ref=$1
	local -n new_ref=$2
	local i changed=0

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                 PREEN PREVIEW                  ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	if (( ${#old_ref[@]} == 0 )); then
		echo -e "${YELLOW} = = > No Changes Proposed.${NC}"
		pause
		return 0
	fi

	for i in "${!old_ref[@]}"; do
		echo -e "${YELLOW}[$((i+1))]${NC} ${GREEN}${old_ref[$i]}${NC}"
		echo -e "${CYAN}    -->${NC} ${YELLOW}${new_ref[$i]}${NC}"
	done

	echo
	echo -e "${CYAN} = = > Proposed Renames:${NC} ${YELLOW}${#old_ref[@]}${NC}"
	echo

	if ! ask_yes_no " = = > Apply These Renames? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Cancelled. No Files Changed.${NC}"
		pause
		return 0
	fi

	for i in "${!old_ref[@]}"; do
		if [[ -e "${new_ref[$i]}" ]]; then
			echo -e "${RE} = = > [SKIP EXISTS]${NC} ${YELLOW}${new_ref[$i]}${NC}"
			continue
		fi

		mv -- "${old_ref[$i]}" "${new_ref[$i]}"
		echo -e "${GREEN} = = > [RENAMED]${NC} ${YELLOW}${old_ref[$i]}${NC} ${CYAN}-->${NC} ${GREEN}${new_ref[$i]}${NC}"
		((changed+=1)) || :
	done

	echo
	echo -e "${GREEN} = = > PREEN Complete. Renamed: $changed${NC}"
	pause
}

run_line_preen() {
	local file choice val marker insert_text out_file backup_file
	local -a lines=()
	local -a old_lines=()
	local -a new_lines=()
	local line newline i

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              TEXT / CSV LINE PREEN             ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	shopt -s nullglob nocaseglob
	local -a text_files=( *.txt *.csv )
	shopt -u nullglob nocaseglob

	if (( ${#text_files[@]} == 0 )); then
		echo -e "${YELLOW} = = > No .txt / .csv Files Found.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${CYAN} = = > Available Text Files:${NC}"
	echo

	local i
	for i in "${!text_files[@]}"; do
		echo -e "${YELLOW}$((i+1)))${NC} ${GREEN}${text_files[$i]}${NC}"
	done

	echo
	echo -ne "${YELLOW} = = > Choose File Number [0.=return]: ${NC}${GREEN}"
	read -r file_choice
	echo -e "${NC}"

	is_exit_token "$file_choice" && return 0

	[[ "$file_choice" =~ ^[0-9]+$ ]] || {
		echo -e "${RED} = = > Invalid Selection.${NC}"
		pause
		return 0
	}

	(( file_choice >= 1 && file_choice <= ${#text_files[@]} )) || {
		echo -e "${RED} = = > Invalid Selection.${NC}"
		pause
		return 0
	}

	file="${text_files[$((file_choice-1))]}"

	mapfile -t lines < "$file"

	echo
	echo -e "${YELLOW}  1) Remove Blank Lines${NC}"
	echo -e "${YELLOW}  2) Remove X characters from BEGINNING${NC}"
	echo -e "${YELLOW}  3) Remove X characters from END${NC}"
	echo -e "${YELLOW}  4) Remove before typed marker${NC}"
	echo -e "${YELLOW}  5) Remove after typed marker${NC}"
	echo -e "${YELLOW}  6) Insert Sequential SxxExx At Line Beginning${NC}"
	echo

	echo -ne "${YELLOW} = = > Choose:${NC} ${GREEN}"
	read -r choice
	echo -e "${NC}"

	is_exit_token "$choice" && return 0

	case "$choice" in
		2|3)
			echo -ne "${YELLOW} = = > Enter Count:${NC} ${GREEN}"
			read -r val
			echo -e "${NC}"
			[[ "$val" =~ ^[0-9]+$ ]] || { echo -e "${RED}Invalid number.${NC}"; pause; return 0; }
			;;
		4|5)
			echo -ne "${YELLOW} = = > Enter Marker Text:${NC} ${GREEN}"
			read -r marker
			echo -e "${NC}"
			[[ -n "$marker" ]] || return 0
			;;
	esac

	if [[ "$choice" == "6" ]]; then
		local season ep_start current_ep tag

		echo -ne "${YELLOW} = = > Season Number:${NC} ${GREEN}"
		read -r season
		echo -e "${NC}"

		echo -ne "${YELLOW} = = > Starting Episode Number:${NC} ${GREEN}"
		read -r ep_start
		echo -e "${NC}"

		[[ "$season" =~ ^[0-9]+$ && "$ep_start" =~ ^[0-9]+$ ]] || {
			echo -e "${RED}Invalid season / episode.${NC}"
			pause
			return 0
		}

		current_ep="$ep_start"
	fi

	old_lines=()
	new_lines=()

	for line in "${lines[@]}"; do
		newline="$line"

		case "$choice" in
			1)
				[[ -z "${line//[[:space:]]/}" ]] && continue
				;;
			2)
				(( val >= ${#line} )) && newline="" || newline="${line:val}"
				;;
			3)
				(( val >= ${#line} )) && newline="" || newline="${line:0:${#line}-val}"
				;;
			4)
				[[ "$line" == *"$marker"* ]] && newline="${line#*"$marker"}"
				;;
			5)
				[[ "$line" == *"$marker"* ]] && newline="${line%%"$marker"*}"
				;;
			6)
				[[ -z "${line//[[:space:]]/}" ]] && continue
				printf -v tag 'S%02dE%02d' "$((10#$season))" "$((10#$current_ep))"
				newline="${tag},${line}"
				((current_ep+=1)) || :
				;;
			*)
				echo -e "${RED}Invalid selection.${NC}"
				pause
				return 0
				;;
		esac

		old_lines+=("$line")
		new_lines+=("$newline")
	done

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}               LINE PREEN PREVIEW               ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	for i in "${!new_lines[@]}"; do
		echo -e "${YELLOW}[$((i+1))]${NC} ${GREEN}${old_lines[$i]}${NC}"
		echo -e "${CYAN}    -->${NC} ${YELLOW}${new_lines[$i]}${NC}"
	done

	echo
	if ! ask_yes_no " = = > Apply Line Preen To File? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Cancelled. No File Changed.${NC}"
		pause
		return 0
	fi

	backup_file="${file}.preen.bak"
	cp -f -- "$file" "$backup_file"

	out_file="$file"
	: > "$out_file"

	for line in "${new_lines[@]}"; do
		printf '%s\n' "$line" >> "$out_file"
	done

	echo
	echo -e "${GREEN} = = > Line Preen Complete:${NC} ${YELLOW}$file${NC}"
	echo -e "${CYAN} = = > Backup:${NC} ${YELLOW}$backup_file${NC}"
	echo
	pause
}

run_preen() {
	local choice val marker insert_text
	local -a targets=()
	local -a old_names=()
	local -a new_names=()

	preen_collect_targets targets

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN} = = > PREEN RULES:${NC}"
		echo -e "${YELLOW}     - All Math Operates ONLY On Filename Stem (Before .ext)${NC}"
		echo -e "${YELLOW}     - Extensions Are Protected And Never Counted${NC}"
		echo -e "${YELLOW}     - Underscores Are Treated Like Segment Dividers${NC}"
		echo -e "${YELLOW}     - Character Removal Is Literal / Exact Math${NC}"
		echo -e "${YELLOW}     - Preview Happens Before Anything Gets Renamed${NC}"
		echo
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}              FILENAME PREENING TOOL             ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo -e "${YELLOW} = = > When filenames need their feathers lined up, you preen.${NC}"
		echo
		echo -e "${CYAN} = = > Targets Found:${NC} ${YELLOW}${#targets[@]}${NC}"
		echo
		echo -e "${YELLOW}  1) Remove X segments from BEGINNING${NC}"
		echo -e "${YELLOW}  2) Remove X segments from END${NC}"
		echo -e "${YELLOW}  3) Keep X segments from BEGINNING${NC}"
		echo -e "${YELLOW}  4) Keep X segments from END${NC}"
		echo -e "${YELLOW}  5) Remove X characters from BEGINNING${NC}"
		echo -e "${YELLOW}  6) Remove X characters from END${NC}"
		echo -e "${YELLOW}  7) Remove before typed marker${NC}"
		echo -e "${YELLOW}  8) Remove after typed marker${NC}"
		echo -e "${YELLOW}  9) Insert text at character position${NC}"
		echo -e "${YELLOW} 10) Insert text before segment number${NC}"
		echo -e "${YELLOW} 11) Insert text after segment number${NC}"
		echo -e "${YELLOW} 12) Insert Sequential SxxExx Tags${NC}"
		echo -e "${YELLOW} 13) Text / CSV Line Preen${NC}"
		echo
		echo -e "${YELLOW}  0.) Return / Quit${NC}"
		echo

		prompt_menu_choice " = = > Choose: " choice

		is_exit_token "$choice" && return 0

		old_names=()
		new_names=()

		# ========================================================
		# SEQUENTIAL SxxExx INSERT MODE
		# ========================================================
		if [[ "$choice" == "12" ]]; then
			local season ep_start insert_mode insert_pos tag order_mode
			local ordered_input current_ep f stem ext newstem
			local -a ordered_targets=()
			local -a idx=()

			echo
			echo -e "${CYAN}================================================${NC}"
			echo -e "${CYAN}         SEQUENTIAL SxxExx INSERT MODE          ${NC}"
			echo -e "${CYAN}================================================${NC}"
			echo

			local i
			for i in "${!targets[@]}"; do
				echo -e "${YELLOW}$((i+1)))${NC} ${GREEN}${targets[$i]}${NC}"
			done

			echo
			echo -e "${CYAN} = = > Episode Order Source:${NC}"
			echo -e "${YELLOW}     1) Use displayed order${NC}"
			echo -e "${YELLOW}     2) Enter custom true episode order${NC}"
			echo

			prompt_menu_choice " = = > Choose Order Mode [1-2 | 0.=return]: " order_mode

			is_exit_token "$order_mode" && continue

			case "$order_mode" in
				1)
					ordered_targets=("${targets[@]}")
					;;
				2)
					echo
					echo -e "${CYAN} = = > Enter files in TRUE episode order.${NC}"
					echo -e "${CYAN} = = > Example:${NC} ${YELLOW}1,5,14,6,8,9${NC}"
					echo

					prompt_read " = = > File Order: " ordered_input

					is_exit_token "$ordered_input" && continue

					ordered_input="${ordered_input// /,}"

					local old_ifs="$IFS"
					IFS=','
					read -r -a idx <<< "$ordered_input"
					IFS="$old_ifs"

					for i in "${idx[@]}"; do
						i="${i//[[:space:]]/}"

						[[ "$i" =~ ^[0-9]+$ ]] || continue
						(( i >= 1 && i <= ${#targets[@]} )) || continue

						ordered_targets+=("${targets[$((i-1))]}")
					done
					;;
				*)
					echo -e "${RE} = = > Invalid Order Mode.${NC}"
					pause
					continue
					;;
			esac

			if (( ${#ordered_targets[@]} == 0 )); then
				echo -e "${RE} = = > No Valid Ordered Targets Selected.${NC}"
				pause
				continue
			fi

			prompt_read " = = > Season Number: " season

			is_exit_token "$season" && continue
			[[ "$season" =~ ^[0-9]+$ ]] || { echo -e "${RE} = = > Invalid season.${NC}"; pause; continue; }

			prompt_read " = = > Starting Episode Number: " ep_start

			is_exit_token "$ep_start" && continue
			[[ "$ep_start" =~ ^[0-9]+$ ]] || { echo -e "${RE} = = > Invalid episode.${NC}"; pause; continue; }

			echo
			echo -e "${CYAN} 1) Insert At Character Position${NC}"
			echo -e "${CYAN} 2) Insert Before Segment Number${NC}"
			echo -e "${CYAN} 3) Insert After Segment Number${NC}"
			echo

			prompt_menu_choice " = = > Insert Mode [1-3 | 0.=return]: " insert_mode

			is_exit_token "$insert_mode" && continue

			case "$insert_mode" in
				1|2|3) ;;
				*) echo -e "${RE} = = > Invalid Insert Mode.${NC}"; pause; continue ;;
			esac

			prompt_read " = = > Position / Segment Number: " insert_pos

			is_exit_token "$insert_pos" && continue
			[[ "$insert_pos" =~ ^[0-9]+$ ]] || { echo -e "${RE} = = > Invalid position.${NC}"; pause; continue; }

			current_ep="$ep_start"

			for f in "${ordered_targets[@]}"; do
				[[ -f "$f" ]] || continue

				ext="${f##*.}"
				stem="${f%.*}"

				printf -v tag 'S%02dE%02d' "$((10#$season))" "$((10#$current_ep))"

				case "$insert_mode" in
					1)
						newstem="${stem:0:insert_pos}_${tag}_${stem:insert_pos}"
						;;

					2|3)
						local segline seg_oldifs
						local -a segs=()

						segline="$(preen_split_segments "$stem")"

						seg_oldifs="$IFS"
						IFS=' '
						read -r -a segs <<< "$segline"
						IFS="$seg_oldifs"

						if [[ "$insert_mode" == "2" ]]; then
							segs=("${segs[@]:0:insert_pos}" "$tag" "${segs[@]:insert_pos}")
						else
							segs=("${segs[@]:0:insert_pos+1}" "$tag" "${segs[@]:insert_pos+1}")
						fi

						newstem="$(preen_join_segments "${segs[@]}")"
						;;
				esac

				newstem="${newstem//__/_}"
				newstem="${newstem##_}"
				# newstem="${newstem%%_}" removes trailing underscore if we ever decide the bird over-preened.

				old_names+=("$f")
				new_names+=("${newstem}.${ext}")

				((current_ep+=1)) || :
			done

			preen_preview_and_apply old_names new_names
			preen_collect_targets targets
			continue
		fi

		if [[ "$choice" == "13" ]]; then
			run_line_preen
			preen_collect_targets targets
			continue
		fi

		case "$choice" in
			1|2|3|4|5|6|9|10|11)
				prompt_read " = = > Enter Count / Position: " val
				is_exit_token "$val" && continue
				[[ "$val" =~ ^[0-9]+$ ]] || { echo -e "${RE} = = > Invalid number.${NC}"; pause; continue; }
				;;
		esac

		case "$choice" in
			7|8)
				prompt_read " = = > Enter Marker Text: " marker
				is_exit_token "$marker" && continue
				[[ -n "$marker" ]] || continue
				;;
			9|10|11)
				prompt_read " = = > Insert Text: " insert_text
				is_exit_token "$insert_text" && continue
				;;
		esac

		local f stem ext newstem
		for f in "${targets[@]}"; do
			[[ -f "$f" ]] || continue

			ext="${f##*.}"
			stem="${f%.*}"
			newstem="$stem"

			case "$choice" in
				1|2|3|4|10|11)
					local segline seg_oldifs
					local -a segs=()

					segline="$(preen_split_segments "$stem")"

					seg_oldifs="$IFS"
					IFS=' '
					read -r -a segs <<< "$segline"
					IFS="$seg_oldifs"

					case "$choice" in
						1)
							(( val >= ${#segs[@]} )) && continue
							segs=("${segs[@]:val}")
							;;
						2)
							(( val >= ${#segs[@]} )) && continue
							segs=("${segs[@]:0:${#segs[@]}-val}")
							;;
						3)
							segs=("${segs[@]:0:val}")
							;;
						4)
							(( val > ${#segs[@]} )) && continue
							segs=("${segs[@]:${#segs[@]}-val}")
							;;
						10)
							segs=("${segs[@]:0:val}" "$insert_text" "${segs[@]:val}")
							;;
						11)
							segs=("${segs[@]:0:val+1}" "$insert_text" "${segs[@]:val+1}")
							;;
					esac

					newstem="$(preen_join_segments "${segs[@]}")"
					;;

				5)
					(( val >= ${#stem} )) && continue
					newstem="${stem:val}"
					;;
				6)
					(( val >= ${#stem} )) && continue
					newstem="${stem:0:${#stem}-val}"
					;;
				7)
					[[ "$stem" == *"$marker"* ]] && newstem="${stem#*"$marker"}"
					;;
				8)
					[[ "$stem" == *"$marker"* ]] && newstem="${stem%%"$marker"*}"
					;;
				9)
					newstem="${stem:0:val}${insert_text}${stem:val}"
					;;
				*)
					echo -e "${RE} = = > Invalid selection.${NC}"
					pause
					continue 2
					;;
			esac

			newstem="${newstem//__/_}"
			newstem="${newstem##_}"
			# newstem="${newstem%%_}" removes trailing underscore if we ever decide the bird over-preened.

			[[ -z "$newstem" ]] && continue

			local newfile="${newstem}.${ext}"

			if [[ "$f" != "$newfile" ]]; then
				old_names+=("$f")
				new_names+=("$newfile")
			fi
		done

		preen_preview_and_apply old_names new_names
		preen_collect_targets targets
	done
}

# =========================
# #MARKER: TITLEZ AND SUBTITLEZ MENU
# =========================
# PURPOSE:
# - Separate title-bar / playback tools from filename/subtitle tools
# - Reuse existing engines without redesigning them yet
# - Keep user flow aligned with the new workflow menu structure
#
run_title_subtitle_menu() {
    while true; do
        clear
        echo -e "${CYAN}================================================${NC}"
        echo -e "${CYAN}            TITLEZ AND SUBTITLEZ                ${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     1) Subtox, FileNames, Subtitlez"
        echo "     2) BARFIX / Fix-Title-Bar-Display / File-Name + Playback Tools"
        echo "     3) Preen Filename Adjustments / SxxExx Injector"
        echo
        echo "     10-key exit > 0. (or q) Enter to quit"
        echo

        read -r -p "     Choice: ${NC}${GREEN}" ts_choice
        echo -e "${NC}"
        ts_choice="${ts_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$ts_choice"; then
    	    return 0
        fi

        case "$ts_choice" in
            1)
                run_subtitlez_menu
                ;;
            2)
                run_title_playback_menu
                ;;
            3)
                run_preen
                ;;
            [Qq])
                return 0
                ;;
            *)
                echo -e "${REB} = = > Invalid.${NC}"
                pause
                ;;
        esac
    done
}

# =========================
# #MARKER: SUBTITLEZ SUBMENU
# =========================
# CURRENT DESIGN:
# - Route bulk subtitle tasks through existing SUBTOX engine for now
# - Keep direct item names visible in workflow menu even if engine is still unified
#
run_subtitlez_menu() {
    while true; do
        clear
        echo -e "${CYAN}================================================${NC}"
        echo -e "${CYAN}                 SUBTITLEZ                      ${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     1) SUBTOX"
        echo "     2) Full Collection Folder Recursive Filename Detox Scan"
		echo "     3) Detox Existing File Names In This Folder"
        echo "     4) Pack external.srt"
        echo "     5) Extract Internal Subtitles"
        echo
        echo "     10-key exit > 0. (or q) Enter to quit"
        echo

        read -r -p "     Choice: ${NC}${GREEN}" subtitle_choice
        echo -e "${NC}"
        subtitle_choice="${subtitle_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$subtitle_choice"; then
    	    return 0
        fi

        case "$subtitle_choice" in
            1)
                run_subtox
                ;;
            2)
                run_collection_detox_scan_only
                ;;
            3)
                local -a direct_detox_vids=()

                shopt -s nullglob nocaseglob
                direct_detox_vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
                shopt -u nullglob nocaseglob

                run_subtox_direct_detox "${direct_detox_vids[@]}"
                ;;
            4)
                run_subtox_pack
                ;;
			5)
				run_subtox_extract
				;;
            [Qq])
                return 0
                ;;
            *)
                echo -e "${REB} = = > Invalid.${NC}"
                pause
                ;;
        esac
    done
}

# =========================
# #MARKER: TITLE / PLAYBACK SUBMENU
# =========================
# CURRENT DESIGN:
# - BARFIX owns title-bar metadata and playback default behavior
# - Filename detox / rename remains separate from title-bar metadata
#
run_title_playback_menu() {
    while true; do
        clear
        echo -e "${CYAN}==========================================================${NC}"
        echo -e "${CYAN}        BAR / FILE BAR-TITLE / FILE-NAME                  ${NC}"
        echo -e "${CYAN}  Users View Of The Players Title Bar Hence Barfix        ${NC}"
        echo -e "${CYAN}==========================================================${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     1) BARFIX Title + Playback Tools"
        echo "     2) Rename / Detox Tools"
        echo
        echo "     10-key exit > 0. (or q) Enter to quit"
        echo

        read -r -p "     Choice: ${NC}${GREEN}" title_choice
        echo -e "${NC}"
        title_choice="${title_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$title_choice"; then
    	    return 0
        fi

        case "$title_choice" in
            1)
                run_barfix
                ;;
            2)
                run_subtox_rename
                ;;
            [Qq])
                return 0
                ;;
            *)
                echo -e "${REB} = = > Invalid.${NC}"
                pause
                ;;
        esac
    done
}

# ================================================================
# #MARKER: SUBTOX CODEC-AWARE EXTERNAL SUBTITLE PACKER
# ================================================================
# PURPOSE:
# - Pack external subtitle files back into local video files.
# - Support both text subtitles and bitmap subtitles.
# - Work as the reverse side of codec-aware subtitle extraction.
#
# SUPPORTED INPUT SUBS:
#   Text   : .srt .ass .ssa .vtt
#   Bitmap : .sup .sub
#
# MATCH RULE:
# - Finds SxxExx in video filename.
# - Finds external subtitle files containing same SxxExx.
#
# WARNING:
# - External subtitles must match the exact timing of the target video.
# - Original/OEM subtitle files may NOT match SMC / SmartCut outputs
#   if trimming or intro removal changed timing.
# ================================================================
run_subtox_pack() {
	local -a vids=()
	local -a subs=()
	local vid s out EP_CODE SUB_NAME ext
	local i
	local -a cmd=()

	clear
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}          SUBTOX :: CODEC-AWARE SUBTITLE PACK               ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${CYAN} = = > This tool packs external subtitle files into MKV.${NC}"
	echo -e "${CYAN} = = > Text subtitles supported:${NC} ${GREEN}srt / ass / ssa / vtt${NC}"
	echo -e "${CYAN} = = > Bitmap subtitles supported:${NC} ${GREEN}sup / sub${NC}"
	echo
	echo -e "${RED} = = > ===== SUBTITLE TIMING WARNING =====${NC}"
	echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
	echo -e "${YELLOW} = = > This Works Best On ORIGINAL / OEM Episode Files.${NC}"
	echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
	echo -e "${YELLOW} = = > If You Use REKEY Files, Confirm Subtitle Timing Still Matches.${NC}"
	echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
	echo -e "${RED} = = > If You Use SMC / SMARTGAP-Cut Files, Old External Subtitles${NC}"
	echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
	echo -e "${RED} = = > May Be Broken By Pre-Trim, Intro Removal, And Post-Trim Edits.${NC}"
	echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
	echo -e "${RED} = = > Do NOT Trust Original External Subtitles On Cut Outputs${NC}"
	echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
	echo -e "${RED} = = > Unless They Were Retimed For That Exact Final File.${NC}"
	echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
	echo

	if ! command -v ffmpeg >/dev/null 2>&1; then
		echo -e "${REB} = = > Missing Dependency:${NC} ${YELLOW}ffmpeg${NC}"
		pause
		return 1
	fi

	shopt -s nullglob nocaseglob
	vids=(*.lrv *.mkv *.mp4 *.avi *.mov *.mpg *.mpeg *.ts *.m4v *.ogv *.flv *.3gp *.divx *.webm *.xvid *.wmv)
	shopt -u nocaseglob

	if (( ${#vids[@]} == 0 )); then
		echo -e "${YE} = = > No Local Video Files Found.${NC}"
		pause
		return 0
	fi

	echo -e "${CYAN} = = > Video Files Found:${NC} ${YELLOW}${#vids[@]}${NC}"
	echo

	if ! ask_yes_no " = = > Continue With External Subtitle Packing? [1=yes | 2=no]: "; then
		echo -e "${YELLOW} = = > External Subtitle Packing Canceled.${NC}"
		pause
		return 0
	fi

	for vid in "${vids[@]}"; do
		[[ -f "$vid" ]] || continue

		[[ "$vid" =~ ^SUBPACKED_ ]] && continue
		[[ "$vid" =~ ^BARFIX_ ]] && continue
		[[ "$vid" =~ ^intro_template ]] && continue

		EP_CODE="$(printf '%s\n' "$vid" | grep -oiE 'S[0-9]{2}E[0-9]{2}' | head -1 | tr '[:lower:]' '[:upper:]' || true)"

		if [[ -z "${EP_CODE:-}" ]]; then
			echo -e "${YE} = = > No SxxExx Found For:${NC} ${YELLOW}$vid${NC}"
			continue
		fi

		echo
		echo -e "${CYAN}------------------------------------------------------------${NC}"
		echo -e "${CYAN} = = > Video:${NC} ${GREEN}$vid${NC}"
		echo -e "${CYAN} = = > Subtitle Key:${NC} ${YELLOW}$EP_CODE${NC}"

		subs=()

		while IFS= read -r -d '' s; do
			if printf '%s\n' "$s" | grep -qiE "$EP_CODE"; then
				subs+=("$s")
			fi
		done < <(
			find . -type f \
				\( -iname "*.srt" -o -iname "*.ass" -o -iname "*.ssa" -o -iname "*.vtt" -o -iname "*.sup" -o -iname "*.sub" \) \
				-print0 2>/dev/null
		)

		if (( ${#subs[@]} == 0 )); then
			echo -e "${YE} = = > No Matching External Subs Found.${NC}"
			continue
		fi

		echo -e "${GR} = = > Matching Subs Found:${NC} ${YELLOW}${#subs[@]}${NC}"

		cmd=(ffmpeg -hide_banner -loglevel error -nostdin -y -i "$vid")

		for s in "${subs[@]}"; do
			echo -e "${CYAN}     +${NC} ${GREEN}$s${NC}"
			cmd+=(-i "$s")
		done

		# Keep all source video/audio. Keep existing source subtitles too.
		cmd+=(-map 0)

		for (( i=0; i<${#subs[@]}; i++ )); do
			SUB_NAME="$(basename "${subs[$i]%.*}")"
			ext="${subs[$i]##*.}"
			ext="${ext,,}"

			cmd+=(-map "$((i+1)):0")

			case "$ext" in
				srt)
					cmd+=(-metadata:s:s:"$i" "title=$SUB_NAME" -metadata:s:s:"$i" language=eng)
					;;
				ass|ssa)
					cmd+=(-metadata:s:s:"$i" "title=$SUB_NAME" -metadata:s:s:"$i" language=eng)
					;;
				vtt)
					cmd+=(-metadata:s:s:"$i" "title=$SUB_NAME" -metadata:s:s:"$i" language=eng)
					;;
				sup)
					cmd+=(-metadata:s:s:"$i" "title=$SUB_NAME" -metadata:s:s:"$i" language=eng)
					;;
				sub)
					cmd+=(-metadata:s:s:"$i" "title=$SUB_NAME" -metadata:s:s:"$i" language=eng)
					;;
				*)
					cmd+=(-metadata:s:s:"$i" "title=$SUB_NAME")
					;;
			esac
		done

		out="$(build_stage_output_name "SUBPACKED" "$vid")"
		out="${out%.*}.mkv"

		if [[ -f "$out" ]]; then
			echo -e "${YE} = = > Output Already Exists. Skipping To Avoid Overwrite:${NC} ${YELLOW}$out${NC}"
			continue
		fi

		cmd+=(-c copy -disposition:s 0 "$out")

		if "${cmd[@]}"; then
			echo -e "${GR} = = > SUBPACKED CREATED:${NC} ${YELLOW}$out${NC}"
			stage_archive_file "$vid" "SUBTOX"
		else
			echo -e "${RE} = = > SUBPACK FAILED:${NC} ${YELLOW}$vid${NC}"
			rm -f -- "$out"
		fi
	done

	pause
	return 0
}

# ================================================================
# #MARKER: SUBTOX CODEC-AWARE INTERNAL SUBTITLE EXTRACTOR
# ================================================================
# PURPOSE:
# - Extract internal subtitle streams from local video files.
# - Detect subtitle codec before choosing output extension.
# - Stop pretending every subtitle can become .srt.
#
# WHY:
# - Text subtitles can be extracted as text.
# - Bitmap subtitles, such as BluRay PGS, must be extracted as bitmap.
# - OCR is NOT performed here.
#
# OUTPUT ROOT:
#   subs_extracted/
#     Episode_Name/
#       S01E01_track00_eng.srt
#       S01E01_track01_eng.sup
#
# CODEC MAP:
#   subrip              -> srt
#   ass                 -> ass
#   ssa                 -> ssa
#   webvtt              -> vtt
#   hdmv_pgs_subtitle   -> sup
#   dvd_subtitle        -> sub
# ================================================================
run_subtox_extract() {
	local -a vids=()
	local file base stem out_dir
	local stream_count
	local idx codec lang ext out
	local extracted_count=0
	local failed_count=0
	local skipped_count=0

	clear
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}          SUBTOX :: CODEC-AWARE SUBTITLE EXTRACT             ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${CYAN} = = > This tool extracts internal subtitle streams.${NC}"
	echo -e "${CYAN} = = > Text subtitles stay text:${NC} ${GREEN}srt / ass / ssa / vtt${NC}"
	echo -e "${CYAN} = = > Bitmap subtitles stay bitmap:${NC} ${GREEN}sup / sub${NC}"
	echo -e "${YE} = = > NOTE:${NC} ${YELLOW}Bitmap subtitles are NOT OCR-converted into SRT.${NC}"
	echo

	if ! command -v ffprobe >/dev/null 2>&1; then
		echo -e "${REB} = = > Missing Dependency:${NC} ${YELLOW}ffprobe${NC}"
		pause
		return 1
	fi

	if ! command -v ffmpeg >/dev/null 2>&1; then
		echo -e "${REB} = = > Missing Dependency:${NC} ${YELLOW}ffmpeg${NC}"
		pause
		return 1
	fi

	shopt -s nullglob nocaseglob
	vids=(*.lrv *.mkv *.mp4 *.avi *.mov *.mpg *.mpeg *.ts *.m4v *.ogv *.flv *.3gp *.divx *.webm *.xvid *.wmv)
	shopt -u nocaseglob

	if (( ${#vids[@]} == 0 )); then
		echo -e "${YE} = = > No Local Video Files Found.${NC}"
		pause
		return 0
	fi

	echo -e "${CYAN} = = > Video Files Found:${NC} ${YELLOW}${#vids[@]}${NC}"
	echo -e "${CYAN} = = > Output Root:${NC} ${GREEN}subs_extracted/${NC}"
	echo

	if ! ask_yes_no " = = > Extract internal subtitles now? [1=yes | 2=no]: "; then
		echo -e "${YE} = = > Subtitle extraction canceled.${NC}"
		pause
		return 0
	fi

	mkdir -p "subs_extracted"

	for file in "${vids[@]}"; do
		[[ -f "$file" ]] || continue

		base="$(basename "$file")"
		stem="${base%.*}"
		out_dir="subs_extracted/$stem"

		echo
		echo -e "${CYAN}------------------------------------------------------------${NC}"
		echo -e "${CYAN} = = > Extracting From:${NC} ${GREEN}$file${NC}"

		stream_count="$(
			ffprobe -v error \
				-select_streams s \
				-show_entries stream=index \
				-of csv=p=0 \
				"$file" 2>/dev/null | wc -l | awk '{print $1}'
		)"

		stream_count="${stream_count:-0}"

		echo -e "${CYAN} = = > Subtitle Streams Found:${NC} ${YELLOW}$stream_count${NC}"

		if (( stream_count == 0 )); then
			echo -e "${YE} = = > No Subtitle Streams. Skipping.${NC}"
			((skipped_count+=1)) || :
			continue
		fi

		mkdir -p "$out_dir"

		for ((idx=0; idx<stream_count; idx++)); do
			codec="$(
				ffprobe -v error \
					-select_streams "s:$idx" \
					-show_entries stream=codec_name \
					-of default=noprint_wrappers=1:nokey=1 \
					"$file" 2>/dev/null | head -n 1
			)"

			lang="$(
				ffprobe -v error \
					-select_streams "s:$idx" \
					-show_entries stream_tags=language \
					-of default=noprint_wrappers=1:nokey=1 \
					"$file" 2>/dev/null | head -n 1
			)"

			codec="${codec:-unknown}"
			lang="${lang:-und}"
			lang="${lang//[^A-Za-z0-9_-]/_}"

			case "$codec" in
				subrip)
					ext="srt"
					;;
				ass)
					ext="ass"
					;;
				ssa)
					ext="ssa"
					;;
				webvtt)
					ext="vtt"
					;;
				hdmv_pgs_subtitle)
					ext="sup"
					;;
				dvd_subtitle)
					ext="sub"
					;;
				*)
					ext="sub"
					;;
			esac

			out="$out_dir/$(printf 'track%02d_%s_%s.%s' "$idx" "$lang" "$codec" "$ext")"

			echo -e "${CYAN} = = > Track:${NC} ${YELLOW}$idx${NC} ${CYAN}| Codec:${NC} ${YELLOW}$codec${NC} ${CYAN}| Lang:${NC} ${YELLOW}$lang${NC}"
			echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"

			rm -f -- "$out"

			if ffmpeg -hide_banner -loglevel error -y \
				-i "$file" \
				-map "0:s:$idx" \
				-c:s copy \
				"$out"; then

				if [[ -s "$out" ]]; then
					echo -e "${GR} = = > Extracted:${NC} ${GREEN}$out${NC}"
					((extracted_count+=1)) || :
				else
					echo -e "${YE} = = > Empty Output Removed:${NC} ${YELLOW}$out${NC}"
					rm -f -- "$out"
					((failed_count+=1)) || :
				fi
			else
				echo -e "${REB} = = > Extract Failed:${NC} ${YELLOW}$file track $idx${NC}"
				rm -f -- "$out"
				((failed_count+=1)) || :
			fi
		done

		echo -e "${CYAN} = = > Extract Folder:${NC} ${GREEN}$out_dir${NC}"
	done

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}              SUBTOX EXTRACTION SUMMARY                    ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > Extracted Streams:${NC} ${GREEN}$extracted_count${NC}"
	echo -e "${CYAN} = = > Failed Streams:${NC} ${YELLOW}$failed_count${NC}"
	echo -e "${CYAN} = = > Files With No Subs:${NC} ${YELLOW}$skipped_count${NC}"
	echo -e "${CYAN} = = > Output Root:${NC} ${GREEN}subs_extracted/${NC}"
	echo

	pause
	return 0
}

# ================================================================
# #MARKER: SMARTGAP TRIM-ONLY BATCH MAP BUILDER
# ================================================================
# PURPOSE:
# - Create A Legal intro_map.csv For Batch Tip/Tail Trim Jobs
# - Allows SMARTGAP To Run Without Real Intro Detection
# - Optional Same-Time Segment Removal For Every File
#
# MODES:
# - TRIM_ONLY:
#     start=0 end=0
#
# - GLOBAL_SEGMENT:
#     start/end supplied by user
#
# OUTPUT CSV:
#   filename,start,end,start_hms,end_hms,template_used,diff
# ================================================================
run_smartgap_trim_only_batch_mode() {
	local intro_map_file="intro_map.csv"
	local outro_map_file="outro_map.csv"
	local seg_start_raw seg_end_raw
	local seg_start seg_end
	local template_tag="TRIM_ONLY"
	local count=0
	local f

	local -a targets=()

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        SMARTGAP TRIM-ONLY BATCH MAP BUILDER      ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > This Creates Neutral Batch Maps So SMARTGAP Can Batch Trim.${NC}"
	echo -e "${YELLOW} = = > intro_map.csv handles tip / front-side trim rows.${NC}"
	echo -e "${YELLOW} = = > outro_map.csv handles tail / end-side trim rows.${NC}"
	echo
	echo -e "${CYAN} = = > Optional Global Segment Removal:${NC}"
	echo -e "${YELLOW}       Leave blank for normal tip/tail trim map skeletons.${NC}"
	echo -e "${YELLOW}       Example: remove same ad from 12:30 to 13:15 in every file.${NC}"
	echo

	prompt_read " = = > Segment START To Remove (blank = none): " seg_start_raw

	if is_exit_token "$seg_start_raw"; then
		echo -e "${YE} = = > Canceled.${NC}"
		pause
		return 0
	fi

	if [[ -n "$seg_start_raw" ]]; then
		prompt_read " = = > Segment END To Remove: " seg_end_raw

		if is_exit_token "$seg_end_raw"; then
			echo -e "${YE} = = > Canceled.${NC}"
			pause
			return 0
		fi

		seg_start="$(to_seconds "$seg_start_raw" 2>/dev/null || true)"
		seg_end="$(to_seconds "$seg_end_raw" 2>/dev/null || true)"

		if [[ -z "$seg_start" || -z "$seg_end" ]]; then
			echo -e "${REB} = = > Invalid Segment Time.${NC}"
			pause
			return 1
		fi

		if awk -v s="$seg_start" -v e="$seg_end" 'BEGIN { exit !(e > s) }'; then
			template_tag="GLOBAL_SEGMENT"
		else
			echo -e "${REB} = = > Segment END Must Be Greater Than START.${NC}"
			pause
			return 1
		fi
	else
		seg_start="0"
		seg_end="0"
	fi

	shopt -s nullglob nocaseglob
	for f in *.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv}; do
		[[ -f "$f" ]] || continue

		case "$f" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*|intro_template*)
				continue
				;;
		esac

		targets+=("$f")
	done
	shopt -u nullglob nocaseglob

	if (( ${#targets[@]} == 0 )); then
		echo -e "${REB} = = > No Working Video Targets Found.${NC}"
		pause
		return 1
	fi

	echo
	echo -e "${CYAN} = = > Targets Found:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo -e "${CYAN} = = > Map Mode:${NC} ${YELLOW}$template_tag${NC}"
	echo -e "${CYAN} = = > Intro Map:${NC} ${GREEN}$intro_map_file${NC}"
	echo -e "${CYAN} = = > Outro Map:${NC} ${GREEN}$outro_map_file${NC}"
	echo

	for f in "$intro_map_file" "$outro_map_file"; do
		if [[ -f "$f" ]]; then
			echo -e "${YE} = = > Existing Map Found:${NC} ${YELLOW}$f${NC}"
			cp -- "$f" "${f}.bak_$(date '+%Y%m%d_%H%M%S')"
			echo -e "${CYAN} = = > Backup Created For:${NC} ${GREEN}$f${NC}"
		fi
	done

	if ! ask_yes_no " = = > Create / Replace intro_map.csv and outro_map.csv? (y/n or 1/2): "; then
		echo -e "${YE} = = > Canceled.${NC}"
		pause
		return 0
	fi

	printf 'filename,start,end,start_hms,end_hms,template_used,diff\n' > "$intro_map_file"
	printf 'filename,start,end,start_hms,end_hms,template_used,diff\n' > "$outro_map_file"

	for f in "${targets[@]}"; do
		# Intro map: neutral front-side placeholder.
		printf '%s,%s,%s,%s,%s,%s,%s\n' \
			"$f" \
			"0" \
			"0" \
			"$(format_seconds_hms 0)" \
			"$(format_seconds_hms 0)" \
			"TRIM_ONLY_INTRO" \
			"0" >> "$intro_map_file"

		# Outro map:
		# - Normal trim-only skeleton uses start=0,end=end as a clear tail-side placeholder.
		# - Global segment mode mirrors the selected segment into both maps.
		if [[ "$template_tag" == "GLOBAL_SEGMENT" ]]; then
			printf '%s,%s,%s,%s,%s,%s,%s\n' \
				"$f" \
				"$seg_start" \
				"$seg_end" \
				"$(format_seconds_hms "$seg_start")" \
				"$(format_seconds_hms "$seg_end")" \
				"GLOBAL_SEGMENT" \
				"0" >> "$outro_map_file"
		else
			printf '%s,%s,%s,%s,%s,%s,%s\n' \
				"$f" \
				"0" \
				"end" \
				"$(format_seconds_hms 0)" \
				"end" \
				"TRIM_ONLY_OUTRO" \
				"0" >> "$outro_map_file"
		fi

		((count+=1)) || :
	done

	echo
	echo -e "${GR} = = > Trim-Only Batch Maps Created.${NC}"
	echo -e "${CYAN} = = > Rows Written Per Map:${NC} ${YELLOW}$count${NC}"
	echo -e "${CYAN} = = > Intro Map:${NC} ${GREEN}$intro_map_file${NC}"
	echo -e "${CYAN} = = > Outro Map:${NC} ${GREEN}$outro_map_file${NC}"
	echo

	pause
	return 0
}

# ================================================================
# #MARKER: BATCH NORMALIZE LEGACY SOURCES TO MKV TOOL
# ================================================================
# PURPOSE:
# - Batch-remux working-dir legacy/non-MKV video files to MKV
# - Reuse existing normalize_to_mkv() engine
# - Prepare AVI / older containers before SmartCut, SMARTGAP, or BARFIX
#
# SAFETY:
# - Skips internal Factory outputs
# - Prompts before running
# - Does not invent a second remux engine
# ================================================================
run_batch_normalize_to_mkv_tool() {
	local -a sources=()
	local -a targets=()
	local f result rescued_run_dir
	local total count=0 fail_count=0

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}       BATCH NORMALIZE LEGACY SOURCES TO MKV    ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > This prepares AVI / legacy containers for SmartCut, SMARTGAP, and BARFIX.${NC}"
	echo -e "${YELLOW} = = > Uses existing normalize_to_mkv() behavior.${NC}"
	echo -e "${YELLOW} = = > MKV files are skipped.${NC}"
	echo

	shopt -s nullglob nocaseglob
	sources=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	for f in "${sources[@]}"; do
		[[ -f "$f" ]] || continue

		case "$f" in
			REKEY_*|SMC_*|PILOT_SMC_*|BARFIX_*|SUBPACKED_*|SUBTOX_*|ARCHIVE_*|intro_template*|custom_cut*)
				continue
				;;
		esac

		targets+=("$f")
	done

	total="${#targets[@]}"

	if (( total == 0 )); then
		echo -e "${YE} = = > No Legacy / Non-MKV Working Targets Found.${NC}"
		pause
		return 0
	fi

	echo -e "${CYAN} = = > Targets Found:${NC} ${YELLOW}$total${NC}"
	echo
	for f in "${targets[@]}"; do
		echo -e "${GREEN}  - $f${NC}"
	done
	echo

	if ! ask_yes_no " = = > Batch Normalize These To MKV? (y/n or 1/2): "; then
		echo -e "${YE} = = > Batch Normalize Canceled.${NC}"
		pause
		return 0
	fi

		rescued_run_dir="OEM/NORMALIZED/$(date '+%Y-%m')"

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             NORMALIZE PASS STARTED             ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	for f in "${targets[@]}"; do
		((count+=1)) || :

		echo
		echo -e "${CYAN}[$count / $total] TARGET:${NC} ${GREEN}$f${NC}"

		result="$(normalize_to_mkv "$f" || true)"

		if [[ "${result,,}" == *.mkv && -f "$result" ]]; then
			echo -e "${GR} = = > NORMALIZED:${NC} ${GREEN}$result${NC}"

			if [[ "$result" != "$f" ]]; then
				archive_rescued_source_file "$f" "$rescued_run_dir"
			fi
		else
			echo -e "${REB} = = > NORMALIZE FAILED:${NC} ${YELLOW}$f${NC}"
			echo -e "${YE} = = > Returned:${NC} ${YELLOW}${result:-none}${NC}"
			((fail_count+=1)) || :
		fi
	done

	echo
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              NORMALIZE PASS SUMMARY            ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > Targets Seen:${NC} ${YELLOW}$total${NC}"
	echo -e "${CYAN} = = > Failed:${NC} ${YELLOW}$fail_count${NC}"
	echo

	pause
	return 0
}

run_smartcut_logs_menu() {
	echo -e "${CYAN} = = > Logs / Maps (placeholder)${NC}"
	pause
}

run_smc_custom_cutz() {
	echo -e "${CYAN} = = > SMC Custom Cutz (placeholder)${NC}"
	pause
}

# ================================================================
# #MARKER: OUTRO_MAP LAZY CREATE
# ================================================================
ensure_outro_map() {
	if [[ ! -f "$OUTRO_MAP" ]]; then
		printf '%s\n' "filename,start,end,start_hms,end_hms,template_used,diff" > "$OUTRO_MAP"
	fi
}

# ================================================================
# #MARKER: OUTROFIND DEFAULTS
# ================================================================
OUTRO_MAP="${OUTRO_MAP:-outro_map.csv}"
OUTRO_SCAN_BACK_SECONDS="${OUTRO_SCAN_BACK_SECONDS:-180}"

# ================================================================
# #MARKER: PICK ONE TEMPLATE SOURCE
# ================================================================
pick_one_template_source() {
	local -n _targets_ref=$1
	local choice total

	total="${#_targets_ref[@]}"

	clear
	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > PICK TEMPLATE SOURCE FILE${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo

	for idx in "${!_targets_ref[@]}"; do
		printf '%b%5d)%b %b%s%b\n' \
			"$YELLOW" "$((idx + 1))" "$NC" "$GREEN" "${_targets_ref[$idx]}" "$NC"
	done

	echo
	prompt_menu_choice " = = > Pick ONE file [1-${total} | 0.=cancel]: " choice

	if is_exit_token "$choice"; then
		return 1
	fi

	if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > total )); then
		echo -e "${REB} = = > Invalid File Selection.${NC}"
		return 1
	fi

	_targets_ref=("${_targets_ref[$((choice - 1))]}")
	return 0
}

# ================================================================
# #MARKER: FINGERPRINT TEMPLATE OPTIMIZER
# ================================================================
# PURPOSE:
# - Build the visible intro template from the ORIGINAL episode source.
# - Avoid carrying SmartCut boundary-reference artifacts into the template.
# - Apply only conservative cleanup: mild temporal/spatial denoise and a
#   high-quality x264 encode. No AI detail invention and no forced upscale.
# - Keep the SmartCut result as a hidden raw reference beside the template.
#
# INPUT:
#   $1 = original source file
#   $2 = exact intro start in seconds
#   $3 = exact intro end in seconds
#   $4 = optimized visible output path
#
# OUTPUT:
# - Exact-duration MKV suitable for the structural/temporal fingerprint maker.
# - Returns nonzero without replacing an existing output if optimization fails.
# ================================================================
optimize_intro_template_for_fingerprint() {
	local src="$1"
	local start="$2"
	local end="$3"
	local out="$4"
	local duration=""
	local tmp_out="${out}.optimizer_tmp.mkv"
	local actual_duration=""
	local duration_error=""

	duration="$(awk -v s="$start" -v e="$end" 'BEGIN {
		d=e-s
		if (d > 0) printf "%.3f", d
	}')"

	if [[ -z "$duration" ]] || ! awk -v d="$duration" 'BEGIN { exit !(d > 0) }'; then
		echo -e "${REB} = = > Fingerprint Optimizer Received An Invalid Time Range.${NC}"
		return 1
	fi

	rm -f -- "$tmp_out"

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > FINGERPRINT TEMPLATE OPTIMIZER${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	echo -e "${CYAN} = = > Exact Range:${NC} ${YELLOW}${start}s -> ${end}s${NC}"
	echo -e "${CYAN} = = > Target Duration:${NC} ${YELLOW}${duration}s${NC}"
	echo -e "${CYAN} = = > Cleanup:${NC} ${YELLOW}Mild hqdn3d; no upscale; no sharpening${NC}"
	echo -e "${CYAN} = = > Encode:${NC} ${YELLOW}x264 CRF 16 / slow / yuv420p${NC}"
	echo

	# Put -ss after -i so FFmpeg decodes through the requested boundary instead
	# of beginning from a nearby packet/keyframe. This costs time only once when
	# the template is made and avoids inheriting a damaged cut-boundary GOP.
	if ! ffmpeg \
		-hide_banner \
		-loglevel warning \
		-stats \
		-nostdin \
		-y \
		-i "$src" \
		-ss "$start" \
		-t "$duration" \
		-map 0:v:0 \
		-map "0:a?" \
		-map_metadata 0 \
		-vf "hqdn3d=1.2:1.2:4.0:4.0,format=yuv420p" \
		-c:v libx264 \
		-preset slow \
		-crf 16 \
		-c:a aac \
		-b:a 192k \
		-sn \
		-avoid_negative_ts make_zero \
		-max_interleave_delta 0 \
		"$tmp_out"; then
		rm -f -- "$tmp_out"
		echo -e "${REB} = = > Fingerprint Template Optimization Failed.${NC}"
		return 1
	fi

	if [[ ! -s "$tmp_out" ]]; then
		rm -f -- "$tmp_out"
		echo -e "${REB} = = > Fingerprint Optimizer Produced No Usable Output.${NC}"
		return 1
	fi

	actual_duration="$(get_file_duration_seconds "$tmp_out" 2>/dev/null || true)"
	if [[ -z "$actual_duration" ]]; then
		rm -f -- "$tmp_out"
		echo -e "${REB} = = > Could Not Verify Optimized Template Duration.${NC}"
		return 1
	fi

	duration_error="$(awk -v a="$actual_duration" -v t="$duration" 'BEGIN {
		d=a-t
		if (d < 0) d=-d
		printf "%.3f", d
	}')"

	if ! awk -v d="$duration_error" 'BEGIN { exit !(d <= 0.150) }'; then
		rm -f -- "$tmp_out"
		echo -e "${REB} = = > Optimized Template Duration Drifted Too Far.${NC}"
		echo -e "${CYAN}       Expected:${NC} ${YELLOW}${duration}s${NC}"
		echo -e "${CYAN}       Actual:${NC}   ${YELLOW}${actual_duration}s${NC}"
		echo -e "${CYAN}       Error:${NC}    ${YELLOW}${duration_error}s${NC}"
		return 1
	fi

	mv -f -- "$tmp_out" "$out"

	echo
	echo -e "${GR} = = > Fingerprint Template Optimized:${NC} ${GREEN}$(factory_display_path "$out")${NC}"
	echo -e "${CYAN} = = > Verified Duration:${NC} ${YELLOW}${actual_duration}s${NC}"
	return 0
}

# ================================================================
# #MARKER: SMC TEMPLATE BUILDER
# ================================================================
create_template_smc() {

	have_smartcut || {
		echo -e "${REB} = = > No SmartCut engine found.${NC}"
		echo -e "${CYAN} = = > Install:${NC} ${YELLOW}pipx install smartcut${NC}"
		pause
		return 1
	}

	local -a targets=()
	local src start end keep_args out choice outro_len
	local template_kind template_title smc_out raw_name

	# ------------------------------------------------------------
	# Collect eligible files
	# ------------------------------------------------------------
	shopt -s nullglob nocaseglob
	targets=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nocaseglob

	local f
	local -a filtered=()
	for f in "${targets[@]}"; do
		[[ "$f" =~ ^SMC_ ]] && continue
		filtered+=("$f")
	done

	targets=("${filtered[@]}")

	if (( ${#targets[@]} == 0 )); then
		echo -e "${REB} = = > No eligible source files found.${NC}"
		pause
		return 1
	fi

	# ------------------------------------------------------------
	# Pick source file
	# ------------------------------------------------------------
	if ! pick_one_template_source targets; then
		echo -e "${YELLOW} = = > Template Build Cancelled.${NC}"
		return 0
	fi

	src="${targets[0]}"

	# ------------------------------------------------------------
	# Template type menu
	# ------------------------------------------------------------
	clear
	echo -e "${CYAN}     =============================================================${NC}"
	echo -e "${YELLOW}     ========> Open File Selected From Which To Extract <=======${NC}"
	echo -e "${GREEN}     ===========> intro_template.mkv <==========================${NC}"
	echo -e "${YELLOW}     ====> Get Exact Times From That File For Accuracy <========${NC}"
	echo -e "${GREEN}     =============> Watch It With Your Eyes To Get The <========${NC}"
	echo -e "${YELLOW}     =================> Start And End Times To The Second <=====${NC}"
	echo -e "${GREEN}     ==> Verify Start And End Timings for intro_template.mkv <==${NC}"
	echo
	echo -e "${YELLOW}     ======>   Verify  Start  Timings  for  ${NC}${GREEN}outro.mkv${NC}${YELLOW} <=========${NC}"
	echo -e "${YELLOW}     ======>  ${NC}${GREEN}outro.mkv${NC}${YELLOW}<======= Input Seconds To Keep <=========${NC}"
	echo -e "${YELLOW}     ==> Leave Blank=Outro Cuts Will Go To End of File <========${NC}"
	echo -e "${CYAN}     ===========================================================${NC}"
	echo -e "${GREEN}       = = > CHOOSE TEMPLATE TYPE${NC}"
	echo -e "${CYAN}     =============================================================${NC}"
	echo
	echo -e "${CYAN}     1) Intro Template + Fingerprint Optimizer${NC}"
	echo -e "${CYAN}     2) Outro Template (Start + End)${NC}"
	echo
	echo -e "${CYAN}     0.) Return${NC}"
	echo

	prompt_menu_choice " = = > Select Template Type [1-2 | 0.=return]: " choice

	case "$choice" in
		1)
			prompt_read " = = > Enter Intro Start Time: " start
			prompt_read " = = > Enter Intro End Time: " end

			start="$(to_seconds "$start")"
			end="$(to_seconds "$end")"

			keep_args="$start,$end"
			out="$(next_template_output_path "intro_template/intro_template.mkv")"
			template_kind="intro"
			;;
		2)
			prompt_read " = = > Enter Outro Start Time: " start
			start="$(to_seconds "$start")"

			echo
			echo -e "${CYAN} = = > Outro End Mode:${NC}"
			echo -e "${CYAN}     - Enter seconds to keep after start.${NC}"
			echo -e "${CYAN}     - Blank = keep from start to END of file.${NC}"
			echo

			prompt_read " = = > Outro Length Seconds (blank=end): " outro_len

			if [[ -n "$outro_len" ]]; then
				outro_len="$(to_seconds "$outro_len")"
				end="$(awk -v s="$start" -v l="$outro_len" 'BEGIN{printf "%.3f", s+l}')"
			else
				end="end"
			fi

			keep_args="$start,$end"
			out="$(next_template_output_path "intro_template/outro.mkv")"
			template_kind="outro"
			;;
		0.)
			return 0
			;;
		*)
			echo -e "${REB} = = > Invalid Selection.${NC}"
			pause
			return 1
			;;
	esac

	mkdir -p intro_template

	# Intro keeps SMC's exact cut as a hidden diagnostic/reference file while
	# the visible template is rebuilt from the original source by FFmpeg.
	if [[ "$template_kind" == "intro" ]]; then
		raw_name=".$(basename "${out%.*}").smc_raw.mkv"
		smc_out="$(dirname "$out")/$raw_name"
	else
		smc_out="$out"
	fi

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > TEMPLATE BUILD PREVIEW${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	echo -e "${CYAN} = = > Keep:${NC} ${YELLOW}$keep_args${NC}"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	if [[ "$template_kind" == "intro" ]]; then
		echo -e "${CYAN} = = > SMC Raw Reference:${NC} ${YELLOW}$(factory_display_path "$smc_out")${NC}"
		echo -e "${CYAN} = = > Optimizer:${NC} ${YELLOW}Original-source accurate decode + mild cleanup${NC}"
	fi
	echo

	if ! ask_yes_no " = = > Proceed? (y/n or 1/2): "; then
		echo -e "${YELLOW} = = > Template Build Cancelled.${NC}"
		return 0
	fi

	rm -f -- "$smc_out"

	echo
	echo -e "${CYAN} = = > Building SmartCut Template Reference...${NC}"
	echo

	if ! "$SMC_BIN" "$src" "$smc_out" --keep "$keep_args"; then
		rm -f -- "$smc_out"
		echo
		echo -e "${REB} = = > TEMPLATE BUILD FAILED.${NC}"
		echo
		pause
		return 1
	fi

	if [[ ! -s "$smc_out" ]]; then
		echo -e "${REB} = = > SmartCut Produced No Usable Template Reference.${NC}"
		pause
		return 1
	fi

	if [[ "$template_kind" == "intro" ]]; then
		if ! optimize_intro_template_for_fingerprint "$src" "$start" "$end" "$out"; then
			echo
			echo -e "${YE} = = > Optimizer Failed; Preserving The SMC Raw Reference.${NC}"
			echo -e "${YE} = = > No Visible intro_template Was Installed.${NC}"
			pause
			return 1
		fi
	fi

	template_title="$(factory_template_title_from_source "$template_kind" "$src")"
	factory_set_mkv_title_if_possible "$out" "$template_title"

	echo
	echo -e "${GR} = = > TEMPLATE CREATED:${NC} ${GREEN}$(factory_display_path "$out")${NC}"
	if [[ "$template_kind" == "intro" ]]; then
		echo -e "${CYAN} = = > Hidden SMC Reference:${NC} ${YELLOW}$(factory_display_path "$smc_out")${NC}"
		echo -e "${CYAN} = = > Next Step:${NC} ${YELLOW}Intro Template Structural Fingerprint Maker Will Run Now${NC}"
	fi

	echo
	pause
	run_intro_template_fingerprint_report
}

# ================================================================
# #MARKER: SMC BANNER HELPERS
# ================================================================
smc_banner() {
	local title="$1"

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > $title${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
}

smc_phase_banner() {
	local title="$1"

	echo
	echo -e "${CYAN}------------------------------------------------------------${NC}"
	echo -e "${CYAN} = = > $title${NC}"
	echo -e "${CYAN}------------------------------------------------------------${NC}"
	echo
}

resolve_media_file_from_map_name() {
	local wanted="$1"
	local stem ext candidate

	# Exact match first.
	if [[ -f "$wanted" ]]; then
		printf '%s\n' "$wanted"
		return 0
	fi

	stem="${wanted%.*}"

	for ext in mkv mp4 avi mov m4v ts webm mpg mpeg; do
		candidate="${stem}.${ext}"
		if [[ -f "$candidate" ]]; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done

	return 1
}

run_phash_engine_colored() {
	local line

	while IFS= read -r line; do
		case "$line" in
			MATCH\|*)
				echo -e "${GR}${line}${NC}"
				;;
			NO_MATCH|*NO_MATCH*)
				echo -e "${YE}${line}${NC}"
				;;
			TEMPLATE_READY*|ENGINE_CFG*|TEMPLATE_ORDER*)
				echo -e "${CYAN}${line}${NC}"
				;;
			TOP_CANDIDATES*|*avg_diff*|*diff*)
				echo -e "${YELLOW}${line}${NC}"
				;;
			*ERROR*|*Error*|*Traceback*|*failed*|*FAILED*)
				echo -e "${REB}${line}${NC}"
				;;
			*)
				echo -e "${WHITE}${line}${NC}"
				;;
		esac
	done
}

run_smartcut_colored() {
	local file="$1"
	local out="$2"
	local cut_args="$3"
	local rc=0

	"$SMC_BIN" "$file" "$out" --cut "$cut_args" 2>&1 | while IFS= read -r line; do
		case "$line" in
			*"completed successfully"*|*"Output saved"*)
				echo -e "${GR}${line}${NC}"
				;;
			*"failed"*|*"error"*|*"Error"*|*"Traceback"*)
				echo -e "${REB}${line}${NC}"
				;;
			*it\ \[*)
				echo -e "${CYAN}${line}${NC}"
				;;
			*)
				echo -e "${ORANGE}${line}${NC}"
				;;
		esac
	done

	rc="${PIPESTATUS[0]}"
	return "$rc"
}

#=========================
#MARKER: SMARTCUT UNIFIED ENGINE
#=========================
smartcut_from_csv() {
	local csv="intro_map.csv"

	# rolling defaults (persist across calls in same session)
	TIP_TRIM_SECONDS="${TIP_TRIM_SECONDS:-0}"
	TAIL_TRIM_SECONDS="${TAIL_TRIM_SECONDS:-0}"
	local tip_offset="${TIP_OFFSET_SECONDS:-0}"
	local intro_pad_before="${INTRO_PAD_BEFORE_SECONDS:-0}"
	local intro_pad_after="${INTRO_PAD_AFTER_SECONDS:-0}"
	local outro_pad_before="${OUTRO_PAD_BEFORE_SECONDS:-0}"

	local csv_mode=1

	if [[ ! -f "$csv" ]]; then
		csv_mode=0
		echo -e "${YE} = = > intro_map.csv not found.${NC}"
		echo -e "${CYAN} = = > CSV intro removal disabled for this run.${NC}"
		echo -e "${CYAN} = = > Running SMC Tip/Tail Only Mode instead.${NC}"
		echo
	fi

	have_smartcut || {
		echo -e "${REB} = = > No SmartCut engine found.${NC}"
		pause
		return 1
	}

	smc_banner "SMC / SMARTCUT SURGERY BATCH"

	# show current defaults
echo -e "${CYAN} = = > Tip:${NC} ${YELLOW}${TIP_TRIM_SECONDS}s${NC}  ${CYAN}| Tail:${NC} ${YELLOW}${TAIL_TRIM_SECONDS}s${NC}  ${CYAN}| Outro Pre:${NC} ${YELLOW}${OUTRO_PAD_BEFORE_SECONDS}s${NC}"
echo -e "${CYAN} = = > Intro Offset:${NC} ${YELLOW}${TIP_OFFSET_SECONDS}s${NC}  ${CYAN}| Intro Pre:${NC} ${YELLOW}${INTRO_PAD_BEFORE_SECONDS}s${NC}  ${CYAN}| Intro Post:${NC} ${YELLOW}${INTRO_PAD_AFTER_SECONDS}s${NC}"
echo -e "${CYAN} = = > Barfix:${NC} ${YELLOW}$([[ "${SMC_BARFIX_LITE_ENABLED:-1}" == "1" ]] && echo ON || echo OFF)${NC}  ${CYAN}| Audio:${NC} ${YELLOW}${SMC_BARFIX_AUDIO_LANG:-eng}${NC}  ${CYAN}| Subs Off:${NC} ${YELLOW}${SMC_BARFIX_SUBS_OFF:-1}${NC}  ${CYAN}| Title:${NC} ${YELLOW}${SMC_BARFIX_TITLE_MODE:-after_sxxexx}${NC}"
echo

	# input with "enter = keep last"
	local input

	prompt_read " = = > Tip Snip Seconds (Current Setting ${TIP_TRIM_SECONDS}): " input
	if is_exit_token "$input"; then
		echo -e "${YELLOW} = = > Batch Cancelled.${NC}"
		return 0
	fi
	[[ -n "$input" ]] && TIP_TRIM_SECONDS="$input"

	prompt_read " = = > Tail Tuck Seconds (Current Setting ${TAIL_TRIM_SECONDS}): " input
	if is_exit_token "$input"; then
		echo -e "${YELLOW} = = > Batch Cancelled.${NC}"
		return 0
	fi
	[[ -n "$input" ]] && TAIL_TRIM_SECONDS="$input"

	smc_phase_banner "CUT PLAN"
	echo -e "${CYAN} = = > CSV Source:${NC} ${GREEN}$csv${NC}"
	echo -e "${CYAN} = = > Tip Snip:${NC}  ${YELLOW}${TIP_TRIM_SECONDS}s${NC}"
	echo -e "${CYAN} = = > Tail Tuck:${NC} ${YELLOW}${TAIL_TRIM_SECONDS}s${NC}"
	echo -e "${CYAN} = = > Global Offset:${NC} ${YELLOW}${tip_offset}s${NC}"
	echo -e "${CYAN} = = > Intro Pre-Pad:${NC} ${YELLOW}${intro_pad_before}s${NC}"
	echo -e "${CYAN} = = > Intro Post-Pad:${NC} ${YELLOW}${intro_pad_after}s${NC}"
	echo -e "${CYAN} = = > Outro Pre-Pad:${NC} ${YELLOW}${outro_pad_before}s${NC}"
	echo

	local pilot_mode max_files processed=0

	echo -e "${CYAN} = = > SmartCut Run Scope:${NC}"
	echo -e "${CYAN}     1) Pilot First File${NC}"
	echo -e "${CYAN}     2) Pilot First 3 Files${NC}"
	echo -e "${CYAN}     3) Full Batch${NC}"
	echo

	prompt_menu_choice " = = > Select Scope [1-3 | default=1]: " pilot_mode

	case "${pilot_mode:-1}" in
		1) max_files=1 ;;
		2) max_files=3 ;;
		3) max_files=0 ;;
		*)
			echo -e "${YE} = = > Invalid Scope. Using Pilot First File.${NC}"
			max_files=1
			;;
	esac

	if (( max_files > 0 )); then
		PILOT_MODE=1
		pilot_begin_session "smartcut_scope"
	else
		PILOT_MODE=0
	fi

local -a manual_targets=()
local duration duration_int total_cut

if (( csv_mode == 0 )); then
	shopt -s nullglob nocaseglob
	manual_targets=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nocaseglob

	local f
	local -a filtered=()
	for f in "${manual_targets[@]}"; do
		[[ "$f" =~ ^SMC_ ]] && continue
		[[ "$f" =~ ^BARFIX_ ]] && continue
		[[ "$f" =~ ^REKEY_ ]] && continue
		filtered+=("$f")
	done

	manual_targets=("${filtered[@]}")

	if (( ${#manual_targets[@]} == 0 )); then
		echo -e "${REB} = = > No eligible video files found.${NC}"
		pause
		return 1
	fi

	# ========================================================
	# #MARKER: SMARTCUT SCOPE GATE
	# ========================================================
	# WHY:
	# - Pilot First File / First 3 Files should not ask the
	#   second manual limiter question.
	# - Full Batch still gets the normal picker/limiter.
	# ========================================================
	if (( max_files == 0 )); then
		if ! limit_targets_interactive manual_targets; then
			echo -e "${YELLOW} = = > SMC Tip/Tail Mode Cancelled.${NC}"
			return 0
		fi
	else
		if (( ${#manual_targets[@]} > max_files )); then
			manual_targets=("${manual_targets[@]:0:max_files}")
		fi

		echo -e "${GREEN} = = > Pilot Scope Active:${NC} ${YELLOW}${#manual_targets[@]} file(s)${NC}"
		echo
	fi

	for file in "${manual_targets[@]}"; do
		cut_args=""

		if awk -v t="$TIP_TRIM_SECONDS" 'BEGIN{exit !(t > 0)}'; then
			cut_args="0,$TIP_TRIM_SECONDS"
		fi

		if awk -v t="$TAIL_TRIM_SECONDS" 'BEGIN{exit !(t > 0)}'; then
			if [[ -n "$cut_args" ]]; then
				cut_args="$cut_args,-$TAIL_TRIM_SECONDS,end"
			else
				cut_args="-$TAIL_TRIM_SECONDS,end"
			fi
		fi

		if [[ -z "$cut_args" ]]; then
			echo -e "${YE} = = > No Tip Or Tail Cut Requested. Skipping:${NC} $file"
			continue
		fi

                  
		# ========================================================
		# #MARKER: SMARTCUT MINIMUM DURATION SAFETY CHECK
		# ========================================================
		# WHY:
		# - Prevent SmartCut from crashing when requested cuts
		#   consume the entire source runtime.
		# - Common cause: tiny intro/template/test clip left in
		#   the working folder.
		# ========================================================
		duration="$(ffprobe -v error \
			-show_entries format=duration \
			-of default=noprint_wrappers=1:nokey=1 \
			"$file" 2>/dev/null || true)"

		duration_int="$(awk -v d="${duration:-0}" 'BEGIN { printf "%d", d }')"
		total_cut="$(awk -v tip="${TIP_TRIM_SECONDS:-0}" -v tail="${TAIL_TRIM_SECONDS:-0}" 'BEGIN { printf "%d", tip + tail }')"

		if (( duration_int <= total_cut + 5 )); then
			echo
			echo -e "${YE} = = > Source Too Short For Requested Cut Plan. Skipping:${NC} ${YELLOW}$file${NC}"
			echo -e "${CYAN} = = > Duration:${NC} ${YELLOW}${duration_int}s${NC}"
			echo -e "${CYAN} = = > Requested Removal:${NC} ${YELLOW}${total_cut}s${NC}"
			echo -e "${YE} = = > This Usually Means A Template / Intro / Tiny Clip Was Left In The Working Folder.${NC}"
			echo
			pause
			continue
		fi

		out="$(build_stage_output_name "SMC" "$file")"

		if [[ "${PILOT_MODE:-0}" == "1" ]]; then
			pilot_register_restore_point "$file" "SMC_TIPTAIL_PILOT_SOURCE"
			pilot_register_output "$out" "SMC_TIPTAIL_PILOT_OUTPUT"
		fi


		if [[ -f "$out" ]]; then
			echo -e "${YE} = = > SMC Output Already Exists. Skipping To Avoid Overwrite:${NC} ${YELLOW}$out${NC}"
			continue
		fi

		smc_phase_banner "TIP / TAIL TARGET"
		echo -e "${CYAN} = = > Source:${NC} ${GREEN}$file${NC}"
		echo -e "${CYAN} = = > Cut Plan:${NC} ${YELLOW}$cut_args${NC}"
		smc_explain_cut_plan "$cut_args"
		echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
		echo

		"$SMC_BIN" "$file" "$out" --cut "$cut_args"

		if [[ $? -eq 0 ]]; then
			echo -e "${GR} = = > SMC TIP/TAIL COMPLETE:${NC} ${GREEN}$out${NC}"

			if [[ "${PILOT_MODE:-0}" == "1" ]]; then
				echo -e "${YE} = = > Pilot Mode: Original Left In Working Directory For Redo Safety.${NC}"
			else
				stage_archive_file "$file" "SMC"
			fi

			file="$out"

			if [[ "${SMC_BARFIX_LITE_ENABLED:-1}" == "1" ]]; then
				run_barfix_lite_on_file "$file"
			fi
		else
			echo -e "${REB} = = > SMC TIP/TAIL FAILED:${NC} ${GREEN}$file${NC}"
		fi
	done
		if [[ "${PILOT_MODE:-0}" == "1" ]]; then
			handle_smc_pilot_review
			PILOT_MODE=0
			pause
			return 0
		fi

		PILOT_MODE=0
		pause
		return 0
		fi

# this is the top of the loop
# ================================================================
# #MARKER: SMC CSV LOOP
# ================================================================
local pilot_outputs_created=0

while IFS=, read -r file start end _; do

	[[ -z "$file" ]] && continue
	[[ "$file" == filename* ]] && continue

	local resolved_file=""

	if ! resolved_file="$(resolve_media_file_from_map_name "$file")"; then
		echo -e "${YE} = = > CSV Source Missing. Skipping:${NC} ${YELLOW}$file${NC}"
		continue
	fi

	if [[ "$resolved_file" != "$file" ]]; then
		echo -e "${CYAN} = = > CSV Source Resolved By Stem:${NC}"
		echo -e "${CYAN}     Map:${NC} ${YELLOW}$file${NC}"
		echo -e "${CYAN}     Disk:${NC} ${GREEN}$resolved_file${NC}"
		file="$resolved_file"
	fi

	# ================================================================
	# #MARKER: SMC PILOT LIMITER
	# ================================================================
	((processed+=1)) || :

	if (( max_files > 0 && processed > max_files )); then
		echo -e "${YELLOW} = = > Pilot Limit Reached (${max_files} file(s)).${NC}"
		break
	fi

	local adj_start adj_end cut_args out

	adj_start=$(awk -v s="$start" -v o="$tip_offset" -v p="$intro_pad_before" 'BEGIN{
		v=s+o-p
		if (v < 0) v=0
		printf "%.3f", v
	}')

	adj_end=$(awk -v e="$end" -v o="$tip_offset" -v p="$intro_pad_after" 'BEGIN{
		v=e+o+p
		if (v < 0) v=0
		printf "%.3f", v
	}')

	cut_args=""

	# ================================================================
	# #MARKER: SMC VALID INTRO CUT GUARD
	# ================================================================
	if awk -v s="$adj_start" -v e="$adj_end" 'BEGIN { exit !(e > s) }'; then
		cut_args="$adj_start,$adj_end"
	fi

	# ================================================================
	# #MARKER: SMC OUTRO_MAP MERGE
	# ================================================================
	local outro_start=""
	local adj_outro_start=""

	if [[ -f "${OUTRO_MAP:-outro_map.csv}" ]]; then
		outro_start="$(
			awk -F, -v target="$file" '
				function stem(x) {
					gsub(/^.*\//, "", x)
					sub(/\.[^.]*$/, "", x)
					return x
				}

				NR == 1 { next }

				$1 == target || stem($1) == stem(target) {
					print $2
					exit
				}
			' "${OUTRO_MAP:-outro_map.csv}"
		)"
	fi

	if [[ -n "$outro_start" ]]; then
		adj_outro_start="$(awk -v s="$outro_start" -v p="$outro_pad_before" 'BEGIN{
			v=s-p
			if (v < 0) v=0
			printf "%.3f", v
		}')"

		if [[ -n "$cut_args" ]]; then
			cut_args="$cut_args,$adj_outro_start,end"
		else
			cut_args="$adj_outro_start,end"
		fi

		echo -e "${CYAN} = = > OutroMap Match:${NC} ${YELLOW}${outro_start},end${NC}"
		echo -e "${CYAN} = = > Outro Pre-Pad Applied:${NC} ${YELLOW}${outro_pad_before}s${NC}"
		echo -e "${CYAN} = = > Adjusted Outro Cut:${NC} ${YELLOW}${adj_outro_start},end${NC}"
	fi

	if awk -v t="$TIP_TRIM_SECONDS" 'BEGIN{exit !(t > 0)}'; then
		if [[ -n "$cut_args" ]]; then
			cut_args="0,$TIP_TRIM_SECONDS,$cut_args"
		else
			cut_args="0,$TIP_TRIM_SECONDS"
		fi
	fi

	if awk -v t="$TAIL_TRIM_SECONDS" 'BEGIN{exit !(t > 0)}'; then
		if [[ -n "$cut_args" ]]; then
			cut_args="$cut_args,-$TAIL_TRIM_SECONDS,end"
		else
			cut_args="-$TAIL_TRIM_SECONDS,end"
		fi
	fi

	if [[ -z "$cut_args" ]]; then
		echo -e "${YE} = = > No Valid Cut Plan Built. Skipping:${NC} ${YELLOW}$file${NC}"
		continue
	fi

	out="$(build_stage_output_name "SMC" "$file")"

	if [[ -f "$out" ]]; then
		echo -e "${YE} = = > SMC Output Already Exists. Skipping To Avoid Overwrite:${NC} ${YELLOW}$out${NC}"
		continue
	fi

	smc_phase_banner "SURGERY TARGET"

	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$file${NC}"
	echo -e "${CYAN} = = > Cut Plan:${NC} ${YELLOW}$cut_args${NC}"
	smc_explain_cut_plan "$cut_args"
	echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	echo
	echo -e "${CYAN} = = > ACTIVE SMC ENGINE:${NC} ${YELLOW}$(trim_working_path_display "$SMC_BIN" 3)${NC}"
	echo -e "${GREEN} = = > Support Them Here: ${RE}https://${BW}smartmediacutter${CY}.com/${NC}"
	echo

	#if [[ -x "${SMC_BIN:-}" ]]; then
		#echo -e "${CYAN} = = > SMC VERSION:${NC} ${YELLOW}$("$SMC_BIN" --version 2>/dev/null | head -n1)${NC}"
	#fi

	if run_smartcut_colored "$file" "$out" "$cut_args"; then
		echo -e "${GR} = = > SMC SURGERY COMPLETE:${NC} ${GREEN}$out${NC}"

		if [[ "${PILOT_MODE:-0}" == "1" ]]; then
			pilot_register_restore_point "$file" "SMC_CSV_PILOT_SOURCE"
			pilot_register_output "$out" "SMC_CSV_PILOT_OUTPUT"
			pilot_register_smc_cut_plan "$file" "$out" "$cut_args"
			((pilot_outputs_created+=1)) || :
			echo -e "${YE} = = > Pilot Mode: Original Left In Working Directory For Redo Safety.${NC}"
		else
			stage_archive_file "$file" "SMC"
		fi

		file="$out"

		if [[ "${SMC_BARFIX_LITE_ENABLED:-1}" == "1" ]]; then
			run_barfix_lite_on_file "$file"
		fi
	else
		echo -e "${REB} = = > SMC SURGERY FAILED:${NC} ${GREEN}$file${NC}"
		echo -e "${YEB} = = >${NC}${YE} Logs In Working Dir Until You Press Enter${NC}"
		rm -f -- "$out"
	fi

done < "$csv"

if [[ "${PILOT_MODE:-0}" == "1" ]]; then
	if (( pilot_outputs_created > 0 )); then
		handle_smc_pilot_review
	else
		echo -e "${YE} = = > Pilot Review Skipped: No Pilot Output Was Created.${NC}"
	fi
fi

PILOT_MODE=0
rm -f x265_2pass.log.cutree
pause
rm -f x265_2pass.log
}

# ========================================================
# #MARKER: SMARTCUT ENGINE DETECTION
# ========================================================
# PURPOSE:
# - Locate The SmartCut / Smart Media Cutter Engine Used By Factory.
# - Prefer A Carried TOOLBOX smc.app When Available.
# - Fall Back To Working-Folder smc.app Or pipx / PATH smartcut Only If Needed.
#
# ENGINE ORDER:
#   1) FACTORY_HOME/smc.app
#      - Preferred portable Factory copy.
#      - After TOOLBOX resolution, FACTORY_HOME should normally be TOOLBOX.
#
#   2) TOOLBOX/smc.app Beside factory.sh Or Working Folder
#      - Allows factory.sh to be loose beside a TOOLBOX directory.
#
#   3) Working Folder smc.app
#      - Emergency / local test override.
#
#   4) smartcut
#      - Legacy pipx / PATH fallback.
#
# NOTES:
# - Smart Media Cutter AppImage should be renamed to smc.app.
# - The AppImage must remain executable:
#       chmod +x smc.app
#
# OUTPUT:
# - Sets SMC_BIN
# - Sets HAS_SMC
# - Returns 0 If A Usable Engine Is Found
# - Returns 1 If Not Found
# ========================================================
resolve_smc_bin() {
	local candidate=""

	local -a smc_candidates=(
		"${FACTORY_HOME}/smc.app"
		"${FACTORY_HOME}/SMC.app"
		"${SCRIPT_DIR}/TOOLBOX/smc.app"
		"${SCRIPT_DIR}/TOOLBOX/SMC.app"
		"${FACTORY_WORKDIR}/TOOLBOX/smc.app"
		"${FACTORY_WORKDIR}/TOOLBOX/SMC.app"
		"${FACTORY_WORKDIR}/smc.app"
		"${FACTORY_WORKDIR}/SMC.app"
		"./TOOLBOX/smc.app"
		"./TOOLBOX/SMC.app"
		"./smc.app"
		"./SMC.app"
	)

	for candidate in "${smc_candidates[@]}"; do
		if [[ -x "$candidate" ]]; then
			SMC_BIN="$candidate"
			HAS_SMC=1
			echo -e "${GR} = = > SmartCut Engine:${NC} ${YELLOW}$(trim_working_path_display "$SMC_BIN" 3)${NC}"
			return 0
		fi
	done

	if have_cmd smartcut; then
		SMC_BIN="$(command -v smartcut)"
		HAS_SMC=1
		echo -e "${YE} = = > SmartCut Engine Fallback:${NC} ${YELLOW}$SMC_BIN${NC}"
		return 0
	fi

	SMC_BIN=""
	HAS_SMC=0
	print_missing_optional_dep "smc.app / smartcut" "SmartCut / Smart Media Cutter missions will be unavailable."
	return 1
}

have_smartcut() {
	resolve_smc_bin >/dev/null 2>&1
}

# ========================================================
# #MARKER: FACTORY STARTUP ENVIRONMENT REPORT
# ========================================================
show_factory_environment_report() {
	local cols lines smc_display template_display

	cols="$(tput cols 2>/dev/null || printf '0')"
	lines="$(tput lines 2>/dev/null || printf '0')"

	resolve_smc_bin >/dev/null 2>&1 || true

	smc_display="${SMC_BIN:-not found}"
	template_display="${INTRO_TEMPLATE_DIR:-${FACTORY_HOME}/intro_template}"

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}                 FACTORY ENVIRONMENT                        ${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > Factory Home:${NC} ${YELLOW}$(trim_working_path_display "$FACTORY_HOME" 3)${NC}"
	echo -e "${CYAN} = = > Working Dir :${NC} ${YELLOW}$(trim_working_path_display "$FACTORY_WORKDIR" 3)${NC}"
	echo -e "${CYAN} = = > SmartCut    :${NC} ${YELLOW}$(trim_working_path_display "$smc_display" 3)${NC}"
	echo -e "${CYAN} = = > Templates   :${NC} ${YELLOW}$(trim_working_path_display "$template_display" 3)${NC}"
	echo -e "${CYAN} = = > Terminal    :${NC} ${YELLOW}${cols} x ${lines}${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo
}

# ================================================================
# #MARKER: SMARTCUT SESSION VARZ MENU
# ================================================================
smartcut_session_varz_menu() {
	local choice input
	local auto_jump="${1:-}"

	case "$auto_jump" in
		introfind|1)
			choice="1"
			;;
	esac

	while true; do
		clear
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN}                    SMARTCUT SESSION VARZ                   ${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo

		echo -e "${YELLOW}     1) Intro/Outro Find Vars${NC}"
		echo -e "${YELLOW}     2) SmartCut Cut Vars${NC}"
		echo -e "${YELLOW}     3) Barfix Lite Vars${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo
		echo -e "${YE} = = >     ${CYAN}= = = = = = ${NC}${YELLOW}Review Decimal Points Carefully ${CYAN}= = = = = = ${NC}"
		echo -e "${YE} = = > Example: ${GREEN}24.5 = 24.5 Seconds, But 2.20 = 2 Minutes 20 Seconds.${NC}"
		echo -e "${YE} = = > For Fractional Seconds After Minutes Use Colon Format:${GREEN} 2:20.5 = 2 Minutes 20.5 Seconds.${NC}"
		echo

		if [[ -z "${choice:-}" ]]; then
			prompt_menu_choice " = = > Select Option [1-3 | 0.=return]: " choice
		fi

		if is_exit_token "$choice"; then
			return 0
		fi

		case "$choice" in
			1)
				clear
				echo -e "${CYAN}============================================================${NC}"
				echo -e "${CYAN} = = > INTRO / OUTRO FIND VARS (SESSION)${NC}"
				echo -e "${CYAN}============================================================${NC}"
				echo

				echo -e "${YELLOW}--- INTRO FIND VARS ---${NC}"
				prompt_read " = = > Intro Scan Start Seconds (current ${INTRO_SCAN_START:-${DEFAULT_SCAN_START:-30}}): " input
				[[ -n "$input" ]] && INTRO_SCAN_START="$input"

				prompt_read " = = > Max Intro Scan Seconds (current ${INTRO_MAX_SCAN:-${DEFAULT_MAX_SCAN:-601}}): " input
				[[ -n "$input" ]] && INTRO_MAX_SCAN="$input"

				prompt_read " = = > Intro Hash Diff Threshold (current ${INTRO_HASH_DIFF:-${DEFAULT_HASH_DIFF:-12}}): " input
				[[ -n "$input" ]] && INTRO_HASH_DIFF="$input"

				prompt_read " = = > Intro Step Size Seconds (current ${INTRO_STEP_SIZE:-1}): " input
				[[ -n "$input" ]] && INTRO_STEP_SIZE="$input"

				prompt_read " = = > Intro Anchor Seconds CSV (CSV or auto) (current ${INTRO_ANCHOR_SECONDS:-3,5,7}): " input
				[[ -n "$input" ]] && INTRO_ANCHOR_SECONDS="$input"

				echo
				echo -e "${CYAN} = = > Intro Hash Mode:${NC} ${YELLOW}${INTRO_HASH_MODE:-phash}${NC}"
				echo -e "${CYAN}     1) dHash  ${YELLOW}(fastest for credits, high contrast)${NC}"
				echo -e "${CYAN}     2) aHash  ${YELLOW}(fast/simple average hash)${NC}"
				echo -e "${CYAN}     3) pHash  ${YELLOW}(heavier perceptual hash)${NC}"
				echo -e "${CYAN}     4) wHash  ${YELLOW}(wavelet hash)${NC}"
				echo

				prompt_menu_choice " = = > Select Intro Hash Mode [1-4 | blank=keep current]: " input

				case "$input" in
					"")
						;;
					1)
						INTRO_HASH_MODE="dhash"
						;;
					2)
						INTRO_HASH_MODE="ahash"
						;;
					3)
						INTRO_HASH_MODE="phash"
						;;
					4)
						INTRO_HASH_MODE="whash"
						;;
					*)
						echo -e "${YE} = = > Invalid Hash Mode. Keeping:${NC} ${YELLOW}${INTRO_HASH_MODE:-phash}${NC}"
						;;
				esac
				echo
				echo -e "${CYAN}--- OUTRO FIND VARS ---${NC}"
				prompt_read " = = > Outro Tail Scan Seconds (current ${OUTRO_TAIL_SCAN_SECONDS:-200}): " input
				[[ -n "$input" ]] && OUTRO_TAIL_SCAN_SECONDS="$input"

				prompt_read " = = > Outro Hash Diff Threshold (current ${OUTRO_HASH_DIFF:-16}): " input
				[[ -n "$input" ]] && OUTRO_HASH_DIFF="$input"

				prompt_read " = = > Outro Step Size Seconds (current ${OUTRO_STEP_SIZE:-1}): " input
				[[ -n "$input" ]] && OUTRO_STEP_SIZE="$input"

				prompt_read " = = > Outro Anchor Seconds CSV (CSV or auto) (current ${OUTRO_ANCHOR_SECONDS:-8,12,16}): " input
				[[ -n "$input" ]] && OUTRO_ANCHOR_SECONDS="$input"

				echo
				echo -e "${CYAN} = = > Outro Hash Mode:${NC} ${YELLOW}${OUTRO_HASH_MODE:-dhash}${NC}"
				echo -e "${CYAN}     1) dHash  ${YELLOW}(fastest for credits, high contrast)${NC}"
				echo -e "${CYAN}     2) aHash  ${YELLOW}(fast/simple average hash)${NC}"
				echo -e "${CYAN}     3) pHash  ${YELLOW}(heavier perceptual hash)${NC}"
				echo -e "${CYAN}     4) wHash  ${YELLOW}(wavelet hash)${NC}"
				echo

				prompt_menu_choice " = = > Select Outro Hash Mode [1-4 | blank=keep current]: " input

				case "$input" in
					"")
						;;
					1)
						OUTRO_HASH_MODE="dhash"
						;;
					2)
						OUTRO_HASH_MODE="ahash"
						;;
					3)
						OUTRO_HASH_MODE="phash"
						;;
					4)
						OUTRO_HASH_MODE="whash"
						;;
					*)
						echo -e "${YE} = = > Invalid Hash Mode. Keeping:${NC} ${YELLOW}${OUTRO_HASH_MODE:-dhash}${NC}"
						;;
				esac
				echo
				echo -e "${GR} = = > Intro/Outro Find Vars Updated.${NC}"
				smartcut_save_sticky_session
				pause

				if [[ -n "$auto_jump" ]]; then
					auto_jump=""
					choice=""
					return 0
				fi
				choice=""
				;;

			2)
				clear
				echo -e "${CYAN}============================================================${NC}"
				echo -e "${CYAN} = = > SMARTCUT CUT VARS (SESSION)${NC}"
				echo -e "${CYAN}============================================================${NC}"
				echo

				prompt_read " = = > Tip Snip Seconds (current ${TIP_TRIM_SECONDS:-0}): " input
				[[ -n "$input" ]] && TIP_TRIM_SECONDS="$input"

				prompt_read " = = > Tail Tuck Seconds (current ${TAIL_TRIM_SECONDS:-0}): " input
				[[ -n "$input" ]] && TAIL_TRIM_SECONDS="$input"

				prompt_read " = = > Intro Offset Seconds (current ${TIP_OFFSET_SECONDS:-0}): " input
				[[ -n "$input" ]] && TIP_OFFSET_SECONDS="$input"

				prompt_read " = = > Intro Pre-Pad Seconds (current ${INTRO_PAD_BEFORE_SECONDS:-0}): " input
				[[ -n "$input" ]] && INTRO_PAD_BEFORE_SECONDS="$input"

				prompt_read " = = > Intro Post-Pad Seconds (current ${INTRO_PAD_AFTER_SECONDS:-0}): " input
				[[ -n "$input" ]] && INTRO_PAD_AFTER_SECONDS="$input"

				prompt_read " = = > Outro Pre-Pad Seconds (current ${OUTRO_PAD_BEFORE_SECONDS:-0}): " input
				[[ -n "$input" ]] && OUTRO_PAD_BEFORE_SECONDS="$input"

				echo
				echo -e "${GR} = = > SmartCut Cut Vars Updated.${NC}"
				smartcut_save_sticky_session
				pause
				choice=""
				;;

			3)
				clear
				echo -e "${CYAN}============================================================${NC}"
				echo -e "${CYAN} = = > BARFIX LITE VARS (SESSION)${NC}"
				echo -e "${CYAN}============================================================${NC}"
				echo

				echo -e "${YELLOW} = = > Enable Barfix Lite After SmartCut?${NC}"
				echo -e "${CYAN}     1) Yes${NC}"
				echo -e "${CYAN}     2) No${NC}"
				prompt_menu_choice " = = > Select [1/2]: " choice
				case "$choice" in
					1) SMC_BARFIX_LITE_ENABLED=1 ;;
					2) SMC_BARFIX_LITE_ENABLED=0 ;;
				esac
				echo

				echo -e "${YELLOW} = = > Preferred Audio Language Default${NC}"
				echo -e "${CYAN}     1) English${NC}"
				echo -e "${CYAN}     2) Japanese${NC}"
				echo -e "${CYAN}     3) Spanish${NC}"
				echo -e "${CYAN}     4) French${NC}"
				echo -e "${CYAN}     5) German${NC}"
				echo -e "${CYAN}     6) Keep Existing / No Audio Change${NC}"
				prompt_menu_choice " = = > Select [1-6]: " choice
				case "$choice" in
					1) SMC_BARFIX_AUDIO_LANG="eng" ;;
					2) SMC_BARFIX_AUDIO_LANG="jpn" ;;
					3) SMC_BARFIX_AUDIO_LANG="spa" ;;
					4) SMC_BARFIX_AUDIO_LANG="fra" ;;
					5) SMC_BARFIX_AUDIO_LANG="deu" ;;
					6) SMC_BARFIX_AUDIO_LANG="skip" ;;
				esac
				echo

				echo -e "${YELLOW} = = > Disable Subtitles By Default?${NC}"
				echo -e "${CYAN}     1) Yes${NC}"
				echo -e "${CYAN}     2) No${NC}"
				prompt_menu_choice " = = > Select [1/2]: " choice
				case "$choice" in
					1) SMC_BARFIX_SUBS_OFF=1 ;;
					2) SMC_BARFIX_SUBS_OFF=0 ;;
				esac
				echo

				echo -e "${YELLOW} = = > Title Naming Mode${NC}"
				echo -e "${CYAN}     1) After SxxExx${NC}"
				echo -e "${CYAN}     2) Full Filename${NC}"
				echo -e "${CYAN}     3) Skip Title Set${NC}"
				echo -e "${CYAN}     4) Choose Segment Number${NC}"
				prompt_menu_choice " = = > Select [1-4]: " choice
				case "$choice" in
					1) SMC_BARFIX_TITLE_MODE="after_sxxexx" ;;
					2) SMC_BARFIX_TITLE_MODE="full_filename" ;;
					3) SMC_BARFIX_TITLE_MODE="skip" ;;
					4) SMC_BARFIX_TITLE_MODE="segment"
						prompt_read " = = > Start Title At Segment Number: " SMC_BARFIX_TITLE_SEGMENT
						;;
				esac
				echo

				echo -e "${GR} = = > Barfix Lite Vars Updated.${NC}"
				smartcut_save_sticky_session
				pause
				choice=""
				;;

			*)
				echo -e "${YE} = = > Invalid Selection.${NC}"
				pause
				choice=""
				;;
		esac
	done
}

run_smartcut_menu() {
	local choice

	have_smartcut || {
		echo -e "${REB} = = > No SmartCut engine found.${NC}"
		echo -e "${CYAN} = = > Install:${NC} ${YELLOW}pipx install smartcut${NC}"
		pause
		return 1
	}

	# ================================================================
	# #MARKER: SMC DEFAULT SEEDS
	# ================================================================
	TIP_TRIM_SECONDS="${TIP_TRIM_SECONDS:-0}"
	TAIL_TRIM_SECONDS="${TAIL_TRIM_SECONDS:-0}"
	TIP_OFFSET_SECONDS="${TIP_OFFSET_SECONDS:-0}"
	INTRO_PAD_BEFORE_SECONDS="${INTRO_PAD_BEFORE_SECONDS:-0}"
	INTRO_PAD_AFTER_SECONDS="${INTRO_PAD_AFTER_SECONDS:-0}"
	OUTRO_PAD_BEFORE_SECONDS="${OUTRO_PAD_BEFORE_SECONDS:-0}"
	SMC_BARFIX_LITE_ENABLED="${SMC_BARFIX_LITE_ENABLED:-1}"
	# Audio default (eng / jpn / spa / fra / deu / skip)
	SMC_BARFIX_AUDIO_LANG="${SMC_BARFIX_AUDIO_LANG:-eng}"
	# Subtitles off by default (1=off, 0=leave)
	SMC_BARFIX_SUBS_OFF="${SMC_BARFIX_SUBS_OFF:-1}"
	# Title mode (after_sxxexx / full_filename / segment / skip)
	SMC_BARFIX_TITLE_MODE="${SMC_BARFIX_TITLE_MODE:-after_sxxexx}"
	# Segment start (only used if mode=segment)
	SMC_BARFIX_TITLE_SEGMENT="${SMC_BARFIX_TITLE_SEGMENT:-3}"

	while true; do
		clear
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN}                     SMARTCUT MAIN MENU                     ${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo

		echo -e "${YELLOW}     1) Run SmartCut Batch (CSV-driven, no prompts)${NC}"
		echo -e "${YELLOW}     2) Run SmartCut Single File / Manual Cut Plan${NC}"
		echo -e "${YELLOW}     3) Set Session VarZ${NC}"
		echo -e "${YELLOW}     4) Build Trim-Only Batch Map${NC}"
		echo -e "${YELLOW}     5) Batch Normalize To Mkv Tool${NC}"
		echo -e "${YELLOW}     6) SMC Custom Cutz${NC}"
		echo -e "${YELLOW}     7) View Maps / Logs${NC}"
		echo -e "${YELLOW}     8) Cleanup / Finalize${NC}"
		echo -e "${YELLOW}     9) Create SmartCut Templates${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo

		prompt_menu_choice " = = > Select Option [1-9 | 0.=return]: " choice

		if is_exit_token "$choice"; then
			return 0
		fi

		case "$choice" in

			1)
				smartcut_from_csv
				;;
			2)
				echo -e "${CYAN}============================================================${NC}"
				echo -e "${CYAN} = = > SMARTCUT SINGLE FILE (MANUAL CUT PLAN)${NC}"
				echo -e "${CYAN}============================================================${NC}"
				echo

				# --------------------------------------------------------
				# PICK FILE
				# --------------------------------------------------------
				shopt -s nullglob nocaseglob
				targets=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
				shopt -u nocaseglob

				if (( ${#targets[@]} == 0 )); then
					echo -e "${REB} = = > No Eligible Files Found.${NC}"
					pause
					continue
				fi

				if ! limit_targets_interactive targets; then
					echo -e "${YE} = = > Selection Cancelled.${NC}"
					continue
				fi

				file="${targets[0]}"

				echo
				echo -e "${CYAN} = = > Selected:${NC} ${GREEN}$file${NC}"
				echo

				# --------------------------------------------------------
				# MANUAL INPUTS
				# --------------------------------------------------------
				prompt_read " = = > Intro Start Time: " intro_start
				prompt_read " = = > Intro End Time:   " intro_end

				intro_start="$(to_seconds "$intro_start")"
				intro_end="$(to_seconds "$intro_end")"

				# Optional outro
				prompt_read " = = > Outro Start Time (blank = none): " outro_start

				if [[ -n "$outro_start" ]]; then
					outro_start="$(to_seconds "$outro_start")"
					use_outro=1
				else
					use_outro=0
				fi

				# --------------------------------------------------------
				# APPLY PADS / OFFSETS
				# --------------------------------------------------------
				intro_start_adj="$(awk -v s="$intro_start" -v o="${TIP_OFFSET_SECONDS:-0}" -v p="${INTRO_PAD_BEFORE_SECONDS:-0}" 'BEGIN{printf "%.3f", s + o - p}')"
				intro_end_adj="$(awk -v e="$intro_end"   -v p="${INTRO_PAD_AFTER_SECONDS:-0}"  'BEGIN{printf "%.3f", e + p}')"

				if (( use_outro )); then
					outro_start_adj="$(awk -v s="$outro_start" -v p="${OUTRO_PAD_BEFORE_SECONDS:-0}" 'BEGIN{printf "%.3f", s - p}')"
				fi

				# --------------------------------------------------------
				# BUILD CUT ARGS
				# --------------------------------------------------------
				# --------------------------------------------------
				# Intro Removal Segment
				# --------------------------------------------------
				# WHY:
				# - Trim-only maps may contain neutral placeholders:
				#       0.000,0.000
				# - SmartCut interprets that as a REAL cut
				# - Causes front tip trim behavior to break
				#
				# RULE:
				# - Only append intro cut if end > start
				# --------------------------------------------------
				cut_args=""

				if awk -v s="$intro_start_adj" -v e="$intro_end_adj" 'BEGIN { exit !(e > s) }'; then
					cut_args="$intro_start_adj,$intro_end_adj"
				fi

				if (( use_outro )); then
					cut_args="$cut_args,$outro_start_adj,end"
				fi

				# Tip snip
				if awk -v t="${TIP_TRIM_SECONDS:-0}" 'BEGIN{exit !(t > 0)}'; then
					cut_args="0,${TIP_TRIM_SECONDS},$cut_args"
				fi

				# Tail tuck
				if awk -v t="${TAIL_TRIM_SECONDS:-0}" 'BEGIN{exit !(t > 0)}'; then
					cut_args="$cut_args,-${TAIL_TRIM_SECONDS},end"
				fi

				# --------------------------------------------------------
				# PREVIEW
				# --------------------------------------------------------
				echo
				echo -e "${CYAN}============================================================${NC}"
				echo -e "${CYAN} = = > CUT PLAN PREVIEW${NC}"
				echo -e "${CYAN}============================================================${NC}"
				echo
				echo -e "${CYAN} = = > File:${NC} ${GREEN}$file${NC}"
				echo -e "${CYAN} = = > Cut Args:${NC} ${YELLOW}$cut_args${NC}"
				smc_explain_cut_plan "$cut_args"
				echo

				if ! ask_yes_no " = = > Proceed? (y/n or 1/2): "; then
					echo -e "${YE} = = > Cancelled.${NC}"
					continue
				fi

				# --------------------------------------------------------
				# PREP OUTPUT (OEM + PREFIX)
				# --------------------------------------------------------
				out="$(build_stage_output_name "SMC" "$file")"

				echo
				echo -e "${CYAN} = = > Running SmartCut...${NC}"
				echo

				"$SMC_BIN" "$file" "$out" --cut "$cut_args"

				if [[ $? -eq 0 ]]; then
					echo -e "${GR} = = > SMC MANUAL COMPLETE:${NC} ${GREEN}$out${NC}"

				if [[ "${PILOT_MODE:-0}" == "1" ]]; then
					echo -e "${YE} = = > Pilot Mode: Original Left In Working Directory For Redo Safety.${NC}"
				else
					stage_archive_file "$file" "SMC"
				fi

					file="$out"

					if [[ "${SMC_BARFIX_LITE_ENABLED:-1}" == "1" ]]; then
						run_barfix_lite_on_file "$file"
					fi
				else
					echo -e "${REB} = = > SMC MANUAL FAILED:${NC} ${GREEN}$file${NC}"
				fi

				echo
				pause
				;;
			3)
				smartcut_session_varz_menu
				;;
			4)
				run_smartgap_trim_only_batch_mode
				;;
			5)
				run_batch_normalize_to_mkv_tool
				;;
			6)
				run_clip_join_triage_menu        # placeholder for now
				;;
			7)
				log_looker     # or existing view functions
				;;
			8)
				run_finalize_menu
				;;
			9)
				create_template_smc
				;;
			*)
				echo -e "${YE} = = > Invalid Selection.${NC}"
				pause
				;;
		esac
	done
}

# =========================
# #MARKER: SMARTGAP WORKFLOW MENU
# =========================
# PURPOSE:
# - Put SMARTGAP-Related Actions Under One Workflow Stage
# - Keep Batch Cutting And Clip-Joining In The Same Surgery Area
# - Preserve Existing SMARTGAP Engine While Adding A Simple Join Tool
#
run_smartgap_menu() {
    while true; do
        clear
        echo -e "${CYAN}================================================${NC}"
        echo -e "${CYAN}                 RUN SMARTGAP                     ${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     1) Old Pilot Run Go To SmartCut Now"
        echo "     2) Old Full Batch Go To SmartCut Now"
        echo "     3) Create An intro_map.csv For Batch Tip/Tail Trim Jobs"
        echo "     4) Old Global Trim / Pad Controls Go To SmartCut Now"
        echo "     5) Join Two Clips Into One"
        echo -e "${CYAN}     6) SmartCut / SMCUT Tools${NC}${YEB}< = = = GO HERE${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     10-key exit > 0. (or q) Enter to quit"
        echo

        read -r -p "     Choice: ${NC}${GREEN}" smartgap_choice
        echo -e "${NC}"
        smartgap_choice="${smartgap_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$smartgap_choice"; then
    	    return 0
        fi

        case "$smartgap_choice" in
			1)
				echo
				echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
				echo -e "${CYAN}      = = > SMARTGAP PILOT RUN (STRONGLY RECOMMENDED)${NC}"
				echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
				echo
				echo -e "${YELLOW}     Purpose:"
				echo -e "       • Validate intro timing, trim accuracy, and seam quality"
				echo -e "       • Before committing to a full batch run."
				echo
				echo -e "     Why Pilot Run Matters:"
				echo -e "       • Confirms intro alignment is correct"
				echo -e "       • Verifies pre-trim and post-trim timing"
				echo -e "       • Detects drift or padding issues early"
				echo -e "       • Prevents full-batch mistakes"
				echo
				echo -e "     What This Will Do:"
				echo -e "       • Select 3 sample episodes from intro_map.csv"
				echo -e "       • Run SMARTGAP using those entries only"
				echo -e "       • Output files as PILOT_SMC_*"
				echo -e "       • Pause for inspection before continuing${NC}"
				echo

				echo -e "${CYAN} = = > Tip: Review results carefully before full run.${NC}"
				echo -e "${CYAN} = = > You may adjust pre/post trim values if needed.${NC}"
				echo

				#echo -e "${CYAN} = = > Optional: Inspect Show Notes (timing references)${NC}"
				#inspect_show_notes || true
				#echo

				echo -e "${YELLOW} = = > Press ENTER To Prepare Pilot Run...${NC}"
                read -r

				if [[ ! -f "intro_map.csv" ]]; then
					echo -e "${REB} = = > Pilot Run Cannot Start:${NC}${YELLOW} intro_map.csv not found.${NC}"
					echo -e "${YELLOW} = = > Build Or provide intro_map.csv First, Then Run Pilot Mode.${NC}"
					echo
					pause
					return 0
				fi

				# ========================================================
				# BACKUP ORIGINAL MAP intro_map.csv If Found By The Above Look For Command
				# ========================================================
				ORIG_MAP="$INTRO_MAP"
				BACKUP_MAP="GOOD_intro_map.csv"
				PILOT_MAP="intro_map.csv"

				if [[ -f "$ORIG_MAP" ]]; then
					mv "$ORIG_MAP" "$BACKUP_MAP"
					echo -e "${YE} = = > NOTICE: For This Temp Run intro_map.csv Renamed.${NC}"
					echo -e "${YE} = = > Backup Preserved You Can Find Your Original Named >${NC} ${GREEN}$BACKUP_MAP${NC}"
					echo
				else
					echo -e "${RE} = = > intro_map.csv Not Found.${NC}"
					break
				fi

				# ========================================================
				# BUILD PILOT MAP (3 RANDOM)
				# ========================================================
				echo -e "${CYAN} = = > Building Pilot Map...${NC}"

				head -n 1 "$BACKUP_MAP" > "$PILOT_MAP"

				if command -v shuf >/dev/null 2>&1; then
					tail -n +2 "$BACKUP_MAP" | shuf | head -n 3 >> "$PILOT_MAP"
				else
					tail -n +2 "$BACKUP_MAP" | head -n 3 >> "$PILOT_MAP"
				fi

				echo -e "${GREEN} = = > Pilot Map Ready:${NC} $PILOT_MAP"
				echo

				# ========================================================
				# PILOT RUN LOOP
				# ========================================================
				while true; do

					PILOT_MODE=1

					echo -e "${CYAN} = = > Starting Pilot Run...${NC}"
					echo

					#prompt_normalize_first_workflow
                    PILOT_MODE=1
					run_smartgap

					echo
					echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
					echo -e "${CYAN}      = = > PILOT RUN COMPLETE${NC}"
					echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
					echo

					echo -e "${YELLOW}     Review:"
					echo -e "       Inspect PILOT_SMC_* outputs"
					echo -e "       Confirm Timing And Seam Quality"
					echo

					echo "       1) Proceed To FULL Run"
					echo "       2) Re-Run pilot (Same 3 Files)"
					echo "       3) Re-Run pilot (New Random 3)"
					echo "       4) Cancel And Restore${NC}"

                    echo -e "${YELLOW}      = = > Choose: ${NC}"
                    read -r pilot_choice
					case "$pilot_choice" in
						1)
							remove_all_pilot_outputs
							echo -e "${GREEN} = = > Proceeding To Full Run...${NC}"

							rm -f "$PILOT_MAP"
							mv "$BACKUP_MAP" "$ORIG_MAP"
							echo -e "${CYAN} = = > Backup Restored To Your Original Named >${NC} ${GREEN}intro_map.csv${NC}"

							PILOT_MODE=0
							run_smartgap
							break
							;;

						2)
							echo -e "${CYAN} = = > Re-running Pilot (same set)...${NC}"
							pilot_redo_session
							;;

						3)
							echo -e "${CYAN} = = > Generating New Pilot Set...${NC}"

							pilot_redo_session

							head -n 1 "$BACKUP_MAP" > "$PILOT_MAP"

							if command -v shuf >/dev/null 2>&1; then
								tail -n +2 "$BACKUP_MAP" | shuf | head -n 3 >> "$PILOT_MAP"
							else
								tail -n +2 "$BACKUP_MAP" | head -n 3 >> "$PILOT_MAP"
							fi
							;;

						*)
							echo -e "${YELLOW} = = > Pilot Cancelled. Restoring original map...${NC}"

							pilot_abort_recovery

							rm -f "$PILOT_MAP"

							if [[ -f "$BACKUP_MAP" ]]; then
								mv "$BACKUP_MAP" "$ORIG_MAP"
							fi

							PILOT_MODE=0

							echo -e "${YELLOW} = = > Backup Restored To Your Original Named >${NC} ${GREEN}intro_map.csv${NC}"

							break
							;;
					esac
				done
				;;
            2)
                #prompt_normalize_first_workflow # reserved for future rusty
                #PILOT_MODE=0
                run_smartcut_menu
                ;;
            3)
                run_smartgap_trim_only_batch_mode
                ;;
            4)
                #prompt_normalize_first_workflow # reserved for future rusty
                run_smartcut_menu
                ;;
            5)
                run_join_two_clips
                ;;
            6)
                run_smartcut_menu
                ;;
            [Qq])
                return 0
                ;;
            *)
                echo -e "${REB} = = > Invalid.${NC}"
                pause
                ;;
        esac
    done
}

# =========================
# #MARKER: JOIN TWO CLIPS
# =========================
# PURPOSE:
# - Join Two User-Selected Full Clips From The Current Working Directory
# - Useful For Part 1 + Part 2 Style Episodes After Processing Is Complete
#
# IMPORTANT:
# - This Is Working-Directory Only
# - User Selects Part 1 And Part 2 Manually
# - Best Used After All Intro Cuts / Trims / Title Work Are Complete
# - But Has Nothing Top Do With Intro Cutting Just A Tool Added For You
# - To Join Any 2 Clips Together Whatever The Quality
#
run_join_two_clips() {
    local -a join_sources
    local part1 part2 join_tmpdir join_list out base1

    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}             JOIN TWO CLIPS INTO ONE            ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${YELLOW} Use This After All Intro Processing, Snips, Clips, And Title Work.${NC}"
    echo -e "${YELLOW} = = > Select Part 1 first,  = = > then Part 2.${NC}"
    echo

    shopt -s nullglob nocaseglob
    join_sources=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
    shopt -u nullglob nocaseglob

    if [[ ${#join_sources[@]} -eq 0 ]]; then
        echo -e "${RE} = = > No Video Files Found In Current Working Directory.${NC}"
        pause
        return 1
    fi

    echo -e "${CYAN} = = > Select Part 1:${NC}"
    select part1 in "${join_sources[@]}"; do
        [[ -n "${part1:-}" ]] && break
    done

    echo
    echo -e "${CYAN} = = > Select Part 2:${NC}"
    select part2 in "${join_sources[@]}"; do
        [[ -n "${part2:-}" ]] && break
    done

    base1="${part1%.*}"
    out="JOINED_${base1}.mkv"

    echo
    echo -e "${CYAN} = = > Part 1:${NC} $part1"
    echo -e "${CYAN} = = > Part 2:${NC} $part2"
    echo -e "${CYAN} = = > Output:${NC} $out"
    echo

    if ! ask_yes_no " = = > Proceed With Join? (y/n): "; then
        echo -e "${YELLOW} = = > Join Canceled.${NC}"
        pause
        return 0
    fi

    join_tmpdir="_join_two_clips_tmp"
    rm -rf "$join_tmpdir"
    mkdir -p "$join_tmpdir"
    join_list="$join_tmpdir/join.txt"

    printf "file '%s/%s'\n" "$(pwd)" "$part1" > "$join_list"
    printf "file '%s/%s'\n" "$(pwd)" "$part2" >> "$join_list"

    echo
    echo -e "${CYAN} = = > Joining Clips...${NC}"

    if ffmpeg -hide_banner -loglevel error -nostdin \
        -f concat -safe 0 -i "$join_list" \
        -c copy "$out" -y; then
        echo -e "${GR} = = > Joined Output Created: $out${NC}"
    else
        echo -e "${REB} = = > Join failed.${NC}"
        echo -e "${YE} = = > Tip:Both Files Should Be Similarly Prepared Before Joining.${NC}"
    fi

    rm -rf "$join_tmpdir"
    pause
    return 0
}

# =========================
# #MARKER: TRIAGE WORKING-FILE PICKER
# =========================
# PURPOSE:
# - Let Working-Dir Surgery Tools Pick Almost Any Video File In The Folder
# - Unlike the stricter raw-source picker, this one intentionally allows:
#     REKEY_
#     SMC_
#     BARFIX_
#     TIPSNIP_
#     TAILTUCK_
#     PILOT_SMC_
#
# DESIGN:
# - This is for "work on whatever file is here now"
# - Only hide things that are not real working targets
#
# OUTPUT:
# - Prints chosen filename on stdout
# - Returns 0 on success
# - Returns 1 on cancel / no valid files
# =========================
triage_choose_single_working_file() {
	local choice
	local -a vids=()
	local -a candidates=()
	local f i

	shopt -s nullglob nocaseglob
	vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	for f in "${vids[@]}"; do
		# Hide only things that are clearly not normal working targets
		[[ "$f" =~ ^(OEM_|SUBPACKED_) ]] && continue
		candidates+=("$f")
	done

	if (( ${#candidates[@]} == 0 )); then
		echo >&2
		echo -e "${YE} = = > No Eligible Working Video Files Found In This Directory.${NC}" >&2
		pause
		return 1
	fi

	while true; do
		clear >&2
		echo -e "${CYAN}================================================${NC}" >&2
		echo -e "${CYAN}         TRIAGE / SURGERY WORKING-FILE PICKER   ${NC}" >&2
		echo -e "${CYAN}================================================${NC}" >&2
		echo >&2

		for ((i=0; i<${#candidates[@]}; i++)); do
			echo -e "${YELLOW}    $((i+1))) ${GREEN}${candidates[$i]}${NC}" >&2
		done

		echo >&2
		echo -e "${YELLOW}    0.) Return${NC}" >&2
		echo >&2

		echo -ne "${YELLOW}     Choice: ${NC}${GREEN}" >&2
		read -r choice
		echo -e "${NC}" >&2

		choice="${choice//[[:space:]]/}"
		choice="${choice,,}"

		if is_exit_token "$choice"; then
			return 1
		fi

		if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#candidates[@]} )); then
			printf '%s\n' "${candidates[$((choice-1))]}"
			return 0
		fi

		echo >&2
		echo -e "${REB} = = > Invalid Selection.${NC}" >&2
		pause
	done
}


# =========================
# #MARKER: TRIAGE ONE-FILE SOURCE PICKER
# =========================
# PURPOSE:
# - Let Triage / Surgery tools pick one real working-dir source file
# - Exclude generated workflow outputs so user sees the raw/main candidates
#
# OUTPUT:
# - Prints chosen filename on stdout
# - Returns 0 on success
# - Returns 1 on cancel / no valid files
# =========================
triage_choose_single_source_file() {
	local choice
	local -a vids=()
	local -a candidates=()
	local f i

	shopt -s nullglob nocaseglob
	vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	for f in "${vids[@]}"; do
		[[ "$f" =~ ^(REKEY_|SMC_|BARFIX_|SUBPACKED_|OEM_|PILOT_SMC_|TIPSNIP_|TAILTUCK_) ]] && continue
		candidates+=("$f")
	done

	if (( ${#candidates[@]} == 0 )); then
		echo >&2
		echo -e "${YE} = = > No Eligible Source Video Files Found In This Working Directory.${NC}" >&2
		pause
		return 1
	fi

	while true; do
		clear >&2
		echo -e "${CYAN}================================================${NC}" >&2
		echo -e "${CYAN}           TRIAGE / SURGERY SOURCE PICKER       ${NC}" >&2
		echo -e "${CYAN}================================================${NC}" >&2
		echo >&2

		for ((i=0; i<${#candidates[@]}; i++)); do
			echo -e "${YELLOW}    $((i+1))) ${GREEN}${candidates[$i]}${NC}" >&2
		done

		echo >&2
		echo -e "${YELLOW}    0.) Return${NC}" >&2
		echo >&2

		echo -ne "${YELLOW}     Choice: ${NC}${GREEN}" >&2
		read -r choice
		echo -e "${NC}" >&2

		choice="${choice//[[:space:]]/}"
		choice="${choice,,}"

		if is_exit_token "$choice"; then
			return 1
		fi

		if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#candidates[@]} )); then
			printf '%s\n' "${candidates[$((choice-1))]}"
			return 0
		fi

		echo >&2
		echo -e "${REB} = = > Invalid Selection.${NC}" >&2
		pause
	done
}

# =========================
# #MARKER: TRIAGE ONE-FILE REKEY TOOL
# =========================
# PURPOSE:
# - Run A Single-File REKEY Rebuild From Triage Center
# - Give The User A Fast Shortcut To Cut-Friendlier Working Output
#
# NOTES:
# - Uses Current REKEY_CRF Default
# - Leaves Original Untouched
# - Output Naming:
#     REKEY_<original_stem>.mkv
# =========================
run_one_file_rekey_tool() {
	local src
	local out

	if ! src="$(triage_choose_single_source_file)"; then
		return 0
	fi

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}             ONE-FILE REKEY / NORMALIZE         ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	echo -e "${CYAN} = = > Starting REKEY CRF:${NC} ${YELLOW}$REKEY_CRF${NC}"
	echo -e "${CYAN} = = > Audio Policy:${NC} ${GREEN}copy-through${NC}"
	echo -e "${CYAN} = = > Goal:${NC} ${YELLOW}Cut-Friendlier Working Source${NC}"
	echo

	if ! ask_yes_no " = = > Proceed With One-File REKEY Build? (y/n or 1/2): "; then
		echo
		echo -e "${YE} = = > One-File REKEY Cancelled.${NC}"
		pause
		return 0
	fi

	if normalize_cut_friendly_file "$src" "$REKEY_CRF"; then
		out="REKEY_$(basename "${src%.*}").mkv"
		echo
		echo -e "${GR} = = > One-File REKEY Completed.${NC}"
		echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
	else
		echo
		echo -e "${REB} = = > One-File REKEY Failed.${NC}"
		echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
	fi

	pause
}



# =========================
# #MARKER: TRIAGE CENTER / QUICK CLIP SURGERY HELPERS
# =========================
# PURPOSE:
# - Give Utility / Advanced Tools A Fast "Bit Surgery" Hub
# - Put The Small Fast Helpers In One Place For Folder Triage Work:
#     * Clip Grab
#     * Join Two Clips
#     * One-File Normalize To MKV / Playback Defaults
#     * Rebuild / Normalize Sources To REKEY (existing batch handoff)
#     * BARFIX
#
# WHY THIS EXISTS:
# - Sometimes A Folder Is In "Custom Cut / Join / Rescue / Triage" Mode
# - Future-Me Should Not Have To Remember Which Other Stage Hides Which Tiny Tool
# - This Is A Convenience Access Hub, NOT A Rewrite Of Existing Homes
#
# IMPORTANT:
# - Clip Grab Remains In Utility / Advanced Tools
# - Join Two Clips Remains In SMARTGAP
# - BARFIX Remains In Title / Playback Land
# - Batch Normalize / REKEY Rebuild Remains In Prepare Sources
# - This Menu Only Adds Fast Side-Door Access
#
# MOTTO:
# - If Your Clip Grabs And Joins Aren't Becoming To You
# - Then You Should Be Coming To Us
#

run_one_file_normalize_to_mkv_tool() {
	# =========================
	# #MARKER: ONE-FILE NORMALIZE TO MKV / PLAYBACK DEFAULTS
	# =========================
	# PURPOSE:
	# - Let User Pick One Working-Dir Source
	# - Run Existing normalize_to_mkv() On It Directly
	#
	# BEHAVIOR:
	# - Non-MKV  -> stream-copy remux to .mkv
	# - MKV      -> applies playback defaults in-place where supported
	#
	local -a sources=()
	local src pick result

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}         ONE-FILE NORMALIZE TO MKV TOOL         ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Fast One-Off Normalize / Remux Helper.${NC}"
	echo -e "${YELLOW} = = > Good For Triage Work, Not A Full Factory Pass.${NC}"
	echo

	shopt -s nullglob nocaseglob
	sources=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	local -a filtered=()
	local f
	for f in "${sources[@]}"; do
		[[ "$f" =~ ^REKEY_ ]] && continue
		[[ "$f" =~ ^(SMC_|PILOT_SMC_) ]] && continue
		[[ "$f" =~ ^BARFIX_ ]] && continue
		[[ "$f" =~ ^SMC_ ]] && continue
		filtered+=("$f")
	done

	if [[ ${#filtered[@]} -eq 0 ]]; then
		echo -e "${RE} = = > No Eligible Source Files Found.${NC}"
		pause
		return 1
	fi

	while true; do
		echo
		echo -e "${CYAN} = = > Select File:${NC} ${YELLOW}[number | 0.=cancel | q]${NC}"
		echo

		select src in "${filtered[@]}"; do
			pick="${REPLY//[[:space:]]/}"

			# ========================================================
			# TEN-KEY EXIT HOOK
			# ========================================================
			if is_exit_token "$pick"; then
				return 0
			fi

			if [[ -n "${src:-}" ]]; then
				break 2
			fi

			echo -e "${REB} = = > Invalid Selection.${NC}"
			break
		done
	done

	echo
	echo -e "${CYAN} = = > Selected:${NC} $src"
	echo
	if ! ask_yes_no " = = > Proceed With One-File Normalize / MKV Pass? (y/n): "; then
		echo -e "${YELLOW} = = > One-File Normalize Cancelled.${NC}"
		pause
		return 0
	fi

	echo
	result="$(normalize_to_mkv "$src")"
	echo -e "${GREEN} = = > Result:${NC} $result"
	echo
	pause
}


# =========================
# #MARKER: TRIAGE TIP SNIP
# =========================
# PURPOSE:
# - Trim Time Off The Beginning Of One Selected File
# - Keep Original Untouched
#
# OUTPUT NAME:
# - TIPSNIP_<original_stem>.mkv
#
# NOTES:
# - Fast copy trim
# - Best on REKEY / keyframe-friendly sources
# - Exact edge accuracy may vary on hostile raw sources
# =========================
run_tip_snip() {
	local trim_amount
	local duration
	local src
	local out
	local ok_count=0
	local fail_count=0
	local -a targets=()
	local -a vids=()
	local f
	local cut_args

	shopt -s nullglob nocaseglob
	vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	for f in "${vids[@]}"; do
		# Triage surgery intentionally allows prior TIP / TAIL products.
		# These are single-file corrective tools, not protected batch stages.
		[[ "$f" =~ ^(OEM_|SUBPACKED_) ]] && continue
		targets+=("$f")
	done

	if (( ${#targets[@]} == 0 )); then
		echo -e "${YE} = = > No Eligible Working Video Files Found.${NC}"
		pause
		return 0
	fi

	# ----- SURGERY PICKER NATURAL FILENAME SORT ----------------------------
	# Sort by the complete filename, case-insensitive and number-aware.
	# Mixed extensions stay together instead of grouping by file type.
	# A temporary prefix such as a01_ will intentionally push a file near the top.
	mapfile -t targets < <(printf '%s\n' "${targets[@]}" | LC_ALL=C sort -fV)

	if ! limit_targets_interactive targets; then
		echo -e "${YE} = = > Tip Snip Cancelled.${NC}"
		pause
		return 0
	fi

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                  TIP SNIP TOOL                 ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > Selected Files:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo -e "${YE} = = > Fast Copy Trim.${NC}"
	echo -e "${YE} = = > Best On REKEY / Keyframe-Friendly Sources.${NC}"
	echo

	prompt_read " = = > Enter Tip Snip Amount To Remove From Beginning (seconds or HH:MM:SS | 0.=cancel): " trim_amount

	if is_exit_token "$trim_amount"; then
		return 0
	fi

	trim_amount="$(to_seconds "$trim_amount" 2>/dev/null || true)"
	if [[ -z "${trim_amount:-}" ]]; then
		echo -e "${REB} = = > Invalid Time Entry.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${CYAN} = = > Trim Amount:${NC} ${YELLOW}${trim_amount}s${NC}"
	echo -e "${CYAN} = = > Files To Process:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo

	if ! ask_yes_no " = = > Proceed With Tip Snip Batch? (y/n or 1/2): "; then
		echo
		echo -e "${YE} = = > Tip Snip Cancelled.${NC}"
		pause
		return 0
	fi

	for src in "${targets[@]}"; do
		duration="$(ffprobe -v error -show_entries format=duration \
			-of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null || true)"

		if [[ -z "${duration:-}" ]]; then
			echo -e "${REB} = = > Could Not Read Duration:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
			continue
		fi

		if ! awk -v t="$trim_amount" -v d="$duration" 'BEGIN { exit (t < d ? 0 : 1) }'; then
			echo -e "${REB} = = > Tip Snip Amount Too Large:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
			continue
		fi

		out="TIPSNIP_$(basename "${src%.*}").mkv"

		if [[ -e "$out" ]]; then
			echo -e "${YE} = = > Output Exists, Skipping:${NC} ${YELLOW}$out${NC}"
			((fail_count+=1)) || :
			continue
		fi

		if ! resolve_smc_bin; then
			echo -e "${REB} = = > SmartCut Engine Missing. Tip Snip Cannot Continue.${NC}"
			((fail_count+=1)) || :
			continue
		fi

		cut_args="0,$trim_amount"

		echo -e "${CYAN} = = > Tip Snip Cut Plan:${NC} ${YELLOW}$cut_args${NC}"
		smc_explain_cut_plan "$cut_args"

		if run_smartcut_colored "$src" "$out" "$cut_args"; then
			echo -e "${GR} = = > Tip Snip Completed:${NC} ${GREEN}$out${NC}"
			((ok_count+=1)) || :
		else
			rm -f -- "$out"
			echo -e "${REB} = = > Tip Snip Failed:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
		fi
	done

	echo
	echo -e "${CYAN} = = > Tip Snip Batch Complete.${NC}"
	echo -e "${CYAN} = = > OK:${NC} ${GREEN}$ok_count${NC}"
	echo -e "${CYAN} = = > Failed/Skipped:${NC} ${YELLOW}$fail_count${NC}"
	pause
}

# =========================
# #MARKER: TRIAGE TAIL TUCK
# =========================
run_tail_tuck() {
	local trim_amount
	local duration
	local end_time
	local src
	local out
	local ok_count=0
	local fail_count=0
	local -a targets=()
	local -a vids=()
	local f
	local cut_args

	shopt -s nullglob nocaseglob
	vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	for f in "${vids[@]}"; do
		# Triage surgery intentionally allows prior TIP / TAIL products.
		# These are single-file corrective tools, not protected batch stages.
		[[ "$f" =~ ^(OEM_|SUBPACKED_) ]] && continue
		targets+=("$f")
	done

	if (( ${#targets[@]} == 0 )); then
		echo -e "${YE} = = > No Eligible Working Video Files Found.${NC}"
		pause
		return 0
	fi

	# ----- SURGERY PICKER NATURAL FILENAME SORT ----------------------------
	# Sort by the complete filename, case-insensitive and number-aware.
	# Mixed extensions stay together instead of grouping by file type.
	# A temporary prefix such as a01_ will intentionally push a file near the top.
	mapfile -t targets < <(printf '%s\n' "${targets[@]}" | LC_ALL=C sort -fV)

	if ! limit_targets_interactive targets; then
		echo -e "${YE} = = > Tail Tuck Cancelled.${NC}"
		pause
		return 0
	fi

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}                  TAIL TUCK TOOL                ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > Selected Files:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo -e "${YE} = = > Fast Copy Trim.${NC}"
	echo -e "${YE} = = > Best On REKEY / Keyframe-Friendly Sources.${NC}"
	echo

	prompt_read " = = > Enter Tail Tuck Amount To Remove (seconds or HH:MM:SS | 0.=cancel): " trim_amount

	if is_exit_token "$trim_amount"; then
		return 0
	fi

	trim_amount="$(to_seconds "$trim_amount" 2>/dev/null || true)"
	if [[ -z "${trim_amount:-}" ]]; then
		echo -e "${REB} = = > Invalid Time Entry.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${CYAN} = = > Trim Amount:${NC} ${YELLOW}${trim_amount}s${NC}"
	echo -e "${CYAN} = = > Files To Process:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo

	if ! ask_yes_no " = = > Proceed With Tail Tuck Batch? (y/n or 1/2): "; then
		echo
		echo -e "${YE} = = > Tail Tuck Cancelled.${NC}"
		pause
		return 0
	fi

	for src in "${targets[@]}"; do
		duration="$(ffprobe -v error -show_entries format=duration \
			-of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null || true)"

		if [[ -z "${duration:-}" ]]; then
			echo -e "${REB} = = > Could Not Read Duration:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
			continue
		fi

		end_time="$(fsub "$duration" "$trim_amount")"

		if [[ -z "${end_time:-}" ]] || ! awk -v e="$end_time" 'BEGIN { exit (e > 0 ? 0 : 1) }'; then
			echo -e "${REB} = = > Tail Tuck Amount Too Large:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
			continue
		fi

		out="TAILTUCK_$(basename "${src%.*}").mkv"

		if [[ -e "$out" ]]; then
			echo -e "${YE} = = > Output Exists, Skipping:${NC} ${YELLOW}$out${NC}"
			((fail_count+=1)) || :
			continue
		fi

		if ! resolve_smc_bin; then
			echo -e "${REB} = = > SmartCut Engine Missing. Tail Tuck Cannot Continue.${NC}"
			((fail_count+=1)) || :
			continue
		fi

		cut_args="$end_time,end"

		echo -e "${CYAN} = = > Tail Tuck Cut Plan:${NC} ${YELLOW}$cut_args${NC}"
		smc_explain_cut_plan "$cut_args"

		if run_smartcut_colored "$src" "$out" "$cut_args"; then
			echo -e "${GR} = = > Tail Tuck Completed:${NC} ${GREEN}$out${NC}"
			((ok_count+=1)) || :
		else
			rm -f -- "$out"
			echo -e "${REB} = = > Tail Tuck Failed:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
		fi
	done

	echo
	echo -e "${CYAN} = = > Tail Tuck Batch Complete.${NC}"
	echo -e "${CYAN} = = > OK:${NC} ${GREEN}$ok_count${NC}"
	echo -e "${CYAN} = = > Failed/Skipped:${NC} ${YELLOW}$fail_count${NC}"
	pause
}

# =========================
# #MARKER: TRIAGE TIP + TAIL
# =========================
run_tip_and_tail() {
	local tip_amount
	local tail_amount
	local duration
	local src
	local out
	local ok_count=0
	local fail_count=0
	local -a targets=()
	local -a vids=()
	local f
	local cut_args

	shopt -s nullglob nocaseglob
	vids=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	for f in "${vids[@]}"; do
		# Triage surgery intentionally allows prior TIP / TAIL products.
		[[ "$f" =~ ^(OEM_|SUBPACKED_) ]] && continue
		targets+=("$f")
	done

	if (( ${#targets[@]} == 0 )); then
		echo -e "${YE} = = > No Eligible Working Video Files Found.${NC}"
		pause
		return 0
	fi

	# ----- SURGERY PICKER NATURAL FILENAME SORT ----------------------------
	# Sort by the complete filename, case-insensitive and number-aware.
	# Mixed extensions stay together instead of grouping by file type.
	# A temporary prefix such as a01_ will intentionally push a file near the top.
	mapfile -t targets < <(printf '%s\n' "${targets[@]}" | LC_ALL=C sort -fV)

	if ! limit_targets_interactive targets; then
		echo -e "${YE} = = > Tip + Tail Cancelled.${NC}"
		pause
		return 0
	fi

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}               TIP + TAIL SURGERY               ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > Selected Files:${NC} ${YELLOW}${#targets[@]}${NC}"
	echo -e "${YE} = = > Both Ends Will Be Trimmed In One SmartCut Operation.${NC}"
	echo

	prompt_read " = = > Tip Amount To Remove From Beginning (seconds or HH:MM:SS | 0.=cancel): " tip_amount

	if is_exit_token "$tip_amount"; then
		return 0
	fi

	tip_amount="$(to_seconds "$tip_amount" 2>/dev/null || true)"

	if [[ -z "${tip_amount:-}" ]]; then
		echo -e "${REB} = = > Invalid Tip Time Entry.${NC}"
		pause
		return 0
	fi

	prompt_read " = = > Tail Amount To Remove From Ending (seconds or HH:MM:SS | 0.=cancel): " tail_amount

	if is_exit_token "$tail_amount"; then
		return 0
	fi

	tail_amount="$(to_seconds "$tail_amount" 2>/dev/null || true)"

	if [[ -z "${tail_amount:-}" ]]; then
		echo -e "${REB} = = > Invalid Tail Time Entry.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${CYAN} = = > Tip Remove:${NC}  ${YELLOW}${tip_amount}s${NC}"
	echo -e "${CYAN} = = > Tail Remove:${NC} ${YELLOW}${tail_amount}s${NC}"
	echo -e "${CYAN} = = > Files:${NC}       ${YELLOW}${#targets[@]}${NC}"
	echo

	if ! ask_yes_no " = = > Proceed With Combined Tip + Tail Surgery? (y/n or 1/2): "; then
		echo -e "${YE} = = > Tip + Tail Cancelled.${NC}"
		pause
		return 0
	fi

	if ! resolve_smc_bin; then
		echo -e "${REB} = = > SmartCut Engine Missing. Tip + Tail Cannot Continue.${NC}"
		pause
		return 0
	fi

	for src in "${targets[@]}"; do
		duration="$(ffprobe -v error -show_entries format=duration \
			-of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null || true)"

		if [[ -z "${duration:-}" ]]; then
			echo -e "${REB} = = > Could Not Read Duration:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
			continue
		fi

		if ! awk -v tip="$tip_amount" -v tail="$tail_amount" -v d="$duration" \
			'BEGIN { exit ((tip + tail) < d ? 0 : 1) }'; then
			echo -e "${REB} = = > Combined Tip + Tail Amounts Consume Entire File:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
			continue
		fi

		out="TIPSNIP_TAILTUCK_$(basename "${src%.*}").mkv"

		if [[ -e "$out" ]]; then
			echo -e "${YE} = = > Output Exists, Skipping:${NC} ${YELLOW}$out${NC}"
			((fail_count+=1)) || :
			continue
		fi

		cut_args="0,$tip_amount,-$tail_amount,end"

		echo
		echo -e "${CYAN} = = > Source:${NC} ${GREEN}$src${NC}"
		echo -e "${CYAN} = = > Tip + Tail Cut Plan:${NC} ${YELLOW}$cut_args${NC}"
		smc_explain_cut_plan "$cut_args"

		if run_smartcut_colored "$src" "$out" "$cut_args"; then
			echo -e "${GR} = = > Tip + Tail Completed:${NC} ${GREEN}$out${NC}"
			((ok_count+=1)) || :
		else
			rm -f -- "$out"
			echo -e "${REB} = = > Tip + Tail Failed:${NC} ${YELLOW}$src${NC}"
			((fail_count+=1)) || :
		fi
	done

	echo
	echo -e "${CYAN} = = > Tip + Tail Surgery Complete.${NC}"
	echo -e "${CYAN} = = > OK:${NC} ${GREEN}$ok_count${NC}"
	echo -e "${CYAN} = = > Failed/Skipped:${NC} ${YELLOW}$fail_count${NC}"
	pause
}

compare_two_files() {
	local a b
	if ! pick_file a "COMPARE FILE A"; then return 0; fi
	if ! pick_file b "COMPARE FILE B"; then return 0; fi
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}              AUDLAB BEFORE / AFTER COMPARE     ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${CYAN} = = > FILE A:${NC} ${GREEN}$a${NC}"
	audlab_truth_compact "$a" | awk -F'|' -v CYAN="$CYAN" -v GREEN="$GREEN" -v YELLOW="$YELLOW" -v WHITE="$WHITE" -v NC="$NC" '{printf "%s     duration=%s%s %ssize=%s%s %svideo=%s%s %saudio=%s%s %ssubs=%s%s %svcodec=%s%s %sacodec=%s%s %spix=%s%s %sres=%s%s\n", WHITE,YELLOW,$1,WHITE,YELLOW,$2,WHITE,GREEN,$3,WHITE,GREEN,$4,WHITE,GREEN,$5,WHITE,GREEN,$6,WHITE,GREEN,$7,WHITE,GREEN,$8,WHITE,GREEN,$9}'
	echo
	echo -e "${CYAN} = = > FILE B:${NC} ${GREEN}$b${NC}"
	audlab_truth_compact "$b" | awk -F'|' -v CYAN="$CYAN" -v GREEN="$GREEN" -v YELLOW="$YELLOW" -v WHITE="$WHITE" -v NC="$NC" '{printf "%s     duration=%s%s %ssize=%s%s %svideo=%s%s %saudio=%s%s %ssubs=%s%s %svcodec=%s%s %sacodec=%s%s %spix=%s%s %sres=%s%s\n", WHITE,YELLOW,$1,WHITE,YELLOW,$2,WHITE,GREEN,$3,WHITE,GREEN,$4,WHITE,GREEN,$5,WHITE,GREEN,$6,WHITE,GREEN,$7,WHITE,GREEN,$8,WHITE,GREEN,$9}'
	audlab_log_compare "MANUAL_COMPARE" "$a" "$b" "manual_compare"
	echo
	echo -e "${GR} = = > Compare logged to:${NC} ${GREEN}$AUDLAB_LOG${NC}"
	echo
	pause
}

run_tip_tail_surgery_menu() {
	local surgery_choice

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}               TIP / TAIL SURGERY               ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Tip Snip       (Trim Beginning)${NC}"
		echo -e "${YELLOW}     2) Tail Tuck      (Trim Ending)${NC}"
		echo -e "${YELLOW}     3) Tip + Tail     (Trim Both In One Pass)${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo

		prompt_menu_choice "     Choice: " surgery_choice

		if is_exit_token "$surgery_choice"; then
			return 0
		fi

		case "$surgery_choice" in
			1)
				run_tip_snip
				;;
			2)
				run_tail_tuck
				;;
			3)
				run_tip_and_tail
				;;
			*)
				echo -e "${REB} = = > Invalid.${NC}"
				pause
				;;
		esac
	done
}


run_clip_join_triage_menu() {
	local triage_choice

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}        TRIAGE CENTER / CLIP SURGERY TOOLS      ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Clip_Grab BitZ From VidZ${NC}"
		echo -e "${YELLOW}     2) Join Two Clips Into One${NC}"
		echo -e "${YELLOW}     3) Tip / Tail Surgery${NC}"
		echo -e "${YELLOW}     4) Reserved / Future Triage Tool${NC}"
		echo -e "${YELLOW}     5) One-File Normalize To MKV / Playback Defaults${NC}"
		echo -e "${YELLOW}     6) Rekey This File First${NC}"
		echo -e "${YELLOW}     7) BARFIX Title + Playback Tools${NC}"
		echo
		echo -e "${YELLOW}     0.) Return  (or q)  =  Quit${NC}"
		echo
		echo -e "${CYAN} = = > If Your Clip Grabs And Joins Aren't Becoming To You${NC}"
		echo -e "${CYAN}= = = = = = = = = = = = = = = = = = = = = = = = = = = = = ${NC}"
		echo -e "${CYAN} = = > Then You Should Be Coming To Us${NC}"
		echo -e "${CYAN}= = = = = = = = = = = = = = = = = = = = = = = = = = = = = ${NC}"
		echo

		prompt_menu_choice "     Choice: " triage_choice

		if is_exit_token "$triage_choice"; then
			return 0
		fi

		case "$triage_choice" in
			1)
				run_custom_cut
				;;
			2)
				run_join_two_clips
				;;
			3)
				run_tip_tail_surgery_menu
				;;
			4)
				echo
				echo -e "${YE} = = > Option 4 Is Reserved For A Future Triage Tool.${NC}"
				pause
				;;
			5)
				run_one_file_normalize_to_mkv_tool
				;;
			6)
				run_one_file_rekey_tool
				;;
			7)
				run_barfix
				;;
			*)
				echo -e "${REB} = = > Invalid.${NC}"
				pause
				;;
		esac
	done
}

run_probes_menu() {
	local probes_choice

	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}                  PROBES / DIAGNOSTICS          ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Diff Two Local Files${NC}"
		echo -e "${YELLOW}     2) Keyframe Probe${NC}"
		echo -e "${YELLOW}     3) Media Truth Probe${NC}"
		echo -e "${YELLOW}     4) Dependency Status${NC}"
		echo -e "${YELLOW}     5) Startup Diagnostics / Operating Mode${NC}"
		echo -e "${YELLOW}     6) Reykey One File${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo

		prompt_menu_choice " = = > Select Option [1-6 | 0.=return]: " probes_choice

		if is_exit_token "$probes_choice"; then
			return 0
		fi

		case "$probes_choice" in
			1)
				compare_two_files
				;;
			2)
				inspect_run_keyframe_probe
				;;
			3)
				run_video_truth_probe_menu
				;;
			4)
				inspect_dependencies
				;;
			5)
				show_startup_diagnostics
				pause
				;;
			6)
				run_one_file_rekey_tool
				;;
			*)
				echo -e "${REB} = = > Invalid.${NC}"
				pause
				;;
		esac
	done
}


# =========================
# #MARKER: UTILITY / ADVANCED TOOLS MENU
# =========================
# PURPOSE:
# - Hold Safe Utility Tools That Do Not Alter Core Workflow Engines
# - Keep Redundant-But-Useful Quick Checks Available From One Place
#
# CURRENT SAFE SCOPE:
# - Show Templates
# - Show Working-Folder Target Files
# - Diff Two Files
# - REKEY Validity Check
# - Keyframe Cut-Friendliness Check
# - Triage Center / Clip Surgery Tools
# - Dependency Status / System Readiness Check
#
# IMPORTANT:
# - This menu is the right home for diagnostic / informational tools.
# - Dependency inspect belongs here because it is:
#     * non-destructive
#     * useful on any machine
#     * helpful for troubleshooting partial installs
# - Triage Center is a convenience access point, not a replacement for
#   Prepare Sources, SMARTGAP, or BARFIX's other homes.
#
run_utility_menu() {
while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}              UTILITY / ADVANCED TOOLS          ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Audio Triage Center${NC}"
		echo -e "${YELLOW}     2) Video Rescue Dirty / AVI${NC}"
		echo -e "${YELLOW}     3) Probes / Diagnostics${NC}"
		echo -e "${YELLOW}     4) REKEY Preference / Normalize-First Controls${NC}"
		echo -e "${YELLOW}     5) Clip / Join Triage${NC}"
		echo -e "${YELLOW}     6) Twisted Color Menu${NC}"
		echo -e "${YELLOW}     7) Archival Array${NC}"
		echo
		echo -e "${YELLOW}     0.) Return${NC}"
		echo

		prompt_menu_choice " = = > Select Option [1-7 | 0.=return]: " util_choice

		if is_exit_token "$util_choice"; then
			return 0
		fi

		case "$util_choice" in
			1)
				run_audio_triage_menu
				;;
			2)
				run_avi_rescue_menu
				;;
			3)
				run_probes_menu
				;;
			4)
				prepare_set_rekey_preference
				;;
			5)
				run_clip_join_triage_menu
				;;
			6)
				run_twisted_menu
				;;
			7)
				run_archival_array
				;;
			*)
				echo -e "${REB} = = > Invalid.${NC}"
				pause
				;;
		esac
	done
}

normalize_to_mkv() {
	local file="$1"
	local ext base out

	ext="${file##*.}"
	base="${file%.*}"
	out="${base}.mkv"

	# NOTE:
	# - stdout is reserved for the final usable output path only.
	# - all status chatter goes to stderr because callers use command substitution.

	# ============================================================
	# MKV IN-PLACE NORMALIZATION (LIGHT TOUCH)
	# ============================================================
		# Even If Already MKV, We May Still Want To Enforce:
		# - English Audio Default
		# - Subtitles Off
		#
		# NOTE:
		# - Uses Mkvpropedit If Available (Fast, No Remux)
		# - Falls Back To No-Op If Unavailable (Preserve Behavior)
		# ============================================================
	if [[ "${ext,,}" == "mkv" ]]; then
		if command -v mkvpropedit >/dev/null 2>&1; then
			echo -e "${CYAN} = = > Applying Playback Defaults (In-Place): $file${NC}" >&2

			mkvpropedit "$file" \
				--edit track:a1 --set flag-default=1 \
				--edit track:a1 --set language=eng \
				>/dev/null 2>&1 || true

			mkvpropedit "$file" \
				--edit track:s1 --set flag-default=0 \
				>/dev/null 2>&1 || true
		fi

		printf '%s\n' "$file"
		return 0
	fi

	echo -e "${CYAN} = = > Converting $file → $out${NC}" >&2

	rm -f -- "$out"

	# TIER 1: SAFE CONTAINER RESCUE REMUX
	# ============================================================
	# Best case:
	# - no re-encode
	# - fast
	# - no quality loss
	# - generated timestamps when needed
	# - corrupt packets discarded instead of poisoning the stream
	#
	# FACTORY FLOOR NOTE:
	# Sometimes the video is innocent and the container paperwork is guilty.
	# This is the clipboard-straightening desk before anyone fires up the welder.
	if run_with_progress "Normalize Tier 1 Stream-Copy: $(basename "$file")" \
		ffmpeg -hide_banner -loglevel error -nostdin -y \
			-fflags +genpts+discardcorrupt \
			-err_detect ignore_err \
			-i "$file" \
			-map 0 \
			-c copy \
			-disposition:a:0 default \
			-disposition:s 0 \
			-metadata:s:a:0 language=eng \
			"$out"; then

		if [[ -s "$out" ]]; then
			echo -e "${GR} = = > Normalize Tier 1 Passed.${NC}" >&2
			printf '%s\n' "$out"
			return 0
		fi
	fi

	rm -f -- "$out"
	echo -e "${YE} = = > Normalize Tier 1 Failed. Trying Timestamp Rescue.${NC}" >&2

	# ============================================================
	# TIER 2: GENERATED TIMESTAMPS + STREAM COPY
	# ============================================================
	# Helps legacy containers that lack sane PTS/DTS timing.
	# Still tries to avoid re-encoding.
	# ============================================================
	if run_with_progress "Normalize Tier 2 GenPTS Copy: $(basename "$file")" \
		ffmpeg -hide_banner -loglevel error -nostdin -y \
			-fflags +genpts \
			-fflags +genpts+discardcorrupt \
			-err_detect ignore_err \
			-i "$file" \
			-map 0 \
			-c copy \
			-disposition:a:0 default \
			-disposition:s 0 \
			-metadata:s:a:0 language=eng \
			"$out"; then

		if [[ -s "$out" ]]; then
			echo -e "${GR} = = > Normalize Tier 2 Passed.${NC}" >&2
			printf '%s\n' "$out"
			return 0
		fi
	fi

	rm -f -- "$out"
	echo -e "${YE} = = > Normalize Tier 2 Failed. Rebuilding Audio.${NC}" >&2

	# ============================================================
	# TIER 3: COPY VIDEO + REBUILD AUDIO
	# ============================================================
	# Common fix for old AVI / XVID / MP3 timestamp mess:
	# - video stays copied
	# - audio becomes clean AAC
	# - container becomes MKV
	# ============================================================
	if run_with_progress "Normalize Tier 3 Copy Video + AAC Audio: $(basename "$file")" \
		ffmpeg -hide_banner -loglevel error -nostdin -y \
			-fflags +genpts \
			-i "$file" \
			-map 0 \
			-c:v copy \
			-c:a aac -b:a 192k \
			-c:s copy \
			-disposition:a:0 default \
			-disposition:s 0 \
			-metadata:s:a:0 language=eng \
			"$out"; then

		if [[ -s "$out" ]]; then
			echo -e "${GR} = = > Normalize Tier 3 Passed.${NC}" >&2
			printf '%s\n' "$out"
			return 0
		fi
	fi

	rm -f -- "$out"
	echo -e "${YE} = = > Normalize Tier 3 Failed. Trying Fast Full Rebuild.${NC}" >&2

	# ============================================================
	# TIER 4: FAST FULL REBUILD
	# ============================================================
	# Last-resort light rebuild:
	# - not full REKEY if you want that there is a menu for you
	# - no forced 1-second GOP machinery because smartcut is sooo good
	# - intended as rescue normalization, not precision cutting prep because smartcut is that good
	# ============================================================
	if run_with_progress "Normalize Tier 4 Fast Full Rebuild: $(basename "$file")" \
		ffmpeg -hide_banner -loglevel error -nostdin -y \
			-fflags +genpts \
			-i "$file" \
			-map 0 \
			-c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p \
			-c:a aac -b:a 192k \
			-c:s copy \
			-disposition:a:0 default \
			-disposition:s 0 \
			-metadata:s:a:0 language=eng \
			"$out"; then

		if [[ -s "$out" ]]; then
			echo -e "${GR} = = > Normalize Tier 4 Passed.${NC}" >&2
			printf '%s\n' "$out"
			return 0
		fi
	fi

	rm -f -- "$out"
	echo -e "${REB} = = > Normalize To MKV Failed All Tiers:${NC} ${YELLOW}$file${NC}" >&2
	return 1
}

keyframe_interval() {
    file="$1"

    ffprobe -loglevel error -select_streams v \
    -show_entries frame=pkt_pts_time,key_frame \
    -of csv "$file" | \
    awk -F',' '$3==1 {print $2}' | \
    awk 'NR>1{print $1-prev} {prev=$1}' | \
    awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 999}'
}

rebuild_if_needed() {
	local file="$1"
	local interval fps fps_calc out

	interval=$(keyframe_interval "$file")
	interval=${interval:-999}

	echo -e "${YELLOW} = = > Keyframe interval: ${interval}s${NC}" >&2

	if (( $(echo "$interval <= 1.0" | bc -l) )); then
		echo -e "${GREEN} = = > High Precision Detected. Rebuild Skipped.${NC}" >&2
		echo "$file"
		return
	fi

	echo -e "${CYAN} = = > Rebuilding To 1-sec GOP Precision...${NC}" >&2
	echo -e "${CYAN} = = > REKEY CRF:${NC} ${YELLOW}${REKEY_CRF}${NC} ${CYAN}(quality knob)${NC}" >&2
    echo -e "${CYAN} = = > Audio Policy:${NC} ${GREEN}copy-through${NC}" >&2

	fps=$(ffprobe -v error -select_streams v:0 \
		-show_entries stream=r_frame_rate \
		-of default=noprint_wrappers=1:nokey=1 "$file")

	if [[ -z "$fps" ]]; then
		echo -e "${RE} = = > FPS Detection Failed. Using Original.${NC}" >&2
		echo "$file"
		return
	fi

	fps_calc=$(echo "$fps" | awk -F'/' '{printf "%.0f", $1/$2}')
	out="${file%.mkv}_rebuilt.mkv"

	if run_with_progress "Rebuilding GOP Precision: $(basename "$file")" \
		ffmpeg -hide_banner -loglevel error -nostdin -y -i "$file" \
			-c:v libx264 -preset medium -crf "$REKEY_CRF" \
			-g "$fps_calc" -keyint_min "$fps_calc" \
			-sc_threshold 0 \
			-c:a copy \
			"$out"; then

		if [[ -f "$out" ]]; then
			echo -e "${GREEN} = = > Rebuild Successful.${NC}" >&2
			echo "$out"
			return
		fi
	fi

	echo -e "${REB} = = > Rebuild Failed. Using Original File.${NC}" >&2
	echo "$file"
}

# part of advanced tools=====================================================================
run_rebuild_rekey_handoff_tool() {
	# =========================
	# #MARKER: REBUILD / REKEY HANDOFF TOOL
	# =========================
	# PURPOSE:
	# - Provide Fast Access To Existing Batch REKEY Rebuild Logic
	# - Do NOT Duplicate That Engine Here
	#
	# WHY:
	# - The Real Rebuild / Tight-Keyframe Path Already Lives In Prepare Sources.
	# - This Triage Center Should Link To It, Not Clone It.
	#
	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          REBUILD / REKEY HANDOFF TOOL          ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Current Rebuild / REKEY Engine Lives In Prepare Sources.${NC}"
	echo -e "${CYAN} = = > This Opens The Existing Batch Normalizer Wrapper Directly.${NC}"
	echo

    if ask_yes_no " = = > Open Rebuild / REKEY Path Now? (y/n or 1/2): "; then
    	prepare_run_batch_normalizer_wrapper
    fi
}

# end of do over all reyey auth =======================================================================

already_outro_processed() {
	local target="$1"
	local canon base

	[[ -f "$OUTRO_MAP" ]] || return 1

	canon="$(canonical_factory_path "$target")"
	base="$(basename "$target")"

	awk -F',' -v t="$target" -v c="$canon" -v b="$base" '
		NR == 1 { next }
		$1 == t || $1 == c || $1 == b {
			found=1
			exit
		}
		END { exit found ? 0 : 1 }
	' "$OUTRO_MAP"
}

already_processed() {
	local target="$1"
	local canon base

	[[ -f "$INTRO_MAP" ]] || return 1

	canon="$(canonical_factory_path "$target")"
	base="$(basename "$target")"

	awk -F',' -v t="$target" -v c="$canon" -v b="$base" '
		NR == 1 { next }
		$1 == t || $1 == c || $1 == b {
			found=1
			exit
		}
		END { exit found ? 0 : 1 }
	' "$INTRO_MAP"
}

probe_keyframe_suitability() {
  local file="$1"
  local result
  local keyframes gaps min_gap avg_gap max_gap verdict

  result="$(ffprobe -v error -select_streams v:0 \
    -skip_frame nokey \
    -show_frames \
    -show_entries frame=best_effort_timestamp_time \
    -of default=nw=1:nk=1 "$file" 2>/dev/null \
  | awk '
      NF {
        k=$1+0
        if(count>0){
          gap=k-prev
          if(min=="" || gap<min) min=gap
          if(max=="" || gap>max) max=gap
          sum+=gap
          gaps++
        }
        prev=k
        count++
      }
      END {
        printf "keyframes=%d\n", count
        printf "gaps=%d\n", gaps
        if(gaps>0){
          printf "min_gap=%.3f\n", min
          printf "avg_gap=%.3f\n", sum/gaps
          printf "max_gap=%.3f\n", max
          if(max<=2.0) print "verdict=SAFE"
          else if(max<=5.0) print "verdict=CAUTION"
          else print "verdict=RISKY"
        } else {
          print "min_gap=NA"
          print "avg_gap=NA"
          print "max_gap=NA"
          print "verdict=UNKNOWN"
        }
      }'
  )"

  keyframes="$(echo "$result" | awk -F'=' '/^keyframes=/{print $2}')"
  gaps="$(echo "$result" | awk -F'=' '/^gaps=/{print $2}')"
  min_gap="$(echo "$result" | awk -F'=' '/^min_gap=/{print $2}')"
  avg_gap="$(echo "$result" | awk -F'=' '/^avg_gap=/{print $2}')"
  max_gap="$(echo "$result" | awk -F'=' '/^max_gap=/{print $2}')"
  verdict="$(echo "$result" | awk -F'=' '/^verdict=/{print $2}')"

  echo -e "${CYAN} = = > Keyframe Suitability Check${NC}"
  echo -e "${CYAN} = = > File:${NC} $(basename "$file")"
  echo -e "${CYAN} = = > Keyframes:${NC} ${keyframes:-0}"
  echo -e "${CYAN} = = > Avg gap:${NC} ${avg_gap:-NA}s"
  echo -e "${CYAN} = = > Max gap:${NC} ${max_gap:-NA}s"
  echo -e "${CYAN} = = > Verdict:${NC} ${verdict:-UNKNOWN}"

  case "${verdict:-UNKNOWN}" in
    SAFE)
      echo -e "${GR} = = > Copy-Based Precise Cuts Likely Suitable.${NC}"
      ;;
    CAUTION)
      echo -e "${YE} = = > Moderate Keyframe Gaps Detected. Inspect Output Carefully.${NC}"
      ;;
    RISKY)
      echo -e "${REB} = = > Large Keyframe Gaps Detected. Copy-Based Cuts May Tear Or Assemble Poorly.${NC}"
      ;;
    *)
      echo -e "${YE} = = > Could Not Determine Keyframe Suitability.${NC}"
      ;;
  esac
}

run_keyframe_suitability_check() {

	clear
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}        KEYFRAME CUT-FRIENDLINESS CHECK         ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW}PURPOSE:${NC}"
	echo -e " = = > Check if a source is suitable for precise copy-based cuts"
	echo -e " = = > Displays SAFE / CAUTION / RISKY verdict"
	echo

	# ========================================================
	# TARGET COLLECTION (reuse your standard scope)
	# ========================================================
	local -a targets=()
	mapfile -t targets < <(prepare_collect_rekey_scope_targets)

	if [[ "${#targets[@]}" -eq 0 ]]; then
		echo -e "${RE} = = > No Eligible Video Files Found.${NC}"
		echo
		pause
		return 0
	fi

	echo -e "${CYAN} = = > Available Targets:${NC}"
	echo

	local i=1
	local f
	for f in "${targets[@]}"; do
		echo "  $i) $f"
		((i++))
	done

	echo
	echo -e "${YELLOW} = = > Select File Number (or 0 to cancel): ${NC}"
	read -r choice

	if is_exit_token "$choice"; then
		echo
		return 0
	fi

	if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#targets[@]} )); then
		echo -e "${REB} = = > Invalid Selection.${NC}"
		echo
		pause
		return 0
	fi

	local selected="${targets[$((choice-1))]}"

	echo
	echo -e "${CYAN} = = > Checking:${NC} ${GREEN}$selected${NC}"
	echo

	# ========================================================
	# ACTUAL ENGINE CALL
	# ========================================================
	# NOTE:
	# - Wrap the expensive probe so the screen does not feel frozen.
	# - Do NOT call get_keyframe_verdict() again afterward.
	# - probe_keyframe_suitability already prints the verdict block.
	# ========================================================
	if run_with_progress "Probing keyframe cut-friendliness: $(basename "$selected")" \
		probe_keyframe_suitability "$selected"; then
		:
	else
		echo
		echo -e "${REB} = = > Keyframe Probe Failed.${NC}"
	fi
	echo

	pause
}


# ============================================================
# #MARKER: REKEY VALIDATION HELPERS
# ============================================================
# PURPOSE:
# - Confirm A Video File Is Readable.
# - Confirm A REKEY File Is Not Only Readable, But Also Actually Cut-Friendly.
#
is_valid_video_file() {
    local f="$1"

    [[ -f "$f" ]] || return 1
    ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$f" >/dev/null 2>&1
}

is_cut_friendly_rekey_file() {
    local f="$1"
    local verdict

    is_valid_video_file "$f" || return 1

    echo -e "${CYAN} = = > Validating REKEY Cut-Friendliness:${NC} $(basename "$f")" >&2

    verdict="$(get_keyframe_verdict "$f" 2>/dev/null || true)"

    case "$verdict" in
        SAFE|CAUTION)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================================
#  TEMPLATE BUILDER
# ============================================================

# =========================
# #MARKER: TEMPLATE SOURCE KEYFRAME PROBE
# =========================

get_keyframe_verdict() {
    local file="$1"

    ffprobe -v error -select_streams v:0 \
        -skip_frame nokey \
        -show_frames \
        -show_entries frame=best_effort_timestamp_time \
        -of default=nw=1:nk=1 "$file" 2>/dev/null \
    | awk '
        NF {
            k=$1+0
            if(count>0){
                gap=k-prev
                if(max=="" || gap>max) max=gap
            }
            prev=k
            count++
        }
        END {
            if(count<=1) {
                print "UNKNOWN"
            } else if(max<=2.0) {
                print "SAFE"
            } else if(max<=5.0) {
                print "CAUTION"
            } else {
                print "RISKY"
            }
        }'
}

# =========================
# #MARKER: TEMPLATE SOURCE REBUILD
# =========================
rebuild_cut_friendly_source() {
    local in="$1"
    local out fps fps_calc
    local old_int_trap old_term_trap

    out="REKEY_$(basename "${in%.*}").mkv"

    if is_valid_video_file "$out"; then
        echo -e "${YELLOW} = = > Rebuilt Source Already Exists: $out${NC}" >&2
        echo "$out"
        return 0
    fi

    if [[ -f "$out" ]]; then
        echo -e "${YELLOW} = = > Existing Rebuilt File Is Invalid. Removing Stale File:${NC} $out" >&2
        rm -f "$out"
    fi

    fps=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=r_frame_rate \
        -of default=noprint_wrappers=1:nokey=1 "$in" 2>/dev/null)

    fps_calc=$(echo "$fps" | awk -F'/' '{if ($2>0) printf "%.0f", $1/$2}')
    [[ -z "$fps_calc" ]] && fps_calc=24

    echo -e "${CYAN} = = > Building Cut-Friendly Rebuilt Source...${NC}" >&2

    # Preserve Existing Trap Handlers So We Can Restore Them Afterward.
    old_int_trap="$(trap -p INT || true)"
    old_term_trap="$(trap -p TERM || true)"

    # During This Rebuild Only, Ctrl+C / TERM Should Delete Partial REKEY Output.
    trap 'echo -e "\n${RE} = = > Rebuild Interrupted. Removing Incomplete File:${NC} $out" >&2; rm -f "$out"; return 130' INT TERM

    if run_with_progress "Rebuilding Source: $(basename "$in")" \
        ffmpeg -hide_banner -loglevel error -nostdin -y -i "$in" \
        -c:v libx264 -preset medium -crf 18 \
        -g "$fps_calc" -keyint_min "$fps_calc" \
        -sc_threshold 0 \
        -c:a aac -b:a 256k -ac 2 -ar 48000 \
        "$out"; then

        # Restore Prior Traps Before Leaving Success Path.
        if [[ -n "$old_int_trap" ]]; then
            eval "$old_int_trap"
        else
            trap - INT
        fi

        if [[ -n "$old_term_trap" ]]; then
            eval "$old_term_trap"
        else
            trap - TERM
        fi

        if [[ -f "$out" ]]; then
            echo "$out"
            return 0
        else
            echo -e "${RE} = = > Rebuild Reported Success But Output Missing.${NC}" >&2
            return 1
        fi
    else
        local rebuild_status=$?

        # Restore Prior Traps Before Failure Cleanup.
        if [[ -n "$old_int_trap" ]]; then
            eval "$old_int_trap"
        else
            trap - INT
        fi

        if [[ -n "$old_term_trap" ]]; then
            eval "$old_term_trap"
        else
            trap - TERM
        fi

        rm -f "$out"

        if [[ "$rebuild_status" -eq 130 ]]; then
            echo -e "${YELLOW} = = > Rebuild Canceled By User:${NC} $in" >&2
            return 130
        fi

        echo -e "${REB} = = > Rebuild Failed:${NC} $in" >&2
        return 1
    fi
}

#  OLD ASS TEMPLATE BUILDER

create_template() {

# old ways now it is smc

	# =========================
	# #MARKER: TEMPLATE SOURCE PICKER (FILTER INTERNAL OUTPUTS)
	# =========================
	# WHY:
	# - Template Builder Should Present The User With Real Source Episodes,
	#   Not Internal Working Products Created By Other Tools.
	# - Showing REKEY_ Files In The Picker Is Confusing Because The User May
	#   Not Remember Whether A Rebuilt Version Already Exists Or Why It Exists.
	# - We Therefore Hide Internal/Generated Files Here And Let The Script
	#   Detect/Reuse A Matching Rebuilt Source Automatically After Selection.
	#
	# HIDDEN FROM THIS PICKER:
	# - REKEY_          : Cut-Friendly Rebuilt Sources
	# - SMC_        : SMARTGAP Outputs
	# - BARFIX_         : BARFIX Remux Outputs
	# - intro_template* : Template Assets, Not Source Episodes
	#
	echo -e "${CYAN}=============== Template Builder ===============${NC}"
	echo
	echo -e "${CYAN} = = > Select Source Episode For Intro Template:${NC}"

	shopt -s nullglob nocaseglob
	local -a template_sources=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	local -a filtered_sources=()
	local f
	for f in "${template_sources[@]}"; do
		[[ "$f" =~ ^REKEY_ ]] && continue
		[[ "$f" =~ ^(SMC_|PILOT_SMC_) ]] && continue
		[[ "$f" =~ ^BARFIX_ ]] && continue
		[[ "$f" =~ ^intro_template ]] && continue
		[[ "$f" =~ ^SMC_ ]] && continue
		filtered_sources+=("$f")
	done

	if [[ ${#filtered_sources[@]} -eq 0 ]]; then
		echo -e "${RE} = = > No Eligible Source Episodes Found For Template Builder.${NC}"
		pause
		return 1
	fi

    local pick
    while true; do
    	echo
    	echo -ne "${CYAN} = = > Select File:${NC} ${YELLOW}[number | q=cancel]${NC}${GREEN}"
        echo
    	select src in "${filtered_sources[@]}"; do
        echo -e "${NC}"
    		pick="${REPLY//[[:space:]]/}"
            # ========================================================
            # TEN-KEY EXIT HOOK
            # ========================================================
            if is_exit_token "$pick"; then
            	return 0
            fi

    		if [[ -n "${src:-}" ]]; then
    			break 2
    		fi

    		echo -e "${RE} = = > Invalid Selection. Enter A Listed Number, or q to cancel.${NC}"
    		break
    	done
    done

    echo -e "${CYAN}     ========================================================${NC}"
    echo -e "${YELLOW}     ======> Open The File You Selected To Extract <=========${NC}"
    echo -e "${YELLOW}     ===========> intro_template.mkv From <==================${NC}"
    echo -e "${YELLOW}     ==> If You Rebuilt File Then Open That File <===========${NC}"
    echo -e "${YELLOW}     ==> Renamed With Rekey In The Title <===================${NC}"
    echo -e "${YELLOW}     ====> Get Exact Times From That File For Accuracy <=====${NC}"
    echo -e "${YELLOW}     ========> Watch It With Your Eyes To Get The <==========${NC}"
    echo -e "${YELLOW}     =====> Start And End Times To The Second <==============${NC}"
    echo -e "${YELLOW}     ==> TEMPLATE SOURCE CHECK + OPTIONAL REBUILD <==========${NC}"
    echo -e "${RED}     ===x Believe The Keyframe Suitability Check x===========${NC}"
    echo -e "${RED}     ===x If It Is Caution Or Risky x========================${NC}"
    echo -e "${RED}     ===x Your Resultant File Will Not Be Pretty x===========${NC}"
    echo -e "${RED}     ===x When It Offers To Rebuild The File Let It x========${NC}"
    echo -e "${RED}     ===x It Will Rebuild For Tight 1 Sec Keyframes And x====${NC}"
    echo -e "${RED}     ===x Better intro_template Quality And Timing x=========${NC}"
    echo -e "${YELLOW}     ==> TEMPLATE SOURCE CHECK + OPTIONAL REBUILD <==========${NC}"
    echo -e "${YELLOW}     ==> If You Rebuilt File Then Open That File <===========${NC}"
    echo -e "${YELLOW}     ==> Renamed With Rekey In The Title <===================${NC}"
    echo -e "${YELLOW}     ==> To Verify Start And End Timings <===================${NC}"
    echo -e "${CYAN}     ========================================================${NC}"

    src="$(get_preferred_source_file "$src")"

	# old #MARKER: TEMPLATE EXISTING REKEY DETECTION function used to live here thios can be removed after a short while

    # =========================
    # #MARKER: TEMPLATE SOURCE CHECK + OPTIONAL REBUILD
    # =========================

    # =========================
    # #MARKER: TEMPLATE SOURCE CHECK + OPTIONAL REBUILD
    # =========================

    local cached_src_verdict cached_src_checked
    cached_src_verdict="$(info_get_keyframe_verdict_by_working "$src" 2>/dev/null || true)"
    cached_src_checked="$(info_get_keyframe_checked_path_by_working "$src" 2>/dev/null || true)"

    # ========================================================
    # CACHE-AWARE DISPLAY REUSE
    # --------------------------------------------------------
    # PURPOSE:
    # - If We Already Selected A Trusted Cached REKEY Source
    #   And Its Raw Signature Is Still Current, do NOT pay the
    #   keyframe suitability probe cost again just to redraw
    #   the same verdict/info on screen.
    #
    # DESIGN:
    # - Reuse cached display fields when available
    # - Fall back to live probe only when cache display info
    #   has not been recorded yet
    # ========================================================
    if [[ -n "${cached_src_verdict:-}" && -n "${cached_src_checked:-}" ]]; then
        src_verdict="$cached_src_verdict"
        src_checked="$cached_src_checked"
        echo -e "${GREEN} = = > Using Cached Keyframe Suitability Display...${NC}"
    else
        echo -e "${CYAN} = = > Checking Source Keyframe Suitability...${NC}"
        probe_keyframe_suitability "$src" || true

        src_verdict="$(get_keyframe_verdict "$src" 2>/dev/null || true)"
        src_verdict="${src_verdict:-UNKNOWN}"
        src_checked="$src"

        # ----------------------------------------------------
        # ONE-TIME DISPLAY CACHE WRITE
        # ----------------------------------------------------
        # WHY:
        # - If this source already has a ledger row, enrich it
        #   with the checked-path so future screens can redraw
        #   without paying the probe cost again.
        # ----------------------------------------------------
        record_working_source_state "$src" "$src" "1" "1" "$src_verdict" "$src_checked"
    fi

    # Assign color based on verdict (SAFE=green, CAUTION=yellow, RISKY=red)
    case "$src_verdict" in
        SAFE) verdict_color="$GR" ;;
        CAUTION) verdict_color="$YE" ;;
        RISKY) verdict_color="$REB" ;;
        *) verdict_color="$NC" ;;
    esac

    echo -e "${CYAN} = = > Source Keyframe Verdict:${NC} ${verdict_color}${src_verdict}${NC}"
    echo -e "${CYAN} = = > Source Checked:${NC} ${GREEN}${src_checked}${NC}"

    if [[ "$src_verdict" == "RISKY" || "$src_verdict" == "CAUTION" ]]; then
        echo
        if ask_yes_no " = = > Source May Be Poor For Precise Cuts. Build Cut-Friendly Rebuilt Source First? (y/n, default: n): "; then
            rebuilt_src="$(rebuild_cut_friendly_source "$src")"
            if [[ -n "$rebuilt_src" && -f "$rebuilt_src" ]]; then
                src="$rebuilt_src"
                echo -e "${GR} = = > Using Rebuilt Source: $src${NC}"
            else
                echo -e "${REB} = = > Rebuild Failed. Continuing With Original Source.${NC}"
            fi
        fi
    fi

	# =========================
	# #MARKER: TEMPLATE TIME ENTRY CONFIRM LOOP
	# =========================
	# WHY:
	# - Rebuilding A Cut-Friendly Source Can Take Time.
	# - If The User Mistypes Intro Start/End Values, They Should Be Able To
	#   Correct Them Immediately Without Aborting The Whole Script.
	#
	# BEHAVIOR:
	# - Prompt For Start/End
	# - Show Entered Values Plus Computed Duration
	# - Ask For Confirmation
	# - If User Says "n", Re-Prompt Only The Times
	#
	while true; do
	    local start_raw end_raw
	    echo
        echo -e "${CYAN} = = > Enter Cut Range:${NC}"
        echo -e "${YELLOW} = = >  Start: ${NC}"
        read -r start_raw
        echo -e "${YELLOW} = = >    End: ${NC}"
        read -r end_raw
	    echo

	    start="$(to_seconds "$start_raw")"
	    end="$(to_seconds "$end_raw")"

	    cut_dur="$(echo "$end - $start" | bc)"

	    echo -e "${CYAN} = = > Entered Start: $start_raw -> ${start}s${NC}"
	    echo -e "${CYAN} = = > Entered End: ${end_raw} -> ${end}s${NC}"
	    echo -e "${CYAN} = = > Computed Duration: ${cut_dur}${NC}"
	    echo

	    if ask_yes_no "${CYAN} = = > Are These Times Correct? (y/n): ${NC}"; then
	        break
	    fi

	    echo -e "${YELLOW} = = > Re-Enter Times.${NC}"
	done

    # ====================================================================
    # #MARKER: TEMPLATE TEMP WORKDIR (LOCAL + SAFE)
    # ====================================================================
    # WHY:
    # - SMARTGAP Defines TMPDIR, But Template Builder Does NOT.
    # - With `set -u`, Referencing An Undefined Variable (TMPDIR) Causes A Hard Crash.
    # - Therefore Template Builder MUST Manage Its Own Temp Workspace.
    #
    # DESIGN:
    # - Local, Self-Contained Temp Directory
    # - No Dependency On Other Subsystems
    # - Easy Cleanup
    #
    # NOTE:
    # - Using A Fixed Name Instead Of Mktemp For Now To Keep Behavior Predictable
    # - Safe Because Script Runs In Controlled Working Directory
    #
    template_tmpdir="_template_builder_tmp"
    mkdir -p "$template_tmpdir"

    temp_cut="$template_tmpdir/temp_cut.mkv"

    echo -e "${CYAN} = = > Cutting Intro Segment...${NC}"
    # =========================
    # #MARKER: TEMPLATE CUT FIX (duration-based seek)
    # =========================
    # PURPOSE:
    # - Extract Precise Intro Segment Using Duration-Based Cutting (-t)
    # - Avoids Timestamp Corruption Caused By -to With Input Seeking
    #
    # NOISE CONTROL:
    # -hide_banner : Removes Ffmpeg Version/Config Spam
    # -loglevel error : Only Show Actual Failures
    # -nostdin : Prevents Ffmpeg From Hijacking Input (Important In Scripts)
    #
    # DESIGN:
    # - This Is A Re-Encode Step → Accuracy Prioritized Over Speed
    # - Uses Libx264 For Clean Keyframe-Aligned Output

    # Compute Exact Duration Instead Of Using -to (Prevents Timeline Corruption)
    cut_dur="$(echo "$end - $start" | bc)"

	src_dur=$(ffprobe -v error -show_entries format=duration \
	  -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null || true)
	echo -e "${CYAN} = = > Source duration:${NC} ${src_dur:-UNKNOWN}s"

    echo -e "${CYAN} = = > Cut start: $start | end: $end | duration: $cut_dur${NC}"

    if run_with_progress "Cutting template segment: $(basename "$src")" \
      ffmpeg -hide_banner -loglevel error -nostdin -y \
      -i "$src" \
      -map 0:v:0 -map "0:a?" \
      -vf "trim=start=${start}:duration=${cut_dur},setpts=PTS-STARTPTS" \
      -af "atrim=start=${start}:duration=${cut_dur},asetpts=PTS-STARTPTS" \
      -c:v libx264 -crf 18 -preset veryfast \
      -c:a aac -b:a 160k \
      "$temp_cut"; then
        :
    else
        echo -e "${REB} = = > Template Cut Failed.${NC}"
        rm -f "$temp_cut"
        rmdir "$template_tmpdir" 2>/dev/null || true
        return 1
    fi

	# Debug: verify actual duration of temp cut
	temp_dur=$(ffprobe -v error -show_entries format=duration \
	  -of default=noprint_wrappers=1:nokey=1 "$temp_cut")

	temp_video_dur=$(ffprobe -v error -select_streams v:0 \
	  -show_entries stream=duration \
	  -of default=noprint_wrappers=1:nokey=1 "$temp_cut" 2>/dev/null || true)

	temp_audio_dur=$(ffprobe -v error -select_streams a:0 \
	  -show_entries stream=duration \
	  -of default=noprint_wrappers=1:nokey=1 "$temp_cut" 2>/dev/null || true)

	echo -e "${YELLOW} = = > Temp cut format duration:${NC} ${temp_dur}s"
#	echo -e "${YELLOW} = = > Temp cut video duration:${NC} ${temp_video_dur:-NA}s"
#	echo -e "${YELLOW} = = > Temp cut audio duration:${NC} ${temp_audio_dur:-NA}s"

    fps=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=r_frame_rate \
        -of default=noprint_wrappers=1:nokey=1 "$temp_cut")

    fps_calc=$(echo "$fps" | awk -F'/' '{if ($2>0) printf "%.0f", $1/$2}')
    [[ -z "$fps_calc" ]] && fps_calc=24
#=======================================================
# ------------ AUTO-INCREMENT OUTPUT NAME --------------
#=======================================================
    # Rule:
    #   - First Try: intro_template.mkv
    #   - If It Exists: intro_template_<N>.mkv (1,2,3...)
    #
    # Output Location:
    #   - ./intro_template/
    #
    mkdir -p "intro_template"

    base_name="intro_template"
    ext="mkv"
    index=0

    while :; do
        if [[ $index -eq 0 ]]; then
            candidate="intro_template/${base_name}.${ext}"
        else
            candidate="intro_template/${base_name}_${index}.${ext}"
        fi

        echo "DEBUG: Checking Candidate=$candidate exists? $( [[ -f "$candidate" ]] && echo YES || echo NO )"
        [[ ! -f "$candidate" ]] && break
        index=$((index + 1))
    done
# -------------------------------------------------------------------------------
    ffmpeg -hide_banner -loglevel error -nostdin -y -i "$temp_cut" \
            -c:v libx264 -preset medium \
            -g "$fps_calc" -keyint_min "$fps_calc" \
            -sc_threshold 0 \
            -c:a copy "$candidate"

    # =================================================
    # #MARKER: TEMPLATE TEMP CLEANUP
    # =================================================
    # Remove Temp Cut File
    rm -f "$temp_cut"

    # Attempt To Remove Temp Directory If Empty
    # (Won't Error If Something Else Exists Inside)
    rmdir "$template_tmpdir" 2>/dev/null || true

    echo -e "${GREEN} = = > Template Created: $candidate${NC}"
    pause
    run_intro_template_fingerprint_report
}

# End Of TEMPLATE BUILDER intro_template.mkv

# =========================================================
# MARKER: RUN WITH PROGRESS (GENERIC LONG-RUN WRAPPER)
# =========================================================
# PURPOSE:
# - Show Visible Life-Sign Output During Long-Running File Operations.
# - Prevent The Script From Looking Frozen During Quiet Ffmpeg / Tar Work.
# - Wrap A Long-Running Command And Return Its Exit Code Unchanged.
#
# DESIGN GOALS:
# - Runs The Target Command In The Background.
# - Prints A One-Time Banner First.
# - Redraws One Live Status Line On STDERR.
# - Keeps STDOUT Clean For Command Substitution / Piped Output.
# - Avoids Ugly Wrapping / Smearing On Narrow Terminals.
# - Leaves The Terminal On A Clean New Line When Done.
#
# LIVE DISPLAY PROVIDES:
# - Task Label.
# - Animated Spinner.
# - Wave-Style Working Motion.
# - Elapsed Seconds.
# - Optional File Index Context.
# - Optional Rolling Average + Approx ETA After Enough Files Finish.
#
# ETA POLICY:
# - No ETA For First 2 Completed Files.
# - ETA Starts After 3 Completed Files.
# - ETA Is Approximate Because File Size / Codec / CRF / Resolution Vary.
#
# PORTABILITY:
# - Defensively Initializes Progress Globals If Missing.
# - Falls Back To Raw Seconds If format_seconds_hms() Is Not Present.
# - Safe To Copy Into Another Script Without Top-Level Defaults.
#
# USAGE:
#   run_with_progress "Label Here..." command arg1 arg2 ...
#
# EXAMPLE:
#   run_with_progress "Building OEM Archive..." tar -czf archive.tar ./OEM
#
# NOTES:
# - Best Used For Quiet Long-Running Commands.
# - Avoid Wrapping Commands That Already Emit Their Own Live Progress.
# - All Progress Text Goes To STDERR.
#
# IMPORTANT:
# - STDOUT Must Stay Reserved For True Return Values.
# - This Matters For Helpers Used Like:
#     var="$(some_function)"
#
# HOUSE RULE:
# - Feedback Is King — User Should Never Wonder If The Script Is Stuck.
# =========================================================

run_with_progress() {
	local label="$1"
	shift

	# --------------------------------------------------------
	# VISUAL ELEMENTS (spinner + wave animation)
	# --------------------------------------------------------
	local spin='|/-\'
	local wave=(
		".    "
		"..   "
		"...  "
		".... "
		"....."
		" ...."
		"  ..."
		"   .."
		"    ."
	)

	local s=0
	local w=0
	local spin_len=${#spin}
	local wave_len=${#wave[@]}

	# --------------------------------------------------------
	# RUNTIME STATE
	# --------------------------------------------------------
	local cmd_pid
	local cmd_status=0
	local start_ts now_ts elapsed
	local avg_seconds=0
	local eta_seconds=0
	local remaining_files=0
	local avg_human=""
	local eta_human=""
	local progress_note=""

	# --------------------------------------------------------
	# TERMINAL WIDTH CONTROL (prevents wrap/visual glitching)
	# --------------------------------------------------------
	local cols max_label
	local live_label
	local live_line

	# --------------------------------------------------------
	# PORTABLE DEFENSIVE DEFAULTS
	# --------------------------------------------------------
	# PURPOSE:
	# - Allows this function to be copied anywhere safely
	# - Prevents set -u crashes if globals are not defined
	# - Falls back to zero-state tracking automatically
	# --------------------------------------------------------
	PROGRESS_DONE_COUNT="${PROGRESS_DONE_COUNT:-0}"
	PROGRESS_TOTAL_SECONDS="${PROGRESS_TOTAL_SECONDS:-0}"
	PROGRESS_TOTAL_FILES="${PROGRESS_TOTAL_FILES:-0}"
	PROGRESS_CURRENT_INDEX="${PROGRESS_CURRENT_INDEX:-0}"
	PROGRESS_LAST_ELAPSED="${PROGRESS_LAST_ELAPSED:-0}"

	# --------------------------------------------------------
	# INITIAL USER FEEDBACK (one-time banner)
	# --------------------------------------------------------
	echo -e "${CYAN} = = > ${label}${NC}" >&2

	start_ts="$(date +%s)"

	# --------------------------------------------------------
	# LAUNCH TARGET COMMAND IN BACKGROUND
	# --------------------------------------------------------
	"$@" &
	cmd_pid=$!

	# --------------------------------------------------------
	# TERMINAL WIDTH SAFETY
	# --------------------------------------------------------
	cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
	(( cols < 40 )) && cols=80

	max_label=$(( cols - 70 ))
	(( max_label < 12 )) && max_label=12

	if (( ${#label} > max_label )); then
		live_label="${label:0:max_label-3}..."
	else
		live_label="$label"
	fi

	# --------------------------------------------------------
	# HEARTBEAT LOOP (runs until command exits)
	# --------------------------------------------------------
	while kill -0 "$cmd_pid" 2>/dev/null; do
		now_ts="$(date +%s)"
		elapsed=$(( now_ts - start_ts ))
		(( elapsed < 0 )) && elapsed=0

		progress_note=""


# ========================================================
# ARCHIE ROLLING PROGRESS / ETA STATE
# ========================================================
# PURPOSE:
# - Give The Yellow "Please Stand By" Line Real Context
# - Track Per-File Elapsed Seconds
# - Build A Rolling Average After A Few Completed Files
# - Show A Rough ETA For Remaining Files
#
# IMPORTANT:
# - ETA is intentionally approximate
# - Different files can vary wildly by:
#     duration / resolution / codec / level / audio mode
# - So we do NOT show ETA immediately
# - We wait until enough files have completed to form a clue
#
# RULE:
# - No ETA for first 2 completed files
# - Start showing ETA after 3 completed files
# ========================================================

		if (( PROGRESS_TOTAL_FILES > 0 )); then
			if (( PROGRESS_DONE_COUNT >= 3 )); then
				avg_seconds=$(( PROGRESS_TOTAL_SECONDS / PROGRESS_DONE_COUNT ))
				remaining_files=$(( PROGRESS_TOTAL_FILES - PROGRESS_DONE_COUNT ))

				if (( remaining_files < 0 )); then
					remaining_files=0
				fi

				eta_seconds=$(( avg_seconds * remaining_files ))

				# ----------------------------------------------------
				# HUMAN READABLE TIME (fallback if helper missing)
				# ----------------------------------------------------
				if declare -F format_seconds_hms >/dev/null 2>&1; then
					avg_human="$(format_seconds_hms "$avg_seconds")"
					eta_human="$(format_seconds_hms "$eta_seconds")"
				else
					avg_human="${avg_seconds}s"
					eta_human="${eta_seconds}s"
				fi

				progress_note=" file ${PROGRESS_CURRENT_INDEX}/${PROGRESS_TOTAL_FILES} avg ${avg_human} eta ${eta_human}"
			elif (( PROGRESS_DONE_COUNT > 0 )); then
				progress_note=" file ${PROGRESS_CURRENT_INDEX}/${PROGRESS_TOTAL_FILES} gathering timing data..."
			else
				progress_note=" file ${PROGRESS_CURRENT_INDEX}/${PROGRESS_TOTAL_FILES}"
			fi
		fi

		# --------------------------------------------------------
		# BUILD SINGLE-LINE STATUS DISPLAY
		# --------------------------------------------------------
		live_line=" = = > ${live_label} [${spin:s:1}] ${wave[w]}-WORKING-${wave[w]} [${elapsed}s]${progress_note}"

		# --------------------------------------------------------
		# PRINT IN-PLACE (no scrolling)
		# --------------------------------------------------------
		printf '\r\033[2K%b%s%b' "${YELLOW}" "$live_line" "${NC}" >&2

		s=$(( (s + 1) % spin_len ))
		w=$(( (w + 1) % wave_len ))

		sleep 0.20
	done

	# --------------------------------------------------------
	# CAPTURE EXIT STATUS
	# --------------------------------------------------------
	wait "$cmd_pid"
	cmd_status=$?

		if (( cmd_status == 130 || cmd_status == 143 || cmd_status == 255 )); then
			printf '\r\033[2K' >&2
			echo >&2

			if declare -F on_abort >/dev/null 2>&1; then
				on_abort
			fi

			exit "$cmd_status"
		fi

	# --------------------------------------------------------
	# FINAL TIME ACCOUNTING
	# --------------------------------------------------------
	now_ts="$(date +%s)"
	elapsed=$(( now_ts - start_ts ))
	(( elapsed < 0 )) && elapsed=0

	PROGRESS_LAST_ELAPSED="$elapsed"
	PROGRESS_TOTAL_SECONDS=$(( PROGRESS_TOTAL_SECONDS + elapsed ))
	PROGRESS_DONE_COUNT=$(( PROGRESS_DONE_COUNT + 1 ))

	# --------------------------------------------------------
	# CLEAN LINE + MOVE TO FRESH LINE
	# --------------------------------------------------------
	printf '\r\033[2K' >&2
	echo >&2

	return "$cmd_status"
}

# ========================================================
# #MARKER: ARRAY ASCII SCROLL PLAYER
# ========================================================
ARRAY_ASCII_FILE="${ARRAY_ASCII_FILE:-ARRAY_ASCII.txt}"
ARRAY_ASCII_MIN_FILES="${ARRAY_ASCII_MIN_FILES:-20}"
ARRAY_ASCII_EVERY_N_FILES="${ARRAY_ASCII_EVERY_N_FILES:-10}"

array_play_ascii_scroll() {
	local art_file="${1:-$ARRAY_ASCII_FILE}"
	local passes="${2:-4}"
	local frame_delay="${3:-0.45}"
	local hold_delay="${4:-0.35}"

	local scene_separator="===SCENE==="
	local current_scene=""
	local -a scenes=()
	local line total_scenes pass scene_index

	[[ -f "$art_file" ]] || return 0

	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ "$line" == "$scene_separator" ]]; then
			if [[ -n "$current_scene" ]]; then
				scenes+=("$current_scene")
				current_scene=""
			fi
			continue
		fi

		current_scene+="$line"$'\n'
	done < "$art_file"

	if [[ -n "$current_scene" ]]; then
		scenes+=("$current_scene")
	fi

	total_scenes="${#scenes[@]}"
	(( total_scenes > 0 )) || return 0

	for (( pass=0; pass<passes; pass++ )); do
		scene_index=$(( pass % total_scenes ))

		printf "\033[2J\033[H"
		echo -e "${MAGENTA}================================================${NC}"
		echo -e "${MAGENTA}              ARRAY INTERMISSION                ${NC}"
		echo -e "${MAGENTA}================================================${NC}"
		echo

		printf '%s' "${scenes[$scene_index]}"
		echo

		sleep "$frame_delay"
	done

	sleep "$hold_delay"
	return 0
}

array_maybe_play_ascii_scroll() {
	[[ -f "$ARRAY_ASCII_FILE" ]] || return 0

	PROGRESS_TOTAL_FILES="${PROGRESS_TOTAL_FILES:-0}"
	PROGRESS_DONE_COUNT="${PROGRESS_DONE_COUNT:-0}"

	(( PROGRESS_TOTAL_FILES >= ARRAY_ASCII_MIN_FILES )) || return 0
	(( PROGRESS_DONE_COUNT > 0 )) || return 0
	(( PROGRESS_DONE_COUNT % ARRAY_ASCII_EVERY_N_FILES == 0 )) || return 0

	array_play_ascii_scroll "$ARRAY_ASCII_FILE" 4 0.45 0.35
}

# =========================
# #MARKER: BATCH NORMALIZER SINGLE-FILE WORKER
# =========================
# PURPOSE:
# - Normalize One Source File Into A Cut-Friendly REKEY_ Output Using The
#    Current Batch CRF Knob Passed Down By Batch Normalize.
#
# WHY THIS EXISTS:
# - Batch Mode Needs A Dedicated Worker That Can Be Launched Safely
#   Across Many Files Without Dragging In Interactive One-Off Logic.
#
# REKEY PHILOSOPHY:
# - QUALITY FIRST
# - 1-SECOND GOP FOR CUT-FRIENDLINESS
# - AUDIO PASSES THROUGH UNCHANGED
# - NOT A SIZE-SQUEEZE TOOL
#
# DESIGN RULE:
# - Keep GOP / keyframe structure fixed and trustworthy.
# - Use REKEY_CRF as the single quality tuning knob.
# - Do NOT re-encode audio here; REKEY is not an audio "improvement" pass.
# - Keep Quality/Settings FIXED.
# - Throttle By Number Of Simultaneous Files, NOT By Lowering Encode Quality.
# =========================

normalize_cut_friendly_file() {
	local in="$1"
	local rekey_crf="${2:-$REKEY_CRF}"
	local out_override="${3:-}"
	local quiet_progress="${4:-0}"
	local out fps fps_calc

	# ========================================================
	# OUTPUT NAMING RULE
	# --------------------------------------------------------
	# PURPOSE:
	# - Preserve the normal REKEY_<name>.mkv output by default
	# - Allow rolling/secondary callers to override the output path
	#   (example: .try2.mkv)
	# - Allow throughput workers to keep the same normal output naming
	#
	# CALL SHAPES:
	# - normalize_cut_friendly_file "$src" "$crf"
	# - normalize_cut_friendly_file "$src" "$crf" "$custom_out"
	# - normalize_cut_friendly_file "$src" "$crf" "$custom_out" "$quiet_progress"
	# ========================================================
	if [[ -n "$out_override" ]]; then
		out="$out_override"
	else
		out="REKEY_$(basename "${in%.*}").mkv"
	fi

	# Skip only if existing rebuilt file is actually valid/readable.
	if is_valid_video_file "$out"; then
		if (( quiet_progress == 0 )); then
			echo -e "${YELLOW} = = > Skip Existing Rebuilt File:${NC} ${GREEN}$out${NC}"
		fi
		return 0
	fi

	# If a stale/corrupt partial file exists, remove it before rebuilding.
	if [[ -f "$out" ]]; then
		if (( quiet_progress == 0 )); then
			echo -e "${YELLOW} = = > Existing Rebuilt File Is Invalid. Removing Stale File:${NC} ${GREEN}$out${NC}"
		fi
		rm -f "$out"
	fi

	fps="$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate \
		-of default=nokey=1:noprint_wrappers=1 "$in")"

	if [[ -z "$fps" || "$fps" == "0/0" ]]; then
		fps_calc=24
	else
		fps_calc=$(awk -v fr="$fps" 'BEGIN{
			split(fr,a,"/")
			if (a[2] == 0 || a[2] == "") print 24
			else printf "%.3f", a[1]/a[2]
		}')
	fi

	# ========================================================
	# DISPLAY POLICY
	# --------------------------------------------------------
	# NORMAL / ADAPTIVE / SINGLE-FILE:
	# - keep rich per-file display + spinner heartbeat
	#
	# THROUGHPUT / CONCURRENT:
	# - suppress per-file chatter and spinner animation
	# - parent batch runner becomes the main terminal narrator
	#
	# WHY:
	# - Multiple simultaneous run_with_progress heartbeat lines all fight
	#   over the same terminal row and create visual garbage.
	# ========================================================
	if (( quiet_progress == 0 )); then
		echo -e "${CYAN} = = > Normalizing:${NC} ${GREEN}$in${NC}"
		echo -e "${CYAN} = = > Output:${NC} ${GREEN}$out${NC}"
		echo -e "${CYAN} = = > GOP target:${NC} ${YELLOW}~1 second (${fps_calc} fps)${NC}"
		echo -e "${CYAN} = = > REKEY_CRF:${NC} ${YELLOW}$rekey_crf${NC}"
		echo -e "${CYAN} = = > Audio Policy:${NC} ${YELLOW}copy-through${NC}"

		# ========================================================
		# 8-BIT PLAYBACK COMPATIBILITY RULE
		# --------------------------------------------------------
		# FORCE yuv420p here so REKEY outputs stay broadly compatible
		# with ordinary player and hardware-decode paths.
		# ========================================================
		if run_with_progress "Batch Normalize: $(basename "$in")" \
			ffmpeg -y -hide_banner -nostats -loglevel error \
				-i "$in" \
				-map 0 \
				-c:v libx264 -preset medium -crf "$rekey_crf" \
				-pix_fmt yuv420p \
				-g "$fps_calc" -keyint_min "$fps_calc" -sc_threshold 0 \
				-force_key_frames "expr:gte(t,n_forced*1)" \
				-c:a copy \
				-c:s copy \
				"$out"; then
			echo -e "${GREEN} = = > Rebuilt:${NC} ${GREEN}$out${NC}"
			return 0
		else
			echo -e "${REB} = = > Normalize Failed:${NC} ${GREEN}$in${NC}"
			rm -f "$out"
			return 1
		fi
	fi

	# ========================================================
	# QUIET THROUGHPUT PATH
	# --------------------------------------------------------
	# NO spinner
	# NO per-file chatter
	# Parent worker summary handles the user-facing feedback
	# ========================================================
	# ========================================================
	# 8-BIT PLAYBACK COMPATIBILITY RULE
	# --------------------------------------------------------
	# FORCE yuv420p here too, so throughput mode does not drift
	# away from the normal visible path.
	# ========================================================
	if ffmpeg -y -hide_banner -nostats -loglevel error \
		-i "$in" \
		-map 0 \
		-c:v libx264 -preset medium -crf "$rekey_crf" \
		-pix_fmt yuv420p \
		-g "$fps_calc" -keyint_min "$fps_calc" -sc_threshold 0 \
		-force_key_frames "expr:gte(t,n_forced*1)" \
		-c:a copy \
		-c:s copy \
		"$out"; then
		return 0
	else
		rm -f "$out"
		return 1
	fi
}

# ==============================================================================
# --- FUNCTION: CUSTOM CUT (BRUTAL ONE-OFF CLIP TOOL) ---
# ==============================================================================
run_custom_cut() {
    # =========================
    # #MARKER: CUSTOM CUT SOURCE PICKER
    # =========================
    # WHY:
    # - Custom Cut Is A One-Off Clip Grabber.
    # - It Should Work In Any Working Directory And Show Any Source File
    #   Format The Tool Already Knows How To Handle.
    # - Unlike Template Builder, It Does NOT Care About intro_template/
    #   And Does NOT Need Normalization/Rebuild Prep Logic.
    #
    # HIDDEN FROM THIS PICKER:
    # - REKEY_   : internal rebuilt sources
    # - SMC_ : SMARTGAP outputs
    # - BARFIX_  : BARFIX remux outputs
    #
    clear
    echo -e "${CYAN} = = >...............Custom Cut----------------${NC}"
    echo
    echo -e "${CYAN} = = > Select source file for one-off clip cut:${NC}"

    shopt -s nullglob nocaseglob
    local -a custom_sources=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
    shopt -u nullglob nocaseglob

    local -a filtered_sources=()
    local f
    for f in "${custom_sources[@]}"; do
        [[ "$f" =~ ^REKEY_ ]] && continue
        [[ "$f" =~ ^(SMC_|PILOT_SMC_) ]] && continue
        [[ "$f" =~ ^BARFIX_ ]] && continue
		[[ "$f" =~ ^SMC_ ]] && continue
        filtered_sources+=("$f")
    done

    if [[ ${#filtered_sources[@]} -eq 0 ]]; then
        echo -e "${RE} = = > No eligible source files found for Custom Cut.${NC}"
        pause
        return 1
    fi

    # =========================
    # #MARKER: CUSTOM CUT SOURCE PICKER (WITH CANCEL)
    # =========================
    # PURPOSE:
    # - Let User Pick A Source File
    # - Allow Backing Out Cleanly With q Or 0
    #
    local pick
    while true; do
        echo
        echo -e "${CYAN} = = > Select File:${NC} ${YELLOW}[number | q=cancel]${NC}"
        echo

        select src in "${filtered_sources[@]}"; do
            pick="${REPLY//[[:space:]]/}"
            # ========================================================
            # TEN-KEY EXIT HOOK
            # ========================================================
            if is_exit_token "$pick"; then
                echo -e "${YELLOW} = = > Custom Cut Cancelled.${NC}"
                pause
                return 0
            fi

            if [[ -n "${src:-}" ]]; then
                break 2
            fi

            echo -e "${RE} = = > Invalid Selection. Enter A Listed Number, or q to cancel.${NC}"
            break
        done
    done

    echo
    echo -e "${CYAN}     ========================================================${NC}"
    echo -e "${YELLOW}     ==========> CUSTOM CUT = FAST ONE-OFF CLIP <===========${NC}"
    echo -e "${CYAN}     --------------------------------------------------------${NC}"
    echo -e "${YELLOW}     ==> Open The Source File You Selected <=================${NC}"
    echo -e "${CYAN}     --------------------------------------------------------${NC}"
    echo -e "${YELLOW}     ==> Watch It And Get Exact Start And End Times <=======${NC}"
    echo -e "${CYAN}     --------------------------------------------------------${NC}"
    echo -e "${YELLOW}     ==> Enter Times In Seconds Or hh:mm:ss Format <========${NC}"
    echo -e "${CYAN}     --------------------------------------------------------${NC}"
    echo -e "${YELLOW}     ==>  10 Key Accepts Times In 2.20=2:20Format  <========${NC}"
    echo -e "${CYAN}     --------------------------------------------------------${NC}"
    echo -e "${YELLOW}     ==> Output Will Be Saved In Current Working Folder <===${NC}"
    echo -e "${CYAN}     --------------------------------------------------------${NC}"
    echo -e "${YELLOW}     ==> No intro_template Folder Needed Or Used <==========${NC}"
    echo -e "${CYAN}     --------------------------------------------------------${NC}"
    echo -e "${YELLOW}     ==> No Keyframe Check / No Rebuild / No Normalize <====${NC}"
    echo -e "${CYAN}     ========================================================${NC}"

    # =========================
    # #MARKER: CUSTOM CUT TIME ENTRY CONFIRM LOOP
    # =========================
    # WHY:
    # - User May Mistype Times.
    # - Re-Prompt Only The Timing Values Until Confirmed.
    #
    local start_raw end_raw start end cut_dur
    while true; do
	    echo
        echo -e "${CYAN} = = > Enter Cut Range:${NC}"
        echo -e "${YELLOW} = = >  Start: ${NC}"
        read -r start_raw
        echo -e "${YELLOW} = = >    End: ${NC}"
        read -r end_raw
	    echo

        start="$(to_seconds "$start_raw")"
        end="$(to_seconds "$end_raw")"

        if [[ -z "${start:-}" || -z "${end:-}" ]]; then
            echo -e "${RE} = = > Invalid Time Entry. Try Again.${NC}"
            continue
        fi

        if ! awk "BEGIN {exit !($end > $start)}"; then
            echo -e "${RE} = = > End Time Must Be Greater Than Start Time.${NC}"
            continue
        fi

        cut_dur="$(echo "$end - $start" | bc)"

        echo -e "${CYAN} = = > Entered Start:${NC} $start_raw -> ${start}s"
        echo -e "${CYAN} = = > Entered End:${NC} ${end_raw} -> ${end}s"
        echo -e "${CYAN} = = > Computed Duration:${NC} ${cut_dur}"
        echo

        if ask_yes_no " = = > Are These Times Correct? (y/n): "; then
            break
        fi

        echo -e "${YELLOW} = = > Re-Enter Times.${NC}"
    done

    # =========================
    # #MARKER: CUSTOM CUT OUTPUT NAMING
    # =========================
    # RULE:
    # - First Try: custom_cut.mkv
    # - Then:      custom_cut_1.mkv, custom_cut_2.mkv, etc.
    #
    local base_name="custom_cut"
    local ext="mkv"
    local index=0
    local candidate=""

    while :; do
        if [[ $index -eq 0 ]]; then
            candidate="${base_name}.${ext}"
        else
            candidate="${base_name}_${index}.${ext}"
        fi

        [[ ! -f "$candidate" ]] && break
        index=$((index + 1))
    done

    # =========================
    # #MARKER: CUSTOM CUT TEMP WORKDIR
    # =========================
    # WHY:
    # - Self-Contained Temp Workspace
    # - No Dependency On TMPDIR From Other Functions
    #
    local custom_tmpdir="_custom_cut_tmp"
    local temp_cut="$custom_tmpdir/temp_cut.mkv"

    mkdir -p "$custom_tmpdir"

    src_dur=$(ffprobe -v error -show_entries format=duration \
      -of default=noprint_wrappers=1:nokey=1 "$src" 2>/dev/null || true)
    echo -e "${CYAN} = = > Source Duration:${NC} ${src_dur:-UNKNOWN}s"
    echo -e "${CYAN} = = > Cut Start: $start | End: $end | Duration: $cut_dur${NC}"

    echo -e "${CYAN} = = > Cutting Custom Clip....${NC}"

    # =========================
    # #MARKER: CUSTOM CUT MAIN CUT
    # =========================
    # PURPOSE:
    # - Brutal One-Off Clip Extraction
    # - Accurate Duration-Based Trim
    # - No Keyframe Analysis Or Rebuild Pipeline
    #
    # DESIGN:
    # - Re-Encode For Predictable Results Across Mixed Source Formats
    #
    if run_with_progress "Cutting custom clip: $(basename "$src")" \
      ffmpeg -hide_banner -loglevel error -nostdin -y \
      -i "$src" \
      -map 0:v:0 -map "0:a?" \
      -vf "trim=start=${start}:duration=${cut_dur},setpts=PTS-STARTPTS" \
      -af "atrim=start=${start}:duration=${cut_dur},asetpts=PTS-STARTPTS" \
      -c:v libx264 -crf 18 -preset veryfast \
      -c:a aac -b:a 160k \
      "$temp_cut"; then
        :
    else
        echo -e "${REB} = = > Custom Cut Failed.${NC}"
        rm -f "$temp_cut"
        rmdir "$custom_tmpdir" 2>/dev/null || true
        pause
        return 1
    fi

    temp_dur=$(ffprobe -v error -show_entries format=duration \
      -of default=noprint_wrappers=1:nokey=1 "$temp_cut" 2>/dev/null || true)

    echo -e "${YELLOW} = = > Temp Cut Format Duration:${NC} ${temp_dur:-UNKNOWN}s"

    fps=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=r_frame_rate \
        -of default=noprint_wrappers=1:nokey=1 "$temp_cut" 2>/dev/null || true)

    fps_calc=$(echo "$fps" | awk -F'/' '{if ($2>0) printf "%.0f", $1/$2}')
    [[ -z "$fps_calc" ]] && fps_calc=24

    ffmpeg -hide_banner -loglevel error -nostdin -y -i "$temp_cut" \
        -c:v libx264 -preset medium \
        -g "$fps_calc" -keyint_min "$fps_calc" \
        -sc_threshold 0 \
        -c:a copy "$candidate"

    # =========================
    # #MARKER: CUSTOM CUT TEMP CLEANUP
    # =========================
    rm -f "$temp_cut"
    rmdir "$custom_tmpdir" 2>/dev/null || true

    echo -e "${GREEN} = = > Custom Cut Created: $candidate${NC}"
    pause
}

# ==============================================================================
# --- FUNCTION: RESTORE OEM PREFIX ---
# ==============================================================================
restore_OEM_prefix() {
    # =========================
    # #MARKER: OEM RESTORE HEADER
    # =========================
    # PURPOSE:
    # - Undo OEM source staging
    # - Move files out of ./OEM/ back into the working directory
    # - Strip the leading OEM_ prefix during the move
    #
    # RESULT EXAMPLE:
    #   before:
    #       ./OEM/OEM_Episode01.mkv
    #
    #   after:
    #       ./Episode01.mkv
    #
    # IMPORTANT:
    # - This is a MOVE back to working dir, not an in-place rename
    # - If target name already exists in working dir, skip safely
    # - If ./OEM becomes empty, rename it to a done-flag folder
    #
    clear
    echo -e "${CYAN} = = > Restore OEM_ Files From /OEM${NC}"
    echo

    # =========================
    # #MARKER: OEM RESTORE PRECHECKS
    # =========================
    # PURPOSE:
    # - Verify ./OEM exists
    # - Collect only files beginning with OEM_
    #
    if [[ ! -d "OEM" ]]; then
        echo -e "${YELLOW} = = > No ./OEM Directory Found.${NC}"
        pause
        return 0
    fi

    shopt -s nullglob
    local -a OEM_files=(OEM/OEM_*)
    shopt -u nullglob

    if [[ ${#OEM_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW} = = > No OEM_ Files Found In ./OEM.${NC}"
        echo

        # =========================
        # #MARKER: OEM EMPTY DIR DONE FLAG (NO FILES FOUND)
        # =========================
        # PURPOSE:
        # - If ./OEM exists but is already empty, convert it into a
        #   visible "done" marker folder instead of deleting it.
        #
        shopt -s nullglob dotglob
        local OEM_contents_empty_check=(OEM/*)
        shopt -u nullglob dotglob

        if (( ${#OEM_contents_empty_check[@]} == 0 )); then
            local done_dir_empty="done wow"
            local idx_empty=0
            local candidate_empty="$done_dir_empty"

            while [[ -e "$candidate_empty" ]]; do
                ((idx_empty+=1)) || :
                candidate_empty="${done_dir_empty}_${idx_empty}"
            done

            mv -- OEM "$candidate_empty"
            echo -e "${CYAN} = = > OEM Folder Empty -> Renamed To '$candidate_empty'${NC}"
        fi

        pause
        return 0
    fi

    # =========================
    # #MARKER: OEM RESTORE PREVIEW
    # =========================
    # PURPOSE:
    # - Show user exactly what move + rename will happen
    #
    echo -e "${CYAN} = = > Preview Restore (Move + Rename):${NC}"
    echo

    local f base new_name
    for f in "${OEM_files[@]}"; do
        base="$(basename "$f")"
        new_name="${base#OEM_}"
        echo "$f  ->  ./$new_name"
    done

    echo

    echo

    if ! ask_yes_no " = = > Proceed With Restore? (y/n or 1/2, default: n): "; then
    	echo -e "${YELLOW} = = > OEM Restore Cancelled.${NC}"
    	pause
    	return 0
    fi

    # =========================
    # #MARKER: OEM RESTORE MOVE LOOP
    # =========================
    # PURPOSE:
    # - Move each OEM_ file from ./OEM/ back to working dir
    # - Strip OEM_ prefix
    # - Skip if destination already exists
    #
    echo
    echo -e "${CYAN} = = > Restoring Files...${NC}"

    local moved=0
    local skipped=0

    for f in "${OEM_files[@]}"; do
        base="$(basename "$f")"
        new_name="${base#OEM_}"

        if [[ -e "$new_name" ]]; then
            echo -e "${YELLOW} = = > SKIP: $new_name Already Exists In Working Dir${NC}"
            ((skipped+=1)) || :
            continue
        fi

        if mv -- "$f" "$new_name"; then
            echo -e "${GREEN} = = > RESTORED: $f -> $new_name${NC}"
            ((moved+=1)) || :
        else
            echo -e "${REB} = = > FAIL: Could Not Restore $f${NC}"
            ((skipped+=1)) || :
        fi
    done

    # =========================
    # #MARKER: OEM RESTORE SUMMARY
    # =========================
    echo
    echo -e "${GREEN} = = > Done.${NC} Restored: $moved | Skipped: $skipped"

    # =========================
    # #MARKER: OEM DIR FINALIZE (DONE FLAG)
    # =========================
    # PURPOSE:
    # - If ./OEM is now empty after restore, rename it instead of deleting it
    # - This acts as a visible "done with this working dir" flag
    #
    if [[ -d "OEM" ]]; then
        shopt -s nullglob dotglob
        local OEM_contents=(OEM/*)
        shopt -u nullglob dotglob

        if (( ${#OEM_contents[@]} == 0 )); then
            local done_dir="done wow"
            local idx=0
            local candidate="$done_dir"

            # Avoid clobbering an existing done-flag folder
            while [[ -e "$candidate" ]]; do
                ((idx+=1)) || :
                candidate="${done_dir}_${idx}"
            done

            mv -- OEM "$candidate"
            echo -e "${CYAN} = = > OEM Folder Empty -> Renamed To '$candidate'${NC}"
        else
            echo -e "${YELLOW} = = > OEM folder Not Empty, Leaving As-Is.${NC}"
        fi
    fi

    echo
    pause
    return 0
}

# ====================================================
# #MARKER: BATCH NORMALIZER MISSION
# ====================================================
# PURPOSE:
# - Rebuild All Eligible Source Videos In The Current Folder Into REKEY_*.mkv
#   So Later Template Builder / SMARTGAP Work Can Happen On Cut-Friendly Sources.
#
# IMPORTANT:
# - This Mode Is NON-DESTRUCTIVE.
# - Originals Are NOT Deleted, Renamed, Or Modified.
# - This Means Disk Usage Can Grow Significantly During Processing.
#
# DISK SPACE REALITY:
# - REKEY Pass Alone Can Nearly Double Folder Usage.
# - If SMC Outputs Are Later Created Too, Total Working Size Can Approach
#   Triple The Original Folder Footprint.
#
# LOAD CONTROL:
# - Light  = 1 File At A Time
# - Medium = 3 Files At A Time
# - Thrash = User-Chosen Concurrent Job Count
#

run_batch_normalizer() {

	local execution_mode
	local max_jobs
	local -a norm_sources
                clear
	echo
	echo -e "     ${YEB} WHY ARE YOU HERE , SMARTCUT IS KING .${NC}"
	echo -e "     ${YELLOW} YOU DO NOT HAVE TO DO THIS ANYMORE read this."
				echo " = = > Current broad state:"
				echo " = = >  - SmartCut is now the primary workflow engine."
				echo " = = >  - OEM/ archive staging is active for non-destructive processing."
				echo " = = >  - SMC_ outputs are now the primary finished cut products."
				echo " = = >  - Barfix Lite can auto-run after successful SmartCut operations."
				echo " = = >  - Intro/Outro detection supports adjustable scan depth, anchors, and step size."
				echo
				echo " = = > Current workflow philosophy:"
				echo " = = >  - Working directory should contain current active products only."
				echo " = = >  - OEM/ stores prior-stage files and protected originals by run folder."
				echo " = = >  - Prefixes identify current workflow stage, not permanent identity."
				echo " = = >  - Finalize/Cleanup removes workflow noise after verification."
				echo
				echo " = = > Typical workflow:"
				echo " = = >  - Inspect folder state / grouped files"
				echo " = = >  - Build intro/outro templates"
				echo " = = >  - Detect intros/outros into CSV maps"
				echo " = = >  - Run SmartCut batch or manual plans"
				echo " = = >  - Optional Barfix Lite auto-applies playback/title defaults"
				echo " = = >  - Review outputs"
				echo " = = >  - Cleanup / finalize"
                echo -e "${NC}"
                pause

	if ! ask_yes_no "     = = > Did You Read That Up There ? (y/n or 1/2): "; then
		echo -e "${YELLOW}     = = > Batch Normalizer Canceled.${NC}"
		pause
		return 0
	fi


	echo -e "     ${CYAN}==========================================================${NC}"
	echo -e "     ${CYAN}      BATCH NORMALIZER :: CUT-FRIENDLY REKEY BUILDER      ${NC}"
	echo -e "     ${CYAN}==========================================================${NC}"
	echo -e "     ${YELLOW}WARNING: Originals Are Kept Untouched And Outputs Are Added Beside Them.${NC}"
	echo -e "     ${YELLOW}WARNING: Folder Size WILL DOUBLE During Normalization.= = = = = = = = = ${NC}"
	echo -e "     ${YELLOW}WARNING: If You Later Also Create SMC Outputs, WORKING SIZE WILL= = ${NC}"
	echo -e "     ${YELLOW}WARNING: TRIPLE THE ORIGINAL FOLDER SIZE. = = = = = = = = = = = = = = = ${NC}"
	echo -e "     ${REB}WARNING: = = = = = = = >${NC}${YELLOW}Check Your Disk Space WARNING${NC}${REB} < = = = = = = = = ${NC}"
	echo -e "     ${CYAN}= = > If Your Here Twice Thats OK, It Will Skip All Already Done And---${NC}"
	echo -e "     ${CYAN}= = > Still Set The Flag For Rekey Favorability During This Session----${NC}"
	echo -e "     ${CYAN}= = > YOU DO NOT NEED TO DO ANY OF THIS ANYMORE SMARTCUT IS KING----${NC}"
	echo

	if ! ask_yes_no "     = = > Did You Read That Up There ? (y/n or 1/2): "; then
		echo -e "${YELLOW}     = = > Batch Normalizer Canceled.${NC}"
		pause
		return 0
	fi
	echo

	# =========================
	# #MARKER: BATCH NORMALIZER TARGET DISCOVERY
	# =========================
	# Only Include Likely OEM/Source Files.
	# Hide Internal/Generated Products So The Job Cannot Recurse Into Its Own
	# Outputs Or Into Unrelated Helper Assets.
	#
	shopt -s nullglob nocaseglob
	local -a all_norm_candidates=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
	shopt -u nullglob nocaseglob

	local f
	for f in "${all_norm_candidates[@]}"; do
		[[ "$f" =~ ^(REKEY_|SMC_|BARFIX_|SUBPACKED_|OEM_|PILOT_SMC_) ]] && continue
		[[ "$f" == "intro_template.mkv" ]] && continue
		[[ "$f" == intro_template_* ]] && continue
		norm_sources+=("$f")
	done

	if (( ${#norm_sources[@]} == 0 )); then
		echo -e "${REB} = = > No Eligible Source Videos Found For Batch Normalization.${NC}"
		pause
		return 0
	fi

	echo
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN}            BATCH NORMALIZER TARGET PREVIEW               ${NC}"
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN} = = > Eligible Source Files Found:${NC} ${YELLOW}${#norm_sources[@]}${NC}"
	echo

	local idx
	for ((idx=0; idx<${#norm_sources[@]}; idx++)); do
		echo -e "${GREEN}  $((idx+1)))${NC} ${norm_sources[$idx]}"
	done
	echo

	# =========================
	# #MARKER: BATCH NORMALIZER EXECUTION MODE SELECT
	# =========================
	# WHY:
	# - Adaptive Mode Needs Ordered Sequential Feedback
	# - Throughput Mode Needs Independent Parallel Jobs
	# - These Are Opposite Behaviors, So We Choose Intentionally
	#
	if ! execution_mode="$(rekey_choose_batch_execution_mode)"; then
		echo
		echo -e "${YELLOW} = = > Batch Normalizer Canceled At Execution Mode Selection.${NC}"
		pause
		return 0
	fi

	clear
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN}          BATCH NORMALIZER :: EXECUTION CONFIRM           ${NC}"
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN} = = > Selected Mode:${NC} ${YELLOW}$execution_mode${NC}"
	echo -e "${CYAN} = = > Files In Scope:${NC} ${YELLOW}${#norm_sources[@]}${NC}"

	case "$execution_mode" in
		ADAPTIVE)
			echo -e "${CYAN} = = > Adaptive Mode Selected.${NC}"
			echo -e "${CYAN} = = > Rolling CRF Will Update From File To File.${NC}"
			echo -e "${CYAN} = = > Concurrency Presets Do Not Apply In This Mode.${NC}"
			echo

			if ! ask_yes_no " = = > Start Adaptive Mode Batch Now? (y/n or 1/2): "; then
				echo -e "${YELLOW} = = > Adaptive Mode Launch Canceled.${NC}"
				pause
				return 0
			fi
			echo

			run_batch_normalizer_adaptive "${norm_sources[@]}"
			return 0
			;;

		THROUGHPUT)
			echo -e "${CYAN} = = > Fixed Batch CRF Will Be Used For This Pass.${NC}"
			echo -e "${CYAN} = = > ${GREEN}Light ${YELLOW}Medium ${RED}Thrash ${CYAN}Concurrency Is Available Here.${NC}"

			if ! max_jobs="$(rekey_choose_throughput_job_count)"; then
				echo
				echo -e "${YELLOW} = = > Throughput Mode Canceled At Load Selection.${NC}"
				pause
				return 0
			fi

			echo
			echo -e "${CYAN} = = > Max Parallel Jobs Selected:${NC} ${GREEN}$max_jobs${NC}"
			echo

			if ! ask_yes_no " = = > Start Throughput Mode Batch Now? (y/n or 1/2): "; then
				echo -e "${YELLOW} = = > Throughput Mode Launch Canceled.${NC}"
				pause
				return 0
			fi
			echo

			run_batch_normalizer_throughput "$max_jobs" "${norm_sources[@]}"
			return 0
			;;

		*)
			echo -e "${REB} = = > Unknown Execution Mode Returned:${NC} $execution_mode"
			pause
			return 1
			;;
	esac
}

# ============================================================
# #MARKER: POST-NORMALIZE REKEY REGISTRATION PASS
# ============================================================
# PURPOSE:
# - After Batch Normalizer creates REKEY files, register ONLY
#   newly-created / not-yet-recorded REKEY pairs into info.csv.
#
# WHY THIS EXISTS:
# - Full refresh_rekey_auth_system() is too expensive to run
#   every time we merely "visit" normalization controls.
# - We only want to pay the validation cost once per new REKEY.
#
# WHAT THIS DOES:
# - Scans eligible raw/original targets
# - Looks for matching REKEY_<basename>.mkv
# - Skips rows already trusted/current in info.csv
# - Validates new REKEY files once
# - Records SAFE / RISKY verdict into the ledger
# - Enables prefer_rekey for this shell session
#
# HOUSE RULE:
# - Freshly-created REKEY files should be registered immediately.
# - Originals should NOT silently remain the preferred cutting source.
# ============================================================
register_new_rekeys_after_batch_normalizer() {
	local -a targets=()
	local raw base rekey verdict
	local checked=0
	local newly_recorded=0
	local already_known=0
	local missing_rekey=0
	local safe_count=0
	local risky_count=0

	ensure_info_map
	mapfile -t targets < <(prepare_collect_rekey_scope_targets)

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}   POST-NORMALIZE :: REKEY REGISTRATION PASS    ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Registering Newly Available REKEY Files Into info.csv...${NC}"
	echo

	for raw in "${targets[@]}"; do
		[[ -f "$raw" ]] || continue

		base="${raw%.*}"
		rekey="REKEY_${base}.mkv"

		if [[ ! -f "$rekey" ]]; then
			((missing_rekey+=1)) || :
			continue
		fi

		# --------------------------------------------------------
		# SKIP IF THIS RAW -> REKEY PAIR IS ALREADY TRUSTED/CURRENT
		# --------------------------------------------------------
		if cached_rekey_is_trusted_for_raw "$raw" "$rekey"; then
			((already_known+=1)) || :
			continue
		fi

		# --------------------------------------------------------
		# ALSO SKIP IF THIS EXACT REKEY HAS ALREADY BEEN CHECKED
		# FOR THIS RAW AND THE CACHE ROW IS CURRENT.
		# --------------------------------------------------------
		if info_cache_is_current "$raw"; then
			if [[ "$(info_get_working_name "$raw" 2>/dev/null || true)" == "$rekey" ]]; then
				if [[ "$(info_get_validated_once "$raw" 2>/dev/null || true)" == "1" ]]; then
					((already_known+=1)) || :
					continue
				fi
			fi
		fi

		((checked+=1)) || :
		echo -e "${CYAN} = = > [CHECKING]${NC} RAW:   ${GREEN}$raw${NC}"
		echo -e "${CYAN} = = > [MATCHED] ${NC} REKEY: ${GREEN}$rekey${NC}"

		if is_cut_friendly_rekey_file "$rekey"; then
			verdict="SAFE"
			record_working_source_state "$raw" "$rekey" "1" "1" "$verdict" "$rekey"
			echo -e "${GREEN} = = > [AUTHORIZED]${NC} $rekey"
			((safe_count+=1)) || :
		else
			verdict="RISKY"
			record_working_source_state "$raw" "$rekey" "0" "1" "$verdict" "$rekey"
			echo -e "${YEB} = = > [RECORDED REJECT]${NC} $rekey"
			((risky_count+=1)) || :
		fi

		((newly_recorded+=1)) || :
		echo
	done

	# --------------------------------------------------------
	# BIAS FUTURE SOURCE RESOLUTION TOWARD REKEY
	# --------------------------------------------------------
	prefer_rekey="0"

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}    POST-NORMALIZE REKEY REGISTRATION SUMMARY   ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN} = = > New REKEY Pairs Checked:${NC} $checked"
	echo -e "${GREEN} = = > Newly Recorded SAFE Rows:${NC} $safe_count"
	echo -e "${YELLOW} = = > Newly Recorded RISKY Rows:${NC} $risky_count"
	echo -e "${CYAN} = = > Already Known / Skipped:${NC} $already_known"
	echo -e "${CYAN} = = > Raw Targets Without REKEY:${NC} $missing_rekey"
	echo -e "${GREEN} = = > REKEY Preference Forced ON For This Shell Session.${NC}"
	echo
}

# ==============================================================================
# --- FUNCTION 7: SMARTGAP (RED) <---Old Tech Not Really Used Anymore
# ==============================================================================
run_smartgap() {

# ==============================================================================
#  SMARTGAP v2 :: SURGERY STAGE / INTRO REMOVAL / TRIM / JOIN HANDOFF AREA
#  go to inspect_show_notes() on this page and read that EOF block so we dont 
#  duplicate a wall of text anymore that we did already
#  BEST USED AFTER SOURCE PREP / NORMALIZATION WHEN NEEDED:
#   - Consistent Codec / Container Behavior Helps
#   - Constant-Frame-Rate Helps
#   - Tight Keyframes / Clean GOP Structure Help Stream-Copy Cuts Behave Better
#
#  WHAT THIS SURGERY STAGE CURRENTLY COVERS:
#   - CSV-Aware Intro Removal From intro_map.csv
#   - Manual / Map-Assisted Intro Cut Work
#   - Global Offset Support
#       * Applied To Intro Start Only
#       * Preserves Intro Duration
#   - Global Pre-Trim
#       * Example: MGM Logo / Studio Bumper / Lead-In Junk
#   - Global Post-Trim
#       * Example: End Credits / Preview / Tail Junk
#   - Title-Bar Repair During Output Build
#       * Prompt Underscore Segment
#       * Remove SxxExx From Metadata Title
#       * Processed Filenames Are Renamed SMC_<Original>
#   - Non-Destructive Output Philosophy
#       * Original Working Files Are Not Modified In-Place Here
#   - Stream-Copy Or Clean-Cut Focus
#       * No Seam Reencode In This SMARTGAP Path
#
#  CLIP-GRAB / JOIN RELATIONSHIP:
#   - SMARTGAP Menu Now Serves As The Shared Surgery Area For:
#       * Batch Episode Cutting
#       * Clip Grab / Bit Harvest / Join-Two-Clips Style Work
#   - In Other Words:
#       * SMARTGAP = Episode Surgery Stage
#       * Clip-Grab / Clip-Join = Specialty Surgery Tools In The Same Zone
#
#  intro_map.csv NOTES:
#   - Machine-Safe Timing Still Lives In Numeric start/end Seconds
#   - Human-Readable start_hms/end_hms May Also Be Present For Eyeballs
#   - SMARTGAP Logic Continues Trusting Numeric Seconds, Not The Display Columns
#
#  PRACTICAL NOTES:
#   - Best Accuracy Still Comes From Well-Prepared Sources <<<<<<<<<<<<<<<<<<<
#   - Pilot A Few Episodes First Before Full-Batch Surgery
#   - If Behavior Is Consistent, Fix With Offset / Pad / Trim Before Reaching
#     For More Templates
#   - This Path Produces SMC_ Outputs Intended To Become Final Replacements
#     Later In Finalize / Cleanup
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# - #MARKER: COLORS used to be here , this comment can go after a while
# - Uses Global Color Definitions (Do Not Redefine Locally)
# - so there

# =========================
# #MARKER: DEFAULTS
# =========================
DEFAULT_MAP="intro_map.csv"
DEFAULT_GLOBAL_OFFSET="0"      # Seconds (+/-) Applied To Intro Start Only
DEFAULT_PRE_TRIM="0"           # Remove From Very Beginning (seconds)
DEFAULT_POST_TRIM="0"          # Remove From Very End (seconds)
DEFAULT_TITLE_SEGMENT="3"      # Underscore Segment Index To Begin Title (1-based)
DEFAULT_WIPE_META="n"          # Y=Blast Metadata, N=Preserve Most, But Always Set Title
DEFAULT_PAD_START="0"          # Seconds (+/-) Applied To Intro START After Map/Manual
DEFAULT_PAD_END="0"            # Seconds (+/-) Applied To Intro END After Map/Manual


# =========================
# #MARKER: NUM NORM (MUST BE BEFORE PROMPTS)
# =========================
# Normalize numeric string for bc:
# - trim whitespace
# - remove leading '+'
# - empty -> 0
num_norm() {
  local v
  v="$(echo "${1:-}" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/^\+//')"
  [[ -z "$v" ]] && v="0"
  echo "$v"
}

# =========================
# #MARKER: BANNER + PROMPTS
# =========================
clear
echo -e "${MAGENTA}================================================${NC}"
echo -e "${MAGENTA}   SMARTGAP v2 :: Normalized Pipeline = = = =     ${NC}"
echo -e "${MAGENTA}================================================${NC}"
echo

prompt_read " = = > Map CSV File? (Default: ${DEFAULT_MAP}): " MAP_FILE
MAP_FILE=${MAP_FILE:-$DEFAULT_MAP}

prompt_read " = = > Global offset seconds to apply to intro START (+/-) (Default: ${DEFAULT_GLOBAL_OFFSET}): " GLOBAL_OFFSET
GLOBAL_OFFSET=${GLOBAL_OFFSET:-$DEFAULT_GLOBAL_OFFSET}

prompt_read " = = > Pad intro START seconds (+/-) After Map/Manual (Default: ${DEFAULT_PAD_START}): " PAD_START
PAD_START=${PAD_START:-$DEFAULT_PAD_START}

prompt_read " = = > Pad intro END seconds (+/-) After Map/Manual (Default: ${DEFAULT_PAD_END}): " PAD_END
PAD_END=${PAD_END:-$DEFAULT_PAD_END}

prompt_read " = = > Global PRE-trim seconds (Remove From Beginning) (Default: ${DEFAULT_PRE_TRIM}): " PRE_TRIM
PRE_TRIM=${PRE_TRIM:-$DEFAULT_PRE_TRIM}

prompt_read " = = > Global POST-trim seconds (Remove From End) (Default: ${DEFAULT_POST_TRIM}): " POST_TRIM
POST_TRIM=${POST_TRIM:-$DEFAULT_POST_TRIM}

GLOBAL_OFFSET="$(num_norm "$GLOBAL_OFFSET")"
PAD_START="$(num_norm "$PAD_START")"
PAD_END="$(num_norm "$PAD_END")"
PRE_TRIM="$(num_norm "$PRE_TRIM")"
POST_TRIM="$(num_norm "$POST_TRIM")"

echo
echo -e "${CYAN} = = > Title Bar Repair ---${NC}"

prompt_read " = = > Start Title At Which Underscore Segment? (1-based, Default: ${DEFAULT_TITLE_SEGMENT}): " TITLE_SEGMENT
TITLE_SEGMENT=${TITLE_SEGMENT:-$DEFAULT_TITLE_SEGMENT}
KF_CHECK=${KF_CHECK:-n}
WIPE_META=${WIPE_META:-$DEFAULT_WIPE_META}

echo

# =========================
# #MARKER: FILE TARGETS
# =========================

# ========================================================
# TARGET BUILD RULES
# --------------------------------------------------------
# NORMAL RUNS:
# - Build visible targets from the working directory
# - This preserves the long-standing behavior where a file
#   missing from intro_map.csv can still halt for manual input
#
# PILOT RUNS:
# - Build targets STRICTLY from column 1 of the current MAP_FILE
# - This is required so pilot mode processes only the chosen
#   2–3 sample rows instead of sweeping the full folder
# ========================================================

if [[ "${PILOT_MODE:-0}" == "1" ]]; then
  # ------------------------------------------------------
  # PILOT MODE: derive target list ONLY from current MAP_FILE
  # ------------------------------------------------------
  FILES=()

  if [[ ! -f "$MAP_FILE" ]]; then
    echo -e "${RE} = = > Pilot MAP_FILE Not Found:${NC} $MAP_FILE"
    exit 1
  fi

  while IFS=',' read -r map_file _rest; do
    [[ -z "${map_file:-}" ]] && continue
    [[ "$map_file" == "filename" ]] && continue
    [[ -f "$map_file" ]] || continue
    FILES+=("$map_file")
  done < "$MAP_FILE"

else
  # ------------------------------------------------------
  # NORMAL MODE: derive visible targets from working folder
  # ------------------------------------------------------
  shopt -s nullglob nocaseglob
  FILES=(*.mkv *.mp4 *.avi *.mov *.mpg *.mpeg *.ts *.m4v *.flv *.webm *.wmv)
  shopt -u nullglob nocaseglob

  # Filter out internal/generated files from the visible target list.
  # SMARTGAP should target original episode identities

  FILTERED=()
  for f in "${FILES[@]}"; do
	[[ "$f" =~ ^SMC_ ]] && continue
	[[ "$f" =~ ^PILOT_SMC_ ]] && continue
    [[ "$f" =~ ^REKEY_ ]] && continue
    [[ "$f" =~ ^BARFIX_ ]] && continue
    [[ "$f" =~ ^intro_template ]] && continue
    FILTERED+=("$f")
  done
  FILES=("${FILTERED[@]}")
fi

# ========================================================
# #MARKER: APPLY TARGET LIMITER / MANUAL PICKER
# ========================================================
if [[ "${PILOT_MODE:-0}" != "1" ]]; then
	if ! limit_targets_interactive FILES; then
		echo -e "${YELLOW} = = > Factory Batch Selection Cancelled.${NC}"
		pause
		return 0
	fi
fi

TOTAL=${#FILES[@]}
if [[ "$TOTAL" -eq 0 ]]; then
  echo -e "${RE} = = > No Targets Found In This Folder / Map.${NC}"
  exit 1
fi

# =========================
# #MARKER: HELPERS
# =========================


  # ========================================================
  # PILOT MODE SAFETY:
  # - Pilot runs must NEVER collide with real full-batch outputs.
  # - If PILOT_MODE=1, force a distinct output prefix.
  # - Otherwise use the normal SMARTGAP default prefix.
  # ========================================================

safe_out_name() {
  local in="$1"

  if [[ "${PILOT_MODE:-0}" == "1" ]]; then
    echo "PILOT_SMC_${in%.*}.mkv"
  else
    echo "SMC_${in%.*}.mkv"
  fi
}

lookup_map() {
  local file="$1"
  local base_file
  base_file="$(basename "$file")"

  [[ -f "$MAP_FILE" ]] || { echo ""; return 0; }

  # exact match on first CSV column
  awk -F',' -v f="$base_file" '$1==f {print; exit}' "$MAP_FILE" 2>/dev/null || true
}

# Safe float math
# Safe float math
#fadd() { echo "scale=3; ($1)+($2)" | bc; }
#fsub() { echo "scale=3; ($1)-($2)" | bc; }
#fmax0() { echo "scale=3; if(($1)<0) 0 else ($1)" | bc; }

# =========================
# #MARKER: KEYFRAME FILE SELECTOR
# =========================
select_keyframe_probe_target() {
  local i choice

  echo -e "${CYAN} = = > Keyframe Probe Target Selection ====${NC}"
  for ((i=0; i<${#FILES[@]}; i++)); do
    echo -e "  ${CYAN}$((i+1)))${NC} ${FILES[$i]}"
  done
  echo

  echo -e "${YELLOW} = = > Probe Which File Number? (blank = skip): ${NC}"
  read -r choice

  if [[ -z "$choice" ]]; then
    KF_TARGET_FILE=""
    return 0
  fi

  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo -e "${YELLOW} = = > Invalid Selection. Skipping Keyframe Probe.${NC}"
    KF_TARGET_FILE=""
    return 0
  fi

  if (( choice < 1 || choice > ${#FILES[@]} )); then
    echo -e "${YELLOW} = = > Out-Of-Range Selection. Skipping Keyframe Probe.${NC}"
    KF_TARGET_FILE=""
    return 0
  fi

  KF_TARGET_FILE="${FILES[$((choice-1))]}"
  echo -e "${GREEN} = = > Keyframe Probe Target:${NC} ${KF_TARGET_FILE}"
  echo
}

# =========================
# #MARKER: CLEAN TEMP + TRAP
# =========================
TMPDIR="_smartgap_tmp_v2"

if [[ "${PILOT_MODE:-0}" == "1" ]]; then
	pilot_begin_session "smartgap"
fi

cleanup() { rm -rf "$TMPDIR"; }

on_abort() {
	echo -e "\n${REB} = = > ABORTED. Cleaning Temp...${NC}"

	if [[ -n "${ARCHIVE_TMPDIR:-}" && -d "$ARCHIVE_TMPDIR" ]]; then
		rm -rf -- "$ARCHIVE_TMPDIR"
		echo -e "${GREEN} = = > Removed Archive Temp Workspace.${NC}"
	fi

	# ========================================================
	# HASH ENGINE ABORT CLEANUP
	# ========================================================
	rm -f -- \
		"${PHASH_ENGINE:-.phash_engine.py}" \
		".phash_engine.py" \
		".hash_engine.py" \
		".phash_engine.stderr.log" \
		".hash_engine.stderr.log"

	# ========================================================
	# EMERGENCY PILOT RESTORE
	# --------------------------------------------------------
	# PURPOSE:
	# - Prevent pilot-mode side effects from persisting after
	#   an interrupted run (Ctrl+C / SIGTERM)
	#
	# WHAT THIS PROTECTS AGAINST:
	# - intro_map.csv left in pilot-swapped state
	# - GOOD_intro_map.csv stranded under backup name
	# - orphaned PILOT_SMC_* outputs cluttering workspace
	#
	# DESIGN DECISION (NON-INTERACTIVE):
	# - Abort paths must be fast, deterministic, and safe
	# - No user prompts allowed here (signal context)
	#
	# ACTIONS TAKEN:
	# - Restore original intro_map.csv if backup exists
	# - Remove ALL PILOT_SMC_* outputs
	# - Proceed with normal temp cleanup
	#
	# NOTE:
	# - This ONLY triggers when PILOT_MODE=1
	# - Normal SMARTGAP runs are unaffected
	# ========================================================
	if [[ "${PILOT_MODE:-0}" == "1" ]]; then
		pilot_abort_recovery
	fi

		# Always clean temp workspace
		cleanup
		exit 1
	}

	trap on_abort SIGINT SIGTERM


	remove_all_pilot_outputs() {
		local found=0

		echo -e "${CYAN} = = > Removing All Existing PILOT_SMC_* Outputs...${NC}"

		shopt -s nullglob
		for f in PILOT_SMC_*; do
			[[ -e "$f" ]] || continue
			rm -f -- "$f"
			echo -e "${GREEN} = = > Removed:${NC} $f"
			found=1
		done
		shopt -u nullglob

		if [[ "$found" -eq 0 ]]; then
			echo -e "${YELLOW} = = > No Existing PILOT_SMC_* Outputs Found.${NC}"
		fi

		echo
	}

# =========================
# #MARKER: KEYFRAME TARGET SELECT
# =========================
if [[ "${KF_CHECK:-n}" == "y" ]]; then
  select_keyframe_probe_target
fi

# =========================
# #MARKER: PREVIEW SUMMARY
# =========================
echo -e "${CYAN} = = > Targets:${NC}${GREEN} $TOTAL${NC}"
echo -e "${CYAN} = = > Map File:${NC}${GREEN} $MAP_FILE${NC}"
echo -e "${CYAN} = = > Global Offset:${NC}${GREEN} ${GLOBAL_OFFSET}s (Applies To Intro START Only)${NC}"
echo -e "${CYAN} = = > Pre-Trim/Post-Trim:${NC}${GREEN} ${PRE_TRIM}s / ${POST_TRIM}s${NC}"
echo -e "${CYAN} = = > Title Segment:${NC}${GREEN} $TITLE_SEGMENT${NC}"
echo -e "${CYAN} = = > Intro Pads Start/End:${NC}${GREEN} ${PAD_START}s / ${PAD_END}s${NC}"
echo -e "${CYAN} = = > Keyframe Check:${NC}${GREEN} $KF_CHECK${NC}"
[[ -n "${KF_TARGET_FILE:-}" ]] && echo -e "${CYAN} = = > Keyframe Probe File:${NC}${GREEN} $KF_TARGET_FILE${NC}"
echo

if ! ask_yes_no " = = > Proceed? (y/n): "; then
	echo -e "${YELLOW} = = > Canceled.${NC}"
	pause
	return 0
fi

mkdir -p "$TMPDIR"

# =========================
# #MARKER: MAIN LOOP
# =========================
for ((idx=0; idx<TOTAL; idx++)); do
  orig_in="${FILES[$idx]}"
  base_in="$(basename "$orig_in")"
  in="$(get_preferred_source_file "$orig_in")"
  out="$(safe_out_name "$base_in")"

if [[ "${PILOT_MODE:-0}" == "1" ]]; then
	pilot_register_restore_point "$orig_in" "smartgap_PILOT_SOURCE"
	pilot_register_output "$out" "smartgap_PILOT_OUTPUT"
fi

  echo
  echo -e "${MAGENTA}----------------------------------------------${NC}"
  echo -e "${MAGENTA} = = > [$((idx+1)) / $TOTAL] TARGET: ${GREEN}${base_in}${NC}"

  if [[ "$in" != "$orig_in" ]]; then
    echo -e "${CYAN} = = > Working Source Selected:${NC} ${GREEN}$(basename "$in")${NC}"
  fi

  # =========================
  # #MARKER: KEYFRAME SUITABILITY CALL
  # =========================
  if [[ "${KF_CHECK:-n}" == "y" && -n "${KF_TARGET_FILE:-}" && "$orig_in" == "$KF_TARGET_FILE" ]]; then
    probe_keyframe_suitability "$in"
    echo
  fi

  if [[ -f "$out" ]]; then
    echo -e "${YELLOW} = = > [SKIP] Output Exists: $out${NC}"
    continue
  fi

  # ---- duration ----
  dur="$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$in" 2>/dev/null || true)"
  if [[ -z "$dur" ]]; then
    echo -e "${REB} = = > [FAIL] Could Not Read Duration.${NC}"
    continue
  fi
  dur="$(printf "%.3f" "$dur" 2>/dev/null || echo "$dur")"

  # ---- intro start/end from CSV else manual ----
  map_line="$(lookup_map "$orig_in")"
  if [[ -n "$map_line" ]]; then
    t_start="$(echo "$map_line" | cut -d',' -f2)"
    t_end="$(echo "$map_line" | cut -d',' -f3)"

    # #MARKER: NORM MAP TIMES
    t_start="$(num_norm "$t_start")"
    t_end="$(num_norm "$t_end")"

    intro_dur="$(fsub "$t_end" "$t_start")"
    t_start="$(fadd "$t_start" "$GLOBAL_OFFSET")"
    t_start="$(fmax0 "$t_start")"
    t_end="$(fadd "$t_start" "$intro_dur")"

    echo -e "${GREEN} = = > [MAP]${NC} ${YE}Start=${t_start}s End=${t_end}s Dur=${intro_dur}s${NC}"
    else
    echo -e "${YELLOW} = = > [NO MAP]${NC} Manual Entry Needed."
    echo
    echo -e "${CYAN} = = > Enter Cut Range:${NC}"
    echo -e "${YELLOW} = = >  Start: ${NC}"
    read -r start_raw
    echo -e "${YELLOW} = = >    End: ${NC}"
    read -r end_raw
    echo

		#MARKER: NORM MANUAL TIMES
	t_start="$(to_seconds "$start_raw")"
	t_end="$(to_seconds "$end_raw")"
	intro_dur="$(fsub "$t_end" "$t_start")"

	echo -e "${CYAN} = = > Manual Start:${NC} ${start_raw} -> ${t_start}s"
	echo -e "${CYAN} = = > Manual End:${NC} ${end_raw} -> ${t_end}s"
	echo -e "${CYAN} = = > Manual Intro Duration:${NC} ${intro_dur}s"
  fi

  # ---- apply global PRE/POST trims to whole file ----
  start_keep="$(fmax0 "$PRE_TRIM")"
  end_keep="$(fsub "$dur" "$POST_TRIM")"
  if (( $(echo "$end_keep <= $start_keep" | bc -l) )); then
    echo -e "${REB} = = > [FAIL] PRE/POST Trims Invalid (End <= Start).${NC}"
    continue
  fi

  # ---- apply pads (independent start/end nudges) ----
  t_start="$(fadd "$t_start" "$PAD_START")"
  t_start="$(fmax0 "$t_start")"
  t_end="$(fadd "$t_end" "$PAD_END")"

  # sanity: prevent inverted/zero intro window
  if (( $(echo "$t_end <= $t_start" | bc -l) )); then
    echo -e "${REB} = = > [FAIL] Pads Caused Invalid Intro Window (End <= Start). Skipping.${NC}"
    continue
  fi

  # intro must fall inside keep window
  if (( $(echo "$t_start < $start_keep" | bc -l) )); then t_start="$start_keep"; fi
  if (( $(echo "$t_end > $end_keep" | bc -l) )); then t_end="$end_keep"; fi

  # segments:
  # A: [start_keep .. t_start]
  # B: [t_end .. end_keep]
  A0="$start_keep"
  A1="$t_start"
  B0="$t_end"
  B1="$end_keep"

  # If intro collapses to nothing, this becomes a pure pre/post trim job.
  if (( $(echo "$A1 <= $A0" | bc -l) )) && (( $(echo "$B1 <= $B0" | bc -l) )); then
    echo -e "${REB} = = > [FAIL] Nothing Left After Trims/Intro Removal. Skipping.${NC}"
    continue
  fi

  # ---- title ----
  title="$(make_title_from_filename "$base_in" "$TITLE_SEGMENT")"
  echo -e "${CYAN} = = > Title Segment In Use:${NC} ${GREEN}${TITLE_SEGMENT}${NC}"
  echo -e "${CYAN} = = > Title Bar:${NC} ${GREEN}${title}${NC}"

  # ---- per-job temp workspace ----
  work="$TMPDIR/job_$idx"
  rm -rf "$work"
  mkdir -p "$work"
  join="$work/join.txt"
  : > "$join"

  # metadata flags
  meta_flags=()
  if [[ "$WIPE_META" == "y" ]]; then
    meta_flags=(-map_metadata -1)
  fi

  add_join() {
    local f="$1"
    local abs
    abs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
    echo "file '$abs'" >> "$join"
  }

  # ---- build A ----
  if (( $(echo "$A1 > $A0" | bc -l) )); then
    segA="$work/A.mkv"
    if ffmpeg -hide_banner -loglevel error -nostdin \
      -ss "$A0" -to "$A1" -i "$in" \
      -c copy -map 0 -avoid_negative_ts make_zero \
      "$segA" -y; then
      add_join "$segA"
    else
      echo -e "${REB} = = > [FAIL] Segment A Slice Failed.${NC}"
      continue
    fi
  fi

  # ---- build B ----
  if (( $(echo "$B1 > $B0" | bc -l) )); then
    segB="$work/B.mkv"
    if ffmpeg -hide_banner -loglevel error -nostdin \
      -ss "$B0" -to "$B1" -i "$in" \
      -c copy -map 0 -avoid_negative_ts make_zero \
      "$segB" -y; then
      add_join "$segB"
    else
      echo -e "${REB} = = > [FAIL] Segment B Slice Failed.${NC}"
      continue
    fi
  fi

  # ---- concat copy ----
  tmpout="$work/out.mkv"
  echo -e "${CYAN} = = > [CONCAT] Building Output...${NC}"
  if ffmpeg -hide_banner -loglevel error -nostdin \
    -f concat -safe 0 -i "$join" \
    -c copy \
    "${meta_flags[@]}" -metadata title="$title" \
    -fflags +genpts -avoid_negative_ts make_zero -flags +global_header \
    "$tmpout" -y; then

    mv "$tmpout" "$out"
    echo -e "${GREEN} = = > [OK] Created: ${CYAN}${out}${NC}"
  else
    echo -e "${REB} = = > [FAIL]${NC} Concat-Copy refused."
    echo -e "${YELLOW} = = > Tip:${NC} Ensure Files Are Normalized Consistently (codec/fps/pix_fmt/tracks)."
    echo -e "${YELLOW} = = > Tip:${NC} If A Source Is Damaged, Remux Once:"
    echo -e "  ffmpeg -i \"${base_in}\" -map 0 -c copy \"REMUX_${base_in%.*}.mkv\""
  fi
done

cleanup
echo
echo -e "${MAGENTA}================================================${NC}"
echo -e "${MAGENTA}       SMARTGAP v2 Complete.${NC}"
echo -e "${MAGENTA}================================================${NC}"

    pause
    return 0
}

# End Of SMARTGAP

# ============================================================
# #MARKER: NORMALIZE-FIRST WORKFLOW HELPERS
# ============================================================
# PURPOSE:
# - Offer A One-Shot Directory-Level Normalize Pass Before Detection/Cutting Work.
# - Set A Simple Global Preference Flag So Later Stages May Prefer REKEY Sources.
#
# DESIGN:
# - Default Is OFF.
# - Only Enabled When The User Explicitly Says Yes.
# - This Helper Should Be Called From Higher-Level Workflow Entry Points,
#   Never From Per-File Loops.
prefer_rekey="0"

prompt_normalize_first_workflow() {
    echo
    echo -e "${CYAN}==== REKEY Source Selection / Normalize-First Workflow ====${NC}"
    echo -e "${CYAN}= = = = = What Your Answer Really Means = = = = = = =${NC}"
    echo -e "${GREEN}YES:  = = > Yes Means Use Existing REKEY Files As Working Source For This Operation${NC}"
    echo -e "${GREEN}YES:  = = > Build Missing REKEY Files If Needed (Existing Matching REKEY Files Are Skipped)${NC}"
    echo -e "${YELLOW} = = > NO:  = = > No Means No  = = > Use Original Source Files Instead${NC}"
    echo

	if ask_yes_no " = = > Use REKEY Files As Working Source For This Operation? (y/n or 1/2): "; then
		prefer_rekey="1"
		echo -e "${GREEN} = = > REKEY Source Preference Enabled.${NC}"
		echo -e "${CYAN} = = > Existing Matching REKEY Files Will Be Preferred As Source.${NC}"
	else
		prefer_rekey="0"
		echo -e "${YELLOW} = = > REKEY Preference Disabled For This Shell Session.${NC}"
		echo -e "${YEB} = = > WARNING: REKEY Preference Is OFF.${NC}"
		echo -e "${YELLOW} = = > Cutting From Originals Is Discouraged And May Produce Bad Cuts.${NC}"
		echo -e "${CYAN} = = > Original Source Files Remain The Preferred Working Source.${NC}"
	fi
}

# start of REKEY AUTO-SELECTION HELPERS

# ============================================================
# #MARKER: REKEY AUTO-SELECTION HELPERS
# ============================================================
# PURPOSE:
# - Prefer A Matching REKEY_ Source Automatically When Normalize-First Mode
#   Has Been Enabled And A Rebuilt Version Already Exists.
# - Decides Which Existing Source File To Hand Forward.
#
# WHY THIS EXISTS:
# - Repeated IntroFind Passes On The Same Season Were Re-Paying The
#   is_cut_friendly_rekey_file() Tax Again And Again.
# - That Was Wasteful, Especially When intro_map.csv Was Still Evolving
#   Across Multiple Detection Runs And Key Creation/Additions.
#
# NEW CACHE-AWARE DESIGN:
# - First Reuse Trusted Positive Cache Hits
# - Before Re-Probing Cut-Friendliness, Ask info.csv Whether This Exact
#   REKEY Candidate Was Already Validated And Trusted For This Raw File.
# - Then Honor Known Negative Cache Hits
# - Only Then Pay The Expensive Probe Cost
# - If Yes, Reuse It Immediately.
# - If No, Pay The Expensive Probe Once, Then Record The Result.
#
get_preferred_source_file() {
    local src="$1"
    local dir base rekey verdict
	# ========================================================
	# CANONICALIZE SOURCE ON ENTRY
	# ========================================================
	# WHY:
	# - Keep candidate REKEY path generation stable.
	src="$(canonical_factory_path "$src")"

    dir="$(dirname "$src")"
    base="$(basename "$src")"
    rekey="$dir/REKEY_${base%.*}.mkv"
	rekey="$(canonical_factory_path "$rekey")"

    # ========================================================
    # GATE 0: FEATURE DISABLED
    # ========================================================
    if [[ "$prefer_rekey" != "1" ]]; then
        printf '%s\n' "$src"
        return 0
    fi

    # ========================================================
    # GATE 1: NO MATCHING REKEY FILE EXISTS
    # ========================================================
    if [[ ! -f "$rekey" ]]; then
        printf '%s\n' "$src"
        return 0
    fi

    # ========================================================
    # GATE 2: TRUSTED CACHE HIT
    # ========================================================
    if cached_rekey_is_trusted_for_raw "$src" "$rekey"; then
        echo -e "${GR} = = > Found Trusted Cached REKEY Source, Using:${NC} ${CYAN}$(basename "$rekey")${NC}" >&2
        printf '%s\n' "$rekey"
        return 0
    fi

    # ========================================================
    # GATE 3: KNOWN NEGATIVE CACHE HIT
    # ========================================================
    # WHY:
    # - We Already Tested This Exact REKEY Candidate For This Exact Raw File.
    # - It Already Failed To Earn Trusted Status.
    # - Do NOT Waste Time Probing It Again Unless The Raw File Changed.
    #
    if cached_rekey_is_known_bad_for_raw "$src" "$rekey"; then
        echo -e "${YE} = = > REKEY Was Previously Tested And Rejected. Skipping Re-Validation:${NC} $(basename "$rekey")" >&2
        printf '%s\n' "$src"
        return 0
    fi

    # ========================================================
    # GATE 4: EXPENSIVE PROBE PATH
    # ========================================================
    # No reusable cache answer was found.
    # Pay The Probe Cost Once, Then Record The Result.
    #
    if is_cut_friendly_rekey_file "$rekey"; then
        verdict="SAFE"
        record_working_source_state "$src" "$rekey" "1" "1" "$verdict" "$rekey"
        echo -e "${GR} = = > Found Valid Cut-Friendly REKEY File, Using:${NC} $(basename "$rekey")" >&2
        printf '%s\n' "$rekey"
        return 0
    fi

    # ========================================================
    # GATE 5: REKEY EXISTS BUT FAILED FRIENDLINESS CHECK
    # ========================================================
    verdict="RISKY"
    record_working_source_state "$src" "$rekey" "0" "1" "$verdict" "$rekey"

    echo -e "${RE} = = > Found REKEY File, But It Is Not Cut-Friendly. Ignoring:${NC} $(basename "$rekey")" >&2
    printf '%s\n' "$src"
}

# end of REKEY AUTO-SELECTION HELPERS
# start of NEGATIVE REKEY CACHE CHECK
# =========================
# #MARKER: NEGATIVE REKEY CACHE CHECK
# =========================
# PURPOSE:
# - Detect A REKEY Candidate We Already Tested And Already Rejected.
# - Prevent Paying The Same Expensive Cut-Friendliness Probe Again.
#
# WHY THIS EXISTS:
# - Positive Cache Reuse Is Already Handled By:
#     cached_rekey_is_trusted_for_raw
# - But Negative Results Were Only Being RECORDED, Not HONORED.
# - That Meant Known-Bad REKEY Files Could Still Be Re-Probed On Later Runs.
#
# NEGATIVE CACHE RULE:
# - working_name must match this exact REKEY candidate
# - raw_name must match this exact raw file
# - validated_once must be 1
# - auth_rekey must be 0
# - verdict should indicate a previously rejected / non-trusted result
# - raw-file signature must still be current
#
# IMPORTANT:
# - This Is NOT Saying The REKEY File Is Corrupt.
# - It Only Means:
#     "We Already Checked This Candidate For This Raw File, And It Did NOT
#      Earn Trusted-Working-Source Status."
# - If The Raw File Changes, Cache Is Invalid And We Probe Again.
#
cached_rekey_is_known_bad_for_raw() {
    local raw="$1"
    local rekey="$2"
    local cached_raw auth validated verdict
	# ========================================================
	# CANONICALIZE BOTH COMPARISON SIDES ON ENTRY
	# ========================================================
	raw="$(canonical_factory_path "$raw")"
	rekey="$(canonical_factory_path "$rekey")"

    [[ -f "$rekey" ]] || return 1

    cached_raw="$(info_get_raw_name_by_working "$rekey" 2>/dev/null || true)"
	# ========================================================
	# CANONICALIZE CACHED RAW NAME BEFORE COMPARISON
	# ========================================================
	cached_raw="$(canonical_factory_path "$cached_raw")"
    auth="$(info_get_auth_rekey_by_working "$rekey" 2>/dev/null || true)"
    validated="$(info_get_validated_once_by_working "$rekey" 2>/dev/null || true)"
    verdict="$(info_get_keyframe_verdict_by_working "$rekey" 2>/dev/null || true)"

    [[ -n "$cached_raw" ]] || return 1
    [[ "$cached_raw" == "$raw" ]] || return 1
    [[ "$auth" == "0" ]] || return 1
    [[ "$validated" == "1" ]] || return 1

    # Raw source must still match the ledger signature.
    info_cache_is_current "$raw" || return 1

    case "$verdict" in
        RISKY|BAD|REJECTED|FAILED)
            return 0
            ;;
    esac

    return 1
}

# end of NEGATIVE REKEY CACHE CHECK

ensure_phash_engine() {
	# During engine development, always rebuild from the current Factory source.
	rm -f -- "$PHASH_ENGINE"

	echo -e "${YE} = = > Building Local xHash Engine:${NC} ${GREEN}$(factory_display_path "$PHASH_ENGINE")${NC}"

	# IMPORTANT:
	# Move/copy the existing full:
	#   cat << 'EOF' > .phash_engine.py
	# Python block into this helper.
	#
	# Change its first line from:
	#   cat << 'EOF' > .phash_engine.py
	# to:
	#   cat << 'EOF' > "$PHASH_ENGINE"

	cat << 'EOF' > "$PHASH_ENGINE"
import cv2, imagehash, glob, os, sys, re
from PIL import Image

# ============================================================
# ARGUMENT CONTRACT
# ------------------------------------------------------------
# KEEP THE ORIGINAL FOUR POSITIONS EXACTLY AS THEY WERE:
#
#   sys.argv[1] = SCAN_START
#   sys.argv[2] = LIMIT
#   sys.argv[3] = HASH_DIFF
#   sys.argv[4] = FILE
#
# OPTIONAL ADDITIONS AFTER THAT:
#
#   sys.argv[5] = STEP SIZE         (example: "0.5")
#   sys.argv[6] = ANCHOR SECONDS    (example: "3,5,7")
#
# Stdout contract must remain:
#   MATCH|start|end|template|diff
#   NO_MATCH
# ============================================================

SCAN_START = float(sys.argv[1])
LIMIT      = float(sys.argv[2])
HASH_DIFF  = int(sys.argv[3])
FILE       = sys.argv[4]

# Optional separate ceiling for candidate INTRO START positions.
# LIMIT remains the media / anchor-sampling ceiling.
CANDIDATE_END = LIMIT

if len(sys.argv) >= 10:
    try:
        CANDIDATE_END = float(sys.argv[9])
    except Exception:
        print(
            f"WARN|bad candidate-end arg '{sys.argv[9]}', using LIMIT {LIMIT}",
            file=sys.stderr
        )
        CANDIDATE_END = LIMIT

# ============================================================
# OPTIONAL TUNING INPUTS
# ------------------------------------------------------------
# Safe defaults if Bash does not pass the extra knobs.
# ============================================================

HASH_MODE = "phash"

if len(sys.argv) >= 9:
    HASH_MODE = sys.argv[8].strip().lower()

if HASH_MODE not in ("phash", "dhash", "ahash", "whash"):
    print(f"WARN|unknown HASH_MODE '{HASH_MODE}', using phash", file=sys.stderr)
    HASH_MODE = "phash"

DEFAULT_STEP = 0.5
DEFAULT_ANCHORS = [3.0, 5.0, 7.0]

STEP = DEFAULT_STEP
ANCHOR_OFFSETS = DEFAULT_ANCHORS[:]

if len(sys.argv) >= 6:
    try:
        STEP = float(sys.argv[5])
    except Exception:
        print(f"WARN|bad step arg '{sys.argv[5]}', using default {DEFAULT_STEP}", file=sys.stderr)
        STEP = DEFAULT_STEP

if len(sys.argv) >= 7:
    raw_anchor_arg = sys.argv[6].strip()
    if raw_anchor_arg:
        try:
            parsed = []
            for piece in raw_anchor_arg.split(","):
                piece = piece.strip()
                if not piece:
                    continue
                parsed.append(float(piece))

            parsed = [x for x in parsed if x >= 0]

            if parsed:
                ANCHOR_OFFSETS = parsed
            else:
                print(f"WARN|anchor arg '{raw_anchor_arg}' produced no valid offsets, using default", file=sys.stderr)
        except Exception:
            print(f"WARN|bad anchor arg '{raw_anchor_arg}', using default {DEFAULT_ANCHORS}", file=sys.stderr)
            ANCHOR_OFFSETS = DEFAULT_ANCHORS[:]

TEMPLATE_GLOB = "intro_template/intro_template*.mkv"

if len(sys.argv) >= 8:
    TEMPLATE_GLOB = sys.argv[7]

if STEP <= 0:
    print(f"WARN|non-positive STEP {STEP}, forcing default {DEFAULT_STEP}", file=sys.stderr)
    STEP = DEFAULT_STEP

# ============================================================
# DISPLAY PATH HELPER
# ------------------------------------------------------------
# Keep real paths for processing, but shorten paths in human
# diagnostic output.
# ============================================================

def display_path(path):
    path = os.path.abspath(str(path))

    roots = [
        (os.environ.get("FACTORY_WORKDIR", os.getcwd()), "."),
        (os.environ.get("FACTORY_HOME", os.path.join(os.getcwd(), "TOOLBOX")), "TOOLBOX"),
    ]

    for root, label in roots:
        if not root:
            continue

        root = os.path.abspath(root)

        if path == root:
            return label

        if path.startswith(root + os.sep):
            rel = os.path.relpath(path, root)

            if rel.startswith("intro_template" + os.sep):
                return rel

            return label + "/" + rel

    return path

# ============================================================
# TEMPLATE SORTING
# ============================================================

def template_sort_key(p):
    name = os.path.basename(p)

    if name == "intro_template.mkv":
        return (0, 0, "")

    m = re.match(r"^intro_template_(\d+)\.mkv$", name)
    if m:
        return (1, int(m.group(1)), "")

    m = re.match(r"^intro_template(\d+)\.mkv$", name)
    if m:
        return (2, int(m.group(1)), "")

    return (9, 0, name.lower())

TEMPLATES = glob.glob(TEMPLATE_GLOB)

if not TEMPLATES and TEMPLATE_GLOB == "intro_template/intro_template*.mkv":
    TEMPLATES = glob.glob("intro_template*.mkv")

TEMPLATES.sort(key=template_sort_key)

print("TEMPLATE_ORDER|" + "|".join(display_path(p) for p in TEMPLATES), file=sys.stderr)
print(
    f"ENGINE_CFG|HASH_MODE={HASH_MODE}"
    f"|SCAN_START={SCAN_START}"
    f"|CANDIDATE_END={CANDIDATE_END}"
    f"|LIMIT={LIMIT}"
    f"|HASH_DIFF={HASH_DIFF}"
    f"|STEP={STEP}"
    f"|ANCHORS={ANCHOR_OFFSETS}",
    file=sys.stderr
)

# ============================================================
# HASH CACHE
# ------------------------------------------------------------
# Cache per (path,time) so repeated candidate/anchor checks do not
# reopen/hash the same exact frame over and over.
# ============================================================

hash_cache = {}

def get_hash(path, sec):
    cache_key = (path, round(sec, 3))
    if cache_key in hash_cache:
        return hash_cache[cache_key]

    cap = cv2.VideoCapture(path)
    cap.set(cv2.CAP_PROP_POS_MSEC, sec * 1000.0)
    res, frame = cap.read()
    cap.release()

    if not res or frame is None:
        hash_cache[cache_key] = None
        return None

    try:
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        img = Image.fromarray(rgb)

        if HASH_MODE == "dhash":
            ph = imagehash.dhash(img)
        elif HASH_MODE == "ahash":
            ph = imagehash.average_hash(img)
        elif HASH_MODE == "whash":
            ph = imagehash.whash(img)
        else:
            ph = imagehash.phash(img)

        hash_cache[cache_key] = ph
        return ph
    except Exception:
        hash_cache[cache_key] = None
        return None

# ============================================================
# TEMPLATE PREP
# ------------------------------------------------------------
# Build per-template:
#   - duration
#   - anchor hashes
#
# IMPORTANT TIMING MODEL:
# - We are scanning CANDIDATE INTRO STARTS, not candidate "matched frame"
#   positions.
# - For a candidate start S:
#       template anchor at 3s  -> compare to episode frame at S+3
#       template anchor at 5s  -> compare to episode frame at S+5
#       template anchor at 7s  -> compare to episode frame at S+7
#
# This fixes the prior broken behavior where all template anchors were
# compared against one single episode frame.
# ============================================================

template_data = []

for template in TEMPLATES:
    cap_temp = cv2.VideoCapture(template)
    fps = cap_temp.get(cv2.CAP_PROP_FPS)
    frame_count = int(cap_temp.get(cv2.CAP_PROP_FRAME_COUNT))
    cap_temp.release()

    duration = 0.0
    if fps and fps > 0:
        duration = frame_count / fps

    anchors = []
    skipped_anchor_count = 0

    for anchor_sec in ANCHOR_OFFSETS:
        # Skip anchor points beyond the template duration.
        if duration > 0 and anchor_sec > duration:
            skipped_anchor_count += 1
            continue

        h = get_hash(template, anchor_sec)
        if h is not None:
            anchors.append((anchor_sec, h))
        else:
            skipped_anchor_count += 1

    if not anchors:
        print(f"SKIP_TEMPLATE|{display_path(template)}|reason=no_valid_anchor_hashes", file=sys.stderr)
        continue

    template_data.append({
        "path": template,
        "duration": duration,
        "anchors": anchors,
        "max_anchor": max(a for a, _ in anchors),
    })

    print(
        f"TEMPLATE_READY|{display_path(template)}|duration={duration:.3f}|anchors_ok={len(anchors)}|anchors_skipped={skipped_anchor_count}",
        file=sys.stderr
    )

if not template_data:
    print("NO_MATCH")
    sys.exit(0)

# ============================================================
# FLOAT RANGE
# ============================================================

def frange(start, stop, step):
    count = 0
    value = start
    epsilon = step / 1000.0

    while value < stop + epsilon:
        yield round(value, 3)
        count += 1
        value = start + (count * step)

# ============================================================
# SCORING MODEL
# ------------------------------------------------------------
# For each candidate INTRO START and each template:
#   - compare every template anchor hash against episode frame at:
#         candidate_start + anchor_sec
#   - compute:
#         avg_diff
#         best_anchor_diff
#         best_anchor_sec
#
# Global lowest avg_diff under threshold wins.
# ============================================================

best_match = None
second_best_score = None
candidate_count = 0

for candidate_start in frange(SCAN_START, CANDIDATE_END, STEP):
    for t in template_data:
        diffs = []
        anchor_results = []
        best_anchor_diff = None
        best_anchor_sec = None

        for anchor_sec, template_hash in t["anchors"]:
            episode_sample_time = candidate_start + anchor_sec

            # Do not sample beyond the requested scan ceiling.
            if episode_sample_time > LIMIT:
                continue

            episode_hash = get_hash(FILE, episode_sample_time)
            if episode_hash is None:
                continue

            diff = template_hash - episode_hash
            diffs.append(diff)
            anchor_results.append((anchor_sec, diff))

            if best_anchor_diff is None or diff < best_anchor_diff:
                best_anchor_diff = diff
                best_anchor_sec = anchor_sec

        if not diffs:
            continue

        avg_diff = sum(diffs) / float(len(diffs))
        candidate_count += 1

        candidate_info = {
            "start_time": candidate_start,
            "template": t["path"],
            "duration": t["duration"],
            "avg_diff": avg_diff,
            "best_anchor_diff": best_anchor_diff,
            "best_anchor_sec": best_anchor_sec,
            "anchor_count": len(diffs),
			"anchor_results": anchor_results,
        }

        if best_match is None or avg_diff < best_match["avg_diff"]:
            if best_match is not None:
                prior_best = best_match["avg_diff"]
                if second_best_score is None or prior_best < second_best_score:
                    second_best_score = prior_best

            best_match = candidate_info
        else:
            if second_best_score is None or avg_diff < second_best_score:
                second_best_score = avg_diff

# ============================================================
# DECISION / OUTPUT
# ============================================================

print(f"SCAN_DONE|candidates_scored={candidate_count}", file=sys.stderr)

# ============================================================
# DEBUG: TOP CANDIDATE WINDOW
# ------------------------------------------------------------
# PURPOSE:
# - Show the best few candidates so we can see:
#     - how close non-winners are
#     - whether threshold is too strict
#     - whether matches cluster tightly or are noisy
#
# NOTE:
# - stderr only (does NOT affect Bash parsing)
# ============================================================

try:
    # Re-run lightweight ranking from collected candidates
    # We reconstruct from best_match + second_best_score is not enough,
    # so we track top candidates manually during scan.

    # This requires capturing candidates during scan
    # (we kept minimal memory earlier, so rebuild cheaply)

    debug_candidates = []

    # Re-scan lightly (cheap because of hash cache)
    for candidate_start in frange(SCAN_START, CANDIDATE_END, STEP):
        for t in template_data:
            diffs = []

            for anchor_sec, template_hash in t["anchors"]:
                episode_sample_time = candidate_start + anchor_sec
                if episode_sample_time > LIMIT:
                    continue

                episode_hash = get_hash(FILE, episode_sample_time)
                if episode_hash is None:
                    continue

                diffs.append(template_hash - episode_hash)

            if not diffs:
                continue

            avg = sum(diffs) / float(len(diffs))

            debug_candidates.append((avg, candidate_start, t["path"]))

    # Sort best first
    debug_candidates.sort(key=lambda x: x[0])

    print("TOP_CANDIDATES|showing_best_5", file=sys.stderr)

    for i, (avg, tstart, tpath) in enumerate(debug_candidates[:5]):
        print(
            f"  #{i+1}|start={tstart:.3f}|avg_diff={avg:.3f}|template={display_path(tpath)}",
            file=sys.stderr
        )

    if debug_candidates:
        best_avg, best_start, best_path = debug_candidates[0]

        print(
            "BEST_CANDIDATE"
            f"|start={best_start:.3f}"
            f"|avg_diff={best_avg:.3f}"
            f"|template={best_path}"
        )

except Exception as e:
    print(f"DEBUG_WINDOW_FAILED|{e}", file=sys.stderr)

if best_match is not None and best_match["avg_diff"] < HASH_DIFF:
    start = best_match["start_time"]
    if start < 0:
        start = 0.0

    end = start + best_match["duration"]

    print(
        f"MATCH|{int(start)}|{int(end)}|{best_match['template']}|{int(best_match['avg_diff'])}"
    )

    delta_to_next = None
    if second_best_score is not None:
        delta_to_next = second_best_score - best_match["avg_diff"]

    print(
        "BEST_MATCH"
        f"|start={best_match['start_time']:.3f}"
        f"|template={display_path(best_match['template'])}"
        f"|avg_diff={best_match['avg_diff']:.3f}"
        f"|best_anchor_diff={best_match['best_anchor_diff']}"
        f"|best_anchor_sec={best_match['best_anchor_sec']}"
        f"|anchors_used={best_match['anchor_count']}"
        f"|delta_to_next={delta_to_next}",
        file=sys.stderr
    )

    anchor_result_text = "|".join(
        f"{anchor_sec:.3f}s={diff}"
        for anchor_sec, diff in best_match["anchor_results"]
    )

    print(
        f"ANCHOR_DIFFS|{anchor_result_text}",
        file=sys.stderr
    )

    sys.exit(0)

print("NO_MATCH")
EOF
}

run_outrofind_selected_files() {
	local -a targets=()
	local file duration outro_scan_start outro_limit outro_output outro_result
	local outro_start outro_end outro_start_hms outro_end_hms
	local outro_template_used outro_diff_used
	local outro_find_t0 outro_find_t1 outro_find_elapsed outro_find_elapsed_hms

	ensure_phash_engine || {
		echo -e "${REB} = = > Could Not Build xHash Engine.${NC}"
		pause
		return 1
	}

		if (( "$(outro_template_count "${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}")" == 0 )); then
		echo -e "${REB} = = > Outro Template Missing:${NC} ${YELLOW}${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}${NC}"
		pause
		return 1
	fi

	echo -e "${CYAN} = = > Outro Map Entries Found:${NC} ${YELLOW}$(tail -n +2 "$OUTRO_MAP" 2>/dev/null | wc -l)${NC}"

	shopt -s nullglob nocaseglob
	targets=( *.mkv )
	shopt -u nullglob nocaseglob

	if (( ${#targets[@]} == 0 )); then
		echo -e "${YE} = = > No MKV Targets Found.${NC}"
		pause
		return 0
	fi

	limit_targets_interactive targets || {
		echo -e "${YE} = = > OutroFind Selection Cancelled.${NC}"
		pause
		return 0
	}

	for file in "${targets[@]}"; do
		[[ -f "$file" ]] || continue

	if already_outro_processed "$file"; then
		echo -e "${YELLOW} = = > Outro Already Mapped. Skipping:${NC} ${GREEN}$file${NC}"
		continue
	fi

		duration="$(get_file_duration_seconds "$file")"
		outro_limit="$duration"

		primary_outro_template="$(outro_template_primary "${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}")"
		resolved_outro_tail_scan="$(auto_outro_tail_scan_seconds "$primary_outro_template" "${OUTRO_TAIL_SCAN_SECONDS:-auto}")"

		outro_scan_start="$(awk -v d="$duration" -v back="$resolved_outro_tail_scan" 'BEGIN{
			v=d-back
			if (v < 0) v=0
			printf "%.3f", v
		}')"

		resolved_outro_anchors="$(auto_outro_multikey_anchor_csv "${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}" "${OUTRO_ANCHOR_SECONDS:-8,12,16}")"

		echo
		echo -e "${CYAN} = = > DEBUG HASH_MODE:${NC} ${YELLOW}${OUTRO_HASH_MODE:-dhash}${NC}"
		echo -e "${CYAN} = = > DEBUG OUTRO_HASH_DIFF:${NC} ${YELLOW}${OUTRO_HASH_DIFF:-unset}${NC}"
		echo -e "${CYAN} = = > DEBUG INTRO_HASH_DIFF:${NC} ${YELLOW}${INTRO_HASH_DIFF:-unset}${NC}"
		echo -e "${CYAN} = = > DEBUG DEFAULT_HASH_DIFF:${NC} ${YELLOW}${DEFAULT_HASH_DIFF:-unset}${NC}"
		echo
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN}                 OUTROFIND ONLY TARGET                     ${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN} = = > File:${NC} ${GREEN}$file${NC}"
		echo -e "${CYAN} = = > Window:${NC} ${YELLOW}${outro_scan_start}s → ${outro_limit}s${NC}"
		echo -e "${CYAN} = = > Settings:${NC} ${YELLOW}Diff=${OUTRO_HASH_DIFF:-16} Step=${OUTRO_STEP_SIZE:-1} Anchors=$resolved_outro_anchors"
		echo

		echo

		# ------------------------------------------------------------------
		# PHASH STDERR LOG SAFETY
		# ------------------------------------------------------------------
		# Outro-only can be entered without the earlier full IntroFind setup path,
		# so make sure the stderr log target exists before process substitution.
		PHASH_STDERR_LOG="${PHASH_STDERR_LOG:-${FACTORY_HOME}/.phash_engine.stderr.log}"
		: > "$PHASH_STDERR_LOG"

		outro_find_t0="$(date +%s)"

		outro_output="$(
			python3 "$PHASH_ENGINE" \
				"$outro_scan_start" \
				"$outro_limit" \
				"${OUTRO_HASH_DIFF:-16}" \
				"$file" \
				"${OUTRO_STEP_SIZE:-1}" \
				"$resolved_outro_anchors" \
				"${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}" \
				"${OUTRO_HASH_MODE:-dhash}" \
				2> >(tee "$PHASH_STDERR_LOG" | run_phash_engine_colored >&2)
		)"

		outro_find_t1="$(date +%s)"
		outro_find_elapsed="$((outro_find_t1 - outro_find_t0))"
		outro_find_elapsed_hms="$(format_seconds_hms "$outro_find_elapsed")"

		outro_result="$(printf '%s\n' "$outro_output" | awk '
			/^(MATCH\|.*|NO_MATCH)$/ { line=$0 }
			END { print line }
		')"

		if [[ "$outro_result" == MATCH* ]]; then
			IFS='|' read -r _ outro_start _outro_template_duration_end outro_template_used outro_diff_used <<< "$outro_result"
			outro_template_used="$(factory_template_map_path "$outro_template_used")"

			outro_end="$duration"
			outro_start_hms="$(seconds_to_hms "$outro_start")"
			outro_end_hms="$(seconds_to_hms "${outro_end%.*}")"

			echo -e "${GR} = = > Outro Match Found.${NC}"
			echo -e "${CYAN} = = > Outro Start:${NC} ${YELLOW}$outro_start${NC}${GREEN} (${outro_start_hms})${NC}"
			echo -e "${CYAN} = = > Outro End:${NC}   ${YELLOW}$outro_end${NC}${GREEN} (${outro_end_hms})${NC}"
			outro_duration="$(awk -v s="$outro_start" -v e="$outro_end" 'BEGIN{printf "%.3f", e-s}')"
			echo -e "${CYAN} = = > Outro Duration:${NC} ${YELLOW}${outro_duration}s${NC} ${GREEN}($(format_seconds_hms "$outro_duration"))${NC}"
			echo -e "${CYAN} = = > Outro Key:${NC}   ${GREEN}${outro_template_used:-${OUTRO_TEMPLATE:-intro_template/outro.mkv}}${NC}"
			echo -e "${CYAN} = = > Outro Diff:${NC}  ${YELLOW}${outro_diff_used:-}${NC}"
			echo -e "${CYAN} = = > OutroFind Time:${NC}${YELLOW} ${outro_find_elapsed}s ${NC}${GREEN}(${outro_find_elapsed_hms})${NC}"

			ensure_outro_map
			echo "$file,$outro_start,$outro_end,$outro_start_hms,$outro_end_hms,${outro_template_used:-${OUTRO_TEMPLATE:-intro_template/outro.mkv}},${outro_diff_used:-}" >> "$OUTRO_MAP"
		else
			echo -e "${REB} = = > No Outro Match Found For:${NC} ${GREEN}$file${NC}"
		fi
	done

	echo
	echo -e "${GR} = = > Standalone OutroFind Pass Complete.${NC}"
	pause
	return 0
}

run_outro_hash_compare_test() {
	local -a targets=()
	local -a hash_modes=("phash" "dhash")
	local -a anchor_sets=("8,12,16" "4,8,12,16,20")
	local file duration outro_scan_start outro_limit
	local hash_mode anchors outro_output outro_result
	local t0 t1 elapsed result_status start_val diff_val
	local log_file="outro_hash_compare.csv"

	ensure_phash_engine || {
		echo -e "${REB} = = > Could Not Build Hash Engine.${NC}"
		pause
		return 1
	}

	if [[ ! -f "$OUTRO_TEMPLATE" ]]; then
		echo -e "${REB} = = > Outro Template Missing:${NC} ${YELLOW}$OUTRO_TEMPLATE${NC}"
		pause
		return 1
	fi

	shopt -s nullglob nocaseglob
	targets=( *.mkv )
	shopt -u nullglob nocaseglob

	if (( ${#targets[@]} == 0 )); then
		echo -e "${YE} = = > No MKV Targets Found.${NC}"
		pause
		return 0
	fi

	limit_targets_interactive targets || {
		echo -e "${YE} = = > Outro Hash Compare Cancelled.${NC}"
		pause
		return 0
	}

	printf '%s\n' "file,hash_mode,anchors,result,start,diff,elapsed_seconds" > "$log_file"

	for file in "${targets[@]}"; do
		[[ -f "$file" ]] || continue

		duration="$(get_file_duration_seconds "$file")"
		outro_limit="$duration"

		outro_scan_start="$(awk -v d="$duration" -v back="${OUTRO_TAIL_SCAN_SECONDS:-200}" 'BEGIN{
			v=d-back
			if (v < 0) v=0
			printf "%.3f", v
		}')"

		echo
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN}              OUTRO HASH COMPARE TARGET                    ${NC}"
		echo -e "${CYAN}============================================================${NC}"
		echo -e "${CYAN} = = > File:${NC} ${GREEN}$file${NC}"
		echo -e "${CYAN} = = > Window:${NC} ${YELLOW}${outro_scan_start}s → ${outro_limit}s${NC}"
		echo

		for hash_mode in "${hash_modes[@]}"; do
			for anchors in "${anchor_sets[@]}"; do
				PHASH_STDERR_LOG="${PHASH_STDERR_LOG:-phash_stderr.log}"
				: > "$PHASH_STDERR_LOG"

				echo -e "${CYAN} = = > Testing:${NC} ${YELLOW}${hash_mode}${NC} ${CYAN}Anchors:${NC} ${YELLOW}${anchors}${NC}"

				t0="$(date +%s)"

				outro_output="$(
					python3 "$PHASH_ENGINE" \
						"$outro_scan_start" \
						"$outro_limit" \
						"${OUTRO_HASH_DIFF:-16}" \
						"$file" \
						"${OUTRO_STEP_SIZE:-1}" \
						"$anchors" \
						"${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}" \
						"$hash_mode" \
						2> >(tee "$PHASH_STDERR_LOG" | run_phash_engine_colored >&2)
				)"

				t1="$(date +%s)"
				elapsed="$((t1 - t0))"

				outro_result="$(printf '%s\n' "$outro_output" | awk '
					/^(MATCH\|.*|NO_MATCH)$/ { line=$0 }
					END { print line }
				')"

				result_status="NO_MATCH"
				start_val=""
				diff_val=""

				if [[ "$outro_result" == MATCH* ]]; then
					IFS='|' read -r _ start_val _template_end _template_used diff_val <<< "$outro_result"
					result_status="MATCH"
					echo -e "${GR} = = > MATCH:${NC} ${YELLOW}${hash_mode}${NC} ${CYAN}start=${NC}${YELLOW}${start_val}${NC} ${CYAN}diff=${NC}${YELLOW}${diff_val}${NC} ${CYAN}time=${NC}${YELLOW}${elapsed}s${NC}"
				else
					echo -e "${YE} = = > NO MATCH:${NC} ${YELLOW}${hash_mode}${NC} ${CYAN}time=${NC}${YELLOW}${elapsed}s${NC}"
				fi

				printf '%s,%s,%s,%s,%s,%s,%s\n' \
					"$file" "$hash_mode" "$anchors" "$result_status" "$start_val" "$diff_val" "$elapsed" >> "$log_file"
			done
		done
	done

	echo
	echo -e "${GR} = = > Outro Hash Compare Complete.${NC}"
	echo -e "${CYAN} = = > Log:${NC} ${YELLOW}$log_file${NC}"
	echo
	pause
	return 0
}


# end of  HELPERS maybe get em all in here if poss

# and all menus here if poss

# =========================
# #MARKER: INTRO DETECTION TOOLZ MENU
# =========================
# PURPOSE:
# - Group All Detection-Related Modes Into One Workflow Stage
# - Preserve Keypad Muscle Memory (Multi Key Perceptual Stays On 2)
# - Reuse Existing MODE-Based Detection/File-Processing Backend
#
# IMPORTANT:
# - CSV naming authority work does NOT belong here anymore.
# - episodes.csv building now lives under Rename / Detox / CSV Tools.
#
# NOTE:
# - Manual Duration Entry Is Intentionally Hidden For Now.
# - In Its Current Form It Behaves Like A Bulk All-Files Prompt Loop And Does
#   Not Earn A Place In The Polished Workflow Menu Yet.
# =========================
run_intro_detection_menu() {
    while true; do
        clear
        echo -e "${CYAN}=====================================================${NC}"
        echo -e "${CYAN}                INTRO DETECTION TOOLZ                ${NC}"
        echo -e "${CYAN}=====================================================${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     0) Create Introfind Template/Keys outro And intro "
		echo "     1) Analyze Intro Template / Build Fingerprint Report (Begin Cascading Introfind)"
        echo "     2) xHash Detection Use outro/intro_template.mkv To Find It (Multi Key Capable)"
        echo "     3) Hybrid detection Same As Above With Black Detect FallBack (xHash + Blackdetect)"
        echo "     7) Blackdetect Only"
        echo
        echo "     10-key exit > 0. (or q) Enter to quit"
        echo

		echo -ne "${YELLOW}     Choice: ${NC}${GREEN}"
		read -r det_choice
	    echo -e "${NC}"
		det_choice="${det_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_exit_token "$det_choice"; then
            return 0
        fi

        case "$det_choice" in
            0)
                create_template_smc
                ;;

			1)
				run_intro_template_fingerprint_report
				;;

            2)
                MODE="2"

                DEFAULT_SCAN_START="${INTRO_SCAN_START:-${DEFAULT_SCAN_START:-30}}"
                DEFAULT_MAX_SCAN="${INTRO_MAX_SCAN:-${DEFAULT_MAX_SCAN:-601}}"
                DEFAULT_HASH_DIFF="${INTRO_HASH_DIFF:-${DEFAULT_HASH_DIFF:-12}}"
                STEP_SIZE="${INTRO_STEP_SIZE:-1}"
                ANCHOR_SECONDS="${INTRO_ANCHOR_SECONDS:-3,5,7}"

				SCAN_START="${INTRO_SCAN_START:-30}"
				MAX_SCAN="${INTRO_MAX_SCAN:-601}"
				HASH_DIFF="${INTRO_HASH_DIFF:-16}"
				STEP_SIZE="${INTRO_STEP_SIZE:-1}"
				ANCHOR_SECONDS="${INTRO_ANCHOR_SECONDS:-3,5,7}"

				load_intro_template_fingerprint || :

				clear
				echo -e "${CYAN}============================================================${NC}"
				echo -e "${CYAN}              INTRO / OUTRO VAR REVIEW                      ${NC}"
				echo -e "${CYAN}============================================================${NC}"
				echo
				printf '%b%-28s%b %b%-28s%b\n' "$CYAN" "INTROFIND" "$NC" "$CYAN" "OUTROFIND" "$NC"
				printf '%-28s %-28s\n' "----------------------------" "----------------------------"
				printf '%b%-12s%b %b%-14s%b %b%-12s%b %b%-14s%b\n' "$CYAN" "Scan Start:" "$NC" "$YELLOW" "${SCAN_START}s" "$NC" "$CYAN" "Tail Mode:" "$NC" "$YELLOW" "${OUTRO_TAIL_SCAN_SECONDS:-auto}" "$NC"
				printf '%b%-12s%b %b%-14s%b %b%-12s%b %b%-14s%b\n' "$CYAN" "Max Depth:" "$NC" "$YELLOW" "${MAX_SCAN}s" "$NC" "$CYAN" "Tail Pad:" "$NC" "$YELLOW" "${OUTRO_TAIL_SCAN_PAD_SECONDS:-10}s" "$NC"
				printf '%b%-12s%b %b%-14s%b %b%-12s%b %b%-14s%b\n' "$CYAN" "Hash Diff:" "$NC" "$YELLOW" "$HASH_DIFF" "$NC" "$CYAN" "Hash Diff:" "$NC" "$YELLOW" "${OUTRO_HASH_DIFF:-16}" "$NC"
				printf '%b%-12s%b %b%-14s%b %b%-12s%b %b%-14s%b\n' "$CYAN" "Step Size:" "$NC" "$YELLOW" "${STEP_SIZE}s" "$NC" "$CYAN" "Step Size:" "$NC" "$YELLOW" "${OUTRO_STEP_SIZE:-1}s" "$NC"
				printf '%b%-12s%b %b%-14s%b %b%-12s%b %b%-14s%b\n' "$CYAN" "Anchors:" "$NC" "$YELLOW" "$ANCHOR_SECONDS" "$NC" "$CYAN" "Anchors:" "$NC" "$YELLOW" "${OUTRO_ANCHOR_SECONDS:-8,12,16}" "$NC"
				printf '%b%-12s%b %b%-14s%b %b%-12s%b %b%-14s%b\n' "$CYAN" "Hash Mode:" "$NC" "$YELLOW" "${INTRO_HASH_MODE:-phash}" "$NC" "$CYAN" "Hash Mode:" "$NC" "$YELLOW" "${OUTRO_HASH_MODE:-dhash}" "$NC"
				echo

				if (( ${INTRO_FINGERPRINT_LOADED:-0} == 1 )); then
					echo -e "${GR} = = > Structural Fingerprint Loaded${NC}"
					echo -e "${CYAN}       File:${NC} ${GREEN}$(factory_display_path "$INTRO_FINGERPRINT_FILE")${NC}"
					echo -e "${CYAN}       Version:${NC} ${YELLOW}$INTRO_FINGERPRINT_VERSION${NC}"
					echo -e "${CYAN}       Suggested Auto-A:${NC} ${YELLOW}$INTRO_FINGERPRINT_AUTO_A${NC}"
					echo -e "${CYAN}       Suggested Auto-B:${NC} ${YELLOW}$INTRO_FINGERPRINT_AUTO_B${NC}"
					echo -e "${YE}       Display Only — Current IntroFind Settings Remain Unchanged.${NC}"
				else
					echo -e "${YE} = = > Structural Fingerprint:${NC} ${YELLOW}Not Loaded / Not Available${NC}"
				fi
				echo
				echo -e "${YELLOW} = = > Change these from:${NC} ${CYAN}SmartCut Session VarZ > Intro/Outro Find Vars${NC}"
				echo
				prompt_menu_choice " = = > Press Enter To Begin IntroFind, Or 0.=Return: " confirm_introfind

				if is_exit_token "$confirm_introfind"; then
					echo -e "${YE} = = > IntroFind Cancelled.${NC}"
					pause
					continue
				fi

                echo
                return 10
                ;;

            3)
                MODE="4"

                echo -ne "${YELLOW} = = > Seconds To Skip Before Starting Scan? (Default ${DEFAULT_SCAN_START}): ${NC}${GREEN}"
                read -r SCAN_START
			    echo -e "${NC}"
                SCAN_START=${SCAN_START:-$DEFAULT_SCAN_START}

                echo -ne "${YELLOW} = = > Max Scan Depth From Start In Seconds? (Default ${DEFAULT_MAX_SCAN}): ${NC}${GREEN}"
                read -r MAX_SCAN
			    echo -e "${NC}"
                MAX_SCAN=${MAX_SCAN:-$DEFAULT_MAX_SCAN}

                echo -ne "${YELLOW} = = > Hash Diff Threshold Higher Number Easier Match? (Default ${DEFAULT_HASH_DIFF}): ${NC}${GREEN}"
                read -r HASH_DIFF
			    echo -e "${NC}"
                HASH_DIFF=${HASH_DIFF:-$DEFAULT_HASH_DIFF}

                echo -ne "${YELLOW} = = > Scan Step Size In Seconds? (Default 1): ${NC}${GREEN}"
                read -r STEP_SIZE
			    echo -e "${NC}"
                STEP_SIZE=${STEP_SIZE:-1}

                echo -ne "${YELLOW} = = > Anchor Seconds Comma List? (Default 3,5,7): ${NC}${GREEN}"
                read -r ANCHOR_SECONDS
			    echo -e "${NC}"
                ANCHOR_SECONDS="${ANCHOR_SECONDS:-3,5,7}"
                INTRO_ANCHOR_SECONDS="$ANCHOR_SECONDS"

                echo -ne "${YELLOW} = = > If You Chose Blackdetect Then Set Its Duration? (Default ${DEFAULT_BLACK_DURATION}): ${NC}${GREEN}"
                read -r BLACK_DUR
			    echo -e "${NC}"
                BLACK_DUR=${BLACK_DUR:-$DEFAULT_BLACK_DURATION}

                echo -ne "${YELLOW} = = > If You Chose Blackdetect Then Set Its Pixel Threshold? (Default ${DEFAULT_BLACK_PIXTH}): ${NC}${GREEN}"
                read -r BLACK_PIX
			    echo -e "${NC}"
                BLACK_PIX=${BLACK_PIX:-$DEFAULT_BLACK_PIXTH}

                echo
                #prompt_normalize_first_workflow
                return 10
                ;;

            7)
                MODE="7"

                echo -ne "${YELLOW} = = > If You Chose Blackdetect Then Set Its Duration? (Default ${DEFAULT_BLACK_DURATION}): ${NC}${GREEN}"
                read -r BLACK_DUR
			    echo -e "${NC}"
                BLACK_DUR=${BLACK_DUR:-$DEFAULT_BLACK_DURATION}

                echo -ne "${YELLOW} = = > If You Chose Blackdetect Then Set Its Pixel Threshold? (Default ${DEFAULT_BLACK_PIXTH}): ${NC}${GREEN}"
                read -r BLACK_PIX
			    echo -e "${NC}"
                BLACK_PIX=${BLACK_PIX:-$DEFAULT_BLACK_PIXTH}

                echo
                return 10
                ;;

            [Qq])
                return 0
                ;;

            *)
                echo -e "${REB} = = > Invalid.${NC}"
                pause
                ;;
        esac
    done
}

# =================================================
#       DETECTION MODES MENU CALLS
# =================================================
# LEGACY MENU DISPLAY REMOVED
# - Old detection menu text removed for cleanliness
# - MODE input still used for legacy routing
# =================================================
Old() {
# MODE is still consumed by legacy routing below.
read -r MODE
if [[ "$MODE" == "0" ]]; then
    #prompt_normalize_first_workflow
    create_template_smc
    return 0
fi
if [[ "$MODE" == "5" ]]; then
    run_build_episodes
    return 0
fi
if [[ "$MODE" == "6" ]]; then
    run_subtox
    return 0
fi
if [[ "$MODE" == "3" ]]; then
    #prompt_normalize_first_workflow
    run_smartgap
    return 0
fi
if [[ "$MODE" == "8" ]]; then
	run_batch_normalizer
	return 0
fi
case "$MODE" in
  1)
    return 0
    ;;
  2|4)
    run_intro_detection_menu
    return 0
    ;;
  7)
    # =========================
    # #MARKER: DETECTION PROMPTS (BLACKDETECT ONLY)
    # =========================
    echo -ne "${YELLOW} = = > If You Chose Blackdetect Then Set Its Duration? (Default ${DEFAULT_BLACK_DURATION}): ${NC}${GREEN}"
    read -r BLACK_DUR
    echo -e "${NC}"
    BLACK_DUR=${BLACK_DUR:-$DEFAULT_BLACK_DURATION}
    echo -ne "${YELLOW} = = > If You Chose Blackdetect Then Set Its Pixel Threshold? (Default ${DEFAULT_BLACK_PIXTH}): ${NC}${GREEN}"
    read -r BLACK_PIX
    echo -e "${NC}"
    BLACK_PIX=${BLACK_PIX:-$DEFAULT_BLACK_PIXTH}
    echo
    return 0
    ;;
  *)
 	echo -e "${REB} = = > Invalid mode: $MODE${NC}"
	pause
	return 1
	;;
esac
}
# =========================
# #MARKER: WRAPPER → MISSIONS ENTRYPOINT (ORDER MATTERS)
# =========================
run_main_menu
# =========================
# #MARKER: MISSION SHORT-CIRCUIT RETURN
# =========================
# Some Missions Are Complete Standalone Tools And Should NOT Fall Through Into
# The General IntroFind File-Processing Loop Below.
#
# Standalone Missions:
#   0 = Template Builder
#   3 = SMARTGAP
#   5 = BUILD_EPISODES_CSV
#   6 = SUBTOX
#   8 = Batch Normalize
#
# Detection Modes That Should Continue Into The File-Processing Loop:
#   1 = Manual Duration
#   2 = xHash
#   4 = Multi-Pass Hybrid
#   7 = Blackdetect
#
case "${MODE:-}" in
  0|3|5|6|8) exit 0 ;;
esac

# ============================================================
#  FILE PROCESSING
# ============================================================
# Build Eligible Working Targets For Legacy IntroFind Processing.
# Keep Discovery Tighter Than The Old Broad Grab So The Workflow Does Not
# Accidentally Sweep Up Every Generated/Helper File In The Directory.
#
# RULES:
# - Always Hide Template Assets
# - Always Hide BARFIX_ Outputs
# - Always Hide SMC_ Outputs
# - Always Hide OEM-Protected Archive Copies
# - Hide REKEY_ Outputs From The Visible Scan List
#   (REKEY Use Is Handled Later By get_preferred_source_file When Enabled)
#
shopt -s nullglob nocaseglob
all_files=(*.{lrv,mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,xvid,wmv})
shopt -u nullglob nocaseglob

files=()
for f in "${all_files[@]}"; do
    [[ "$f" == intro_template/* ]] && continue
    [[ "$f" =~ ^intro_template ]] && continue
    [[ "$f" =~ ^BARFIX_ ]] && continue
    [[ "$f" =~ ^(SMC_|PILOT_SMC_) ]] && continue
    [[ "$f" =~ ^REKEY_ ]] && continue
	[[ "$f" =~ ^SMC_ ]] && continue
    [[ "$f" =~ ^OEM_ ]] && continue
    files+=("$f")
done

total=${#files[@]}
count=0

# ============================================================
#  TEMPLATE DISCOVERY + PRECOMPUTE (MODE 2 / 4)
# ============================================================

if [[ "${MODE:-}" == "2" || "${MODE:-}" == "4" ]]; then

    shopt -s nullglob

    # ---- Discover Templates ----
    if [[ -d "intro_template" ]]; then
        TEMPLATES=(intro_template/intro_template*.mkv)
    else
        TEMPLATES=(intro_template*.mkv)
    fi

    (( ${#TEMPLATES[@]} > 0 )) || {
        echo -e "${RE} = = > No Intro Templates Found.${NC}"
        exit 1
    }

		echo -e "${CYAN} = = > Templates Detected:${NC}"
		for t in "${TEMPLATES[@]}"; do
		    echo -e "${GREEN} - $t${NC}"
		done
		echo

# ---- Precompute Template Fingerprints (currently informational; not used by xHash engine) ----
    declare -A TEMPLATE_HASHES
    declare -A TEMPLATE_DURS

    echo -e "${CYAN} = = > Precomputing Template Fingerprints...${NC}"

    for template in "${TEMPLATES[@]}"; do

    hash=$(ffmpeg -loglevel error -ss 5 -i "$template" \
        -frames:v 1 -f md5 - 2>/dev/null | awk '{print $NF}')

    dur=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$template" | awk '{printf "%d", $1}')

    TEMPLATE_HASHES["$template"]="$hash"
    TEMPLATE_DURS["$template"]="$dur"

    echo -e "${GREEN} = = > Cached → $template${NC}"
    done

    echo
fi

for raw in "${files[@]}"; do

    [[ -f "$raw" ]] || continue

# #MARKER: ALWAYS SKIP INTRO_TEMPLATE DIR
if [[ "$raw" == intro_template/* ]]; then
  echo -e "${YELLOW} = = > Skipping Template Asset: $raw${NC}"
  continue
fi

    is_template=0
if [[ "${MODE:-}" == "2" || "${MODE:-}" == "4" ]]; then
        for t in "${TEMPLATES[@]}"; do
            if [[ "$raw" == "$t" ]]; then
                is_template=1
                break
            fi
        done
    fi

    if [[ "$is_template" == 1 ]]; then
        echo -e "${YELLOW} = = > Skipping Template File: $raw${NC}"
        continue
    fi

    ((count+=1)) || :
    echo -e "${MAGENTA}-----------------------------------------${NC}"
    echo -e "${MAGENTA} = = > File $count / $total : $raw${NC}"


    resolve_status=0
    file=""

    file="$(resolve_working_source_for_detection "$raw")" || resolve_status=$?

    if [[ "$resolve_status" -eq 10 ]]; then
        continue
    elif [[ "$resolve_status" -ne 0 ]]; then
        echo -e "${REB} = = > Failed To Resolve Working Source For: $raw${NC}"
        continue
    fi

    # =========================
    # #MARKER: DURATION SAFE PARSE
    # =========================
    duration_raw=$(ffprobe -v error -show_entries format=duration \
      -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null || true)

    duration_int=$(printf "%.0f" "${duration_raw:-0}" 2>/dev/null || echo 0)

    if [[ "$duration_int" -le 0 ]]; then
      echo -e "${RE} = = > Could Not Read Duration For: $file${NC}"
      continue
    fi

    # Only detection scan modes need MAX_SCAN / scan limit.
    #
    # IMPORTANT:
    # - MAX_SCAN is a DEPTH FROM SCAN_START, not an absolute timeline stop.
    # - Example:
    #     SCAN_START=30
    #     MAX_SCAN=120
    #   means:
    #     scan candidate times from 30s up to 150s
    #   capped to the file duration.
    #
    # WHY:
    # - The menu prompt says "Max Scan Depth From Start In Seconds"
    # - So the engine limit handed to Python must reflect:
    #       SCAN_START + MAX_SCAN
    #   not just MAX_SCAN by itself.
    #
    if [[ "${MODE:-}" == "2" || "${MODE:-}" == "4" ]]; then
        requested_limit=$(( SCAN_START + MAX_SCAN ))
        limit=$(( duration_int < requested_limit ? duration_int : requested_limit ))
    fi

    case "${MODE:-}" in

    1)
        echo -e "${CYAN} = = > Enter Times:${NC}"
        echo -e "${YELLOW} = = > Start Time (seconds): ${NC}"
        read -r start
        echo -e "${YELLOW} = = > Duration (seconds): ${NC}"
        read -r dur
        end=$((start + dur))

        start_hms="$(seconds_to_hms "$start")"
        end_hms="$(seconds_to_hms "$end")"

        ensure_intro_map
        # 7-column CSV:
        # filename,start,end,start_hms,end_hms,template_used,diff
        #
        # Manual rows intentionally leave template_used and diff blank.
        echo "$raw,$start,$end,$start_hms,$end_hms,," >> "$INTRO_MAP"
        echo -e "${GREEN} = = > Written To CSV.${NC}"
        ;;

2|4)

# ================================================================
# #MARKER: INTRO EPISODE TEMPORAL VISUAL SCOUT
# ================================================================
# PURPOSE:
# - Scout episodes when the template has no useful scene skeleton.
# - Load the saved 3-second dHash temporal signature.
# - Choose a spread of high-information temporal witnesses.
# - Score candidate intro starts at a coarse 1-second step.
# - Rank likely starts for the existing local pHash verifier.
#
# IMPORTANT:
# - dHash scouts.
# - pHash still confirms.
# - Does not produce the final IntroFind match itself.
# ================================================================
run_intro_episode_temporal_report() {
	local target_file="$1"
	local scan_start="$2"
	local candidate_limit="$3"

	load_intro_template_fingerprint >/dev/null 2>&1 || {
		echo -e "${YE} = = > Temporal Episode Scout Skipped: No Fingerprint Loaded.${NC}" >&2
		return 1
	}

	python3 - \
		"$INTRO_FINGERPRINT_FILE" \
		"$target_file" \
		"$scan_start" \
		"$candidate_limit" <<'PY'
import re
import subprocess
import sys

import imagehash
from PIL import Image

fingerprint_path = sys.argv[1]
episode_path = sys.argv[2]
scan_start = float(sys.argv[3])
candidate_limit = float(sys.argv[4])

text = open(
    fingerprint_path,
    "r",
    errors="replace"
).read()

duration_match = re.search(
    r"^Duration:\s*([0-9.]+)",
    text,
    re.MULTILINE
)

if not duration_match:
    print("TEMPORAL_ERROR|template_duration_missing")
    raise SystemExit(1)

template_duration = float(duration_match.group(1))

# ------------------------------------------------------------
# LOAD TEMPLATE TEMPORAL SIGNATURE
# ------------------------------------------------------------
template_samples = []
in_temporal_section = False

for raw in text.splitlines():
    line = raw.strip()

    if line == "TEMPORAL VISUAL SIGNATURE":
        in_temporal_section = True
        continue

    if (
        in_temporal_section
        and line == "BLACK / NEAR-BLACK RANGES"
    ):
        break

    if not in_temporal_section:
        continue

    match = re.match(
        r"^time=([0-9.]+)\s+"
        r"dhash=([0-9a-fA-F]+)\s+"
        r"delta=([0-9]+)$",
        line
    )

    if not match:
        continue

    template_samples.append(
        (
            float(match.group(1)),
            imagehash.hex_to_hash(match.group(2)),
            int(match.group(3)),
        )
    )

if len(template_samples) < 5:
    print("TEMPORAL_ERROR|insufficient_template_samples")
    raise SystemExit(1)

# ------------------------------------------------------------
# SELECT FULL 7-WITNESS TEMPORAL FINGERPRINT
# ------------------------------------------------------------
eligible = template_samples[1:]

ordered = sorted(
    eligible,
    key=lambda item: (-item[2], item[0])
)

wanted = min(7, len(ordered))

min_gap = max(
    3.0,
    template_duration / max(wanted * 1.6, 1.0)
)

witnesses = []

for item in ordered:
    sample_time = item[0]

    if all(
        abs(sample_time - existing[0]) >= min_gap
        for existing in witnesses
    ):
        witnesses.append(item)

    if len(witnesses) >= wanted:
        break

if len(witnesses) < wanted:
    for item in ordered:
        if item not in witnesses:
            witnesses.append(item)

        if len(witnesses) >= wanted:
            break

witnesses.sort(
    key=lambda item: item[0]
)

# ------------------------------------------------------------
# SELECT MULTIPLE 3-WITNESS COARSE PATROL VIEWS
# ------------------------------------------------------------
# PURPOSE:
# - Avoid allowing one three-witness combination to blind the scout.
# - Every view reuses the same FFmpeg hash cache.
# - No additional media decode is required.
#
# VIEW A:
# - Three highest-information witnesses.
#
# VIEW B / C:
# - Different early / middle / late slices of the full fingerprint.
# ------------------------------------------------------------
coarse_view_a = sorted(
    sorted(
        witnesses,
        key=lambda item: (-item[2], item[0])
    )[:3],
    key=lambda item: item[0]
)

coarse_view_b = [
    witnesses[index]
    for index in (0, 2, 5)
    if index < len(witnesses)
]

coarse_view_c = [
    witnesses[index]
    for index in (1, 4, 6)
    if index < len(witnesses)
]

coarse_views = [
    ("A", coarse_view_a),
    ("B", coarse_view_b),
    ("C", coarse_view_c),
]

# ------------------------------------------------------------
# BUILD ONE FFMPEG TEMPORAL ANALYSIS STREAM
# ------------------------------------------------------------
# FFmpeg does the compressed-video decode.
#
# Analysis output:
# - 1 frame per second
# - grayscale
# - 9x8 pixels, exactly what dHash needs
#
# The stream covers the candidate depth plus the latest witness.
# All later coarse and fine scoring is memory-only.
# ------------------------------------------------------------
max_witness_offset = max(
    item[0]
    for item in witnesses
)

analysis_start = max(
    0,
    int(scan_start)
)

analysis_end = int(
    candidate_limit + max_witness_offset
) + 1

analysis_duration = max(
    1,
    analysis_end - analysis_start + 1
)

frame_width = 9
frame_height = 8
frame_bytes = frame_width * frame_height

ffmpeg_cmd = [
    "ffmpeg",
    "-hide_banner",
    "-loglevel",
    "error",
    "-nostdin",
    "-ss",
    str(analysis_start),
    "-i",
    episode_path,
    "-t",
    str(analysis_duration),
    "-an",
    "-sn",
    "-dn",
    "-vf",
    "fps=1,scale=9:8:flags=fast_bilinear,format=gray",
    "-f",
    "rawvideo",
    "-pix_fmt",
    "gray",
    "pipe:1",
]

try:
    process = subprocess.Popen(
        ffmpeg_cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
except OSError:
    print("TEMPORAL_ERROR|ffmpeg_start_failed")
    raise SystemExit(1)

episode_hash_cache = {}
frame_index = 0

while True:
    frame_data = process.stdout.read(frame_bytes)

    if not frame_data:
        break

    if len(frame_data) != frame_bytes:
        break

    sample_second = float(
        analysis_start + frame_index
    )

    image = Image.frombytes(
        "L",
        (frame_width, frame_height),
        frame_data,
    )

    episode_hash_cache[sample_second] = imagehash.dhash(
        image
    )

    frame_index += 1

stderr_data = process.stderr.read()
return_code = process.wait()

if return_code != 0:
    stderr_text = stderr_data.decode(
        "utf-8",
        errors="replace"
    ).strip()

    print(
        "TEMPORAL_ERROR"
        "|ffmpeg_analysis_failed"
        f"|return_code={return_code}"
    )

    if stderr_text:
        print(
            "TEMPORAL_FFMPEG_ERROR|"
            + stderr_text.replace(
                "\n",
                " "
            )[:500]
        )

    raise SystemExit(1)

print(
    "TEMPORAL_FFMPEG_CACHE"
    f"|start={analysis_start}"
    f"|end={analysis_end}"
    f"|fps=1.000"
    f"|size={frame_width}x{frame_height}"
    f"|hashes={len(episode_hash_cache)}"
)


def cached_hash_at(seconds):
    cache_second = float(
        int(round(seconds))
    )

    return episode_hash_cache.get(
        cache_second
    )


# ------------------------------------------------------------
# SHARED TEMPORAL SCORE
# ------------------------------------------------------------
# Keep the proven scoring model untouched:
#   80% visual identity
#   20% temporal rhythm
# ------------------------------------------------------------
def score_candidate(
    candidate_start,
    active_witnesses,
):
    episode_witnesses = []

    for (
        offset,
        template_hash,
        template_delta,
    ) in active_witnesses:
        episode_hash = cached_hash_at(
            candidate_start + offset
        )

        if episode_hash is None:
            return None

        episode_witnesses.append(
            (
                offset,
                template_hash,
                template_delta,
                episode_hash,
            )
        )

    identity_diffs = [
        template_hash - episode_hash
        for (
            offset,
            template_hash,
            template_delta,
            episode_hash,
        ) in episode_witnesses
    ]

    identity_score = (
        sum(identity_diffs)
        / len(identity_diffs)
    )

    rhythm_errors = []
    previous_episode_hash = None

    for (
        offset,
        template_hash,
        template_delta,
        episode_hash,
    ) in episode_witnesses:
        if previous_episode_hash is not None:
            episode_delta = (
                episode_hash - previous_episode_hash
            )

            rhythm_errors.append(
                abs(
                    template_delta
                    - episode_delta
                )
            )

        previous_episode_hash = episode_hash

    rhythm_score = (
        sum(rhythm_errors)
        / len(rhythm_errors)
        if rhythm_errors
        else 0.0
    )

    total_score = (
        identity_score * 0.80
        + rhythm_score * 0.20
    )

    return (
        total_score,
        candidate_start,
        identity_score,
        rhythm_score,
    )


# ------------------------------------------------------------
# TEMPORAL PASS A — MULTI-VIEW COARSE PATROL
# ------------------------------------------------------------
# - 2-second candidate grid.
# - Three independent 3-witness views.
# - Retain top 10 nominations from each view.
# - Merge duplicate candidate starts before fine refinement.
# ------------------------------------------------------------
coarse_view_results = {}
merged_coarse_nominations = {}

for view_name, view_witnesses in coarse_views:
    view_scored = []
    coarse_candidate = scan_start

    while coarse_candidate <= candidate_limit:
        result = score_candidate(
            coarse_candidate,
            view_witnesses,
        )

        if result is not None:
            view_scored.append(result)

        coarse_candidate += 2.0

    view_scored.sort(
        key=lambda item: item[0]
    )

    coarse_view_results[view_name] = view_scored

    print(
        "TEMPORAL_COARSE_VIEW"
        f"|view={view_name}"
        f"|step=2.000"
        f"|witnesses={len(view_witnesses)}"
        f"|candidates_scored={len(view_scored)}"
    )

    print(
        "TEMPORAL_COARSE_WITNESSES"
        f"|view={view_name}|"
        + ",".join(
            f"{item[0]:.3f}"
            for item in view_witnesses
        )
    )

    for rank, item in enumerate(
        view_scored[:10],
        start=1
    ):
        (
            total_score,
            candidate_start,
            identity_score,
            rhythm_score,
        ) = item

        print(
            "TEMPORAL_COARSE_CANDIDATE"
            f"|view={view_name}"
            f"|rank={rank}"
            f"|start={candidate_start:.3f}"
            f"|score={total_score:.3f}"
            f"|identity_score={identity_score:.3f}"
            f"|rhythm_score={rhythm_score:.3f}"
        )

        candidate_key = float(
            int(round(candidate_start))
        )

        existing = merged_coarse_nominations.get(
            candidate_key
        )

        if (
            existing is None
            or total_score < existing[0]
        ):
            merged_coarse_nominations[
                candidate_key
            ] = item

if not merged_coarse_nominations:
    print("TEMPORAL_ERROR|no_coarse_candidates")
    raise SystemExit(1)

merged_coarse_scored = sorted(
    merged_coarse_nominations.values(),
    key=lambda item: item[0]
)

print(
    "TEMPORAL_COARSE_MERGED"
    f"|views={len(coarse_views)}"
    f"|unique_nominations={len(merged_coarse_scored)}"
)

# ------------------------------------------------------------
# BUILD MERGED COARSE NEIGHBORHOODS
# ------------------------------------------------------------
# Each view contributes its top 10 nominations.
# Duplicate starts are removed before windows are built.
# Nearby windows are merged.
# ------------------------------------------------------------
raw_windows = []

for item in merged_coarse_scored:
    center = item[1]

    raw_windows.append(
        (
            max(scan_start, center - 4.0),
            min(candidate_limit, center + 4.0),
        )
    )

raw_windows.sort(
    key=lambda item: item[0]
)

fine_windows = []

for start, end in raw_windows:
    if (
        not fine_windows
        or start > fine_windows[-1][1] + 1.0
    ):
        fine_windows.append(
            [start, end]
        )
    else:
        fine_windows[-1][1] = max(
            fine_windows[-1][1],
            end
        )

# ------------------------------------------------------------
# TEMPORAL PASS B — FINE LOCAL REFINE
# ------------------------------------------------------------
# Full 7 witnesses.
# 1-second candidate grid.
# Uses the same FFmpeg-built in-memory dHash cache.
# ------------------------------------------------------------
fine_scored = []
seen_fine_candidates = set()

for window_start, window_end in fine_windows:
    candidate_start = float(
        int(round(window_start))
    )

    while candidate_start <= window_end:
        candidate_key = float(
            int(round(candidate_start))
        )

        if candidate_key not in seen_fine_candidates:
            seen_fine_candidates.add(candidate_key)

            result = score_candidate(
                candidate_key,
                witnesses,
            )

            if result is not None:
                fine_scored.append(result)

        candidate_start += 1.0

fine_scored.sort(
    key=lambda item: item[0]
)

print(
    "TEMPORAL_FINE"
    f"|windows={len(fine_windows)}"
    f"|witnesses={len(witnesses)}"
    f"|candidates_scored={len(fine_scored)}"
    f"|cache_hashes={len(episode_hash_cache)}"
)

print(
    "TEMPORAL_FINE_WINDOWS|"
    + ",".join(
        f"{start:.3f}-{end:.3f}"
        for start, end in fine_windows
    )
)

print(
    "TEMPORAL_WITNESSES|"
    + ",".join(
        f"{item[0]:.3f}"
        for item in witnesses
    )
)

# ------------------------------------------------------------
# FINAL TEMPORAL REPORT
# ------------------------------------------------------------
# Keep TEMPORAL_SCAN and TEMPORAL_CANDIDATE output names.
# Existing Bash handoff parses TEMPORAL_CANDIDATE.
# ------------------------------------------------------------
print(
    "TEMPORAL_SCAN"
    f"|template_duration={template_duration:.3f}"
    f"|witnesses={len(witnesses)}"
    f"|candidates_scored={len(fine_scored)}"
)

for rank, item in enumerate(
    fine_scored[:10],
    start=1
):
    (
        total_score,
        candidate_start,
        identity_score,
        rhythm_score,
    ) = item

    print(
        "TEMPORAL_CANDIDATE"
        f"|rank={rank}"
        f"|start={candidate_start:.3f}"
        f"|score={total_score:.3f}"
        f"|identity_score={identity_score:.3f}"
        f"|rhythm_score={rhythm_score:.3f}"
    )
PY
}

# ================================================================
# #MARKER: INTRO EPISODE STRUCTURAL MATCH REPORT
# ================================================================
# PURPOSE:
# - Analyze an episode with the same structural tools used on the
#   intro template.
# - Compare episode scene / black timing against the saved template
#   fingerprint.
# - Report likely intro-start candidates.
#
# IMPORTANT:
# - REPORT ONLY.
# - Does not change IntroFind search range or hash behavior.
# - Current dHash / pHash cascade remains untouched.
# ================================================================
run_intro_episode_structural_report() {
	local target_file="$1"
	local scan_start="$2"
	local scan_limit="$3"
	local tmpdir=""
	local scene_csv=""
	local black_log=""
	local structure_output=""

	load_intro_template_fingerprint >/dev/null 2>&1 || {
		echo -e "${YE} = = > Structural Episode Scout Skipped: No Fingerprint Loaded.${NC}" >&2
		return 1
	}

	tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/factory_episode_structure.XXXXXX")"
	scene_csv="$tmpdir/episode_scenes.csv"
	black_log="$tmpdir/episode_blackdetect.log"

	echo -e "${CYAN} = = > Structural Scout:${NC} ${YELLOW}Mapping Episode Scene / Black Pattern...${NC}" >&2

	# ------------------------------------------------------------
	# BLACK / NEAR-BLACK MAP
	# ------------------------------------------------------------
	ffmpeg \
		-hide_banner \
		-loglevel info \
		-nostdin \
		-ss "$scan_start" \
		-to "$scan_limit" \
		-i "$target_file" \
		-vf "blackdetect=d=0.20:pix_th=0.10" \
		-an \
		-f null - \
		2>&1 |
		sed -nE '
			s/.*black_start:([0-9.]+)[[:space:]]+black_end:([0-9.]+)[[:space:]]+black_duration:([0-9.]+).*/\1,\2,\3/p
		' > "$black_log"

	# ------------------------------------------------------------
	# EPISODE SCENE MAP
	# ------------------------------------------------------------
	if command -v scenedetect >/dev/null 2>&1; then
		scenedetect \
			-q \
			-i "$target_file" \
			-o "$tmpdir" \
			time \
				--start "${scan_start}s" \
				--end "${scan_limit}s" \
			detect-adaptive \
			list-scenes \
				--skip-cuts \
				--filename "episode_scenes.csv" \
			>/dev/null 2>&1 || :
	fi

	if [[ ! -s "$scene_csv" ]]; then
		echo -e "${YE} = = > Structural Scout Could Not Build Episode Scene Map.${NC}" >&2
		rm -rf -- "$tmpdir"
		return 1
	fi

	structure_output="$(
		python3 - \
			"$INTRO_FINGERPRINT_FILE" \
			"$scene_csv" \
			"$black_log" \
			"$scan_start" \
			"$scan_limit" <<'PY'
import csv
import re
import sys
from pathlib import Path

fingerprint_path = Path(sys.argv[1])
scene_csv = Path(sys.argv[2])
black_log = Path(sys.argv[3])
scan_start = float(sys.argv[4])
scan_limit = float(sys.argv[5])

# ------------------------------------------------------------
# LOAD TEMPLATE STRUCTURE
# ------------------------------------------------------------
text = fingerprint_path.read_text(errors="replace")

duration_match = re.search(
    r"^Duration:\s*([0-9.]+)",
    text,
    re.MULTILINE
)

if not duration_match:
    print("STRUCTURAL_ERROR|template_duration_missing")
    raise SystemExit(1)

template_duration = float(duration_match.group(1))

template_scenes = []
in_scene_section = False

for raw in text.splitlines():
    line = raw.strip()

    if line == "SCENE STRUCTURE":
        in_scene_section = True
        continue

    if in_scene_section and line.startswith("SUGGESTED REPORT-ONLY ANCHORS"):
        break

    if not in_scene_section:
        continue

    match = re.match(
        r"^\d+:\s*([0-9.]+)\s*->\s*([0-9.]+)",
        line
    )

    if match:
        start = float(match.group(1))
        end = float(match.group(2))
        template_scenes.append((start, end))

template_black = []
in_black_section = False

for raw in text.splitlines():
    line = raw.strip()

    if line == "BLACK / NEAR-BLACK RANGES":
        in_black_section = True
        continue

    if in_black_section and line == "SCENE STRUCTURE":
        break

    if not in_black_section:
        continue

    match = re.match(
        r"^([0-9.]+)\s*->\s*([0-9.]+)",
        line
    )

    if match:
        template_black.append(
            (float(match.group(1)), float(match.group(2)))
        )

# ------------------------------------------------------------
# LOAD EPISODE SCENES
# ------------------------------------------------------------
episode_scenes = []

with scene_csv.open(
    newline="",
    errors="replace"
) as handle:
    reader = csv.DictReader(handle)

    for row in reader:
        try:
            start = float(row.get("Start Time (seconds)", ""))
            end = float(row.get("End Time (seconds)", ""))
        except (TypeError, ValueError):
            continue

        if end <= scan_start:
            continue

        if start >= scan_limit:
            continue

        episode_scenes.append((start, end))

episode_black = []

if black_log.exists():
    for raw in black_log.read_text(errors="replace").splitlines():
        parts = raw.strip().split(",")

        if len(parts) != 3:
            continue

        try:
            start = float(parts[0]) + scan_start
            end = float(parts[1]) + scan_start
        except ValueError:
            continue

        episode_black.append((start, end))

if len(template_scenes) < 2 or len(episode_scenes) < 2:
    print("STRUCTURAL_ERROR|insufficient_scene_data")
    raise SystemExit(1)

# Template internal scene-boundary offsets.
template_boundaries = [
    scene[0]
    for scene in template_scenes[1:]
    if 0.0 < scene[0] < template_duration
]

episode_boundaries = [
    scene[0]
    for scene in episode_scenes
    if scan_start <= scene[0] <= scan_limit
]

# ------------------------------------------------------------
# CANDIDATE GENERATION
#
# Align every episode scene boundary against every template
# scene boundary. Each alignment suggests a possible intro start.
# ------------------------------------------------------------
raw_candidates = []

for episode_boundary in episode_boundaries:
    for template_boundary in template_boundaries:
        candidate_start = episode_boundary - template_boundary

        if candidate_start < scan_start:
            continue

        if candidate_start + template_duration > scan_limit:
            continue

        raw_candidates.append(candidate_start)

# De-duplicate nearby candidate starts.
raw_candidates.sort()

candidates = []

for value in raw_candidates:
    if not candidates or abs(value - candidates[-1]) >= 0.75:
        candidates.append(value)

# ------------------------------------------------------------
# STRUCTURAL SCORING
#
# Lower score is better.
# Compare:
# - expected scene-boundary offsets
# - black-range positions
# ------------------------------------------------------------
def nearest_distance(value, values):
    if not values:
        return 999.0

    return min(abs(value - item) for item in values)

scored = []

for candidate_start in candidates:
    expected_scene_times = [
        candidate_start + offset
        for offset in template_boundaries
    ]

    scene_errors = [
        nearest_distance(expected, episode_boundaries)
        for expected in expected_scene_times
    ]

    scene_score = (
        sum(scene_errors) / len(scene_errors)
        if scene_errors
        else 999.0
    )

    black_errors = []

    for black_start, black_end in template_black:
        expected_start = candidate_start + black_start
        expected_end = candidate_start + black_end

        if episode_black:
            best = min(
                (
                    abs(expected_start - ep_start)
                    + abs(expected_end - ep_end)
                ) / 2.0
                for ep_start, ep_end in episode_black
            )

            black_errors.append(best)

    black_score = (
        sum(black_errors) / len(black_errors)
        if black_errors
        else 0.0
    )

    # Scene structure carries most of the first-pass weight.
    total_score = (
        scene_score * 0.75
        + black_score * 0.25
    )

    scored.append(
        (
            total_score,
            scene_score,
            black_score,
            candidate_start
        )
    )

scored.sort(key=lambda item: item[0])

print(
    "STRUCTURAL_SCAN"
    f"|template_duration={template_duration:.3f}"
    f"|episode_scenes={len(episode_scenes)}"
    f"|episode_black_ranges={len(episode_black)}"
    f"|candidates_scored={len(scored)}"
)

for index, (
    total_score,
    scene_score,
    black_score,
    candidate_start
) in enumerate(scored[:10], start=1):
    print(
        "STRUCTURAL_CANDIDATE"
        f"|rank={index}"
        f"|start={candidate_start:.3f}"
        f"|score={total_score:.3f}"
        f"|scene_score={scene_score:.3f}"
        f"|black_score={black_score:.3f}"
    )
PY
	)"

	rm -rf -- "$tmpdir"

	if [[ -z "$structure_output" ]]; then
		return 1
	fi

	printf '%s\n' "$structure_output"
}

# ================================================================
# #MARKER: INTRO HASH ENGINE RUNNER
# ================================================================
# PURPOSE:
# - Provide one reusable Bash entry point to the local xHash engine.
# - Used by normal IntroFind now.
# - Future cascade scout / refine passes can reuse the same engine.
# ================================================================
run_intro_hash_engine() {
	local scan_start="$1"
	local scan_limit="$2"
	local hash_diff="$3"
	local target_file="$4"
	local step_size="$5"
	local anchors="$6"
	local template_glob="$7"
	local hash_mode="$8"
	local candidate_end="${9:-$scan_limit}"

	python3 "$PHASH_ENGINE" \
		"$scan_start" \
		"$scan_limit" \
		"$hash_diff" \
		"$target_file" \
		"$step_size" \
		"$anchors" \
		"$template_glob" \
		"$hash_mode" \
		"$candidate_end" \
		2> >(tee "$PHASH_STDERR_LOG" | run_phash_engine_colored >&2)
}

# =========================
# #MARKER: PHASH DEP CHECK
# =========================
if ! python3 - <<'PY' >/dev/null 2>&1
import cv2
from PIL import Image
import imagehash
PY
then
  echo -e "${REB} = = > xHash Engine Missing Python Modules.${NC}"
  echo -e "${YE} = = > Install:${NC} python3 -m pip install --user pillow python-imagehash opencv-python"
  pause
  continue
fi

  echo -e "${CYAN} = = > Running Scene Detect/xHash Cascading IntroFind...${NC}"

resolved_intro_anchors="$(
	auto_anchor_csv_from_duration \
		"${INTRO_TEMPLATE_DIR}/intro*.mkv" \
		"intro" \
		"${INTRO_ANCHOR_SECONDS:-3,5,7}"
)"

    # --- Generate temporary Python engine ---
# =========================
# PHASH ENGINE v2.0
# BEST-MATCH / MULTI-ANCHOR / SUB-SECOND SCAN
# =========================

	ensure_phash_engine || {
		echo -e "${REB} = = > Could Not Build Hash Engine.${NC}"
		pause
		continue
	}

    # =========================
    # #MARKER: PHASH RESULT PARSE HARDENING
    # =========================
    # PURPOSE:
    # - Keep Python stderr diagnostics visible to the human
    #   WITHOUT letting them corrupt the Bash stdout contract.
    # - Preserve the engine's promised stdout surface:
    #       MATCH|start|end|template|diff
    #       NO_MATCH
    #
    # WHY THIS BLOCK CHANGED:
    # - v2.0 engine now prints useful debug to stderr:
    #       TEMPLATE_ORDER|...
    #       ENGINE_CFG|...
    #       SCAN_DONE|...
    #       BEST_MATCH|...
    # - If we do 2>&1 into one capture variable, Bash can no longer safely
    #   assume the captured text is a single clean MATCH/NO_MATCH line.
    #
    # DESIGN:
    # - stdout is captured into phash_output
    # - stderr is mirrored to screen AND saved to a sidecar log
    # - then we extract only the final authoritative MATCH|... or NO_MATCH line
    #
	PHASH_STDERR_LOG="${PHASH_STDERR_LOG:-${FACTORY_HOME}/.phash_engine.stderr.log}"

	intro_find_t0="$(date +%s)"

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN}          STRUCTURAL INTRO SCENE DETECT SCOUT               ${NC}"
	echo -e "${CYAN}============================================================${NC}"

	# ========================================================
	# #MARKER: DURATION-AWARE STRUCTURAL INTRO SCOUT DEPTH
	# ========================================================
	# DEFAULT RULE:
	# - Search at least the first 12 minutes for an intro start.
	# - Otherwise search the first 25% of the episode.
	# - Cap automatic scout depth at 25 minutes.
	#
	# IMPORTANT:
	# - scout_candidate_limit = latest intro START we want to consider.
	# - scout_analysis_limit = additional template runway so a late intro
	#   can still be structurally analyzed in full.
	# ========================================================

	scout_candidate_limit="$(
		awk \
			-v duration="$duration_raw" \
			'BEGIN {
				v = duration * 0.25

				if (v < 720)
					v = 720

				if (v > 1500)
					v = 1500

				if (v > duration)
					v = duration

				printf "%.3f", v
			}'
	)"

	intro_template_runtime="$(
		get_file_duration_seconds \
			"${INTRO_TEMPLATE_DIR}/intro_template.mkv" \
			2>/dev/null || true
	)"

	if [[ -z "$intro_template_runtime" ||
	      ! "$intro_template_runtime" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
		intro_template_runtime="120"
	fi

	scout_analysis_limit="$(
		awk \
			-v candidate_limit="$scout_candidate_limit" \
			-v template_duration="$intro_template_runtime" \
			-v file_duration="$duration_raw" \
			'BEGIN {
				v = candidate_limit + template_duration

				if (v > file_duration)
					v = file_duration

				printf "%.3f", v
			}'
	)"

	echo
	echo -e "${CYAN} = = > Structural Scout Depth:${NC}"
	echo -e "${CYAN}       Episode Duration:${NC} ${YELLOW}${duration_raw}s${NC}"
	echo -e "${CYAN}       Candidate Start Depth:${NC} ${YELLOW}${scout_candidate_limit}s${NC}"
	echo -e "${CYAN}       Analysis Runway:${NC} ${YELLOW}${scout_analysis_limit}s${NC}"

	load_intro_template_fingerprint >/dev/null 2>&1 || :

	scout_output=""
	scout_label="Structural"
	scout_candidate_prefix="STRUCTURAL_CANDIDATE"

	case "${INTRO_FINGERPRINT_SCOUT_MODE:-structural}" in
		temporal)
			scout_label="Temporal"
			scout_candidate_prefix="TEMPORAL_CANDIDATE"

			echo -e "${CYAN} = = > Fingerprint Scout Mode:${NC} ${YELLOW}TEMPORAL VISUAL${NC}"

			scout_output="$(
				run_intro_episode_temporal_report \
					"$file" \
					"$SCAN_START" \
					"$scout_candidate_limit" \
					2>&1
			)" || scout_output=""
			;;

		structural|*)
			scout_label="Structural"
			scout_candidate_prefix="STRUCTURAL_CANDIDATE"

			echo -e "${CYAN} = = > Fingerprint Scout Mode:${NC} ${YELLOW}STRUCTURAL${NC}"

			scout_output="$(
				run_intro_episode_structural_report \
					"$file" \
					"$SCAN_START" \
					"$scout_analysis_limit" \
					2>&1
			)" || scout_output=""
			;;
	esac

	if [[ -n "$scout_output" ]]; then
		printf '%s\n' "$scout_output"
	else
		echo -e "${YE} = = > ${scout_label} Scout Produced No Report.${NC}"
	fi

	echo

	# ========================================================
	# #MARKER: CASCADING INTROFIND - SCOUT / VERIFY / RESCUE
	# ========================================================
	# PASS 1:
	# - Fingerprint selects Structural or Temporal Visual scout.
	# - Selected scout produces ranked likely intro starts.
	#
	# PASS 2:
	# - Existing local pHash verifies top ranked candidates.
	#
	# PASS 3:
	# - If real scout candidates exist but none confirm,
	#   run bounded cluster rescue.
	# ========================================================

	intro_refine_radius="${INTRO_REFINE_RADIUS_SECONDS:-9}"
	intro_structural_candidate_limit="${INTRO_STRUCTURAL_CANDIDATE_LIMIT:-3}"

	intro_template_duration="$(
		printf '%s\n' "$scout_output" |
			awk -F'|' '
				/^(STRUCTURAL_SCAN|TEMPORAL_SCAN)\|/ {
					for (i=1; i<=NF; i++) {
						if ($i ~ /^template_duration=/) {
							value=$i
							sub(/^template_duration=/, "", value)
							print value
							exit
						}
					}
				}
			'
	)"

	if [[ -z "$intro_template_duration" ]]; then
		intro_template_duration="0"
	fi

	phash_output=""
	phash_status=0
	structural_match_found=0

	mapfile -t structural_candidates < <(
		printf '%s\n' "$scout_output" |
			awk \
				-F'|' \
				-v candidate_prefix="$scout_candidate_prefix" '
				$1 == candidate_prefix {
					rank=""
					start=""

					for (i=1; i<=NF; i++) {
						if ($i ~ /^rank=/) {
							rank=$i
							sub(/^rank=/, "", rank)
						}

						if ($i ~ /^start=/) {
							start=$i
							sub(/^start=/, "", start)
						}
					}

					if (rank != "" && start != "") {
						print rank "|" start
					}
				}
			' |
			head -n "$intro_structural_candidate_limit"
	)

	if (( ${#structural_candidates[@]} > 0 )); then
		echo
		echo -e "${CYAN} = = > Cascade Pass 1:${NC} ${YELLOW}${scout_label} Candidate Scout${NC}"
		echo -e "${CYAN}       Candidates:${NC} ${YELLOW}${#structural_candidates[@]}${NC}"

		for structural_candidate in "${structural_candidates[@]}"; do
			IFS='|' read -r structural_rank structural_start <<< "$structural_candidate"

			refine_start="$(
				awk \
					-v candidate="$structural_start" \
					-v radius="$intro_refine_radius" \
					-v floor="$SCAN_START" \
					'BEGIN {
						v = candidate - radius
						if (v < floor) v = floor
						printf "%.3f", v
					}'
			)"

			refine_candidate_end="$(
				awk \
					-v candidate="$structural_start" \
					-v radius="$intro_refine_radius" \
					-v ceiling="$duration_raw" \
					'BEGIN {
						v = candidate + radius
						if (v > ceiling) v = ceiling
						printf "%.3f", v
					}'
			)"

			refine_limit="$(
				awk \
					-v candidate_end="$refine_candidate_end" \
					-v template_duration="$intro_template_duration" \
					-v ceiling="$duration_raw" \
					'BEGIN {
						v = candidate_end + template_duration
						if (v > ceiling) v = ceiling
						printf "%.3f", v
					}'
			)"

			echo
			echo -e "${CYAN} = = > Cascade Pass 2:${NC} ${YELLOW}Local pHash Verification${NC}"
			echo -e "${CYAN}       ${scout_label} Rank:${NC} ${YELLOW}#$structural_rank${NC}"
			echo -e "${CYAN}       Candidate Start:${NC} ${YELLOW}${structural_start}s${NC}"
			echo -e "${CYAN}       Candidate Window:${NC} ${YELLOW}${refine_start}s -> ${refine_candidate_end}s${NC}"
			echo -e "${CYAN}       Engine Ceiling:${NC} ${YELLOW}${refine_limit}s${NC}"
			echo -e "${CYAN}       Step:${NC} ${YELLOW}${INTRO_STEP_SIZE:-1}s${NC}"

			phash_output="$(
				run_intro_hash_engine \
					"$refine_start" \
					"$refine_limit" \
					"$HASH_DIFF" \
					"$file" \
					"${INTRO_STEP_SIZE:-1}" \
					"$resolved_intro_anchors" \
					"intro_template/intro_template*.mkv" \
					"${INTRO_HASH_MODE:-phash}" \
					"$refine_candidate_end"
			)"
			phash_status=$?

			refine_result="$(printf '%s\n' "$phash_output" | awk '
				/^(MATCH\|.*|NO_MATCH)$/ { line=$0 }
				END { print line }
			')"

			if [[ $phash_status -eq 0 && "$refine_result" == MATCH* ]]; then
				echo -e "${GR} = = > ${scout_label} Candidate Confirmed By Local pHash.${NC}"
				structural_match_found=1
				break
			fi

			echo -e "${YEB} = = >${NC}${YE} ${scout_label} Candidate #${structural_rank} Was Not Confirmed.${NC}"
		done
	fi

	if (( structural_match_found == 0 && ${#structural_candidates[@]} > 0 )); then
		echo
		echo -e "${YE} = = > Primary ${scout_label} Candidates Did Not Produce A Confirmed Match.${NC}"
		echo -e "${CYAN} = = > Cascade Pass 3:${NC} ${YELLOW}Bounded ${scout_label} Island Rescue${NC}"

		# --------------------------------------------------------
		# BUILD SEPARATE CANDIDATE ISLANDS
		# --------------------------------------------------------
		# Each final scout candidate receives ±15 seconds.
		# Overlapping windows merge.
		# Distant candidates remain separate and are never bridged
		# into one giant pHash scan.
		# --------------------------------------------------------
		mapfile -t rescue_islands < <(
			printf '%s\n' "${structural_candidates[@]}" |
				awk \
					-F'|' \
					-v floor="$SCAN_START" \
					-v ceiling="$duration_raw" '
					{
						center = $2 + 0
						start = center - 15
						end = center + 15

						if (start < floor)
							start = floor

						if (end > ceiling)
							end = ceiling

						printf "%.3f|%.3f\n", start, end
					}
				' |
				sort -t'|' -k1,1n |
				awk -F'|' '
					NR == 1 {
						start = $1
						end = $2
						next
					}

					{
						if ($1 <= end + 1) {
							if ($2 > end)
								end = $2
						} else {
							printf "%.3f|%.3f\n", start, end
							start = $1
							end = $2
						}
					}

					END {
						if (NR > 0)
							printf "%.3f|%.3f\n", start, end
					}
				'
		)

		phash_output="NO_MATCH"
		phash_status=0
		cluster_result="NO_MATCH"
		rescue_island_number=0

		for rescue_island in "${rescue_islands[@]}"; do
			IFS='|' read -r cluster_start cluster_end <<< "$rescue_island"
			((rescue_island_number+=1)) || :

			echo
			echo -e "${CYAN} = = > Rescue Island #${rescue_island_number}:${NC}"
			echo -e "${CYAN}       Window:${NC} ${YELLOW}${cluster_start}s -> ${cluster_end}s${NC}"
			echo -e "${CYAN}       Rescue Step:${NC} ${YELLOW}0.5s${NC}"
			echo -e "${CYAN}       Anchors:${NC} ${YELLOW}${resolved_intro_anchors}${NC}"

			cluster_engine_limit="$(
				awk \
					-v candidate_end="$cluster_end" \
					-v template_duration="$intro_template_duration" \
					-v file_duration="$duration_raw" \
					'BEGIN {
						v = candidate_end + template_duration

						if (v > file_duration)
							v = file_duration

						printf "%.3f", v
					}'
			)"

			phash_output="$(
				run_intro_hash_engine \
					"$cluster_start" \
					"$cluster_engine_limit" \
					"$HASH_DIFF" \
					"$file" \
					"0.5" \
					"$resolved_intro_anchors" \
					"intro_template/intro_template*.mkv" \
					"${INTRO_HASH_MODE:-phash}" \
					"$cluster_end"
			)"
			phash_status=$?

			cluster_result="$(printf '%s\n' "$phash_output" | awk '
				/^(MATCH\|.*|NO_MATCH)$/ { line=$0 }
				END { print line }
			')"

			if [[ $phash_status -eq 0 && "$cluster_result" == MATCH* ]]; then
				echo -e "${GR} = = > ${scout_label} Rescue Island Confirmed By Fine pHash.${NC}"
				structural_match_found=1
				break
			fi

			echo -e "${YE} = = > Rescue Island #${rescue_island_number} Did Not Confirm A Match.${NC}"
		done

		if (( structural_match_found == 0 )); then
			echo
			echo -e "${YE} = = > All Bounded ${scout_label} Rescue Islands Failed.${NC}"
			echo -e "${YE} = = > Full-Range pHash Suppressed To Avoid A Long Scan During Testing.${NC}"
			phash_output="NO_MATCH"
			phash_status=0
		fi
	fi

	if (( structural_match_found == 0 && ${#structural_candidates[@]} == 0 )); then
		echo
		echo -e "${YE} = = > ${scout_label} Scout Produced No Rescue Candidates.${NC}"
		echo -e "${YE} = = > Bounded Cluster Rescue Skipped.${NC}"
		echo -e "${YE} = = > Full-Range pHash Suppressed To Avoid A Long Brute-Force Scan.${NC}"

		phash_output="NO_MATCH"
		phash_status=0
	fi

	# ========================================================
	# #MARKER: SECONDARY TEMPORAL SCOUT AFTER STRUCTURAL FAILURE
	# ========================================================
	# PURPOSE:
	# - A structurally usable fingerprint normally tries Structural first.
	# - If Structural candidates and bounded island rescue all fail,
	#   give the already-built Temporal fingerprint a full chance.
	# - Keep pHash as the final confirmation authority.
	#
	# IMPORTANT:
	# - Temporal-primary fingerprints do not run this block again.
	# - No full-range pHash fallback is introduced.
	# - Existing Structural behavior remains unchanged when it succeeds.
	# ========================================================
	if (( structural_match_found == 0 )) &&
	   [[ "${INTRO_FINGERPRINT_SCOUT_MODE:-structural}" == "structural" ]]; then

		echo
		echo -e "${YE} = = > Structural Cascade Did Not Confirm A Match.${NC}"
		echo -e "${CYAN} = = > Cascade Pass 4:${NC} ${YELLOW}Secondary Temporal Visual Scout${NC}"

		# --------------------------------------------------------
		# SECONDARY TEMPORAL PHASH TOLERANCE
		# --------------------------------------------------------
		# PURPOSE:
		# - Keep the normal IntroFind threshold unchanged.
		# - Allow a small confirmation margin only after the
		#   structural cascade has failed and Temporal takes over.
		#
		# NOTE:
		# - The engine accepts avg_diff strictly BELOW HASH_DIFF.
		# - Therefore an observed avg_diff of 18.000 requires 19.
		# --------------------------------------------------------
		secondary_temporal_hash_diff="$(
			awk \
				-v base="$HASH_DIFF" \
				'BEGIN {
					v = base + 3

					if (v > 19)
						v = 19

					printf "%d", v
				}'
		)"

		echo -e "${CYAN} = = > Secondary Temporal pHash Diff:${NC} ${YELLOW}${secondary_temporal_hash_diff}${NC} ${CYAN}(Primary Remains ${HASH_DIFF})${NC}"

		secondary_scout_output="$(
			run_intro_episode_temporal_report \
				"$file" \
				"$SCAN_START" \
				"$scout_candidate_limit" \
				2>&1
		)" || secondary_scout_output=""

		if [[ -n "$secondary_scout_output" ]]; then
			printf '%s\n' "$secondary_scout_output"
		else
			echo -e "${YE} = = > Secondary Temporal Scout Produced No Report.${NC}"
		fi

		secondary_template_duration="$(
			printf '%s\n' "$secondary_scout_output" |
				awk -F'|' '
					/^TEMPORAL_SCAN\|/ {
						for (i=1; i<=NF; i++) {
							if ($i ~ /^template_duration=/) {
								value=$i
								sub(/^template_duration=/, "", value)
								print value
								exit
							}
						}
					}
				'
		)"

		if [[ -z "$secondary_template_duration" ]]; then
			secondary_template_duration="$intro_template_duration"
		fi

		mapfile -t secondary_temporal_candidates < <(
			printf '%s\n' "$secondary_scout_output" |
				awk -F'|' '
					/^TEMPORAL_CANDIDATE\|/ {
						rank=""
						start=""

						for (i=1; i<=NF; i++) {
							if ($i ~ /^rank=/) {
								rank=$i
								sub(/^rank=/, "", rank)
							}

							if ($i ~ /^start=/) {
								start=$i
								sub(/^start=/, "", start)
							}
						}

						if (rank != "" && start != "") {
							print rank "|" start
						}
					}
				' |
				head -n "$intro_structural_candidate_limit"
		)

		if (( ${#secondary_temporal_candidates[@]} > 0 )); then
			echo
			echo -e "${CYAN} = = > Secondary Temporal Candidates:${NC} ${YELLOW}${#secondary_temporal_candidates[@]}${NC}"

			for secondary_candidate in "${secondary_temporal_candidates[@]}"; do
				IFS='|' read -r secondary_rank secondary_start <<< "$secondary_candidate"

				secondary_refine_start="$(
					awk \
						-v candidate="$secondary_start" \
						-v radius="$intro_refine_radius" \
						-v floor="$SCAN_START" \
						'BEGIN {
							v = candidate - radius

							if (v < floor)
								v = floor

							printf "%.3f", v
						}'
				)"

				secondary_refine_end="$(
					awk \
						-v candidate="$secondary_start" \
						-v radius="$intro_refine_radius" \
						-v ceiling="$duration_raw" \
						'BEGIN {
							v = candidate + radius

							if (v > ceiling)
								v = ceiling

							printf "%.3f", v
						}'
				)"

				secondary_engine_limit="$(
					awk \
						-v candidate_end="$secondary_refine_end" \
						-v template_duration="$secondary_template_duration" \
						-v ceiling="$duration_raw" \
						'BEGIN {
							v = candidate_end + template_duration

							if (v > ceiling)
								v = ceiling

							printf "%.3f", v
						}'
				)"

				echo
				echo -e "${CYAN} = = > Cascade Pass 5:${NC} ${YELLOW}Secondary Temporal pHash Verification${NC}"
				echo -e "${CYAN}       Temporal Rank:${NC} ${YELLOW}#${secondary_rank}${NC}"
				echo -e "${CYAN}       Candidate Start:${NC} ${YELLOW}${secondary_start}s${NC}"
				echo -e "${CYAN}       Candidate Window:${NC} ${YELLOW}${secondary_refine_start}s -> ${secondary_refine_end}s${NC}"
				echo -e "${CYAN}       Engine Ceiling:${NC} ${YELLOW}${secondary_engine_limit}s${NC}"
				echo -e "${CYAN}       Step:${NC} ${YELLOW}${INTRO_STEP_SIZE:-1}s${NC}"
				echo -e "${CYAN}       Anchors:${NC} ${YELLOW}${resolved_intro_anchors}${NC}"

				phash_output="$(
					run_intro_hash_engine \
						"$secondary_refine_start" \
						"$secondary_engine_limit" \
						"$secondary_temporal_hash_diff" \
						"$file" \
						"${INTRO_STEP_SIZE:-1}" \
						"$resolved_intro_anchors" \
						"intro_template/intro_template*.mkv" \
						"${INTRO_HASH_MODE:-phash}" \
						"$secondary_refine_end"
				)"
				phash_status=$?

				secondary_refine_result="$(
					printf '%s\n' "$phash_output" |
						awk '
							/^(MATCH\|.*|NO_MATCH)$/ {
								line=$0
							}

							END {
								print line
							}
						'
				)"

				if [[ $phash_status -eq 0 &&
				      "$secondary_refine_result" == MATCH* ]]; then
					echo -e "${GR} = = > Secondary Temporal Candidate Confirmed By Local pHash.${NC}"
					structural_match_found=1
					break
				fi

				echo -e "${YEB} = = >${NC}${YE} Secondary Temporal Candidate #${secondary_rank} Was Not Confirmed.${NC}"
			done
		fi

		# --------------------------------------------------------
		# SECONDARY TEMPORAL ISLAND RESCUE
		# --------------------------------------------------------
		# Only runs if Temporal produced real candidates but its
		# top-three local verification did not confirm a match.
		# Distant candidates remain separate islands.
		# --------------------------------------------------------
		if (( structural_match_found == 0 &&
		      ${#secondary_temporal_candidates[@]} > 0 )); then

			echo
			echo -e "${CYAN} = = > Cascade Pass 6:${NC} ${YELLOW}Bounded Secondary Temporal Island Rescue${NC}"

			mapfile -t secondary_rescue_islands < <(
				printf '%s\n' "${secondary_temporal_candidates[@]}" |
					awk \
						-F'|' \
						-v floor="$SCAN_START" \
						-v ceiling="$duration_raw" '
						{
							center = $2 + 0
							start = center - 15
							end = center + 15

							if (start < floor)
								start = floor

							if (end > ceiling)
								end = ceiling

							printf "%.3f|%.3f\n", start, end
						}
					' |
					sort -t'|' -k1,1n |
					awk -F'|' '
						NR == 1 {
							start = $1
							end = $2
							next
						}

						{
							if ($1 <= end + 1) {
								if ($2 > end)
									end = $2
							} else {
								printf "%.3f|%.3f\n", start, end
								start = $1
								end = $2
							}
						}

						END {
							if (NR > 0)
								printf "%.3f|%.3f\n", start, end
						}
					'
			)

			secondary_island_number=0

			for secondary_island in "${secondary_rescue_islands[@]}"; do
				IFS='|' read -r secondary_island_start secondary_island_end <<< "$secondary_island"
				((secondary_island_number+=1)) || :

				secondary_island_limit="$(
					awk \
						-v candidate_end="$secondary_island_end" \
						-v template_duration="$secondary_template_duration" \
						-v file_duration="$duration_raw" \
						'BEGIN {
							v = candidate_end + template_duration

							if (v > file_duration)
								v = file_duration

							printf "%.3f", v
						}'
				)"

				echo
				echo -e "${CYAN} = = > Secondary Temporal Rescue Island #${secondary_island_number}:${NC}"
				echo -e "${CYAN}       Window:${NC} ${YELLOW}${secondary_island_start}s -> ${secondary_island_end}s${NC}"
				echo -e "${CYAN}       Rescue Step:${NC} ${YELLOW}0.5s${NC}"
				echo -e "${CYAN}       Anchors:${NC} ${YELLOW}${resolved_intro_anchors}${NC}"

				phash_output="$(
					run_intro_hash_engine \
						"$secondary_island_start" \
						"$secondary_island_limit" \
						"$secondary_temporal_hash_diff" \
						"$file" \
						"0.5" \
						"$resolved_intro_anchors" \
						"intro_template/intro_template*.mkv" \
						"${INTRO_HASH_MODE:-phash}" \
						"$secondary_island_end"
				)"
				phash_status=$?

				secondary_island_result="$(
					printf '%s\n' "$phash_output" |
						awk '
							/^(MATCH\|.*|NO_MATCH)$/ {
								line=$0
							}

							END {
								print line
							}
						'
				)"

				if [[ $phash_status -eq 0 &&
				      "$secondary_island_result" == MATCH* ]]; then
					echo -e "${GR} = = > Secondary Temporal Rescue Island Confirmed By Fine pHash.${NC}"
					structural_match_found=1
					break
				fi

				echo -e "${YE} = = > Secondary Temporal Rescue Island #${secondary_island_number} Did Not Confirm A Match.${NC}"
			done
		fi

		if (( structural_match_found == 0 )); then
			echo
			echo -e "${YE} = = > Secondary Temporal Cascade Did Not Confirm A Match.${NC}"
			echo -e "${YE} = = > Full-Range pHash Remains Suppressed.${NC}"

			phash_output="NO_MATCH"
			phash_status=0
		fi
	fi

	intro_find_t1="$(date +%s)"
	intro_find_elapsed="$((intro_find_t1 - intro_find_t0))"
	intro_find_elapsed_hms="$(format_seconds_hms "$intro_find_elapsed")"

    # ========================================================
    # EXTRACT ONLY THE REAL ENGINE CONTRACT LINE
    # --------------------------------------------------------
    # Even if future-you adds more stdout later by mistake,
    # this keeps the Bash side anchored on the final legal line.
    # ========================================================
    result="$(printf '%s\n' "$phash_output" | awk '
        /^(MATCH\|.*|NO_MATCH)$/ { line=$0 }
        END { print line }
    ')"

    if [[ $phash_status -ne 0 ]]; then
        echo -e "${REB} = = > xHash Engine Failed For: $file${NC}"

        # Helpful breadcrumb for future-you:
        if [[ -f "$PHASH_STDERR_LOG" ]]; then
            echo -e "${YE} = = > See Python stderr log:${NC} $PHASH_STDERR_LOG"
        fi

        [[ -n "$phash_output" ]] && echo "$phash_output"

        result="PHASH_ERROR"

        if [[ "${MODE:-}" == "2" ]]; then
            continue
        fi
    fi

    # ========================================================
    # CONTRACT GUARD:
    # - If Python exited 0 but we still did not get a legal result line,
    #   treat that as an engine-side protocol failure.
    # ========================================================
    if [[ $phash_status -eq 0 && -z "$result" ]]; then
        echo -e "${REB} = = > xHash Engine Returned No Parseable Result For: $file${NC}"

        if [[ -f "$PHASH_STDERR_LOG" ]]; then
            echo -e "${YE} = = > See Python stderr log:${NC} $PHASH_STDERR_LOG"
        fi

        result="PHASH_ERROR"

        if [[ "${MODE:-}" == "2" ]]; then
            continue
        fi
    fi

    # Optional human-facing echo so you can see the exact contract line
    # that Bash is about to trust.
    if [[ "$result" == MATCH* || "$result" == "NO_MATCH" ]]; then
        echo -e "${CYAN} = = > Engine Result:${NC}${GREEN} $result${NC}"
    fi

    if [[ "$result" == MATCH* ]]; then
        IFS='|' read -r _ start end template_used diff_used <<< "$result"

		# Keep the real winning-template path for the audio witness.
		# The mapped path below is only for reports and intro_map.csv.
		template_source="$template_used"
		template_used="$(factory_template_map_path "$template_used")"

        start_hms="$(seconds_to_hms "$start")"
        end_hms="$(seconds_to_hms "$end")"

        echo -e "${GRB} = = >${NC}${GREEN} Perceptual Match Found.${NC}"
        echo -e "${CYAN} = = > Start:${NC}${YELLOW} $start ${NC}${GREEN}(${start_hms})${NC}"
        echo -e "${CYAN} = = > End:${NC}${YELLOW}   $end ${NC}${GREEN}(${end_hms})${NC}"

        duration="$(awk -v s="$start" -v e="$end" 'BEGIN{printf "%.3f", e - s}')"
        duration_hms="$(seconds_to_hms "$duration")"

        echo -e "${CYAN} = = > Match Duration:${NC}${YELLOW} $duration ${NC}${GREEN}(${duration_hms})${NC}"

        echo -e "${CYAN} = = > Key:${NC}${YELLOW}   $template_used${NC}"
        echo -e "${CYAN} = = > Diff:${NC}${YELLOW}  ${diff_used:-}${NC}"
        echo -e "${CYAN} = = > IntroFind Time:${NC}${YELLOW} ${intro_find_elapsed}s ${NC}${GREEN}(${intro_find_elapsed_hms})${NC}"

		run_audio_waveform_witness \
			"$file" \
			"$start" \
			"$template_source"

        ensure_intro_map

        # 7-column CSV:
        # filename,start,end,start_hms,end_hms,template_used,diff
        #
        # IMPORTANT:
        # - start/end remain the machine-authoritative values
        # - *_hms remains display-only convenience
        # - template_used records which key won
        # - diff records the selected xHash score returned by Python
        #
        echo "$raw,$start,$end,$start_hms,$end_hms,$template_used,${diff_used:-}" >> "$INTRO_MAP"


# outro stuff new pass start
		# ================================================================
		# #MARKER: OPTIONAL OUTROFIND PASS
		# ================================================================
		if (( "$(outro_template_count "${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}")" > 0 )); then

			if already_outro_processed "$raw" || already_outro_processed "$file"; then
				echo -e "${YELLOW} = = > Outro Already Mapped By RAW / Working Name. Skipping Optional OutroFind:${NC} ${GREEN}$raw${NC}"
				continue
			fi

			duration=""
			outro_scan_start=""
			outro_limit=""
			outro_output=""
			outro_result=""
			outro_start=""
			outro_end=""
			outro_start_hms=""
			outro_end_hms=""
			outro_template_used=""
			outro_diff_used=""
			#local duration outro_scan_start outro_limit outro_output outro_result
			#local outro_start outro_end outro_start_hms outro_end_hms outro_template_used outro_diff_used

			duration="$(get_file_duration_seconds "$file")"
			outro_limit="$duration"

			primary_outro_template="$(outro_template_primary "${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}")"
			resolved_outro_tail_scan="$(auto_outro_tail_scan_seconds "$primary_outro_template" "${OUTRO_TAIL_SCAN_SECONDS:-auto}")"

			outro_scan_start="$(awk -v d="$duration" -v back="$resolved_outro_tail_scan" 'BEGIN{
				v=d-back
				if (v < 0) v=0
				printf "%.3f", v
			}')"

			echo
			echo -e "${CYAN} = = > Outro Template Key(s):${NC} ${GREEN}$(factory_template_map_path "${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}")${NC}"
			echo -e "${CYAN} = = > Running OutroFind Window:${NC} ${YELLOW}${outro_scan_start}s → ${outro_limit}s${NC}"
			echo

			outro_find_t0="$(date +%s)"

				resolved_outro_anchors="$(auto_outro_multikey_anchor_csv "${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}" "${OUTRO_ANCHOR_SECONDS:-8,12,16}")"
			echo -e "${CYAN} = = > OutroFind Settings:${NC} ${YELLOW}Mode=${OUTRO_HASH_MODE:-dhash} Diff=${OUTRO_HASH_DIFF:-16} Step=${OUTRO_STEP_SIZE:-1} Anchors=$resolved_outro_anchors${NC}"

			outro_output="$(
				python3 "$PHASH_ENGINE" \
					"$outro_scan_start" \
					"$outro_limit" \
					"${OUTRO_HASH_DIFF:-16}" \
					"$file" \
					"${OUTRO_STEP_SIZE:-1}" \
					"$resolved_outro_anchors" \
					"${OUTRO_TEMPLATE_GLOB:-intro_template/outro*.mkv}" \
					"${OUTRO_HASH_MODE:-dhash}" \
					2> >(tee "$PHASH_STDERR_LOG" | run_phash_engine_colored >&2)
			)"

			outro_find_t1="$(date +%s)"
			outro_find_elapsed="$((outro_find_t1 - outro_find_t0))"
			outro_find_elapsed_hms="$(format_seconds_hms "$outro_find_elapsed")"
			outro_result="$(printf '%s\n' "$outro_output" | awk '
				/^(MATCH\|.*|NO_MATCH)$/ { line=$0 }
				END { print line }
			')"

			if [[ "$outro_result" == MATCH* ]]; then
				IFS='|' read -r _ outro_start _outro_template_duration_end outro_template_used outro_diff_used <<< "$outro_result"
				outro_template_used="$(factory_template_map_path "$outro_template_used")"

				outro_end="$duration"
				outro_start_hms="$(seconds_to_hms "$outro_start")"
				outro_end_hms="$(seconds_to_hms "${outro_end%.*}")"

				echo -e "${GR} = = > Outro Match Found.${NC}"
				echo -e "${CYAN} = = > Outro Start:${NC} ${YELLOW}$outro_start${NC}${GREEN} (${outro_start_hms})${NC}"
				echo -e "${CYAN} = = > Outro End:${NC}   ${YELLOW}$outro_end${NC}${GREEN} (${outro_end_hms})${NC}"

		        outro_duration="$(awk -v s="$outro_start" -v e="$outro_end" 'BEGIN{printf "%.3f", e - s}')"
		        outro_duration_hms="$(seconds_to_hms "$outro_duration")"

		        echo -e "${CYAN} = = > Outro Duration:${NC}${YELLOW} $outro_duration ${NC}${GREEN}(${outro_duration_hms})${NC}"

				echo -e "${CYAN} = = > Outro Key:${NC}   ${GREEN}${outro_template_used:-${OUTRO_TEMPLATE:-intro_template/outro.mkv}}${NC}"
				echo -e "${CYAN} = = > Outro Diff:${NC}  ${YELLOW}${outro_diff_used:-}${NC}"
				echo -e "${CYAN} = = > OutroFind Time:${NC}${YELLOW} ${outro_find_elapsed}s ${NC}${GREEN}(${outro_find_elapsed_hms})${NC}"

				ensure_outro_map
				echo "$raw,$outro_start,$outro_end,$outro_start_hms,$outro_end_hms,${outro_template_used:-${OUTRO_TEMPLATE:-intro_template/outro.mkv}},${outro_diff_used:-}" >> "$OUTRO_MAP"
			else
				echo -e "${REB} = = > No Outro Match Found For:${NC} ${YE}$file${NC}"
			fi

		else
			echo -e "${YE} = = > Optional OutroFind Skipped:${NC} ${YELLOW}$(factory_display_path "$OUTRO_TEMPLATE")${NC} ${YE}Not Found.${NC}"
		fi

# outro stuff new pass end 


    elif [[ "$result" == "NO_MATCH" ]]; then
        echo -e "${REB} = = > No Perceptual Match Found Within ${limit}s.${NC}"
    fi

    if [[ "${MODE:-}" == "2" ]]; then
        continue
    fi

    if [[ "$result" == "PHASH_ERROR" ]]; then
        echo -e "${CYAN} = = > xHash Engine Error. Running Blackdetect...${NC}"
        ffmpeg -hide_banner -loglevel error -nostdin -i "$file" \
            -vf blackdetect=d=${BLACK_DUR}:pix_th=${BLACK_PIX} \
            -an -f null - 2>&1 | tee blackdetect.log
    elif [[ "$result" != MATCH* ]]; then
        echo -e "${CYAN} = = > No xHash Match. Running Blackdetect...${NC}"
        ffmpeg -hide_banner -loglevel error -nostdin -i "$file" \
            -vf blackdetect=d=${BLACK_DUR}:pix_th=${BLACK_PIX} \
            -an -f null - 2>&1 | tee blackdetect.log
    fi
    ;;

    7)
        echo -e "${CYAN} = = > Running Blackdetect...${NC}"
        ffmpeg -hide_banner -loglevel error -nostdin -i "$file" \
        -vf blackdetect=d=${BLACK_DUR}:pix_th=${BLACK_PIX} \
        -an -f null - 2>&1 | tee blackdetect.log
        ;;

    *)
        echo -e "${REB} = = > Invalid Mode.${NC}"
        exit 1
        ;;
    esac

done

echo
echo -e "${CYAN}=============================================${NC}"
echo -e "${YELLOW}--------IntroFind v2.1 Completed-------------${NC}"
echo -e "${YEB} = =>Output:${NC}${GREEN}$INTRO_MAP-outro_map.csv${NC}${YEB}<= = ${NC}"
echo -e "${YEB} = = >${NC}${YE}Logs In Working Dir Until You Press Enter${NC}"
echo

# =========================
# #MARKER: RETURN TO MAIN MENU AFTER ENGINE RUN
# =========================
pause
rm -f -- "$PHASH_ENGINE"
rm -f -- "$PHASH_STDERR_LOG"
run_main_menu
exit 0
