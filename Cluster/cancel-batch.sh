#!/bin/bash

# Cancel slurm jobs by name

myqueue | grep $1 | awk '{print $1}' | xargs scancel