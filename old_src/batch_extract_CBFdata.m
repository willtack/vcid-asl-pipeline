clear

PAR = setparameter;

fid = fopen('ExtractedData_May3.xls','w');

fprintf(fid,'\t\t');
for sesno = 1:length(PAR.subject(1).asldir)
    fprintf(fid,'%s\t',PAR.aslprefix{sesno});
    for s = 1:9
	fprintf(fid,'\t');
    end 
end
fprintf(fid,'\n');    

fprintf(fid,'SUBID \t Session \t GM CBF \t GM CV \t WM CBF \t WM CV \t GM/WM contrast \t PVWM15 CBF \t PVWM15 CV \t PVWM125 CBF \t PVWM125 CV\t');
for s = 1:4
    fprintf(fid,'GM CBF \t GM CV \t WM CBF \t WM CV \t GM/WM contrast \t PVWM15 CBF \t PVWM15 CV\t PVWM125 CBF \t PVWM125CV\t');
end
fprintf(fid,'\n');

for sb = 1:PAR.nsubs
    if length(PAR.subject(sb).asldir)==0
	continue;
    end

    c123loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^c[123].*nii');
    if isempty(c123loc)
	continue;
    end
    c1 = spm_read_vols(spm_vol(c123loc(1,:)));
    c2 = spm_read_vols(spm_vol(c123loc(2,:)));
    c3 = spm_read_vols(spm_vol(c123loc(3,:)));
   
    fprintf(fid,'%s\t',PAR.subject(sb).subid);

 
    pvCBF15loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^PVCBF15.*nii');
    pvCBF125loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^PVCBF125.*nii');
    pvcbf15 = spm_read_vols(spm_vol(pvCBF15loc))>0;
    pvcbf125 = spm_read_vols(spm_vol(pvCBF125loc))>0;
    
    if contains(lower(pvCBF15loc),'baseline')
	fprintf(fid,'Baseline\t');
    else
	fprintf(fid,'Followup\t');
    end
    for sesno = 1:length(PAR.subject(sb).asldir)
        if isempty(PAR.subject(sb).asldir{sesno})
            for s = 1:9
                fprintf(fid,'\t');
            end
            continue;
        end
        P = my_spm_select('FPlist',PAR.subject(sb).asldir{sesno},'^t1.*meanCBF.*nii');
        Y = spm_read_vols(spm_vol(P));
        
        gmCBF = Y(c1>0.9);
        wmCBF = Y(c2>0.995);
        
        fprintf(fid,'%0.2f\t',mean(gmCBF));
        fprintf(fid,'%0.2f\t',std(gmCBF)/mean(gmCBF));
        fprintf(fid,'%0.2f\t',mean(wmCBF));
        fprintf(fid,'%0.2f\t',std(wmCBF)/mean(wmCBF));
        
        fprintf(fid,'%0.2f\t',mean(gmCBF)/mean(wmCBF));
        
        pvCBF = Y((pvcbf15 - (c3>0.99))>0);
        fprintf(fid,'%0.2f\t',mean(pvCBF));
        fprintf(fid,'%0.2f\t',std(pvCBF)/mean(pvCBF));
        
        
        pvCBF = Y((pvcbf125 - (c3>0.99))>0);
        fprintf(fid,'%0.2f\t',mean(pvCBF));
        fprintf(fid,'%0.2f\t',std(pvCBF)/mean(pvCBF));
        
        
    end
    fprintf(fid,'\n');
    
end

fclose(fid);

%
%
%     for sb = 1:25%PAR.nsubs
%         %     if sb>=2 && strcmp(PAR.subject(sb).subid,PAR.subject(sb-1).subid)
%         %         continue;
%         %     end
%         %
%
%
%         fprintf(fid,'%s\t',PAR.subject(sb).subid);
%
%         P = my_spm_select('FPlist',PAR.subject(sb).asldir{1},'^wFNIRT.*meanCBF.*nii');
%         c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{1},'^wFNIRT.*c[12].*nii');
%
%         Y = spm_read_vols(spm_vol(P));
%         c12 = spm_read_vols(spm_vol(c12loc));
%
%         gm = c12(:,:,:,1)>0.8;
%         wm = c12(:,:,:,2)>0.9;
%         wb = sum(c12,4) > 0.75;
%         fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(wb)), mean(Y(gm&roi1)), mean(Y(wm&roi1)),mean(Y(wb&roi1)) );
%         fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(gm&roi2)), mean(Y(wm&roi2)),mean(Y(wb&roi2)) );
%
%
%         P = my_spm_select('FPlist',PAR.subject(sb).asldir{3},'^wFNIRT.*meanCBF.*nii');
%         c12loc = my_spm_select('FPlist',PAR.subject(sb).asldir{3},'^wFNIRT.*c[12].*nii');
%
%         Y = spm_read_vols(spm_vol(P));
%         c12 = spm_read_vols(spm_vol(c12loc));
%         gm = c12(:,:,:,1)>0.8;
%         wm = c12(:,:,:,2)>0.9;
%         wb = sum(c12,4) > 0.75;
%         fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(wb)), mean(Y(gm&roi1)), mean(Y(wm&roi1)),mean(Y(wb&roi1)) );
%         fprintf(fid,'%0.2f \t %0.2f \t %0.2f\t%0.2f\t', mean(Y(gm&roi2)), mean(Y(wm&roi2)),mean(Y(wb&roi2)) );
%
%         fprintf(fid,'\n');
%
%
%     end
%

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

% fid = fopen('Global_thresh85_Nov14.xls','w');
% for sb = 1:PAR.nsubs
%     fprintf(fid,'%s\t',PAR.subject(sb).subid);
%     c1loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^c1.*.nii');
%     c1 = spm_read_vols(spm_vol(c1loc));
%     c2loc = my_spm_select('FPlist',PAR.subject(sb).anatdir,'^c2.*.nii');
%     c2 = spm_read_vols(spm_vol(c2loc));
%     roi = (c1 + c2 )>0.85;
%     for s = 1:6
%         P = my_spm_select('FPlist',PAR.subject(sb).asldir{s},'^r.*nii');
%         if size(P,1)~=1
%             error('Some problem');
%         end
%         Y = spm_read_vols(spm_vol(P));
%         fprintf(fid,'%f\t',mean(Y(roi & (Y~=0))));
%     end
%     fprintf(fid,'\n');
% end
%
% fclose(fid);
