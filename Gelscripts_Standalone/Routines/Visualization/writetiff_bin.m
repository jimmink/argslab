function writetiff_bin(img,filename)

imwrite(img(:,:,1), filename)
for i = 2:size(img,3)
    imwrite(img(:,:,i), filename, 'writemode', 'append');
end
