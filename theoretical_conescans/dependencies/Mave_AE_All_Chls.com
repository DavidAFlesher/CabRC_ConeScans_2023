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
set m   = `awk -f awk.it cla910_chain_A_optM1_symm_fixed.pdb | awk '{print $1}'`
cat << eof >! awk.it
{if(NR==$n) {chn=substr(\$0,22,1); print chn}}
eof
set chn = `awk -f awk.it cla910_chain_A_optM1_symm_fixed.pdb | awk '{print $1}'`

###
mave << eof
A
cla910_chainA_ESP_at_2p22A.map
cla_core.mask
LogMatrix/lsqkab_${chn}${m}.matrix_TR
p1.sym
lsq_rt_a2a.o

CHLA_bent_center_FC.map
MapsMtzs/map_${chn}${m}_moved_A.map
eof
###
ave << eof
E
CHLA_bent_center_FC.map
cla_core.mask
MapsMtzs/map_${chn}${m}_moved_A.map
MapsMtzs/map_${chn}${m}_moved_E.map
p1.sym
lsq_rt_a2a.o

echo ${chn} ${m}

eof
####
@ n += 1
if( $n <= 1) goto BEGINNING

