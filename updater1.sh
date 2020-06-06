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

declare theseFiles="*.html"
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

function step1()             # "Step #1 - find all the html files"
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

function step2()             # "Step #2 - process the array of files"
{

    echo -e "Step #2 - process the collection of files"
    
    local -a AllHtmlFiles=()
    
    eval "$@"                       # This eval statement receives the 'instructions' for recreating
                                    # the array variable, effectively passed 'ByVal'. The downside is 
                                    # that the name has already been fixed when it was passed.

    for file in "${AllHtmlFiles[@]}"
    do
        if [[ "$file" != "./index.html" ]]
        then
            #echo -e "the Do loop"
            step3 "$file"
            step4 "$file"

        fi
    done

}

function step3()             # "Step #3 - work with each html file"
{

    if [[ $step3_Echoed -eq $FALSE ]]
    then
        echo -e "Step #3 - look through each html file"
        step3_Echoed=$TRUE
    fi

    local _theStringFindResults=""
    local -A arrayOfOldLinks=()
                                                                            
    _FindAll _theStringFindResults "$oldLinkPattern" "$@"               # where $@ is the incoming file.
                                                                        # then rename the ArrayOfStrings..

    _FindReplace _theStringFindResults 'ArrayOfStrings' 'arrayOfOldLinks' "$_theStringFindResults"
    eval "$_theStringFindResults"                                       # unravel the return result into 'arrayOfOldLinks', 

    if [[ ${#arrayOfOldLinks[@]} -gt 0 ]]
    then

        for index in ${!arrayOfOldLinks[@]}         # for each line of <h3><a href="/content/GTK/someFile.html">
        do                                           # send each line to step 3a for processing
            local _oldLink="${arrayOfOldLinks[$index]}"
            local _ret_FullString=""
            local _ret_IndexLookup=""
            local _ret_newLinkWithBookmark=""
            local _ret_oldLinkText=""
            local _temp1
            
            step3a _ret_FullString _ret_IndexLookup "$_oldLink"
            
            _Trim _ret_trimmedFullString $_ret_FullString
            _wsTrim _ret_newLink "$_ret_trimmedFullString"
            
            #_old_dont_use_#_FindReplace _ret_newLinkWithBookmark "$_ret_IndexLookup" "bkmk$_ret_IndexLookup" $_ret_newLink
            _Insert _ret_newLinkWithID "id='bkmk$_ret_IndexLookup' " "$_ret_newLink" 4
            
            _Find _ret_oldLinkText '(?<=\>)(.+)(?=\<)' "$_oldLink" '-s'

            _ret_newLink=""
            _FindReplace _ret_newLink ');"></a>' ");\">$_ret_oldLinkText</a>" "$_ret_newLinkWithID"

            echo -e '\n _FindReplace' "\n::$_oldLink" "\n::$_ret_newLink" "\n::$@\n"

            _FindReplace _temp1 "$_oldLink" "$_ret_newLink" "$@" '-w'

            #echo -e "$_ret_newLink"
            #echo -e ":\n  old: $_oldLink\n  new: $_ret_newLink\n bkmk: $_ret_newLinkWithBookmark\n text: $_ret_oldLinkText\n:"
                    
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

function step4()             # "Step #4 - update the bookmarks"
{
    #echo -e "Step #4 - update the bookmarks in this file: $@"

    local _arrayOfBookmarks=""
    local -A arrayOfOldBookmarks=()
    local _newBookmark
    local _temp0

    # remnants    # (?<=href).*([_]{1,}).*(?=\")     # (?<=href=\").*(?=\")
    #
    # The following is a successful pass thru of all html files to remove underscores in the ToC bookmark links
    #_FindAll _arrayOfBookmarks '^\s{1,}<li>.*class="toggle".*href=".*[_]{1,}.*">' "$@"
    #
    # The following is a successful pass thru of all html files to add bkmk to the bookmarks
    #_FindAll _arrayOfBookmarks '^\s{1,}<li>.*class="toggle".*href="#(?!bkmk).*">' "$@"
    #
    # The following is a successful pass thru of all html files to replace </a class="toggle"> with </a>
    #_FindAll _arrayOfBookmarks '^\s{1,}<li>.*class="toggle".*</a\sclass="toggle">' "$@"
    #

    _FindAll _arrayOfBookmarks '(?<=<h.><a\s).*name="[[:alnum:]_{1,}]*"' "$@"   # '(?<=<h.><a\s).*name="[[:alnum:]_{1,}]*"'

    _FindReplace _arrayOfBookmarks 'ArrayOfStrings' 'arrayOfOldBookmarks' "$_arrayOfBookmarks"
    eval "$_arrayOfBookmarks"
    # arrayOfOldBookmarks[]

    if [[ ${#arrayOfOldBookmarks[@]} -gt 0 ]]
    then
        echo -e "\n==================================================================================================="
        echo -e " Step #4 - checking the bookmarks in this file: $@"
        echo -e "==================================================================================================="
        for string in ${!arrayOfOldBookmarks[@]}
        do
            #-----------------------------------------------------------------------------------------
            #echo -e "\n${arrayOfOldBookmarks[$string]}"
            #step4a    "${arrayOfOldBookmarks[$string]}" "$@"
            _FindReplace _newBookmark 'name="'   'id="bkmk' "${arrayOfOldBookmarks[$string]}" -a
            _FindReplace _newBookmark 'bkmkbkmk' 'bkmk'     "$_newBookmark" -a
            _FindReplace _newBookmark '_'        ''         "$_newBookmark" -a
            echo -e "\nUpdate: ${RED}${arrayOfOldBookmarks[$string]}${NC} to ${GREEN}$_newBookmark${NC}\n"
            _FindReplace _temp0 "${arrayOfOldBookmarks[$string]}" "$_newBookmark" "$@" '-aw'
            #echo -e "$_temp0"
            #-----------------------------------------------------------------------------------------
            local _theBKMK=${arrayOfOldBookmarks[$string]}
            local _oldName=$(_sc SubString $_theBKMK 7 $(( $(_sc Len $_theBKMK) - 7  )))
            local _newName=$(_sc FindReplace '_' '' $_oldName '-a')
            if [[ ! ${#_oldName} -eq ${#_newName} ]]
            then
                echo -e " :: $_oldName ${GREEN}needs updating to ${NC}${BLUE}$_newName${NC}"
                _FindReplace _temp0 "$_oldName" "$_newName" "$@" '-aw'

            else
                echo -e "${BLACK} :: skipping $_oldName${NC}"
            fi
            #-----------------------------------------------------------------------------------------
            
        done

    fi

}

function step4a()
{
    echo -e "\n Step 4a ..\n"
    #return 0
    local _arrayOfBookmarks=""
    local -A arrayOfOldBookmarks=()

    _FindAll _arrayOfBookmarks "$1" "$2"

    _FindReplace _arrayOfBookmarks 'ArrayOfStrings' 'arrayOfOldBookmarks' "$_arrayOfBookmarks"
    eval "$_arrayOfBookmarks"
    # arrayOfOldBookmarks[]

    if [[ ${#arrayOfOldBookmarks[@]} -gt 0 ]]
    then
        for string in ${!arrayOfOldBookmarks[@]}
        do
            local _theBKMK=${arrayOfOldBookmarks[$string]}
            local _oldName=$(_sc SubString $_theBKMK 7 $(( $(_sc Len $_theBKMK) - 7  )))
            local _newName=$(_sc FindReplace '_' '' $_oldName '-a')
            echo -e " :: $_oldName needs updating to $_newName"
        
        done
    fi
}

main
