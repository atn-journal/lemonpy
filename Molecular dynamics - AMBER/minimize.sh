#!/usr/bin/env bash

# Usage: ./minimize.sh -p {prmtop} -r {residues}

# Get topology and number of residues
while getopts :p:r: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        r) res=${OPTARG};;
    esac
done

# Create minimization input files
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

# Redirect stdout and stderr to log
exec > >(tee minimize.log) 2>&1

echo topology=$prmtop
echo residues=$res

# Run minimization
pmemd.cuda -O -i min1.in -o ${prmtop}_min1.out -p ${prmtop}.prmtop -c ${prmtop}.inpcrd -r ${prmtop}_min1.rst -ref ${prmtop}.inpcrd -inf ${prmtop}_min1.mdinfo
pmemd.cuda -O -i min2.in -o ${prmtop}_min2.out -p ${prmtop}.prmtop -c ${prmtop}_min1.rst -r ${prmtop}_min2.rst -ref ${prmtop}.inpcrd -inf ${prmtop}_min2.mdinfo
pmemd.cuda -O -i min3.in -o ${prmtop}_min3.out -p ${prmtop}.prmtop -c ${prmtop}_min2.rst -r ${prmtop}_min3.rst -ref ${prmtop}.inpcrd -inf ${prmtop}_min3.mdinfo

echo -e "\n##################################################";echo "Minimization took ${SECONDS} s"; echo -e "##################################################\n"

#Display results in VMD
vmd ${prmtop}.prmtop -netcdf ${prmtop}_min1.rst -netcdf ${prmtop}_min2.rst -netcdf ${prmtop}_min3.rst
