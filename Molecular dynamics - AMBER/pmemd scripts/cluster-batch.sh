#!/bin/bash

ID='d6'
dependency=5714561
ns_in=2700

ns_out=$(($ns_in+100))
file="$ID-${ns_in}ns"
output="$ID-${ns_out}ns"

sed -r "s/#SBATCH --job-name=.*/#SBATCH --job-name=$output/" $file.slurm > $output.slurm
sed -r -i "s/#*SBATCH --dependency=afterok:.*/#SBATCH --dependency=afterok:$dependency/" $output.slurm
sed -r -i "s/^ns_in=$(($ns_in-100))/ns_in=$ns_in/" $output.slurm

dependency=$(sbatch $output.slurm | awk '{print $4}')

#######################################################################################################################

ns_in=$ns_out
ns_out=$(($ns_in+100))
file="$ID-${ns_in}ns"
output="$ID-${ns_out}ns"

sed -r "s/#SBATCH --job-name=.*/#SBATCH --job-name=$output/" $file.slurm > $output.slurm
sed -r -i "s/#*SBATCH --dependency=afterok:.*/#SBATCH --dependency=afterok:$dependency/" $output.slurm
sed -r -i "s/^ns_in=$(($ns_in-100))/ns_in=$ns_in/g" $output.slurm

dependency=$(sbatch $output.slurm | awk '{print $4}')
