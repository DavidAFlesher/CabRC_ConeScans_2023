#!/bin/csh
setup rave old
setup ccp4
setenv MAPSIZE  60000000
setenv MASKSIZE 60000000

###
@ n = 1
BEGINNING:
cat << eof >! awk.it
{if(NR==$n) {no=0+substr(\$0,23,4); print no}}
eof
set m   = `awk -f awk.it 7vzr_only-Mg-Zn.pdb | awk '{print $1}'`
cat << eof >! awk.it
{if(NR==$n) {chn=substr(\$0,22,1); print chn}}
eof
set chn = `awk -f awk.it 7vzr_only-Mg-Zn.pdb | awk '{print $1}'`

###
mave << eof
A
7vzr_EMD32229.map
CHLA_bent_center_core2.mask
LogMatrix/lsqkab_${chn}${m}.matrix_TR
p1.sym
lsq_rt_a2a.o

CHLA_bent_center_FC.map
MapsMtzs/7vzr_${chn}${m}_moved_A.map
eof
###
ave << eof
E
CHLA_bent_center_FC.map
CHLA_bent_center_core2.mask
MapsMtzs/7vzr_${chn}${m}_moved_A.map
MapsMtzs/7vzr_${chn}${m}_moved_E.map
p1.sym
lsq_rt_a2a.o

echo ${chn} ${m}

eof
####
@ n += 1
if( $n <= 28) goto BEGINNING

