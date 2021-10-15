#! /bin/bash
#
#

CONTAINER="[vcid-asl-pipeline]"
echo -e "$CONTAINER  Initiated"

DATA_DIR=/opt/base/Nifti
MCR_ROOT=/usr/local/MATLAB/MATLAB_Runtime/v99/
CODE_DIR=/opt/base/vcid_asl_pipeline/for_redistribution_files_only

# Check for required inputs
if [[ -z "$DATA_DIR" ]]; then
  echo -e "$CONTAINER  One or more input files were not found! Exiting!"
  exit 1
fi

ls -Rl ${DATA_DIR}
ls -al


# Run the Matlab executable
time ${CODE_DIR}/run_vcid_asl_pipeline.sh "${MCR_ROOT}" "${DATA_DIR}"

# Check exit status
exit_status=$?
if [[ $exit_status != 0 ]]; then
  echo -e "$CONTAINER  An error occurred during execution of the Matlab executable. Exiting!"
  exit 1
fi

exit 0
