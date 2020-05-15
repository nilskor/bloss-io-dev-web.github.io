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
declare -ri  TRUE=0          # g - global scope; r - read-only; i - integer; x - exportable
declare -ri FALSE=1

declare -a  ARGS=()          # a - indexed array
declare -a LINES=()


#----------------------------------------------------------
# Overridden Echo function - www.etalabs.net/sh_tricks.html
#----------------------------------------------------------
#
function echo()
{
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
}

function usage()
(
    echo -e ""
    echo -e "usage goes here"
    echo -e "All Here Document, Here-doc or Heredoc style input must end with a plain 'EOF' eg. EOF"
    echo -e ""
)

#----------------------------------------------------------
# Read Here-Docs either directly or forced with '-hd'
#----------------------------------------------------------
#
function readInput()
{
    while read -r line
    do
        if [[ $line == "EOF" ]]
        then
            break
        fi
        LINES+=($line$'\n')    # Push  # new-line is :   $'\n'
    done
}

function _countLines()
{
    #echo -e "Number of elements in LINES is: ${#LINES[@]}"
    #echo -e "Command line passed to 'countLines' is: $@"

    local _return_countLines

    if [[ $# -eq 0 || -z $1 ]] && [[ ${#LINES[@]} -gt 0 ]]
    then
        #echo "${#LINES[@]}"
        returnResult="${#LINES[@]}"
        eval "$1=\${returnResult}"

    elif [[ $# -eq 1 || $2 == "-?" || $2 == "--help" || $2 == "-h" || -z $2 ]]
    then

        echo -e "\n countLines inputFileName <or> \"some string\" <or> <<Here-document ending with EOF\n"

    elif [[ -f $2  ]]
    then

        declare -i result="$(wc --lines $2 | gawk {'print $1'})" # gawk print $1 shouldn't be changed ..
        if [[ $result -gt 1 ]]
        then
                result=$((++result))
        fi
        #echo "$result"
        returnResult="$result"
        eval "$1=\${returnResult}"

    else

        #echo -e "Just about to count lines .. $@"
        #declare -i result="$(wc --lines <<< $@)"
        declare -i result=$(wc --lines <<< "${@}")
        #echo -e "Just did the count and found $result lines in $@."
        #if [[ $result -gt 1 ]]
        #then
        #        result=$((++result))
        #fi

        #echo -e "Number of elements in LINES is: ${#LINES[@]}, ${LINES[@]}"
        if [[ ${#LINES[@]} -gt 0 ]]
        then
            result+=${#LINES[@]}

        fi

        #echo "$result"

        printf -v _return_countLines %q $result
        #_return_countLines="freddo frog"
        eval "$1=\${_return_countLines}"

    fi

}

function _countWords()
{
        local _return_countWords
        _return_countWords="freddo frog"
        eval "$1=\${_return_countWords}"
}

#--------------------------------------------------------
# The Strings pseudo-class of string functions
#--------------------------------------------------------
#
StringClass()
(
    showUsage()
    (
        declare APIs=""
        echo -e "\n The following is a list of all the declared string functions available in this module.\n"
        APIs="$(declare -F)"
        APIs="${APIs//declare -f/.\/StringFunctions}"
        for apiName in ${APIs[@]}
        do
            echo "$apiName"
        done
        echo -e "\n All Here Document, Here-doc or Heredoc style input must end with a plain 'EOF' eg. EOF"
        echo ""

    ) >&2
    
    isValidArg()
    (
        test "$(type -t "$1")" = "function"
    )

    countLines()
    (
        local _result
        _countLines _result "$@"
        [ ! -z "${_result:-}" ] && echo -e "$_result"
    )

    countWords()
    (
        local _result
        _countWords _result "$@"
        [ ! -z "${_result:-}" ] && echo -e "$_result"
    )

    #--------------------------------
    # Parameter check for StringClass
    #--------------------------------
    #
    if [[ $# -gt 0 ]]
    then

        if isValidArg $@
        then
            "$@"
        else
            showUsage
        fi

    else
        showUsage
    fi
)

#--------------------------------------------------------
# Process the "real" command line that called this script
#--------------------------------------------------------
#
if [[ -t 0 ]]      # input comes only from the string on the command line - no redirection.
then

    #if   [[ $# -eq 0 ]]
    #then
    #    #usage
    #    #StringClass showUsage
    #    echo
    #
    #elif [[ $# -gt 0 ]]
    if [[ $# -gt 0 ]]
    then

        if [[ ${1:0:1} == "-" ]] && [[ ${1:1:1} =~ [[:graph:]] ]]
        then
            #echo "found invalid option"
            StringClass showUsage
            exit
        fi

        ARGS=("$@")

        for index in "${ARGS[@]}"
        do
            if [[ $index == "-hd" ]]
            then
                readInput # read more input into the ARGS array
            fi
        done

    fi

else               # input comes from redirection.

    ARGS=("$@")
    readInput  # read more input into the ARGS array

fi

#----------------------------------------------------------
# Then, send all known command line data into StringClass()
#----------------------------------------------------------
#
if [[ ${#ARGS[@]} -gt 0 ]]
then

    #echo -e "${ARGS[@]}"
    StringClass "${ARGS[@]}"

fi
