#!/usr/bin/env bash

# Usage: ./strip-traj.sh -p {prmtop} -t {trajectory}

# Get topology and trajectory
while getopts :p:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        t) nc=$(basename ${OPTARG} .nc);;
    esac
done

# Write out script to strip trajectory
cat << EOF > strip-traj.in
parm ${prmtop}.prmtop
trajin ${nc}.nc
autoimage
strip :Na+
strip :Cl-
strip :WAT
trajout ${nc}_dry.nc netcdf
go

EOF

# Redirect stdout and stderr to log
exec > >(tee strip-traj.log) 2>&1

echo topology=$prmtop
echo trajectory=$nc

# Strip trajectory
cpptraj -i strip-traj.in
