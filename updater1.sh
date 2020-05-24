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

source ./StringFunctions

# Useful string splitting behaviour occurs with IFS=$'\n\t'
# The default is to split on spaces, tabs and newlines $' \n\t'
#IFS=$'\n\t'

# Set variables:
#declare -ri  TRUE=0          # g - global scope; r - read-only; i - integer; x - exportable
#declare -ri FALSE=1

declare RED='\033[1;31m'     # actually a light Red to be exact :)
declare GREEN='\033[0;32m'
declare NC='\033[0m'         # No Color

declare theIndexFile="GTK3test.html"
declare oldLinkPattern="^[ ]*<h3><a.+.href=./content/GTK3/.*"
declare hrefPattern="[-0-9A-Za-z_\ \W]+(.html)"                     # The global set of 'pages' in this hybrid SPA are in index.html 
                                                                    # as links, and those links have #References made up of the 
                                                                    # file-names (creating uniqueness). Searching for the file-names
                                                                    # is written here as a RegEx.

declare -i step3_Echoed=$FALSE
declare -i step4_Echoed=$FALSE

declare theWholeIndexFile=""

function   setIFS(){ IFS=$'\n\t'; }
function unsetIFS(){ IFS= ;       }

function main()
{
    echo -e "main()"

    local -a _step1Result=()

    setIFS

    theWholeIndexFile="$(< $theIndexFile)"

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

    echo -e "Step #2 - process the collection of files"
    
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

    if [[ $step3_Echoed -eq $FALSE ]]
    then
        echo -e "Step #3 - look through each html file"
        step3_Echoed=$TRUE
    fi

    local -A _theStringFindResults=()
    local -A ArrayOfStrings=()      # this must be declared as 'ArrayOfStrings' to use the return result.

    _stringFind2 _theStringFindResults "$oldLinkPattern" "$*"

    eval "$_theStringFindResults"   # unravel the return result into 'ArrayOfStrings', 
                                    # which is the output of stringFind.

    if [[ ${#ArrayOfStrings[@]} -gt 0 ]]
    then
        for string in ${!ArrayOfStrings[@]}         # for each line of <h3><a href="/content/GTK/someFile.html">
        do
            step4 "${ArrayOfStrings[$string]}"      # send each line to step 4 for processing
        done
        #sort -n -k1
    fi

}

function step4()
{

    if [[ $step4_Echoed -eq $FALSE ]]
    then
        echo -e "Step #4 - create the unique file name index lookup"
        step4_Echoed=$TRUE
    fi

    foundName=`grep -E -i -o "$hrefPattern" <<< "$@"` || foundIt=""

    if [[ -n $foundName ]]
    then
        foundName=${foundName//_}     # remove underscores           # collapse the file name down to a #Reference
        foundName=${foundName// }     # remove spaces
        foundName=${foundName//-}     # remove hyphens
        foundName=${foundName//.html} # remove '.html'
        echo -e "$foundName"
    fi

}

main
