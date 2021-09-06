#!/usr/bin/env bash

# Usage: ./strip-prmtop.sh -p {prmtop}

while getopts :p: flag
do
    case "${flag}" in
        p) prmtop=$(basename ${OPTARG} .prmtop);;
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
