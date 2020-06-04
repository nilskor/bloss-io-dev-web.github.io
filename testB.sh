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

source ./StringFunctions

#set -vx

echo -e ""

declare -a test1=()
declare -A test2=()
declare someCrap
declare data='some
dummy extrå long
string that needs cöunting'


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              isNumber test (not yet implemented)                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

printf %f -1e32 &>/dev/null && echo "-1e32 is a number" || echo "-1e32 is not a number \n"


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              Array Type tests                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

declare -p test1 2>/dev/null | grep -q '^declare \-a' && echo "test1 is an indexed array" || echo "test1 is not an indexed array"

declare -p test2 2>/dev/null | grep -q '^declare \-A' && echo "test2 is an associative array" || echo "test2 is not an associative array"

declare -p data 2>/dev/null | grep -q '^declare \-[aA]' && echo "data is an array" || echo "data is not an array"

declare -p test1 2>/dev/null | grep -q '^declare \-[aA]' && echo "test1 is an array type" || echo "test1 is not an array type"


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              Counting tests                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

_CountBytes someCrap "$data"

echo -e "Byte count is: $someCrap, for the string: $data \n"

_CountBytes someCrap index.html

echo -e "Byte count for index.html is: $someCrap \n"

_CountChars someCrap "$data"

echo -e "Char count is: $someCrap, for the string: $data \n"

_CountChars someCrap index.html

echo -e "Char count for index.html is: $someCrap \n"

_CountLines someCrap "$data"

echo -e "Line count is: $someCrap, for the string: $data \n"

_CountLines someCrap index.html

echo -e "Line count for index.html is: $someCrap \n"

_CountWords someCrap "$data"

echo -e "Word count is: $someCrap, for the string: $data \n"

_CountWords someCrap index.html

echo -e "Word count for index.html is: $someCrap \n"

_Length someCrap "fred sdfsfds fsfdf vsdfs dfvsdfs"

echo -e "String length for 'fred sdfsfds fsfdf vsdfs dfvsdfs' is: $someCrap \n"

_CountChars someCrap "fred sdfsfds fsfdf vsdfs dfvsdfs"

echo -e "Char count for 'fred sdfsfds fsfdf vsdfs dfvsdfs' is: $someCrap \n\nCharCount with --explain: (note the trailing LF Line Feed - Char '0x0a')\n"

_CountChars someCrap "fred sdfsfds fsfdf vsdfs dfvsdfs" '--explain'

_Length someCrap "$data"

echo -e "\n\nString length of '$data' is: $someCrap \n"

_Length someCrap index.html

echo -e "String length of 'index.html' is: $someCrap \n"


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              Find tests                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

_Find someCrap "href=\"#index\"" index.html

echo -e "Trying to find href=\"#index\" in 'index.html' returned: $someCrap \n"

_Find someCrap "^[[:space:]]+<a" index.html

echo -e "Trying to find '^[[:space:]]+<a' in 'index.html' returned: $someCrap \n"

_Find someCrap "href=\"#index\"" index.html '-s'

echo -e "Trying to find href=\"#index\" in 'index.html' returned: $someCrap \n"

someLink='<a name="GTK_Tools" class="two" href="/content/GTK3/GTK_Tools.html">GTK+ Tools</a>'
echo -e "someLink: $someLink"
_Find someCrap '(?<=\>)(.+)(?=\<)' "$someLink" '-s'
echo -e "\nTrying to find '(?<=\>)(.+)(?=\<)' in '\$someLink' returned: $someCrap \n"


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              Find and Replace tests                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

_FindReplace someCrap html FROG testFile.html -aw
echo -e "In the file 'testFile.html', we replaced 'html' with 'FROG'. \n"
#_FindReplace someCrap FROG html testFile.html -aw
#echo -e "In the file 'testFile.html', we replaced 'FROG' with 'html'. \n"

echo "FreddoFrog      IsYummyChocolate     # the original string"
_FindReplace someCrap [[:space:]][[:space:]] " " 'FreddoFrog      IsYummyChocolate' -a
echo -e "$someCrap        # the string modified with _FindReplace '  ' and -a \n"

echo "FreddoFrog      IsYummyChocolate     # the original string"
_FindReplace someCrap 'FreddoFrog' 'CaramelKoala' 'FreddoFrog      IsYummyChocolate'
echo -e "$someCrap   # the string modified with _FindReplace '  ' \n"

echo "FreddoFrog      IsYummyChocolate     # the original string"
_FindReplace someCrap 'Chocolate' 'CocoaButter' 'FreddoFrog      IsYummyChocolate'
echo -e "$someCrap   # the string modified with _FindReplace '  ' \n"

