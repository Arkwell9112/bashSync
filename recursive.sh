#!/usr/bin/env bash

while read file; do
    if [[ -f $1$3${file} ]]; then
        #On récupère dans un premier temps les informations sur le fichier en cour pour l'arbre 1.
        entry=$(./appel_lecture $3${file})
        size=$(stat -c %s $1$3${file})
        admin=$(stat -c %a $1$3${file})
        date=$(stat -c %Y $1$3${file})
        IFS='|'
        read -a tab <<< ${entry} #On récupère les informations sur ce fichier qui sont stockées dans le journal.
        if [[ ${tab[0]} == 0 ]]; then #Si le journal est vide pour ce fichier on l'ajoute et ensuite on rappel la fonction récursive.
            ./ecriture $3${file} ${size} ${admin} ${date}
            ./recursive.sh $1 $2 $3
        elif [[ ${tab[2]} == ${size} && ${tab[3]} == ${admin} && ${tab[4]} == ${date} ]]; then #Si notre fichier n'a pas été modifié on compare ses métadonnées avec celles du même fichier dans l'auyre arbre. On effectue les actions nécessaires en fonction.
            if [[ -f $2$3${file} ]]; then #Si le fichier existe dans l'autre arbre on remplace le notre avec le fichier modifié, si l'auyre n'a pas été modifié non plus on ne fait rien.
                othersize=$(stat -c %s $2$3${file})
                otheradmin=$(stat -c %a $2$3${file})
                otherdate=$(stat -c %Y $2$3${file})
                if [[ ${tab[2]} != ${othersize} || ${tab[3]} != ${otheradmin} || ${tab[4]} != ${otherdate} ]]; then
                    mkdir -p $1$3 && cp -p $2$3${file} $1$3${file}
                    touch $2$3${file}
                    touch $1$3${file}
                    ./ecriture $3${file} ${othersize} ${otheradmin} $(stat -c %Y $2$3${file})
                fi
            else # SI le fichier n'existe pas dans l'autre arbre on copie celui de cet arbre vers l'autre arbre.
                mkdir -p $2$3 && cp -p $1$3${file} $2$3${file}
                touch $1$3${file}
                touch $2$3${file}
                ./ecriture $3${file} ${size} ${admin} $(stat -c %Y $1$3${file})
            fi
        else #SI notre fichier a été modifié on compare avec l'autre pour voir que faire.
            othersize=$(stat -c %s $2$3${file})
            otheradmin=$(stat -c %a $2$3${file})
            otherdate=$(stat -c %Y $2$3${file})
            if [[ -f $2$3${file} ]]; then # SI l'autre fichier existe, on regarde si il a été modifié si non on copie le notre si oui il y a conflit.
                if [[ ${tab[2]} == ${othersize} && ${tab[3]} == ${otheradmin} && ${tab[4]} == ${otherdate} ]]; then
                    mkdir -p $2$3 && cp -p $1$3${file} $2$3${file}
                    touch $1$3${file}
                    touch $2$3${file}
                    ./ecriture $3${file} ${size} ${admin} $(stat -c %Y $1$3${file})
                else # Il y a conflit on vérifie si ce n'est pas juste un conflit de métadonnées, sinon on demande à l'utilisateur quel fichier il souhaite garder.
                    if [[ ${otherdate} > ${date} && $(diff $1$3${file} $2$3${file}) == "" ]]; then
                        mkdir -p $2$3 && cp -p $1$3${file} $2$3${file}
                        touch $1$3${file}
                        touch $2$3${file}
                        ./ecriture $3${file} $(stat -c %s $1$3${file}) $(stat -c %a $1$3${file}) $(stat -c %Y $1$3${file})
                    elif [[ $(diff $1$3${file} $2$3${file}) == "" ]]; then
                        mkdir -p $1$3 && cp -p $2$3${file} $1$3${file}
                        touch $1$3${file}
                        touch $2$3${file}
                        ./ecriture $3${file} $(stat -c %s $1$3${file}) $(stat -c %a $1$3${file}) $(stat -c %Y $1$3${file})
                    else
                        ./gconflict.sh $1$3${file} $2$3${file}
                        if [[ $? == 0 ]]; then
                            mkdir -p $2$3 && cp -p $1$3${file} $2$3${file}
                            touch $1$3${file}
                            touch $2$3${file}
                            ./ecriture $3${file} $(stat -c %s $1$3${file}) $(stat -c %a $1$3${file}) $(stat -c %Y $1$3${file})
                        else
                            mkdir -p $1$3 && cp -p $2$3${file} $1$3${file}
                            touch $1$3${file}
                            touch $2$3${file}
                            ./ecriture $3${file} $(stat -c %s $1$3${file}) $(stat -c %a $1$3${file}) $(stat -c %Y $1$3${file})
                        fi
                    fi
                fi
            else # Si l'autre fichier n'existe pas il suffit alors de copier le notre dans l'autre arbre.
                mkdir -p  $2$3 && cp -p $1$3${file} $2$3${file}
                touch $1$3${file}
                touch $2$3${file}
                ./ecriture $3${file} ${size} ${admin} $(stat -c %Y $1$3${file})
            fi
        fi
    elif [[ -d $1$3${file} ]]; then # Si le fichier balayé n'est pas un fichier mais un dossier on appel la fonction récursive.
        ./recursive.sh $1 $2 "$3$file/"
    fi
done< <(ls $1$3 2> /dev/null)