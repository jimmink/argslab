%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PREPARATION SUPERLOOP %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is a project loop that performs the preparation to skeletonization.

function [Ifl, Iraw, Ibin] = project_prep(a,filepaths,zframes,sigmablur,binThres,switch_outputlabeling,switch_optimizationtools,sesizeX,sesizeY,sesizeZ,minfrac,particlediameter,realpxX,realpxY,realpxZ,h_fill_thr)

    %% skeletonization macroloop

    path = filepaths{a};
    sesize = [sesizeX,sesizeY,sesizeZ];
    realpx = [realpxX,realpxY,realpxZ];
    
    %% Import TIF stack
    
    [pathstr, fname, extension] = fileparts(path);
    if ~strcmp(extension,'.tif')
        path = [pathstr, filesep, fname, '.tif'];
        [It, ~] = tifread(path);
        movefile(path, [pathstr, filesep, 'Output', filesep, fname, filesep, fname, '.tif']);
    else
        [It, ~] = tifread(path);
    end
    
    if strcmp(zframes,'all') == 1
        zframes = size(It,3);
    end
    I(:,:,:) = It(:,:,size(It,3)-zframes+1:size(It,3));

    %% Preprocessing

    % Save for later visualization
    Iraw = I;

    % Perform 3D Gaussian blurring, reducing noise at the signal/no
    % signal interface. Such noise causes the skeletonization step to
    % find non-existent side chains. 
    if sigmablur > 0
        Iblur = imgaussfilt3(I,sigmablur); 
    else 
        Iblur = I;
    end

    % Binarize the blurred image.
    [Ibin, ~, ~, ~] = binarize(Iblur,binThres,path,switch_outputlabeling, switch_optimizationtools);
        
    clear I

    % Morphological closing step.
	if ~any(sesize==0)
        Icl = imclose(Ibin,create_ellipsoid(sesize,particlediameter,realpx)); 
    else
        Icl = Ibin;
	end

    % Remove small clusters using a threshold $minfrac$, removing clusters smaller than $minfrac$*largestcluster.
    [Iso,~] = smallout(Icl,26,minfrac,switch_outputlabeling);

    % Fill the holes inside the gelated structure.
    Ifl = fill_holes(Iso, h_fill_thr, particlediameter, realpx);

    close all

end
