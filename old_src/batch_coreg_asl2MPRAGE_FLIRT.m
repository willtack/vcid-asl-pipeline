function batch_coreg_asl2MPRAGE_FLIRT(PAR,indx)

if nargin<2
    indx = 1:PAR.nsubs;
end

for subno = indx
    fprintf('Coregistering EPI to T1 for subject ID: %s,  #%d/%d\n',PAR.subject(subno).subid,subno,PAR.nsubs);
    try
	compress_nii_files(PAR.subject(subno).anatdir);
	for sesno = 1:length(PAR.subject(subno).asldir)
	    if ~isempty(PAR.subject(subno).asldir{sesno})
		compress_nii_files(PAR.subject(subno).asldir{sesno});
	    end
	end
        if isfield(PAR.subject(subno),'M0dir')
            coreg_ASLM0_to_ASL(PAR,subno);
        end
        coreg_ASLM0_to_MPRAGE_FLIRT(PAR,subno);
    catch ERROR
        fid = fopen(['batch_coregistration_errors_' PAR.subject(subno).subid '.txt'],'w');
        fprintf(fid,'Error in coregistration with %s\n', PAR.subject(subno).subid);
        fprintf(fid,'%s\n',ERROR.message);
        fclose(fid);
    end
end
%close(hwtbr);


function coreg_ASLM0_to_ASL(PAR,subno)
defaults=spm_get_defaults;
flags = defaults.coreg;
resFlags = struct(...
    'interp', 1,...                       % trilinear interpolation
    'wrap', flags.write.wrap,...           % wrapping info (ignore...)
    'mask', flags.write.mask,...           % masking (see spm_reslice)
    'which',1,...                         % write reslice time series for later use, don't write the first 1
    'mean',0);                            % do write mean image

for sesno = 1:length(PAR.subject(subno).asldir)
    P = spm_select('FPlist',PAR.subject(subno).asldir{sesno},'ASLspace');
    if ~isempty(P)
        continue;
    end
    
    PG=my_spm_select('FPList', PAR.subject(subno).asldir{sesno}, ['^mean' PAR.aslprefix{sesno} '.*\.nii']);
    
    if strcmp(deblank(PG),'/')
        fprintf('No mean ASL exist for %s!\n',PAR.subject(subno).asldir{sesno});
        continue;
    end
    
    % get mean in this directory
    %PG - Tar(G)et image, NEVER CHANGED
    %PF - Source image, transformed to match PG
    %PO - (O)ther images, originally realigned to PF and transformed again to PF
    
    % TARGET
    % get (NOT skull stripped structural from) Structurals
    VG = spm_vol(PG);
    
    PF =my_spm_select('FPList', PAR.subject(subno).M0dir{sesno},    ['^mean' PAR.M0prefix{sesno} '.*nii']);
    PF1=fullfile(PAR.subject(subno).asldir{sesno}, ['ASLspace_' spm_str_manip(PF(1,:),'t')]);
    cpstr=['!cp '  PF ' ' PF1  ];
    eval(cpstr);    % make a copy of the mean EPI
    PF=PF1;
    
    VF= spm_vol(PF(1,:));
    
    x  = spm_coreg(VG, VF,flags.estimate);
    %get the transformation to be applied with parameters 'x'
    M  = inv(spm_matrix(x));
    
    MM=spm_get_space(deblank(PF));
    spm_get_space(deblank(PF),M*MM);
    
    spm_reslice(strvcat(PG,PF),resFlags);
    delete(deblank(PF));
    
    
    compress_nii_files(PAR.subject(subno).asldir{sesno});
    compress_nii_files(PAR.subject(subno).M0dir{sesno});
end

%


function coreg_ASLM0_to_MPRAGE_FLIRT(PAR,subno)

% wmsegfile = spm_select('FPlist',PAR.subject(subno).anatdir,'wmseg.*nii');
% if ~isempty(wmsegfile)
%     fprintf('WMSEG file is present for subject %s, might have been coregistered\n',PAR.subject(subno).subid);
%     %     return;
% end

c2vol = spm_select('FPlist',PAR.subject(subno).anatdir,'^c2');
% if isempty(c2vol)
%     fprintf('- WM map not found for %s.\n',PAR.subject(subno).anatdir);
%     return;
% end

