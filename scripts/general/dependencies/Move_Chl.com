#!/bin/csh
#
#setup ccp4
###
@ n = 1
BEGINNING:
cat << eof >! awk.it
{if(NR==$n) {no=0+substr(\$0,23,4); print no}}
eof
set m = `awk -f awk.it model_chls.pdb | awk '{print $1}'`
cat << eof >! awk.it
{if(NR==$n) {chn=substr(\$0,22,1); print chn}}
eof
set chn = `awk -f awk.it model_chls.pdb | awk '{print $1}'`
echo ${chn} ${m}
####
#echo test
echo ${chn} ${m} | awk '{printf("%1s%4d\n",$1,$2)}' >! egrep.exp
grep -f egrep.exp complete_model.pdb >! tmp.pdb
lsqkab xyzinf CHLA_bent_center_core.pdb xyzinm tmp.pdb xyzout PDBs/${chn}${m}_moved.pdb >! lsqkab_CHLA.log << eof
output xyz 
fit   residue all ${m} to ${m}  chain ${chn}
match residue     1 to 1 
eof

###
@ n += 1
if( $n <= 1) goto BEGINNING

