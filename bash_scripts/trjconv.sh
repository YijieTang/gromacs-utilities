#!/bin/bash -e
# 1ns NPT equilibrium
show_help() {
  echo "usage: -i [input file, *.gro or *.xtc] [-t *.tpr] [-b begin(ps)] [-e end(ps)] [-s record every nth step]"
}

##### parse input
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
input_file=""
verbose=0

while getopts "h?i:t:b:e:s:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    i)  input_file=$OPTARG
	;;
    t)  top_file=$OPTARG
	;;
    b)  begin=$OPTARG
	;;
    e)  end=$OPTARG
	;;
    s)  skip=$OPTARG
	;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z $input_file ] && show_help && exit 1

##### main function
. gmx_functions.sh
run=$(echo "$input_file" | grep -Po '^[^.]*(?=[^.]*)')
ext=$(echo "$input_file" | grep -Po '[^.]*(?=$)')
[ -z $top_file ] && top_file="$run".tpr
[ -z $begin ] && begin=0
[ -z $skip ] && skip=1

if [ -z $end ];
then
  echo -e "2\n0" | gmx_mpi trjconv -s "$top_file" -f "$run"."$ext" -b "$begin" -skip "$skip" -o "$run"_wholemolcentercompact."$ext" -pbc mol -center -ur compact
else
  echo -e "2\n0" | gmx_mpi trjconv -s "$top_file" -f "$run"."$ext" -b "$begin" -e "$end" -skip "$skip" -o "$run"_wholemolcentercompact."$ext" -pbc mol -center -ur compact
fi

echo -e "2\n0" | gmx_mpi trjconv -s "$top_file" -f "$run"_wholemolcentercompact."$ext" -o "$run"_trjconv."$ext" -fit rot+trans
rm "$run"_wholemolcentercompact."$ext"
#mv "$run"."$ext" "$run"."$ext".orig
#mv "$run"_trjconv."$ext" "$run"."$ext"
