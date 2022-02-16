function batch_extract_M0(PAR)


for subno = 1:PAR.nsubs
    for sesno = 1:length(PAR.subject(subno).M0dir)
        if isempty(PAR.subject(subno).M0dir{sesno})
            continue;
        end
        
        P=spm_select('FPlist',PAR.subject(subno).M0dir{sesno},'^mean.*nii');
        if ~isempty(P)
            continue;
        end
        
        P=my_spm_select('FPlist',PAR.subject(subno).M0dir{sesno},['^' PAR.M0prefix{sesno} '.*nii']);
        if isempty(P)
            continue;
        end
        
        v = spm_vol(P);
        v0 = v(1);
        Y = spm_read_vols(v);
        v0.fname = fullfile(PAR.subject(subno).M0dir{sesno},['mean' spm_str_manip(P,'t')]);
        spm_write_vol(v0,Y(:,:,:,1));
        compress_nii_files(PAR.subject(subno).M0dir{sesno});
    end
end