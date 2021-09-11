#!/bin/bash

# Define names
top='basename_of_prmtop'
inp='basename_of_input_coord'
out='basename_of_output_trajectory'

# RUN MD
time pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc

# Process trajectory
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

send-email.py "Terminó la corrida ${out} en MicroMol"


# Define names
inp=$out
out='basename_of_output_trajectory'

# RUN MD
time pmemd.cuda -O -i md.in -o ${out}.out -p ${top}.prmtop -c ${inp}.rst -r ${out}.rst -x ${out}.nc

# Process trajectory
strip-traj.sh -p ${top}.prmtop -t ${out}.nc
analyze-traj.sh -p ${top}.prmtop -t ${out}_dry.nc
reduce-traj.sh -p ${top}.prmtop -t ${out}_dry.nc

send-email.py "Terminó la corrida ${out} en MicroMol"
