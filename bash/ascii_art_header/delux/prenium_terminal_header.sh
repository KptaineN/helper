#!/usr/bin/env bash
# ASCII art à gauche + infos système + mini ls à droite avec dégradé violet → rose

set -o pipefail

# ========= ASCII ART (XENO) =========
read -r -d '' ascii_block << 'EOF'
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
⠀⠀⠀⠀⠭⠄⠀⠀⡰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⡄⠀⠀⠀
EOF

mapfile -t ascii_art <<< "$ascii_block"


# Largeur interne du tableau (entre les deux bordures)
BOX_WIDTH=46

# Texte de gauche
TITLE="🖥️  CONFIG SYSTÈME"
USER_NAME="$(whoami)"

# Construction de la chaîne "TITLE .... USER" centrée proprement
middle_content="$TITLE  $USER_NAME"

# Calcul des espaces restants
content_len=${#middle_content}
spaces=$(( BOX_WIDTH - content_len ))

if (( spaces < 0 )); then
    spaces=0
fi

padding=""
for ((i=0; i<spaces; i++)); do padding+=" "; done

############################################
#  INFOS SYSTÈME → stockées dans un tableau
############################################
sysinfo_lines=()

# Couleurs pour le bloc sysinfo (indépendantes du reste)
if command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    SYS_RESET="$(tput sgr0)"
    SYS_BOLD="$(tput bold)"
    SYS_DIM="$(printf '\e[2m')"
    SYS_COL_TITLE="$(tput setaf 5)${SYS_BOLD}"  # violet titre
    SYS_COL_LABEL="$(tput setaf 5)"             # violet normal
else
    SYS_RESET="" SYS_BOLD="" SYS_DIM=""
    SYS_COL_TITLE="" SYS_COL_LABEL=""
fi

# ----- Distro -----
distro="Linux"
if command -v lsb_release >/dev/null 2>&1; then
    distro="$(lsb_release -ds 2>/dev/null | sed 's/^"//; s/"$//')"
elif [ -r /etc/os-release ]; then
    . /etc/os-release
    distro="${PRETTY_NAME:-$NAME $VERSION}"
fi

# ----- CPU -----
cpu="Unknown CPU"
if [ -r /proc/cpuinfo ]; then
    cpu="$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^[[:space:]]*//')"
    cpu="${cpu:0:60}"
fi

# ----- RAM -----
ram="Unknown RAM"
if command -v free >/dev/null 2>&1; then
    ram="$(free -h | awk '/^Mem:/ {print $2}')"
elif [ -r /proc/meminfo ]; then
    kb="$(grep -m1 'MemTotal' /proc/meminfo | awk '{print $2}')"
    if [ -n "$kb" ]; then
        ram="$((kb / 1024))MiB"
    fi
fi
sysinfo_lines+=("")
# On remplit sysinfo_lines (une ligne = une entrée affichable à droite)
sysinfo_lines+=("${SYS_COL_TITLE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${SYS_RESET}")

# Ligne du milieu → titre + username alignés
sysinfo_lines+=("${SYS_COL_TITLE}┃ ${middle_content}            ┃${SYS_RESET}")

sysinfo_lines+=("${SYS_COL_TITLE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${SYS_RESET}")

# Indentation pour la valeur (tu peux ajuster : ici 12 espaces)
INDENT="            "
sysinfo_lines+=("")
# DISTRO (2 lignes)
sysinfo_lines+=("${SYS_COL_LABEL}   🐧  Dist :${SYS_RESET}")
sysinfo_lines+=("${INDENT}${distro}")
sysinfo_lines+=("")

# CPU (2 lignes)
sysinfo_lines+=("${SYS_COL_LABEL}   💻  CPU  :${SYS_RESET}")
sysinfo_lines+=("")
sysinfo_lines+=("${cpu}")
sysinfo_lines+=("")

# RAM (2 lignes)
sysinfo_lines+=("${SYS_COL_LABEL}   💾  RAM  :${SYS_RESET}")
sysinfo_lines+=("${INDENT}${ram}")
sysinfo_lines+=("")

# ligne vide pour respirer
#sysinfo_lines+=("")

sysinfo_count=${#sysinfo_lines[@]}

# ========= RÉCUP FICHIERS =========
entries=()
while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    [[ "$name" == .* ]] && continue   # pas les fichiers cachés
    entries+=( "$name" )
done < <(LC_ALL=C ls -A1 2>/dev/null || true)
files_count=${#entries[@]}

# ========= COULEURS & DÉGRADÉ =========
RESET=$'\e[0m'

if command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 256 ]; then
    # violet → rose
    gradient=(129 135 171 177 183 219 213 207)
else
    gradient=(135)  # magenta simple
fi
gradient_len=${#gradient[@]}

# ========= ICÔNES =========
DIR_ICON="📁"
FILE_ICON="📄"
EXEC_ICON="⚙️"
C_ICON="📘"
MK_ICON="🧱"

# ========= LARGEUR ASCII =========
left_width=0
for line in "${ascii_art[@]}"; do
    (( ${#line} > left_width )) && left_width=${#line}
done
left_width=$((left_width + 2))

# ========= AFFICHAGE =========
rows_ascii=${#ascii_art[@]}
# total de lignes à droite = sysinfo + fichiers
rows_right=$((sysinfo_count + files_count))
rows=$rows_ascii
(( rows_right > rows )) && rows=$rows_right

for ((i=0; i<rows; i++)); do
    # ----- gauche : ASCII avec dégradé -----
    if (( i < rows_ascii )); then
        line="${ascii_art[i]}"
        color_idx=$(( i % gradient_len ))
        color_left=$'\e[38;5;'"${gradient[color_idx]}"'m'
        left_colored="${color_left}${line}${RESET}"
    else
        left_colored=""
    fi

    # ----- droite : d'abord sysinfo, puis ls -----
    right_line=""
    if (( i < sysinfo_count )); then
        # on est dans le bloc sysinfo
        right_line="${sysinfo_lines[i]}"
    else
        # on est dans la partie fichiers
        idx=$(( i - sysinfo_count ))
        if (( idx < files_count )); then
            name=${entries[idx]}
            full="./$name"
            color_idx=$(( idx % gradient_len ))
            color_right=$'\e[38;5;'"${gradient[color_idx]}"'m'

            icon="$FILE_ICON"
            if [[ -d "$full" ]]; then
                icon="$DIR_ICON"
            elif [[ "$name" == *.c ]]; then
                icon="$C_ICON"
            elif [[ "$name" == "Makefile" || "$name" == "makefile" ]]; then
                icon="$MK_ICON"
            elif [[ -x "$full" && ! -d "$full" ]]; then
                icon="$EXEC_ICON"
            fi

            right_line="${color_right}${icon} ${name}${RESET}"
        fi
    fi

    printf "%-*s  %s\n" "$left_width" "$left_colored" "$right_line"
done

