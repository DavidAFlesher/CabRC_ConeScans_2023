#!/bin/csh
#
#setup ccp4
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
####

grep CMB PDBs/${chn}${m}_moved.pdb | sed 's/CMB ... ...../CA  ALA A1001/' >! PDBs/${chn}${m}_moved_ref1.pdb
grep C2B PDBs/${chn}${m}_moved.pdb | sed 's/C2B ... ...../CA  ALA A1002/' >> PDBs/${chn}${m}_moved_ref1.pdb
grep C1B PDBs/${chn}${m}_moved.pdb | sed 's/C1B ... ...../CA  ALA A1003/' >> PDBs/${chn}${m}_moved_ref1.pdb
grep C3B PDBs/${chn}${m}_moved.pdb | sed 's/C3B ... ...../CA  ALA A1004/' >> PDBs/${chn}${m}_moved_ref1.pdb

grep CAB PDBs/${chn}${m}_moved.pdb | sed 's/CAB ... ...../CA  ALA A1001/' >! PDBs/${chn}${m}_moved_ref2.pdb
grep C3B PDBs/${chn}${m}_moved.pdb | sed 's/C3B ... ...../CA  ALA A1002/' >> PDBs/${chn}${m}_moved_ref2.pdb
grep C2B PDBs/${chn}${m}_moved.pdb | sed 's/C2B ... ...../CA  ALA A1003/' >> PDBs/${chn}${m}_moved_ref2.pdb
grep C4B PDBs/${chn}${m}_moved.pdb | sed 's/C4B ... ...../CA  ALA A1004/' >> PDBs/${chn}${m}_moved_ref2.pdb

grep CMC PDBs/${chn}${m}_moved.pdb | sed 's/CMC ... ...../CA  ALA A1001/' >! PDBs/${chn}${m}_moved_ref3.pdb
grep C2C PDBs/${chn}${m}_moved.pdb | sed 's/C2C ... ...../CA  ALA A1002/' >> PDBs/${chn}${m}_moved_ref3.pdb
grep C1C PDBs/${chn}${m}_moved.pdb | sed 's/C1C ... ...../CA  ALA A1003/' >> PDBs/${chn}${m}_moved_ref3.pdb
grep C3C PDBs/${chn}${m}_moved.pdb | sed 's/C3C ... ...../CA  ALA A1004/' >> PDBs/${chn}${m}_moved_ref3.pdb

grep CAC PDBs/${chn}${m}_moved.pdb | sed 's/CAC ... ...../CA  ALA A1001/' >! PDBs/${chn}${m}_moved_ref4.pdb
grep C3C PDBs/${chn}${m}_moved.pdb | sed 's/C3C ... ...../CA  ALA A1002/' >> PDBs/${chn}${m}_moved_ref4.pdb
grep C2C PDBs/${chn}${m}_moved.pdb | sed 's/C2C ... ...../CA  ALA A1003/' >> PDBs/${chn}${m}_moved_ref4.pdb
grep C4C PDBs/${chn}${m}_moved.pdb | sed 's/C4C ... ...../CA  ALA A1004/' >> PDBs/${chn}${m}_moved_ref4.pdb


#foreach ID (1 2)
foreach ID (1)
#lsqkab xyzinf PDBs/${chn}${m}_moved_ref${ID}.pdb xyzinm Cone_standardZ_sp2.pdb xyzout PDBs/Cone_${chn}${m}_ref${ID}.pdb << eof
lsqkab xyzinf PDBs/${chn}${m}_moved_ref${ID}.pdb xyzinm Cone_standardZ_sp3.pdb xyzout PDBs/Cone_${chn}${m}_ref${ID}.pdb << eof
output xyz
fit   resid CA 1001 to 1004 chain A
match resid CA 1001 to 1004 chain A
eof
grep A1001 PDBs/Cone_${chn}${m}_ref${ID}.pdb >! PDBs/Cone_${chn}${m}_ref${ID}_axis.pdb
awk '{if($6>=300&&$6<=373) print $0}' PDBs/Cone_${chn}${m}_ref${ID}.pdb >> PDBs/Cone_${chn}${m}_ref${ID}_axis.pdb
end

