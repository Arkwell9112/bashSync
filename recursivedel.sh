#!/usr/bin/env bash

while read file; do
    if [[ -f $1$3${file} || -f $2$3${file} ]]; then #Si le fichier est un fichier alors on le supprime des deux arbres et enfin on supprime l'entrée dans le journal.
        rm -f $1$3${file}
        rm -f $2$3${file}
        ./delete $3${file}
    elif [[ -d $1$3${file} || $2$3${file} ]]; then #Si le fichier est un dossier alors on lance l'application récursive.
        ./recursivedel.sh $1 $2 "$3$file/"
    fi
done< <(ls $1$3 2> /dev/null)