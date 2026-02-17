#!/bin/bash

# Vérifie si l'utilisateur a lancé le script en superutilisateur
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : Ce script doit être exécuté avec les permissions de superutilisateur." >&2
    exit 1  # Sort avec le code d'erreur 1
fi

# Vérifie si le script est utilisé sur macOS
if [[ "$OSTYPE" != darwin* ]]; then
    echo "Erreur : Ce script doit être exécuté sur un environnement OS X/macOS." >&2
    exit 1
fi

# Vérifie si Homebrew est installé
if ! command -v brew &> /dev/null; then
    # Installe Homebrew
    echo "[⚠️] Homebrew n'est pas installé. Installation de Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "[✅] Homebrew est déjà installé."
fi