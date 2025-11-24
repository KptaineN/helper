#!/bin/bash

echo "🔍 Vérification de l'état de Secure Boot..."
sleep 1

if ! command -v mokutil &> /dev/null; then
    echo "❌ mokutil n'est pas installé. Installation en cours..."
    sudo apt update && sudo apt install mokutil -y
fi

STATE=$(mokutil --sb-state | grep -i "SecureBoot" | awk '{print $2}')

echo "🔐 Secure Boot est actuellement : $STATE"

read -p "Souhaitez-vous modifier l'état de Secure Boot ? (yes/no) : " CHOICE

if [[ "$CHOICE" == "yes" ]]; then
    echo "⚠️ Cette opération doit être faite manuellement dans le BIOS/UEFI."
    echo "👉 Redémarre ton PC et accède au BIOS (souvent avec F2, F10 ou DEL)."
    echo "Puis va dans 'Security' ou 'Boot' et change l'option Secure Boot."
else
    echo "👍 Aucun changement effectué. Tu peux continuer comme ça."
fi

