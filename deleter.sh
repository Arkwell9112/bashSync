#!/usr/bin/env bash

totreat=false #Fonction permettant de supprimer un fichier ou un répertoire de la synchronisation (sinon si les deux ne supprime pas simultanément des deux arebres à la prochaine syncronisation le fichier restant sera à nouveau copié.
if [[ -d $1$3 || -d $2$3 ]]; then
    totreat=true
fi
if [[ -e $1$3 ]]; then
    ./recursivedel.sh $1 $2 $3
else
    ./recursivedel.sh $2 $1 $3
fi
if [[ ${totreat} == true ]]; then
    rm -r -f $1$3
    rm -r -f $2$3
fi
