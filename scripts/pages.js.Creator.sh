#!/bin/bash

# Will exit script if we would use an uninitialised variable:
# either set -u or set -o nounset
set -o nounset

# Will exit script when a simple command (not a control structure) fails:
# either set -e or set -o errexit
set -o errexit

# This setting prevents errors in a pipeline from being masked.
set -o pipefail

#set -vx # uncomment for debugging

source ./scripts/StringFunctions

# Useful string splitting behaviour occurs with IFS=$'\n\t'
# The default is to split on spaces, tabs and newlines $' \n\t'
#IFS=$'\n\t'

declare theseFiles="*.html"
declare theIndexFile="index.html"

# <h3><a href="/content/GTK3/Widgets Objects/Abstract_Base/GtkWidget"><font color="#2e3440">
#     GtkWidget
#     </font></a></h3>
# The above can only be found with:
#
# grep -Pazo '(?s)<h3><a.*?</a></h3>' ./content/GTK3/Widgets\ Objects/Abstract\ Base/Abstract\ Base.html

#declare oldLinkPattern="^[ ]*<h3><a.+.href=./content/GTK3/.*"      
#declare oldLinkPattern='<a[ ]name=.+.href=./content/GTK3/.+</a>'
declare oldLinkPattern='<a[ ]href="/content/GTK3/.*</a>'
declare hrefPattern="[-0-9A-Za-z_\ \W]+(.html)"                     # The global set of 'pages' in this hybrid SPA are in index.html 
                                                                    # as links, and those links have #References made up of the 
                                                                    # file-names (creating uniqueness). Searching for the file-names
                                                                    # is written here as a RegEx.

declare -i step3_Echoed=$FALSE
declare -i step3a_Echoed=$FALSE
declare -i step3b_Echoed=$FALSE


declare -ir DO_NOT_WRITE=$FALSE

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
    local -i _loopCounter_=1
    local hashTag=""
    local title=""
    
    eval "$@"                       # This eval statement receives the 'instructions' for recreating
                                    # the array variable, effectively passed 'ByVal'. The downside is 
                                    # that the name has already been fixed when it was passed.

declare Page0=""
Page0=$(cat <<-EndOfMessage
    page0: {
        name: "index",                       // the source filename sans '.html'
        sourceURL: "./content/page0.html",   // the important bit - the actual source file
        hashTag: "#/content/index.html",     // what this page should look like in the address bar
        title: "index",                      // for setting the document title
        injector: "injectHere",              // the important bit - where to actually inject the content into
        description: "page0 desc.",          // more for documentation than anything else
        innerHTML: "index"                   // may not be useful, just in case we need an alias showing on the page
    },
EndOfMessage
)

    printf "%s\\n" $Page0

    for file in "${AllHtmlFiles[@]}"
    do
            if [[ "$file" != "./index.html" && "$file" != "./test.html" && "$file" != "./content/page0.html" ]]
            then

                hashTag=${file/./#}
                printf "%s\\n" "    page$_loopCounter_: {"

                    foundName=${file##*/}
                    foundName=${foundName//.html} # remove '.html'
                    title="$foundName"
                    foundName=${foundName//_}     # remove underscores           # collapse the file name down to a #Reference
                    foundName=${foundName// }     # remove spaces
                    foundName=${foundName//-}     # remove hyphens
                    printf "%s\\n" "        name: \"$foundName\","
                    printf "%s\\n" "        sourceURL: \"$file\","
                    printf "%s\\n" "        hashTag: \"$hashTag\","
                    printf "%s\\n" "        title: \"$title\","
                    printf "%s\\n" "        injector: \"injectHere\","
                    printf "%s\\n" "        description: \"page$_loopCounter_ description.\","
                    printf "%s\\n" "        innerHTML: \"$title\""
                    printf "%s\\n" "    },"
                
                (( _loopCounter_ = _loopCounter_ + 1 ))
            
            fi
    done

}



main

# page0: {
#         name: "index",              // the source filename sans '.html'
#         sourceURL: "./content/page0.html",    // the important bit - the actual source file
#         hashTag: "#/content/index.html",    // what this page should look like in the address bar
#         title: "index",             // for setting the document title
#         injector: "injectHere",     // the important bit - where to actually inject the content into
#         description: "page0 desc.", // more for documentation than anything else
#         innerHTML: "index"          // may not be useful, just in case we need an alias showing on the page
#     },