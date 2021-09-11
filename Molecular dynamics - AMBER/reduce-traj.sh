#!/usr/bin/env bash

# Usage: ./reduce-traj.sh -p {prmtop} -t {trajectory}

while getopts :p:t: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
        t) nc=$(basename ${OPTARG} .nc);;
    esac
done

cat << EOF > reduce.in
parm ${prmtop}.prmtop
trajin ${nc}.nc 1 last 10
trajout ${nc}_small.nc netcdf
go

EOF

cpptraj -i reduce.in
