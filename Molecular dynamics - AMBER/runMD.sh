#!/bin/bash

# Usage: ./runMD.sh

# Redirect stdout and stderr to log
exec > >(tee runMD.log) 2>&1

# Define basenames
prmtop='prmtop'
echo topology=$prmtop
inp='rst'
echo input coordinates=$inp
out='trajectory'
echo output trajectory=$out
res='residues'
echo residues=$res

# RUN MD
time pmemd.cuda -O -i md.in -o $out.out -p $prmtop.prmtop -c $inp.rst -r $out.rst -x $out.nc -inf $out.mdinfo

# Process trajectory
strip-traj.sh -p $prmtop.prmtop -t $out.nc
strip-prmtop.sh -p $prmtop.prmtop
analyze-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc -r $res
reduce-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc

send-email.py "Terminó la corrida $out en MicroMol"


# Define names
inp=$out
echo input coordinates=$out
out='trajectory'
echo output trajectory=$out

# RUN MD
time pmemd.cuda -O -i md.in -o $out.out -p $prmtop.prmtop -c $inp.rst -r $out.rst -x $out.nc -inf $out.mdinfo

# Process trajectory
strip-traj.sh -p $prmtop.prmtop -t $out.nc
strip-prmtop.sh -p $prmtop.prmtop
analyze-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc -r $res
reduce-traj.sh -p ${prmtop}_dry.prmtop -t ${out}_dry.nc

send-email.py "Terminó la corrida $out en MicroMol"
