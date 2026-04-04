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
# -----------------------------------------------------------------------------------------
#   NEW Setup Command no word wrap with this baby,it installs the bathroom sink and all
# sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]"
# -------------------------DEPENDENCY DESCRIPTIONS INSTALL THESE---------------------------
# ffmpeg:       The Main Engine For Remuxing, Trimming, Joining, Rebuilding, And More.
# -----------------------------------------------------------------------------------------
# ffprobe:      The "Eyes" Used To Calculate Duration, Streams, FPS, And Probe Details.
# -----------------------------------------------------------------------------------------
# bc:           The "Brain" For Decimal Math And Timing Comparisons.
# -----------------------------------------------------------------------------------------
# awk:          Text Surgery Helper Used For Parsing, Formatting, And Field Work.
# -----------------------------------------------------------------------------------------
# sed:          Stream Editor Used For Cleanup, Input Normalization, And Text Fixups.
# -----------------------------------------------------------------------------------------
# grep:         Pattern Hunter Used For Matching, Filtering, And Decision Logic.
# -----------------------------------------------------------------------------------------
# df:           Disk Space Reporter So The Script Can Warn About Free Space.
# -----------------------------------------------------------------------------------------
# python3:      Needed For Python-Based Helper Paths And Related Tooling.
# -----------------------------------------------------------------------------------------
# pipx:         The Safe "Bubble" Environment For Python Apps Like Scenedetect.
# -----------------------------------------------------------------------------------------
# scenedetect:  The "Orbital Laser" For Automatic Intro Finding (Installed Via Pipx).
# -----------------------------------------------------------------------------------------
# iconv:        Character Transliteration Helper Used In Some Title Cleanup Paths.
# -----------------------------------------------------------------------------------------
# ffplay:       Quick Playback Checker For Manual Review / Sanity Checks.
# -----------------------------------------------------------------------------------------
# findmnt:      Friendly Drive Label / Mount Source Lookup Helper.
# -----------------------------------------------------------------------------------------
# less:         Scrollable Pager For Long Notes / Explain Screens.
# -----------------------------------------------------------------------------------------
# mkvpropedit:  Fast In-Place MKV Metadata Editor (Title Repair Without Remux).
# -----------------------------------------------------------------------------------------
# mkvpropedit:  Is part of mkvtoolnix. [mkvtoolnix.download](https://mkvtoolnix.download/)
# -----------------------------------------------------------------------------------------
#
# INSTALL COMMAND:
# sudo apt update && sudo apt install ffmpeg bc gawk sed grep coreutils python3 python3-pip pipx mkvtoolnix util-linux less -y && pipx install "scenedetect[opencv]"
# -----------------------------------------------------------------------------------------
# NOTES:
# - ffprobe and ffplay normally come with the ffmpeg package.
# - df is part of coreutils on Debian/Ubuntu/Mint systems.
# - findmnt is usually provided by util-linux on Debian/Ubuntu/Mint systems.
# - mkvpropedit comes from mkvtoolnix.
# - scenedetect is OPTIONAL but automatic intro detection is the star of the show.
# - less is OPTIONAL; note screens can fall back to plain cat behavior.
# - iconv is OPTIONAL; some detox/transliteration behavior may be reduced without it.
# -----------------------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob

# ------------------ COLORS ------------------
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
MAGENTA="\033[1;35m"
WHITE='\033[1;37m'
BWHITE='\033[1;37m'
NC="\033[0m"

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
#     RE YE GR BW
#   These are reserved for true meaning-based warnings / verdicts and must NOT
#   be remapped by twisted(). Use these for:
#     GR = SAFE / PASS / OK
#     YE = CAUTION / NOTICE / WARNING
#     RE = RISK / FAIL / DANGER / DESTRUCTIVE
#     BW = wording or effects or reserved for future
# RULE:
# - Use ${RED}/${YELLOW}/${GREEN}/etc for decorative or general display output
# - Use ${RE}/${YE}/${GR}/${BW} for any output where the actual meaning of the color
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

# engine
 
#=================================================================================================================

# menus     

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
		echo -e "${YELLOW}     0) Return${NC}"
		echo
        echo -e "${YELLOW}"
		read -r -p " = = > Select option [1-5 | 0=return]: " choice
        echo -e "${NC}"

        if is_factory_exit_token "$choice"; then
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
				echo -e "${WHITE}  0) Return${NC}"
				echo

				read -r -p " = = > Select theme [1-6 | 0=return]: " theme_name
				theme_name="${theme_name,,}"
				theme_name="${theme_name//[[:space:]]/}"

				case "$theme_name" in
					1) twisted theme classic ;;
					2) twisted theme mellow ;;
					3) twisted theme danger ;;
					4) twisted theme ice ;;
					5) twisted theme twisted ;;
					6) twisted theme mono ;;
					0|q)
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
# Safe Pause Function With Color
pause() {
    echo -e "${GR}>->->->-> = = > Review Above Carefully.....${NC}"
    echo -e "${BW}>->->->-> = = > Screen Will Clear When You ${NC}"
    echo -e "${YE}>->->->-> = = > Press Enter To Continue....${NC}"
    read -r _
}


# ------------------ DEFAULTS ------------------
DEFAULT_SCAN_START=30
DEFAULT_HASH_DIFF=24
DEFAULT_MAX_SCAN=601
DEFAULT_BLACK_DURATION=0.5
DEFAULT_BLACK_PIXTH=0.10

INTRO_MAP="intro_map.csv"
output="intro_template.mkv"
INFO_MAP="info.csv"


# - Helpers

