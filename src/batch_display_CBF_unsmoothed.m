function batch_display_CBF(PAR)


mkdir CBFmaps_Unsmoothed
cd CBFmaps_June11_Unsmoothed

for sb = 1:PAR.nsubs
    for ses = 1:length(PAR.subject(sb).asldir)
        if isempty(PAR.subject(sb).asldir{ses})
            continue;
        end
        P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^meanCBF.*nii');
        %if isempty(P)
        %    P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^meanCBF.*nii');
        %    sP = fullfile(PAR.subject(sb).asldir{ses},['s' spm_str_manip(P,'t')]);
        %    spm_smooth(P,sP,[5 5 5]);
	%    P = sP;
        %end
        close all
        figure('Position',[1 1 1000 800]);
        imshow(createmontage(P),[-10,100],'InitialMagnification','fit');
        title(sprintf('%s \t %s',PAR.subject(sb).subid, PAR.aslprefix{ses}),'Interpreter','None');  
	colorbar;
        set(gca,'Fontsize',15);      
        if contains(lower(P),'baseline')
            print_img([PAR.subject(sb).subid '_' PAR.aslprefix{ses} '_Baseline.png'],1000,800)
        else
            print_img([PAR.subject(sb).subid '_' PAR.aslprefix{ses} '_Followup.png'],1000,800)
        end
    end
end

cd(PAR.codepath);
