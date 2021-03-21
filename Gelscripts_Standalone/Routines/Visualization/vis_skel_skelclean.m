function vis_skel_skelclean(skel,skel_raw,imagepath)
% Creates a tiff image of the difference between a cleaned and a raw 
% skeleton, the deleted bits in red.

red = uint8(skel_raw)*256;
blue = uint8(skel)*256;
green = blue;

new_img = cat(4,red,green,blue);

new_img = permute(new_img,[1,2,4,3]); % rearrange dimensions for rgb tif output
imwrite(new_img(:,:,:,1), imagepath);
for i = 2:size(new_img,4)
    imwrite(new_img(:,:,:,i), imagepath, 'writemode', 'append');
end
