function vis_skel_cleaning(Iraw,skel,node,skel_raw,node_raw,imagepath)
% Creates a tiff image where the skeletonization is overlaid with the
% binarized image.

red = Iraw;
green = red;
blue = red;

node_raw(node==1) = 0;
skel_raw(skel==1) = 0;

red(skel) = 0;
green(skel) = 255;
blue(skel) = 0;

red(skel_raw) = 255;
green(skel_raw) = 0;
blue(skel_raw) = 0;

red(node) = 0;
green(node) = 0;
blue(node) = 255;

red(node_raw) = 200;
green(node_raw) = 0;
blue(node_raw) = 200;



new_img = cat(4,red,green,blue);

new_img = permute(new_img,[1,2,4,3]); % rearrange dimensions for rgb tif output
imwrite(new_img(:,:,:,1), imagepath);
for i = 2:size(new_img,4)
    imwrite(new_img(:,:,:,i), imagepath, 'writemode', 'append');
end