#!/usr/bin/env bash

echo Número de residuos de la proteína:
read res

cat << EOF > min1.in
Minimizing the system 
with 25 kcal/mol restraints 
on PROTEIN, 500 steps of steepest
descent and 2000 of 
conjugated gradient
 &cntrl
 imin=1,
 ntx=1,
 irest=0,
 ntpr=50, 
 ntf=1, 
 ntb=1,
 cut=9.0,
 nsnb=10,
 ntr=1, 
 maxcyc=2500,
 ncyc=2000,
 ntmin=1,
 restraintmask=':1-${res}',
 restraint_wt=25.0,
 &end
 &ewald
   ew_type = 0, skinnb = 1.0,
 &end

EOF

cat << EOF > min2.in
Minimizing the system 
with 15 kcal/mol restraints 
on PROTEIN, 500 steps of steepest
descent and 2000 of 
conjugated gradient
 &cntrl
 imin=1,
 ntx=1,
 irest=0,
 ntpr=50, 
 ntf=1, 
 ntb=1,
 cut=9.0,
 nsnb=10,
 ntr=1, 
 maxcyc=2500,
 ncyc=2000,
 ntmin=1,
 restraintmask=':1-${res}',
 restraint_wt=15.0,
 &end
 &ewald
   ew_type = 0, skinnb = 1.0,
 &end

EOF

cat << EOF > min3.in
Minimizing the system 
with 5 kcal/mol restraints 
on PROTEIN, 500 steps of steepest
descent and 2000 of 
conjugated gradient
 &cntrl
 imin=1,
 ntx=1,
 irest=0,
 ntpr=50, 
 ntf=1, 
 ntb=1,
 cut=9.0,
 nsnb=10,
 ntr=1, 
 maxcyc=2500,
 ncyc=2000,
 ntmin=1,
 restraintmask=':1-${res}',
 restraint_wt=5.0,
 &end
 &ewald
   ew_type = 0, skinnb = 1.0,
 &end

EOF

echo Nombre del .prmtop:
read prmtop

# cat << EOF > rst2pdb.in
# parm ${prmtop}.prmtop
# trajin ${prmtop}_min.rst
# trajout ${prmtop}_min.pdb pdb
# go
# 
# EOF

pmemd -O -i min1.in -o min1.out -p ${prmtop}.prmtop -c ${prmtop}.inpcrd -r min1.rst -ref ${prmtop}.inpcrd
pmemd -O -i min2.in -o min2.out -p ${prmtop}.prmtop -c min1.rst -r min2.rst -ref ${prmtop}.inpcrd
pmemd -O -i min3.in -o min3.out -p ${prmtop}.prmtop -c min2.rst -r ${prmtop}_min.rst -ref ${prmtop}.inpcrd

echo La minimización demoró $(($SECONDS/60)) minutos.

vmd ${prmtop}_min.pdb -netcdf min1.rst -netcdf min2.rst -netcdf ${prmtop}_min.rst
