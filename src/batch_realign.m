function batch_realign(PAR)


fprintf('------------------------------------------------------------------')
fprintf('\nREALIGNING THE EPI TIME SERIES\n');
fprintf('------------------------------------------------------------------\n\n')

global defaults;
spm_defaults;

% Get realignment defaults
defs = defaults.realign;
reaFlags = struct(...
    'quality', defs.estimate.quality,...  % estimation quality
    'fwhm', 5,...                         % smooth before calculation
    'rtm', 0,...                          % whether to realign to mean % we have to remove the first pair later
    'PW',''...                            %
    );
% Flags to pass to routine to create resliced images
% (spm_reslice)
resFlags1 = struct(...
    'interp', 1,...                       % trilinear interpolation
    'wrap', defs.write.wrap,...           % wrapping info (ignore...)
    'mask', defs.write.mask,...           % masking (see spm_reslice)
    'which',2,...                         % write reslice time series for later use
    'mean',1);                            % do write mean image

resFlags2 = struct(...
    'interp', 1,...                       % trilinear interpolation
    'wrap', defs.write.wrap,...           % wrapping info (ignore...)
    'mask', defs.write.mask,...           % masking (see spm_reslice)
    'which',0,...                         % write reslice time series for later use
    'mean',1);                            % do write mean image



for subno =1:PAR.nsubs % for each subject
    fprintf('\n\nRealign EPI for subject %s\n',PAR.subject(subno).subid);
    for sesno = 1:length(PAR.subject(subno).asldir)
        if isempty(PAR.subject(subno).asldir{sesno})
            continue;
        end
        try
            P=spm_select('FPlist',PAR.subject(subno).asldir{sesno},'^mean.*nii');
            if ~isempty(P)
                continue;
            end
            P=my_spm_select('ExtFPlist',PAR.subject(subno).asldir{sesno},['^' PAR.aslprefix{sesno} '.*nii']);
            
            if isempty(P)
                continue;
            end
            
            % Run the realignment
            spm_realign_asl(P, reaFlags);
            spm_reslice(P, resFlags1);
            compress_nii_files(PAR.subject(subno).asldir{sesno});
        catch ERROR
            fid = fopen(['batch_realign_errors_ASL_' PAR.subject(subno).subid '.txt'],'w');
            fprintf(fid,'Error in realignment in %s\n', PAR.subject(subno).asldir{sesno});
            fprintf(fid,'%s\n',ERROR.message);
            fclose(fid);
        end
    end
    
    if isfield(PAR.subject(subno),'M0dir')
        try
            for sesno = 1:length(PAR.subject(subno).M0dir)
                if isempty(PAR.subject(subno).M0dir{sesno})
                    continue;
                end
                P=spm_select('FPlist',PAR.subject(subno).M0dir{sesno},'^mean.*nii');
                if ~isempty(P)
                    continue;
                end
                P=my_spm_select('ExtFPlist',PAR.subject(subno).M0dir{sesno},['^' PAR.M0prefix{sesno} '.*nii']);
                if isempty(P)
                    continue;
                end
                
                if size(P,1)==1
                    P=my_spm_select('FPlist',PAR.subject(subno).M0dir{sesno},['^' PAR.M0prefix{sesno} '.*nii']);
                    movefile(P,fullfile(spm_str_manip(P,'H'),['mean' spm_str_manip(P,'t')]));
                else
                    % Run the realignment
                    spm_realign(P, reaFlags);
                    spm_reslice(P, resFlags2);
                end
                compress_nii_files(PAR.subject(subno).M0dir{sesno})
            end
        catch ERROR
            fid = fopen(['batch_realign_errors_M0' PAR.subject(subno).subid '.txt'],'w');
            fprintf(fid,'Error in realignment in %s\n', PAR.subject(subno).M0dir{sesno});
            fprintf(fid,'%s\n',ERROR.message);
            fclose(fid);
        end
    end
end
