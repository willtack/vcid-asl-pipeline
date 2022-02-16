clear

PAR = setparameter;
% batch_segment(PAR);
% batch_create_mask(PAR);
% batch_fnirt(PAR);
% batch_fnirt_inverse_mapping(PAR);
% batch_MNI_2_sub_masks(PAR);
% 
% 


%%% Extract ROI CBF
% fid = fopen('PV125ROICBF_vent99_Oct2.xls','w');
% for sb = 1:PAR.nsubs
%     fprintf(fid,'%s\t',PAR.subject(sb).subid);
%     roiloc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^PVCBF125.*.nii');
%     roiorig = spm_read_vols(spm_vol(roiloc));
%     c3loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^c3.*.nii');
%     c3 = spm_read_vols(spm_vol(c3loc));
%     roi = (roiorig - c3>0.99)>0;
%     for s = 1:6
%         P = my_spm_select('FPlist',PAR.subject(sb).asldir{s},'^r.*nii');
%         if size(P,1)~=1
%             error('Some problem');
%         end
%         Y = spm_read_vols(spm_vol(P));
%         fprintf(fid,'%f\t',median(Y(roi)));
%     end
%     fprintf(fid,'\n');
% end
% 
% fclose(fid);

%%% Extract GM Global CBF

fid = fopen('Global_thresh85_Nov14.xls','w');
for sb = 1:PAR.nsubs
    fprintf(fid,'%s\t',PAR.subject(sb).subid);    
    c1loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^c1.*.nii');
    c1 = spm_read_vols(spm_vol(c1loc));
    c2loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^c2.*.nii');
    c2 = spm_read_vols(spm_vol(c2loc));
    roi = (c1 + c2 )>0.85;
    for s = 1:6
        P = my_spm_select('FPlist',PAR.subject(sb).asldir{s},'^r.*nii');
        if size(P,1)~=1
            error('Some problem');
        end
        Y = spm_read_vols(spm_vol(P));
        fprintf(fid,'%f\t',mean(Y(roi & (Y~=0))));
    end
    fprintf(fid,'\n');
end

fclose(fid);