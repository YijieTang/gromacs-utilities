awk '{if($0=="@<TRIPOS>BOND"){flag=0};if(flag){sum+=$9;};if($0=="@<TRIPOS>ATOM"){flag=1};}END{print sum}' $1
