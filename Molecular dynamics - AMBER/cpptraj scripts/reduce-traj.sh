#!/usr/bin/env bash

# Usage: ./reduce-traj.sh -t {trajectory}

# Get topology and trajectory
while getopts :t: flag
do
    case "${flag}" in
        t) nc=$(basename ${OPTARG} .nc);;
    esac
done

prmtop=${nc%_*}

# Write out script to delete 90 % of frames from trajectory
cat << EOF > reduce.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last 10
trajout ${nc}_small.nc netcdf
go
EOF

# Redirect stdout and stderr to log
exec > >(tee reduce-traj.log) 2>&1

echo topology=$prmtop
echo trajectory=$nc

# Reduce trajectory
cpptraj -i reduce.in
