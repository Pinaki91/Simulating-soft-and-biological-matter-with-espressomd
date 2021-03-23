#!/bin/bash
#SBATCH --account=def-stephweb
#SBATCH --time=160:00:00
#SBATCH --job-name=FUS
#SBATCH --output=%x-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem=32G
date
mpirun -np 4 /home/pinaki/espresso-3.3.1/./Espresso /home/pinaki/codes/FUS/data/wildtype/temp1/fuslcd_wt.tcl
date
