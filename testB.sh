#!/bin/bash

# Will exit script if we would use an uninitialised variable:
# either set -u or set -o nounset
set -o nounset

# Will exit script when a simple command (not a control structure) fails:
# either set -e or set -o errexit
set -o errexit

# This setting prevents errors in a pipeline from being masked.
set -o pipefail

# Useful string splitting behaviour occurs with IFS=$'\n\t'
# The default is to split on spaces, tabs and newlines $' \n\t'
IFS=$'\n\t'

# Set variables:
#declare -ri  TRUE=0
#declare -ri FALSE=1

#echo -e "::: TestB :::Length of [LINES] is: ${#LINES[@]}, :::Contents of [LINES] is: ${LINES[@]}"
source ./StringFunctions
#echo -e "::: TestB-1 :::Length of [LINES] is: ${#LINES[@]}, :::Contents of [LINES] is: ${LINES[@]}"

#set -vx

echo -e ""

declare -a test1=()
declare -A test2=()
declare someCrap
declare data='some
dummy extra long
string that needs counting'

#echo -e "::: TestB-2 :::Length of [LINES] is: ${#LINES[@]}, :::Contents of [LINES] is: ${LINES[@]}"

#printf %i .1
printf %f -1e32 &>/dev/null && echo "-1e32 is a number" || echo "-1e32 is not a number"
echo ""

declare -p test1 2>/dev/null | grep -q '^declare \-a' && echo "test1 is an indexed array" || echo "test1 is not an indexed array"
echo ""

declare -p test2 2>/dev/null | grep -q '^declare \-A' && echo "test2 is an associative array" || echo "test2 is not an associative array"
echo ""

declare -p data 2>/dev/null | grep -q '^declare \-[aA]' && echo "data is an array" || echo "data is not an array"
echo ""

declare -p test1 2>/dev/null | grep -q '^declare \-[aA]' && echo "test1 is an array type" || echo "test1 is not an array type"
echo ""

_countLines someCrap "$data"

echo -e "Line count is: $someCrap, for the string: $data \n"

_countLines someCrap index.html

echo -e "Line count for index.html is: $someCrap \n"

_countWords someCrap "$data"

echo -e "Word count is: $someCrap, for the string: $data \n"

_countWords someCrap index.html

echo -e "Word count for index.html is: $someCrap \n"

_stringLength someCrap "fred sdfsfds fsfdf vsdfs dfvsdfs"

echo -e "String length for 'fred sdfsfds fsfdf vsdfs dfvsdfs' is: $someCrap \n"

_stringLength someCrap "$data"

echo -e "String length of '$data' is: $someCrap \n"

_stringFind someCrap "href=\"#index\"" index.html

echo -e "Trying to find href=\"#index\" in 'index.html' returned: $someCrap \n"

_stringFind someCrap "^[[:space:]]+<a" index.html

echo -e "Trying to find '^[[:space:]]+<a' in 'index.html' returned: $someCrap \n"

_findReplace someCrap html FROG testFile.html -aw
echo -e "In the file 'testFile.html', we replaced 'html' with 'FROG'. \n"
#_findReplace someCrap FROG html testFile.html -aw
#echo -e "In the file 'testFile.html', we replaced 'FROG' with 'html'. \n"

_subString someCrap "FreddoFrogIsYummyChocolate" 12 5

echo -e "From the string 'FreddoFrogIsYummyChocolate', offset 12, length 5 gives: $someCrap \n"

_findReplace someCrap [[:space:]][[:space:]] " " 'FreddoFrog      IsYummyChocolate' -a

echo -e "$someCrap"

declare sedTest="FreddoFrog      IsYummyChocolate FreddoFrog      IsYummyChocolate"
declare sedPattern="(  )+"
echo ""
sed -r "s/$sedPattern/ /g" <<< "$sedTest"

stringToBeSearched="$sedTest"
thePattern="$sedPattern"
newString=" "
_return_findReplace=`sed -r s/"$thePattern"/"$newString"/ <<< "$stringToBeSearched"` || _return_findReplace=""  # once
echo ""
echo -e "'_return_findReplace': $_return_findReplace \n"

refText='<a name="Migrating_GTK" class="two" href="/content/GTK3/Migrating_GTK.html">Migrating from Previous Versions of GTK+</a>'

_stringFind2 someCrap '(?<=\>)(.+)(?=\<)' "$refText"
declare -A ArrayOfStrings=()
echo -e "Before unravelling: $someCrap \n"
eval "$someCrap"
echo -e "refText: \"${ArrayOfStrings[@]}\" ; contains ${#ArrayOfStrings[@]} element(s).\n"

_stringLength someLength "${ArrayOfStrings[@]}"
_subString someCrap "${ArrayOfStrings[@]}" 1 "( $someLength - 2 )"

echo -e "$someCrap \n"

StringClass subString "${ArrayOfStrings[@]}" 1 $(( $(StringClass stringLength "${ArrayOfStrings[@]}") - 2 ))
echo ""

