function vis_raw_skel(Iraw,skel,node,imagepath)
% Creates a tiff image of the raw data, with the skeleton overlaid upon it.

red = Iraw;
green = red;
blue = red;

red(skel) = 0;
green(skel) = intmax(class(red));
blue(skel) = 0;

green(node) = 0;
red(node) = 0;
blue(node) = intmax(class(red));

new_img = cat(4,red,green,blue);

new_img = permute(new_img,[1,2,4,3]); % rearrange dimensions for rgb tif output
imwrite(new_img(:,:,:,1), imagepath);
for i = 2:size(new_img,4)
    imwrite(new_img(:,:,:,i), imagepath, 'writemode', 'append');
end
