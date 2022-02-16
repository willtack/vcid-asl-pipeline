#! /bin/bash
#
#

CONTAINER="[vcid-asl-pipeline]"
echo -e "$CONTAINER  Initiated"

DATA_DIR=/opt/base/input
OUTPUT_DIR=/opt/base/output
MCR_ROOT=/usr/local/MATLAB/MATLAB_Runtime/v99/
CODE_DIR=/opt/base/vcid_asl_pipeline/for_redistribution_files_only

# Check for required inputs
if [[ -z "$DATA_DIR" ]]; then
  echo -e "$CONTAINER  One or more input files were not found! Exiting!"
  exit 1
fi

ls -Rl ${DATA_DIR}
ls -al

mkdir -p ${OUTPUT_DIR}

# Run the Matlab executable
time ${CODE_DIR}/run_vcid_asl_pipeline.sh "${MCR_ROOT}" "${DATA_DIR}"

# Check exit status
exit_status=$?
if [[ $exit_status != 0 ]]; then
  echo -e "$CONTAINER  An error occurred during execution of the Matlab executable. Exiting!"
  exit 1
fi

# Move output files to dedicated folder
mkdir -p "${OUTPUT_DIR}"/CoregFiles
for SUB in $(find ${DATA_DIR} -maxdepth 1 -type d | grep sub-); do
  for SES in $(find ${SUB} -maxdepth 1 -type d | grep ses-); do
    for ASL_DIR in $(find ${SES} -type d | grep ASL | grep -v TOF | grep -v HASL); do
      echo $ASL_DIR
      # Save coregistration overlay pictures
      fName=$(basename $SUB)-$(basename $SES)-$(basename $ASL_DIR)_coreg.png
      coregFile=$(find ${ASL_DIR} -type f | grep png)
      if [[ -f $coregFile ]]; then
        cp $coregFile "${OUTPUT_DIR}"/CoregFiles/"${fName}"
      fi

      # Copy ASL pipeline results to output directory
      NEW_DIR="${OUTPUT_DIR}"/$(basename $SUB)/$(basename $SES)
      mkdir -p ${NEW_DIR}
      cp -r ${ASL_DIR}/* ${NEW_DIR}/
    done
  done
done

exit 0