% t1brain = spm_select('FPlist',PAR.subject(subno).anatdir,['^skullstripped_.*m' PAR.anatprefix '.*.gz']);
t1 = spm_select('FPlist',PAR.subject(subno).anatdir,['^m' PAR.anatprefix '.*.gz']);
maskloc = spm_select('FPlist',PAR.subject(subno).anatdir,'^mask_.*.gz');
wmsegvol = fullfile(PAR.subject(subno).anatdir,'EPIREG_wmseg.nii.gz');

if ~exist(wmsegvol,'file')
    commandc = sprintf('fslmaths %s -mas %s -thr 0.1 -bin %s', c2vol, maskloc, wmsegvol);
    system(commandc);
end

for sesno = 1:length(PAR.subject(subno).asldir)
    P = spm_select('FPlist',PAR.subject(subno).asldir{sesno},'^rbk_mask.*nii');
    if ~isempty(P)
        continue;
    end
    
    
    epi_vol  = spm_select('FPlist',PAR.subject(subno).asldir{sesno}, ['^rASLspace_mean' PAR.M0prefix{sesno} '.*.nii.gz']);
    outputname = fullfile(PAR.subject(subno).asldir{sesno},['ASL2MPRAGE_' PAR.subject(subno).subid]);
    
    commandc = ['flirt -ref ' t1 ' -in ' epi_vol ' -dof 6 -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -omat ' outputname '.mat -out ' outputname ' -cost normmi'];
    system(commandc);
    
    commandc = ['fslmaths ', wmsegvol ' -edge -bin -mas ' wmsegvol ' ' outputname '_fast_wmedge.nii.gz'];
    system(commandc);
    
    
    
    %Calculate inverse transform
    outputmat_inv = fullfile(PAR.subject(subno).asldir{sesno}, 'MPRAGE2ASL.mat');
    inmat  = [outputname '.mat'];
    commandc = sprintf('%s -omat %s -inverse %s', 'convert_xfm', outputmat_inv, inmat);
    system(commandc);
    
    
    epi_vol  = spm_select('FPlist',PAR.subject(subno).asldir{sesno}, ['^mean' PAR.aslprefix{sesno} '.*.nii.gz']);
    
    
    %     if ~exist([outputname '.nii.gz'],'file')
    %It has been removed in a previous call to the script
    commandc = ['applywarp --ref=' t1 ' --in=' epi_vol ' --out=' outputname '_img --premat=' inmat ' --interp=trilinear'];
    system(commandc);
    %     else
    %         movefile([outputname '.nii.gz'],[outputname '_img.nii.gz']);
    %     end
    
    regoutputimg = fullfile(PAR.subject(subno).asldir{sesno}, ['ASL2MPRAGE_' PAR.subject(subno).subid '.png']);
    check_epi_reg([outputname '_img'], regoutputimg);
    
    %         %Remove registered data (unnecessary)
    %         output_reg = spm_select('FPlist',PAR.asldir{subno,sesno},['^' outputname '.*nii.gz']);
    %         commandc = sprintf('rm %s',output_reg);
    % %         disp(commandc);
    %         system(commandc);
    
    
    
    P = spm_select('FPlist',PAR.subject(subno).anatdir,'^c[123].*nii.gz');
    for k=1:3
        Pout = fullfile(PAR.subject(subno).asldir{sesno},['rbk_' spm_str_manip(P(k,:),'t')]);
        commandc = ['applywarp --ref=' epi_vol ' --in=' P(k,:) ' --out=' Pout ' --premat=' outputmat_inv ' --interp=trilinear'];
        system(commandc);
    end
    
    P = spm_select('FPlist',PAR.subject(subno).anatdir,'^mask.*nii.gz');
    Pout = fullfile(PAR.subject(subno).asldir{sesno},['rbk_' spm_str_manip(P,'t')]);
    commandc = ['applywarp --ref=' epi_vol ' --in=' P ' --out=' Pout ' --premat=' outputmat_inv ' --interp=nn'];
    system(commandc);
    %         %Remove registered data (unnecessary)
    %         output_reg = spm_select('FPlist',PAR.asldir{subno,sesno},['^' outputname '.*nii.gz']);
    %         commandc = sprintf('rm %s',output_reg);
    % %         disp(commandc);
    %         system(commandc);
    
    
    
    
end



