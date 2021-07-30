function vis_bin_raw(Iraw,Ibin,imagepath)
% Creates a tiff image of the raw data, overlaid with green if it was 
% determined above the threshold, and red if below.

red = zeros(size(Iraw),class(Iraw));
green = red;
blue = red;

red(Ibin==0) = Iraw(Ibin==0);
green(Ibin) = Iraw(Ibin);

new_img = cat(4,red,green,blue);
new_img = permute(new_img,[1,2,4,3]); % rearrange dimensions for rgb tif output
imwrite(new_img(:,:,:,1), imagepath);
for i = 2:size(new_img,4)
    imwrite(new_img(:,:,:,i), imagepath, 'writemode', 'append');
end
