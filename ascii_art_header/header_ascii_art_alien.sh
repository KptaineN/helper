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
#   (on utilise un heredoc pour éviter d'échapper les guillemets / \)
# =========================

mapfile -t ascii_art << 'EOF'
         __.,,------.._                                                      
      ,''   _      _   '`.                                                   
     /.__, ._  _-=- _`    Y                                                  
    (.____.-.`      ''`   j                                                  
     VvvvvvV`.Y,.    _.,-'       ,     ,     ,                               
       Y    ||,   ''\         ,/    ,/    ./                                 
   =---|-  ,'  ,     `-..,'_,'/___,'/   ,'/   ,                              
   ..  ,;,,',-'"\,  ,  .     '     ' ""''' '--,/    .. ..                    
 ,'. `.`---'     `, /  , Y -=-    ,'   ,   ,. .`-..'||''||' ..               
ff\`. `._        /f ,'j j , ,' ,   , f ,  \=\ Y   '||''||'`'||'_..           
l` \` `.`."`-..,-' j  /./ /, , / , / /l \   \=\l   || `''||||'...            
 `  `   `-._ `-.,-/ ,' /`"/-/-/-/-"'''"`.`.  `'.\--`'--..`'_`' || ,          
            "`-_,',  ,'  f    ,   /      `._    ``._     ,  `-.`'//       ,  
          ,-"'' _.,-'    l_,-'_,,'          "`-._ . "`. /|     `.'\ ,     |  
        ,',.,-'"          \=) ,`-.         ,    `-'._`.V |       \ // .. . /j 
        |f\\               `._ )-."`.     /|         `.| |        `.`-||-\\/  
        l` \`                 "`._   "`--' j          j' j          `-`---'   
         `  `                     "`,-  ,'/       ,-'"  /                     
                                 ,'",__,-'       /,, ,-'                      
                                 Vvv'            VVv'                         
EOF

rows=${#ascii_art[@]}      # nombre de lignes du xeno
total_rows=$((rows + 1))   # +1 pour la ligne de date

# =========================
#   PALETTES VIOLET / NOIR
# =========================
# fg = violet/bordeaux, bg = noir / gris très sombre

fg_palette=(55 54 53 91 127 129 93 54 53 91 129 201 129 91 55)
bg_palette=(232 233 234 234 234 234 234 234 234 234 234 234 234 233 232)

fg_len=${#fg_palette[@]}
bg_len=${#bg_palette[@]}

get_fg_for_line() {
    local i="$1"
    local idx=$(( i * (fg_len - 1) / (total_rows - 1) ))
    echo "${fg_palette[$idx]}"
}

get_bg_for_line() {
    local i="$1"
    local idx=$(( i * (bg_len - 1) / (total_rows - 1) ))
    echo "${bg_palette[$idx]}"
}

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
    bg_code=$(get_bg_for_line "$i")

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


