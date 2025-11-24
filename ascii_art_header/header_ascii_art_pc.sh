#!/bin/bash

# ====== CONFIG ======
MARGIN_LEFT=2      # marge à gauche
LINE_DELAY=0.02    # temps entre chaque ligne (en secondes)

# Cache le curseur et assure qu'il sera restauré à la fin même en cas d'erreur
tput civis
trap 'tput cnorm' EXIT

# =========================
#   LIGNES DYNAMIQUES
# =========================

date_line="$(date +'%A, %d %B %Y')"
name="$(whoami)"

# On centre le user DANS l'écran du PC
# Ligne de référence :
# "              | |   Computer           | | |              "
# => l'intérieur "Computer        " fait 16 caractères
screen_width=16
name_len=${#name}

if (( name_len > screen_width )); then
    # Si le nom est trop long, on le tronque
    name="${name:0:screen_width}"
    name_len=${#name}
fi

padding_total=$(( screen_width - name_len ))
padding_left=$(( padding_total / 2 ))
padding_right=$(( padding_total - padding_left ))

centered_name="$(printf '%*s%s%*s' "$padding_left" "" "$name" "$padding_right" "")"

# Préfixe / suffixe EXACTEMENT comme la ligne "Computer"
screen_prefix="              | |   "
screen_suffix="   | | |              "
line_user="${screen_prefix}${centered_name}${screen_suffix}"

# =========================
#   ASCII ART
# =========================

ascii_art=(
" $date_line"
"              ,----------------------------,               "
"              |  /----------------------\\  |              "
"              | |                      | | |              "
"              | |   Computer           | | |              "
"$line_user"
"              | |   Services           | | |              "
"              | |       42  Company    | | |              "
"              |  \\______________________/  |              "
"              |____________________________|              "
"            ,---\\_____    ' [] '    ______/------,       "
"          /         /______________\\          / |      "
"        /_____________________________________/  | ___   "
"        |                                    |   |    )   "
"        |  _ _ _                '['-----']'  |   |    (   "
"        |  o o o                '[-----]'   |\\  |    _)_  "
"        |___________________________________|_\\_|   /  /  "
"      /-------------------------------------/       ( )/   "
"    /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/                   "
"  /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/                    "
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                     "
)

rows=${#ascii_art[@]}

# =========================
#   PALETTE RGB (arc-en-ciel)
# =========================
# rouge → orange → jaune → vert → cyan → bleu → violet → magenta
palette=(196 202 208 220 190 82 46 51 45 27 33 57 93 129 201)
palette_len=${#palette[@]}

get_color_for_line() {
    local i="$1"
    # mappe la ligne i dans [0..palette_len-1] pour un dégradé arc-en-ciel
    local idx=$(( i * (palette_len - 1) / (rows - 1) ))
    echo "${palette[$idx]}"
}

# =========================
#   AFFICHAGE PROGRESSIF
# =========================

start_row=1
start_col=$MARGIN_LEFT

clear  # on nettoie une seule fois

for (( i=0; i<rows; i++ )); do
    color_code=$(get_color_for_line "$i")
    color="\e[38;5;${color_code}m"

    # Met en gras la date (ligne 0) et la ligne user
    style=""
    if (( i == 0 )) || [[ "${ascii_art[$i]}" == "$line_user" ]]; then
        style="\e[1m"
    fi

    tput cup $(( start_row + i )) "$start_col"
    echo -e "${style}${color}${ascii_art[$i]}\e[0m"

    sleep "$LINE_DELAY"
done

