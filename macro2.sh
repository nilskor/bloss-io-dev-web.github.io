#!/bin/bash

#set -x -E -u -v
#set -u -x -E

totalFiles=0

cmdFindALine="grep -E -i"
cmdFindAString="grep -E -i -o"
cmdStringCount="grep -E -ic"

indexFile="/home/mag/dev2/hspa7/index.html"

wholeFile=""

targetLineSearchPattern="^[ ]*<h3><a.+.href=./content/GTK3/"   # These are the target line(s) we want to find and update (written as a RegEx).
fileName="[-0-9A-Za-z_\ \W]+(.html)"              # The global set of 'pages' in this hybrid SPA are in index.html as links, and
                                             # those links have #References made up of the file-names (creating uniqueness).
                                             # Searching for the file-names is written here as a RegEx.
#

function log()
{
    echo -e "$1"
}
function trim()
{
    local func_result="$(sed -r 's/^\s*(\S+(\s+\S+)*)\s*$/\1/' <<< "$1")"
    echo "$func_result"
}


function processWithSed2()
{

    lineCounter=0

    log "\n $1 \n $2 \n $3 \n"

    #result="$(sed -r "s:$2:<h3>$3</h3>:" <<< $wholeFile)"
    #log "\n ::THE RESULT: \n$result"

    if [[ ${#wholeFile} -lt 0 ]] # wrong!!!!!!
    then

        while read line
        do
            echo "$(sed -rn 's:^[ ]*<h3><a.+.href=./content/GTK3/.*</a></h3>:#####-the-replacement-line-goes-here-#####:p' <<< $line)"
            ((lineCounter++))
        done < <(echo "$wholeFile")
    fi
}


function processor()
{
    thisCurrentFile="$1"
    wholeFile="$(sed -rn 's/.*/&/p' $1)"

    result=""
    result="$($cmdStringCount "$targetLineSearchPattern" "$thisCurrentFile")"

    anyLinesFound=""
    foundName=""

    if [ $result -gt 0 ]
    then

        anyLinesFound="$($cmdFindALine "$targetLineSearchPattern" "$thisCurrentFile")"   # find the target line we want to update

        while read line
        do

            foundName="$($cmdFindAString "$fileName" <<< "$line")"                       # extract the file name
            foundName=${foundName//_}
            foundName=${foundName// }
            foundName=${foundName//-}
            foundName=${foundName//.html}

            replacementLine=""
            replacementLine="$($cmdFindALine "#$foundName'" $indexFile)"
            replacementLine="$(trim "$replacementLine")"
            
            if [[ ${#replacementLine} -gt 0 ]]
            then
                processWithSed2 "$thisCurrentFile" "$line" "$replacementLine"
            fi

        done < <(echo "$anyLinesFound") 

    fi
}

while IFS= read file
do

    processor "$file"

done < <(find -iname "GTK3test.html")
