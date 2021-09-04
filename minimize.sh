#!/usr/bin/env bash

# Agregar que escriba los min.in y el rst2pdb. Agregar tiempo

pmemd -O -i min1.in -o min1.out -p $1.prmtop -c $1.inpcrd -r min1.rst -ref $1.inpcrd
pmemd -O -i min2.in -o min2.out -p $1.prmtop -c min1.rst -r min2.rst -ref $1.inpcrd
pmemd -O -i min3.in -o min3.out -p $1.prmtop -c min2.rst -r $1_min.rst -ref $1.inpcrd
sed -i -e "s/ .*\.rst/ $1_min.rst/g" -e "s/ .*\.pdb/ $1_min.pdb/g" rst2pdb
cpptraj -p $1.prmtop < rst2pdb
