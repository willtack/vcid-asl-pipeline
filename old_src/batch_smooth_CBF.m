function batch_smooth_CBF(PAR)

for subno =1:PAR.nsubs
    for sesno = 1:length(PAR.subject(subno).asldir)
        filename=my_spm_select('FPList', PAR.subject(subno).asldir{sesno}, '^SCRUB_cbf_0_r.*\.nii');
        sfilename = fullfile(PAR.subject(subno).asldir{sesno},['s' spm_str_manip(filename,'t')]);
        spm_smooth(filename,sfilename,PAR.FWHM);
        
        compress_nii_files(PAR.subject(subno).asldir{sesno});
    end
end