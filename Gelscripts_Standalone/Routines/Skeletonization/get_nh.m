function nhood = get_nh(skel,can_ind)
% GET_NH obtains the neighborhood of all the nodes provided, with "skel"
% being the skeleton, and "i" being a list of the voxels for which the
% neighborhood is to be obtained. "i" should be a list of voxel indices.
%
% This routine is based on MATLAB code from Kerschnitzki, Kollmannsberger
% et al., J. Bone. Miner. Res., 28(8):1837-1845, 2013. This code is based 
% on algorithms published in Lee et al., Comput. Gr. Image Process., 
% 56(6):462-478, 1994.

% preallocate
width = size(skel,1);
height = size(skel,2);
depth = size(skel,3);

[x,y,z]=ind2sub([width height depth],can_ind);

nhood = false(length(can_ind),27);

% working loop
for xx=1:3
    for yy=1:3
        for zz=1:3
            w=sub2ind([3 3 3],xx,yy,zz);
            idx = sub2ind([width height depth],x+xx-2,y+yy-2,z+zz-2);
            nhood(:,w)=skel(idx);
        end
    end
end