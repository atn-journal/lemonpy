#!/usr/bin/env bash

# Usage: ./strip-traj.sh -p {prmtop} -t {trajectory}

while getopts :p:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        t) nc1=$(basename ${OPTARG} .nc);;
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
