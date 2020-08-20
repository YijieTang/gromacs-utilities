PYDIR="~/GROMACS/gromacs-utilities/python_scripts"
PYMOLDIR="~/GROMACS/gromacs-utilities/pymol_scripts"

echo "run topol_check.sh on the topology file, check all relavent .itp files"
echo "run topol_all_available_defs.sh to check all available defines in topology"
echo "run check_defined_constants.sh with topology and mdp to check defined keywords in .mdp"
echo """
open .gro in pymol, run show_disre.py and show_dihre.py, check all restraints
e.g.
pymol asqj-fe-akg-dhcpcf3-mix_dodec_solv_neutral.gro "$PYMOLDIR"/asqj-align.pml -d 'run "$PYDIR"/show_disre.py;run "$PYDIR"/show_dihre.py;run "$PYDIR"/show_angre.py'

try the following cmd:
before_md.sh *.top *.mdp *.mdp ...
"""

arr=("$@")

[ "$#" == 0 ] && exit

date
echo "topol_check.sh -f $1"
topol_check.sh -f $1
echo ""
echo "topol_all_available_defs.sh -f $1"
topol_all_available_defs.sh -f $1
echo ""

for i in $(seq 1 $(( $# - 1 )))
do
  echo "check_defined_constants.sh -f $1 -m ${arr[$i]}"
  check_defined_constants.sh -f $1 -m ${arr[$i]}
  echo ""
done

#for i in ${arr[@]}
#do
#  cat $i
#done
