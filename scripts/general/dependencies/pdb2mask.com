#!/bin/csh

#$ -cwd -o maskless.out -e maskless.err

#! cavity-filled mask

setup sbgrid

#setenv MASKSIZE 70000000

setenv NUMMASKS 1

foreach model ( bcl905_chain_A_optM1_symm_fixed_moved )

#setup rave

#setup ccp4

set qqq = pdbmask.tmp

/bin/rm $qqq

echo new cell  25.000  25.000   25.000  90.00  90.00  90.00  >! $qqq

echo new grid  80  80  80               >> $qqq

echo new radius    3                  >> $qqq

echo new pdb pdbmask $model.pdb         >> $qqq

echo list pdbmask                       >> $qqq

echo expand pdbmask                     >> $qqq

#echo expand pdbmask                     >> $qqq

#echo expand pdbmask                     >> $qqq

echo fill pdbmask                       >> $qqq

echo contract pdbmask                   >> $qqq

#echo contract pdbmask                   >> $qqq

#echo contract pdbmask                   >> $qqq

echo island pdbmask                     >> $qqq

echo list pdbmask                       >> $qqq

echo write pdbmask      $model.mask     >> $qqq

echo quit                               >> $qqq

mama -b < $qqq

/bin/rm $qqq

mama2ccp4 maskin $model.mask maskout $model.ccp4mask 

end
