#!/bin/bash

# ====== CONFIG ======
MARGIN_LEFT=2      # marge à gauche
LINE_DELAY=0.02    # temps entre chaque ligne (en secondes)

# Cache le curseur et assure qu'il sera restauré à la fin même en cas d'erreur
tput civis
trap 'tput cnorm' EXIT

# =========================
#   ASCII ART
# =========================

date_line="$(date +'%A, %d %B %Y')"
name="$(whoami)"
prefix=" |       ---   "
suffix="   ----      | "
inside_width=$(( ${#prefix} + ${#name} + ${#suffix} ))

# largeur totale de ta ligne (compte EXACTEMENT tes caractères)
total_width=37   # à adapter : compte tes " | ... | "

# calcul du centrage
padding_total=$(( total_width - ${#prefix} - ${#name} - ${#suffix} ))
padding_left=$(( padding_total / 2 ))
padding_right=$(( padding_total - padding_left ))

line_name=" |         ---$(printf '%*s' $padding_left "")$name$(printf '%*s' $padding_right "")----          |"


ascii_art=(
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠟⠋⠻⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠞⠛⠛⣿⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠃⠀⠀⠀⣿⣤⣤⣤⣤⣤⣤⣤⠾⠋⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⢠⡞⠛⠛⠁⠀⠀⠀⠀⠀⠀⣼⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠟⠻⣦⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⢠⡍⠀⠀⠀⠀⠀⠀⠀⣠⣤⣤⣄⡀⣴⠏⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠈⣷⠀⠀⠀⠀⠀⠀⠀⠀⢘⠃⠀⠀⠀⠀⠀⢀⡟⠁⣠⣤⣤⠙⣄⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⣠⡴⠖⠛⠶⣦⡀⠀⠀⠀⠀⠀⢹⡆⠀⠀⠀⠀⠀⢿⡄⠸⣿⣿⡟⠀⣿⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⢰⡏⢠⣾⣿⣶⠀⢻⡄⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠈⠻⢶⣤⣤⣤⠾⠃⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠘⣧⡈⠛⠛⠛⣀⡾⠁⠀⠀⣤⠀⠀⠀⣠⡆⠀⠀⠀⠀⣠⡾⠃⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠙⠛⠛⣿⠻⣤⣀⡀⠀⠘⠃⠀⠀⠋⠀⠀⣀⣤⠾⠋⢀⡼⠃⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠘⠷⣤⠈⠙⠛⠛⠶⠶⠶⠞⠛⠛⠉⠀⣠⠴⡋⠀⠀⠀⠀⢸⡏⠳⣦⣀⠀⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⣶⠦⣤⣤⣤⣤⣤⠴⠶⠛⠉⢸⡇⠀⠀⠀⠀⢸⡇⠀⠀⠙⠃⠀⠀"
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⠀⠀⠀⠀⠀⣸⠀⠀⠀⣼⠃"
"⠀⠀⠀⣠⡾⠻⣄⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⣸⠇⠀⠀⣼⠏⠀"
"⠀⢀⡾⠋⠀⠀⠙⢷⣄⡀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⢀⣼⠏⠀⢀⣼⡟⠀⠀"
"⠀⠈⠻⣦⡀⠀⠀⠀⠉⠉⠛⠛⠻⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⢀⣠⠾⠁⠀⣠⣾⠁⠀⠀⠀"
"⠀⠀⠀⠈⠛⢶⣄⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠁⣀⣤⠾⣫⠀⠀⠀   "
"⠀⠀⠀⠀⠀⠀⠉⠛⠛⠛⠛⠛⠋⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⠶⠟⠋⠁⠀⠀⠀     "
"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀          "

)

rows=${#ascii_art[@]}

# =========================
#   PALETTE DÉGRADÉ VERTICAL
# =========================
# Codes 256 couleurs (vert foncé -> vert clair)
palette=(166 160 160 160 166 172 208 214 52)
palette_len=${#palette[@]}



get_color_for_line() {
    local i="$1"
    # mappe la ligne i dans [0..palette_len-1] pour faire un dégradé
    local idx=$(( i * (palette_len - 1) / (rows - 1) ))
    echo "${palette[$idx]}"
}

# =========================
#   AFFICHAGE PROGRESSIF
# =========================

start_row=1
start_col=$MARGIN_LEFT

# Nettoyer l'écran une seule fois au début
clear

for (( i=0; i<rows; i++ )); do
    color_code=$(get_color_for_line "$i")
    color="\e[38;5;${color_code}m"

    # Met en gras la date et la dernière ligne "WELCOME..."
    style=""
    if (( i == 1 || i == rows - 1 )); then
        style="\e[1m"
    fi

    tput cup $(( start_row + i )) "$start_col"
    echo -e "${style}${color}${ascii_art[$i]}\e[0m"

    # Petit délai pour l'effet "image qui se révèle"
    sleep "$LINE_DELAY"
done

# Le header est affiché une fois, le curseur est remis grâce au trap (EXIT)

