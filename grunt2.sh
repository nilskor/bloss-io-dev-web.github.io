#!/bin/bash

# Will exit script if we would use an uninitialised variable:
# either set -u or set -o nounset
set -o nounset

# Will exit script when a simple command (not a control structure) fails:
# either set -e or set -o errexit
set -o errexit

# This setting prevents errors in a pipeline from being masked.
set -o pipefail

#set -vx

# Useful string splitting behaviour occurs with IFS=$'\n\t'
# The default is to split on spaces, tabs and newlines $' \n\t'
IFS=$'\n\t'

# Set variables:
declare -grix  TRUE=0       # g - global scope; r - read-only; i - integer; x - exportable
declare -grix FALSE=1

declare -a ARGS=()          # a - indexed array

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

function usage()
(
    echo "usage goes here"
)

function readInput()
{
    local result=""
    local NEWLINE=$'\n'
    local REPLY=""
    
    while read -r line
    do
        if [[ $line == "EOF" ]]
        then
            break
        fi
        #result+="${line}"$NEWLINE
        ARGS+=($line)    # Push
    done
    #eval "$1=\${result}"

}

echo "\$? $?"

if [[ -t 0 ]]
then
    echo "true, input from typing a command line of arguments"

    if   [[ $# -eq 0 ]]
    then
        usage

    elif [[ $# -gt 0 ]]
    then
        ARGS=("$@")

        for index in "${ARGS[@]}"
        do
            if [[ $index == "-hd" ]]
            then
                #declare hereDoc=""
                readInput #hereDoc
                #echo -e "$hereDoc"

            fi
        done

    fi

else
    echo "false, some input came via redirection"

    #if   [[ $# -eq 0 ]]
    #then
    #    usage

    #elif [[ $# -gt 0 ]]
    #then
        ARGS=("$@")
        #declare hereDoc=""
        readInput #hereDoc
        #echo -e "$hereDoc"

    #fi

fi



if [[ ${#ARGS[@]} -gt 0 ]]
then
    echo -e "${ARGS[@]}"

fi
