#!/bin/bash

# Will exit script if we would use an uninitialised variable:
# either set -u or set -o nounset
set -o nounset

# Will exit script when a simple command (not a control structure) fails:
# either set -e or set -o errexit
set -o errexit

# This setting prevents errors in a pipeline from being masked.
set -o pipefail

#set -x

# Useful string splitting behaviour occurs with IFS=$'\n\t'
# The default is to split on spaces, tabs and newlines $' \n\t'
IFS=$'\n\t'

# Set variables:
declare -grix  TRUE=0
declare -grix FALSE=1

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

String()
(
    function counter()
    (

        echo "$@"

    )
)

function pass_back_a_string()
{
    #eval "echo in pass_back_a_string, original $1 is \$$1"
    #local result=911
    local result="some result to return, in this case, a string."
    eval "$1=\${result}"
}

return_var='original string'
pass_back_a_string return_var
#echo $return_var


declare str="'$*'"
echo "str is $str"

foo()
{
    local result=""
    local NEWLINE=$'\n'
    while read -r line
    do
        if [[ $line == "EOF" ]]
        then
            break
        fi
        result+="${line}"$NEWLINE
        
    done
    #echo "hi${NEWLINE}mag"
    eval "$1=\${result}"
}
foo return_var
echo "return var is $return_var"

exit

__=""
_stdin=""

read -N1 -t1 __  && {
  (( $? <= 128 ))  && {
    IFS= read -rd '' _stdin
    _stdin="$__$_stdin"
  }
}

echo "-------------------------------"
echo "$__"
echo "$_stdin"
echo "$@"
echo "$#"

exit

declare myVar=$(tee)

echo "Number of ARGS: $#"

while read -r line
do
    echo "$line"
    if [[ $line == "EOF" ]]
    then
        break
    fi
done <&0

echo "Number of ARGS: $#"