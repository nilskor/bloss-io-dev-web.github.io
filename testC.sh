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

    printf "$fmt$end" "$*"
    setIFS
)

source ./StringFunctions

# https://stackoverflow.com/a/10583562/7791211 - use of eval to return arrays (pass ByVal)
# https://stackoverflow.com/a/49971213/7791211 - use local -n to return arrays (pass ByRef)

#_sc Find '<a .*?</a>' ./scratchpad.txt -sm

declare data='some
dummy extrå long
string that needs cöunting'

declare foundIt
declare doCaseInsensitive='-i'
declare thePattern='<a .*?</a>'

#grep -Pazo $doCaseInsensitive "(?s)$thePattern" ./scratchpad.txt

#echo -e "\n\n::------------------::\n"

exec 3>&2
exec 2> /dev/null
foundIt=$(grep -Pazo -m1 $doCaseInsensitive "(?s)$thePattern" ./scratchpad.txt | head -zn 1) || foundIt=""
exec 2>&3

#echo -e "$foundIt"

function test1()
{
    local complexResult1

    exec 3>&2
    exec 2> /dev/null

    complexResult1=$(grep -Pazo -m1 $doCaseInsensitive "(?s)$thePattern" ./scratchpad.txt | head -zn 1) || foundIt=""
    
    exec 2>&3
    
    eval "$1=\${complexResult1}"

}

declare fred # returned as an eval statement

test1 fred   # returned as an eval statement

echo -e "$fred"
echo -e "$(_sc Len "$fred")"

if [[ ${#fred} -gt 0 ]]
then

    foundIt=($foundIt)
    nextChunk="$stringToBeSearched"
    iPos=0
    iPrevPos=1
    iPrevLen=0

    for item in ${foundIt[@]}
    do
        iPos=$(_sc Find "$item" "$nextChunk")
        iLen=$(_sc Len "$item")
        nextChunk=${nextChunk#*$item}
        iCalc=$(( $iPos + $iPrevPos + $iPrevLen - 1 ))
        ArrayOfStrings[$iCalc]="$item"
        iPrevPos=$iCalc
        iPrevLen=$iLen
    
    done

fi
