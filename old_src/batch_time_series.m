clear
close all

%
PAR = setparameter;

for ses = 1:5
    tsnr{ses} = [];
end
mxxlim = zeros(5,1);
for sb = 1:PAR.nsubs
    for ses = 1:length(PAR.subject(sb).asldir)
        if isempty(PAR.subject(sb).asldir{ses})
            continue;
        end
        
        subplot(5,1,ses)
        hold on
        
        P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^cbf_0_r.*nii');
        if isempty(P)
	    continue;
	end
	Y = spm_read_vols(spm_vol(P));
        
        c1loc = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^rbk_c1.*nii');
        c1 = spm_read_vols(spm_vol(c1loc));
        c2loc = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^rbk_c2.*nii');
        c2 = spm_read_vols(spm_vol(c2loc));
        
        roi = (c1+c2)>0.85; %% global
        roi = c1>0.9;
        roi = c2 > 0.99; 
        gmCBF = [];
        for s = 1:size(Y,4)
            tmp = Y(:,:,:,s);
            gmCBF(s) = mean(tmp(roi));
        end
        
        plot(gmCBF)
	mxxlim(ses) = max(mxxlim(ses),length(gmCBF));
        tsnr{ses} = [tsnr{ses},mean(gmCBF)/std(gmCBF)];
    end
end



asltype = {'Labeling,PLD : 1.8,1.8','LL : bs2 - sis','LL : bs2 - mis','LL : bs31 - mis','LL : bs31-mis-vfa'};

for ses = 1:5
   subplot(5,1,ses) 
   ylim([0,100])
   title(sprintf('%s, TSNR = %0.2f (%0.2f)',asltype{ses},median(tsnr{ses}),mad(tsnr{ses},1)))
   set(gca,'fontsize',15)
   box on
   grid on
   xlim([0,mxxlim(ses)+1])
end
