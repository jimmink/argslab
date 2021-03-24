function [vox,n_idx,ep] = pk_follow_link(skel,node,k,j,idx,cans,c2n)
% PK_FOLLOW_LINK produces a list of idx's of voxels from a given node and
% an initial first canal voxel to the first node.

% This routine is based on MATLAB code from Kerschnitzki, Kollmannsberger
% et al., J. Bone. Miner. Res., 28(8):1837-1845, 2013. This code is based 
% on algorithms published in Lee et al., Comput. Gr. Image Process., 
% 56(6):462-478, 1994.

vox = [];
n_idx = [];
ep = 0;

% assign start node to first voxel
vox(1) = node(k).idx(j);

i=1;
isdone = false;
while(~isdone) % if no node has yet been found
    i=i+1; % following iteration
    next_cand = c2n(idx); % vind één van de naburige voxel-ids
    cand = cans(next_cand,2);
    if(cand==vox(i-1)) % switch direction
        cand = cans(next_cand,3);
    end
    if(skel(cand)>1) % node found
        vox(i) = idx;
        vox(i+1) = cand; % first node
        n_idx = skel(cand)-1; % node number
        if(node(n_idx).ep)
            ep=1;
        end
        isdone = 1;
    else % next voxel
        vox(i) = idx;
        idx = cand;
    end
end
