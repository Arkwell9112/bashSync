#!/usr/bin/env bash
# Petit script permettant de balayer les deux arbres pour n'oublier aucuns fichiers.
./recursive.sh $1 $2 $3
./recursive.sh $2 $1 $3