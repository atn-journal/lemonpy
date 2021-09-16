#!/usr/bin/env bash

# Usage: ./join-traj.sh -p {prmtop} -t {first_trajectory} -j {trajectory_to_add}

# Redirect stdout and stderr to log
exec > >(tee join.log) 2>&1

# Get topology and trajectories to join
while getopts :p:t:j: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop)
cat << EOF > join.in
parm ${prmtop}.prmtop
EOF
echo topology=$prmtop
;;
        t) nc1=$(basename ${OPTARG} .nc)
cat << EOF >> join.in
trajin ${nc1}.nc
EOF
echo first trajectory=$nc1
;;
        j) nc2=$(basename ${OPTARG} .nc)
cat << EOF >> join.in
trajin ${nc2}.nc
EOF
echo add trajectory=$nc2
;;
    esac
done

# Write out script to join trajectories
cat << EOF >> join.in
trajout ${nc2}_join.nc netcdf
go

EOF

# Join trajectories
cpptraj -i join.in
