#!/usr/bin/env bash

# Usage: ./join-traj.sh -p {prmtop} -t {first_trajectory} -j {trajectory_to_add}

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

cat << EOF >> join.in
trajout ${nc2}_join.nc netcdf
go
    
EOF

cpptraj -i join.in
