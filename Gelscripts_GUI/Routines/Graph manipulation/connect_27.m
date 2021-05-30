function fullpath = connect_27(voxelid_1,voxelid_2,allowed_voxels,arraysize,offsetmask)
% CONNECT_27 connects two voxels through a set of allowed voxels. The
% output is ordered to go from voxel 1 to voxel 2. Similar to a method
% involving bwconngeodesic, but that code does not assume 27-connectivity.

    % make a new array of zeros the size of arraysize, and label
    % all allowed voxels "Inf"
	nodecube = zeros(arraysize);
    nodecube(allowed_voxels) = Inf;
	nodecube(voxelid_1) = 1;

    % Label all voxels as being "counter" away from an initial voxel
    % voxelid_1, padding not necessary
    nodes_tbc = voxelid_1;
    while ~isempty(nodes_tbc)
        current_quantity = nodecube(nodes_tbc(1));
        surrounding = nodes_tbc(1) + offsetmask;
        infs = surrounding(isinf(nodecube(surrounding)));
        nodecube(infs) = current_quantity + 1;
        nodes_tbc(1) = [];
        nodes_tbc = [nodes_tbc;infs];
    end

    % find one of the quickest paths to a second voxel voxelid_2
    currentvoxel = voxelid_2;
    currentvalue = nodecube(voxelid_2);
    fullpath = zeros(1,currentvalue,'double');
    fullpath(1,currentvalue) = currentvoxel;
    counter = currentvalue - 1;
    while currentvalue > 1
        surrounding = currentvoxel + offsetmask;
        currentvoxel = surrounding(nodecube(surrounding) == currentvalue - 1);
        if size(currentvoxel,1) > 1
            currentvoxel = currentvoxel(1);
        end
        currentvalue = currentvalue - 1;
        fullpath(1,counter) = currentvoxel;
        counter = counter - 1;
    end

end