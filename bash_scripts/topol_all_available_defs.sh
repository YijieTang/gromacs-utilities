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

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z "$input_file" ] && show_help && exit 1

##### main function
grep -nHPo --color=always "(?<=#ifdef ).*" "$input_file"

passed=true

function recursion(){
  base=$(dirname "$1")
  files=($(grep -Po '"\K(.*[.]itp)?(?=")' "$1"))

  for file in "${files[@]}"
  do
    [ -z "$base" ] || [ "$base" = "." ] || file="$base"/"$file"
    if [ -e $file ] || [ -e "$GMXHOME/share/gromacs/top/$file" ]
    then
      [ -e "$file" ] || file="$GMXHOME/share/gromacs/top/$file"
      grep -nHPo --color=always "(?<=#ifdef ).*" "$file"
      var="$(recursion "$file")"
      [ -z "$var" ] || echo "$var"
    else
        echo -e "\e[31m✕\e[39m file not found: $file"
        passed=false
    fi
  done
}

recursion "$input_file"

if $passed
then
  echo "PASSED: ifdef constants in top and included itp are printed!"
else
  echo "ERROR: some included itp file does not exist!"
  exit 1
fi
