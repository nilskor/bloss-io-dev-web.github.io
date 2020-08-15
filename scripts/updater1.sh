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

source ./scripts/StringFunctions

declare gjsJSONprocessor='./scripts/gjs-JSON-processor.js'

# Useful string splitting behaviour occurs with IFS=$'\n\t'
# The default is to split on spaces, tabs and newlines $' \n\t'
#IFS=$'\n\t'

declare theseFiles="GtkApplication.html"
#declare theIndexFile="./scripts/pages.js" # obsoleted by the JSON data in pages.js

# <h3><a href="/content/GTK3/Widgets Objects/Abstract_Base/GtkWidget"><font color="#2e3440">
#     GtkWidget
#     </font></a></h3>
# The above can only be found with:
#
# grep -Pazo '(?s)<h3><a.*?</a></h3>' ./content/GTK3/Widgets\ Objects/Abstract\ Base/Abstract\ Base.html

#declare oldLinkPattern="^[ ]*<h3><a.+.href=./content/GTK3/.*"      
#declare oldLinkPattern='<a[ ]name=.+.href=./content/GTK3/.+</a>'
declare oldLinkPattern='<a[ ]href="/content/GTK3/.*</a>'
declare hrefPattern="[-0-9A-Za-z_\ \W]+(.html)"                     # The global set of 'pages' in this hybrid SPA are in pages.js 
                                                                    # as links, and those links have #References made up of the 
                                                                    # file-names (creating uniqueness). Searching for the file-names
                                                                    # is written here as a RegEx.

declare -i step3_Echoed=$FALSE
declare -i step3a_Echoed=$FALSE
declare -i step3b_Echoed=$FALSE

#declare theWholeIndexFile="" # obsoleted by the JSON data in pages.js

declare -ir DO_NOT_WRITE=$TRUE

function   setIFS(){ IFS=$'\n\t'; }
function unsetIFS(){ IFS= ;       }

function main()
{
    echo -e "main()"

    local -a _step1Result=()

    setIFS

    #theWholeIndexFile="$(< $theIndexFile)" # obsoleted by the JSON data in pages.js

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
                :
                #echo -e "the Do loop"
                #step4 "$file" # mainly bookmark stuff
                step3 "$file" # mainly updating links to suit the hybrid SPA web site
                #step5 "$file" # mainly updating TOC items
                #step6 "$file" # mainly deleting the opening html stuff to make them injectable & compliant.
                #step7 "$file" # mainly deleting <font> tags from new injectable links.
        fi
    done

}

