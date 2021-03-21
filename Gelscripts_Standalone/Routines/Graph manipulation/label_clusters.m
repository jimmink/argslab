function output = label_clusters(linkvoxels,nodeidx,sizes)
% LABEL_CLUSTERS creates a cube that encompasses all nodeidx, and then
% assigns an id to all clusters of connected voxels. The output is a list 
% of linear indices, with in its second column a cluster-id. Assumes 
% 27-connectivity.

    % creates the cube with all nodeidx voxels as "Inf"
    [~,~,lnkvx_locs] = intersect(linkvoxels,nodeidx);
    [allvox_x,allvox_y,allvox_z] = ind2sub(sizes,nodeidx);

    allvx_min_x = min(allvox_x);
    allvx_min_y = min(allvox_y);
    allvx_min_z = min(allvox_z);
    allvox_x = allvox_x - allvx_min_x + 1;
    allvox_y = allvox_y - allvx_min_y + 1;
    allvox_z = allvox_z - allvx_min_z + 1;

    lnkvx_x = allvox_x(lnkvx_locs);
    lnkvx_y = allvox_y(lnkvx_locs);
    lnkvx_z = allvox_z(lnkvx_locs);

    nodecube = zeros(max(allvox_x),max(allvox_y),max(allvox_z));
    for j = 1:size(lnkvx_x,1)
        nodecube(lnkvx_x(j),lnkvx_y(j),lnkvx_z(j)) = Inf;
    end
    nodecube(lnkvx_x(1),lnkvx_y(1),lnkvx_z(1)) = 1;
    
    % Replaces all "Inf" with a cluster id starting from 1
    nodecube = padarray(nodecube,[1 1 1]);
    prev_locs_x = lnkvx_x(1) + 1;
    prev_locs_y = lnkvx_y(1) + 1;
    prev_locs_z = lnkvx_z(1) + 1;
    current_cluster = 1;
    
    while ~isempty(prev_locs_x)
        surrounding = nodecube(prev_locs_x(1)-1:prev_locs_x(1)+1,prev_locs_y(1)-1:prev_locs_y(1)+1,prev_locs_z(1)-1:prev_locs_z(1)+1);
        [x,y,z] = ind2sub([3,3,3],find(surrounding == Inf));
        x = x + prev_locs_x(1) - 2;
        y = y + prev_locs_y(1) - 2;
        z = z + prev_locs_z(1) - 2;
        for j = 1:size(x,1)
            nodecube(x(j),y(j),z(j)) = current_cluster;
        end
        prev_locs_x = vertcat(prev_locs_x,x);
        prev_locs_y = vertcat(prev_locs_y,y);
        prev_locs_z = vertcat(prev_locs_z,z);
        prev_locs_x(1) = [];
        prev_locs_y(1) = [];
        prev_locs_z(1) = [];
        if isempty(prev_locs_x)
            current_cluster = current_cluster + 1;
            if max(nodecube==Inf,[],'all') == 1
                [x,y,z] = ind2sub(size(nodecube),find(nodecube==Inf));
                prev_locs_x = x(1);
                prev_locs_y = y(1);
                prev_locs_z = z(1);
                nodecube(x(1),y(1),z(1)) = current_cluster;
            end
        end
    end
    
    % creates the output
    nodecube = nodecube(2:end-1,2:end-1,2:end-1);
    output = zeros(size(lnkvx_x,1),2);
    counter = 1;
    for i = 1:max(nodecube,[],'all')
        [x,y,z] = ind2sub(size(nodecube),find(nodecube==i));
        x = x + allvx_min_x - 1;
        y = y + allvx_min_y - 1;
        z = z + allvx_min_z - 1;
        for j = 1:length(x)
            output(counter,1) = sub2ind(sizes,x(j),y(j),z(j));
            output(counter,2) = i;
            counter = counter + 1;
        end
    end
    
end
        