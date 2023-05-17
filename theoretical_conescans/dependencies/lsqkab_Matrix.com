#!/bin/csh
#setup uppsala
#setup ccp4
#setup rave
setenv MAPSIZE 80000000


@ n = 1
BEGINNING:
cat << eof >! awk.it
{if(NR==$n) {no=0+substr(\$0,23,4); print no}}
eof
set m = `awk -f awk.it cla910_chain_A_optM1_symm_fixed.pdb | awk '{print $1}'`
cat << eof >! awk.it
{if(NR==$n) {chn=substr(\$0,22,1); print chn}}
eof
set chn = `awk -f awk.it cla910_chain_A_optM1_symm_fixed.pdb | awk '{print $1}'`

#goto next
cat << eof >! lsqkab.inp
fit   residue all 1 to 1 
match residue     $m to $m chain ${chn}
eof

lsqkab xyzinf cla910_chain_A_optM1_symm_fixed.pdb xyzinm CHLA_bent_center_core.pdb >! LogMatrix/lsqkab_${chn}${m}.log < lsqkab.inp
echo ".LSQ_RT_A2B               R         12 (3f17.7)" >! LogMatrix/lsqkab_${chn}${m}.matrix
grep -A3 "      ROTATION MATRIX:" LogMatrix/lsqkab_${chn}${m}.log | grep -v "      ROTATION MATRIX:" |awk '{printf("%17.7f%17.7f%17.7f\n",$1,$2,$3)}' >> LogMatrix/lsqkab_${chn}${m}.matrix
grep "  TRANSLATION VECTOR IN AS" LogMatrix/lsqkab_${chn}${m}.log | awk '{printf("%17.7f%17.7f%17.7f\n",$5,$6,$7)}' >> LogMatrix/lsqkab_${chn}${m}.matrix
awk -f awk_transposition LogMatrix/lsqkab_${chn}${m}.matrix >! LogMatrix/lsqkab_${chn}${m}.matrix_TR

echo ${chn} ${m}

@ n += 1
if( $n <= 1) goto BEGINNING
exit
