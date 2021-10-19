clear

PAR = setparameter;

ACA = [2,12];
MCA = [4,14];
PCA = [6,16];

% indx = [ACA,MCA,PCA];

% fid = fopen('ROIdata.xls','w');
% 
% vascloc = spm_select('FPlist',PAR.codepath,'^mni_vascular_territories_2mm.nii');
% vasc = spm_read_vols(spm_vol(vascloc));
% roi1 = (vasc ==2) | (vasc ==4) | (vasc==12) | (vasc==14);
% roi2 = (vasc ==6) | (vasc ==16) ;
% 
% fprintf(fid,'SUBID \t SL_Anterior_GM \t SL_Anterior_WM \t SL_Posterior_GM \t SL_Posterior_WM \t');
% fprintf(fid,'LL_Anterior_GM \t LL_Anterior_WM \t LL_Posterior_GM \t LL_Posterior_WM \n');
% for sb = 1:25%PAR.nsubs
% %     if sb>=2 && strcmp(PAR.subject(sb).subid,PAR.subject(sb-1).subid)
% %         continue;
% %     end
% %     
%     
% 
%     fprintf(fid,'%s\t',PAR.subject(sb).subid);
% 
%     P = my_spm_select('FPlist',PAR.subject(sb).asldir{1},'^wFNIRT.*meanCBF.*nii');
%     c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{1},'^wFNIRT.*c[12].*nii');
%     
%     Y = spm_read_vols(spm_vol(P));
%     c12 = spm_read_vols(spm_vol(c12loc));
%     
%     gm = c12(:,:,:,1)>0.8;
%     wm = c12(:,:,:,2)>0.9;
%     fprintf(fid,'%0.2f \t %0.2f \t', mean(Y(gm&roi1)), mean(Y(wm&roi1)) );
%     fprintf(fid,'%0.2f \t %0.2f \t', mean(Y(gm&roi2)), mean(Y(wm&roi2)) );
%     
%     
%     P = my_spm_select('FPlist',PAR.subject(sb).asldir{3},'^wFNIRT.*meanCBF.*nii');
%     c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{3},'^wFNIRT.*c[12].*nii');
%     
%     Y = spm_read_vols(spm_vol(P));
%     c12 = spm_read_vols(spm_vol(c12loc));
%     gm = c12(:,:,:,1)>0.8;
%     wm = c12(:,:,:,2)>0.9;
%     fprintf(fid,'%0.2f \t %0.2f \t', mean(Y(gm&roi1)), mean(Y(wm&roi1)) );
%     fprintf(fid,'%0.2f \t %0.2f \t', mean(Y(gm&roi2)), mean(Y(wm&roi2)) );
%     
%     fprintf(fid,'\n');
%     
%     
% end




fid = fopen('Global_ROIdata.xls','w');

vascloc = spm_select('FPlist',PAR.codepath,'^mni_vascular_territories_2mm.nii');
vasc = spm_read_vols(spm_vol(vascloc));
roi1 = (vasc ==4) | (vasc ==14) | (vasc==2) | (vasc==12);
roi2 = (vasc ==6) | (vasc ==16) ;

fprintf(fid,'SUBID \t SL_Global \t SL_Anterior_GM \t SL_Anterior_WM \t Anterior Global\t SL_Posterior_GM \t SL_Posterior_WM \t SL_Posterior Global\t');
fprintf(fid,'LL_Global \t LL_Anterior_GM \t LL_Anterior_WM \t LL_Anterior Global \t LL_Posterior_GM \t LL_Posterior_WM \t LL_Posterior Global\n');
for sb = 1:25%PAR.nsubs
%     if sb>=2 && strcmp(PAR.subject(sb).subid,PAR.subject(sb-1).subid)
%         continue;
%     end
%     
    

    fprintf(fid,'%s\t',PAR.subject(sb).subid);

    P = my_spm_select('FPlist',PAR.subject(sb).asldir{1},'^wFNIRT.*meanCBF.*nii');
    c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{1},'^wFNIRT.*c[12].*nii');
    
    Y = spm_read_vols(spm_vol(P));
    c12 = spm_read_vols(spm_vol(c12loc));
    
    gm = c12(:,:,:,1)>0.8;
    wm = c12(:,:,:,2)>0.9;
    wb = sum(c12,4) > 0.75;
    fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(wb)), mean(Y(gm&roi1)), mean(Y(wm&roi1)),mean(Y(wb&roi1)) );
    fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(gm&roi2)), mean(Y(wm&roi2)),mean(Y(wb&roi2)) );
    
    
    P = my_spm_select('FPlist',PAR.subject(sb).asldir{3},'^wFNIRT.*meanCBF.*nii');
    c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{3},'^wFNIRT.*c[12].*nii');
    
    Y = spm_read_vols(spm_vol(P));
    c12 = spm_read_vols(spm_vol(c12loc));
    gm = c12(:,:,:,1)>0.8;
    wm = c12(:,:,:,2)>0.9;
    wb = sum(c12,4) > 0.75;
    fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(wb)), mean(Y(gm&roi1)), mean(Y(wm&roi1)),mean(Y(wb&roi1)) );
    fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(gm&roi2)), mean(Y(wm&roi2)),mean(Y(wb&roi2)) );
    
    fprintf(fid,'\n');
    
    
end

