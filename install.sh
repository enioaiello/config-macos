#!/bin/bash

# Définit les variables essentielles
# Pour les chemins...
CONFIG_DIR="config"
LOGS_DIR="logs"
DATA_DIR="data"

# Pour les icônes...
SUCCESS_ICON="[✅]"
ERROR_ICON="[❌]"
WARNING_ICON="[⚠️]"
INFO_ICON="[ℹ️]"

# Pour le système
OS_TYPE="darwin"

# Autres variables
corundum_quick_url="https://corundum.fr/quick"

# Définition des fonctions de base

# Fonction qui affiche un saut de ligne (\n)
function insert_newline() {
    echo ""
}

function display_error() {
    echo "${ERROR_ICON} $1" >&2
    echo "${INFO_ICON} Le script va maintenant se terminer." >&2
    exit 1  # Sort avec le code d'erreur 1
}

function display_success() {
    echo "${SUCCESS_ICON} $1"
}

function display_warning() {
    echo "${WARNING_ICON} $1" >&2
}

function display_info() {
    echo "${INFO_ICON} $1"
}

function insert_log() {
    local log_message="$1"
    local log_file="$LOGS_DIR/installation.log"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $log_message" >> "$log_file"
}

# Affiche un ASCII de bienvenue
echo "                                   __ _                                                  "
echo "  ___    ___    _ __    ___   _   / _\` |         _ __ ___     __ _    ___    ___    ___  "
echo " / __|  / _ \\  | '_ \\  | __| (_) | (_| |  ____  | '_ \` _ \\  / _\` |  / __|  / _ \\  / __|"
echo "| (__  | (_) | | | | | | _|  | |  \\__, | |____| | | | | | || (_| | | (__  | (_) | \\__ \\"
echo " \\___|  \\___/  |_| |_| |_|   |_|    |_|         |_| |_| |_| \\__,_|  \\___|  \\___/  |___/"
insert_newline

# Vérifie si l'utilisateur a lancé le script en superutilisateur
if [ "$EUID" -ne 0 ]; then
    display_error "Ce script doit être exécuté avec les permissions de superutilisateur."
else
    display_success "Exécution avec les permissions de superutilisateur confirmée."
fi

# Vérifie que le script a été lancé via 'sudo' et non directement en root
# (nécessaire pour exécuter Homebrew en tant qu'utilisateur normal)
if [ -z "$SUDO_USER" ]; then
    display_error "Impossible de déterminer l'utilisateur d'origine. Lancez le script avec 'sudo' et non directement en root."
fi

# Wrapper : exécute les commandes Homebrew en tant qu'utilisateur normal
function brew_as_user() {
    sudo -u "$SUDO_USER" brew "$@"
}

insert_newline

# Vérifie si le script est utilisé sur macOS
if [[ "$OSTYPE" != darwin* ]]; then
    display_error "Ce script doit être exécuté sur un environnement OS X/macOS."
else
    display_success "Environnement OS X/macOS confirmé."
fi

insert_newline

# Créer les dossiers et fichiers nécessaires
display_info "Création des dépendances nécessaires..."

# Création du répertoire qui contient les différentes configurations de l'ordinateur
# Les fichiers JSON pourront être modifiés par l'utilisateur pour personnaliser les configurations

# Vérifie si le répertoire de configuration existe déjà
if [ -d "config" ]; then
    display_warning "Le répertoire de configuration existe déjà. Il ne sera pas recréé."
else
    display_info "Le répertoire de configuration sera créé."
fi

insert_newline

# Vérifie si le dossier de configuration existe déjà avant de le créer
if [ -d "config" ]; then
    display_warning "Le répertoire de configuration existe déjà. Il ne sera pas recréé."
else
    display_info "Le répertoire de configuration sera créé."
    mkdir config
fi

# Vérifie s'il y a une erreur lors de la création du répertoire de configuration
if [ $? -ne 0 ]; then
    display_error "La création du répertoire de configuration a échoué."
else
    display_success "Le répertoire de configuration a été créé avec succès."
fi

# Vérifie si les fichiers de configuration existent déjà
if [ -f "config/settings.json" ] || [ -f "config/applications.json" ] || [ -f "config/tweaks.json" ]; then
    display_warning "Les fichiers de configuration existent déjà. Ils ne seront pas écrasés."
