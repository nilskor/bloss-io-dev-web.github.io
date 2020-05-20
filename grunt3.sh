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

declare RED='\033[1;31m'     # actually a light Red to be exact :)
declare GREEN='\033[0;32m'
declare NC='\033[0m'         # No Color

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
    #echo -e "Number of elements in ARGS is: ${#ARGS[@]}"
    #echo -e "Elements of ARGS are: ${ARGS[@]}"

    local -i n=0
    for arg in $@
    do
        let "n+=1"
        #echo -e "Individual arg is: $arg, and index is $n"
        if [[ $arg == "-hd" ]]
        then
            set -- "${@:1:n-1}" "${@:n+1}" # remove n'th positional argument - stackoverflow.com/a/23656370
        fi
    done

    #echo -e "Number of elements in LINES is: ${#LINES[@]}"
    #echo -e "Command line after cleaning is: $@"
    #echo -e "Number of elements in '\$@' is $#."

    local _return_countLines

    if [[ $# -eq 1 ]] && [[ ${#LINES[@]} -gt 0 ]]
    then
        #echo "${#LINES[@]}"
        _return_countLines="${#LINES[@]}"
        eval "$1=\${_return_countLines}"

    elif [[ $# -eq 1 || $2 == "-?" || $2 == "--help" || $2 == "-h" || -z $2 ]]
    then

        echo -e "\n countLines inputFileName <or> \"some string\" <or> <<Here-document ending with EOF\n"

    elif [[ -f $2  ]]
    then

        declare -i result="$(wc --lines $2 | gawk {'print $1'})" # gawk print $1 shouldn't be changed ..
        #if [[ $result -gt 1 ]]
        #then
        #        result=$((++result))
        #fi
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
        #echo "here"
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

    local -i n=0
    for arg in $@
    do
        let "n+=1"
        #echo -e "Individual arg is: $arg, and index is $n"
        if [[ $arg == "-hd" ]]
        then
            set -- "${@:1:n-1}" "${@:n+1}" # remove n'th positional argument - stackoverflow.com/a/23656370
        fi
    done

    local _return_countWords

    #if [[ $# -eq 0 || -z $1 ]] && [[ ${#LINES[@]} -gt 0 ]]
    if [[ $# -eq 1 || -z $2 ]] && [[ ${#LINES[@]} -gt 0 ]]
    then

        returnResult="${#LINES[@]}"
        eval "$1=\${returnResult}"

    elif [[ $# -eq 1 || $2 == "-?" || $2 == "--help" || $2 == "-h" || -z $2 ]]
    then

        echo -e "\n countWords inputFileName <or> \"some string\" <or> <<Here-document ending with EOF\n"

    elif [[ -f $2  ]]
    then

        declare -i result="$(wc --words $2 | gawk {'print $1'})" # gawk print $1 shouldn't be changed ..

        #returnResult="$result"
        #eval "$1=\${returnResult}"
        printf -v _return_countWords %q $result
        eval "$1=\${_return_countWords}"

    else

        declare -i result=$(wc --words <<< "${@}")
        result=$((result-1))

        if [[ ${#LINES[@]} -gt 0 ]]
        then
            result+=${#LINES[@]}

        fi

        printf -v _return_countWords %q $result
        eval "$1=\${_return_countWords}"

    fi

}

function _stringLength()
{
    # <SIGNATURE>: (0)_stringLength (1)_result (2)someStringToSearch

    # small pre-processor to remove '-hd' from the argument list.
    local -i n=0
    for arg in $@
    do
        let "n+=1"
        if [[ $arg == "-hd" ]]
        then
            set -- "${@:1:n-1}" "${@:n+1}" # remove n'th positional argument - stackoverflow.com/a/23656370
        fi
    done

    # main part of the function

    local _return_stringLength

    declare -i result=0

    if [[ $# -eq 1 || -z $2 ]] && [[ ${#LINES[@]} -gt 0 ]]
    then

        returnResult="${#LINES[@]}"
        returnResult=$(( returnResult ))
        eval "$1=\${returnResult}"

    elif [[ $# -eq 1 || $2 == "-?" || $2 == "--help" || $2 == "-h" || -z $2 ]]
    then
        echo -e "\n stringLength someString or 'some continuous string that is quoted'\n"

    elif [[ $# -eq 2 ]] && [[ -f $2  ]]
    then
        stringToBeSearched="$(< $2)"
        result="$(( ${#stringToBeSearched} ))"
        printf -v _return_stringLength %q $result
        eval "$1=\${_return_stringLength}"

    else

        result="$(( ${#2} ))"
        printf -v _return_stringLength %q $result
        eval "$1=\${_return_stringLength}"

    fi

}

function _stringFind()
{
    # <SIGNATURE>: (0)_stringFind (1)_result (2)searchPattern (3)someStringToSearch
    
    # small pre-processor to remove '-hd' from the argument list.
    local -i n=0
    for arg in $@
    do
        let "n+=1"
        if [[ $arg == "-hd" ]]
        then
            set -- "${@:1:n-1}" "${@:n+1}" # remove n'th positional argument - stackoverflow.com/a/23656370
        fi
    done

    # main part of the function

    local -i _return_stringFind=0

    if [[ $# -le 1 ]]
    then
        echo -e "missing arguments"
        echo -e "The command syntax is: stringFind searchPattern someStringToSearch"

    elif [[ $# -eq 3 ]] || [[ $# -eq 2 && ${#LINES[@]} -gt 0 ]]
    then
        
        if [[ $# -eq 3 ]] && [[ -f $3  ]]
        then
                #stringToBeSearched="$(sed -rn 's/.*/&/p' $3)"
                stringToBeSearched="$(< $3)"
        
        elif [[ $# -eq 3 ]]
        then
                stringToBeSearched="${3} ${LINES[@]}"
        
        elif [[ $# -eq 2 ]] && [[ ${#LINES[@]} -gt 0 ]]
        then
                stringToBeSearched="${LINES[@]}"
        fi

        thePattern="$2"

        foundIt=`grep -E -i -o -m 1 "$thePattern" <<< "$stringToBeSearched" | head -n 1` || foundIt=""
        
        if [[ ${#foundIt} -gt 0 ]]
        then
            searchString="$foundIt"
            rest=${stringToBeSearched#*$searchString}
            result="$(( ${#stringToBeSearched} - ${#rest} - ${#searchString} + 1 ))"
        else
            result=0
        fi

        printf -v _return_stringFind %q $result
        eval "$1=\${_return_stringFind}"

    fi

}

function _findReplace()
{
    # <SIGNATURE>: (0)_findReplace (1)_result (2)oldString/pattern (3)newString (4)someStringToSearch
    
    # small pre-processor to remove '-hd' from the argument list.
    local -i n=0
    for arg in $@
    do
        let "n+=1"
        if [[ $arg == "-hd" ]]
        then
            set -- "${@:1:n-1}" "${@:n+1}" # remove n'th positional argument - stackoverflow.com/a/23656370
        fi
    done

    # main part of the function

    #echo -e "@ is: $@, which is equal to $#. LINES is ${#LINES[@]}."

    local _return_findReplace=""
    local -i doAll=$FALSE
    local -i writeFile=$FALSE

    if [[ $# -ge 4 ]] || [[ $# -eq 3 && ${#LINES[@]} -gt 0 ]]
    then
        
        if [[ $# -ge 4 ]] && [[ -f $4  ]]
        then
                #stringToBeSearched="$(sed -rn 's/.*/&/p' $4)"
                stringToBeSearched="$(< $4)"
        
        elif [[ $# -ge 4 ]]
        then
                stringToBeSearched="$4"
        
        elif [[ $# -eq 3 ]] && [[ ${#LINES[@]} -gt 0 ]]
        then
                stringToBeSearched="${LINES[@]}"
        fi

        if [[ ! -z ${5:-} ]] && [[ ${5:-} == "-a" ]]
        then
            doAll=$TRUE

        elif [[ ! -z ${5:-} ]] && [[ ${5:-} == "-w" ]] && [[ -f $4  ]]
        then
            writeFile=$TRUE

        elif [[ ! -z ${5:-} ]] && [[ ${5:-} == "-aw" ]] && [[ -f $4  ]]
        then
            doAll=$TRUE && writeFile=$TRUE
        fi

        thePattern="${2:-}"
        newString="${3:-}"

        if [[ $doAll == $FALSE ]]
        then
            _return_findReplace="${stringToBeSearched/${thePattern}/${newString}}"
        else
            _return_findReplace="${stringToBeSearched//${thePattern}/${newString}}"
        fi

        if [[ $writeFile == $TRUE ]]
        then
            echo "$_return_findReplace">$4
        fi

        eval "$1=\${_return_findReplace}"


    elif [[ $# -eq 1 || $2 == "-?" || $2 == "--help" || $2 == "-h" ]]
    then
        echo -e " \n The command syntax is: findReplace oldString newString someStringToSearch\n"
        echo -e " someStringToSearch may be: <someString> or <someFile> or <Here-document> or <Here-string>"
        echo -e " Giving more than 4 parameter means the extras will be ignored, except! :"
        echo -e " - if you provide -a on the end, then a 'Replace All' will occur."
        echo -e " - if you provide -w on the end and your searched string was a file, the file will be updated."
        echo -e " - or in combination, a -aw for 'Replace All' and write the update to file.\n"
        echo -e " If successful, the updated string will be returned.\n"
        echo -e " For Pattern Matching visit https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching \n"

    else
        echo -e "\n Error - missing arguments."
        eval "_findReplace _result --help"
    fi

}

function _subString()
{
    # <SIGNATURE>: (0)_subString (1)_result (2)someStringToSearch (3)offset (4)length
    
    # small pre-processor to remove '-hd' from the argument list.
    local -i n=0
    for arg in $@
    do
        let "n+=1"
        if [[ $arg == "-hd" ]]
        then
            set -- "${@:1:n-1}" "${@:n+1}" # remove n'th positional argument - stackoverflow.com/a/23656370
        fi
    done

    # main part of the function

    local _return_subString=0
    local -i noLength=$FALSE

    if [[ $# -ge 4 ]] || [[ $# -eq 3 && ${#LINES[@]} -gt 0 ]]
    then
        #echo -e "\n @ is: $@, which is equal to $#. LINES is ${#LINES[@]}.\n"

        if [[ $# -eq 3 ]] && [[ ${#LINES[@]} -gt 0 ]]
        then
                stringToBeSearched="${LINES[@]}"
        
        elif [[ $# -ge 4 ]] && [[ -f ${2:-}  ]]
        then
                stringToBeSearched="$(< ${2:-})"
        
        elif [[ $# -ge 4 ]]
        then
                stringToBeSearched="${2:-}"
        
        fi

        if [[ $# -eq 4 ]] && [[ ${4:-} == "-nl" ]]
        then
            noLength=$TRUE
        fi

        local -i theOffset=${3:-0}
        local theLength="${4:-}"

        if [[ $noLength == $FALSE ]]
        then
            _return_subString="${stringToBeSearched:${theOffset}:${theLength}}"
        else
            _return_subString="${stringToBeSearched:${theOffset}}"
        fi

        #echo -e "$_return_subString"
        eval "$1=\${_return_subString}"

    elif [[ $# -eq 1 || ${2:-} == "-?" || ${2:-} == "--help" || ${2:-} == "-h" ]]
    then
        echo -e "\n Extract and return a subString from within a larger piece of text or file. \n"
        echo -e " ${GREEN}subString someStringToSearch   offset length${NC}"
        echo -e " ${GREEN}subString someFileToSearch.txt offset length${NC}\n"
        echo -e " offset & length need to be whole +/- numbers eg. integers"
        echo -e " offset means: the position X number characters from the start of 'someStringToSearch'. \n"
        echo -e " It's ok to substitute '-nl' as a length to indicate 'no length', in which case,"
        echo -e " the rest of 'someStringToSearch' is returned, starting from offset. \n"
        echo -e " ${GREEN}subString FreddoFrogIsYummyChocolate 12 5    will return 'Yummy'"
        echo -e " subString FreddoFrogIsYummyChocolate 12 -nl  will return 'YummyChocolate'"
        echo -e " subString FreddoFrogIsYummyChocolate 12 -4   will return 'YummyChoco'${NC} \n"
        echo -e " A negative length means: come from the back of 'someStringToSearch', unlike"
        echo -e " a positive length, which means come forward from the offset position. \n"
        echo -e " See https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion \n" 
        echo -e " Giving more than 3 parameter means the extras will be ignored. \n"
        echo -e " -hd and Heredocs/Herestrings are valid as input eg. :\n"
        echo -e " -   ${GREEN}subString -hd 346 -7${NC}  or  ${GREEN}subString 421 5 -hd${NC}  or  "
        echo -e " -   ${GREEN}subString 76 2 <<EOF${NC}  or  ${GREEN}subString 88 12 <<<someString${NC} \n"

    else
        echo -e "\n ${RED}Error - missing arguments.${NC}"
        eval "_subString _result --help"
    fi
 
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
        echo -e "\n The following is a list of all the functions available in this script module.\n"
        
        APIs="$(declare -F)"
        APIs="${APIs//declare -f/.\/StringFunctions}"
        
        for apiName in "${APIs[@]}"
        do
            echo "$apiName"
        done
        echo -e "\n All Here Document, Here-doc or Heredoc style input must end with a plain 'EOF' eg. EOF"
        echo -e " Heredoc style input can be forced with the '-hd' switch as a parameter, terminated with EOF"
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

    stringLength()
    (
        local _result
        _stringLength _result "$@"
        [ ! -z "${_result:-}" ] && echo -e "$_result"
    )

    stringFind()
    (
        local _result
        _stringFind _result "$@"
        [ ! -z "${_result:-}" ] && echo -e "$_result"
    )

    findReplace()
    (
        local _result
        _findReplace _result "$@"
        [ ! -z "${_result:-}" ] && echo -e "$_result"
    )

    subString()
    (
        local _result
        _subString _result "$@"
        [ ! -z "${_result:-}" ] && echo -e "$_result"
    )


    #isNumber(){ printf %f "$1" &>/dev/null && echo "true" || echo "false" }
    #isArray() { declare -p test1 2>/dev/null | grep -q '^declare \-[aA]' && echo "test1 is an array type" || echo "test1 is not an array type" }

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

        for arg in "${ARGS[@]}"
        do
            if [[ $arg == "-hd" ]]
            then
                readInput # read more input into the ARGS array
            fi
        done

    fi

else               # input comes from redirection.

    ARGS=("$@")
    readInput  # read more input into the LINES array

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
