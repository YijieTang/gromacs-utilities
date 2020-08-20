#!/bin/bash
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
input_file=""
verbose=0

show_help() {
  echo "usage: -f [*.gro input gro file] -o [*.itp output itp file]"
}

while getopts "h?f:o:" opt; do
    case "$opt" in
    h)
        show_help
        exit 0
        ;;
    f)  GRO=$OPTARG
        ;;
    o)  itp=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

[ -z "$GRO" ] && show_help && exit 1
[ -z "$itp" ] && show_help && exit 1

#### main function

echo -ne '! a H*\nq\n' | gmx make_ndx -f $GRO -o _index.ndx
echo -ne '!H*\n' | gmx genrestr -f $GRO -o $itp -n _index.ndx
