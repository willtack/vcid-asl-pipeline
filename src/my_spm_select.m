function files = my_spm_select(str,pth,filestr)

if length(filestr)>=3 && strcmp(filestr(end-2:end),'nii')
    files1 = spm_select('FPlist',pth,[filestr '$']);
    files2 = spm_select('FPlist',pth,[filestr '.gz$']);
else
    files1 = spm_select('FPlist',pth,[filestr '.*nii$']);
    files2 = spm_select('FPlist',pth,[filestr '.*nii.gz$']);
end

if isempty(files1)
    for s = 1:size(files2,1)
        gunzip(deblank(files2(s,:)));
    end
else
    for s = 1:size(files2,1)
        filename = files2(s,1:end-3);
        flag = 0;
        for t = 1:length(files1)
            if strfind(files1(t,:),filename)
                flag = 1;
                break;
            end
        end
        if flag==0
            gunzip(deblank(files2(s,:)));
        end
    end
    
end


if length(filestr)>=3 && strcmp(filestr(end-2:end),'nii')
    files = spm_select(str,pth,[filestr '$']);
else
    files = spm_select(str,pth,[filestr '.*nii$']);
end
