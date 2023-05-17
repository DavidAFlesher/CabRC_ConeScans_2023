#!/bin/csh
cp awk_functions awk.it
#############
echo thinking...
cat << eof >> awk.it
BEGIN {cx[1]=25.0; cx[2]=25.0; cx[3]=25.0; cx[4]=90.00; cx[5]=90.00; cx[6]=90.00;
ccpvolr(cx,ac,v); ortho(cx,c2f,f2c); 
x1[1]=$1; x1[2]=$2; x1[3]=$3; x2[1]=$4; x2[2]=$5; x2[3]=$6; B=$7;
#for(i=1; i<=3; i++) {x0[i]=(x1[i]+x2[i])/2.0; dx[i]=x2[i]-x1[i]};
for(i=1; i<=3; i++) {x0[i]=x1[i]; dx[i]=x2[i]-x1[i]};
dist=dx[1]*dx[1]+dx[2]*dx[2]+dx[3]*dx[3];
for(i=1; i<=3; i++) {dx[i]=dx[i]/sqrt(dist)}; range = 5.0;
C=0.017453; twopi=6.28319;
}
eof
cat awk_main_lineB2 >> awk.it
awk -f awk.it $8.list      >! $9.ED
