#!/usr/bin/bash

read -a ARR <<< "$1"

git checkout $2

for i in "${ARR[@]}"; do
    git cherry-pick $i -X theirs --allow-empty;
done

git checkout dev
