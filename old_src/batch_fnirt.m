function batch_fnirt(PAR,SUBIDs,subindices)

%hwtbr = waitbar(0);
if nargin == 3
    indx = subindices;
elseif nargin<2
    indx = 1:PAR.nsubs;
else
    %indx = SUBIDs
    indx = [];
    for subno = 1:PAR.nsubs
        if ismember(PAR.subject(subno).subid,SUBIDs)
            indx = [indx,subno];
        end
    end
end

refvol = fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_2mm_brain.nii.gz');
for subno = indx
    try
        compress_nii_files(PAR.subject(subno).anatdir);
        fprintf('%s\n%s\n',repmat('-',1,100),repmat('-',1,100));
        fprintf('Fnirt for subject %s\n',PAR.subject(subno).subid);
        
        
        t1vol = spm_select('FPlist',PAR.subject(subno).anatdir,['^m' PAR.anatprefix '.*.nii']);
        %     t1brainvol = spm_select('FPlist',PAR.subject(subno).anatdir,['^skullstripped_.*m' PAR.anatprefix '.*.gz']);
        outputaffmat = fullfile(PAR.subject(subno).anatdir, 'sub2mni_affine.mat');
        warpfile     = fullfile(PAR.subject(subno).anatdir, 'sub2mni_warpcoef.nii.gz');
        flirtoutfile = fullfile(PAR.subject(subno).anatdir, ['wFLIRT_' spm_str_manip(t1vol,'t')]);
        fnirtoutfile = fullfile(PAR.subject(subno).anatdir, ['wFNIRT_' spm_str_manip(t1vol,'t')]);
        %     bettedvol = fullfile(PAR.subject(subno).anatdir,['betted_' spm_str_manip(t1vol,'t')]);
        bettedvol = spm_select('FPlist',PAR.subject(subno).anatdir,'^skullstripped_.*nii');
        %     system(['bet ' t1vol ' ' bettedvol]);
        if isempty(t1vol)&&isempty(bettedvol)
            continue;
        end
        
        % Affine registration
        commandc = ['flirt -ref ' refvol ' -in ' bettedvol ' -omat ' outputaffmat ' -bins 256' ' -cost corratio' ...
            ' -searchrx -180 180'  ' -searchry -180 180' ' -searchrz -180 180' ' -dof 12' ' -interp trilinear'];
        %disp(commandc);
        system(commandc);
        commandc=['applywarp --ref=' refvol ' --in=' t1vol ' --out=' flirtoutfile  ' --premat=' outputaffmat];
        %disp(commandc);
        system(commandc);
        
        % Non linear registration
        commandc = ['fnirt --ref=' refvol ' --in=' t1vol ' --aff=' outputaffmat ' --cout=' warpfile ' --iout=' fnirtoutfile ' --config=T1_2_MNI152_2mm --lambda=400,200,150,75,60,45'];
        %%%%% --lambda=400,200,150,75,60,45 Use this if Jacobian error
        %%%%%% --lambda=400,300,200,150,75,60
        %%%%% --lambda=450,350,250,150,75,60
        %%%%%  --lambda=450,350,250,200,100,75
        %disp(commandc);
        system(commandc);
        
        
        %%QA: Check and save registration output
        outputimg = fullfile(PAR.subject(subno).anatdir,[ 'wFNIRT_' PAR.subject(subno).subid '.png']);
        img2show = spm_read_niigz_vol(fnirtoutfile);
        himg=myimshow3D(img2show(:,end:-1:1,14:2:end-14),8);
        saveas(himg, outputimg);
        close(himg);
        outputimg = fullfile(PAR.subject(subno).anatdir,[ 'wFLIRT_' PAR.subject(subno).subid '.png']);
        img2show = spm_read_niigz_vol(flirtoutfile);
        himg=myimshow3D(img2show(:,end:-1:1,14:2:end-14),8);
        saveas(himg, outputimg);
        close(himg);
    catch ERROR
        if ~exist('fid','var')
            fid = fopen(['batch_fnirt_errors_' PAR.subject(subno).subid '.txt'],'w');
        end
        fprintf(fid,'Error in FNIRT in %s\n', PAR.subject(subno).anatdir);
        fprintf(fid,'%s\n',ERROR.message);
        fclose(fid);
    end
end