#foreach ID (3 4)
#lsqkab xyzinf PDBs/${chn}${m}_moved_ref${ID}.pdb xyzinm Cone_standardZ_sp3.pdb xyzout PDBs/Cone_${chn}${m}_ref${ID}.pdb << eof
#foreach ID (3)
#lsqkab xyzinf PDBs/${chn}${m}_moved_ref${ID}.pdb xyzinm Cone_standardZ_sp2.pdb xyzout PDBs/Cone_${chn}${m}_ref${ID}.pdb << eof
#output xyz
#fit   resid CA 1001 to 1004 chain A
#match resid CA 1001 to 1004 chain A
#eof
#grep A1001 PDBs/Cone_${chn}${m}_ref${ID}.pdb >! PDBs/Cone_${chn}${m}_ref${ID}_axis.pdb
#awk '{if($6>=300&&$6<=373) print $0}' PDBs/Cone_${chn}${m}_ref${ID}.pdb >> PDBs/Cone_${chn}${m}_ref${ID}_axis.pdb
#end

###
cat << eof >! awk.it
{x[NR]=0.0+substr(\$0,31,8); y[NR]=0.0+substr(\$0,39,8); z[NR]=0.0+substr(\$0,47,8)}
END{x0=x[1]; y0=y[1]; z0=z[1]; for(i=2; i<=73; i+=1) {x1=x[i]; y1=y[i]; z1=z[i]; 
printf("source CalculateED_lineB2.com %8.3f%8.3f%8.3f%8.3f%8.3f%8.3f 0.0 MapsMtzs/7vzr_${chn}${m}_moved_E PlotDensityZ/${chn}${m}_cone1_%-2d\n",x0,y0,z0,x1,y1,z1,i-1)}}
eof
awk -f awk.it  PDBs/Cone_${chn}${m}_ref1_axis.pdb >! Part1.com
cat << eof >! awk.it
{x[NR]=0.0+substr(\$0,31,8); y[NR]=0.0+substr(\$0,39,8); z[NR]=0.0+substr(\$0,47,8)}
END{x0=x[1]; y0=y[1]; z0=z[1]; for(i=2; i<=73; i+=1) {x1=x[i]; y1=y[i]; z1=z[i];
printf("source CalculateED_lineB2.com %8.3f%8.3f%8.3f%8.3f%8.3f%8.3f 0.0 MapsMtzs/7vzr_${chn}${m}_moved_E PlotDensityZ/${chn}${m}_cone2_%-2d\n",x0,y0,z0,x1,y1,z1,i-1)}}
eof
awk -f awk.it  PDBs/Cone_${chn}${m}_ref2_axis.pdb >! Part2.com
cat << eof >! awk.it
{x[NR]=0.0+substr(\$0,31,8); y[NR]=0.0+substr(\$0,39,8); z[NR]=0.0+substr(\$0,47,8)}
END{x0=x[1]; y0=y[1]; z0=z[1]; for(i=2; i<=73; i+=1) {x1=x[i]; y1=y[i]; z1=z[i];
printf("source CalculateED_lineB2.com %8.3f%8.3f%8.3f%8.3f%8.3f%8.3f 0.0 MapsMtzs/7vzr_${chn}${m}_moved_E PlotDensityZ/${chn}${m}_cone3_%-2d\n",x0,y0,z0,x1,y1,z1,i-1)}}
eof
awk -f awk.it  PDBs/Cone_${chn}${m}_ref3_axis.pdb >! Part3.com
cat << eof >! awk.it
{x[NR]=0.0+substr(\$0,31,8); y[NR]=0.0+substr(\$0,39,8); z[NR]=0.0+substr(\$0,47,8)}
END{x0=x[1]; y0=y[1]; z0=z[1]; for(i=2; i<=73; i+=1) {x1=x[i]; y1=y[i]; z1=z[i];
printf("source CalculateED_lineB2.com %8.3f%8.3f%8.3f%8.3f%8.3f%8.3f 0.0 MapsMtzs/7vzr_${chn}${m}_moved_E PlotDensityZ/${chn}${m}_cone4_%-2d\n",x0,y0,z0,x1,y1,z1,i-1)}}
eof
awk -f awk.it  PDBs/Cone_${chn}${m}_ref4_axis.pdb >! Part4.com

source Part1.com
#source Part2.com
#source Part3.com
#source Part4.com
###
@ n += 1
if( $n <= 28) goto BEGINNING

