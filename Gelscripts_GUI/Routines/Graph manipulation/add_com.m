function node = add_com(node,sizes)
% ADD_COM adds the centers of masses (rounded to a pixel) of a multi-voxel
% node. ADD_COM takes the voxel of the node that is closest to the actual
% center of mass.

node(1).CoM = 0;
for i = 1:size(node,2)
    if size(node(i).idx,1) > 1
        [x,y,z] = ind2sub(sizes,node(i).idx);
        CoM = mean([x,y,z],1);
        d_from_CoM = sum(abs([x,y,z] - CoM),2);
        [~,b] = min(d_from_CoM);
        node(i).CoM = node(i).idx(b);
    else
        node(i).CoM = node(i).idx;
    end
end