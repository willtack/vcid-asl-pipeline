function batch_create_mask(PAR,indx)


fprintf('------------------------------------------------------------------')
fprintf('\nCREATING MASKS FROM MPRAGE IMAGES\n');
fprintf('------------------------------------------------------------------\n\n')


if nargin<2
    indx = 1:PAR.nsubs;
end

for subno=indx
    try
        
        PP=spm_select('FPlist',PAR.subject(subno).anatdir,'^mask');
        if ~isempty(PP)
            continue;
        end

	fprintf('Creating Mask for %s, # %d/%d\n',PAR.subject(subno).subid,subno,PAR.nsubs);
        
        c123 = spm_select('FPlist',PAR.subject(subno).anatdir,'^c[123].*.nii$');
        if isempty(c123)
            c123 = spm_select('FPlist',PAR.subject(subno).anatdir,'^c[123].*.nii.gz$');
            for k=1:size(c123,1)
                gunzip(deblank(c123(k,:)));
            end
            c123 = spm_select('FPlist',PAR.subject(subno).anatdir,'^c[123].*.nii$');
            
        end
        
        sc1 = fullfile(PAR.subject(subno).anatdir,['s' spm_str_manip(c123(1,:),'t')]);
        sc2 = fullfile(PAR.subject(subno).anatdir,['s' spm_str_manip(c123(2,:),'t')]);
        sc3 = fullfile(PAR.subject(subno).anatdir,['s' spm_str_manip(c123(3,:),'t')]);
        spm_smooth(c123(1,:),sc1,[5 5 5]);
        spm_smooth(c123(2,:),sc2,[5 5 5]);
        spm_smooth(c123(3,:),sc3,[5 5 5]);
        
        img_c1 = spm_read_vols(spm_vol(sc1));
        img_c2 = spm_read_vols(spm_vol(sc2));
        img_c3 = spm_read_vols(spm_vol(sc3));
        
        threshold = 0.1;
        mask  = double(((img_c1+img_c2) >= threshold)& ((img_c1 >= threshold) | (img_c2 >= threshold)));
        
        n_passes = 3;
        mask = fill_in_holes_inside_brain(mask,n_passes);
        
        
        v = spm_vol(sc1);
        v.fname=fullfile(PAR.subject(subno).anatdir,['mask_' PAR.anatprefix '_' PAR.subject(subno).subid '.nii']);
        spm_write_vol(v,mask);
        
        
        
        sc = spm_select('FPlist',PAR.subject(subno).anatdir,'^sc[123]');
        for k =1: size(sc,1)
            delete(deblank(sc(k,:)));
        end
        
        
        P = spm_select('FPlist',PAR.subject(subno).anatdir,['^m' PAR.anatprefix '.*nii$']);
        if isempty(P)
            P = spm_select('FPlist',PAR.subject(subno).anatdir,['^m' PAR.anatprefix '.*nii.gz$']);
            gunzip(deblank(P));
            P = spm_select('FPlist',PAR.subject(subno).anatdir,['^m' PAR.anatprefix '.*nii$']);
        end
        
        v = spm_vol(P);
        Y=spm_read_vols(v);
        Y(mask==0)=0;
        v.fname = fullfile(PAR.subject(subno).anatdir,['skullstripped_' spm_str_manip(P,'tr') '.nii']);
        spm_write_vol(v,Y);
        
        compress_nii_files(PAR.subject(subno).anatdir);
    catch ERROR
        fid = fopen(['batch_create_mask_errors_' PAR.subject(subno).subid '.txt'],'w');        
        fprintf(fid,'Error in creating mask in %s\n', PAR.subject(subno).anatdir);
        fprintf(fid,'%s\n',ERROR.message);
        fclose(fid);
    end
    
end
