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