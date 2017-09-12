#!/bin/bash
# Usage: ./copyOldCardsFor2017.sh <old folder name>
# example: ./copyOldCardsFor2017.sh dyellell012j_5f_NLO_FXFX

if [ -z $1 ]; then
    echo "You need to enter the folder name as an argument"
    echo "ex: ./copyOldCardsFor2017.sh dyellell012j_5f_NLO_FXFX"
    exit 1
fi

base_folder=$(git rev-parse --show-toplevel)/bin/MadGraph5_aMCatNLO

old_cards_path=cards/production/13TeV/$1
new_cards_path=cards/production/2017/$1
git checkout tags/pre2017 -- $old_cards_path

for old_card in $(find $old_cards_path -type f -follow -print); do 
    old_card=$base_folder/$old_card
    echo $old_card
    new_card=${old_card/13TeV/2017}
    card_dir=$(dirname $new_card)
    if [ ! -d $card_dir ]; then
        mkdir -p $card_dir
    fi
    mv $old_card $new_card
    git add $new_card
    git rm $old_card
done

git commit -m "Copying $1 cards from legacy production to modify for 2017"

for run_card in $(find $new_cards_path -type f -follow -print -name "*run_card*"); do 
    sed -i "s/^ [0-9]* *= *lhaid/\$DEFAULT_PDF_SETS = lhaid/g" $run_card
    sed -i "s/.*= *reweight_PDF/\$DEFAULT_PDF_MEMBERS = reweight_PDF/g" $run_card
    sed -i "s/.*= *PDF_set_min//g" $run_card
    sed -i "s/.*= *PDF_set_max//g" $run_card
    git add $run_card
done

git commit -m "Updating PDF sets to 2017 defaults for $1"
