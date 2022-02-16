function batch_segment(PAR)

fprintf('------------------------------------------------------------------')
fprintf('\nSEGMENTING THE MPRAGE IMAGES\n');
fprintf('------------------------------------------------------------------\n\n')


spmpath = spm('dir');

matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 1.0000e-03;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1]; %% Save bias field corrected
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {fullfile(spmpath,'tpm','TPM.nii,1')};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {fullfile(spmpath,'tpm','TPM.nii,2')};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {fullfile(spmpath,'tpm','TPM.nii,3')};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {fullfile(spmpath,'tpm','TPM.nii,4')};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {fullfile(spmpath,'tpm','TPM.nii,5')};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {fullfile(spmpath,'tpm','TPM.nii,6')};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];

matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 1.0000e-03 0.5000 0.0500 0.2000];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';  % European brain
% matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'eastern';  % eastern asian brain
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];

% if PAR.dartel   %% if dartel template is used later
%     matlabbatch{1}.spm.spatial.preproc.tissue(1).native(1,2) = 1;
%     matlabbatch{1}.spm.spatial.preproc.tissue(2).native(1,2) = 1;
% end
% if PAR.forward_transform     %% If normalization is done without dartel
%     matlabbatch{1}.spm.spatial.preproc.warp.write(1,2) = 1;
% end
% if PAR.inverse_transform     %% If MNI to subject-space warping is required
%     matlabbatch{1}.spm.spatial.preproc.warp.write(1,1) = 1;
% end


%T1img = cell(PAR.nsubs,1);
%idx = 0;
parfor subno = 1:PAR.nsubs
    try
        fprintf('Segmenting T1 image for subject # %d, subid = %s\n', subno,PAR.subject(subno).subid);
        matfile=spm_select('FPList',PAR.subject(subno).anatdir,['^' PAR.anatprefix '.*_seg8\.mat$']);
        if ~isempty(matfile)
            fprintf('T1 image in %s has been segmented!\n', PAR.subject(subno).anatdir);
            continue;
        end
        
        
        P=spm_select('FPlist',PAR.subject(subno).anatdir, ['^' PAR.anatprefix '.*nii$']);
        if isempty(P)
            P=spm_select('FPlist',PAR.subject(subno).anatdir, ['^' PAR.anatprefix '.*nii.gz$']);
            gunzip(deblank(P));
            P=spm_select('FPlist',PAR.subject(subno).anatdir, ['^' PAR.anatprefix '.*nii$']);
        end
        
        if isempty(P)
            fprintf('No T1 image found in %s\n',PAR.subject(subno).anatdir);
            continue;
        end
        if size(P,1)>1
            fprintf('Multiple T1 image in %s, segmenting the last image\n',PAR.subject(subno).anatdir);
            P=P(2,:);
        end
        
        %idx = idx + 1;
        %T1img{1,1} =  P(1,:);
        matlabbtch = matlabbatch;
        matlabbtch{1}.spm.spatial.preproc.channel.vols = {P(1,:)};
        cfg_util('run', matlabbtch);
        compress_nii_files(PAR.subject(subno).anatdir)
    catch Errmsg
        fid = fopen(['batch_segment_errors_' PAR.subject(subno).subid '.txt'],'w');        
        fprintf(fid,'Error in segmentation in %s\n', PAR.subject(subno).anatdir);
        fprintf(fid,'%s\n', Errmsg.message);
        fclose(fid);
        
        errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ERROR.stack(1).name, ERROR.stack(1).line, ERROR.message);
        fprintf(1, '%s\n', errorMessage);
    end
end

