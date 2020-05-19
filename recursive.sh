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
            ./ecriture $3${file} ${size} ${admin} ${date}
            ./recursive.sh $1 $2 $3
        elif [[ ${tab[2]} == ${size} && ${tab[3]} == ${admin} && ${tab[4]} == ${date} ]]; then
            if [[ -f $2$3${file} ]]; then
                othersize=$(stat -c %s $2$3${file})
                otheradmin=$(stat -c %a $2$3${file})
                otherdate=$(stat -c %Y $2$3${file})
                if [[ ${tab[2]} != ${othersize} || ${tab[3]} != ${otheradmin} || ${tab[4]} != ${otherdate} ]]; then
                    mkdir -p $1$3 && cp $2$3${file} $1$3${file}
                    touch $2$3${file}
                    ./ecriture $3${file} ${othersize} ${otheradmin} $(stat -c %Y $2$3${file})
                fi
            else
                mkdir -p $2$3 && cp $1$3${file} $2$3${file}
                touch $1$3${file}
                ./ecriture $3${file} ${size} ${admin} $(stat -c %Y $1$3${file})
            fi
        else
            if [[ -f $2$3${file} ]]; then
                othersize=$(stat -c %s $2$3${file})
                otheradmin=$(stat -c %a $2$3${file})
                otherdate=$(stat -c %Y $2$3${file})
                if [[ ${tab[2]} == ${othersize} && ${tab[3]} == ${otheradmin} && ${tab[4]} == ${otherdate} ]]; then
                    mkdir -p $2$3 && cp $1$3${file} $2$3${file}
                    touch $1$3${file}
                    ./ecriture $3${file} ${size} ${admin} $(stat -c %Y $1$3${file})
                else
                    echo 'Conflict'
                fi
            else
                mkdir -p  $2$3 && cp $1$3${file} $2$3${file}
                touch $1$3${file}
                ./ecriture $3${file} ${size} ${admin} $(stat -c %Y $1$3${file})
            fi
        fi
    elif [[ -d $1$3${file} ]]; then
        ./recursive.sh $1 $2 "$3$file/"
    fi
done< <(ls $1$3)