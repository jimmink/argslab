function [ Iout, bindata, surfdata, vis_image ] = binarize( I, binThres, path, switch_outputlabeling, switch_optimizationtools)
% BINARIZE binarizes a stack of images automatically, or with a set
% threshold, automatic threshold via Otsu's method is taken if binThres is 
% 'auto'. Otherwise the threshold is taken between the value of the 10% 
% lowest and highest intensities in the image.

[xImage,yImage,NumberImages] = size(I);
[pathstr, fname, ~] = fileparts(path);

Iout = zeros(xImage,yImage,NumberImages,'logical');

vis_image = zeros(xImage,yImage,NumberImages,'uint8');

HiLoFrac = 0.1;
tot2D = xImage*yImage;
HiLoFracAbs = round(HiLoFrac*tot2D);

if strcmp(binThres,'auto') == 1
	if strcmp(switch_outputlabeling,'yes') == 1
        disp('Binarizing images with Otsu''s method...')
	end
    bindata = zeros(NumberImages,4);
    bindata(:,1) = 1:NumberImages;
    for k = 1:NumberImages
        I2D = I(:,:,k);
        ValueRow = sort(I2D(:),'descend');
        avgHigh = mean(ValueRow(1:HiLoFracAbs));
        avgLow = mean(ValueRow(tot2D-HiLoFracAbs:tot2D));
        otsuthres = graythresh(I2D); % Otsu's method, Matlab in-built routine
        bindata(k,2:4) = [avgHigh,avgLow,otsuthres]; % Write statistics
        for i = 1:xImage
            for j = 1:yImage
                if I(i,j,k) <= otsuthres*255
                    Iout(i,j,k) = 0;
                else
                    Iout(i,j,k) = 1;
                end
            end
        end
    end
    
    % Feedback output
    if switch_optimizationtools == 1
        figure('Position',[0,300,500,400])
        hold on
        bindata(:,2:3) = bindata(:,2:3)/255;
        plot(bindata(:,1),bindata(:,2),bindata(:,1),bindata(:,3),bindata(:,1),bindata(:,4))
        title('Binarization intensity along z-axis')
        xlabel('slice (#)')
        ylabel('Normalized intensity')
        legend('90% intensity value (I_{90})','10% intensity value (I_{10})','Threshold Otsu''s method','Location','northwest')
        savefig([pathstr,'/Output/',fname,'/Intensity_alongz.fig']);
        hold off
    end
else
    if isnumeric(binThres) == 0
        error('Invalid threshold')
    end
    if switch_outputlabeling == 1
        fprintf('Binarizing images with %1.2f threshold...',binThres);
    end
    bindata = zeros(NumberImages,5);
    bindata(:,1) = 1:NumberImages;
    for k = 1:NumberImages
        I2D = I(:,:,k);
        ValueRow = sort(I2D(:),'descend');
        avgHigh = mean(ValueRow(1:HiLoFracAbs));
        avgLow = mean(ValueRow(tot2D-HiLoFracAbs:tot2D));
        realThres = (avgHigh - avgLow)*binThres + avgLow;
        if strcmp(switch_outputlabeling,'yes') == 1
            otsuthres = graythresh(I2D); % Otsu's method, for feedback output comparison
            bindata(k,2:5) = [avgHigh,avgLow,realThres,otsuthres]; % Write statistics
        else
            bindata(k,2:4) = [avgHigh,avgLow,realThres]; % Write statistics
        end
        for i = 1:xImage
            for j = 1:yImage
                if I(i,j,k) < realThres
                    Iout(i,j,k) = 0;
                else
                    Iout(i,j,k) = 1;
                end
            end
        end
        int_factor = (255 / 2) / realThres;
        vis_image(:,:,k) = I(:,:,k) * int_factor;
    end
    
    % Feedback output
    if switch_optimizationtools == 1
        figure('Position',[0,300,500,400])
        hold on
        bindata(:,2:4) = bindata(:,2:4)/255;
        plot(bindata(:,1),bindata(:,2),bindata(:,1),bindata(:,3),bindata(:,1),bindata(:,4),bindata(:,1),bindata(:,5))
        title('Binarization intensity along z-axis')
        xlabel('slice (#)')
        ylabel('Normalized intensity')
        legend('90% intensity value (I_{90})','10% intensity value (I_{10})','Set threshold','Threshold Otsu''s method','Location','northwest')
        savefig([pathstr,'/Output/',fname,'/Intensity_alongz.fig']);
        hold off
    end
end

%% Plot other output data, if demanded

% Determine fraction of filled in voxels

surfdata = zeros(NumberImages,2);
surfdata(:,1) = 1:NumberImages;
for k = 1:NumberImages
    Icount = 0;
    for i = 1:xImage
        for j = 1:yImage
            if Iout(i,j,k) == 0
            else
               Icount = Icount + 1;
            end
        end
    end
    surfdata(k,2) = Icount;
end

if switch_optimizationtools == 1
    figure('Position',[520,300,500,400])
    hold on
    surfdata(:,2) = surfdata(:,2)/tot2D;
    plot(surfdata(:,1),surfdata(:,2))
    title('Fraction of voxels filled in after binarization, per slice')
    xlabel('slice (#)')
    ylabel('Fraction of voxels filled in')
    axis([-inf inf 0 1])
    savefig([pathstr,'/Output/',fname,'/Filledvoxels_alongz.fig']);
    hold off
end

end

