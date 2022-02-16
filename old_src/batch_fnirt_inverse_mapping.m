function batch_fnirt_inverse_mapping(PAR,indx)

if nargin<2
    indx = 1:PAR.nsubs;
end

% setenv('PATH', [getenv('PATH') ':/usr/local/fsl']);

for subno = indx
    try
        outfile = spm_select('FPlist',PAR.subject(subno).anatdir,'MNI2sub.*');
        if ~isempty(outfile)
            continue;
        end
        fprintf('FNIRT Inverse Mapping for %s, # %d/%d\n',PAR.subject(subno).subid,subno,PAR.nsubs);
        warpfile     = fullfile(PAR.subject(subno).anatdir, 'sub2mni_warpcoef.nii.gz');
        t1vol = spm_select('FPlist',PAR.subject(subno).anatdir,['^m' PAR.anatprefix '.*.nii']);
        outfile = fullfile(PAR.subject(subno).anatdir,['MNI2sub_' PAR.subject(subno).subid]);
        commandc = ['invwarp --ref=' t1vol ' --warp=' warpfile ' --out=' outfile];
        system(commandc);
    catch ERROR
        
        fid = fopen(['batch_fnirt_inverse_mapping_errors_' PAR.subject(subno).subid '.txt'],'w');        
        fprintf(fid,'Error in inverse FNIRT mapping in %s\n', PAR.subject(subno).anatdir);
        fprintf(fid,'%s\n',ERROR.message);
        fclose(fid);        
    end
end
