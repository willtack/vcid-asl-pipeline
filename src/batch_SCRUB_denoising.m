function batch_SCRUB_denoising(PAR)

for subno =1:PAR.nsubs
    for sesno = 1:length(PAR.subject(subno).asldir)
        filename=my_spm_select('FPList', PAR.subject(subno).asldir{sesno}, '^cbf_0_r.*\.nii');
        tpmimgs=my_spm_select('FPList', PAR.subject(subno).asldir{sesno}, '^rbk_c[123].*\.nii');
        
        maskimg = my_spm_select('FPList', PAR.subject(subno).asldir{sesno}, '^rbk_mask.*\.nii');
        SCRUBdenoising(filename,tpmimgs,maskimg,'SCRUB');
        compress_nii_files(PAR.subject(subno).asldir{sesno});
    end
end

