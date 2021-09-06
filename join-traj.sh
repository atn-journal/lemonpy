#!/usr/bin/env bash

# Usage: ./join-traj.sh -p {basename of prmtop} -t {basename of first trajectory} -j {basename of trajectory to add}

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
