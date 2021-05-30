function readnplay(filename,projectpath)
% Reads and plays image stacks and bypasses issues with importing tiff
% stacks that implay has.

if ~isfile(filename)
    warning('The file %s does not exist',filename)
end

[~,fname,ext] = fileparts(filename);
if strcmp(ext,'.txt') || strcmp(ext,'.xyz') 
    filename = [projectpath,filesep,'Output',filesep,fname,filesep,fname,'.tif'];
end

switch ext
    case '.fig'
        openfig(filename)
    case '.png' % for some reason, matlab cannot read the background color in the png imgaes, thus we set it manually
        Im = imread(filename, 'BackgroundColor', 'none') ; % read in first image
        openNonFig(Im,1)
    otherwise % tiff stacks, etc.
        I_info = imfinfo(filename); % return tiff structure, one element per image
        if strcmp(fname,'Rawimage_binarized') || strcmp(fname,'Rawimage_uncleaned-skeleton') || ...
                strcmp(fname,'Rawimage_skeletoncleaning') || strcmp(fname,'Rawimage_skeleton')
            Im = imread(filename, 1);
            for i = 2:size(I_info,1)
                Im(:,:,:,i) = imread(filename, i);
            end
        else
            Im = imread(filename, 1) ; % read in image
        end        
        openNonFig(Im,numel(I_info),I_info,filename)
end

end


function openNonFig(Im,N,varargin)
if nargin > 2
    I_info = varargin{1};
    fn = varargin{2};
end

    if N == 1
        imshow(rescale(Im));
    else
        if contains(fn,'Rawimage_binarized.tif') || contains(fn,'Rawimage_uncleaned-skeleton') || ...
                contains(fn,'Rawimage_skeletoncleaning') || contains(fn,'Rawimage_skeleton')
            I = Im;
        elseif ismatrix(Im)
            I = zeros([size(Im) N]);
            I(:,:,1) = Im;
            for ii = 2:size(I_info, 1)
                I(:,:,ii) = imread(fn, ii);
            end
            I = rescale(I); % rescale intensity for visualization
        elseif ndims(Im) == 3
            I = zeros([size(Im) N]);
            I(:,:,:,1) = Im;
            for ii = 2:size(I_info, 1)
                I(:,:,:,ii) = imread(fn, ii);
            end
        else
            error('Unsupported dimensionality. Found %i.',ndims(I))
        end
        implay(I)
    end

end