echo "FreddoFrog      IsYummyChocolate     # the original string"
_regexFindReplace someCrap "\s{2,}" " " 'FreddoFrog      IsYummyChocolate' -a
echo -e "$someCrap          # the string modified with _regexFindReplace '\s{2,}' and -a \n"

echo "FreddoFrog      IsYummyChocolate     # the original string"
_regexFindReplace someCrap "(  )+" " " 'FreddoFrog      IsYummyChocolate' -a
echo -e "$someCrap          # the string modified with _regexFindReplace '(  )+' and -a \n"

echo "FreddoFrog      IsYummyChocolate FreddoFrog      IsYummyChocolate     # the original string"
_regexFindReplace someCrap '(  )+' ' ' 'FreddoFrog      IsYummyChocolate FreddoFrog      IsYummyChocolate' -a
echo -e "$someCrap               # the string modified with _regexFindReplace '(  )+' and -a \n"


#declare sedTest="FreddoFrog      IsYummyChocolate FreddoFrog      IsYummyChocolate"
#declare sedPattern="(  )+"
#sed -r "s/$sedPattern/ /g" <<< "$sedTest"

#stringToBeSearched="$sedTest"
#thePattern="$sedPattern"
#newString=" "
#_ret_findReplace=`sed -r s/"$thePattern"/"$newString"/ <<< "$stringToBeSearched"` || _ret_findReplace=""  # once
#echo -e "\n'_ret_findReplace': $_ret_findReplace \n"


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              FindAll and SubString tests                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

refText='<a name="Migrating_GTK" class="two" href="/content/GTK3/Migrating_GTK.html">Migrating from Previous Versions of GTK+</a>'
echo -e " Original text:\n\n $refText\n"

_FindAll someCrap '(?<=\>)(.+)(?=\<)' "$refText"
declare -A ArrayOfStrings=()
echo -e " Before unravelling: $someCrap \n"
eval "$someCrap"
echo -e " refText: \"${ArrayOfStrings[@]}\" ; contains ${#ArrayOfStrings[@]} element(s).\n"

_Length someLength "${ArrayOfStrings[@]}"
_SubString someCrap "${ArrayOfStrings[@]}" 1 "( $someLength - 2 )"

echo -e " $someCrap \n"

StringClass SubString "${ArrayOfStrings[@]}" 1 $(( $(StringClass Length "${ArrayOfStrings[@]}") - 2 ))
echo ""

_SubString someCrap "FreddoFrogIsYummyChocolate" 13 5
echo -e " From the string 'FreddoFrogIsYummyChocolate', position 13, length 5 gives: $someCrap \n"

                                                                          #char 64 is the LF
choccy='FreddoFrog IsYummyChocolate FreddoFrog IsYummyChocolate. Freddo
    Frog IsYummyChocolate FreddoFrog IsYummyChocolate.'
_FindAll someCrap 'Yummy' "$choccy"
eval "$someCrap"
echo -e " FindAll 'Yummy' in 'FreddoFrog IsYummyChocolate FreddoFrog IsYummyChocolate.' \n"
#echo -e "Array: \"${ArrayOfStrings[@]}\" ; contains ${#ArrayOfStrings[@]} element(s).\n"
echo -e " $someCrap"


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              Trim tests                                                             "
echo -e " ----------------------------------------------------------------------------------\n"
echo -e " RTrim:"
echo -e "=======\n"

echo -e "'Freddo         Frog                   '      # original text \n"

_RTrim someCrap "Freddo         Frog                   "
echo -e "${#someCrap} is the length of the RTrim'd text \n\n"

echo -e " wsTrim:"
echo -e "=======\n"

echo -e "Freddo         Frog                   .       # original text \n"
_wsTrim someCrap "Freddo         Frog                   ."
echo -e "${someCrap}                                  # default, using wsTrim \n"

_wsTrim someCrap "Freddo         Frog                   ." "-s"
echo -e "${someCrap}               # -s (single) \n\n"

echo -e "Freddo         . Frog                   .     # original text \n"
_wsTrim someCrap "Freddo         . Frog                   ." "-f"
echo -e "${someCrap}             # -f (first) \n"

_wsTrim someCrap "Freddo         . Frog                   ."
echo -e "$someCrap                                 # default - do all \n"

# -- other examples for a gist ..

./StringFunctions FindReplace '-' '_' "$(./StringFunctions CreateUUID 2)" -a
echo ""

./StringFunctions Insert abcdef $(./StringFunctions RandomString 128) 30 4
echo ""

refText='<a name="Migrating_GTK" class="two" href="/content/GTK3/Migrating_GTK.html">Migrating from Previous Versions of GTK+</a>'
_Insert someCrap 'href="some.link" ' "$refText" 4
echo -e "$someCrap \n"

