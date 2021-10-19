clear
close all

PAR = setparameter;

for sb = 22:25
    for ses = 1:length(PAR.subject(sb).asldir)
        if isempty(PAR.subject(sb).asldir{ses})
            continue;
        end
        P = spm_select('FPlist',PAR.subject(sb).asldir{ses},'^ASL.*png');
        imshow(imread(P),[]);
        title(P)
        pause
    end
end