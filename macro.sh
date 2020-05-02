#!/bin/bash

totalFiles=0

targetLine="^[ ]*<h3><a.+.href=./content/GTK3/"   # This is the target line we want to find and update (written as a RegEx).
fileName="[-0-9A-Za-z_\ \W]+(.html)"         # The global set of 'pages' in this hybrid SPA are in index.html as links, and
                                             # those links have #References made up of the file-names (creating uniqueness).
                                             # Searching for the file-names is written here as a RegEx.
#
#echo "$targetLine"
#echo "$fileName"

function processWithSed2()
{
    echo -e "\n $1\n $2\n"

    lineCounter=0
    wholeFile=""
    wholeFile="$(sed -rn 's/.*/&/p' $1)"
    result="$(sed -r 's:^[ ]*<h3><a.+.href=./content/GTK3/.*</a></h3>:#####-the-replacement-line-goes-here-#####:' <<< $wholeFile)"
    echo "$result"

    if [[ ${#wholeFile} -lt 0 ]]
    then

        while read line
        do
            #echo "Each original line is : $line"
            #echo "$(sed -rn 's/[ ]*<h3><a[ ]*.*<.a><.h3>/#####-the-replacement-line-goes-here-#####/p' <<< $line)"
            echo "$(sed -rn 's:^[ ]*<h3><a.+.href=./content/GTK3/.*</a></h3>:#####-the-replacement-line-goes-here-#####:p' <<< $line)"
            ((lineCounter++))
        done < <(echo "$wholeFile")
    fi
    #echo -e "\nlineCount is $lineCounter\n"
    #echo "$wholeFile"
}

function processWithSed()
{
    result=""
    result="$(sed -r -n '/^[ ]*<h3><a[ ].*href=\"\/content\/GTK3\//p' "$1")"
    if [[ ${#result} -gt 0 ]]
    then
        echo "$1"
        echo "$result"
        echo -e "\n Now to process the results as if it were a file ..\n"
        while read line
        do
            echo "Each line: $line"
        done < <(echo "$result")
    fi
}

function processor()
{
    result="$(grep -E -ic "$targetLine" "$1")"  # Use grep to test the file for anything useful

    lineContent=""
    foundName=""

    if [ $result -gt 0 ]                        # If grep can't find anything in this file, move on ..
    then

        echo -e "\n Current file: $1\n Found $result occurrences.\n"
        lineContent="$(grep -E -i "$targetLine" "$1")"   # find the target line we want to update
        echo -e " Line content is:\n$lineContent"

        foundName="$(grep -E -i -o "$fileName" <<< "$lineContent")"  # extract the file name
        foundName=${foundName//_}     # remove underscores           # collapse the file name down to a #Reference
        foundName=${foundName// }     # remove spaces
        foundName=${foundName//-}     # remove hyphens
        foundName=${foundName//.html} # remove '.html'

        #echo -e "$foundName"
        #grep -E -i "~/dev2/hspa7/index.html" <<< "$foundName"
        
        while read line
        do
            replacementLine=""
            echo -e " Read a line: $line"                 # search index.html for #Reference, as that will be the replacement line
            replacementLine="$(grep -E -i "#$line'" '/home/mag/dev2/hspa7/index.html')"
            echo "$replacementLine"
            processWithSed2 "$1" "$replacementLine"

        done < <(echo "$foundName")
    fi
}
 
while IFS= read file
do

    ((totalFiles++))
    processor "$file"           # send each file thru to the 'processor' function.
    echo -e "\n"
    processWithSed2 "$file"

done < <(find -iname "GTK3test.html")  # this starts it all off, the search for html files to be modified.
 
echo -e "Searched $totalFiles html files for links.\n"

#echo | awk '{ print substr("'"${String}"'",3,4)}'
