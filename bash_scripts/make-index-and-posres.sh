#!/bin/bash
show_help() {
  echo "usage: -c *.gro -n *.ndx"
}

##### parse input
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?n:c:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    n)  ndx=$OPTARG
        ;;
    c)  gro=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z $ndx ] && show_help && exit 1
[ -z $gro ] && show_help && exit 1

##### main function

pro_heavy_itp="posre_PRO-H.itp"
backbone_itp="posre_PRO_BACKBONE.itp"

echo -ne '! "Water_and_ions"\nq\n' | gmx_mpi make_ndx -f "$gro" -o "$ndx"
sed -i 's/!Water_and_ions/non-Water_and_ions/' "$ndx"
echo -ne "Protein-H\n" | gmx_mpi genrestr -f "$gro" -n "$ndx" -o "$pro_heavy_itp"
echo -ne "Backbone\n" | gmx_mpi genrestr -f "$gro" -n "$ndx" -o "$backbone_itp"

grep "POSRES_PRO-H" topol_pro.itp || echo -ne "\n#ifdef POSRES_PRO-H\n#include \""$pro_heavy_itp"\"\n#endif\n" >> topol_pro.itp
grep "POSRES_PRO_BACKBONE" topol_pro.itp || echo -ne "\n#ifdef POSRES_PRO_BACKBONE\n#include \""$backbone_itp"\"\n#endif\n" >> topol_pro.itp
