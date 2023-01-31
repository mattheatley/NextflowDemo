#!/bin/bash
#SBATCH --job-name=NFslamseq
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=1G
#SBATCH --time=01:00:00
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err


# SETTINGS

CONDA_ENV='nf-core_v2.6_env'
WORKFLOW='./clone/main.nf'
MODE='test'

UON_PROFILE="augusta"
UON_CONFIG="./AugustaWorkflow.config"



# LOAD

# activate user environment
source $HOME/.bash_profile

# activate nextflow environment
conda activate $CONDA_ENV

# load singularity
module load singularity/3.4.2



# PREP

# remove singularity cache directory layers; ~/.singularity/cache
singularity cache clean -f

# remove nextflow singularity cache images; cacheDir
# rm -r ./singularity

# alter permissions for newly created files (default: umask 0027)
umask 0022



# RUN

# update profile for testing
if [ $MODE == 'test' ]
then
    echo "*** TEST MODE ***"
    UON_PROFILE="$MODE,$UON_PROFILE"
fi

# run nextflow
RUN_CMD="nextflow run $WORKFLOW -c $UON_CONFIG -profile $UON_PROFILE"

echo "Active Environment (Conda): $CONDA_DEFAULT_ENV"
echo $RUN_CMD
eval $RUN_CMD


