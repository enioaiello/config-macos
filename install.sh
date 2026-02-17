#!/bin/bash

# Vérifie si l'utilisateur a lancé le script en superutilisateur
if [ "$EUID" -ne 0 ]; then
    echo "[❌] Erreur : Ce script doit être exécuté avec les permissions de superutilisateur." >&2
    exit 1  # Sort avec le code d'erreur 1
else
    echo "[✅] Exécution avec les permissions de superutilisateur confirmée."
fi

# Vérifie si le script est utilisé sur macOS
if [[ "$OSTYPE" != darwin* ]]; then
    echo "[❌] Erreur : Ce script doit être exécuté sur un environnement OS X/macOS." >&2
    exit 1
else
    echo "[✅] Environnement OS X/macOS confirmé."
fi

# Vérifie si Homebrew est installé
if ! command -v brew &> /dev/null; then
    # Installe Homebrew
    echo "[⚠️] Homebrew n'est pas installé. Installation de Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "[✅] Homebrew est déjà installé."
fi

# Met à jour Homebrew et les formules
echo "[ℹ️] Mise à jour de Homebrew et des formules..."
brew update
brew upgrade

# Vérifie s'il y a une erreur
if [ $? -ne 0 ]; then
    echo "[❌] Erreur : La mise à jour de Homebrew a échoué." >&2
    exit 1
else
    echo "[✅] Homebrew et les formules sont à jour."
fi