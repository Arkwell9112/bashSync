#!/usr/bin/env bash

while read file; do
    if [[ -f $1$3${file} ]]; then
        entry=$(./appel_lecture $3${file})
        size=$(stat -c %s $1$3${file})
        admin=$(stat -c %a $1$3${file})
        date=$(stat -c %Y $1$3${file})
        IFS='|'
        read -a tab <<< ${entry}
        if [[ ${tab[0]} == 0 ]]; then
            ./ecriture $3$1 ${size} ${admin} ${date}
            echo 'Bonjour les gars'
        elif [[ ${tab[1]} == ${size} && ${tab[2]} == ${admin} && ${tab[3]} == ${date} ]]; then
            if [[ -f $2$3${file} ]]; then
                othersize=$(stat -c %s $2$3${file})
                otheradmin=$(stat -c %a $2$3${file})
                otherdate=$(stat -c %Y $2$3${file})
                if [[ ${tab[1]} != ${othersize} || ${tab[2]} != ${otheradmin} || ${tab[3]} != ${otherdate} ]]; then
                    mv $2$3${file} $1$3${file}
                    ./ecriture $3${file} ${othersize} ${otheradmin} ${otherdate}
                fi
            else
                mv $1$3${file} $2$3${file}
                ./ecriture $3${file} ${size} ${admin} ${date}
            fi
        else
            if [[ -f $2$3${file} ]]; then
                othersize=$(stat -c %s $2$3${file})
                otheradmin=$(stat -c %a $2$3${file})
                otherdate=$(stat -c %Y $2$3${file})
                if [[ ${tab[1]} == ${othersize} && ${tab[2]} == ${otheradmin} && ${tab[3]} == ${otherdate} ]]; then
                    mv $1$3${file} $2$1${file}
                    ./ecriture $3${file} ${size} ${admin} ${date}
                else
                    echo 'Conflict'
                fi
            else
                mv $1$3${file} $2$1${file}
                ./ecriture $3${file} ${size} ${admin} ${date}
            fi
        fi
    elif [[ -d $1$3${file} ]]; then
        ./recursive.sh $1 $2 "$3$file/"
    fi
done< <(ls $1$3)