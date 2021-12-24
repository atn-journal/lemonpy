#!/usr/bin/env bash

# Get topology and number of residues
prmtop=''
res=

# Create minimization input files
cat << EOF > min1.in
Minimizing the system with 25 kcal/mol restraints on PROTEIN,
2000 steps of steepest descent and 500 of conjugated gradient.
  &cntrl
    imin=1,ntmin=1,ncyc=2000,maxcyc=2500,
    ntr=1,restraintmask=':1-${res}',restraint_wt=25.0,
    cut=9.0,
    nsnb=10,
    ntpr=50,
  /

EOF

cat << EOF > min2.in
Minimizing the system with 25 kcal/mol restraints on PROTEIN,
2000 steps of steepest descent and 500 of conjugated gradient.
  &cntrl
    imin=1,ntmin=1,ncyc=2000,maxcyc=2500,
    ntr=1,restraintmask=':1-${res}',restraint_wt=15.0,
    cut=9.0,
    nsnb=10,
    ntpr=50,
  /

EOF

cat << EOF > min3.in
Minimizing the system with 25 kcal/mol restraints on PROTEIN,
2000 steps of steepest descent and 500 of conjugated gradient.
  &cntrl
    imin=1,ntmin=1,ncyc=2000,maxcyc=2500,
    ntr=1,restraintmask=':1-${res}',restraint_wt=5.0,
    cut=9.0,
    nsnb=10,
    ntpr=50,
  /

EOF

# Redirect stdout and stderr to log
exec 3>&1 4>&2 1> >(tee min.log) 2>&1

echo topology=$prmtop
echo residues=$res

# Run minimization
pmemd.cuda -O -i min1.in -o ${prmtop}_min1.out -p ${prmtop}.prmtop -c ${prmtop}.inpcrd -r ${prmtop}_min1.rst -ref ${prmtop}.inpcrd -inf ${prmtop}_min1.mdinfo
pmemd.cuda -O -i min2.in -o ${prmtop}_min2.out -p ${prmtop}.prmtop -c ${prmtop}_min1.rst -r ${prmtop}_min2.rst -ref ${prmtop}.inpcrd -inf ${prmtop}_min2.mdinfo
pmemd.cuda -O -i min3.in -o ${prmtop}_min3.out -p ${prmtop}.prmtop -c ${prmtop}_min2.rst -r ${prmtop}_min3.rst -ref ${prmtop}.inpcrd -inf ${prmtop}_min3.mdinfo

echo -e "\n##################################################"
echo "Minimization took ${SECONDS} s"
echo -e "##################################################\n"

# Stop redirection to log
exec 1>&3 2>&4
