function [ Iout, tInfo ] = tifread( path )
% TIFREAD converts a single channel tif file into an array.
% Array is defined as (:,:,i) the ith image. Image properties are outputted
% in tInfo.
    
tInfo = imfinfo(path);
mImage = tInfo(1).Width;
nImage = tInfo(1).Height;
NumberImages = length(tInfo);
bitdepth = tInfo(1).BitDepth;
if bitdepth == 1
    Iout = zeros(nImage,mImage,NumberImages,'logical');
elseif bitdepth == 8
    Iout = zeros(nImage,mImage,NumberImages,'uint8');
elseif bitdepth == 24
    Iout = zeros(nImage,mImage,NumberImages,'uint8');
    disp('Input image is RGB, and it is strongly recommended to use greyscale images. Importing flattened image...')
end
    
warning('off','imageio:tiffmexutils:libtiffWarning')

TifLink = Tiff(path,'r');

if ~(bitdepth == 24)
    for i = 1:NumberImages
        TifLink.setDirectory(i);
        Iout(:,:,i) = TifLink.read();
    end
else
	for i = 1:NumberImages
        TifLink.setDirectory(i);
        Iout(:,:,i) = mean(TifLink.read(),3);
	end
end
TifLink.close();

Iout = permute(Iout,[2,1,3]);

% If converted from simulation, and therefore logical, invert; take this
% step away after finishing simulation conversion script.
if bitdepth == 1
    Iout(:,:,:) = ~Iout(:,:,:);
end

warning('on','imageio:tiffmexutils:libtiffWarning')

end