function step3()             # "Step #3 - work with each html file"
{

    if [[ $step3_Echoed -eq $FALSE ]]
    then
        echo -e "\nStep #3 - look through each html file"
        step3_Echoed=$TRUE
    fi

    local _theStringFindResults=""
    #  where $@ is the incoming file.
    _FindAll _theStringFindResults '<a href="/content/GTK3/(.*?|\n)</a>' "$@" '-m'

    # An example of what we're looking for ..
    # <h3><a id="bkmkGTKWidgetsObjects" href='#GTKWidgetsObjects' class="two"  onclick="injectContentInto( 'injectHere',  '/content/GTK3/Widgets Objects/GTK Widgets Objects.html', 'GTK Widgets Objects' );">GTK+ Widgets and Objects</a></h3>
                                                                                        
    local -A arrayOfOldLinks=()
    # then rename the ArrayOfStrings..
    _FindReplace _theStringFindResults 'ArrayOfStrings' 'arrayOfOldLinks' "$_theStringFindResults"
    
    # unravel the return result into 'arrayOfOldLinks', 
    eval "$_theStringFindResults"                                       

    local toWriteOrNot=''
    if [[ $DO_NOT_WRITE -eq $FALSE ]]
    then
        toWriteOrNot='-w'
    fi

    if [[ ${#arrayOfOldLinks[@]} -gt 0 ]]
    then
            echo -e "\n==================================================================================================="
            echo -e " Step #3 - checking the injectable links in this file: $@  (${#arrayOfOldLinks[@]})"
            echo -e "           using ('<a href=\"/content/GTK3/(.*?|\\\n)</a>')  "
            echo -e "==================================================================================================="
            
            # for each line of <h3><a href="/content/GTK/someFile.html">
            # send each line to step 3a for processing
            
            for index in ${!arrayOfOldLinks[@]}         
            do                                           

                local _oldLink="${arrayOfOldLinks[$index]}"
                
                #local _ret_FullString=""
                #local _ret_IndexLookup=""
                #local _ret_newLinkWithBookmark=""
                #local _ret_oldLinkText=""
                #local _temp1

                # Examples:
                # old - <h3><a id="bkmkGTKWidgetsObjects" href='#GTKWidgetsObjects' class="two"  onclick="injectContentInto( 'injectHere',  '/content/GTK3/Widgets Objects/GTK Widgets Objects.html', 'GTK Widgets Objects' );">GTK+ Widgets and Objects</a></h3>
                # new - <h3><a id="bkmkPage1" data-id="Page1" class="two">Page 1</a></h3>
                
                #step3a _ret_FullString _ret_IndexLookup "$_oldLink"
                
                #_Trim _ret_trimmedFullString $_ret_FullString
                #_wsTrim _ret_newLink "$_ret_trimmedFullString"

                echo -e "${DGREY}The link that needs replacing:\n${LGREY}$_oldLink${GREEN}"
                
                local _ret_Name854_=""
                _Find _ret_Name854_ '(?<=\/)([A-Za-z0-9_-]*?)(?=\.html)' "$_oldLink" '-sm'
                echo -e "Found: $_ret_Name854_"
                #_FindReplace _ret_Name613_ '_' ' ' "$_ret_Name854_" '-a'
                #_ret_Name613_=".$_ret_Name613_"
                #echo -e "$_ret_Name613_"
                local _res_JSON923_="$($gjsJSONprocessor 'name' "$_ret_Name854_")"
                echo -e "$_res_JSON923_"

                #local _ret_newLink=""
                #_regexFindReplace _ret_newLink "\shref=\".*?\"{1,1}" '' "$_oldLink"
                #_regexFindReplace _ret_newLink "(\n{1,}|\s{2,})" '' "$_ret_newLink"
                #_regexFindReplace _ret_newLink "(\n{1,}|\s{2,})" '' "$_ret_newLink"
                #_regexFindReplace _ret_newLink '">' "\" data-id='$_res_JSON923_'>" "$_ret_newLink"
                #echo -e "${LCYAN}$_ret_newLink${NC}\n"

                #_Insert _ret_newLinkWithID "id='bkmk$_ret_IndexLookup' " "$_ret_newLink" 4
                #_Find _ret_oldLinkText '(?<=\s)<img src=".*?">' "$_oldLink" '-sm'
                #_ret_oldLinkText=$(_sc LTrim $_ret_oldLinkText)
                #echo -e "$_ret_oldLinkText"

                #if [[ ${#_ret_newLink} -lt ${#_oldLink} ]]
                #then
                #    _FindReplace _temp1 "$_oldLink" "$_ret_newLink" "$@" $toWriteOrNot
                #else
                #    echo -e "\n New link is longer than, or the same as the old link:\n"
                #    echo -e " $_ret_newLink\n"
                #    echo -e " $_oldLink\n"
                #fi
                #echo ""
                #echo -e "$_ret_newLink"
                #echo -e ":\n  old: $_oldLink\n  new: $_ret_newLink\n bkmk: $_ret_newLinkWithBookmark\n text: $_ret_oldLinkText\n:"
                        
            done
    else
        :
        #echo -e "\n ${RED}Step 3, found nothing, next file ..${NC}\n" 
    fi

}

function step3a()            # "Step #3a - create the unique file name index lookup"
{

    if [[ $step3a_Echoed -eq $FALSE ]]
    then
        #echo -e "\nStep #3a - create the unique file name index lookup"
        step3a_Echoed=$TRUE
    fi

    #foundName=`grep -E -i -o "$hrefPattern" <<< "$3"` || foundIt=""
    local _ret_PossibleLookupName=""
    local foundName=""

    _Find _ret_PossibleLookupName '((?<=/)|(?<=#))([A-Za-z0-9._]*)(?=">)' "$3" '-s'

    foundName="$_ret_PossibleLookupName"

    echo -e "\nSTEP3 - $foundName\n"

    if [[ -n $foundName ]]
    then
            foundName=${foundName//_}     # remove underscores           # collapse the file name down to a #Reference
            foundName=${foundName// }     # remove spaces
            foundName=${foundName//-}     # remove hyphens
            foundName=${foundName//.html} # remove '.html'
            
            _result3b="$(step3b "$foundName")"
            echo -e "Found a new link:\n$(step3b "$foundName")\n"    # return the result_3b back to step 3
            eval "$1=\${_result3b}; $2=\${foundName}"  # return the result_3b back to step 3, as well as the index lookup
    fi

}
function step3aa()            # "Step #3a - create the unique file name index lookup"
{

    if [[ $step3a_Echoed -eq $FALSE ]]
    then
        #echo -e "\nStep #3a - create the unique file name index lookup"
        step3a_Echoed=$TRUE
    fi

    #foundName=`grep -E -i -o "$hrefPattern" <<< "$3"` || foundIt=""
    local _ret_PossibleLookupName=""
    local foundName=""

    _Find _ret_PossibleLookupName '((?<=/)|(?<=#))([A-Za-z0-9._]*)(?=">)' "$3" '-s'

    foundName="$_ret_PossibleLookupName"

    echo -e "\nSTEP3 - $foundName\n"

    if [[ -n $foundName ]]
    then
            foundName=${foundName//_}     # remove underscores           # collapse the file name down to a #Reference
            foundName=${foundName// }     # remove spaces
            foundName=${foundName//-}     # remove hyphens
            foundName=${foundName//.html} # remove '.html'
            
            _result3b="$(step3b "$foundName")"
            echo -e "Found a new link:\n$(step3b "$foundName")\n"    # return the result_3b back to step 3
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

    foundLine=`grep -E "#$@'" <<< "$theWholeIndexFile"` || foundLine=""

    echo -e "$foundLine"    # return the results from step3b back to 3a
}

function step4()             # "Step #4 - update the bookmarks"
{
    #echo -e "Step #4 - update the bookmarks in this file: $@"

    local _newBookmark
    local _temp0

    # The following are successful regexes:
    #
    # removes underscores in the ToC bookmark links:
    #_FindAll _arrayOfBookmarks '^\s{1,}<li>.*class="toggle".*href=".*[_]{1,}.*">' "$@"
    #
    # adds bkmk to the bookmarks
    #_FindAll _arrayOfBookmarks '^\s{1,}<li>.*class="toggle".*href="#(?!bkmk).*">' "$@"
    #
    # replace </a class="toggle"> with </a>
    #_FindAll _arrayOfBookmarks '^\s{1,}<li>.*class="toggle".*</a\sclass="toggle">' "$@"
    #
    # find name="" and replace with id=""
    # _FindAll _arrayOfBookmarks '(?<=<h.><a\s).*name="[[:alnum:]_{1,}]*"' "$@"

    local _arrayOfBookmarks=""
    _FindAll _arrayOfBookmarks '(?<=<li><a href="#).*(?="><)' "$@"
    #_FindAll _arrayOfBookmarks '(?<=<li>)(?:.*?)(<a href="#).*(?="><)' "$@"

    local -A arrayOfOldBookmarks=()
    _FindReplace _arrayOfBookmarks 'ArrayOfStrings' 'arrayOfOldBookmarks' "$_arrayOfBookmarks"
    eval "$_arrayOfBookmarks"
    # arrayOfOldBookmarks[]

    local toWriteOrNot=''
    if [[ $DO_NOT_WRITE -eq $FALSE ]]
    then
        toWriteOrNot='-aw'
    fi

    if [[ ${#arrayOfOldBookmarks[@]} -gt 0 ]]
    then
        echo -e "\n==================================================================================================="
        echo -e " Step #4 - checking the bookmarks in this file: $@ (${#arrayOfOldBookmarks[@]})"
        echo -e "==================================================================================================="
        for index in ${!arrayOfOldBookmarks[@]}
        do
            local _oldBKMK="${arrayOfOldBookmarks[$index]}"
            #-----------------------------------------------------------------------------------------
            echo -e "\n$_oldBKMK"
            #_FindReplace _newBookmark 'name="'   'id="bkmk' "$_oldBKMK" -a
            #_FindReplace _newBookmark 'bkmkbkmk' 'bkmk'     "$_newBookmark" -a
            #_FindReplace _newBookmark '_'        ''         "$_newBookmark" -a
            #_FindReplace _newBookmark '_'        ''         "$_oldBKMK" -a
            #if [[ ! ${#_oldBKMK} -eq ${#_newBookmark} ]]
            #then
            #    echo -e "\n Update: ${CYAN}$_oldBKMK${NC} to ${PINK}$_newBookmark${NC}\n"
            #    _FindReplace _temp0 "$_oldBKMK" "$_newBookmark" "$@" $toWriteOrNot
            #else
            #    echo -e "${DGREY} :: skipping $_oldBKMK${NC}"
            #fi
            #echo -e "$_temp0"
            #-----------------------------------------------------------------------------------------
            #local _theBKMK=$_oldBKMK
            #local _oldName=$(_sc SubString $_theBKMK 7 $(( $(_sc Len $_theBKMK) - 7  )))
            #local _newName=$(_sc FindReplace '_' '' $_oldName '-a')
            #if [[ ! ${#_oldName} -eq ${#_newName} ]]
            #then
            #    echo -e " :: $_oldName ${GREEN}needs updating to ${NC}${BLUE}$_newName${NC}"
            #    _FindReplace _temp0 "$_oldName" "$_newName" "$@" $toWriteOrNot
            #    
            #else
            #    echo -e "${BLACK} :: skipping $_oldName${NC}"
            #fi
            #-----------------------------------------------------------------------------------------
            
        done

    else
        :
        #echo -e "\n ${PINK}Step 4, found no bookmarks using ('(?<=<li><a href=\"\#).*(?=\"><)') in $@ ${NC}\n" 

    fi

}

function step5()             # mainly updating TOC items
{
    local _arrayOfTOCitems=""
    local -A arrayOfOldTOCitems=()

    _FindAll _arrayOfTOCitems '(?<=<li>).*[ ]class="toggle".*(?=</li>)' "$@"

    # START - rename the array and re-animate it
    _FindReplace _arrayOfTOCitems 'ArrayOfStrings' 'arrayOfOldTOCitems' "$_arrayOfTOCitems"
    eval "$_arrayOfTOCitems"
    # END - arrayOfOldTOCitems[]

    local toWriteOrNot=''
    if [[ $DO_NOT_WRITE -eq $FALSE ]]
    then
        toWriteOrNot='-w'
    fi

    if [[ ${#arrayOfOldTOCitems[@]} -gt 0 ]]
    then
            echo -e "\n==================================================================================================="
            echo -e " Step #5 - checking the TOC items in this file: $@"
            echo -e "==================================================================================================="
            for index in ${!arrayOfOldTOCitems[@]}
            do
                    local _oldTOCitem="${arrayOfOldTOCitems[$index]}"
                    #-----------------------------------------------------------------------------------------
                    echo -e "\n$_oldTOCitem"
                    _Find _q46_fc '<font color="#2e3440">.*?</font>' "$_oldTOCitem" -s
                    #echo -e "$_q46_fc"
                    _FindReplace _newTOCitem "$_q46_fc" '' "$_oldTOCitem"
                    _FindReplace _newTOCitem 'class="toggle" ' '' "$_newTOCitem"
                    _Find _k88_ip '>' "$_newTOCitem"
                    _Insert _newTOCitem "$_q46_fc" "$_newTOCitem" $(( _k88_ip + 1 ))
                    echo -e "$_newTOCitem"
                    _FindReplace _tmp971 "$_oldTOCitem" "$_newTOCitem" "$@" $toWriteOrNot

                    #-----------------------------------------------------------------------------------------
            done
    else
            : # echo -e "\n ${PINK}Step 5, found nothing in $@ ${NC}\n" 
    fi
}

function step6()             # mainly deleting the opening html stuff to make them injectable & compliant.
{

    local toWriteOrNot=''
    if [[ $DO_NOT_WRITE -eq $FALSE ]]
    then
        toWriteOrNot='-w'
    fi

    declare -a _g67_head=()
    _Find _g67_head '<!DOCTYPE html>.*?(?=<!-- article header "section-header" -->)' "$@" -mb

    if [[ ${_g67_head[0]} -gt 0 ]]
    then
            echo -e "\n==================================================================================================="
            echo -e " Step #6 - checking the DOCTYPE <head> in this file: $@"
            echo -e "==================================================================================================="
            echo -e "${_g67_head[1]}"

            _regexFindReplace _k54_fr '<!DOCTYPE html>.*?(?=<!-- article header "section-header" -->)' '' "$@" $toWriteOrNot
    fi

}

function step7()             # mainly deleting <font> tags from new injectable links.
{

    local toWriteOrNot=''
    if [[ $DO_NOT_WRITE -eq $FALSE ]]
    then
        toWriteOrNot='-w'
    fi

    local _arrayOfFontTags=""
    local -A _arrayOfOldFontTags=()
    _FindAll _arrayOfFontTags '<h3><a .*?injectHere.*?</font></a></h3>' "$@" -m
    # START - rename the array and re-animate it
    _FindReplace _arrayOfFontTags 'ArrayOfStrings' '_arrayOfOldFontTags' "$_arrayOfFontTags"
    eval "$_arrayOfFontTags"
    # END - _arrayOfOldFontTags[]

    if [[ ${#_arrayOfOldFontTags[@]} -gt 0 ]]
    then
            echo -e "\n==================================================================================================="
            echo -e " Step #7 - checking for <font> in <a> links in this file: $@   (${#_arrayOfOldFontTags[@]})"
            echo -e "===================================================================================================\n"
            for index in ${!_arrayOfOldFontTags[@]}
            do
                    local _oldFontTagitem="${_arrayOfOldFontTags[$index]}"
                    #-----------------------------------------------------------------------------------------
                    #echo -e "\n$_oldFontTagitem"
                    _Find _v91_ft '<font color="#2e3440">.*?</font>' "$_oldFontTagitem" -s
                    #echo -e "$_v91_ft"
                    _FindReplace _newFontTagitem '<font color="#2e3440">' '' "$_oldFontTagitem"
                    _FindReplace _newFontTagitem '</font>' '' "$_newFontTagitem"
                    echo -e "$_newFontTagitem"
                    _FindReplace _v91_ft "$_oldFontTagitem" "$_newFontTagitem" "$@" $toWriteOrNot
                    #-----------------------------------------------------------------------------------------
            done
    else
            : # echo -e "\n ${PINK}Step 5, found nothing in $@ ${NC}\n" 
    fi

}


main
