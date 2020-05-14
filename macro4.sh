#!/bin/bash

#set -x -E -u -v
#set -u -x -E

# Will exit script if we would use an uninitialised variable:
# either set -u or set -o nounset
set -o nounset

# Will exit script when a simple command (not a control structure) fails:
# either set -e or set -o errexit
set -o errexit

# Will print shell input lines as they are read. 
# either set -v or set -o verbose

# Will print a trace of simple commands as they are expanded and executed.
# either set -x or set -o xtrace


# set variables 
declare -r TRUE=0
declare -r FALSE=1

#===============================================
#
# String Functions:
#
#   Length         ${#string}
#
#   SubString      ${string:position}
#                  or
#                  ${string:position:length}
#
#   Delete(front)  ${string#substring}                     deletes the shortest match of $substring from front of $string
#                  or
#   Delete(back)   ${string%substring}                     deletes the shortest match of $substring from back  of $string
#                  or
#   Delete(long,front)
#                  ${string##substring}                    deletes the longest  match of $substring from front of $string
#                  or
#   Delete(long,back)
#                  ${string%%substring}                    deletes the longest  match of $substring from back  of $string
#
#   Find+Replace   ${string/pattern/replacement}           only the first match
#                  or
#   Find+Replace   ${string//pattern/replacement}          replace all matches
#                  or
#   Find+Replace(front)
#                  ${string/#pattern/replacement}          match and replace from the start
#                  or
#   Find+Replace(back)
#                  ${string/%pattern/replacement}          match and replace from the back
#
#
#===============================================


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
(
    echo -e "$1"
)

function trim()
(
    local func_result="$(sed -r 's/^\s*(\S+(\s+\S+)*)\s*$/\1/' <<< "$1")"
    echo "$func_result"
)

function cmn_replace_in_files 
(

  local search=${1}
  local replace=${2}
  local files=${@:3}

  for file in ${files[@]}; do
    if [[ -e "${file}" ]]; then
      if ( grep --fixed-strings --quiet "${search}" "${file}" ); then
        perl -pi -e "s/\Q${search}/${replace}/g" "${file}"
      else
        cmn_echo_warn "Could not find search string '${search}' (thus, cannot replace with '${replace}') in file: ${file}"
      fi
    else
        cmn_echo_warn "File '${file}' does not exist (thus, cannot replace '${search}' with '${replace}')."
    fi
  done

)

function processWithSed2()
(

    lineCounter=0

    log "\n $1 \n $2 \n $3 \n"

    result="$(sed -r "s:$2:<h3>$3</h3>:" <<< $wholeFile)"
    log "\n ::THE RESULT: \n$result"

    if [[ ${#wholeFile} -lt 0 ]] # wrong!!!!!!
    then

        while read line
        do
            echo "$(sed -rn 's:^[ ]*<h3><a.+.href=./content/GTK3/.*</a></h3>:#####-the-replacement-line-goes-here-#####:p' <<< $line)"
            ((lineCounter++))
        done < <(echo "$wholeFile")
    fi
)


function processor()
(
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
)

while IFS= read file
do

    processor "$file"

done < <(find -iname "GTK3test.html")
