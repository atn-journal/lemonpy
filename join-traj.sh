#!/usr/bin/env bash

# Usage: ./join-traj.sh -p {basename_of_prmtop} -t {basename_of_first_trajectory} -j {basename_of_trajectory_to_add}

while getopts :p:t:j: flag
do
    case "${flag}" in
        p) prmtop=${OPTARG}
cat << EOF > join.in
parm ${prmtop}.prmtop
EOF
;;
        t) nc1=${OPTARG}
cat << EOF >> join.in
trajin ${nc1}.nc
EOF
;;
        j) nc2=${OPTARG}
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
