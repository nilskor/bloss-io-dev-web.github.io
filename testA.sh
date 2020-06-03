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
#declare -grix  TRUE=0
#declare -grix FALSE=1

function   setIFS(){ IFS=$'\n\t'; }
function unsetIFS(){ IFS= ;       }

function echo()
(
    fmt=%s end=\\n IFS=" "

    while [ $# -gt 1 ]
    do
        case "$1" in
            [!-]*|-*[!ne]*) break ;;
            *ne*|*en*) fmt=%b end= ;;
            *n*) end= ;;
            *e*) fmt=%b ;;
        esac
        shift
    done

    printf "$fmt$end" "$*"
    setIFS
)


function someFunction1()
{
    echo "someFunction1() $#, $@"

    local result=""
    result="freddo frog"
    eval "$1=\${result}"
}

names="Netgear
Hon Hai Precision Ind. Co.
Apple"

unsetIFS

IFS=$'\n'      # Change IFS to new line

names=($names) # split to array $names

setIFS

for (( i=0; i<${#names[@]}; i++ ))
do
    echo "$i: ${names[$i]}"
done

echo -e "\n FreddoFrog      IsYummyChocolate FreddoFrog      IsYummyChocolate     # the original string \n"
perl -pe 's/(  )+/ /g' <<< 'FreddoFrog      IsYummyChocolate FreddoFrog      IsYummyChocolate'
echo ""

# Grep replacement:
test1="FreddoFrog      IsYummyChocolate FreddoFrog      IsYummy Chocolate"
echo -e "$test1"
pattern="(?<=y)\b\s.*colate"
perl -nle " if ( /($pattern)/ ) { print \"\$1\\n\" } " <<< "$test1"

# Sed replacement:
test1="FreddoFrog      IsYummyChocolate FreddoFrog      IsYummy Chocolate"
echo -e "$test1"
pattern="(  )+"
newStuff=' '
perl -ple "s/$pattern/$newStuff/g" <<< "$test1"
echo ""

# Sed replacement:
test1="FreddoFrog      IsYummyChocolate FreddoFrog      IsYummy Chocolate"
echo -e "$test1"
pattern="(  )+"
newStuff=' '
perl -pe "s/$pattern/$newStuff/g" <<< "$test1"
echo ""

source ./StringFunctions
declare chocolate="Caramel Koala"
StringClass Length "$chocolate"
SC SubString "$chocolate" 1 $(( $(_sc Len "$chocolate") - 2 ))

# A 'split' function could simply do two substring calls ..
declare chocolate="CaramelKoala"
declare -i split=8
SC SubString "$chocolate" 1 $(( split - 1 ))
SC SubString "$chocolate" $split '-nl'

# An 'insert' function could simply do a 'split' call
declare newString="Raspberry"
result=$(SC SubString "$chocolate" 1 $(( split - 1 )))"$newString"$(SC SubString "$chocolate" $split '-nl')
echo -e "\n$result \n"

# od --width=32 -t x1 -v -Ad serviceClient.sh > rubbish

CmdSubst()
{
    _cmdToRun=$1
    shift
    eval "$_cmdToRun="'$("$@"; statusOfLastTask=$?; echo .; exit "$statusOfLastTask")
                       _statusOfLastTask=$?
                     '"$_cmdToRun=\${$_cmdToRun%?}"
    return "$_statusOfLastTask"
}

ReadFile()
{
    local _fileName=""
    CmdSubst _fileName cat "$2"
    eval "$1=\${_fileName}"
}

names=".Netgear
Hon Hai Precision Ind. Co.
Apple
."

CmdSubst _result2 echo -e "$names"
echo -e "'${_result2}'"

echo -e "'$names'"

CmdSubst _result2 cat scratchpad.txt
echo -e "${#_result2}"

_result3=$(cat scratchpad.txt)
echo -e "${#_result3}"

_result3="$(< scratchpad.txt)"
echo -e "${#_result3}"

ReadFile _result3 scratchpad.txt
echo -e "${#_result3}, $_result3"

StringClass Length "abcde"
StringClass CountBytes "abcde"
StringClass CountChars "abcde"
StringClass CountBytes scratchpad.txt --explain
StringClass Length scratchpad.txt