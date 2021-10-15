function h = myimshow3D(img3D, n_cols, min_value, max_value)
% Usage:
% h = myimshow3D(img3D, n_cols, min_value, max_value)
% Info:
% img3D  = 3D matrix (nx x ny x nz) to be displayed in mosaic form
% n_cols = number of columns in the displayed mosaic
% [min_value, max_value] = intensity scale 
%                          If bit specified,m min/max = mean -/+ 3*SD

if ~exist('min_value','var')
    min_value = max(min(img3D(:)),mean(img3D(:)) - 3*std(img3D(:)));
end
if ~exist('max_value','var')
    max_value = min(max(img3D(:)),mean(img3D(:)) + 3*std(img3D(:)));
end
    


%Convert 3D image to 2D
img = permute(img3D,[2 1 3]);
img = img(end:-1:1,:,:); %flip in the row direction
n_slices = size(img,3);
n_rows = ceil(n_slices/n_cols);
if n_rows*n_cols > n_slices
    n_dif = n_rows*n_cols - n_slices;
    img(:,:,end+1:end+n_dif) = 0;                    
end
img2d = flipud(reshape(img, size(img,1), size(img,2)*size(img,3)));
img2dshow = zeros(size(img,1)*n_rows, size(img,2)*n_cols);
for irow = 1:n_rows
    I1r = 1 + (irow-1)*size(img,1);
    I2r = I1r + size(img,1) - 1;

    I1c = 1 + (irow-1)*n_cols*size(img,2);
    I2c = I1c + n_cols*size(img,2) - 1;
    img2dshow(I1r:I2r, :) = img2d(:, I1c:I2c);
end
    
%Plot
h=figure;
imagesc(img2dshow); colorbar
%imshow(img2dshow, [min_value max_value]), colorbar   
%set(h,'units','normalized','outerposition',[0 0 1 1])



end %function
