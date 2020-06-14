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

declare -a test1=()
declare -A test2=()
declare someCrap
declare data='some
dummy extrå long
string that needs cöunting'


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              isNumber test                                                          "
echo -e " ---------------------------------------------------------------------------------- \n"

_IsNumber someCrap -1e32
echo -e "IsNumber returned $someCrap for -1e32.        (1 is True, 0 is False)."

_IsNumber someCrap 'FreddoFrog'
echo -e "IsNumber returned $someCrap for 'FreddoFrog'. (1 is True, 0 is False)."


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              Array Type tests                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

echo -e "declare -a test1=()"
declare -p test1 2>/dev/null | grep -q '^declare \-a' && echo "test1 is an indexed array" || echo "test1 is not an indexed array"

echo -e "\ndeclare -A test2=()"
declare -p test2 2>/dev/null | grep -q '^declare \-A' && echo "test2 is an associative array" || echo "test2 is not an associative array"

echo -e "\ndeclare data='some
dummy extrå long
string that needs cöunting'"
declare -p data 2>/dev/null | grep -q '^declare \-[aA]' && echo "data is an array" || echo "data  is not an array"

echo -e ""
declare -p test1 2>/dev/null | grep -q '^declare \-[aA]' && echo "test1 is an array type" || echo "test1 is not an array type"


echo -e "\n ----------------------------------------------------------------------------------"
echo -e "              Counting tests                                                             "
echo -e " ---------------------------------------------------------------------------------- \n"

_CountBytes someCrap "$data"

echo -e "Byte count is: $someCrap, for the string: $data \n"

_CountBytes someCrap index.html

echo -e "Byte count for index.html is: $someCrap \n\n"

_Length someCrap "$data"

echo -e "String length of '$data' is: $someCrap \n"

_CountChars someCrap "$data"

echo -e "Char count is: $someCrap, for the string: $data \n\n"

_Length someCrap index.html

echo -e "String length of 'index.html' is: $someCrap \n"

_CountChars someCrap index.html

echo -e "Char count for index.html is: $someCrap \n\n"

_CountLines someCrap "$data"

echo -e "Line count is: $someCrap, for the string: $data \n"

_CountLines someCrap index.html

echo -e "Line count for index.html is: $someCrap \n\n"

_CountWords someCrap "$data"

echo -e "Word count is: $someCrap, for the string: $data \n"

_CountWords someCrap index.html

echo -e "Word count for index.html is: $someCrap \n\n"

_Length someCrap "fred sdfsfds fsfdf vsdfs dfvsdfs"

echo -e "String length for 'fred sdfsfds fsfdf vsdfs dfvsdfs' is: $someCrap \n"

_CountChars someCrap "fred sdfsfds fsfdf vsdfs dfvsdfs"

echo -e "Char count for 'fred sdfsfds fsfdf vsdfs dfvsdfs' is: $someCrap \n"

echo -e "\nCharCount with --explain: (note the trailing LF Line Feed - Char '0x0a')\n"

_CountChars someCrap "fred sdfsfds fsfdf vsdfs dfvsdfs" '--explain'
echo -e ""


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

_Find someCrap '<p>.*?</p>' GTK3test.html
echo -e "Multine-line search in GTK3test.html (no options), '<p>.*?</p>' found:\n$someCrap\n"

_Find someCrap '<div>.*?</div>' GTK3test.html
echo -e "Multine-line search in GTK3test.html (no options), '<div>.*?</div>' found:\n$someCrap\n"

declare -a someCrap2=()
_Find someCrap2 '<p>.*?</p>' GTK3test.html -mb
echo -e "Multine-line search in GTK3test.html (options -mb), '<p>.*?</p>' found ${#someCrap2[@]} elements:"

for iSC2 in "${someCrap2[@]}"
do
    echo -e "\nItem:\n\n$iSC2"
done
echo -e ""


_Find someCrap '<p>.*?</p>' GTK3test.html -scm
echo -e "Multine-line search in GTK3test.html (options -scm), '<p>.*?</p>' found:\n$someCrap\n"


_Find someCrap2 '<P>.*?</P>' GTK3test.html -scmb
echo -e "Multine-line search in GTK3test.html (options -scmb), '<P>.*?</P>' found ${#someCrap2[@]} elements:"

for iSC3 in "${someCrap2[@]}"
do
    echo -e "\nItem:\n\n$iSC3"
done
echo -e ""


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
_Substring someCrap "${ArrayOfStrings[@]}" 1 "( $someLength - 2 )"

echo -e " $someCrap \n"

StringClass Substring "${ArrayOfStrings[@]}" 1 $(( $(StringClass Length "${ArrayOfStrings[@]}") - 2 ))
echo ""

_Substring someCrap "FreddoFrogIsYummyChocolate" 13 5
echo -e " From the string 'FreddoFrogIsYummyChocolate', position 13, length 5 gives: $someCrap \n"

                                                                          #char position # 64 is the LF
choccy='FreddoFrog IsYummyChocolate FreddoFrog IsYummyChocolate. Freddo
    Frog IsYummyChocolate FreddoFrog IsYummyChocolate.'
_FindAll someCrap 'Yummy' "$choccy"
eval "$someCrap"
echo -e "\n FindAll 'Yummy' in '$choccy' \n"
#echo -e "Array: \"${ArrayOfStrings[@]}\" ; contains ${#ArrayOfStrings[@]} element(s).\n"
echo -e " $someCrap\n"

_FindAll someCrap 'Yummy' "$choccy" '-m'
eval "$someCrap"
echo -e "\n FindAll 'Yummy' in '$choccy' -m \n"
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

