#!/bin/bash

# Usage: ./runMD.sh

# Redirect stdout and stderr to log
exec > >(tee runMD.log) 2>&1

# Define basenames
prmtop='prmtop'
inp='rst'
out='trajectory'
res='residues'

echo topology=$prmtop
echo input coordinates=$inp
echo output trajectory=$out
echo residues=$res

echo -e "\n##################################################";echo "Running $out"; echo -e "##################################################\n"

# RUN MD
time pmemd.cuda -O -i md.in -o $out.out -p $prmtop.prmtop -c $inp.rst -r $out.rst -x $out.nc -inf $out.mdinfo

# Process trajectory
strip-traj.sh -p $prmtop.prmtop -t $out.nc
strip-prmtop.sh -p $prmtop.prmtop
analyze-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc -r $res
reduce-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc

send-email.py "Terminó la corrida $out en MicroMol"

echo -e "\n##################################################";echo "MD $out finished"; echo -e "##################################################\n"

# Define names
inp=$out
out='trajectory'

echo input coordinates=$out
echo output trajectory=$out

echo -e "\n##################################################";echo "Running $out"; echo -e "##################################################\n"

# RUN MD
time pmemd.cuda -O -i md.in -o $out.out -p $prmtop.prmtop -c $inp.rst -r $out.rst -x $out.nc -inf $out.mdinfo

# Process trajectory
strip-traj.sh -p $prmtop.prmtop -t $out.nc
strip-prmtop.sh -p $prmtop.prmtop
analyze-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc -r $res
reduce-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc

send-email.py "Terminó la corrida $out en MicroMol"

echo -e "\n##################################################";echo "MD $out finished"; echo -e "##################################################\n"
