clear
close all

%
PAR = setparameter;
ct = zeros(5,1);
Y = zeros(91,109,91,5);
for sb = 1:PAR.nsubs
    for ses = 1:length(PAR.subject(sb).asldir)
        if ~isempty(PAR.subject(sb).asldir{ses})
            P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^wFNIRT.*meanCBF.*nii');
            Y(:,:,:,ses) = Y(:,:,:,ses) + spm_read_vols(spm_vol(P));
            ct(ses) = ct(ses)+1;
        end
    end
end


asltype = {'Labeling,PLD : 1.8,1.8','LL : bs2 - mis','LL : bs2 - sis','LL : bs31 - mis','LL : bs31-mis-vfa'};

% for sb = 1:PAR.nsubs
%     x = [];
%     for ses = 1:length(PAR.subject(sb).asldir)
%         if isempty(PAR.subject(sb).asldir{ses})
%             continue
%         end
%         P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^meanCBF.*nii');
%         c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^rbk_c[12].*nii');
%         Y = spm_read_vols(spm_vol(P));
%     	c = spm_read_vols(spm_vol(c12loc));
%         x = [x; [ses mean(Y(sum(c,4)>0.85))]];
% 
%     end
%     if ~isempty(x)
%         plot(x(:,1),x(:,2),'linewidth',1.5)
%         hold on;
%     end
% 
% end
% 
% set(gca,'xtick',1:5,'xticklabel',asltype,'fontsize',15)


for s = 1:5
    Y(:,:,:,s) = Y(:,:,:,s)/ct(s);
    
end

for s = 2:5
    imshow(createmontage(Y(:,:,:,s)),[0,80],'initialmagnification','fit'), colorbar
    title(asltype{s});
    set(gca,'fontsize',15)
    str = strrep(asltype{s},' ','');
    str = strrep(str,':','_');
    str = strrep(str,'-','_');
    str = strrep(str,'.','_');
    print_img([str '_April7'],1000,800)
end



% imshow(createmontage(-Y(:,:,:,1) + Y(:,:,:,3)),[0,50],'initialmagnification','fit'), colorbar


% asltype = {'Labeling,PLD : 1.8,1.8','LL : bs2 - mis','LL : bs2 - sis','LL : bs2 - sis','LL : bs31 - mis','LL : bs31-mis-vfa'};


% sb = 1;
% while sb < PAR.nsubs
%     if ~strcmp(PAR.subject(sb).subid,PAR.subject(sb+1).subid)
%         sb = sb+1;
%         continue
%     end
%
%     for ses = 1:5
%         if isempty(PAR.subject(sb).asldir{ses}) || isempty(PAR.subject(sb+1).asldir{ses})
%             continue
%         end
%
%         P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^meanCBF.*nii');
%         c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^rbk_c[12].*nii');
%         Y1 = spm_read_vols(spm_vol(P));
%         c1 = spm_read_vols(spm_vol(c12loc));
%
%         P = my_spm_select('FPlist',PAR.subject(sb+1).asldir{ses},'^meanCBF.*nii');
%         c12loc = my_spm_select('FPlist',PAR.subject(sb+1).asldir{ses},'^rbk_c[12].*nii');
%         Y2 = spm_read_vols(spm_vol(P));
%         c2 = spm_read_vols(spm_vol(c12loc));
%
%         subplot(2,3,ses)
%         hold on
%
%         scatter(mean(Y1(c1(:,:,:,1)>0.9)),mean(Y2(c2(:,:,:,1)>0.9)),'b','filled');
%         scatter(mean(Y1(c1(:,:,:,2)>0.99)),mean(Y2(c2(:,:,:,2)>0.99)),'r','filled');
%         axis([0,160,0,160])
%         axis square
%         title(asltype{ses});
%     end
%
%     sb = sb+2;
% end


% for sb = 1:PAR.nsubs
%         for ses = 1:length(PAR.subject(sb).asldir)
%             if ~isempty(PAR.subject(sb).asldir{ses})
%                 P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^meanCBF.*nii');
%                 imshow(createmontage(P),[0,150],'initialmagnification','fit'), colorbar
%                 title(sprintf('Subno: %d, ses: %d', sb,ses));
%                 pause
%             end
%         end
%
% end

