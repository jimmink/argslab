function writetiff_bin(img,filename)
% WRITETIFF_BIN is a very simple script outputting a tiff image stack.

imwrite(img(:,:,1), filename)
for i = 2:size(img,3)
    imwrite(img(:,:,i), filename, 'writemode', 'append');
end
