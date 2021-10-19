clear

PAR = setparameter;

fid = fopen('TSNR_SISvsMIS.xls','w');

fprintf(fid,'SUBID\tGM SIS\tWM SIS\tGlobal SIS\t');
fprintf(fid,'GM MIS\tWM MIS\tGlobal MIS\n');

for sb = [1:26,28:30,32:38,40:PAR.nsubs]
    if isempty(PAR.subject(sb).asldir)
        continue;
    end
    if isempty(PAR.subject(sb).asldir{2})|| isempty(PAR.subject(sb).asldir{3})
        continue;
    end
    
    fprintf(fid,'%s\t',PAR.subject(sb).subid);
    
    for ses = [2,3]
        P = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^cbf_0_r.*nii');
        c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{ses},'^rbk_c[12].*nii');
        Y = spm_read_vols(spm_vol(P));
        c12 = spm_read_vols(spm_vol(c12loc));
        gm = c12(:,:,:,1)>0.9;
        wm = c12(:,:,:,1)>0.99;
        wb = sum(c12,4)>0.8;
        
        CBF = [];
        for t = 1:size(Y,4)
            tmp = Y(:,:,:,t);
            CBF = [CBF;[mean(tmp(gm)),mean(tmp(wm)),mean(tmp(wb))]];
        end
        
        tsnr = mean(CBF)./std(CBF);
        for t = 1:length(tsnr)
            fprintf(fid,'%0.2f\t',tsnr(t));
        end
    end
    fprintf(fid,'\n');
end

fclose(fid);


