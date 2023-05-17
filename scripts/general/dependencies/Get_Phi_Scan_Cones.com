#!/bin/csh
## C=O bond length = 1.23 C-H 1.00, C-C vinyl = 1.44, C-C ethyl = 1.57
@ m = 1
BEGINNING:
cat << eof >! awk.it
{if(NR==$m) {no=0+substr(\$0,23,4); print no}}
eof
set ID = `awk -f awk.it 7vzr_only-Mg-Zn.pdb | awk '{print $1}'`
cat << eof >! awk.it
{if(NR==$m) {chn=substr(\$0,22,1); print chn}}
eof
set chn = `awk -f awk.it 7vzr_only-Mg-Zn.pdb | awk '{print $1}'`
echo ${chn} ${ID}

@ n = 1
#cp /dev/null PhiScanCone1/${chn}${ID}_Cone1_phi_scan.dat
cp /dev/null PhiScanCone2/${chn}${ID}_Cone2_phi_scan.dat
#cp /dev/null PhiScanCone3/${chn}${ID}_Cone3_phi_scan.dat
#cp /dev/null PhiScanCone4/${chn}${ID}_Cone4_phi_scan.dat
beginning: 
#set result1 = `grep "^  1.230" PlotDensity/${chn}${ID}_cone1_$n.ED | awk '{print $2}'`
set result2 = `grep "^  1.230" PlotDensity/${chn}${ID}_cone2_$n.ED | awk '{print $2}'`
#set result3 = `grep "^  1.000" PlotDensity/${chn}${ID}_cone3_$n.ED | awk '{print $2}'`
#set result4 = `grep "^  1.570" PlotDensity/${chn}${ID}_cone4_$n.ED | awk '{print $2}'`
#echo $n $result1 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone1/${chn}${ID}_Cone1_phi_scan.dat
echo $n $result2 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone2/${chn}${ID}_Cone2_phi_scan.dat
#echo $n $result3 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone3/${chn}${ID}_Cone3_phi_scan.dat
#echo $n $result4 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone4/${chn}${ID}_Cone4_phi_scan.dat
@ n += 1 
if ($n <= 72) goto beginning
#sort -n -k1 PhiScanCone1/${chn}${ID}_Cone1_phi_scan.dat >! PhiScanCone1/${chn}${ID}_Cone1_phi_scan.dat2
sort -n -k1 PhiScanCone2/${chn}${ID}_Cone2_phi_scan.dat >! PhiScanCone2/${chn}${ID}_Cone2_phi_scan.dat2
#sort -n -k1 PhiScanCone3/${chn}${ID}_Cone3_phi_scan.dat >! PhiScanCone3/${chn}${ID}_Cone3_phi_scan.dat2
#sort -n -k1 PhiScanCone4/${chn}${ID}_Cone4_phi_scan.dat >! PhiScanCone4/${chn}${ID}_Cone4_phi_scan.dat2

@ m += 1
if ($m <= 28) goto BEGINNING
exit
