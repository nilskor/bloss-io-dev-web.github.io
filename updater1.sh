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

declare theseFiles="GTK3test.html"
declare theIndexFile="index.html"
#declare oldLinkPattern="^[ ]*<h3><a.+.href=./content/GTK3/.*"
declare oldLinkPattern="<a[ ]name=.+.href=./content/GTK3/.+</a>"
declare hrefPattern="[-0-9A-Za-z_\ \W]+(.html)"                     # The global set of 'pages' in this hybrid SPA are in index.html 
                                                                    # as links, and those links have #References made up of the 
                                                                    # file-names (creating uniqueness). Searching for the file-names
                                                                    # is written here as a RegEx.

declare -i step3_Echoed=$FALSE
declare -i step3a_Echoed=$FALSE
declare -i step3b_Echoed=$FALSE

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

    done < <(find -iname "$theseFiles")

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

    local _theStringFindResults=""
    #local -A ArrayOfStrings=()      # this must be declared as 'ArrayOfStrings' to use the return result.
    local -A arrayOfOldLinks=()

    _regexStringFind2 _theStringFindResults "$oldLinkPattern" "$*"          # where $* is the incoming file
    _findReplace _theStringFindResults 'ArrayOfStrings' 'arrayOfOldLinks' "$_theStringFindResults"    # rename the ArrayOfStrings
    eval "$_theStringFindResults"                                           # unravel the return result into 'ArrayOfStrings', 
                                                                            # which is the output of regexStringFind2.
    

    if [[ ${#arrayOfOldLinks[@]} -gt 0 ]]
    then

        for string in ${!arrayOfOldLinks[@]}         # for each line of <h3><a href="/content/GTK/someFile.html">
        do                                           # send each line to step 3a for processing

            #result_3a="$(step3a "${ArrayOfStrings[$string]}")"
                                                    # using the output from 3a/b, now replace the line
            #_trim _trimmedResult $result_3a
            #_wsTrim _trimmedResult "$_trimmedResult"

            #echo -e ":\n old: ${ArrayOfStrings[$string]}\n new: $_trimmedResult\n:"
            
            local _ret_FullString=""
            local _ret_IndexLookup=""
            local _newLinkWithBookmark=""
            local _oldLinkText=""
            local _result5=""
            local -A arrayOldLinkText=()
            
            step3a _ret_FullString _ret_IndexLookup "${arrayOfOldLinks[$string]}"
            #[ ! -z "${_ret_FullString:-}" ] && [ ! -z "${_ret_IndexLookup:-}" ] && echo -e "\n $_ret_FullString, $_ret_IndexLookup \n"
            
            _trim _trimmed_FullString $_ret_FullString
            _wsTrim _new_Link "$_trimmed_FullString"
            
            _findReplace _newLinkWithBookmark "$_ret_IndexLookup" "bkmk$_ret_IndexLookup" $_new_Link
            
            _regexStringFind _oldLinkText '(?<=\>)(.+)(?=\<)' "${arrayOfOldLinks[$string]}" '-s'

            #_regexStringFind2 _oldLinkText '(?<=\>)(.+)(?=\<)' ${arrayOfOldLinks[$string]}
            #_findReplace _oldLinkText 'ArrayOfStrings' 'arrayOldLinkText' "$_oldLinkText"
            #eval "$_oldLinkText"
            #_subString _result5 "${arrayOldLinkText[@]}" 1 $(_sc len "${arrayOldLinkText[@]}")

            echo -e ":\n  old: ${arrayOfOldLinks[$string]}\n  new: $_new_Link\n bkmk: $_newLinkWithBookmark\n text: $_oldLinkText\n:"
                    
        done
        
    fi

}

function step3a()            # "Step #3a - create the unique file name index lookup"
{

    if [[ $step3a_Echoed -eq $FALSE ]]
    then
        #echo -e "\nStep #3a - create the unique file name index lookup"
        step3a_Echoed=$TRUE
    fi

    foundName=`grep -E -i -o "$hrefPattern" <<< "$3"` || foundIt=""

    if [[ -n $foundName ]]
    then
        foundName=${foundName//_}     # remove underscores           # collapse the file name down to a #Reference
        foundName=${foundName// }     # remove spaces
        foundName=${foundName//-}     # remove hyphens
        foundName=${foundName//.html} # remove '.html'
        
        #echo -e "$(step3b "$foundName")"    # return the result_3b back to step 3
        _result3b="$(step3b "$foundName")"
        eval "$1=\${_result3b}; $2=\${foundName}"  # return the result_3b back to step 3, as well as the index lookup
    fi

}

function step3b()            # "Step #3b - find the index lookup inside $theIndexFile and so on .."
{

    if [[ $step3b_Echoed -eq $FALSE ]]
    then
        #echo -e "Step #3b - find '#$@' inside $theIndexFile and so on ..\n:"
        step3b_Echoed=$TRUE
    fi

    foundLine=`grep -E "#$@" <<< "$theWholeIndexFile"` || foundLine=""

    echo -e "$foundLine"    # return the results from step3b back to 3a
}

main
