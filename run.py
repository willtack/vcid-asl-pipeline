import sys
import os
import logging
from pathlib import PosixPath
from fw_heudiconv.cli import export
import bids
import flywheel
import json
import glob
import shutil

print(sys.path)

# logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger('vcid-asl-gear')
logger.info("=======: VCID ASL processing :=======")

with flywheel.GearContext() as context:
    # Setup basic logging
    context.init_logging()
    config = context.config
    analysis_id = context.destination['id']
    matlab_input_dir = "/opt/base/input"
    gear_output_dir = PosixPath(context.output_dir)
    run_script = gear_output_dir / "vcid_run.sh"
    output_root = gear_output_dir / analysis_id
    bids_root = output_root / 'bids_dataset'
    working_dir = PosixPath(str(output_root.resolve()) + "_work")
    mcr_root = "/usr/local/MATLAB/MATLAB_Runtime/v99/"

    # Get relevant container objects
    fw = flywheel.Client(context.get_input('api_key')['key'])
    analysis_container = fw.get(analysis_id)
    project_container = fw.get(analysis_container.parents['project'])
    session_container = fw.get(analysis_container.parent['id'])
    subject_container = fw.get(session_container.parents['subject'])

    # Get subject and session names
    session_label = session_container.label
    subject_label = subject_container.label
    prefix = "sub-{}_ses-{}".format(subject_label, session_label)

    subjects = [subject_container.label]
    sessions = [session_container.label]

    project_label = project_container.label

    # Inputs
    asl = context.get_input('asl-file')
    m0 = context.get_input('m0_file')
    mprage = context.get_input('mprage_file')

    # Configs
    # vcid = context.get_input('vcid')
    # pld = config.get('PLD')
    # ld = config.get('LD')
    bids_acq = config.get('BIDS-acq')
    bids_run = config.get('BIDS-run')
    bids_sub = config.get('BIDS-subject')
    bids_ses = config.get('BIDS-session')


# def write_command():
#     """Write out command script."""
#     with flywheel.GearContext() as context:
#         cmd = "bash -x /opt/base/run.sh"
#
#     logger.info(cmd)
#     os.system("chmod 777 {}".format(run_script))
#     with run_script.open('w') as f:
#         f.write(cmd)
#
#     return run_script.exists()

def fw_heudiconv_download():
    """Use fw-heudiconv to download BIDS data."""

    # Do the download!
    bids_root.parent.mkdir(parents=True, exist_ok=True)
    downloads = export.gather_bids(fw, project_label, subjects, sessions)
    try:
        export.download_bids(fw, downloads, str(output_root.resolve()), dry_run=False, folders_to_download=['perf','anat'])
    except FileExistsError as e:
        logger.info("Already downloaded BIDs data!")

    bids.config.set_option('extension_initial_dot', True)  # suppress warning

    return True

def convert_from_bids():
    """Convert BIDs structure to the expected folder structure for the MATLAB pipeline."""

    # filter bids data
    layout = bids.BIDSLayout(bids_root)
    filters = {}
    if bids_acq:
        filters["acquisition"] = bids_acq
    if bids_run:
        filters["run"] = bids_run
    filters = {"subject": subjects, "session": sessions}
    # get necessary files
    asl_list = layout.get(suffix='asl', extension=['.nii', '.nii.gz'], **filters)
    m0_list = layout.get(suffix='m0scan', extension=['.nii', '.nii.gz'], **filters)
    mprage_list = layout.get(suffix='T1w', extension=['.nii', '.nii.gz'], **filters)

    # create new folder
    print(subjects)
    print(sessions)
    session_dir = os.path.join(matlab_input_dir, "sub-"+subjects[0], "ses-"+sessions[0])
    os.makedirs(session_dir, exist_ok=True)

    # copy bids data to new folder
    i = 1
    for f in asl_list:
        asl_dir = os.path.join(session_dir,'ASL_0{}'.format(i))
        os.makedirs(asl_dir, exist_ok=True)
        shutil.copyfile(f,os.path.join(asl_dir,'ASL.nii.gz'))
        i = i + 1

    j = 1
    for f in m0_list:
        m0_dir = os.path.join(session_dir,'M0_0{}'.format(j))
        os.makedirs(m0_dir, exist_ok=True)
        shutil.copyfile(f, os.path.join(m0_dir, 'M0.nii.gz'))
        j = j + 1

    mprage_dir = os.path.join(session_dir,'MPRAGE')
    os.makedirs(mprage_dir, exist_ok=True)
    shutil.copyfile(mprage_list[0],os.path.join(mprage_dir,'MPRAGE.nii.gz'))

    return True


def main():
    os.system("bash -x /flywheel/v0/docker-env.sh")

    download_ok = fw_heudiconv_download()
    sys.stdout.flush()
    sys.stderr.flush()
    if not download_ok:
        logger.warning("Critical error while trying to download BIDS data.")
        return 1

    convert_ok = convert_from_bids()
    sys.stdout.flush()
    sys.stderr.flush()
    if not convert_ok:
        logger.warning("Critical error while trying to convert BIDs.")
        return 1

    command_ok = os.system("bash -x /opt/base/run.sh")
    if command_ok != 0:
        logger.warning("Critical error while trying to write run command.")
        return 1


    # run command
    #os.system(run_script)

    # transfer output files to gear output directtory
    os.system("cp -r /opt/base/output/* {}".format(gear_output_dir))

    return 0


if __name__ == '__main__':
    sys.exit(main())
