function [img, v] = spm_read_niigz_vol(niigzvol)

[path,filename,ext] = fileparts(niigzvol);
if strcmp(ext,'.gz')
    %unzip    
    gunzip(niigzvol);    
    %read
    v = spm_vol(fullfile(path, filename));
    img = spm_read_vols(v);
    %remove unzipped file
    delete(fullfile(path,filename));
else
    v = spm_vol(niigzvol);
    img = spm_read_vols(v);
end
    
end %function