function batch_warp_EPI2MNI(PAR,indx)

if nargin<2
    indx = 1:PAR.nsubs;
end
refvol = fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_2mm_brain.nii.gz');


for subno = indx%1:PAR.nsubs
    fprintf('%s\n%s\n',repmat('-',1,100),repmat('-',1,100));
    fprintf('EPI to MNI for subject %s\n',PAR.subject(subno).subid);
    for sesno = 1:length(PAR.subject(subno).asldir)
        if isempty(PAR.subject(subno).asldir{sesno})
            continue;
        end

        compress_nii_files(PAR.subject(subno).asldir{sesno});
        %checkvol = spm_select('FPlist',PAR.subject(subno).asldir{sesno},'wFNIRT');
        %if ~isempty(checkvol)
        %    continue;
        %end

        %invol = spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^cbf_0_rPCASL3D_.*.nii.gz']);
        warpfile     = fullfile(PAR.subject(subno).anatdir, 'sub2mni_warpcoef.nii.gz');
        premat = fullfile(PAR.subject(subno).asldir{sesno},['ASL2MPRAGE_' PAR.subject(subno).subid '.mat']);
%         fnirtoutfile = fullfile(spm_str_manip(invol,'H'), ['wFNIRT_' spm_str_manip(invol,'t')]);
%         if isempty(invol)
%             continue;
%         end
% 
%         commandc=['applywarp --ref=' refvol ' --in=' invol ' --out=' fnirtoutfile  ' --warp=' warpfile ' --premat=' premat];
%         %disp(commandc);
%         system(commandc);

        invol = spm_select('FPlist',PAR.subject(subno).asldir{sesno},['^rbk_[c12].*.nii.gz']);
        for s = 1:size(invol,1)
            fnirtoutfile = fullfile(spm_str_manip(invol(s,:),'H'), ['wFNIRT_' spm_str_manip(deblank(invol(s,:)),'t')]);
            commandc=['applywarp --ref=' refvol ' --in=' deblank(invol(s,:)) ' --out=' fnirtoutfile  ' --warp=' warpfile ' --premat=' premat];
            %disp(commandc);
            system(commandc);
        end

    end
end

