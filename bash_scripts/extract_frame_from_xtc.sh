#!/bin/bash -e
show_help() {
  echo "usage: -i [input file *.xtc] -a [initial pymol structure] -t [time(ps)] [-n new_name]"
}

##### parse input
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
input_file=""
time=""
pymol_load=""
new_name=""

while getopts "h?i:t:a:n:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    i)  input_file=$OPTARG
	;;
    t)  time=$OPTARG
	;;
    a)  pymol_load=$OPTARG
	;;
    n)  new_name=$OPTARG
	;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z $input_file ] && show_help && exit 1
[ -z $time ] && show_help && exit 1
[ -z $pymol_load ] && show_help && exit 1

##### main function
run=$(echo "$input_file" | grep -Po '^[^.]*(?=[^.]*)')
ext=$(echo "$input_file" | grep -Po '[^.]*(?=$)')
pymol_load_name=$(echo "$pymol_load" | grep -Po '^[^.]*(?=[^.]*)')
pymol_load_ext=$(echo "$pymol_load" | grep -Po '[^.]*(?=$)')

framextc="$run"_at_"$time"ps."$ext"
pymol_out="$run"_at_"$time"ps.pdb
echo -e "System\nSystem" | gmx_mpi trjconv -f "$run"."$ext" -b "$time" -e "$time" -o "$framextc"

##old version cannot load .gro file
#pymol -cq -d "load "$pymol_load", mol; load_traj "$framextc",mol; save "$pymol_out", mol, state=2"

[ ! "$pymol_load_ext" = "pdb" ] && gmx_mpi editconf -f "$pymol_load" -o "$pymol_load_name"_temp.pdb

pymol -cq -d "load "$pymol_load_name"_temp.pdb, mol; load_traj "$framextc", mol; save "$pymol_out", mol, state=2"
rm "$pymol_load_name"_temp.pdb
[ ! -z "$new_name" ] && mv "$pymol_out" "$new_name"
