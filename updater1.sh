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
#IFS=$'\n\t'

# Set variables:
#declare -ri  TRUE=0          # g - global scope; r - read-only; i - integer; x - exportable
#declare -ri FALSE=1

declare RED='\033[1;31m'     # actually a light Red to be exact :)
declare GREEN='\033[0;32m'
declare NC='\033[0m'         # No Color

declare oldLinkPattern="^[ ]*<h3><a.+.href=./content/GTK3/"   

source ./StringFunctions

function   setIFS(){ IFS=$'\n\t'; }
function unsetIFS(){ IFS= ;       }

function main()
{
    echo -e "main()"

    local -a _step1Result=()

    setIFS

    step1 _step1Result

    step2 "${_step1Result}"

}

function step1()            # "Step #1 - find all the html files"
{
    echo -e "Step #1 - find all the html files"

    local -a AllHtmlFiles=()

    unsetIFS

    while read file
    do

        AllHtmlFiles+=($file)

    done < <(find -iname "*.html")

    setIFS
    
    eval "$1=\$(declare -p AllHtmlFiles)" # This has the nice effect of passing the variable 'ByVal'.
                                          # You get everything you need to recreate the original
                                          # array variable. The downside is the variable name has to
                                          # match in both locations. It does avoid a global variable
                                          # though.

}

function step2()            # "Step #2 - process the array of files"
{

    echo -e "Step #2 - process the array of files"
    
    local -a AllHtmlFiles=()
    
    eval "$@"                       # This eval statement receives the 'instructions' for recreating
                                    # the array variable, effectively passed 'ByVal'. The downside is 
                                    # that the name has already been fixed when it was passed.

    for file in "${AllHtmlFiles[@]}"
    do
        step3 "$file"
    done

}

function step3()            # "Step #3 - work with each html file"
{

    echo -e "Step #3 - work with each html file"

    echo -e "$@"

}

main