# - Canonicalize names everywhere helper
canonical_factory_path() {
	local p="$1"

	# collapse leading ./ only
	while [[ "$p" == ./* ]]; do
		p="${p#./}"
	done

	printf '%s\n' "$p"
}

# =========================
# #MARKER: FACTORY EXIT TOKEN (TEN-KEY FRIENDLY)
# =========================
# PURPOSE:
# - Provide A Universal One-Hand Numpad Exit / Cancel Token
#
# TEN-KEY EXIT HOOK
#
# IMPORTANT:
# - In The MAIN MENU, 0. Means True Program Exit
# - It Must Behave Like q, Not Like "Return From Function"
# - If We Only return 0 Here, Control Falls Through Into The
#   Legacy IntroFind Processing Tail Below run_main_menu
#
#
# RULE:
# - "0." = cancel / back / exit
# - also accepts q/Q for normal keyboard flow
#
is_factory_exit_token() {
	local v="${1:-}"
	[[ "$v" == "0." || "$v" == "q" || "$v" == "Q" ]]
}

ask_yes_no() {
	local prompt="$1"
	local ans

	read -r -p "$prompt" ans
	ans="${ans,,}"
	ans="${ans//[[:space:]]/}"

	[[ "${ans:-n}" == y* ]]
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

# start new rekey validation skipped scheme helpers

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
# more rekey helpers below


# ============================================================
# #MARKER: PREPARE SOURCES :: VERIFIED REKEY HANDOFF HELPERS
# ============================================================
# PURPOSE:
# - After OEM backup creation + Batch Normalizer run, verify that each
#   eligible original source now has BOTH:
#     1) its OEM safety copy in ./oem/OEM_<original>
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
    local -a vids=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
    shopt -u nullglob nocaseglob

    local f
    for f in "${vids[@]}"; do
        [[ "$f" =~ ^(REKEY_|SUTURED_|BARFIX_|SUBPACKED_|OEM_|oem_) ]] && continue
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

prepare_verify_oem_and_rekey_parity() {
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
    local has_oem has_rekey

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
        backup="oem/OEM_${f}"

        has_oem=0
        has_rekey=0

        if [[ -f "$backup" ]]; then
            has_oem=1
            ((PREP_OEM_MATCH_COUNT+=1)) || :
        fi

        if [[ -f "$rekey" ]]; then
            has_rekey=1
            ((PREP_REKEY_MATCH_COUNT+=1)) || :
        fi

        if (( has_oem == 1 && has_rekey == 1 )); then
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
            backup="oem/OEM_${f}"

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
    #     oem/OEM_<original>
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
    echo -e "${YELLOW} = = > OEM Safety Copies Remain In ./oem With oem_ Prefix.${NC}"
    echo -e "${YELLOW} = = > REKEY Working Files Remain In Place.${NC}"
    echo

    read -r -p " = = > Delete Verified Originals Now? (y/n): " delete_reply
    case "${delete_reply,,}" in
        y|yes) ;;
        *)
            echo -e "${YELLOW} = = > Verified Original Deletion Cancelled.${NC}"
            echo
            return 0
            ;;
    esac

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
    prepare_verify_oem_and_rekey_parity
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

	read -r -p " = = > Proceed with FULL REKEY auth ledger rebuild? (y/n): " rebuild_reply
	case "${rebuild_reply,,}" in
		y|yes) ;;
		*)
			echo
			echo -e "${YELLOW} = = > REKEY Auth Ledger Rebuild Cancelled.${NC}"
			echo
			pause
			return 0
			;;
	esac

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
        echo -e "${GREEN} = = > Reusing Cached Trusted Working Source:${NC} $(basename "$cached")" >&2

        # Defensive alias skip:
        # If The Cached Working File Itself Was Already Mapped, Caller Can Skip.
        if already_processed "$cached"; then
            echo -e "${YELLOW} = = > Cached Working Source Already Mapped. Skipping.${NC}" >&2
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
			# GAPMAN may internally switch from raw file identity to a
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
	local oem_size="0"

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
	local -a all_videos=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
	local -a oem_files=(OEM_*)
	local -a rekey_files=(REKEY_*.mkv)
	local -a sutured_files=(SUTURED_*.mkv)
	local -a barfix_files=(BARFIX_*.mkv)
	local -a subpacked_files=(SUBPACKED_*)
	local -a csv_files=(*.csv)

	local -a original_videos=()
	local f
	for f in "${all_videos[@]}"; do
		[[ -f "$f" ]] || continue
		case "${f^^}" in
			OEM_*|REKEY_*|SUTURED_*|PILOT_SUTURED_*|BARFIX_*|SUBPACKED_*)
				continue
				;;
		esac
		original_videos+=("$f")
	done
	shopt -u nullglob nocaseglob

	echo -e "${CYAN} = = > Video Files Total In Working Dir:${NC} ${#all_videos[@]}"
	echo -e "${CYAN} = = > Original Working Videos:${NC} ${#original_videos[@]}"
	echo -e "${CYAN} = = > OEM_* Files In Working Dir:${NC} ${#oem_files[@]}"
	echo -e "${CYAN} = = > REKEY_* Files In Working Dir:${NC} ${#rekey_files[@]}"
	echo -e "${CYAN} = = > SUTURED_* Files In Working Dir:${NC} ${#sutured_files[@]}"
	echo -e "${CYAN} = = > BARFIX_* Files In Working Dir:${NC} ${#barfix_files[@]}"
	echo -e "${CYAN} = = > SUBPACKED_* Files In Working Dir:${NC} ${#subpacked_files[@]}"
	echo -e "${CYAN} = = > CSV Files In Working Dir:${NC} ${#csv_files[@]}"

	if [[ -d oem ]]; then
		oem_size="$(du -sh oem 2>/dev/null | awk '{print $1}')"
		echo -e "${GREEN} = = > oem/ Directory Present${NC} ${YELLOW}(${oem_size})${NC}"
	else
		echo -e "${YELLOW} = = > oem/ Directory Not Present${NC}"
	fi

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
}

ui_show_cleanup_target_snapshot() {
	local -a temp_targets=()
	local -a template_targets=()
	local -a detect_targets=()
	local -a sutured_targets=()

	mapfile -t temp_targets < <(cleanup_collect_temp_targets)
	mapfile -t template_targets < <(cleanup_collect_template_targets)
	mapfile -t detect_targets < <(cleanup_collect_detection_targets)
	mapfile -t sutured_targets < <(cleanup_collect_sutured_targets)

	echo
	echo -e "${CYAN} = = > Temp / junk targets:${NC} ${#temp_targets[@]}"
	echo -e "${CYAN} = = > Template targets:${NC} ${#template_targets[@]}"
	echo -e "${CYAN} = = > Detection map / CSV targets:${NC} ${#detect_targets[@]}"
	echo -e "${CYAN} = = > Finished SUTURED outputs:${NC} ${#sutured_targets[@]}"
}


# =========================
# #MARKER: FOLDER SIZE HELPERS
# =========================
# PURPOSE:
# - Show How Much Space Current Working Directory And OEM Folder Are Using
# - Help User Decide Whether To Archive Or Delete Before Cleanup
#
# WHY THIS EXISTS:
# - Video Workflows Expand Fast (REKEY + SUTURED + OEM Copies)
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
	local cwd wd_size oem_size drive_display
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
	oem_size="$(get_folder_size_human "./oem")"
	echo -e "${CYAN} = = > OEM Folder Size:${NC} ${YELLOW}$oem_size${NC}"

	echo
}

# end of Show How Much Space Current Working Directory And OEM Folder


#==================================================================================
# start of INFO CSV LOOKUP BY WORKING NAME

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
	if [[ ! -d "intro_template" ]]; then
		mkdir -p intro_template
		echo -e "${YELLOW} = = > Created intro_template/ working directory.${NC}"
	fi
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
  # ========================================================

  base="$(echo "$base" | sed -E 's/_+/_/g; s/^_+//; s/_+$//')"

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
	local path="$1"
	local start_seg="${2:-3}"

	# Split on /
	IFS='/' read -r -a parts <<< "$path"

	# Remove empty leading segment from absolute paths
	if [[ -z "${parts[0]:-}" ]]; then
		parts=("${parts[@]:1}")
	fi

	# If path is long enough, trim from requested segment
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

# =========================
# #MARKER: GLOBAL TIME INPUT NORMALIZER
# =========================
# PURPOSE:
# - To Make The Ten Key An Easy Place To Enter Times
# - Accept user time input in any of these forms:
#     120         -> 120 seconds
#     2:20        -> 140 seconds
#     2.20        -> 140 seconds
#     1:02:30     -> 3750 seconds
#     1.02.30     -> 3750 seconds
#
# DESIGN:
# - "." is treated the same as ":" for keypad-friendly entry
# - No separator = raw seconds
# - One separator = mm:ss
# - Two separators = hh:mm:ss
#
# IMPORTANT:
# - This helper returns INTEGER seconds
# - It must live in global scope so Template Builder, GAPMAN, and other
#   workflow stages can all use it.
#
to_seconds() {
  local input
  local h=0 m=0 s=0
  local p1 p2 p3

  input="${1:-}"

  # Trim whitespace
  input="$(echo "$input" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"

  # Empty input -> 0
  [[ -z "$input" ]] && {
    echo "0"
    return 0
  }

  # Keypad-friendly normalization: treat "." same as ":"
  input="${input//./:}"

  # Raw integer seconds
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    echo "$input"
    return 0
  fi

  # Split on ":" after normalization
  IFS=':' read -r p1 p2 p3 <<< "$input"

  if [[ -n "${p1:-}" && -n "${p2:-}" && -z "${p3:-}" ]]; then
    # mm:ss
    m="$p1"
    s="$p2"
  elif [[ -n "${p1:-}" && -n "${p2:-}" && -n "${p3:-}" ]]; then
    # hh:mm:ss
    h="$p1"
    m="$p2"
    s="$p3"
  else
    # Malformed input -> 0
    echo "0"
    return 0
  fi

  # Force base-10 so 08 / 09 do not trigger octal interpretation
  # Ensure variables have default values to prevent arithmetic expansion errors
  echo $((10#${h:-0} * 3600 + 10#${m:-0} * 60 + 10#${s:-0}))
}

# #MARKER: END GLOBAL TEXT / COMMAND HELPERS



    # ------------------ DEP CHECK ------------------
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
	echo -e "${REB} = = > Missing Required Dependency: $dep${NC}"
	echo -e "${RE}============================================================${NC}"
}

print_missing_optional_dep() {
	local dep="$1"
	local why="$2"
	echo -e "${YELLOW}------------------------------------------------------------${NC}"
	echo -e "${YEB} = = > Optional Tool Missing: $dep${NC}"
	echo -e "${YEB} = = > Related Feature Impact: $why${NC}"
	echo -e "${YELLOW}------------------------------------------------------------${NC}"
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
}

    # ============================================================
    # #MARKER: STARTUP DEP CHECK ENTRY POINT
    # ============================================================
    # PURPOSE:
    # - Single call site for startup dependency handling.
    # - Keeps the top-level runtime path obvious.
    # ============================================================
run_startup_dependency_checks() {


    ensure_intro_template_dir
	check_required_dependencies_or_die
	detect_optional_tools
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
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${CYAN} = = > DEPENDENCY STATUS REPORT${NC}"
	echo -e "${CYAN}============================================================${NC}"
	echo

	# --------------------------------------------------------
	# REQUIRED CORE TOOLS
	# --------------------------------------------------------
	# These are the tools the factory broadly relies on.
	# Missing tools here mean the system is not fully ready.
	echo -e "${YELLOW}--- REQUIRED CORE TOOLS ---${NC}"

	for dep in ffmpeg ffprobe bc awk sed grep df; do
		if have_cmd "$dep"; then
			echo -e "${GREEN}[ OK ]${NC} $dep"
		else
			echo -e "${REB}[MISS]${NC} $dep"
		fi
	done

	echo

	# --------------------------------------------------------
	# OPTIONAL / FEATURE TOOLS
	# --------------------------------------------------------
	# These unlock convenience features or special missions.
	# Missing tools here do NOT necessarily mean the factory is unusable.
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

	echo
	echo -e "${CYAN}============================================================${NC}"
	echo -e "${YELLOW} = = > Show Install / Help Wall? (y/n): ${NC}\c"
	read -r ans

	if [[ "$ans" =~ ^[Yy]$ ]]; then
		echo
		show_global_dependency_help_wall
	fi

	echo
	pause
}

# = = = = = = = = = = = = End of dep_check manual

# Helper function for dependency checking
check_opt() {
	local dep="$1"
	local note="$2"

	if have_cmd "$dep"; then
		echo -e "${GREEN}[ OK ]${NC} $dep"
	else
		echo -e "${YELLOW}[MISS]${NC} $dep  -> $note"
	fi
}

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

    echo -e "${RED}=======================================================================${NC}"
    echo -e "${BWHITE}                      THE_FACTORY                                      ${NC}"
    echo -e "${CYAN}-----THE UNIVERSAL VIDEO SANITIZER & TRIMMER & META TITLE FIXER--------${NC}"
    echo -e "${RED}------Clip_Grab BitZ From VidZ Any Dir Drop_In Tool custom_cut.mkv-----${NC}"
    echo -e "${BWHITE}-----IntroFind-Engine + Perceptual_Hash_Detection----------------------${NC}"
    echo -e "${CYAN}------SUBTOX UNIFIED SUBTITLE + RENAME ENGINE -------------------------${NC}"
    echo -e "${RED}=======================================================================${NC}"
    echo
    echo -e "${GREEN}        Main Menu = = = THE_FACTORY = = = Main Menu                     ${NC}"
    echo

    # ------------------ WORKING CONTEXT ------------------
    cwd="$(pwd)"
    drive_display="$(get_drive_display "$cwd")"
    cwd_display="$(trim_working_path_display "$cwd" 3)"

    echo -e "${GREEN} = = > Working Drive/Folder:${NC} [${YELLOW}$drive_display${NC}] ${YELLOW}$cwd_display${NC}"

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
    echo

    # ------------------ WORKFLOW ------------------

    echo -e "${YELLOW}"
    echo "     1) Inspect / Explain Folder State"
    echo "     2) Prepare Sources"
    echo "     3) Build Template / Detect Intros"
    echo "     4) Run GAPMAN"
    echo "     5) Titlez And Subtitlez"
    echo "     6) Utility / Advanced Tools"
    echo "     7) Cleanup / Finalize Folder"
    echo
    echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
    echo

    read -r -p "     Choice: " MAIN_CHOICE
    echo -e "${NC}"
    MAIN_CHOICE="${MAIN_CHOICE//[[:space:]]/}"

    # ========================================================
    # TEN-KEY EXIT HOOK
    # ========================================================
    # IMPORTANT:
    # - In The MAIN MENU, 0. Means True Program Exit
    # - It Must Behave Like q, Not Like "Return From Function"
    # - If We Only return 0 Here, Control Falls Through Into The
    #   Legacy IntroFind Processing Tail Below run_main_menu
    #
    if is_factory_exit_token "$MAIN_CHOICE"; then
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

      4)
        run_gapman_menu
        ;;

      5)
        run_title_subtitle_menu
        ;;

      6)
        run_utility_menu
        ;;

      7)
        run_finalize_menu
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

run_barfix() {

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

    find_english_audio_ordinal() {
      local file="$1"
      local ord=0
      local lang

      while IFS= read -r lang; do
        lang="${lang,,}"
        lang="${lang// /}"

        if [[ "$lang" == "eng" || "$lang" == "en" || "$lang" == "english" ]]; then
          echo "$ord"
          return 0
        fi

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
      local audio_count sub_count english_ord chosen_audio i

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
        english_ord="$(find_english_audio_ordinal "$file")"

        for ((i=0; i<audio_count; i++)); do
          BARFIX_PLAYBACK_ARGS+=(-disposition:a:${i} 0)
        done

        if [[ "$english_ord" =~ ^[0-9]+$ ]] && (( english_ord >= 0 )); then
          chosen_audio="$english_ord"
          BARFIX_AUDIO_REASON="English-Tagged Audio Found"
        else
          chosen_audio="0"
          BARFIX_AUDIO_REASON="No English Tag Found; Falling Back To First Audio"
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

    clear
    echo -e "${CYAN}=====================================================${NC}"
    echo -e "${CYAN}      BARFIX v3 — TITLE + PLAYBACK DEFAULT TOOLS     ${NC}"
    echo -e "${CYAN}=====================================================${NC}"
    echo
    echo -e "${YELLOW}"
    echo "     1) Title Metadata Only        (fast path)"
    echo "     2) Playback Defaults Only     (safe remux)"
    echo "     3) Title + Playback Defaults  (safe remux)"
    echo "     q) Cancel"
    echo

    read -r -p "     Select BARFIX mode [1/2/3/q]: " BARFIX_MODE
    echo -e "${YELLOW}"
    if is_factory_exit_token "$BARFIX_MODE"; then
        return 0
    fi

    if [[ "$BARFIX_MODE" != "1" && "$BARFIX_MODE" != "2" && "$BARFIX_MODE" != "3" ]]; then
      echo -e "${REB} = = > Invalid BARFIX Mode.${NC}"
      pause
      return 1
    fi

    local SEG=""
    if [[ "$BARFIX_MODE" == "1" || "$BARFIX_MODE" == "3" ]]; then
      read -p "Start TITLE At Which Underscore Segment? (1-based, e.g. 3): " SEG
      if [[ -z "${SEG:-}" || ! "$SEG" =~ ^[0-9]+$ || "$SEG" -lt 1 ]]; then
        echo -e "${REB} = = > Invalid Segment Number.${NC}"
        pause
        return 0
      fi
    fi

    # Use SUBTOX's vids list (already collected) if available, else collect here.
    # NOTE: SUBTOX uses local-scoped vids, so BARFIX will usually scan the folder.
    # This is intentional for portable use: BARFIX should work standalone anywhere.
    local targets=()
    if declare -p vids >/dev/null 2>&1 && [[ ${#vids[@]} -gt 0 ]]; then
        for f in "${vids[@]}"; do
            [[ "$f" =~ ^(BARFIX_|SUTURED_|SUBPACKED_|REKEY_) ]] && continue
            targets+=("$f")
        done
    else
        shopt -s nullglob nocaseglob
        local -a files_local=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
        shopt -u nullglob nocaseglob
        for f in "${files_local[@]}"; do
            [[ "$f" =~ ^(BARFIX_|SUTURED_|SUBPACKED_|REKEY_) ]] && continue
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
    echo -e "${YELLOW} = = > Preview:${NC}"
    for f in "${targets[@]}"; do
      if [[ "$BARFIX_MODE" == "1" || "$BARFIX_MODE" == "3" ]]; then
        local t
        t="$(make_title_from_filename "$f" "$SEG")"
        printf "  %s  ->  %s\n" "$f" "$t"
      else
        printf "  %s\n" "$f"
      fi
    done

    echo
    read -p " = = > Proceed? (y/n): " confirm
    [[ "${confirm:-n}" != "y" ]] && { echo " = = > Aborted."; pause; return 0; }

    echo
    local total=${#targets[@]}
    local current=1

    for f in "${targets[@]}"; do
      local t ext name out
      local -a BARFIX_PLAYBACK_ARGS
      local BARFIX_AUDIO_COUNT BARFIX_SUB_COUNT BARFIX_AUDIO_DEFAULT BARFIX_AUDIO_REASON

      ext="${f##*.}"

      echo -e "${YELLOW}YELLOW[$current / $total]${NC} Fixing: $f"

      if [[ "$BARFIX_MODE" == "1" || "$BARFIX_MODE" == "3" ]]; then
        t="$(make_title_from_filename "$f" "$SEG")"
        echo -e "${CYAN} = = > Title:${NC} $t"
      fi

      # =========================
      # #MARKER: BARFIX MODE 1 FAST TITLE-ONLY PATH
      # =========================
      # Keep this path as close as possible to the current known-good BARFIX.
      if [[ "$BARFIX_MODE" == "1" ]]; then
        if [[ "${ext,,}" == "mkv" ]] && have_cmd mkvpropedit; then
          if mkvpropedit "$f" --edit info --set "title=$t" >/dev/null 2>&1; then
            echo -e "  ${GREEN} = = > Updated In-Place:${NC} $f"
          else
            echo -e "  ${REB} = = > FAILED In-Place:${NC} $f"
          fi
        else
          name="${f%.*}"
          out="BARFIX_${name}.mkv"
          if ffmpeg -hide_banner -loglevel error -nostdin -i "$f" \
            -map 0 -c copy -metadata title="$t" \
            "$out" -y; then
            echo -e "  ${GREEN} = = > Created:${NC} $out"
          else
            echo -e "  ${REB} = = > FAILED:${NC} $f"
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
        echo -e "${YELLOW} = = > Audio Default:${NC} None Available"
      else
        echo -e "${CYAN} = = > Audio Streams:${NC} $BARFIX_AUDIO_COUNT"
        echo -e "${CYAN} = = > Subtitle Streams:${NC} $BARFIX_SUB_COUNT"
        echo -e "${CYAN} = = > Default Audio Output Stream:${NC} $((BARFIX_AUDIO_DEFAULT + 1))"
        echo -e "${CYAN} = = > Audio Choice Reason:${NC} $BARFIX_AUDIO_REASON"
      fi

      name="${f%.*}"
      out="BARFIX_${name}.mkv"

      if [[ "$BARFIX_MODE" == "2" ]]; then
        if ffmpeg -hide_banner -loglevel error -nostdin -i "$f" \
          -map 0 -c copy \
          "${BARFIX_PLAYBACK_ARGS[@]}" \
          "$out" -y; then
          echo -e "  ${GR} = = > Created:${NC} $out"
        else
          echo -e "  ${REB} = = > FAILED:${NC} $f"
          rm -f "$out"
        fi
      else
        if ffmpeg -hide_banner -loglevel error -nostdin -i "$f" \
          -map 0 -c copy \
          "${BARFIX_PLAYBACK_ARGS[@]}" \
          -metadata title="$t" \
          "$out" -y; then
          echo -e "  ${GR} = = > Created:${NC} $out"
        else
          echo -e "  ${REB} = = > FAILED:${NC} $f"
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
#  barfix end



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
# GAPMAN / SUTURED WARNING:
# - After GAPMAN, especially when using global PRE-trim, intro removal, and/or
#   global POST-trim, the timeline no longer matches the original broadcast/
#   disc/file runtime.
# - External subtitles made for the original full-length episode will usually
#   become offset, structurally wrong, or completely unusable on SUTURED output.
# - In other words: once the file has been "cut-n-gutted", old external .srt
#   files are no longer trustworthy unless they are specifically retimed for the
#   new cut.
#
# PRACTICAL RULE:
# - Pack external subtitles BEFORE destructive timeline edits whenever possible.
# - Do NOT assume original .srt files will survive GAPMAN trimming intact.
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
    echo -e "${CYAN}                 SUBTOX: UNIFIED ENGINE                                 ${NC}"
    echo -e "${CYAN}=======================================================================${NC}"
    echo -e "${YELLOW}WARNING:= = External Subtitle Work Is Safest On ORIGINAL/OEM Files. = = ${NC}"
    echo -e "${YELLOW}WARNING:= = REKEY Files May Still Work, But Be Sure Subtitle Timing = = ${NC}"
    echo -e "${YELLOW}WARNING:= = Matches That Exact File/Runtime.= = = = = = = = = = = = = = ${NC}"
    echo -e "${RED}WARNING: After GAPMAN / SUTURED Cuts, Old External .srt Files May = = = ${NC}"
    echo -e "${RED}WARNING: Be Shifted, Structurally Wrong, Or Completely Unusable.= = = = ${NC}"
    echo -e "${RED}WARNING: This Is Especially True After PRE-TRIM+INTRO-CUT+POST-TRIM.= = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${YELLOW}1)= = = = = = > Rename & Detox Video File Names < = = = = = = = = = = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${YELLOW}2)= = = = = = > Bulk Pack External .srt Into MKVs < = = = = = = = = = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${YELLOW}3)= = = = = = > Bulk Extract Internal Subtitles To .srt < = = = = = = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"
    echo -e "  ${YELLOW}4)= = = = = = > BARFIX: Title + Playback Default Tools <  = = = = = = ${NC}"
    echo -e "${CYAN}-----------------------------------------------------------------------${NC}"

    echo -e "${YELLOW}"
    read -p " = = > Select Mission [1/2/3/4] or [q] to cancel: " choice
    echo -e "${NC}"
    if is_factory_exit_token "$choice"; then
        return 0
    fi

    shopt -s nullglob nocaseglob
    vids=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
    shopt -u nullglob nocaseglob

    [[ ${#vids[@]} -eq 0 ]] && {
        echo -e "${RE} = = > ERROR: No Video Targets Found In This Folder!${NC}"
        pause
        return 1
    }

# ------------------------------------------------------------------------------
# 1 RENAME & DETOX (TITOX LOGIC)
# ------------------------------------------------------------------------------

    if [[ "$choice" == "1" ]]; then

        filtered=()
        for f in "${vids[@]}"; do
            [[ "$f" =~ ^(SUTURED_|SUBPACKED_) ]] || filtered+=("$f")
        done
        vids=("${filtered[@]}")

        total=${#vids[@]}
        [[ $total -eq 0 ]] && {
            echo -e "${RE}>->->->->->No Targets Found<-<-<-<-<-<${NC}"
            pause
            return 1
        }

        for (( i=0; i<$total; i++ )); do
            file="${vids[$i]}"
            echo -e "\n${CYAN}[$((i+1)) / $total] TARGET: ${GREEN}$file${NC}"

            EP_CODE=$(echo "$file" | grep -oiP 'S\d{2}E\d{2}' | tr '[:lower:]' '[:upper:]' || true)

            if [[ -n "${EP_CODE:-}" ]]; then

                EP_TITLE=""
                if [[ -f "episodes.csv" ]]; then
                    EP_TITLE=$(grep -i "^$EP_CODE," "episodes.csv" 2>/dev/null | cut -d',' -f2- | tr -d '\r' || true)
                fi

                EXT="${file##*.}"

                if [[ -n "$EP_TITLE" ]]; then
                    RAW_FOR_DETOX="$EP_TITLE"
                    BASE_NAME="$EP_CODE"
                else
                    RAW_FOR_DETOX="${file%.*}"
                    BASE_NAME=""
                fi

                CLEAN_TITLE=$(echo "$RAW_FOR_DETOX" | \
                    sed "s/&/and/g; s/é/e/g; s/à/a/g; s/ñ/n/g; s/ç/c/g" | \
                    tr ' ' '_' | tr -dc '[:alnum:]_')

                if [[ -n "$BASE_NAME" ]]; then
                    NEW_NAME="${BASE_NAME}_${CLEAN_TITLE}.${EXT}"
                else
                    NEW_NAME="${CLEAN_TITLE}.${EXT}"
                fi

                if [[ "$file" != "$NEW_NAME" ]]; then
                    echo "Renaming: $file -> $NEW_NAME"
                    mv "$file" "$NEW_NAME"
                fi
            fi
        done

        pause
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
        echo -e "${RED} = = > If You Use SUTURED / GAPMAN-Cut Files, Old External .srt Timing${NC}"
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
            base="${vid%.*}"

            shopt -s nullglob
            subs=("$base"*.srt)
            shopt -u nullglob

            if [[ ${#subs[@]} -gt 0 ]]; then

                cmd=(ffmpeg -hide_banner -loglevel error -nostdin -y -i "$vid")

                for s in "${subs[@]}"; do
                    cmd+=(-i "$s")
                done

                cmd+=(-map 0:v -map 0:a)

                for (( i=0; i<${#subs[@]}; i++ )); do
                    SUB_NAME="${subs[$i]%.*}"
                    cmd+=(-map $((i+1)) -metadata:s:s:$i "title=$SUB_NAME")
                done

                cmd+=(-c copy -disposition:s 0 "SUBPACKED_$vid" -y)

                "${cmd[@]}"
            fi
        done

        pause
        return 0
    fi

# ------------------------------------------------------------------------------
# 3 BULK EXTRACT INTERNAL SUBS
# ------------------------------------------------------------------------------

    if [[ "$choice" == "3" ]]; then

        for vid in "${vids[@]}"; do
            echo -e "${CYAN} = = > Extracting From: $vid${NC}"

            ffmpeg -hide_banner -loglevel error -nostdin -y \
                -i "$vid" -map 0:s? -c:s srt "${vid%.*}.srt"
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
    # DETOX FUNCTION SUB-SYSTEM CALL
    # ------------------------------------------------------------------
# ============================================================
# #MARKER: TITLE DETOX / NORMALIZATION ENGINE
# ============================================================
# PURPOSE:
# - Convert messy/raw titles into clean, filesystem-safe, readable names.
#
# INPUT:
# - Raw string (possibly containing spaces, symbols, unicode, etc.)
#
# OUTPUT:
# - Underscore-separated, cleaned, title-cased string
#
# EXAMPLE:
#   "My Show: Episode #1 (HD)" →
#   "My_Show_Episode_1_Hd"
#
# ============================================================
# DESIGN PHASES:
#
# 1) STRUCTURE CLEANUP:
#    - Convert whitespace → underscores
#    - Replace & with "And"
#
# 2) CHARACTER SANITIZATION:
#    - Remove or normalize special characters
#    - Keep only A-Z, a-z, 0-9, and underscores
#
# 3) OPTIONAL TRANSLITERATION (iconv):
#    - Convert unicode → ASCII equivalents
#    - Example: "é" → "e"
#
# 4) UNDERSCORE NORMALIZATION:
#    - Collapse duplicate underscores
#    - Trim leading/trailing underscores
#
# 5) TITLE CASING:
#    - Capitalize first letter of each segment
#    - Lowercase the rest
#
# ============================================================
# WHY iconv IS OPTIONAL:
# - Not all systems have iconv installed
# - Script must still function without it
# - Without iconv:
#     * Unicode may be stripped instead of converted
#     * Output still remains safe and usable
#
# DESIGN DECISION:
# - Prefer "graceful degradation" over hard dependency
#
# ============================================================
# IMPORTANT:
# - This function must NEVER fail due to missing tools
# - It must always return a usable filename-safe string
# - Safe for use in batch processing pipelines
#
detox_title() {
	local raw="$1"
	local cleaned

	# ========================================================
	# PHASE 1–4: CLEAN + SANITIZE
	# ========================================================
	# If iconv exists → use transliteration
	# If not → skip transliteration safely
	#
	if have_cmd iconv; then
		# Full pipeline with unicode → ASCII conversion
		cleaned=$(echo "$raw" \
			| sed 's/[[:space:]]\+/_/g' \
			| sed 's/&/And/g' \
			| iconv -f utf8 -t ascii//TRANSLIT 2>/dev/null \
			| sed 's/[^A-Za-z0-9_]/_/g' \
			| sed 's/__\+/_/g' \
			| sed 's/^_//; s/_$//')
	else
		# Fallback path (no iconv)
		# Unicode may be stripped instead of converted
		cleaned=$(echo "$raw" \
			| sed 's/[[:space:]]\+/_/g' \
			| sed 's/&/And/g' \
			| sed 's/[^A-Za-z0-9_]/_/g' \
			| sed 's/__\+/_/g' \
			| sed 's/^_//; s/_$//')
	fi

	# ========================================================
	# PHASE 5: TITLE CASE EACH SEGMENT
	# ========================================================
	# Split on underscores and capitalize each word
	#
	echo "$cleaned" | awk -F'_' '{
		for (i=1; i<=NF; i++) {
			# Uppercase first letter, lowercase rest
			$i = toupper(substr($i,1,1)) tolower(substr($i,2))
		}
		OFS="_"
		print
	}'
}

    # ------------------------------------------------------------------
    # SEASON INPUT
    # ------------------------------------------------------------------
    read -p " = = > Enter Season Number (e.g. 1): " SEASON
    [[ -z "$SEASON" ]] && { echo "Canceled."; return 1; }

    printf -v SEASON_PAD "%02d" "$SEASON"

    # ------------------------------------------------------------------
    # START EPISODE NUMBER
    # ------------------------------------------------------------------
    read -p " = = > Starting Episode Number (default 1): " EP_NUM
    EP_NUM=${EP_NUM:-1}

    printf -v EP_PAD "%02d" "$EP_NUM"

    echo
    echo -e "${YELLOW} = = > Enter Episode Titles One Per Line.${NC}"
    echo -e "${YELLOW} = = > Press ENTER On Empty Line To Finish.${NC}"
    echo

    while true; do

        read -p "Title For S${SEASON_PAD}E${EP_PAD}: " TITLE_RAW

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
# - Final outputs such as SUTURED_, BARFIX_, SUBPACKED_, and REKEY_ are only
#   removed in their own dedicated actions with confirmation.
#
run_finalize_menu() {


	show_space_overview() {
		local cwd wd_size oem_size drive_display
		local free total free_color free_gb

		cwd="$(pwd)"
		drive_display="$(get_drive_display "$cwd")"
        cwd_display="$(trim_working_path_display "$cwd" 3)"

		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}        SPACE OVERVIEW / WORKING CONTEXT         ${NC}"
		echo -e "${CYAN}================================================${NC}"

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
        echo -e "${YELLOW} = = >  ^ Free Space${NC}"

		wd_size="$(get_folder_size_human ".")"
		echo -e "${CYAN} = = > Working Dir Size:${NC} ${YELLOW}$wd_size${NC}"

		oem_size="$(get_folder_size_human "./oem")"
		echo -e "${CYAN} = = > OEM Folder Size:${NC} ${YELLOW}$oem_size${NC}"

		echo
	}

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
			_gapman_tmp
			_gapman_preview
			_factory_tmp
			_factory_work
			_hb_temp
			_norm_tmp
			_rekey_tmp
			*.log
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
	echo -e "${YELLOW} = = > OEM Material Is Handled Through The Integrated SUTURED Finalizer.${NC}"
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

		if is_factory_exit_token "$(read -r reply; echo "$reply")"; then
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

		echo -ne "${YELLOW} = = > Remove Template Artifacts And intro_template Directory? (y/n | 0.=cancel): ${NC}"
		read -r reply
		reply="${reply//[[:space:]]/}"

		if is_factory_exit_token "$reply"; then
			echo -e "${YELLOW} = = > Cancelled.${NC}"
			echo
			return 0
		fi

		case "${reply,,}" in
			y|yes)
				cleanup_remove_targets "${targets[@]}"
				;;
			*)
				echo -e "${YELLOW} = = > Template Cleanup Cancelled.${NC}"
				echo
				;;
		esac

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
#   but ONLY after parity checks and SUTURED promotion have
#   completed successfully.
#
# HOUSE RULE:
#   OEM remains safety material until finalize is truly done.
# =========================================================
cleanup_execute_oem_finalize_choice() {
	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}       EXECUTING SAVED OEM FINALIZE CHOICE      ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo

	case "${OEM_FINALIZE_CHOICE:-leave}" in
		archive)
			echo -e "${YELLOW} = = > Executing OEM Choice: Archive OEM Material${NC}"
			echo
			cleanup_archive_oem_material
			;;
		leave)
			echo -e "${YELLOW} = = > Executing OEM Choice: Leave OEM Material Alone${NC}"
			echo
			;;
		dump)
			echo -e "${YELLOW} = = > Executing OEM Choice: Delete OEM Contents, Then Mark Folder Finished${NC}"
			echo
			cleanup_delete_oem_contents
			cleanup_mark_oem_folder_finished
			;;
		mark)
			echo -e "${YELLOW} = = > Executing OEM Choice: Mark OEM Folder Finished, But Keep Contents${NC}"
			echo
			cleanup_mark_oem_folder_finished
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

        echo -ne "${YELLOW} = = > Remove Detection-Map / CSV Style Artifacts? (y/n | 0.=cancel): ${NC}"
        read -r reply
        reply="${reply//[[:space:]]/}"

        if is_factory_exit_token "$reply"; then
        	echo -e "${YELLOW} = = > Cancelled.${NC}"
        	echo
        	return 0
        fi

        case "${reply,,}" in
        	y|yes)
				cleanup_remove_targets "${targets[@]}"
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
		echo " = = >  - finished SUTURED outputs"
		echo

		read -r -p " = = > Run Safe Cleanup Pass Now? (y/n): " reply
        echo -e "${NC}"
		case "${reply,,}" in
			y|yes) ;;
			*)
				echo -e "${YELLOW} = = > Safe Cleanup Pass Cancelled.${NC}"
				pause
				return 0
				;;
		esac

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

	cleanup_collect_sutured_targets() {
		shopt -s nullglob nocaseglob
		local -a sutured=(SUTURED_*.mkv)
		shopt -u nullglob nocaseglob

		local f
		for f in "${sutured[@]}"; do
			[[ -f "$f" ]] || continue
			printf '%s\n' "$f"
		done
	}

	cleanup_final_name_from_sutured() {
		local file="$1"
		local custom_prefix="${2:-}"
		local rest

		rest="${file#SUTURED_}"

		if [[ -n "$custom_prefix" ]]; then
			printf '%s\n' "${custom_prefix}${rest}"
		else
			printf '%s\n' "$rest"
		fi
	}

	cleanup_collect_replaceable_originals() {
		local custom_prefix="${1:-}"
		local -a sutured_targets=()
		local s final_name

		mapfile -t sutured_targets < <(cleanup_collect_sutured_targets)

		for s in "${sutured_targets[@]}"; do
			final_name="$(cleanup_final_name_from_sutured "$s" "$custom_prefix")"
			[[ -f "$final_name" ]] || continue
			printf '%s\n' "$final_name"
		done
	}

	cleanup_mark_oem_folder_finished() {
		local target="Factory_WuZ_Here"

		if [[ ! -d "./oem" ]]; then
			return 0
		fi

		if [[ -e "./$target" ]]; then
			echo -e "${YELLOW} = = > OEM Finished Folder Name Already Exists:${NC} $target"
			echo -e "${YELLOW} = = > Leaving ./oem Name Unchanged To Avoid Collision.${NC}"
			echo
			return 0
		fi

		if mv -- "./oem" "./$target"; then
			echo -e "${GR} = = > OEM Folder Marked Finished As:${NC} $target"
		else
			echo -e "${REB} = = > Failed To Rename OEM Folder To:${NC} $target"
		fi

		echo
	}

# =========================================================
# MARKER: FINALIZE OEM PARITY GUARD (SUTURED -> OEM)
# =========================================================
# PURPOSE:
#   Before destructive finalize steps, verify that every
#   finished SUTURED target still has its matching OEM backup.
#
# WHY THIS EXISTS:
#   Count-only parity is not strong enough here.
#   We do NOT merely care that "the numbers look right" —
#   we care that EACH finalized episode still has its own
#   recoverable OEM counterpart by base filename.
#
# SAFETY MODEL:
#   For every:
#       SUTURED_Episode_Name.mkv
#   require:
#       OEM_Episode_Name.mkv
#
# RESULT:
#   - PASS: finalize may continue
#   - FAIL: finalize must stop before destructive actions
#
# HOUSE RULE:
#   Feedback is king.
#   If parity fails, show exactly what is missing.
# =========================================================
# =========================================================
# MARKER: FINALIZE OEM PARITY GUARD (SUTURED -> OEM)
# =========================================================
# PURPOSE:
#   Before destructive finalize steps, verify that every
#   finished SUTURED target still has its matching OEM backup.
#
# WHY THIS EXISTS:
#   Count-only parity is not strong enough here.
#   We do NOT merely care that "the numbers look right" —
#   we care that EACH finalized episode still has its own
#   recoverable OEM counterpart by base filename.
#
# SAFETY MODEL:
#   For every:
#       SUTURED_Episode_Name.mkv
#   require:
#       ./oem/OEM_Episode_Name.mkv
#
# IMPORTANT:
#   OEM backups in this script live in:
#       ./oem/
#   with filename pattern:
#       oem_<original_filename>
#
# RESULT:
#   - PASS: finalize may continue
#   - FAIL: finalize must stop before destructive actions
#
# HOUSE RULE:
#   Feedback is king.
#   If parity fails, show exactly what is missing.
# =========================================================
cleanup_verify_oem_parity_for_sutured_targets() {
	local -a sutured_targets=()
	local -a missing_oem=()
	local sutured_file base_name expected_oem

	mapfile -t sutured_targets < <(cleanup_collect_sutured_targets)

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}       FINALIZE :: OEM PARITY SAFETY CHECK      ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > Verifying That Every Finished SUTURED File Has A Matching OEM Backup...${NC}"
	echo

	if (( ${#sutured_targets[@]} == 0 )); then
		echo -e "${YELLOW} = = > No SUTURED Targets Found. Nothing To Verify.${NC}"
		echo
		return 1
	fi

	echo -e "${CYAN} = = > OEM Folder Present:${NC} $([[ -d ./oem ]] && echo YES || echo NO)"
	echo

	for sutured_file in "${sutured_targets[@]}"; do
		[[ -f "$sutured_file" ]] || continue

		base_name="${sutured_file#SUTURED_}"
		expected_oem="./oem/OEM_${base_name}"

		echo -e "${CYAN} = = > SUTURED Target:${NC} $sutured_file"
		echo -e "${CYAN} = = > Expected OEM:${NC} $expected_oem"

		if [[ -f "$expected_oem" ]]; then
			echo -e "${GREEN} = = > OEM Match Found.${NC}"
		else
			echo -e "${REB} = = > OEM Match Missing.${NC}"
			missing_oem+=("$expected_oem")
		fi
		echo
	done

	echo -e "${CYAN} = = > Finished SUTURED Targets:${NC} ${#sutured_targets[@]}"
	echo -e "${CYAN} = = > Missing OEM Counterparts:${NC} ${#missing_oem[@]}"
	echo

	if (( ${#missing_oem[@]} == 0 )); then
		echo -e "${GREEN} = = > OEM Parity Check: PASS${NC}"
		echo -e "${GREEN} = = > Every Finished SUTURED File Has A Matching OEM Backup In ./oem.${NC}"
		echo
		return 0
	fi

	echo -e "${REB} = = > OEM Parity Check: FAIL${NC}"
	echo -e "${RED} = = > Missing OEM Counterparts Were Found.${NC}"
	echo
	cleanup_print_targets "Missing OEM Backup(s)" "${missing_oem[@]}"
	echo

	return 1
}

cleanup_archive_oem_folder() {
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

	if [[ ! -d "./oem" ]]; then
		echo -e "${YE} = = > OEM Folder Not Present. Nothing To Archive.${NC}"
		echo
		return 0
	fi

	# ----- COLLECT CSV FILES ---------------------------------
	# Glob is safe; if none exist, array will be empty
	csv_files=( *.csv )

	# ----- COLLECT TEMPLATE FILES FROM INTRO MAP -------------
	# Only include files that actually exist
	while IFS= read -r t; do
		[[ -f "$t" ]] && map_templates+=("$t")
	done < <(get_templates_from_intro_map "$INTRO_MAP")

	# ----- BUILD ARCHIVE NAME --------------------------------
	stamp="$(date +%Y%m%d_%H%M%S)"
	tar_name="oem_archive_${stamp}.tar.gz"

	echo -e "${CYAN} = = > Creating OEM Archive:${NC} $tar_name"

	# ========================================================
	# LONG-RUN OPERATION
	# Use run_with_progress wrapper instead of calling tar directly
	# ========================================================
	if run_with_progress "Archiving OEM Folder..." \
		tar -czf "$tar_name" \
			oem/ \
			"${csv_files[@]}" \
			"${map_templates[@]}"; then

		echo -e "${GR} = = > OEM Archive Created:${NC} $tar_name"
	else
		echo -e "${REB} = = > OEM Archive FAILED:${NC} $tar_name"
	fi

	echo
}

	cleanup_delete_oem_contents() {
		local reply

		if [[ ! -d "./oem" ]]; then
			echo -e "${YE} = = > OEM Folder Not Present. Nothing To Delete.${NC}"
			echo
			return 0
		fi

		read -r -p " = = > Delete OEM Folder Contents Only? (y/n): " reply
		case "${reply,,}" in
			y|yes) ;;
			*)
				echo -e "${YE} = = > OEM Content Deletion Cancelled.${NC}"
				echo
				return 0
				;;
		esac

		find "./oem" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} + 2>/dev/null || true

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
cleanup_handle_oem_material() {
	local reply

	OEM_FINALIZE_CHOICE="leave"

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}          OEM MATERIAL FINALIZE OPTIONS         ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo "     1) Archive OEM Material"
	echo "     2) Leave OEM Material Alone"
	echo "     3) Delete OEM Contents Only, Then Mark Folder Finished"
	echo "     4) Mark OEM Folder Finished, But Keep Contents"
	echo
	read -r -p "     Choice: " reply
	echo

	reply="${reply//[[:space:]]/}"

	# ========================================================
	# TEN-KEY EXIT HOOK
	# ========================================================
	if is_factory_exit_token "$reply"; then
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
			echo -e "${GREEN} = = > No Working-Dir Originals Conflict With Final SUTURED Names.${NC}"
			echo
			return 0
		fi

		echo -e "${YELLOW} = = > The Following Working-Dir Originals Must Move Out Of The Way${NC}"
		echo -e "${YELLOW} = = > Before Finished SUTURED Files Can Become Their Final Names:${NC}"
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

	cleanup_promote_sutured_outputs() {
		local custom_prefix="${1:-}"
		local -a sutured_targets=()
		local s final_name
		local renamed=0
		local failed=0

		mapfile -t sutured_targets < <(cleanup_collect_sutured_targets)

		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}         PROMOTE SUTURED OUTPUTS TO FINAL       ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo

		if (( ${#sutured_targets[@]} == 0 )); then
			echo -e "${YELLOW} = = > No SUTURED Files Found.${NC}"
			echo
			return 1
		fi

		echo -e "${CYAN} = = > Planned Renames:${NC}"
		for s in "${sutured_targets[@]}"; do
			final_name="$(cleanup_final_name_from_sutured "$s" "$custom_prefix")"
			echo -e "  ${GREEN}${s}${NC}  ->  ${YELLOW}${final_name}${NC}"
		done
		echo

		for s in "${sutured_targets[@]}"; do
			final_name="$(cleanup_final_name_from_sutured "$s" "$custom_prefix")"

			if [[ "$s" == "$final_name" ]]; then
				echo -e "${YE} = = > [SKIP SAME NAME]${NC} $s"
				continue
			fi

			if [[ -e "$final_name" ]]; then
				echo -e "${REB} = = > [NAME COLLISION]${NC} $final_name"
				((failed+=1)) || :
				continue
			fi

			if mv -- "$s" "$final_name"; then
				echo -e "${GR} = = > [PROMOTED]${NC} $final_name"
				((renamed+=1)) || :
			else
				echo -e "${REB} = = > [FAILED RENAME]${NC} $s"
				((failed+=1)) || :
			fi
		done

		echo
		echo -e "${CYAN} = = > Promoted:${NC} $renamed"
		echo -e "${CYAN} = = > Failures:${NC} $failed"
		echo

		if (( failed > 0 )); then
			return 1
		fi

		return 0
	}

cleanup_finalize_sutured_replacements() {
	local rename_mode custom_prefix=""
	local delete_ok=0
	local -a _tmp_sutured_check=()

	clear
	show_space_overview

	echo -e "${CYAN}================================================${NC}"
	echo -e "${CYAN}      FINALIZE FINISHED SUTURED REPLACEMENTS    ${NC}"
	echo -e "${CYAN}================================================${NC}"
	echo
	echo -e "${YELLOW} = = > This Finalizer Treats SUTURED Files As The Goal.${NC}"
	echo -e "${YELLOW} = = > OEM Material Is Backup/Archive Material.${NC}"
	echo -e "${YELLOW} = = > Working-Dir Originals May Be Deleted Only By Confirmation.${NC}"
	echo

	mapfile -t _tmp_sutured_check < <(cleanup_collect_sutured_targets)
	if (( ${#_tmp_sutured_check[@]} == 0 )); then
		echo -e "${YELLOW} = = > No SUTURED Files Found. Nothing To Finalize.${NC}"
		echo
		pause
		return 0
	fi
	unset _tmp_sutured_check

	echo -e "${YELLOW}"
	echo -e "${CYAN} = = > Rename Mode For Finished SUTURED Outputs:${NC}"
	echo "     1) Remove SUTURED_ Prefix Entirely"
	echo "     2) Replace SUTURED_ With My Custom Prefix"
	echo
	read -r -p "     Choice: " reply
	echo -e "${NC}"
	echo

	reply="${reply//[[:space:]]/}"

	# ========================================================
	# TEN-KEY EXIT HOOK
	# ========================================================
	if is_factory_exit_token "$reply"; then
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
	if ! cleanup_handle_oem_material; then
		pause
		return 0
	fi

	# --------------------------------------------------------
	# SAFETY GUARD:
	# Before destructive finalize steps, verify that every
	# finished SUTURED target still has its matching OEM backup.
	# --------------------------------------------------------
	if ! cleanup_verify_oem_parity_for_sutured_targets; then
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

	if cleanup_promote_sutured_outputs "$custom_prefix"; then

		# --------------------------------------------------------
		# OEM DISPOSITION HAPPENS ONLY AFTER SUCCESSFUL PROMOTE
		# --------------------------------------------------------
		cleanup_execute_oem_finalize_choice

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
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}                    CLEANUP                     ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}"
		echo "     1) Show Cleanup Status"
		echo "     2) Remove Temp / Junk Files"
		echo "     3) Remove Working Template Artifacts (intro_template/*)"
		echo "     4) Remove PILOT_SUTURED_* Outputs"
		echo "     5) Remove Detection Map / CSV Artifacts"
		echo "     6) Finalize Finished SUTURED Replacements"
		echo "     7) Safe Cleanup Pass"
		echo "     8) Archive CSV + Referenced Templates Only"
		echo
		echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
		echo

		read -r -p "     Choice: " cleanup_choice
		echo -e "${NC}"
		cleanup_choice="${cleanup_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$cleanup_choice"; then
    	    return 0
        fi

		case "$cleanup_choice" in
			1)
				cleanup_show_status
				;;
			2)
				cleanup_temp_junk
				;;
			3)
				cleanup_templates
				;;
            4)
            	echo -e "${YELLOW} = = > Removing Pilot Outputs...${NC}"
            	shopt -s nullglob
            	for f in PILOT_SUTURED_*.mkv; do
            		rm -f -- "$f"
            		echo -e "${GREEN} = = > Removed:${NC} $f"
            	done
            	shopt -u nullglob
            	;;
			5)
				cleanup_detection_maps
				;;
			6)
				cleanup_finalize_sutured_replacements
				;;
			7)
				cleanup_run_all_safe
				;;
            8)
            	echo -e "${CYAN} = = > Building CSV + Template Archive...${NC}"

            	tarname="csv_templates_$(date +%Y%m%d_%H%M%S).tar.gz"

            	csv_files=( *.csv )

            	map_templates=()
            	while IFS= read -r t; do
            		[[ -f "$t" ]] && map_templates+=("$t")
            	done < <(get_templates_from_intro_map "$INTRO_MAP")

            	tar -czf "$tarname" \
            		"${csv_files[@]}" \
            		"${map_templates[@]}"

            	echo -e "${GREEN} = = > Created: $tarname${NC}"
				pause
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
	            THE_FACTORY :: NOTES / EXPLAIN
	================================================

	[SECTION 1 — OVERVIEW]
	- THIS SPACE IS INTENTIONALLY RESERVED FOR LONG-FORM NOTES.
	- USE IT TO DOCUMENT WORKFLOW DECISIONS, GOTCHAS, AND PATTERNS.

	[SECTION 2 — WORKFLOW REMINDERS]
	- INSPECT → PREPARE → DETECT/TEMPLATE → GAPMAN → TITLEZ → CLEANUP
	- PREFER REKEY WHEN KEYFRAMES ARE POOR.

	[SECTION 3 — COMMON PITFALLS]
	- COPY-CUT ON BAD KEYFRAMES = TEARING.
	- MIXED SOURCES (OEM + REKEY) CAN CAUSE MISMATCH BEHAVIOR.
	- TEMPLATES MUST MATCH EPISODE STRUCTURE.

	==== PILOT RUN (STRONGLY RECOMMENDED) REASONS

	BEFORE PROCESSING AN ENTIRE SEASON, RUN GAPMAN ON 2–3 EPISODES FIRST.

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
	- IS IT STILL PRESENT AFTER GAPMAN?

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

	# =========================
	# #MARKER: INSPECT GROUP COLOR + STATUS
	# =========================
	# COLOR / STATUS RULE:
	# - 0 items  -> GREEN  / CLEAN
	# - 1-2 items -> YELLOW / NOTICE
	# - 3+ items -> RED    / BUSY
	#
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

	ui_show_folder_state_snapshot
	echo
	pause
}

inspect_show_file_groups() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}           INSPECT :: FILE GROUPS               ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo

    # NOTE:
    # - OEM_ files are preserved originals / backups.
    # - REKEY_ files are normalized cut-friendly rebuilds.
    # - SUTURED_ files are GAPMAN outputs.
    # - BARFIX_ files are title/playback remux outputs.
    #
    shopt -s nullglob nocaseglob
    local -a all_videos=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
    local -a oem_files=(OEM_*)
    local -a rekey_files=(REKEY_*.mkv)
    local -a sutured_files=(SUTURED_*.mkv)
    local -a barfix_files=(BARFIX_*.mkv)
    local -a subpacked_files=(SUBPACKED_*)
    shopt -u nullglob nocaseglob

    # Build a "plain working targets" view:
    # - Files that are not obvious generated derivatives.
    # - This helps the user see likely source candidates at a glance.
    local -a plain_targets=()
    local f
    for f in "${all_videos[@]}"; do
        [[ "$f" =~ ^OEM_ ]] && continue
        [[ "$f" =~ ^REKEY_ ]] && continue
        [[ "$f" =~ ^(SUTURED_|PILOT_SUTURED_) ]] && continue
        [[ "$f" =~ ^BARFIX_ ]] && continue
        [[ "$f" =~ ^SUBPACKED_ ]] && continue
        [[ "$f" == intro_template* ]] && continue
        [[ "$f" == custom_cut* ]] && continue
        plain_targets+=("$f")
    done

    inspect_print_group "Likely source / working targets" "${plain_targets[@]}"
    inspect_print_group "OEM backups" "${oem_files[@]}"
    inspect_print_group "REKEY normalized files" "${rekey_files[@]}"
    inspect_print_group "SUTURED outputs" "${sutured_files[@]}"
    inspect_print_group "BARFIX outputs" "${barfix_files[@]}"
    inspect_print_group "SUBPACKED outputs" "${subpacked_files[@]}"

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
        echo -e "${CYAN} = = > ${INTRO_MAP} Preview:${NC}"
        head -n 10 "$INTRO_MAP" 2>/dev/null || true
        echo
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
    local -a probe_files=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
    shopt -u nullglob nocaseglob

    if ((${#probe_files[@]}==0)); then
        echo -e "${RE} = = > No Video Files Found.${NC}"
        pause
        return 0
    fi

	echo -e "${CYAN} = = > KEYFRAME SUITABILITY CHECK${NC}"
    echo -e "${CYAN} = = > Select File For Analysis:${NC}"
	local probe_target verdict pick

	while true; do
		echo
		echo -e "${CYAN} = = > Select File:${NC} ${YELLOW}[number | q=cancel]${NC}"
		echo

		select probe_target in "${probe_files[@]}"; do
			pick="${REPLY//[[:space:]]/}"
            # ========================================================
            # TEN-KEY EXIT HOOK
            # ========================================================
            if is_factory_exit_token "$pick"; then
            	return 0
            fi

			if [[ "$pick" == "q" || "$pick" == "Q" || "$pick" == "0" ]]; then
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
    probe_keyframe_suitability "$probe_target"
    echo
    verdict="$(get_keyframe_verdict "$probe_target" 2>/dev/null || true)"
    local verdict_color
    case "$verdict" in
    	SAFE) verdict_color=$GR ;;
    	CAUTION) verdict_color=$YE ;;
    	RISKY) verdict_color=$RE ;;
    	*) verdict_color=$NC ;;
    esac

    echo -e "${CYAN} = = > Cut-Friendliness Verdict:${NC} ${verdict_color}${verdict:-UNKNOWN}${NC}"

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
        echo "     4) Keyframe Cut-Friendliness Probe"
        echo "     5) Working Notes/Explain Current Workflow State"
        echo "     6) Help File, Stuff To Read, Best Practices"
        echo
        echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
        echo

        read -r -p "     Choice: " inspect_choice
        echo -e "${NC}"
        inspect_choice="${inspect_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$inspect_choice"; then
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
                inspect_run_keyframe_probe
                ;;
            5)
                clear
                echo -e "${CYAN}================================================${NC}"
                echo -e "${CYAN}     INSPECT :: CURRENT WORKFLOW EXPLANATION    ${NC}"
                echo -e "${CYAN}================================================${NC}"
                echo
                echo " = = > Current broad state:"
                echo " = = >  - Main menu is the live workflow entrypoint."
                echo " = = >  - Detection submenu bridges into the legacy intro engine."
                echo " = = >  - Template builder accepts normalized time input."
                echo " = = >  - GAPMAN manual entry accepts normalized time input."
                echo " = = >  - REKEY preference logic is active."
                echo
                echo " = = > Typical workflow:"
                echo " = = >  - Inspect folder state"
                echo " = = >  - Prepare / normalize sources as needed"
                echo " = = >  - Build template or detect intros"
                echo " = = >  - Run GAPMAN"
                echo " = = >  - Apply title / subtitle / playback tools"
                echo " = = >  - Cleanup / finalize"
                echo
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
#   SUTURED_, SUBPACKED_, templates, and existing OEM_ files.
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
    # - SUTURED_ outputs
    # - BARFIX_ outputs
    # - SUBPACKED_ outputs
    # - intro_template artifacts
    #
    shopt -s nullglob nocaseglob
    local -a files=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
    shopt -u nullglob nocaseglob

    local f
    for f in "${files[@]}"; do
        [[ "$f" =~ ^OEM_ ]] && continue
        [[ "$f" =~ ^REKEY_ ]] && continue
        [[ "$f" =~ ^(SUTURED_|PILOT_SUTURED_) ]] && continue
        [[ "$f" =~ ^BARFIX_ ]] && continue
        [[ "$f" =~ ^SUBPACKED_ ]] && continue
        [[ "$f" == intro_template* ]] && continue
        [[ "$f" == custom_cut* ]] && continue
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
    printf ' - %s\n' "${targets[@]}"
    echo
    echo -e "${CYAN} = = > Count:${NC} ${#targets[@]}"
    echo
    pause
}

prepare_make_oem_backups() {
    # =========================
    # #MARKER: OEM BACKUP PREP
    # =========================
    # PURPOSE:
    # - Create preserved copies of current source-style files
    # - Store them inside ./oem/
    # - Prefix each preserved copy with OEM_
    #
    # RESULT EXAMPLE:
    #   source file in working dir:
    #       ./Episode01.mkv
    #
    #   preserved OEM copy:
    #       ./oem/OEM_Episode01.mkv
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
    # - OEM preserved copies must live in ./oem/
    # - Create that directory before the copy pass begins
    #
    mkdir -p oem

    echo -e "${YELLOW}This Creates Preserved Sidecar Copies In ./oem As OEM_<filename>.${NC}"
    echo -e "${YELLOW}Existing OEM_ Copies In ./oem Are Skipped, Not Overwritten.${NC}"
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
    # - Copy each eligible source into ./oem/
    # - Add OEM_ prefix while preserving original working file
    #
    for f in "${targets[@]}"; do
        backup="oem/OEM_$(basename "$f")"

        if [[ -e "$backup" ]]; then
            echo -e "${YELLOW} = = > [SKIP]${NC} $backup Already Exists"
            ((skip_count+=1)) || :
            continue
        fi

        # cp -a preserves timestamps/mode where possible and avoids altering
        # the original source content.
        if cp -a -- "$f" "$backup"; then
            echo -e "${GR} = = > [OK]${NC} $f -> $backup"
            ((made_count+=1)) || :
        else
            echo -e "${REB} = = > [FAIL]${NC} $f"
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
    echo

    echo -e "${CYAN} = = > Current Prefer_Rekey State:${NC} ${prefer_rekey:-0}"
    echo
    echo -e "${YELLOW}"
    echo "     1) Enable REKEY Preference For This Shell Session"
    echo "     2) Disable REKEY Preference For This Shell Session"
    echo "     3) Use Guided Normalize-First Prompt"
    echo "     4) Do All-Over REKEY Auth System Refresh"
    echo
    echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
    echo

    read -r -p "     Choice: " pref_choice
    echo -e "${NC}"
    pref_choice="${pref_choice//[[:space:]]/}"

    # ========================================================
    # TEN-KEY EXIT HOOK
    # ========================================================
    if is_factory_exit_token "$pref_choice"; then
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
            echo -e "${YELLOW} REKEY Preference disabled For This Shell Session.${NC}"
            echo -e "${CYAN} Original Source Files Remain The Preferred Working Source.${NC}"
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
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}      PREPARE SOURCES :: BATCH NORMALIZER       ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${CYAN} This Rebuilds Eligible Source Videos Into REKEY_*.mkv Outputs.${NC}"
    echo -e "${YEB} = = > Be Mindful Of Free Space Before Starting.${NC}"
    echo -e "${YEB} = = > This Will Double Folder Space.${NC}"
    echo
    pause
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

    read -r -p " = = > Run Combined Prep Pass Now? (y/n): " combo_reply
    echo -e "${NC}"
    case "${combo_reply,,}" in
        y|yes) ;;
        *)
            echo -e "${YELLOW} = = > Combined Prep Pass Cancelled.${NC}"
            pause
            return 0
            ;;
    esac

    prepare_make_oem_backups
    prepare_run_batch_normalizer_wrapper
    prepare_offer_delete_originals_after_verified_rekey

    prefer_rekey="1"

    clear
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}        COMBINED PREP PASS CORE STEPS DONE      ${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo
    echo -e "${CYAN}REKEY Preference Is Now Enabled For This Shell Session.${NC}"
    echo
    read -r -p "Open BARFIX now? (y/n): " barfix_reply
    case "${barfix_reply,,}" in
        y|yes)
            run_barfix
            ;;
        *)
            ;;
    esac
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
        echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
        echo

        read -r -p "     Choice: " prep_choice
        echo -e "${NC}"
        prep_choice="${prep_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$prep_choice"; then
    	    return 0
        fi

        case "$prep_choice" in
            1)
                prepare_show_candidates
                ;;
            2)
                prepare_make_oem_backups
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
        echo "     1) Subtitlez"
        echo "     2) BAR / File Bar-Title / File-Name + Playback Tools"
        echo
        echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
        echo

        read -r -p "     Choice: " ts_choice
        echo -e "${NC}"
        ts_choice="${ts_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$ts_choice"; then
    	    return 0
        fi

        case "$ts_choice" in
            1)
                run_subtitlez_menu
                ;;
            2)
                run_title_playback_menu
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
        echo "     2) Pack external.srt"
        echo "     3) Extract Internal Subtitles"
        echo
        echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
        echo

        read -r -p "     Choice: " subtitle_choice
        echo -e "${NC}"
        subtitle_choice="${subtitle_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$subtitle_choice"; then
    	    return 0
        fi

        case "$subtitle_choice" in
            1)
                run_subtox
                ;;
            2)
                run_subtox_pack
                ;;
            3)
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
        echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
        echo

        read -r -p "     Choice: " title_choice
        echo -e "${NC}"
        title_choice="${title_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$title_choice"; then
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

# =========================
# #MARKER: SUBTOX PACK / EXTRACT / RENAME WRAPPERS
# =========================
# PURPOSE:
# - Keep Titlez / Subtitlez Submenu Wording Clear And User-Facing.
# - Reuse The Existing SUBTOX Engine For The Real Work.
# - Provide Guided Handoff Instead Of Dead-End Placeholder Banners.
#
# IMPORTANT:
# - These Wrappers Do NOT Implement Separate Engines Yet.
# - They Intentionally Explain Which SUBTOX Mission Currently Owns The Work.
# - This Keeps Menu Structure Clean Without Pretending The Split Already Exists.
#
run_subtox_pack() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}           PACK EXTERNAL .SRT SUBTITLES         ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${YELLOW} = = > Current Implementation Still Lives Inside SUBTOX.${NC}"
    echo -e "${CYAN} = = > Use SUBTOX Mission 2 For External Subtitle Packing.${NC}"
    echo
    read -r -p " = = > Open SUBTOX Now? (y/n): " open_subtox
    case "${open_subtox,,}" in
        y|yes)
            run_subtox
            ;;
        *)
            ;;
    esac
}

run_subtox_extract() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}          EXTRACT INTERNAL SUBTITLE STREAMS      ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${YELLOW} = = > Current Implementation Still Lives Inside SUBTOX.${NC}"
    echo -e "${CYAN} = = > Use SUBTOX Mission 3 For External Subtitle Packing.${NC}"
    echo
    read -r -p " = = > Open SUBTOX Now? (y/n): " open_subtox
    case "${open_subtox,,}" in
        y|yes)
            run_subtox
            ;;
        *)
            ;;
    esac
}

run_subtox_rename() {
    clear
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}             RENAME / DETOX FILE TOOLS          ${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo
    echo -e "${YELLOW} = = > Current Implementation Still Lives Inside SUBTOX.${NC}"
    echo -e "${CYAN} = = > Use SUBTOX Mission 1 For Rename / Detox Operations.${NC}"
    echo
    read -r -p " = = > Open SUBTOX Now? (y/n): " open_subtox
    case "${open_subtox,,}" in
        y|yes)
            run_subtox
            ;;
        *)
            ;;
    esac
}


# =========================
# #MARKER: GAPMAN WORKFLOW MENU
# =========================
# PURPOSE:
# - Put GAPMAN-Related Actions Under One Workflow Stage
# - Keep Batch Cutting And Clip-Joining In The Same Surgery Area
# - Preserve Existing GAPMAN Engine While Adding A Simple Join Tool
#
run_gapman_menu() {
    while true; do
        clear
        echo -e "${CYAN}================================================${NC}"
        echo -e "${CYAN}                 RUN GAPMAN                     ${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     1) Pilot Run On 2–3 Files"
        echo "     2) Full Batch From intro_map.csv"
        echo "     3) Manual Map-Assisted Cuts"
        echo "     4) Global Trim / Pad Controls"
        echo "     5) Join Two Clips Into One Episode"
        echo
        echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
        echo

        read -r -p "     Choice: " gapman_choice
        echo -e "${NC}"
        gapman_choice="${gapman_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$gapman_choice"; then
    	    return 0
        fi

        case "$gapman_choice" in
			1)
				echo
				echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
				echo -e "${CYAN} = = > GAPMAN PILOT RUN (STRONGLY RECOMMENDED)${NC}"
				echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
				echo
				echo -e "${YELLOW}Purpose:${NC}"
				echo -e "  Validate intro timing, trim accuracy, and seam quality"
				echo -e "  before committing to a full batch run."
				echo
				echo -e "${YELLOW}Why Pilot Run Matters:${NC}"
				echo -e "  • Confirms intro alignment is correct"
				echo -e "  • Verifies pre-trim and post-trim timing"
				echo -e "  • Detects drift or padding issues early"
				echo -e "  • Prevents full-batch mistakes"
				echo
				echo -e "${YELLOW}What This Will Do:${NC}"
				echo -e "  • Select 3 sample episodes from intro_map.csv"
				echo -e "  • Run GAPMAN using those entries only"
				echo -e "  • Output files as PILOT_SUTURED_*"
				echo -e "  • Pause for inspection before continuing"
				echo

				echo -e "${CYAN} = = > Tip:${NC} Review results carefully before full run."
				echo -e "${CYAN} = = > You may adjust pre/post trim values if needed."
				echo

				echo -e "${CYAN} = = > Optional: Inspect Show Notes (timing references)${NC}"
				#inspect_show_notes || true
				echo

				read -p " = = > Press ENTER to prepare pilot run..."

				# ========================================================
				# BACKUP ORIGINAL MAP
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

					prompt_normalize_first_workflow
                    PILOT_MODE=1
					run_gapman

					echo
					echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
					echo -e "${CYAN} = = > PILOT RUN COMPLETE${NC}"
					echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
					echo

					echo -e "${YELLOW}Review:${NC}"
					echo -e "  Inspect PILOT_SUTURED_* outputs"
					echo -e "  Confirm Timing And Seam Quality"
					echo

					echo "  1) Proceed To FULL Run"
					echo "  2) Re-Run pilot (Same 3 Files)"
					echo "  3) Re-Run pilot (New Random 3)"
					echo "  4) Cancel And Restore"

					read -p " = = > Choose: " pilot_choice

					case "$pilot_choice" in
						1)
							echo -e "${GREEN} = = > Proceeding To Full Run...${NC}"

							rm -f "$PILOT_MAP"
							mv "$BACKUP_MAP" "$ORIG_MAP"
        					echo -e "${CYAN} = = > Backup Restored To Your Original Named >${NC} ${GREEN}intro_map.csv${NC}"

							PILOT_MODE=0
							run_gapman
							break
							;;

                        2)
                        	echo -e "${CYAN} = = > Re-running Pilot (same set)...${NC}"
                        	remove_all_pilot_outputs "$PILOT_MAP"
                        	;;

						3)
							echo -e "${CYAN} = = > Generating New Pilot Set...${NC}"

							# ========================================================
							# NEW RANDOM 3:
							# - Pilot outputs are disposable test artifacts.
							# - Before building a fresh random pilot set, clear ALL
							#   prior PILOT_SUTURED_* outputs so old leftovers do
							#   not clutter the folder or confuse rerun behavior.
							# ========================================================
							remove_all_pilot_outputs

							head -n 1 "$BACKUP_MAP" > "$PILOT_MAP"

							if command -v shuf >/dev/null 2>&1; then
								tail -n +2 "$BACKUP_MAP" | shuf | head -n 3 >> "$PILOT_MAP"
							else
								tail -n +2 "$BACKUP_MAP" | head -n 3 >> "$PILOT_MAP"
							fi
							;;

						*)
							echo -e "${YELLOW} = = > Pilot Cancelled. Restoring original map...${NC}"

							rm -f "$PILOT_MAP"
							mv "$BACKUP_MAP" "$ORIG_MAP"
                        	remove_all_pilot_outputs "$PILOT_MAP"
        					echo -e "${YELLOW} = = > Backup Restored To Your Original Named >${NC} ${GREEN}intro_map.csv${NC}"
							break
							;;
					esac
				done
				;;
            2)
                prompt_normalize_first_workflow # reserved for future rusty
                PILOT_MODE=0
                run_gapman
                ;;
            3)
                prompt_normalize_first_workflow # reserved for future rusty
                run_gapman
                ;;
            4)
                prompt_normalize_first_workflow # reserved for future rusty
                run_gapman
                ;;
            5)
                run_join_two_clips
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
    join_sources=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
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
# - Join Two Clips Remains In GAPMAN
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
	sources=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
	shopt -u nullglob nocaseglob

	local -a filtered=()
	local f
	for f in "${sources[@]}"; do
		[[ "$f" =~ ^REKEY_ ]] && continue
		[[ "$f" =~ ^(SUTURED_|PILOT_SUTURED_) ]] && continue
		[[ "$f" =~ ^BARFIX_ ]] && continue
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
			if is_factory_exit_token "$pick"; then
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

run_clip_join_triage_menu() {
	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}        TRIAGE CENTER / CLIP SURGERY TOOLS      ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}"
		echo "     1) Clip_Grab BitZ From VidZ"
		echo "     2) Join Two Clips Into One Episode"
		echo "     3) One-File Normalize To MKV / Playback Defaults"
		echo "     4) Rebuild / Normalize Sources To REKEY"
		echo "     5) BARFIX Title + Playback Tools"
		echo
		echo "     0.)Return  (or q)  =  Quit"
		echo
		echo -e "${CYAN} = = > If Your Clip Grabs And Joins Aren't Becoming To You${NC}"
		echo -e "${CYAN}= = = = = = = = = = = = = = = = = = = = = = = = = = = = = ${NC}"
		echo -e "${CYAN} = = > Then You Should Be Coming To Us${NC}"
		echo -e "${CYAN}= = = = = = = = = = = = = = = = = = = = = = = = = = = = = ${NC}"
		echo

		read -r -p "     Choice: " triage_choice
		echo -e "${NC}"
		triage_choice="${triage_choice//[[:space:]]/}"

		# ========================================================
		# TEN-KEY EXIT HOOK
		# ========================================================
		if is_factory_exit_token "$triage_choice"; then
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
				run_one_file_normalize_to_mkv_tool
				;;
			4)
				run_rebuild_rekey_handoff_tool
				;;
			5)
				run_barfix
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
#   Prepare Sources, GAPMAN, or BARFIX's other homes.
#
run_utility_menu() {
	while true; do
		clear
		echo -e "${CYAN}================================================${NC}"
		echo -e "${CYAN}         UTILITY / ADVANCED TOOLS               ${NC}"
		echo -e "${CYAN}================================================${NC}"
		echo
		echo -e "${YELLOW}"
		echo "     1) Show Templates"
		echo "     2) Show Target Files"
		echo "     3) Diff Two Files"
		echo "     4) REKEY Validity Check"
		echo "     5) Keyframe Cut-Friendliness Check"
		echo "     6) Triage Center / Clip Surgery Tools"
		echo "     7) Inspect Dependency Status"
		echo "     8) Twisted Color / Theme Engine"
		echo
		echo "     0.)Return  (or q)  =  Quit"
		echo

		read -r -p "     Choice: " util_choice
		echo -e "${NC}"
		util_choice="${util_choice//[[:space:]]/}"

		# ========================================================
		# TEN-KEY EXIT HOOK
		# ========================================================
		if is_factory_exit_token "$util_choice"; then
			return 0
		fi

		case "$util_choice" in
			1)
				echo
				echo -e "${CYAN} = = > Templates:${NC}"
				shopt -s nullglob
				local -a t
				if [[ -d intro_template ]]; then
					t=(intro_template/intro_template*.mkv)
				else
					t=(intro_template*.mkv)
				fi
				shopt -u nullglob
				if ((${#t[@]}==0)); then
					echo -e "${RE} = = > None Found.${NC}"
				else
					printf " - %s\n" "${t[@]}"
				fi
				pause
				;;
			2)
				echo
				echo -e "${CYAN} = = > Video Targets In Current Folder:${NC}"
				shopt -s nullglob nocaseglob
				local -a v=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
				shopt -u nullglob nocaseglob
				if ((${#v[@]}==0)); then
					echo -e "${RE} = = > None Found.${NC}"
				else
					printf " - %s\n" "${v[@]}"
				fi
				pause
				;;
			3)
				echo
				echo -e "${CYAN} = = > Select File A:${NC}"
				shopt -s nullglob nocaseglob
				local -a diff_files=(*.{sh,txt,csv,srt,mkv,mp4,avi,mov})
				shopt -u nullglob nocaseglob

				if ((${#diff_files[@]}<2)); then
					echo -e "${RE} = = > Need At Least 2 Diffable Files.${NC}"
					pause
					continue
				fi

				local a="" b=""
				select a in "${diff_files[@]}"; do
					[[ -n "${a:-}" ]] && break
				done

				echo
				echo -e "${CYAN} = = > Select File B:${NC}"
				select b in "${diff_files[@]}"; do
					[[ -n "${b:-}" ]] && break
				done

				echo
				echo -e "${CYAN}================ DIFF ================${NC}"
				diff -u -- "$a" "$b" || true
				echo
				pause
				;;
			4)
				run_rekey_validity_check
				;;
			5)
				run_keyframe_suitability_check
				;;
			6)
				run_clip_join_triage_menu
				;;
			7)
				inspect_dependencies
				;;
		    8)
    			run_twisted_menu
    			;;
			*)
				echo -e "${REB} = = > Invalid.${NC}"
				pause
				;;
		esac
	done
}

normalize_to_mkv() {
    file="$1"

    ext="${file##*.}"
    base="${file%.*}"

    # NOTE: Ext Compare Should Be Case-Insensitive To Avoid "MKV" Edge Cases.
    if [[ "${ext,,}" != "mkv" ]]; then
        echo -e "${CYAN} = = > Converting $file → ${base}.mkv${NC}"

        # ============================================================
        # #MARKER: NORMALIZE PLAYBACK DEFAULTS
        # ============================================================
        # GOAL:
        # - Prefer English Audio Track If Available
        # - Disable Subtitles By Default
        # - Keep Operation Lossless (Stream Copy Only)
        #
        # LOGIC:
        # - First English Audio Stream Gets Default Disposition
        # - All Subtitle Streams Explicitly Set To Non-Default
        #
        # NOTE:
        # - Does NOT Remove Subtitles, Only Disables Auto-Display
        # - Safe For Later SUBTOX Operations (Pre-GAPMAN)
        #
        ffmpeg -hide_banner -loglevel error -nostdin -y \
            -i "$file" \
            -map 0 \
            -c copy \
            -disposition:a:0 default \
            -disposition:s 0 \
            -metadata:s:a:0 language=eng \
            "${base}.mkv"

        echo "${base}.mkv"
    else
        # ============================================================
        # #MARKER: MKV IN-PLACE NORMALIZATION (LIGHT TOUCH)
        # ============================================================
        # Even If Already MKV, We May Still Want To Enforce:
        # - English Audio Default
        # - Subtitles Off
        #
        # NOTE:
        # - Uses Mkvpropedit If Available (Fast, No Remux)
        # - Falls Back To No-Op If Unavailable (Preserve Behavior)
        #
        if command -v mkvpropedit >/dev/null 2>&1; then
            echo -e "${CYAN} = = > Applying Playback Defaults (In-Place): $file${NC}" >&2

            # Set First Audio Track As Default And English
            mkvpropedit "$file" \
                --edit track:a1 --set flag-default=1 \
                --edit track:a1 --set language=eng \
                >/dev/null 2>&1 || true

            # Disable All Subtitle Tracks As Default
            # NOTE: mkvpropedit Cannot Bulk-Edit Easily; Best-Effort Only
            mkvpropedit "$file" \
                --edit track:s1 --set flag-default=0 \
                >/dev/null 2>&1 || true
        fi

        echo "$file"
    fi
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
    file="$1"

    interval=$(keyframe_interval "$file")
    interval=${interval:-999}

    echo -e "${YELLOW} = = > Keyframe interval: ${interval}s${NC}" >&2

    if (( $(echo "$interval <= 1.0" | bc -l) )); then
        echo -e "${GREEN} = = > High Precision Detected. Rebuild Skipped.${NC}" >&2
        echo "$file"
        return
    fi

    echo -e "${CYAN} = = > Rebuilding To 1-sec GOP Precision...${NC}" >&2

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

    if ffmpeg -y -i "$file" \
        -c:v libx264 -preset medium \
        -g "$fps_calc" -keyint_min "$fps_calc" \
        -sc_threshold 0 \
        -c:a copy "$out"; then

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
	read -r -p " = = > Open Rebuild / REKEY Path Now? (y/n): " rekey_handoff
	case "${rekey_handoff,,}" in
		y|yes)
			prepare_run_batch_normalizer_wrapper
			;;
		*)
			;;
	esac
}

# end of do over all reyey auth =======================================================================

already_processed() {
    if grep -q "^$1," "$INTRO_MAP" 2>/dev/null; then
        return 0
    else
        return 1
    fi
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
      echo -e "${RE} = = > Large Keyframe Gaps Detected. Copy-Based Cuts May Tear Or Suture Poorly.${NC}"
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

	if is_factory_exit_token "$choice"; then
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
	# ACTUAL ENGINE CALL (THIS IS WHAT STILL EXISTS)
	# ========================================================
	probe_keyframe_suitability "$selected" || true

	local verdict
	verdict="$(get_keyframe_verdict "$selected" 2>/dev/null || true)"
	verdict="${verdict:-UNKNOWN}"

	local verdict_color="$NC"
	case "$verdict" in
		SAFE) verdict_color="$GR" ;;
		CAUTION) verdict_color="$YE" ;;
		RISKY) verdict_color="$RE" ;;
	esac

	echo
	echo -e "${CYAN} = = > Final Verdict:${NC} ${verdict_color}${verdict}${NC}"
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

#  TEMPLATE BUILDER

create_template() {
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
	# - SUTURED_        : GAPMAN Outputs
	# - BARFIX_         : BARFIX Remux Outputs
	# - intro_template* : Template Assets, Not Source Episodes
	#
	echo -e "${CYAN}=============== Template Builder ===============${NC}"
	echo
	echo -e "${CYAN} = = > Select Source Episode For Intro Template:${NC}"

	shopt -s nullglob nocaseglob
	local -a template_sources=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
	shopt -u nullglob nocaseglob

	local -a filtered_sources=()
	local f
	for f in "${template_sources[@]}"; do
		[[ "$f" =~ ^REKEY_ ]] && continue
		[[ "$f" =~ ^(SUTURED_|PILOT_SUTURED_) ]] && continue
		[[ "$f" =~ ^BARFIX_ ]] && continue
		[[ "$f" =~ ^intro_template ]] && continue
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
    	echo -e "${CYAN} = = > Select File:${NC} ${YELLOW}[number | q=cancel]${NC}"
    	echo

    	select src in "${filtered_sources[@]}"; do
    		pick="${REPLY//[[:space:]]/}"
            # ========================================================
            # TEN-KEY EXIT HOOK
            # ========================================================
            if is_factory_exit_token "$pick"; then
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
        RISKY) verdict_color="$RE" ;;
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

    if [[ "$src_verdict" == "RISKY" || "$src_verdict" == "CAUTION" ]]; then
        echo
        read -p " = = > Source May Be Poor For Precise Cuts. Build Cut-Friendly Rebuilt Source First? (y/n, default: n): " rebuild_src
        rebuild_src=${rebuild_src:-n}

        if [[ "$rebuild_src" == "y" ]]; then
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
	    read -p " Start: " start_raw
	    read -p " End: " end_raw
	    echo

	    start="$(to_seconds "$start_raw")"
	    end="$(to_seconds "$end_raw")"

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

    # ====================================================================
    # #MARKER: TEMPLATE TEMP WORKDIR (LOCAL + SAFE)
    # ====================================================================
    # WHY:
    # - GAPMAN Defines TMPDIR, But Template Builder Does NOT.
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
      -map 0:v:0 -map 0:a? \
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
}

# End Of TEMPLATE BUILDER intro_template.mkv

# =========================================================
# MARKER: RUN WITH PROGRESS (GENERIC LONG-RUN WRAPPER)
# =========================================================
# PURPOSE:LONG-RUN COMMAND PROGRESS HELPER
# - Show Visible Life-Sign Output During Long-Running File Operations.
#   Wrap a long-running command and provide a visible heartbeat
# - Prevent The Script From Looking Frozen During Quiet Ffmpeg Work.
#   so the user knows the system is alive and working. we dont need a ctrl-c right now
#
# DESIGN GOALS:
# - Runs The Target Command In Background.
# - Prints A Simple Heartbeat Until The Command Exits.
# - Returns The Original Command's Exit Code Unchanged.
#   - Non-intrusive (does NOT interfere with command output)
#   - Works with ANY command (generic wrapper)
#   - Provides:
#       • task label (repeated)
#       • animated spinner (visual movement)
#       • elapsed time (confidence indicator)
# USAGE:
#   run_with_progress "Label Here..." command arg1 arg2 ...
#
# EXAMPLE:
#   run_with_progress "Building OEM Archive..." tar -czf archive.tar ./oem
#
# NOTES:
#   - Best used for QUIET long-running commands (tar, scans, batch ops)
#   - Avoid wrapping commands that already emit live progress (ffmpeg w/ stats)
#   - Output is sent to STDERR so it does not pollute pipelines
# IMPORTANT:
# - All Progress Text Goes To STDERR.
# - This Keeps STDOUT Clean For Functions That Are Used Inside:
#     var="$(some_function)"
# - In Those Cases, STDOUT Must Remain Reserved For The True Return Value
#   (Such As A File Path), While Progress Still Remains Visible On Screen.
#
# HOUSE RULE:
#   Feedback is king — user should NEVER wonder if the script is stuck.
# =========================================================
run_with_progress() {
	local label="$1"
	shift

	# --------------------------------------------------------
	# INITIAL USER FEEDBACK (one-time banner line)
	# --------------------------------------------------------
	echo -e "${CYAN} = = > ${label}${NC}" >&2

	# --------------------------------------------------------
	# LAUNCH COMMAND IN BACKGROUND
	# --------------------------------------------------------
	"$@" &
	local cmd_pid=$!

	# --------------------------------------------------------
	# TRACKING / VISUAL ELEMENTS
	# --------------------------------------------------------
	local cmd_status=0
	local start_ts now elapsed
	local spin='|/-\'        # classic spinner frames
	local i=0
	local frame

	start_ts=$(date +%s)

	# --------------------------------------------------------
	# HEARTBEAT LOOP
	# Runs until command exits
	# --------------------------------------------------------
	while kill -0 "$cmd_pid" 2>/dev/null; do
		now=$(date +%s)
		elapsed=$((now - start_ts))

		# rotate spinner frame
		frame="${spin:i%${#spin}:1}"

		# ----------------------------------------------------
		# LIVE STATUS LINE (overwrites itself via carriage return)
		# ----------------------------------------------------
		echo -ne "${YELLOW} = = > ${label} ${frame}    ....WORKING-PLEASE-STAND-BY....    [${elapsed}s]${NC}\r" >&2

		sleep 1
		((i++))
	done

	# --------------------------------------------------------
	# CAPTURE EXIT STATUS
	# --------------------------------------------------------
	wait "$cmd_pid"
	cmd_status=$?

	# --------------------------------------------------------
	# CLEAN LINE (erase spinner line after completion)
	# --------------------------------------------------------
	echo -ne "                                                                                                                    \r" >&2

	# --------------------------------------------------------
	# RETURN ORIGINAL COMMAND STATUS
	# --------------------------------------------------------
	return "$cmd_status"
}

# =========================
# #MARKER: BATCH NORMALIZER SINGLE-FILE WORKER
# =========================
# PURPOSE:
# - Normalize One Source File Into A Cut-Friendly REKEY_ Output Using The
#   Same Known-Good Recipe Used By Template Builder Rebuilds.
#
# WHY THIS EXISTS:
# - Template Builder Rebuild Helper Is Interactive-Context Oriented.
# - Batch Mode Needs A Dedicated Worker That Can Be Launched In Background
#   Jobs Safely And Repeatedly Across Many Files.
#
# DESIGN RULE:
# - Keep Quality/Settings FIXED.
# - Throttle By Number Of Simultaneous Files, NOT By Lowering Encode Quality.

normalize_cut_friendly_file() {
	local in="$1"
	local out fps fps_calc

	out="REKEY_$(basename "${in%.*}").mkv"

	# Skip only if existing rebuilt file is actually valid/readable.
	if is_valid_video_file "$out"; then
		echo -e "${YELLOW} = = > Skip Existing Rebuilt File:${NC} $out"
		return 0
	fi

	# If a stale/corrupt partial file exists, remove it before rebuilding.
	if [[ -f "$out" ]]; then
		echo -e "${YELLOW} = = > Existing Rebuilt File Is Invalid. Removing Stale File:${NC} $out"
		rm -f "$out"
	fi

	# Read source frame rate so GOP stays approximately 1 second
	fps=$(ffprobe -v error -select_streams v:0 \
		-show_entries stream=r_frame_rate \
		-of default=noprint_wrappers=1:nokey=1 "$in" 2>/dev/null)

	fps_calc=$(echo "$fps" | awk -F'/' '{if ($2>0) printf "%.0f", $1/$2}')
	[[ -z "$fps_calc" ]] && fps_calc=24

	echo -e "${CYAN} = = > Normalizing:${NC} $in"
	echo -e "${CYAN} = = > Output:${NC} $out"
	echo -e "${CYAN} = = > GOP target:${NC} ~1 second (${fps_calc} frames)${NC}"

	if ffmpeg -hide_banner -loglevel error -nostdin -y -i "$in" \
		-c:v libx264 -preset medium -crf 18 \
		-g "$fps_calc" -keyint_min "$fps_calc" \
		-sc_threshold 0 \
		-c:a aac -b:a 256k -ac 2 -ar 48000 \
		"$out"; then

		echo -e "${GR} = = > Normalized OK:${NC} $out"
		return 0
	else
		echo -e "${REB} = = > Normalize FAILED:${NC} $in"
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
    # - SUTURED_ : GAPMAN outputs
    # - BARFIX_  : BARFIX remux outputs
    #
    clear
    echo -e "${CYAN} = = >...............Custom Cut----------------${NC}"
    echo
    echo -e "${CYAN} = = > Select source file for one-off clip cut:${NC}"

    shopt -s nullglob nocaseglob
    local -a custom_sources=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
    shopt -u nullglob nocaseglob

    local -a filtered_sources=()
    local f
    for f in "${custom_sources[@]}"; do
        [[ "$f" =~ ^REKEY_ ]] && continue
        [[ "$f" =~ ^(SUTURED_|PILOT_SUTURED_) ]] && continue
        [[ "$f" =~ ^BARFIX_ ]] && continue
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
            if is_factory_exit_token "$pick"; then
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
        read -p " Start: " start_raw
        read -p " End: " end_raw
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
      -map 0:v:0 -map 0:a? \
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
restore_oem_prefix() {
    # =========================
    # #MARKER: OEM RESTORE HEADER
    # =========================
    # PURPOSE:
    # - Undo OEM source staging
    # - Move files out of ./oem/ back into the working directory
    # - Strip the leading OEM_ prefix during the move
    #
    # RESULT EXAMPLE:
    #   before:
    #       ./oem/OEM_Episode01.mkv
    #
    #   after:
    #       ./Episode01.mkv
    #
    # IMPORTANT:
    # - This is a MOVE back to working dir, not an in-place rename
    # - If target name already exists in working dir, skip safely
    # - If ./oem becomes empty, rename it to a done-flag folder
    #
    clear
    echo -e "${CYAN} = = > Restore OEM_ Files From /oem${NC}"
    echo

    # =========================
    # #MARKER: OEM RESTORE PRECHECKS
    # =========================
    # PURPOSE:
    # - Verify ./oem exists
    # - Collect only files beginning with OEM_
    #
    if [[ ! -d "oem" ]]; then
        echo -e "${YELLOW} = = > No ./oem Directory Found.${NC}"
        pause
        return 0
    fi

    shopt -s nullglob
    local -a oem_files=(oem/OEM_*)
    shopt -u nullglob

    if [[ ${#oem_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW} = = > No OEM_ Files Found In ./oem.${NC}"
        echo

        # =========================
        # #MARKER: OEM EMPTY DIR DONE FLAG (NO FILES FOUND)
        # =========================
        # PURPOSE:
        # - If ./oem exists but is already empty, convert it into a
        #   visible "done" marker folder instead of deleting it.
        #
        shopt -s nullglob dotglob
        local oem_contents_empty_check=(oem/*)
        shopt -u nullglob dotglob

        if (( ${#oem_contents_empty_check[@]} == 0 )); then
            local done_dir_empty="done wow"
            local idx_empty=0
            local candidate_empty="$done_dir_empty"

            while [[ -e "$candidate_empty" ]]; do
                ((idx_empty+=1)) || :
                candidate_empty="${done_dir_empty}_${idx_empty}"
            done

            mv -- oem "$candidate_empty"
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
    for f in "${oem_files[@]}"; do
        base="$(basename "$f")"
        new_name="${base#OEM_}"
        echo "$f  ->  ./$new_name"
    done

    echo
    read -p " = = > Proceed With Restore? (y/n): " confirm
    confirm="${confirm:-n}"

    if [[ "$confirm" != "y" ]]; then
        echo -e "${YELLOW} = = > OEM Restore Cancelled.${NC}"
        pause
        return 0
    fi

    # =========================
    # #MARKER: OEM RESTORE MOVE LOOP
    # =========================
    # PURPOSE:
    # - Move each OEM_ file from ./oem/ back to working dir
    # - Strip OEM_ prefix
    # - Skip if destination already exists
    #
    echo
    echo -e "${CYAN} = = > Restoring Files...${NC}"

    local moved=0
    local skipped=0

    for f in "${oem_files[@]}"; do
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
    # - If ./oem is now empty after restore, rename it instead of deleting it
    # - This acts as a visible "done with this working dir" flag
    #
    if [[ -d "oem" ]]; then
        shopt -s nullglob dotglob
        local oem_contents=(oem/*)
        shopt -u nullglob dotglob

        if (( ${#oem_contents[@]} == 0 )); then
            local done_dir="done wow"
            local idx=0
            local candidate="$done_dir"

            # Avoid clobbering an existing done-flag folder
            while [[ -e "$candidate" ]]; do
                ((idx+=1)) || :
                candidate="${done_dir}_${idx}"
            done

            mv -- oem "$candidate"
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
#   So Later Template Builder / GAPMAN Work Can Happen On Cut-Friendly Sources.
#
# IMPORTANT:
# - This Mode Is NON-DESTRUCTIVE.
# - Originals Are NOT Deleted, Renamed, Or Modified.
# - This Means Disk Usage Can Grow Significantly During Processing.
#
# DISK SPACE REALITY:
# - REKEY Pass Alone Can Nearly Double Folder Usage.
# - If SUTURED Outputs Are Later Created Too, Total Working Size Can Approach
#   Triple The Original Folder Footprint.
#
# LOAD CONTROL:
# - Light  = 1 File At A Time
# - Medium = 3 Files At A Time
# - Thrash = User-Chosen Concurrent Job Count
#

run_batch_normalizer() {

	local load_mode max_jobs custom_jobs
	local -a norm_sources
	local total idx f active_jobs success_count fail_count skip_count

	clear
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${CYAN}      BATCH NORMALIZER :: CUT-FRIENDLY REKEY BUILDER      ${NC}"
	echo -e "${CYAN}==========================================================${NC}"
	echo
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${YELLOW}WARNING: Originals Are Kept Untouched And Outputs Are Added Beside Them.${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${YELLOW}WARNING: Folder Size WILL DOUBLE During Normalization.= = = = = = = = = ${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${YELLOW}WARNING: If You Later Also Create SUTURED Outputs, WORKING SIZE WILL= = ${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${YELLOW}WARNING: TRIPLE THE ORIGINAL FOLDER SIZE. = = = = = = = = = = = = = = = ${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${REB}WARNING: = = = = = = = > Check Your Disk Space WARNING = = = = = = = = = = ${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${CYAN} = = > This Step Is Intended To Make Later Cuts Clean And Reliable.     ${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${CYAN} = = > Tight 1 Second KeyFrameZ Make For Accurtate CutZ.----------------${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${CYAN} = = > If Your Here Twice Thats OK, It Will Skip All Already Done And---${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo -e "${CYAN} = = > Still Set The Flag For Rekey Favorability During This Session----${NC}"
    echo -e "${CYAN}------------------------------------------------------------------------${NC}"
	echo

    echo -e "${YELLOW}"
	if ! ask_yes_no " = = > Continue Into Source Scan? (y/n): "; then
		echo -e "${YELLOW} = = > Batch Normalizer Canceled.${NC}"
		pause
		return 0
	fi
    echo -e "${NC}"

	# =========================
	# #MARKER: BATCH NORMALIZER TARGET DISCOVERY
	# =========================
	# Only Include Likely OEM/Source Files.
	# Hide Internal/Generated Products So The Job Cannot Recurse Into Its Own
	# Outputs Or Into Unrelated Helper Assets.
	#
	shopt -s nullglob nocaseglob
	local -a all_norm_candidates=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
	shopt -u nullglob nocaseglob

	norm_sources=()
	for f in "${all_norm_candidates[@]}"; do
		[[ "$f" =~ ^OEM_ ]] && continue
		[[ "$f" =~ ^REKEY_ ]] && continue
		[[ "$f" =~ ^(SUTURED_|PILOT_SUTURED_) ]] && continue
		[[ "$f" =~ ^BARFIX_ ]] && continue
		[[ "$f" =~ ^intro_template ]] && continue
		norm_sources+=("$f")
	done

	total=${#norm_sources[@]}
	if [[ "$total" -eq 0 ]]; then
		echo -e "${RE} = = > No Eligible Source Files Found For Normalization.${NC}"
		pause
		return 1
	fi

	echo
	echo -e "${CYAN} = = > Eligible Source Files:${NC} $total"
	for f in "${norm_sources[@]}"; do
		echo " - $f"
	done
	echo

	# =========================
	# #MARKER: BATCH NORMALIZER LOAD MENU
	# =========================
	# WHY:
	# - Numeric Menu Is Easier And Less Error-Prone Than Typing Words.
	# - Keep The User Choice Simple And Predictable.
	#
	# LOAD TIERS:
	# 1 = LIGHT   = 1 Concurrent File
	# 2 = MEDIUM  = 3 Concurrent Files
	# 3 = THRASH  = User-Chosen Concurrent File Count
	#
    echo -e "${YELLOW}"
	echo -e "${CYAN} = = > Select Load Level:${NC}"
	echo -e "${GR} = = > 1) Light   (1 File At A Time)${NC}"
	echo -e "${YE} = = > 2) Medium  (3 Files At A Time)${NC}"
	echo -e "${REB} = = > 3) Thrash  (Default ALL Or Choose Concurrent File Count)${NC}"
	echo

    echo -e "${YELLOW}"
	read -p " = = > Load Level [1/2/3] (Default: 2): " load_choice
    echo -e "${NC}"
	load_choice=${load_choice:-2}

	case "$load_choice" in
		1)
			load_mode="light"
			max_jobs=1
			;;
		2)
			load_mode="medium"
			max_jobs=3
			;;
		3)
			load_mode="thrash"

			# =========================
			# #MARKER: THRASH DEFAULT = ALL FILES
			# =========================
			# WHY:
			# - Thrash Mode Is Intended To Push The Machine As Hard As Possible.
			# - Default Behavior Should Therefore Use ALL Eligible Files Concurrently.
			#
			# DESIGN:
			# - Total = Number Of Eligible Source Files Already Discovered
			# - If User Presses Enter, Use Total
			# - User Can Still Override With A Smaller Number If Desired
			#
			read -p " = = > Max Concurrent Rebuild Jobs? (Default: ALL = $total): " custom_jobs
			custom_jobs=${custom_jobs:-$total}

			if ! [[ "$custom_jobs" =~ ^[0-9]+$ ]] || [[ "$custom_jobs" -lt 1 ]]; then
				echo -e "${YELLOW} = = > Invalid Thrash Job Count. Falling Back To ALL (${total}).${NC}"
				custom_jobs="$total"
			fi

			max_jobs="$custom_jobs"
			;;
		*)
			echo -e "${YELLOW} = = > Invalid Selection. Falling Back To Medium (3 Jobs).${NC}"
			load_mode="medium"
			max_jobs=3
			;;
	esac

	echo
	echo -e "${CYAN} = = > Selected Load Mode:${NC} $load_mode"
	echo -e "${CYAN} = = > Concurrent Jobs:${NC} $max_jobs"
	echo

    echo -e "${YELLOW}"
	if ! ask_yes_no " = = > Start Batch Normalization Now? (y/n): "; then
		echo -e "${YELLOW} = = > Batch Normalizer Canceled.${NC}"
		pause
		return 0
	fi
    echo -e "${NC}"

	echo
	echo -e "${CYAN} = = > Starting Batch Normalization...${NC}"

	success_count=0
	fail_count=0
	skip_count=0

	# =========================
	# #MARKER: BATCH NORMALIZER CONCURRENCY LOOP
	# =========================
	# Jobs Are Launched In The Background Up To The Selected Cap.
	# We Then Wait Until At Least One Slot Opens Before Launching More.
	#
	for ((idx=0; idx<total; idx++)); do
		f="${norm_sources[$idx]}"

		if [[ -f "REKEY_$(basename "${f%.*}").mkv" ]]; then
			echo -e "${YELLOW} = = > [SKIP $((idx+1)) / $total]${NC} Matching REKEY Already Exists For: $f"
			((skip_count+=1)) || :
			continue
		fi

		echo -e "${MAGENTA} = = > [$((idx+1)) / $total] Queueing:${NC} $f"

		(
			if normalize_cut_friendly_file "$f"; then
				exit 0
			else
				exit 1
			fi
		) &

		# =========================
		# #MARKER: BATCH NORMALIZER ACTIVE JOB INDICATOR
		# =========================
		# WHY:
		# - Ffmpeg Is Intentionally Quiet In This Script, So Concurrent Jobs Can
		#   Look Deceptively Serial In The Terminal Output.
		# - Show Current Active Background Normalize Jobs So The User Can Confirm
		#   That Light/Medium/Thrash Load Control Is Actually Working.
		#
		# NOTE:
		# - This Is Informational Only.
		# - It Does Not Change Scheduling Behavior.
		#
		active_jobs=$(jobs -rp | wc -l)
		echo -e "${CYAN} = = > Active Normalize Jobs:${NC} $active_jobs / $max_jobs"

		while true; do
			active_jobs=$(jobs -rp | wc -l)
			[[ "$active_jobs" -lt "$max_jobs" ]] && break
			sleep 1
		done
	done

	# Wait for all background jobs and count outcomes
	for job_pid in $(jobs -p); do
		if wait "$job_pid"; then
			((success_count+=1)) || :
		else
			((fail_count+=1)) || :
		fi
	done

	echo
	echo -e "${CYAN}==========================================================${NC}"
	echo -e "${GREEN} = = > Batch Normalization Pass Complete.${NC}"
	echo -e "${CYAN} = = > Successful New REKEY Files:${NC} $success_count"
	echo -e "${CYAN} = = > Skipped Existing REKEY Files:${NC} $skip_count"
	echo -e "${CYAN} = = > Failed Normalizations:${NC} $fail_count"
	echo -e "${CYAN} = = > Outputs:${NC} REKEY_*.mkv"
	echo -e "${CYAN}==========================================================${NC}"

	pause
	return 0
}

# ==============================================================================
# --- FUNCTION 7: GAPMAN (RED) ---
# ==============================================================================
run_gapman() {

# ==============================================================================
#  GAPMAN v2 :: SURGERY STAGE / INTRO REMOVAL / TRIM / JOIN HANDOFF AREA
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
#       * Processed Filenames Are Renamed SUTURED_<Original>
#   - Non-Destructive Output Philosophy
#       * Original Working Files Are Not Modified In-Place Here
#   - Stream-Copy Or Clean-Cut Focus
#       * No Seam Reencode In This GAPMAN Path
#
#  CLIP-GRAB / JOIN RELATIONSHIP:
#   - GAPMAN Menu Now Serves As The Shared Surgery Area For:
#       * Batch Episode Cutting
#       * Clip Grab / Bit Harvest / Join-Two-Clips Style Work
#   - In Other Words:
#       * GAPMAN = Episode Surgery Stage
#       * Clip-Grab / Clip-Join = Specialty Surgery Tools In The Same Zone
#
#  intro_map.csv NOTES:
#   - Machine-Safe Timing Still Lives In Numeric start/end Seconds
#   - Human-Readable start_hms/end_hms May Also Be Present For Eyeballs
#   - GAPMAN Logic Continues Trusting Numeric Seconds, Not The Display Columns
#
#  PRACTICAL NOTES:
#   - Best Accuracy Still Comes From Well-Prepared Sources <<<<<<<<<<<<<<<<<<<
#   - Pilot A Few Episodes First Before Full-Batch Surgery
#   - If Behavior Is Consistent, Fix With Offset / Pad / Trim Before Reaching
#     For More Templates
#   - This Path Produces SUTURED_ Outputs Intended To Become Final Replacements
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
DEFAULT_SUTURE_PREFIX="SUTURED_"
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
echo -e "${MAGENTA}   GAPMAN v2 :: Normalized Pipeline = = = =     ${NC}"
echo -e "${MAGENTA}================================================${NC}"
echo

#read -p " = = > Map CSV File? (Default: ${DEFAULT_MAP}): " MAP_FILE
MAP_FILE=${MAP_FILE:-$DEFAULT_MAP}

read -p " = = > Global offset seconds to apply to intro START (+/-) (Default: ${DEFAULT_GLOBAL_OFFSET}): " GLOBAL_OFFSET
GLOBAL_OFFSET=${GLOBAL_OFFSET:-$DEFAULT_GLOBAL_OFFSET}

read -p " = = > Pad intro START seconds (+/-) After Map/Manual (Default: ${DEFAULT_PAD_START}): " PAD_START
PAD_START=${PAD_START:-$DEFAULT_PAD_START}

read -p " = = > Pad intro END seconds (+/-) After Map/Manual (Default: ${DEFAULT_PAD_END}): " PAD_END
PAD_END=${PAD_END:-$DEFAULT_PAD_END}

read -p " = = > Global PRE-trim seconds (Remove From Beginning) (Default: ${DEFAULT_PRE_TRIM}): " PRE_TRIM
PRE_TRIM=${PRE_TRIM:-$DEFAULT_PRE_TRIM}

read -p " = = > Global POST-trim seconds (Remove From End) (Default: ${DEFAULT_POST_TRIM}): " POST_TRIM
POST_TRIM=${POST_TRIM:-$DEFAULT_POST_TRIM}

GLOBAL_OFFSET="$(num_norm "$GLOBAL_OFFSET")"
PAD_START="$(num_norm "$PAD_START")"
PAD_END="$(num_norm "$PAD_END")"
PRE_TRIM="$(num_norm "$PRE_TRIM")"
POST_TRIM="$(num_norm "$POST_TRIM")"

echo
echo -e "${CYAN} = = > Title Bar Repair ---${NC}"
read -p " = = > Start Title At Which Underscore Segment? (1-based, Default: ${DEFAULT_TITLE_SEGMENT}): " TITLE_SEGMENT
TITLE_SEGMENT=${TITLE_SEGMENT:-$DEFAULT_TITLE_SEGMENT}

# commented out during development for speedy 
#read -p " = = > Run Keyframe Suitability Check? (y/n, Default: n): " KF_CHECK
KF_CHECK=${KF_CHECK:-n}
# commented out during development for speedy 
#read -p " = = > Wipe Metadata? (y/n, Default: ${DEFAULT_WIPE_META}) [y Wipes All Tags; n Keeps Most] : " WIPE_META
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
  # GAPMAN should target original episode identities, then optionally switch
  # to a validated REKEY working source internally.
  FILTERED=()
  for f in "${FILES[@]}"; do
    [[ "$f" =~ ^${DEFAULT_SUTURE_PREFIX} ]] && continue
    [[ "$f" =~ ^PILOT_${DEFAULT_SUTURE_PREFIX} ]] && continue
    [[ "$f" =~ ^REKEY_ ]] && continue
    [[ "$f" =~ ^BARFIX_ ]] && continue
    [[ "$f" =~ ^intro_template ]] && continue
    FILTERED+=("$f")
  done
  FILES=("${FILTERED[@]}")
fi

TOTAL=${#FILES[@]}
if [[ "$TOTAL" -eq 0 ]]; then
  echo -e "${RE} = = > No Targets Found In This Folder / Map.${NC}"
  exit 1
fi

# =========================
# #MARKER: HELPERS
# =========================

safe_out_name() {
  local in="$1"

  # ========================================================
  # PILOT MODE SAFETY:
  # - Pilot runs must NEVER collide with real full-batch outputs.
  # - If PILOT_MODE=1, force a distinct output prefix.
  # - Otherwise use the normal GAPMAN default prefix.
  # ========================================================
  if [[ "${PILOT_MODE:-0}" == "1" ]]; then
    echo "PILOT_${DEFAULT_SUTURE_PREFIX}${in%.*}.mkv"
  else
    echo "${DEFAULT_SUTURE_PREFIX}${in%.*}.mkv"
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
fadd() { echo "scale=3; ($1)+($2)" | bc; }
fsub() { echo "scale=3; ($1)-($2)" | bc; }
fmax0() { echo "scale=3; if(($1)<0) 0 else ($1)" | bc; }

# =========================
# #MARKER: KEYFRAME FILE SELECTOR
# =========================
select_keyframe_probe_target() {
  local i choice

  echo -e "${CYAN} = = > Keyframe Probe Target Selection ====${NC}"
  for ((i=0; i<${#FILES[@]}; i++)); do
    echo "  $((i+1))) ${FILES[$i]}"
  done
  echo

  read -p " = = > Probe Which File Number? (blank = skip): " choice

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
TMPDIR="_gapman_tmp_v2"

cleanup() { rm -rf "$TMPDIR"; }

on_abort() {
	echo -e "\n${REB} = = > ABORTED. Cleaning Temp...${NC}"

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
	# - orphaned PILOT_SUTURED_* outputs cluttering workspace
	#
	# DESIGN DECISION (NON-INTERACTIVE):
	# - Abort paths must be fast, deterministic, and safe
	# - No user prompts allowed here (signal context)
	#
	# ACTIONS TAKEN:
	# - Restore original intro_map.csv if backup exists
	# - Remove ALL PILOT_SUTURED_* outputs
	# - Proceed with normal temp cleanup
	#
	# NOTE:
	# - This ONLY triggers when PILOT_MODE=1
	# - Normal GAPMAN runs are unaffected
	# ========================================================
	if [[ "${PILOT_MODE:-0}" == "1" ]]; then
		echo -e "${YELLOW} = = > Pilot Abort Detected. Restoring State...${NC}"

		# Restore intro_map.csv from backup if present
		if [[ -f "GOOD_intro_map.csv" ]]; then
			rm -f -- "intro_map.csv"
			mv -f -- "GOOD_intro_map.csv" "intro_map.csv"
			echo -e "${GREEN} = = > Restored:${NC} intro_map.csv"
		else
			echo -e "${YELLOW} = = > No GOOD_intro_map.csv Found (Nothing To Restore).${NC}"
		fi

		# Remove ALL pilot outputs (no prompt)
		remove_all_pilot_outputs
	fi

	# Always clean temp workspace
	cleanup
	exit 1
}

trap on_abort SIGINT SIGTERM


	remove_all_pilot_outputs() {
		local found=0

		echo -e "${CYAN} = = > Removing All Existing PILOT_SUTURED_* Outputs...${NC}"

		shopt -s nullglob
		for f in PILOT_SUTURED_*; do
			[[ -e "$f" ]] || continue
			rm -f -- "$f"
			echo -e "${GREEN} = = > Removed:${NC} $f"
			found=1
		done
		shopt -u nullglob

		if [[ "$found" -eq 0 ]]; then
			echo -e "${YELLOW} = = > No Existing PILOT_SUTURED_* Outputs Found.${NC}"
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
echo -e "${CYAN} = = > Targets:${NC} $TOTAL"
echo -e "${CYAN} = = > Map File:${NC} $MAP_FILE"
echo -e "${CYAN} = = > Global Offset:${NC} ${GLOBAL_OFFSET}s (Applies To Intro START Only)"
echo -e "${CYAN} = = > Pre-Trim/Post-Trim:${NC} ${PRE_TRIM}s / ${POST_TRIM}s"
echo -e "${CYAN} = = > Title Segment:${NC} $TITLE_SEGMENT"
echo -e "${CYAN} = = > Intro Pads Start/End:${NC} ${PAD_START}s / ${PAD_END}s"
echo -e "${CYAN} = = > Keyframe Check:${NC} $KF_CHECK"
[[ -n "${KF_TARGET_FILE:-}" ]] && echo -e "${CYAN} = = > Keyframe Probe File:${NC} $KF_TARGET_FILE"
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

  echo
  echo -e "${MAGENTA}----------------------------------------------${NC}"
  echo -e "${MAGENTA} = = > [$((idx+1)) / $TOTAL] TARGET: ${GREEN}${base_in}${NC}${MAGENTA}${NC}"

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

    echo -e "${GREEN} = = > [MAP]${NC} Start=${t_start}s End=${t_end}s Dur=${intro_dur}s"
  else
    echo -e "${YELLOW} = = > [NO MAP]${NC} Manual Entry Needed."
    read -p "  Intro START: " t_start_raw
    read -p "  Intro END: " t_end_raw

    #MARKER: NORM MANUAL TIMES
    t_start="$(to_seconds "$t_start_raw")"
    t_end="$(to_seconds "$t_end_raw")"
    intro_dur="$(fsub "$t_end" "$t_start")"

    echo -e "${CYAN} = = > Manual Start:${NC} ${t_start_raw} -> ${t_start}s"
    echo -e "${CYAN} = = > Manual End:${NC} ${t_end_raw} -> ${t_end}s"
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
  title="$(make_title_from_filename "$base_in")"
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
  echo -e "${CYAN} = = > [CONCAT]${NC} Building Output..."
  if ffmpeg -hide_banner -loglevel error -nostdin \
    -f concat -safe 0 -i "$join" \
    -c copy \
    "${meta_flags[@]}" -metadata title="$title" \
    -fflags +genpts -avoid_negative_ts make_zero -flags +global_header \
    "$tmpout" -y; then

    mv "$tmpout" "$out"
    echo -e "${GREEN} = = > [OK]${NC} Created: ${GREEN}${out}${NC}"
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
echo -e "${MAGENTA}GAPMAN v2 Complete. Outputs: ${DEFAULT_SUTURE_PREFIX}*.mkv${NC}"
echo -e "${MAGENTA}================================================${NC}"

    pause
    return 0
}

# End Of GAPMAN

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
    read -p " = = > Use REKEY Files As Working Source For This Operation? (y/n): " normalize_first_reply

    case "${normalize_first_reply,,}" in
        y|yes)
            prefer_rekey="1"
            echo -e "${GREEN} = = > REKEY Source Preference Enabled.${NC}"
            echo -e "${CYAN} = = > Existing Matching REKEY Files Will Be Preferred As Source.${NC}"
            echo -e "${CYAN} = = > Missing REKEY Files Are Built By Batch Normalizer As Needed.${NC}"
            run_batch_normalizer
            ;;
        *)
            prefer_rekey="0"
            echo -e "${YELLOW} = = > REKEY Source Preference Not Enabled. Use Original Source Files Instead.${NC}"
            ;;
    esac
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
        echo -e "${GR} = = > Found Trusted Cached REKEY Source, Using:${NC} $(basename "$rekey")" >&2
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
# - Modes 2 / 4 / 7 Still Run Through The Legacy Detection Engine Below.
# - Therefore This Submenu Returns A Special Code (10) After Setting MODE And
#   Gathering Any Required Prompts, So Main Menu Can Hand Off Cleanly.
#
# NOTE:
# - Manual Duration Entry Is Intentionally Hidden For Now.
# - In Its Current Form It Behaves Like A Bulk All-Files Prompt Loop And Does
#   Not Earn A Place In The Polished Workflow Menu Yet.
#
run_intro_detection_menu() {
    while true; do
        clear
        echo -e "${CYAN}================================================${NC}"
        echo -e "${CYAN}           INTRO DETECTION TOOLZ                ${NC}"
        echo -e "${CYAN}================================================${NC}"
        echo
        echo -e "${YELLOW}"
        echo "     0) Create/Rebuild A Key For Introfind intro_template.mkv"
        echo "     2) Multi Key Perceptual Use intro_template.mkv Find It (pHash detection)"
        echo "     3) Hybrid detection Same As Above With Black Detect FallBack (pHash + Blackdetect)"
        echo "     5) Build / Append episodes.csv With SxxExx Added For Auto Naming"
        echo "     7) Blackdetect Only"
        echo
        echo "     10key exit > 0.Enter to Quit   (or q) to Quit"
        echo

        read -r -p "     Choice: " det_choice
        echo -e "${NC}"
        det_choice="${det_choice//[[:space:]]/}"

        # ========================================================
        # TEN-KEY EXIT HOOK
        # ========================================================
        if is_factory_exit_token "$det_choice"; then
    	    return 0
        fi

        case "$det_choice" in
            0)
                prompt_normalize_first_workflow
                create_template
                ;;
            2)
                MODE="2"

                read -p " = = > Seconds To Skip Before Starting Scan? (Default ${DEFAULT_SCAN_START}): " SCAN_START
                SCAN_START=${SCAN_START:-$DEFAULT_SCAN_START}

                read -p " = = > Max Scan Depth From Start In Seconds? (Default ${DEFAULT_MAX_SCAN}): " MAX_SCAN
                MAX_SCAN=${MAX_SCAN:-$DEFAULT_MAX_SCAN}

                read -p " = = > Hash Diff Threshold Higher Number Easier Match? (Default ${DEFAULT_HASH_DIFF}): " HASH_DIFF
                HASH_DIFF=${HASH_DIFF:-$DEFAULT_HASH_DIFF}

                read -p " = = > Scan Step Size In Seconds? (Default 0.5): " STEP_SIZE
                STEP_SIZE=${STEP_SIZE:-0.5}

                read -p " = = > Anchor Seconds Comma List? (Default 3,5,7): " ANCHOR_SECONDS
                ANCHOR_SECONDS=${ANCHOR_SECONDS:-3,5,7}

                echo
                prompt_normalize_first_workflow
                return 10
                ;;
            3)
                MODE="4"

                read -p " = = > Seconds To Skip Before Starting Scan? (Default ${DEFAULT_SCAN_START}): " SCAN_START
                SCAN_START=${SCAN_START:-$DEFAULT_SCAN_START}

                read -p " = = > Max Scan Depth From Start In Seconds? (Default ${DEFAULT_MAX_SCAN}): " MAX_SCAN
                MAX_SCAN=${MAX_SCAN:-$DEFAULT_MAX_SCAN}

                read -p " = = > Hash Diff Threshold Higher Number Easier Match? (Default ${DEFAULT_HASH_DIFF}): " HASH_DIFF
                HASH_DIFF=${HASH_DIFF:-$DEFAULT_HASH_DIFF}

                read -p " = = > Scan Step Size In Seconds? (Default 0.5): " STEP_SIZE
                STEP_SIZE=${STEP_SIZE:-0.5}

                read -p " = = > Anchor Seconds Comma List? (Default 3,5,7): " ANCHOR_SECONDS
                ANCHOR_SECONDS=${ANCHOR_SECONDS:-3,5,7}

                read -p " = = > If You Chose Blackdetect Then Set Its Duration? (Default ${DEFAULT_BLACK_DURATION}): " BLACK_DUR
                BLACK_DUR=${BLACK_DUR:-$DEFAULT_BLACK_DURATION}

                read -p " = = > If You Chose Blackdetect Then Set Its Pixel Threshold? (Default ${DEFAULT_BLACK_PIXTH}): " BLACK_PIX
                BLACK_PIX=${BLACK_PIX:-$DEFAULT_BLACK_PIXTH}

                echo
                prompt_normalize_first_workflow
                return 10
                ;;
            5)
                run_build_episodes
                ;;
            7)
                MODE="7"

                read -p " = = > If You Chose Blackdetect Then Set Its Duration? (Default ${DEFAULT_BLACK_DURATION}): " BLACK_DUR
                BLACK_DUR=${BLACK_DUR:-$DEFAULT_BLACK_DURATION}

                read -p " = = > If You Chose Blackdetect Then Set Its Pixel Threshold? (Default ${DEFAULT_BLACK_PIXTH}): " BLACK_PIX
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

# ============================================================
#       DETECTION MODES MENUZ
# ============================================================

run_missions() {

echo -e "${CYAN}  = = > Select-Detection-Mode:${NC}"
echo -e "${YELLOW}"
echo "     0)  = = >   Create / Rebuild intro_template.mkv"
echo "     1)  = = >   Manual Duration Start Stop Times To intro_map.csv"
echo "     2)  = = >   Multi Key Perceptual Match 2 intro_map.csv For GapMan"
echo "     3)  = = >   GapMan Uses intro_map.csv To Cut-n-Gut Snip-n-Clip"
echo "     4)  = = >   Op #2 With Drop 2 Black-Detect Multi-Pass Hybrid"
echo "     5)  = = >   Build / Append  2 CSV For GapMan"
echo "     6)  = = >   SUBtitles deTOX Filename and Meta"
echo "     7)  = = >   Blackdetect Only No Multipass"
echo "     8)  = = >   Batch Normalize RE-encode All Files For Clean Cuts"
echo

read -p "      = = > Mode [0-8]: " MODE
echo -e "${NC}"
echo

if [[ "$MODE" == "0" ]]; then
    prompt_normalize_first_workflow
    create_template
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
    prompt_normalize_first_workflow
    run_gapman
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
    read -p " = = > If You Chose Blackdetect Then Set Its Duration? (default ${DEFAULT_BLACK_DURATION}): " BLACK_DUR
    BLACK_DUR=${BLACK_DUR:-$DEFAULT_BLACK_DURATION}

    read -p " = = > If You Chose Blackdetect Then Set Its Pixel Threshold? (default ${DEFAULT_BLACK_PIXTH}): " BLACK_PIX
    BLACK_PIX=${BLACK_PIX:-$DEFAULT_BLACK_PIXTH}

    echo

    return 0
    ;;
  *)
    echo -e "${REB} = = > Invalid mode: $MODE${NC}"
    exit 1
    ;;
esac

}

# =========================
# #MARKER: WRAPPER → MISSIONS ENTRYPOINT (ORDER MATTERS)
# =========================

# =========================
# #MARKER: NEW ENTRYPOINT
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
#   3 = GAPMAN
#   5 = BUILD_EPISODES_CSV
#   6 = SUBTOX
#   8 = Batch Normalize
#
# Detection Modes That Should Continue Into The File-Processing Loop:
#   1 = Manual Duration
#   2 = pHash
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
# - Always Hide SUTURED_ Outputs
# - Always Hide OEM-Protected Archive Copies
# - Hide REKEY_ Outputs From The Visible Scan List
#   (REKEY Use Is Handled Later By get_preferred_source_file When Enabled)
#
shopt -s nullglob nocaseglob
all_files=(*.{mkv,mp4,avi,mov,mpg,mpeg,ts,m4v,ogv,flv,3gp,divx,webm,wmv,xvid})
shopt -u nullglob nocaseglob

files=()
for f in "${all_files[@]}"; do
    [[ "$f" == intro_template/* ]] && continue
    [[ "$f" =~ ^intro_template ]] && continue
    [[ "$f" =~ ^BARFIX_ ]] && continue
    [[ "$f" =~ ^(SUTURED_|PILOT_SUTURED_) ]] && continue
    [[ "$f" =~ ^REKEY_ ]] && continue
    [[ "$f" =~ ^OEM_ ]] && continue
    [[ "$f" =~ ^oem_ ]] && continue
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
        echo " - $t"
    done
    echo

# ---- Precompute Template Fingerprints (currently informational; not used by pHash engine) ----
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
        read -p " = = > Start Time (seconds): " start
        read -p " = = > Duration (seconds): " dur
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

# =========================
# #MARKER: PHASH DEP CHECK
# =========================
if ! python3 - <<'PY' >/dev/null 2>&1
import cv2
from PIL import Image
import imagehash
PY
then
  echo -e "${REB} = = > pHash Engine Missing Python Modules.${NC}"
  echo -e "${YE} = = > Install:${NC} python3 -m pip install --user pillow python-imagehash opencv-python"
  pause
  continue
fi

  echo -e "${CYAN} = = > Running Perceptual Hash Detection...${NC}"

    # --- Generate temporary Python engine ---
# =========================
# PHASH ENGINE v2.0
# BEST-MATCH / MULTI-ANCHOR / SUB-SECOND SCAN
# =========================
cat << 'EOF' > .phash_engine.py
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

# ============================================================
# OPTIONAL TUNING INPUTS
# ------------------------------------------------------------
# Safe defaults if Bash does not pass the extra knobs.
# ============================================================

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

if STEP <= 0:
    print(f"WARN|non-positive STEP {STEP}, forcing default {DEFAULT_STEP}", file=sys.stderr)
    STEP = DEFAULT_STEP

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

TEMPLATES = glob.glob("intro_template/intro_template*.mkv")
if not TEMPLATES:
    TEMPLATES = glob.glob("intro_template*.mkv")

TEMPLATES.sort(key=template_sort_key)

print("TEMPLATE_ORDER|" + "|".join(TEMPLATES), file=sys.stderr)
print(f"ENGINE_CFG|SCAN_START={SCAN_START}|LIMIT={LIMIT}|HASH_DIFF={HASH_DIFF}|STEP={STEP}|ANCHORS={ANCHOR_OFFSETS}", file=sys.stderr)

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
        ph = imagehash.phash(Image.fromarray(rgb))
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
        print(f"SKIP_TEMPLATE|{template}|reason=no_valid_anchor_hashes", file=sys.stderr)
        continue

    template_data.append({
        "path": template,
        "duration": duration,
        "anchors": anchors,
        "max_anchor": max(a for a, _ in anchors),
    })

    print(
        f"TEMPLATE_READY|{template}|duration={duration:.3f}|anchors_ok={len(anchors)}|anchors_skipped={skipped_anchor_count}",
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

for candidate_start in frange(SCAN_START, LIMIT, STEP):
    for t in template_data:
        diffs = []
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
    for candidate_start in frange(SCAN_START, LIMIT, STEP):
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
            f"  #{i+1}|start={tstart:.3f}|avg_diff={avg:.3f}|template={tpath}",
            file=sys.stderr
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
        f"|template={best_match['template']}"
        f"|avg_diff={best_match['avg_diff']:.3f}"
        f"|best_anchor_diff={best_match['best_anchor_diff']}"
        f"|best_anchor_sec={best_match['best_anchor_sec']}"
        f"|anchors_used={best_match['anchor_count']}"
        f"|delta_to_next={delta_to_next}",
        file=sys.stderr
    )

    sys.exit(0)

print("NO_MATCH")
EOF

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
    PHASH_STDERR_LOG=".phash_engine.stderr.log"

    phash_output="$(
        python3 .phash_engine.py \
            "$SCAN_START" \
            "$limit" \
            "$HASH_DIFF" \
            "$file" \
            "${STEP_SIZE:-0.5}" \
            "${ANCHOR_SECONDS:-3,5,7}" \
            2> >(tee "$PHASH_STDERR_LOG" >&2)
    )"
    phash_status=$?

    rm -f .phash_engine.py

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
        echo -e "${REB} = = > pHash Engine Failed For: $file${NC}"

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
        echo -e "${REB} = = > pHash Engine Returned No Parseable Result For: $file${NC}"

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
        echo -e "${CYAN} = = > Engine Result:${NC} $result"
    fi

    if [[ "$result" == MATCH* ]]; then
        IFS='|' read -r _ start end template_used diff_used <<< "$result"

        start_hms="$(seconds_to_hms "$start")"
        end_hms="$(seconds_to_hms "$end")"

        echo -e "${GREEN} = = > Perceptual Match Found.${NC}"
        echo -e "${CYAN} = = > Start:${NC} $start (${start_hms})"
        echo -e "${CYAN} = = > End:${NC}   $end (${end_hms})"
        echo -e "${CYAN} = = > Key:${NC}   $template_used"
        echo -e "${CYAN} = = > Diff:${NC}  ${diff_used:-}"

        ensure_intro_map

        # 7-column CSV:
        # filename,start,end,start_hms,end_hms,template_used,diff
        #
        # IMPORTANT:
        # - start/end remain the machine-authoritative values
        # - *_hms remains display-only convenience
        # - template_used records which key won
        # - diff records the selected pHash score returned by Python
        #
        echo "$raw,$start,$end,$start_hms,$end_hms,$template_used,${diff_used:-}" >> "$INTRO_MAP"

    elif [[ "$result" == "NO_MATCH" ]]; then
        echo -e "${REB} = = > No Perceptual Match Found Within ${limit}s.${NC}"
    fi

    if [[ "${MODE:-}" == "2" ]]; then
        continue
    fi

    if [[ "$result" == "PHASH_ERROR" ]]; then
        echo -e "${CYAN} = = > pHash Engine Error. Running Blackdetect...${NC}"
        ffmpeg -hide_banner -loglevel error -nostdin -i "$file" \
            -vf blackdetect=d=${BLACK_DUR}:pix_th=${BLACK_PIX} \
            -an -f null - 2>&1 | tee blackdetect.log
    elif [[ "$result" != MATCH* ]]; then
        echo -e "${CYAN} = = > No pHash Match. Running Blackdetect...${NC}"
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
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}-------IntroFind v2.1 Completed------------${NC}"
echo -e "${GREEN}-------Output: $INTRO_MAP------------------${NC}"
echo -e "${GREEN}===========================================${NC}"

# =========================
# #MARKER: RETURN TO MAIN MENU AFTER ENGINE RUN
# =========================
pause
run_main_menu
exit 0
