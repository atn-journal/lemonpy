#!/usr/bin/env bash

# Usage: ./strip-traj.sh -p {basename of prmtop} -t {basename of trajectory}

while getopts :p:t: flag
do
    case "${flag}" in
        p) prmtop=${OPTARG};;
        t) nc1=${OPTARG};;
    esac
done

cat << EOF > trajio.in
parm ${prmtop}.prmtop
trajin ${nc1}.nc 1 last 10
autoimage
strip :Na+
strip :Cl-
strip :WAT
trajout ${nc1}_dry.nc netcdf
go
    
EOF

cpptraj -i trajio.in
