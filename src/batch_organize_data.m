function batch_organize_data(PAR)


for sb = 1:PAR.nsubs
    %     sb
    P = spm_select('FPlist',PAR.subject(sb).anatdir,[PAR.anatprefix]);
    if isempty(P)
        P = spm_select('FPlist',PAR.subject(sb).anatdir,'^1.*nii.gz');
        movefile(P,fullfile(PAR.subject(sb).anatdir,[PAR.anatprefix '_' PAR.subject(sb).subid '.nii.gz']));
    end
    
    for ses = 1:length(PAR.subject(sb).asldir)
        if isempty(PAR.subject(sb).asldir{ses})
            continue;
        end
        
        P = spm_select('FPlist',PAR.subject(sb).asldir{ses},[PAR.aslprefix{ses}]);
        if isempty(P)
            P = spm_select('FPlist',PAR.subject(sb).asldir{ses},'^1.*nii.gz');
            if ~isempty(P)
                movefile(P,fullfile(PAR.subject(sb).asldir{ses},[PAR.aslprefix{ses} '_' PAR.subject(sb).subid '.nii.gz']));
            end
            %         else
            %             error('Problem');
        end
        
        P = spm_select('FPlist',PAR.subject(sb).M0dir{ses},[PAR.M0prefix{ses}]);
        if isempty(P)
            P = spm_select('FPlist',PAR.subject(sb).M0dir{ses},'^1.*nii.gz');
            if ~isempty(P)
                movefile(P,fullfile(PAR.subject(sb).M0dir{ses},[PAR.M0prefix{ses} '_' PAR.subject(sb).subid '.nii.gz']));
            end
            %         else
            %             error('Problem');
        end
    end
end