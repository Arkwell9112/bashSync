#!/usr/bin/env bash

diff -u $1 $2
echo "Veuillez entrez - si vous voulez que le fichier représenté par + soit écrasè ou inversement."
echo "Dans le cas des fichiers binaires, le fichier représenté par - est le premier fichier listé."
while read -p "+/- ?: " answer </dev/tty; do
    case ${answer} in
    -)
        exit 0
    ;;
    +)
        exit 1
    esac
    echo "+/- ?: "
done
