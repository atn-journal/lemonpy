#!/bin/bash

ID='d6'
dependency=5714561
ns_in=2700
ns_slurm=100

ns_out=$(($ns_in+$ns_slurm))
file="$ID-$(printf "%04d" $ns_in)ns"
output="$ID-$(printf "%04d" $ns_out)ns"

sed -r "s/#SBATCH --job-name=.*/#SBATCH --job-name=$output/" $file.slurm > $output.slurm
sed -r -i "s/#*SBATCH --dependency=afterok:.*/#SBATCH --dependency=afterok:$dependency/" $output.slurm
sed -r -i "s/^ns_in=$(($ns_in-$ns_slurm))/ns_in=$ns_in/" $output.slurm

dependency=$(sbatch $output.slurm | awk '{print $4}')

#######################################################################################################################

for((i=0;i<1;i++));
do
    ns_in=$ns_out
    ns_out=$(($ns_in+$ns_slurm))
    file="$ID-$(printf "%04d" $ns_in)ns"
    output="$ID-$(printf "%04d" $ns_out)ns"

    sed -r "s/#SBATCH --job-name=.*/#SBATCH --job-name=$output/" $file.slurm > $output.slurm
    sed -r -i "s/#*SBATCH --dependency=afterok:.*/#SBATCH --dependency=afterok:$dependency/" $output.slurm
    sed -r -i "s/^ns_in=$(($ns_in-$ns_slurm))/ns_in=$ns_in/g" $output.slurm

    dependency=$(sbatch $output.slurm | awk '{print $4}')
done
