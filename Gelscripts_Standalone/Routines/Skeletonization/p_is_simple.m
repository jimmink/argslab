function p_is_simple = p_is_simple(N)

% P_SIMPLE gives a list of simple points from a list of 27-voxel cubes. A 
% voxel is simple if the change of its value does not change the topology 
% of the image. 
%
% This routine is based on MATLAB code from Kerschnitzki, Kollmannsberger
% et al., J. Bone. Miner. Res., 28(8):1837-1845, 2013. This code is based 
% on algorithms published in Lee et al., Comput. Gr. Image Process., 
% 56(6):462-478, 1994.

% copy neighbors for labeling
n_p = size(N,1);    % aantal voxels
p_is_simple = ones(1,n_p); % preallocate voor alle voxels

cube = zeros(26,n_p); % preallocate voor alle voxels een kubus
cube(1:13,:)=N(:,1:13)'; 
cube(14:26,:)=N(:,15:27)'; % Put all voxels, except the central voxel, in "cube"

label = 2*ones(1,n_p); % preallocate for every voxel with a label "2", i.e. not 1 or 0.

% for all points in the neighborhood
for i=1:26
    
    idx_1 = find(cube(i,:)==1); % make a list of voxel cubes (id's) that have a filled in voxel i
    idx_2 = find(p_is_simple);  % make a list of voxel cubes that have not yet been shown to be a non-simple voxel (after the following iterations)
    idx = intersect(idx_1,idx_2); % all voxels that appear in both lists
    
    if(~isempty(idx)) % if voxels have been found for this i
        
        % split in octants
        
        % start a recursion with all octants that contain point i
        switch(i)
            
            case {1,2,4,5,10,11,13} % NWF
                cube(:,idx) = p_oct_label(1, label, cube(:,idx) );
            case {3,6,12,14} % NEF
                cube(:,idx) = p_oct_label(2, label, cube(:,idx) );
            case {7,8,15,16} % SWF
                cube(:,idx) = p_oct_label(3, label, cube(:,idx) );
            case {9,17} % etc
                cube(:,idx) = p_oct_label(4, label, cube(:,idx) );
            case {18,19,21,22} 
                cube(:,idx) = p_oct_label(5, label, cube(:,idx) );
            case {20,23} 
                cube(:,idx) = p_oct_label(6, label, cube(:,idx) );
            case {24,25}
                cube(:,idx) = p_oct_label(7, label, cube(:,idx) );
            case 26
                cube(:,idx) = p_oct_label(8, label, cube(:,idx) );
        end

        label(idx) = label(idx)+1;
        del_idx = find(label>=4);
        
        if(~isempty(del_idx))
            p_is_simple(del_idx) = 0;
        end
    end
end


