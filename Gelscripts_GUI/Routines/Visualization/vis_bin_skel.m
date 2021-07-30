function vis_bin_skel(skel,node,Ifl,imagepath)
% Creates a tiff image where the skeletonization is overlaid with the
% binarized image.

green = 255*uint8(Ifl);
blue = green;
red = green;

red(skel) = 0;
blue(skel) = 0;
green(skel) = 255;

red(node) = 0;
green(node) = 0;
blue(node) = 255;

new_img = cat(4,red,green,blue);

new_img = permute(new_img,[1,2,4,3]); % rearrange dimensions for rgb tif output
imwrite(new_img(:,:,:,1), imagepath);
for i = 2:size(new_img,4)
    imwrite(new_img(:,:,:,i), imagepath, 'writemode', 'append');
end