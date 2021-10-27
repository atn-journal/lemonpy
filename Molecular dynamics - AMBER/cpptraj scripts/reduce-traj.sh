#!/usr/bin/env bash

# Usage: ./reduce-traj.sh -p {prmtop} -t {trajectory} -s {skip}

# Get topology and trajectory
while getopts :p:t:s: flag
do
    case "${flag}" in
        t) nc=$(basename ${OPTARG} .nc);;
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        s) skip=${OPTARG};;
    esac
done

# Write out script
cat << EOF > REDUCE-TRAJ.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last $skip
trajout ${nc}_offset${skip}.nc netcdf
go
EOF

# Redirect stdout and stderr to log
exec > >(tee reduce-traj.log) 2>&1

echo topology=$prmtop
echo trajectory=$nc

# Reduce trajectory
cpptraj -i REDUCE-TRAJ.in
