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
cp /dev/null PhiScanCone1Z/${chn}${ID}_Cone1Z_phi_scan.dat
#cp /dev/null PhiScanCone2Z/${chn}${ID}_Cone2Z_phi_scan.dat
#cp /dev/null PhiScanCone3Z/${chn}${ID}_Cone3Z_phi_scan.dat
#cp /dev/null PhiScanCone4Z/${chn}${ID}_Cone4Z_phi_scan.dat
beginning: 
set result1 = `grep "^  1.000" PlotDensityZ/${chn}${ID}_cone1_$n.ED | awk '{print $2}'`
#set result2 = `grep "^  1.440" PlotDensityZ/${chn}${ID}_cone2_$n.ED | awk '{print $2}'`
#set result3 = `grep "^  1.230" PlotDensityZ/${chn}${ID}_cone3_$n.ED | awk '{print $2}'`
#set result4 = `grep "^  1.570" PlotDensityZ/${chn}${ID}_cone4_$n.ED | awk '{print $2}'`
echo $n $result1 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone1Z/${chn}${ID}_Cone1Z_phi_scan.dat
#echo $n $result2 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone2Z/${chn}${ID}_Cone2Z_phi_scan.dat
#echo $n $result3 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone3Z/${chn}${ID}_Cone3Z_phi_scan.dat
#echo $n $result4 | awk '{N = ($1+54)%72*5; print N, $2}' >> PhiScanCone4Z/${chn}${ID}_Cone4Z_phi_scan.dat
@ n += 1 
if ($n <= 72) goto beginning
sort -n -k1 PhiScanCone1Z/${chn}${ID}_Cone1Z_phi_scan.dat >! PhiScanCone1Z/${chn}${ID}_Cone1Z_phi_scan.dat2
#sort -n -k1 PhiScanCone2Z/${chn}${ID}_Cone2Z_phi_scan.dat >! PhiScanCone2Z/${chn}${ID}_Cone2Z_phi_scan.dat2
#sort -n -k1 PhiScanCone3Z/${chn}${ID}_Cone3Z_phi_scan.dat >! PhiScanCone3Z/${chn}${ID}_Cone3Z_phi_scan.dat2
#sort -n -k1 PhiScanCone4Z/${chn}${ID}_Cone4Z_phi_scan.dat >! PhiScanCone4Z/${chn}${ID}_Cone4Z_phi_scan.dat2

@ m += 1
if ($m <= 28) goto BEGINNING
exit