else
    display_info "Les fichiers de configuration seront créés."
    touch config/settings.json
    touch config/applications.json
    touch config/tweaks.json

    # Vérifie s'il y a une erreur lors de la création des fichiers de configuration
    if [ $? -ne 0 ]; then
        display_error "La création des fichiers de configuration a échoué."
    else
        display_success "Les fichiers de configuration ont été créés avec succès."
        display_info "Vous pouvez maintenant personnaliser les fichiers de configuration dans le dossier 'config'."

        # Demande à l'utilisateur s'il souhaite ouvrir les fichiers de configuration pour les personnaliser
        read -p "Voulez-vous ouvrir les fichiers de configuration pour les personnaliser ? (y/n) " answer
        if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
            vim config/settings.json
            vim config/applications.json
            vim config/tweaks.json
        else
            display_info "Vous pouvez personnaliser les fichiers de configuration plus tard en les ouvrant dans le dossier 'config'."
            display_warning "Si les fichiers de configuration sont vides ou éronés, le script d'installation utilisera la configuration par défaut."
            display_info "Pour obtenir des modèles de configuration, consultez le dépôt GitHub (https://github.com/enioaiello/config-macos)."
        fi
    fi
fi

# Vérifie si les dossiers de logs et de données existent déjà
if [ -d "logs" ] || [ -d "data" ]; then
    display_warning "Les dossiers de logs ou de données existent déjà. Ils ne seront pas recréés."
else
    display_info "Les dossiers de logs et de données seront créés."
    mkdir logs
    mkdir data
    mkdir data/wallpapers
    mkdir data/scripts
fi

# Vérifie s'il y a une erreur lors de la création des dépendances
if [ $? -ne 0 ]; then
    display_error "La création des dépendances a échoué."
else
    display_success "Les dépendances nécessaires ont été créées avec succès."
fi

# Vérifie si Homebrew est installé
if ! sudo -u "$SUDO_USER" command -v brew &> /dev/null; then
    # Installe Homebrew en tant qu'utilisateur normal (Homebrew refuse d'être installé en root)
    display_info "Homebrew n'est pas installé. Installation de Homebrew..."
    sudo -u "$SUDO_USER" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    display_success "Homebrew est déjà installé."
fi

# Demande à l'utilisateur s'il souhaite mettre à jour Homebrew et les formules avant de continuer
echo "Voulez-vous mettre à jour Homebrew et les formules avant de continuer ?"
select yn in "Oui" "Non"; do
    case $yn in
        Oui ) brew_as_user update && brew_as_user upgrade; break;;
        Non ) display_warning "La mise à jour de Homebrew et des formules a été ignorée. Il est recommandé de les mettre à jour pour éviter les problèmes de compatibilité."; break;;
    esac
done

function open_corundum_quick() {
    display_info "Ouverture de Corundum Quick dans votre navigateur..."
    open "$corundum_quick_url"
    echo "Veuillez sélectionner les applications que vous souhaitez installer, cliquer sur installer et copier-coller la liste d'applications proposée dans le terminal pour installer les applications sélectionnées."
    # Propose un input pour que l'utilisateur puisse coller la liste d'applications à installer
    read -p "Collez la liste d'applications à installer (séparées par des espaces) : " applications_to_install
    # Installe les applications sélectionnées via Homebrew
    for app in $applications_to_install; do
        display_info "Installation de l'application '$app'..."
        brew_as_user install --cask "$app"
        if [ $? -ne 0 ]; then
            display_warning "L'installation de l'application '$app' a échoué."
            echo "L'installation pour cette application a été ignorée. Veuillez vérifier que le nom de l'application est correct et que l'application est disponible dans Homebrew."
        else
            display_success "L'application '$app' a été installée avec succès."
        fi
    done
}

function install_applications_from_config() {
    display_info "Installation des applications depuis le fichier 'config/applications.json'..."
    # Vérifie si le fichier de configuration des applications est vide
    if [ ! -s "config/applications.json" ]; then
        display_warning "Le fichier 'config/applications.json' est vide. Aucune application ne sera installée via Homebrew."
        return
    fi

    # Lit le fichier de configuration des applications et installe les applications listées
    applications=$(jq -r '.applications[]' config/applications.json)
    for app in $applications; do
        display_info "Installation de l'application '$app'..."
        brew_as_user install --cask "$app"
        if [ $? -ne 0 ]; then
            display_warning "L'installation de l'application '$app' a échoué."
            echo "L'installation pour cette application a été ignorée. Veuillez vérifier que le nom de l'application est correct et que l'application est disponible dans Homebrew."
        else
            display_success "L'application '$app' a été installée avec succès."
        fi
    done
}

# Demande à l'utilisateur s'il a une liste d'applications à installer via Homebrew ou s'il souhaite choisir des applications à installer depuis Corundum Quick
echo "Avez-vous une liste d'applications ?"
echo "Si oui, veuillez les ajouter au fichier 'config/applications.json' avant de continuer."
echo "Si non, le script ouvrira Corundum Quick. Sélectionnez vos applications, cliquez sur installer et copiez-collez la commande d'installation dans le terminal pour installer les applications sélectionnées."
select yn in "Homebrew" "Quick" "Ignorer"; do
    case $yn in
        Homebrew ) install_applications_from_config; break;;
        Quick ) open_corundum_quick; break;;
        Ignorer ) display_info "Vous avez choisi d'ignorer l'installation des applications."; break;;
    esac
done