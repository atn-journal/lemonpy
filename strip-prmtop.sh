#!/usr/bin/env bash

# Usage: ./strip-prmtop.sh -p {basename of prmtop}

while getopts :p: flag
do
    case "${flag}" in
        p) prmtop=${OPTARG};;
    esac
done

cat << EOF > dry.in
parm ${prmtop}.prmtop
parmstrip :Na+
parmstrip :Cl-
parmstrip :WAT
parmwrite out ${prmtop}_dry.prmtop
go

EOF

cpptraj -i dry.in
