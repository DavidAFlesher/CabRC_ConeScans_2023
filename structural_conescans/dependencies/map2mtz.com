#!/bin/csh
#

#setup ccp4
setup phenix prev

###
@ n = 1
BEGINNING:
cat << eof >! awk.it
{if(NR==$n) {no=0+substr(\$0,23,4); print no}}
eof
set m = `awk -f awk.it 7vzr_only-Mg-Zn.pdb | awk '{print $1}'`
cat << eof >! awk.it
{if(NR==$n) {chn=substr(\$0,22,1); print chn}}
eof
set chn = `awk -f awk.it 7vzr_only-Mg-Zn.pdb | awk '{print $1}'`
###

/bin/rm MapsMtzs/7vzr_${chn}${m}_moved_E.mtz
phenix.map_to_structure_factors MapsMtzs/7vzr_${chn}${m}_moved_E.map d_min=2.00 output_file_name=MapsMtzs/7vzr_${chn}${m}_moved_E.mtz
mtz2various hklin MapsMtzs/7vzr_${chn}${m}_moved_E.mtz hklout MapsMtzs/7vzr_${chn}${m}_moved_E.list << eof
output user '(3I5,2F12.3)'
labin DUM1=F DUM2=PHIF
monitor 500000
eof

echo ${chn} ${m}

####
@ n += 1
if( $n <= 28) goto BEGINNING

