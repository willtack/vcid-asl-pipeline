function batch_reslice_CBF_t1space(PAR,indx)


if nargin<2
    indx = 1:PAR.nsubs;
end

for subno = indx
    
    
    for sesno = 1:length(PAR.subject(subno).asldir)
        
        if isempty(PAR.subject(subno).asldir{sesno})
            continue;
        end
        
        outvol = spm_select('FPlist',PAR.subject(subno).asldir{sesno},'t1space_');
        if ~isempty(outvol)
          continue;
        end
        compress_nii_files(PAR.subject(subno).asldir{sesno});
        fprintf('EPI to T1 CBF for subject %s, # %d/%d, %s\n',PAR.subject(subno).subid,subno,PAR.nsubs,char(datetime));
        premat = fullfile(PAR.subject(subno).asldir{sesno},['ASL2MPRAGE_' PAR.subject(subno).subid '.mat']);
        %invol = spm_select('FPlist',PAR.subj(subno).asldir{sesno},['^cbf_0_rPCASL3D_.*.nii']);
        %outvol = fullfile(PAR.subj(subno).asldir{sesno},['t1space_' spm_str_manip(invol,'t')]);
        t1 = spm_select('FPlist',PAR.subject(subno).anatdir,['^' PAR.anatprefix '.*.gz']);
        %commandc=['applywarp --ref=' t1 ' --in=' invol ' --out=' outvol  '  --premat=' premat];
        %disp(commandc);
        %system(commandc);
        invol = spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^meanCBF.*.nii']);
        tmp = spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^rbk_c[123].*.nii']);
%         tmp = spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^PCAprocessedCBF.*.nii']);
        invol = strvcat(invol,tmp);
        for s = 1:size(invol,1)
            outvol = fullfile(PAR.subject(subno).asldir{sesno},['t1space_' spm_str_manip(invol(s,:),'t')]);
            commandc=['applywarp --ref=' t1 ' --in=' invol(s,:) ' --out=' outvol  '  --premat=' premat];
            %disp(commandc);
            system(commandc);
        end
    end
end
