#!/usr/bin/env bash

# Usage: ./strip-traj.sh -p {prmtop} -t {trajectory}

while getopts :p:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        t) nc=$(basename ${OPTARG} .nc);;
    esac
done

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

cpptraj -i strip-traj.in
