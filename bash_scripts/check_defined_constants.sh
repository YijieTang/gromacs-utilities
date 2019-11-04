#!/bin/bash

show_help() {
  echo "usage: -f *.top -m *.mdp"
}

##### parse input
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
topfile=""
mdpfile=""

while getopts "h?f:m:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    f)  topfile=$OPTARG
        ;;
    m)  mdpfile=$OPTARG
	;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z "$topfile" ] && show_help && exit 1
[ -z "$mdpfile" ] && show_help && exit 1


##### main function

# $1 is the mdp file
get_defined_constants(){
  [ -f "$1" ] || exit 1
  grep -Po '^[^;]*define[^;]*=[^;]*' $1 | grep -Po '(?<==).*' | grep -Po "(?<= -D)[^ ]+"
}

# $1 is defined keyword, e.g. POSRES_AKG (-D is removed)
# $2 is topology file, $3 is a list of all included itp files
# return the file name under the keyword, e.g. posre_akg.itp
defined_constant_to_file(){
  grep -zPoh "(?<=ifdef "$1"\n#include) .*\n(?=#endif)" $2 $3 | grep -Pao '(?<=").*(?=")'
}


constants=$(get_defined_constants $mdpfile)
checkfiles=$($(dirname "$0")/topol_check.sh -f $topfile | grep -Po "(?<= )[a-zA-Z0-9_]+.itp")

passed=true
for constant in ${constants[@]}
do
  fname=$(defined_constant_to_file "$constant" "$topfile" "$checkfiles")
  if [ -z "$fname" ]
  then
    echo -e "\e[31m✕\e[39m $constant is not found in $topfile or its included itp files"
    passed=false
  else
    if [ -f "$fname" ]
    then
      echo -e "\e[32m✔\e[39m $constant corresponds to $fname, and $fname exists"
    else
      echo -e "\e[31m✕\e[39m $constant corresponds to $fname, but $fname does not exist"
      passed=false
    fi
  fi
done

if $passed
then
  echo "PASSED: mdp constants check passed!"
else
  echo "ERROR: mdp constants check failed!"
  exit 1
fi
