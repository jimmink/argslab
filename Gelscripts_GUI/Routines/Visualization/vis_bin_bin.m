function vis_bin_bin(Ibin,Ifl,imagepath)
% Creates a tiff image of the raw data, overlaid with green if it was 
% determined above the threshold, and red if below.

blue = 255 * uint8((Ibin + Ifl)==2);
green = 255 * uint8(Ifl);
red = 255 * uint8(Ibin);
diffv = Ibin - Ifl;
green(diffv == -1) = 255;
red(diffv == 1) = 255;

new_img = cat(4,red,green,blue);
new_img = permute(new_img,[1,2,4,3]); % rearrange dimensions for rgb tif output
imwrite(new_img(:,:,:,1), imagepath);
for i = 2:size(new_img,4)
    imwrite(new_img(:,:,:,i), imagepath, 'writemode', 'append');
end
