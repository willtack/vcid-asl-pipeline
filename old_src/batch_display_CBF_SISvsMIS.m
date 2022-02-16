function batch_display_SISvsMIS(PAR)

% addpath(genpath('/project/detre/sdolui/jet/sdolui/mytoolbox'));

% spm fmri

if ~exist('CBFmaps_Unsmoothed_SISvsMIS','dir')
    mkdir CBFmaps_Unsmoothed_SISvsMIS
end
cd CBFmaps_Unsmoothed_SISvsMIS

for sb = 26:PAR.nsubs
    try
    if isempty(PAR.subject(sb).asldir)
        continue;
    end
    if isempty(PAR.subject(sb).asldir{2})|| isempty(PAR.subject(sb).asldir{3})
        continue;
    end
    close all
    figure('Position',[1 1 1400 700]);
    
    for ses = [2,3]
        P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^meanCBF.*nii');
        %if isempty(P)
        %    P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^meanCBF.*nii');
        %    sP = fullfile(PAR.subject(sb).asldir{ses},['s' spm_str_manip(P,'t')]);
        %    spm_smooth(P,sP,[5 5 5]);
        %    P = sP;
        %end
        
        if ses==2
            subplot('Position',[0.03,0.03,0.45,0.9])
        else
            subplot('Position',[0.52,0.03,0.45,0.9])
        end
        imshow(createmontage(P),[-10,100],'InitialMagnification','fit');
        title(sprintf('%s \t %s',PAR.subject(sb).subid, PAR.aslprefix{ses}),'Interpreter','None');
        colorbar;
        set(gca,'Fontsize',15);
        
    end
    
    if contains(lower(P),'baseline')
        print_img([PAR.subject(sb).subid '_SISvsMIS_Baseline.png'],1400,700)
    else
        print_img([PAR.subject(sb).subid '_SISvsMIS_Followup.png'],1400,700)
    end
    catch Errmsg
        fid = fopen(fullfile(PAR.codepath,['display_SISvsMIS_' PAR.subject(sb).subid '.txt']),'w');
        fprintf(fid,'Error in print image\n');
        fprintf(fid,'%s\n', Errmsg.message);
        fclose(fid);
    end
end

cd(PAR.codepath)


