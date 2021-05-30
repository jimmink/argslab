%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TORTUOSITY SUPERLOOP %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tort_data,shortestpaths,dtortuosity,dxpath,dypath,dzpath,dxeucl,dyeucl,dzeucl,dxtortuosity,dytortuosity,dztortuosity] = project_tortuosity(a,Apath,node,skel,realpx,particlediameter,edgenode_dist,tort_data,shortestpaths,dtortuosity)

    %% get all the skeletons

    G = makeGraphobj(Apath);
    [dxpath, dypath, dzpath, dxeucl, dyeucl, dzeucl, dxtortuosity, dytortuosity, dztortuosity] = tortuosity( G, node, skel, realpx , particlediameter, edgenode_dist);

    shortestpaths_x = size(dxtortuosity,1) + size(dxtortuosity,2);
    for i = 1:size(dxtortuosity,1)
        shortestpaths_x(i) = min(dxtortuosity(i,:));
    end
    for j = 1:size(dxtortuosity,2)
        shortestpaths_x(i + j) = min(dxtortuosity(:,j));
    end
    shortestpaths_x = unique(shortestpaths_x(shortestpaths_x ~= 0));

    shortestpaths_y = size(dytortuosity,1) + size(dytortuosity,2);
    for i = 1:size(dytortuosity,1)
        shortestpaths_y(i) = min(dytortuosity(i,:));
    end
    for j = 1:size(dytortuosity,2)
        shortestpaths_y(i + j) = min(dytortuosity(:,j));
    end
    shortestpaths_y = unique(shortestpaths_y(shortestpaths_y ~= 0));

    shortestpaths_z = size(dztortuosity,1) + size(dztortuosity,2);
    for i = 1:size(dztortuosity,1)
        shortestpaths_z(i) = min(dztortuosity(i,:));
    end
    for j = 1:size(dztortuosity,2)
        shortestpaths_z(i + j) = min(dztortuosity(:,j));
    end
    shortestpaths_z = unique(shortestpaths_z(shortestpaths_z ~= 0));

    dxtortuosity = reshape(dxtortuosity,[],1);
    dytortuosity = reshape(dytortuosity,[],1);
    dztortuosity = reshape(dztortuosity,[],1);
    dxtortuosity = dxtortuosity(~any(isinf(dxtortuosity),2));
    dytortuosity = dytortuosity(~any(isinf(dytortuosity),2));
    dztortuosity = dztortuosity(~any(isinf(dztortuosity),2));
    dtortuosity(a,1) = mean(dxtortuosity(:));
    dtortuosity(a,2) = mean(dytortuosity(:)); 
    dtortuosity(a,3) = mean(dztortuosity(:));
    tort_data(a,1) = mean(dtortuosity(a,:));
    tort_data(a,2) = std(dtortuosity(a,:));
    if ~isempty(shortestpaths_x)
        shortestpaths(a,1) = min(shortestpaths_x);
    end
    if ~isempty(shortestpaths_y)
        shortestpaths(a,2) = min(shortestpaths_y);
    end
    if ~isempty(shortestpaths_z)
        shortestpaths(a,3) = min(shortestpaths_z);
    end

end