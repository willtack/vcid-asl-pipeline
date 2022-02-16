function PAR=setparameter(datadir)
% prefix is the subject prefix

PAR.codepath = pwd;
PAR.dataroot = datadir;
cd(PAR.codepath);

PAR.anatprefix = 'MPRAGE';

subids = dir(PAR.dataroot);
subids = {subids.name};
subids(ismember(subids,{'.','..','.DS_Store'})) = [];
sb = 0;

for t = 1:length(subids)

    dr = dir(fullfile(PAR.dataroot,subids{t},'ses-*'));
%     dr=dr(~ismember({dr.name},{'.','..'}));

    for s = 1:length(dr)
        ses = 0;
        sb = sb+1;
        
        PAR.subject(sb).subid = subids{t};
        tmpdir = dir(fullfile(PAR.dataroot,subids{t},dr(s).name,'MPRAGE*'));
        PAR.subject(sb).anatdir = fullfile(PAR.dataroot,subids{t},dr(s).name,tmpdir.name);
              
        %
        % EVERYTHING ELSE
        %
        ses = ses+1;
        tmpdir = dir(fullfile(PAR.dataroot,subids{t},dr(s).name,'ASL*'));
        if ~isempty(tmpdir)
            PAR.subject(sb).asldir{ses} = fullfile(PAR.dataroot,subids{t},dr(s).name,tmpdir.name);
        else
            PAR.subject(sb).asldir{ses} = [];
        end
        
        tmpdir = dir(fullfile(PAR.dataroot,subids{t},dr(s).name,'M0*'));
        if ~isempty(tmpdir)
            PAR.subject(sb).M0dir{ses} = fullfile(PAR.dataroot,subids{t},dr(s).name,tmpdir.name);
        else
            PAR.subject(sb).M0dir{ses} = [];
        end
        
        PAR.ASL.PLD{1} = 1.8;
        PAR.ASL.LabelingTime{1} = 1.8;
        PAR.aslprefix{ses} = 'ASL';
        PAR.M0prefix{ses} = 'M0';
    end
    
end


PAR.ASL.lambda = 0.9;
PAR.ASL.T1blood = 1.65;
PAR.ASL.alpha = 0.72;
PAR.ASL.M0scale = 10;
PAR.ASL.Slicetime = 0;
PAR.nsubs = length(PAR.subject);
PAR.FWHM = [5 5 5];




