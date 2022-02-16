clear

codepath = pwd;

cd ../SUBJECTS
dicomdir = pwd;

cd ../Nifti/
niftidir = pwd;

cd(codepath);

subid = dir(fullfile(dicomdir,'HC*'));
subid= {subid.name};
subid(ismember(subid,{'.','..'})) = [];

for sb = 1:length(subid)
    if exist(fullfile(niftidir,subid{sb}),'dir')
        continue;
    end
    fprintf('%s\n',subid{sb})
    dr = dir(fullfile(dicomdir,subid{sb},'detre_group','VCID',subid{sb},'MR_*'));
    for st = 1:length(dr)
        d1 = dr(st);
        if ~isempty(d1)
            d1ASL = dir(fullfile(dicomdir,subid{sb},'detre_group','VCID',subid{sb},d1.name,'*ASL*'));
            d1ASL = {d1ASL.name};
            for t = 1:length(d1ASL)
                if strcmp('.',d1ASL{t}(1))
                    continue;
                end
                subniftidir = fullfile(niftidir,subid{sb},d1.name,d1ASL{t});
                
                tmpdir = fullfile(dicomdir,subid{sb},'detre_group','VCID',subid{sb},d1.name,d1ASL{t});
                
                if contains(tmpdir,'TOF')
                    continue;
                end
                mkdir(subniftidir);
                
                P = spm_select('FPlist',tmpdir,'^1.*nii.gz$');
                for u = 1:size(P,1)
                    copyfile(deblank(P(u,:)),subniftidir);
                end
            end
        end
        
        d1ASL = dir(fullfile(dicomdir,subid{sb},'detre_group','VCID',subid{sb},d1.name,'*MPRAGE*'));
        d1ASL = {d1ASL.name};
        for t = 1:length(d1ASL)
            if strcmp('.',d1ASL{t}(1))
                continue;
            end
            subniftidir = fullfile(niftidir,subid{sb},d1.name,d1ASL{t});
            mkdir(subniftidir);
            tmpdir = fullfile(dicomdir,subid{sb},'detre_group','VCID',subid{sb},d1.name,d1ASL{t});
            P = spm_select('FPlist',tmpdir,'^1.*nii.gz$');
            copyfile(P,subniftidir);
        end
        
    end
    
end
        
 
    
    
    
    
    %% This was the original code used when the complete project was downloaded. The path was slightly different compared to current path when the niftis are downloaded
    % % for sb = 1:length(subid)
    % %     dr = dir(fullfile(dicomdir,subid{sb},'SESSIONS','MR_*'));
    % %     %     d2 = dir(fullfile(dicomdir,subid{sb},'SESSIONS','MR_FOLLOWUP*'));
    % %     %     if max(length(d1),length(d2))>1
    % %     %         error('Problem');
    % %     %     end
    % %     %     if isempty(d1)&&isempty(d2)
    % %     %         continue;
    % %     %     end
    % %     %
    % %     %
    % %
    % %     for st = 1:length(dr)
    % %         d1 = dr(st);
    % %         if ~isempty(d1)
    % %             d1ASL = dir(fullfile(dicomdir,subid{sb},'SESSIONS',d1.name,'ACQUISITIONS','*ASL*'));
    % %             d1ASL = {d1ASL.name};
    % %             for t = 1:length(d1ASL)
    % %                 if strcmp('.',d1ASL{t}(1))
    % %                     continue;
    % %                 end
    % %                 subniftidir = fullfile(niftidir,subid{sb},d1.name,d1ASL{t});
    % %                 mkdir(subniftidir);
    % %                 tmpdir = fullfile(dicomdir,subid{sb},'SESSIONS',d1.name,'ACQUISITIONS',d1ASL{t},'FILES');
    % %
    % %                 if contains(tmpdir,'TOF')
    % %                     continue;
    % %                 end
    % %
    % %                 P = spm_select('FPlist',tmpdir,'^1.*nii.gz$');
    % %                 for u = 1:size(P,1)
    % %                     copyfile(deblank(P(u,:)),subniftidir);
    % %                 end
    % %             end
    % %
    % % %             d1ASL = dir(fullfile(dicomdir,subid{sb},'SESSIONS',d1.name,'ACQUISITIONS','*MPRAGE*'));
    % % %             d1ASL = {d1ASL.name};
    % % %             for t = 1:length(d1ASL)
    % % %                 if strcmp('.',d1ASL{t}(1))
    % % %                     continue;
    % % %                 end
    % % %                 subniftidir = fullfile(niftidir,subid{sb},d1.name,d1ASL{t});
    % % %                 mkdir(subniftidir);
    % % %                 tmpdir = fullfile(dicomdir,subid{sb},'SESSIONS',d1.name,'ACQUISITIONS',d1ASL{t},'FILES');
    % % %                 P = spm_select('FPlist',tmpdir,'^1.*nii.gz$');
    % % %                 copyfile(P,subniftidir);
    % % %             end
    % %
    % %
    % %         end
    % %
    % %     end
    % %
    % % end
