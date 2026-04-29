#!/usr/bin/env bash
# HEADER CAT + TREE — VERSION FIX STABLE (wcwidth + columns exactes)

set -o pipefail

# ===== CONFIG =====
MARGIN_LEFT=2
LINE_DELAY=0.01

# hide cursor
if command -v tput >/dev/null 2>&1; then
  tput civis 2>/dev/null || true
  trap 'tput cnorm 2>/dev/null || true' EXIT
fi

# ===== GET VISUAL WIDTH (UNICODE-AWARE) =====
visual_width() {
    local s="$1" total=0 c w
    while IFS= read -r -n1 c; do
        w=$(printf "%s" "$c" | wcwidth 2>/dev/null)
        (( w < 0 )) && w=1
        total=$((total + w))
    done <<< "$s"
    echo $total
}

# =========================
#   LIGNE DATE
# =========================
date_line="$(date +'%A, %d %B %Y')"


# =========================
#   ASCII ART CAT
# =========================
mapfile -t ascii_art << 'EOF'
⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠟⠛⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿
⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿
⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿
⣿⣿⣿⣧⠀⠀⠀⠀⣠⣾⣿⣿⣿⣆⠀⠀⠀⠀⠀⣠⣾⣿⣿⣆⠀⠀⢀⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠀⠀⠀⢸⣿⣿⣿⡃⠀⣿⡀⠀⠀⠀⠀⣿⠁⠈⣿⣿⡀⠀⠈⣿⣿⣿⣿⣿
⣿⣿⣿⡟⠀⠀⠀⠈⢿⣿⣿⣷⣴⡿⠀⠀⠀⠀⠀⢿⣦⣴⣿⡿⠁⠀⠀⣿⣿⣿⣿⣿
⡿⠿⠿⠿⠀⠀⠀⠀⠀⠉⠉⠉⠉⠀⠀⠀⠀⠁⠀⠈⠙⠛⠋⠀⠀⠀⠀⠛⣛⡛⠛⢻
⣷⣶⣶⡶⠦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠿⢿⣿
⣯⣥⣴⣶⡿⠓⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠚⠿⢿⣷⣿⣷⣤
⣿⣿⣋⣥⣶⣿⣿⣿⣶⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣴⣾⣿⣿⣿⣶⣤⣝⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿
EOF


# ====== DEGRADE BLEU ======
fg_palette=(17 18 19 20 21 27 33 39 45 51 153 195 231)
fg_len=${#fg_palette[@]}

get_fg_for_line() {
  echo "${fg_palette[$(($1 % fg_len))]}"
}

# ===============================================
#         BUILD TREE (AS ARRAY)
# ===============================================
tree_lines=()

build_tree() {
    tree_lines=()
    tree_lines+=("📂 Structure du dossier")
    tree_lines+=("")

    if command -v tree >/dev/null 2>&1; then
        while IFS= read -r l; do
            tree_lines+=("$l")
        done < <(tree -L 2 -F --dirsfirst --noreport)
    else
        tree_lines+=(".")
        for d in */; do
            [ -d "$d" ] || continue
            tree_lines+=("├── ${d%/}/")
        done
        for f in *; do
            [ -f "$f" ] || continue
            tree_lines+=("├── $f")
        done
    fi
}
build_tree


# ===============================================
#           CALCUL LARGEURS RÉELLES
# ===============================================
left_width=0
for line in "${ascii_art[@]}"; do
    w=$(visual_width "$line")
    (( w > left_width )) && left_width=$w
done

right_width=0
for line in "${tree_lines[@]}"; do
    w=$(visual_width "$line")
    (( w > right_width )) && right_width=$w
done

gap=5   # espace entre cat et tree
term_cols=$(tput cols 2>/dev/null || echo 80)
total_needed=$(( MARGIN_LEFT + left_width + gap + right_width ))

# =========================
#   COULEURS
# =========================
RESET=$'\e[0m'
DATE_COLOR=$'\e[38;5;45m'
TREE_COLOR=$'\e[38;5;159m'

# ===============================================
#   MODE VERTICAL SI PAS ASSEZ DE PLACE
# ===============================================
if (( term_cols < total_needed )); then
    printf "%s%s%s\n" "$DATE_COLOR" "$date_line" "$RESET"
    sleep "$LINE_DELAY"

    # cat
    for i in "${!ascii_art[@]}"; do
        c="${ascii_art[$i]}"
        cc=$(get_fg_for_line "$i")
        fg=$'\e[38;5;'"$cc"'m'
        printf "%s%s%s\n" "$fg" "$c" "$RESET"
        sleep "$LINE_DELAY"
    done

    printf "\n"

    # tree
    for l in "${tree_lines[@]}"; do
        printf "%s%s%s\n" "$TREE_COLOR" "$l" "$RESET"
        sleep "$LINE_DELAY"
    done

    exit 0
fi


# ===============================================
#            AFFICHAGE SIDE-BY-SIDE
# ===============================================
printf "%*s%s%s%s\n" "$MARGIN_LEFT" "" "$DATE_COLOR" "$date_line" "$RESET"
sleep "$LINE_DELAY"

rows=${#ascii_art[@]}
(( ${#tree_lines[@]} > rows )) && rows=${#tree_lines[@]}

for ((i=0; i<rows; i++)); do
    # left
    if (( i < ${#ascii_art[@]} )); then
        cc=$(get_fg_for_line "$i")
        fg=$'\e[38;5;'"$cc"'m'
        left="${fg}${ascii_art[$i]}${RESET}"
    else
        left=""
    fi

    # right
    if (( i < ${#tree_lines[@]} )); then
        right="${TREE_COLOR}${tree_lines[$i]}${RESET}"
    else
        right=""
    fi

    printf "%*s%-*s%*s%s\n" \
        "$MARGIN_LEFT" "" \
        "$left_width" "$left" \
        "$gap" "" \
        "$right"

    sleep "$LINE_DELAY"
done

