function batch_MNI_2_sub_masks(PAR)

roiloc = spm_select('FPlist',pwd,'^PVCBF.*.nii$');
for subno = 1:PAR.nsubs
    %P1 = spm_select('FPlist',PAR.subject(subno).anatdir,'PVCBF15.*mask.*nii');
    %P2 = spm_select('FPlist',PAR.subject(subno).anatdir,'PVCBF20.*mask.*nii');
    %P3 = spm_select('FPlist',PAR.subject(subno).anatdir,'PVLesion.*mask.*nii');
    %if ~isempty(P1) && ~isempty(P2) && ~isempty(P3)
    %    continue;
    %end
%     for s = 1:size(tmproiloc,1)
%         delete(deblank(tmproiloc(s,:)));
%     end
    t1vol = spm_select('FPlist',PAR.subject(subno).anatdir,['^m' PAR.anatprefix '.*.nii']);
    if isempty(t1vol)
        continue;
    end
    fprintf('MNI to Subject masks for subject %s, # %d/%d, %s\n',PAR.subject(subno).subid,subno,PAR.nsubs,char(datetime)); 
    mni2sub = fullfile(PAR.subject(subno).anatdir,['MNI2sub_' PAR.subject(subno).subid]);
    for s = 1:size(roiloc,1)
        outputfile = fullfile(PAR.subject(subno).anatdir,[spm_str_manip(roiloc(s,:),'ts') '_' PAR.subject(subno).subid]);
        commandc = ['applywarp --ref=' t1vol ' --in=' roiloc(s,:) ' --warp=' mni2sub ' --out=' outputfile ' --interp=nn'];
        system(commandc);
    end
end