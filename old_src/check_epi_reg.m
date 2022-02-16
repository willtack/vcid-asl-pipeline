function check_epi_reg(outputname, regoutputimg)
% Usage:
% check_epi_reg(outptutname, regoutputimg)
% Info:
% Displays a three-view projection of the first resliced image 
% ([outputname '.nii.gz']) that has been registered to the anatomical 
% dataset using EPI_REG, with the WM edge used in the boundary-based (bb) 
% cost function employed overlayed ([outputname '_fast_wmedge.nii.gz']).
% The image is saved in the path specified by regoutputimg.
% The function uses SPM functions to read the images.

%% Read output EPI_REG image (registered to anat)
regimgname = [outputname, '.nii.gz'];
regimg = spm_read_niigz_vol(regimgname);
regimg = regimg / max(regimg(:));
regimg(regimg(:)<0) = 0;

%% Read WM edge created by EPI_REG
wmedgename = spm_select('FPlist',spm_str_manip(outputname,'H'),'_fast_wmedge.nii.gz');
wmedgeimg  = spm_read_niigz_vol(wmedgename);

%% Find image dimensions and calculate middle slice for SAG/COR/TRA views
dim = size(regimg);
midsli = round(dim./2);

%% Flip images A-P to be displayed correctly
regimg = regimg(:,end:-1:1,:,:);
wmedgeimg = wmedgeimg(:,end:-1:1,:,:);

%% Find slices with maximum intensity voxels for SAG/COR/TRA views 
% (alternate display)
% MIP = maximum intensity projection
mipsli = zeros(size(midsli));
for idim = 1:3
    Nslices = dim(idim);
    maxI = zeros(Nslices,1);
    for islice = 1:Nslices
        switch idim
            case 1
                curslice = regimg(islice,:,:);
            case 2
                curslice = regimg(:,islice,:);
            case 3
                curslice = regimg(:,:,islice);
        end
        maxI(islice) = sum(squeeze(curslice(:)));        
    end
    mipsli(idim) = find(maxI == max(maxI),1);
end


%% Concatenate the views to form a 2x3 image
% imgRGB = 
% ----------------------------------------------------------------------- %
%         MIDSLI.SAG          MIDSLI.COR              MIDSLI.TRA          %
%         dim(3) x dim(2)     dim(3) x dim(1)         dim(2) x dim(1)     %
%                                                                         %
%         MIPSLI.SAG          MIPSLI.COR              MIPSLI.TRA          %
%         dim(3) x dim(2)     dim(3) x dim(1)         dim(2) x dim(1)     %
% ------------------------------------------------------------------------%

imgRGB = zeros(max(dim(2:3)) * 2, dim(1)*2 + dim(2), 3); 

for itypedim = 1:2
    switch itypedim
        case 1
            sliceidx = midsli;
            r_offset = 0;
        case 2
            sliceidx = mipsli;
            r_offset = max(dim(2:3));
    end
    
    midsag.reg = regimg(sliceidx(1),:,:,1);
    midcor.reg = regimg(:,sliceidx(2),:,1);
    midtra.reg = regimg(:,:,sliceidx(3),1);
    %
    midsag.wmedge = wmedgeimg(sliceidx(1),:,:,1);
    midcor.wmedge = wmedgeimg(:,sliceidx(2),:,1);
    midtra.wmedge = wmedgeimg(:,:,sliceidx(3),1);
    
    %
    img3D = zeros(max(dim(2:3)), dim(1)*2 + dim(2));
    img3D(1:dim(3), 1:dim(2))               = flipud(squeeze(midsag.reg)');
    img3D(1:dim(3), dim(2)+1:dim(2)+dim(1)) = flipud(squeeze(midcor.reg)');
    img3D(1:dim(2), dim(2)+dim(1)+1:end)    = squeeze(midtra.reg)';

    img3Dwmedge = zeros(size(img3D(:,:,1)));
    img3Dwmedge(1:dim(3), 1:dim(2))               = flipud(squeeze(midsag.wmedge)');
    img3Dwmedge(1:dim(3), dim(2)+1:dim(2)+dim(1)) = flipud(squeeze(midcor.wmedge)');
    img3Dwmedge(1:dim(2), dim(2)+dim(1)+1:end)    = squeeze(midtra.wmedge)';

    
    %Red channel
    img3D(img3Dwmedge(:) == 1) = 0;    
    imgRGB( (r_offset + 1):(r_offset + max(dim(2:3))),:,1) = img3D;
    %Green channel
    img3D(img3Dwmedge(:) == 1) = 1;    
    imgRGB( (r_offset + 1):(r_offset + max(dim(2:3))),:,2) = img3D;
    %Blue channel
    img3D(img3Dwmedge(:) == 1) = 0;    
    imgRGB( (r_offset + 1):(r_offset + max(dim(2:3))),:,3) = img3D;

end

h1=figure('units','normalized','position',[ 0 0 1 1]);
imagesc(imgRGB); axis off
saveas(h1,regoutputimg);
close(h1);

end %function