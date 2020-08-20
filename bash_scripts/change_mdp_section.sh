#!/bin/bash
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
input_file=""
verbose=0

show_help() {
  echo "usage: -f *.mdp -k keyword -v value"
}

while getopts "h?f:k:v:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    f)  mdp_file=$OPTARG
        ;;
    k)  key=$OPTARG
        ;;
    v)  value=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z "$mdp_file" ] && show_help && exit 1
[ -z "$key" ] && show_help && exit 1
[ -z "$value" ] && show_help && exit 1

#### main function
section=$(grep "^[^;]*"$key"\s*=.*" "$mdp_file")
replace="${key} = ${value}"
if [ -z "$section" ]
then
  echo -e "\e[31m✕\e[39m $key is not found or commented in $mdp_file"
else
  cp "$mdp_file" "$mdp_file".backup
  sed -i "s/\("$key".*=\).*/\1 $value/g" "$mdp_file"
  echo -e "\e[32m✔\e[7m $(echo $section | tr -d "\t")\e[27m is replaced by \e[7m$replace\e[27m"
  echo -e "$mdp_file has been backed up to "$mdp_file".backup\e[39m"
  diff -Naur "$mdp_file".backup "$mdp_file"
fi
