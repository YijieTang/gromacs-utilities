#!/bin/bash

show_help() {
  echo "usage: -f *.top  gromacs topology file"
}

##### parse input
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
input_file=""

while getopts "h?f:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    f)  input_file=$OPTARG
        ;;
    esac
done

# set the remaining args to $1, $2, ...
shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z "$input_file" ] && show_help && exit 1

##### main function

passed=true

function recursion() {
  files=($(grep -Po '"\K(.*[.]itp)?(?=")' "$1"))

  for file in "${files[@]}"
  do
    if [ -e "$file" ] || [ -e "$GMXHOME/share/gromacs/top/$file" ]
    then
      for i in $(seq 1 $2)
      do
        printf "  "
      done

      [ -e "$file" ] || file="$GMXHOME/share/gromacs/top/$file"
      echo -e "\e[32m✔\e[39m file found: $file"
      dir=$(pwd)
      fname=$(echo "$file" | grep -Po '(?<=/|^)([^/]*$)')
      newDir=$(echo "$file" | grep -Po '\K(.*)?(?=/)')
      [ -z "$newDir" ] && newDir=$dir
      cd "$newDir"
      var="$(recursion "$fname" $(($2 + 1)) )"
      [ -z "$var" ] || echo "$var"
      cd "$dir"
    else
      echo -e "\e[31m✕\e[39m file not found: $file"
      passed=false
    fi
  done
}

recursion "$input_file" 0
if $passed
then
  echo "PASSED: topology check passed!"
else
  echo "ERROR: topology check failed!"
  exit 1
fi
