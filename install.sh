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

# Créer les dossiers et fichiers nécessaires
echo "[ℹ️] Création des dépendances nécessaires..."

# Création du répertoire qui contient les différentes configurations de l'ordinateur
# Les fichiers JSON pourront être modifiés par l'utilisateur pour personnaliser les configurations
mkdir config

# Vérifie si les fichiers de configuration existent déjà
if [ -f "config/settings.json" ] || [ -f "config/applications.json" ]; then
    echo "[⚠️] Attention : Les fichiers de configuration existent déjà. Ils ne seront pas écrasés." >&2
else
    echo "[ℹ️] Les fichiers de configuration seront créés."
    touch config/settings.json
    touch config/applications.json

    # Vérifie s'il y a une erreur lors de la création des fichiers de configuration
    if [ $? -ne 0 ]; then
        echo "[❌] Erreur : La création des fichiers de configuration a échoué." >&2
        exit 1
    else
        echo "[✅] Les fichiers de configuration ont été créés avec succès."
        echo "[ℹ️] Vous pouvez maintenant personnaliser les fichiers de configuration dans le dossier 'config'." >&2

        # Demande à l'utilisateur s'il souhaite ouvrir les fichiers de configuration pour les personnaliser
        read -p "Voulez-vous ouvrir les fichiers de configuration pour les personnaliser ? (y/n) " answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
            vim config/settings.json
            vim config/applications.json
        else
            echo "[ℹ️] Vous pouvez personnaliser les fichiers de configuration plus tard en les ouvrant dans le dossier 'config'."
            echo "[⚠️] Si les fichiers de configuration sont vides ou éronés, le script d'installation utilisera la configuration par défaut."
            echo "[ℹ️] Pour obtenir des modèles de configuration, consultez le dépôt GitHub (https://github.com/enioaiello/config-macos)."
        fi
    fi
fi

mkdir logs
mkdir data
mkdir data/wallpapers
mkdir data/scripts

# Vérifie s'il y a une erreur lors de la création des dépendances
if [ $? -ne 0 ]; then
    echo "[❌] Erreur : La création des dépendances a échoué." >&2
    exit 1
else
    echo "[✅] Les dépendances nécessaires ont été créées avec succès."
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