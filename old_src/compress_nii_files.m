function compress_nii_files(pth)

if isempty(pth)
    return;
end
files = spm_select('FPlist',pth,'.*.nii$');
for s = 1:size(files,1)
    tmp = deblank(files(s,:));
    tmp = strrep(tmp,' ','\ ');
    system(['gzip -f ' tmp]);
end