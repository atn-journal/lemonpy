#!/usr/bin/env bash

# Usage: ./join-traj.sh -p {prmtop} -t {first_trajectory} -j {trajectory_to_add}

# Get topology and trajectories to join
while getopts :p:t:j: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop)
cat << EOF > join.in
parm ${prmtop}.prmtop
EOF
;;
        t) nc1=$(basename ${OPTARG} .nc)
cat << EOF >> join.in
trajin ${nc1}.nc
EOF
;;
        j) nc2=$(basename ${OPTARG} .nc)
cat << EOF >> join.in
trajin ${nc2}.nc
EOF
;;
    esac
done

# Write out script to join trajectories
cat << EOF >> join.in
trajout ${nc2}_join.nc netcdf
go
    
EOF

# Redirect stdout and stderr to log
exec > >(tee join.log) 2>&1

echo topology=$prmtop
echo first trajectory=$nc1
echo second trajectory=$nc2

# Join trajectories
cpptraj -i join.in
