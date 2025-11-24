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
welcome_line="WELCOME to $(whoami) !"

ascii_art=(
"                                                          "
"$date_line"
"                                                          "
"                      .                                   "
"                      M                                   "
"                     dM                                   "
"                     MMr                                  "
"                    4MMML                  .              "
"                    MMMMM.                xf              "
"    .              'MMMMM               .MM-              "
"     Mh..          +MMMMMM            .MMMM               "
"     .MMM.         .MMMMML.          MMMMMh               "
"      )MMMh.        MMMMMM         MMMMMMM                "
"       3MMMMx.     'MMMMMMf      xnMMMMMM'                "
"       '*MMMMM      MMMMMM.     nMMMMMMP'                 "
"         *MMMMMx    'MMMMM/    .MMMMMMM=                  "
"          *MMMMMh   'MMMMM'   JMMMMMMP                    "
"            MMMMMM   3MMMM.  dMMMMMM            .         "
"             MMMMMM  'MMMM  .MMMMM(        .nnMP'         "
" .=m.,        *MMMMx  MMM.  dMMMM'    .nnMMMMM*           "
"   MMMn...     *MMMMr °MM   MMM'   .nMMMMMMM*'            "
"    '4MMMMnn..   *MMM  MM  MP'  .dMMMMMMM''               "
"      ^MMMMMMMMx.  *ML 'M .M*  .MMMMMM**'     ___         "
"         *PMMMMMMhn. *x > M  .MMMM**''      __NOE__       "
"            ''**MMMMhx/.h/ .=*'              (o o)        "
"                     .3P'%....             ./-(_)-'       "
"                   nP'     '*MMnx  '                      "
"╚═══════════════════════════════════════════════════╝"
"$welcome_line"
)

rows=${#ascii_art[@]}

# =========================
#   PALETTE DÉGRADÉ VERTICAL
# =========================
# Codes 256 couleurs (vert foncé -> vert clair)
palette=(22 28 34 40 46 82 118 154)
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

