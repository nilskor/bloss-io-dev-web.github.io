#!/bin/bash

input="all-html-files-justName.log"

name=""

while IFS= read -r line
do

    name="$line"
    echo "$name"

done < "$input"

