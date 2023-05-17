#!/bin/csh
#

#setup ccp4
#setup phenix prev


###
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
###

/bin/rm MapsMtzs/map_${chn}${m}_moved_E.mtz

# new stuff

mapmask mapin MapsMtzs/map_${chn}${m}_moved_E.map mapout MapsMtzs/map_${chn}${m}_moved_E_ZXY.map << eof
AXIS Z X Y
eof
sfall mapin MapsMtzs/map_${chn}${m}_moved_E_ZXY.map hklout MapsMtzs/map_${chn}${m}_moved_E.mtz << eof >! sfall.log
mode SFCALC MAPIN
symm p1
resolution 120 1.5
BADD 0.00
eof
rm MapsMtzs/map_${chn}${m}_moved_E_ZXY.map

###
cad hklin1 MapsMtzs/map_${chn}${m}_moved_E.mtz hklin2 MapsMtzs/map_${chn}${m}_moved_E.mtz hklout MapsMtzs/map_${chn}${m}_moved_E_FPSIGFPPHIB.mtz << eof
labin  file 1 E1=FC       E2=PHIC
labout file 1 E1=FP       E2=PHIB
ctype  file 1 E1=F        E2=P
labin  file 2 E1=FC
labout file 2 E1=SIGFP
ctype  file 2 E1=Q
scale file 2 0.05
scale file 1 1.00
symmetry P1
eof


mtz2various hklin MapsMtzs/map_${chn}${m}_moved_E.mtz hklout MapsMtzs/map_${chn}${m}_moved_E.list << eof
output user '(3I5,2F12.3)'
labin DUM1=FC DUM2=PHIC
monitor 500000
eof



echo ${chn} ${m}

####
@ n += 1
if( $n <= 1) goto BEGINNING

