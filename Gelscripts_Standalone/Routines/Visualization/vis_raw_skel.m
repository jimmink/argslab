function vis_raw_skel(Iraw,skel,node,imagepath)
% Creates a tiff image of the raw data, with the skeleton overlaid upon it.

skel_new = zeros(size(skel),'logical');
% for i = 1:size(skel,3)
%     if i == 1
%         skel_new(:,:,i) = max(skel(:,:,i:i+3),[],3);
%     elseif i == 2
%         skel_new(:,:,i) = max(skel(:,:,i-1:i+3),[],3);
%     elseif i == 3
%         skel_new(:,:,i) = max(skel(:,:,i-2:i+3),[],3);
% 	elseif i == size(skel_new,3)-2
%         skel_new(:,:,i) = max(skel(:,:,i-3:i+2),[],3);
%     elseif i == size(skel_new,3)-1
%         skel_new(:,:,i) = max(skel(:,:,i-3:i+1),[],3);
%     elseif i == size(skel_new,3)
%         skel_new(:,:,i) = max(skel(:,:,i-3:i),[],3);
%     else
%         skel_new(:,:,i) = max(skel(:,:,i-3:i+3),[],3);
%     end
% end

red = Iraw;
green = red;
blue = red;

red(skel_new) = 0;
green(skel_new) = intmax(class(red));
blue(skel_new) = 0;

green(node) = 0;
red(node) = 0;
blue(node) = intmax(class(red));

new_img = cat(4,red,green,blue);

new_img = permute(new_img,[1,2,4,3]); % rearrange dimensions for rgb tif output
imwrite(new_img(:,:,:,1), imagepath);
for i = 2:size(new_img,4)
    imwrite(new_img(:,:,:,i), imagepath, 'writemode', 'append');
end
