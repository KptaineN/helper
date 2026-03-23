#!/bin/bash

# ====== CONFIG ======
MARGIN_LEFT=2      # marge à gauche
LINE_DELAY=0.02    # temps entre chaque ligne (en secondes)

# Cache le curseur et assure qu'il sera restauré à la fin même en cas d'erreur
tput civis
trap 'tput cnorm' EXIT

# =========================
#   LIGNE DYNAMIQUE (DATE)
# =========================

date_line="$(date +'%A, %d %B %Y')"

# =========================
#   ASCII ART XENOMORPH
# =========================
# heredoc pour ne pas s'embêter avec les guillemets / backslashes

mapfile -t ascii_art << 'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⡤⢤⣀⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⢶⠞⢩⣧⡨⠿⠿⢿⡝⠯⠛⠶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣶⠟⠍⠁⢒⠿⡠⠖⠉⠉⢙⣷⠀⠀⠀⠈⠩⣲⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢤⡿⣥⡖⣲⣿⣿⣞⣁⣀⠴⢚⣿⠛⣷⡈⣆⠀⠱⡌⠉⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢰⡿⢛⣶⣿⣿⣿⠋⣹⣟⣁⣴⣾⠃⢀⡏⠇⠸⡀⠀⢱⠀⢈⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣿⡇⡘⣾⣿⣿⡇⣸⡯⠽⠟⢋⣉⠑⡞⠀⡼⢠⢧⠀⠀⡇⠈⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠐⡿⢰⢁⡟⠀⠉⣰⠙⡿⣷⣶⢦⡄⢰⠁⢰⠃⣸⡌⠀⢸⠃⢀⢾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣷⢸⢸⢧⡰⢼⣿⡀⠉⠁⠈⠀⠀⠀⢧⢇⣸⣳⠁⡰⢃⠀⣸⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢿⣿⡸⣼⡝⢦⠣⠁⠀⠀⠀⠀⠀⠀⠘⠙⠻⢥⠞⢁⠜⣰⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠈⢿⢿⣼⣇⠘⣧⡀⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⣼⣧⣾⡷⠛⢿⠓⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠸⠺⣿⣿⣇⣿⠙⢦⡀⠀⠀⠀⠀⠀⠀⢀⣼⡿⠋⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⢀⡤⠶⠶⠿⢿⣿⡇⠀⠀⠈⠓⠤⣤⡤⠖⠊⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⡴⠋⠀⠀⠀⠀⠀⠙⠓⠤⠄⣀⡀⠀⢸⣷⣦⡤⠤⠖⠒⠒⠢⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢸⠃⠀⠀⠀⠀⠀⢀⢆⡀⠀⠂⠒⠒⠒⠻⠦⣄⡀⠀⢀⠢⠤⠤⢄⡹⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⡚⠀⠀⠀⠀⠀⠀⡸⠋⠀⠀⠀⠀⠀⢀⠀⠀⠀⠈⠳⡄⠀⠀⠀⠀⠀⠈⠉⠳⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀
⢹⠀⠀⠀⠀⠀⢠⠇⠀⠀⠀⠀⠀⠀⠻⠇⠀⠀⠀⠀⠙⡄⠀⠀⠀⠀⠀⠀⠀⣾⣵⣄⠀⠀⠀⠀⠀⠀⠀
⠀⣇⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠈⠀⣿⠀⠀⠀⠀⠀⠀⠀
⠀⠻⡄⠀⠀⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⣷⠀⠀⠀⠀⠈⡦⣀⠀⠀⠀⠀⠀⠀⠀⣀⠠⠖⠋⠈⠳⣄⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠹⡄⠀⠀⠀⠀⢸⠈⠉⠒⠒⠒⠊⠉⠁⠀⠀⠀⠀⠀⠀⠈⠳⣆⡀⠀⢀⡴⠟⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢥⠀⠀⠀⠀⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢸⡄⠀⠀⠀⢸⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠈⣷⠀⠀⠀⠀⡹⣿⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⠀⠛⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣿⠄⠀⠀⠀⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠭⠄⠀⠀⡰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⡄⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠸⡆⠀⢰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠓⢄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀                  
EOF

rows=${#ascii_art[@]}      # nombre de lignes du xeno
total_rows=$((rows + 1))   # +1 pour la ligne de date

# =========================
#   PALETTE ROSE + FOND GRIS
# =========================
# fg = variantes de rose/magenta, bg = gris foncé unique

fg_palette=(161 162 163 164 198 199 200 201 206 207 213)
fg_len=${#fg_palette[@]}

get_fg_for_line() {
    local i="$1"
    local idx=$(( i * (fg_len - 1) / (total_rows - 1) ))
    echo "${fg_palette[$idx]}"
}

bg_code=236  # gris foncé (ni trop noir, ni trop clair)

# =========================
#   AFFICHAGE PROGRESSIF
# =========================

start_row=1
start_col=$MARGIN_LEFT

clear  # une seule fois

for (( i=0; i<total_rows; i++ )); do
    if (( i == 0 )); then
        # Ligne de date tout en haut
        line=" $date_line"
    else
        line="${ascii_art[i-1]}"
    fi

    fg_code=$(get_fg_for_line "$i")

    # couleur texte (38) + fond (48)
    color="\e[38;5;${fg_code}m\e[48;5;${bg_code}m"

    # Met la date en gras
    style=""
    if (( i == 0 )); then
        style="\e[1m"
    fi

    tput cup $(( start_row + i )) "$start_col"
    echo -e "${style}${color}${line}\e[0m"

    sleep "$LINE_DELAY"
done

