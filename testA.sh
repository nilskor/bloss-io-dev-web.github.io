#!/bin/bash

# Will exit script if we would use an uninitialised variable:
# either set -u or set -o nounset
set -o nounset

# Will exit script when a simple command (not a control structure) fails:
# either set -e or set -o errexit
set -o errexit

# This setting prevents errors in a pipeline from being masked.
set -o pipefail

# Useful string splitting behaviour occurs with IFS=$'\n\t'
# The default is to split on spaces, tabs and newlines $' \n\t'
IFS=$'\n\t'

# Set variables:
#declare -grix  TRUE=0
#declare -grix FALSE=1

function   setIFS(){ IFS=$'\n\t'; }
function unsetIFS(){ IFS= ;       }

function echo()
(
    fmt=%s end=\\n IFS=" "

    while [ $# -gt 1 ]
    do
        case "$1" in
            [!-]*|-*[!ne]*) break ;;
            *ne*|*en*) fmt=%b end= ;;
            *n*) end= ;;
            *e*) fmt=%b ;;
        esac
        shift
    done

    printf ":: $fmt$end" "$*"
)


function someFunction1()
{
    echo "someFunction1() $#, $@"

    local result=""
    result="freddo frog"
    eval "$1=\${result}"
}

names="Netgear
Hon Hai Precision Ind. Co.
Apple"

unsetIFS

IFS=$'\n'      # Change IFS to new line

names=($names) # split to array $names

setIFS

for (( i=0; i<${#names[@]}; i++ ))
do
    echo "$i: ${names[$i]}"
done
