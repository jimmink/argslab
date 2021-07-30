function [node,link] = skel2graph_firstclean(skel)
% SKEL2GRAPH_FIRSTCLEAN creates graph files from a skeleton, and applies a
% first cleaning routine that cleans nodes only twice connected, 
% non-connected nodes, and unnecessarily kept node voxels. Note that 
% single-connected nodes and their links are removed in the later used 
% SKEL2GRAPH_THOROUGHCLEAN. 

% The graph file creation section is adapted from Philip Kollmannsberger's 
% skeletonization code.

% pad volume with zeros
skel=padarray(skel,[1 1 1]);

% image dimensions
w=size(skel,1);
l=size(skel,2);
h=size(skel,3);

% need this for labeling nodes etc.
skel2 = uint16(skel);

% all skeleton voxels
list_canal=find(skel);

% 26-neighborhood of all skeleton voxels
nh = logical(get_nh(skel,list_canal));

% 26-neighborhood positie-indices of all skeleton voxels
nhi = get_nh_idx(skel,list_canal);

% number of filled in voxels in the 26-neighborhood for each skel voxel 
% +1, due to the central voxel being filled in per definition
sum_nh = sum(logical(nh),2);

% define all skeleton voxels with >2 neighbors as nodes
nodes = list_canal(sum_nh>3);

% define all skeleton voxels with exactly one neighbors as end nodes
ep = list_canal(sum_nh==2);

% make a list of the canal voxels
cans = list_canal(sum_nh==3);

% Nx3 matrix with the two neighbors of each canal voxel
can_nh_idx = get_nh_idx(skel,cans);
can_nh = get_nh(skel,cans);

% remove center of 3x3 cube
can_nh_idx(:,14)=[];
can_nh(:,14)=[];

% write an array where all canal voxels are given with its two neighbors
can_nb = sort(logical(can_nh).*can_nh_idx,2);

% remove the zeros
can_nb(:,1:end-2) = [];

% enlarge with their neighbors
cans = [cans can_nb];

% Make a look-up list of all linear indices for all canal voxels
c2n=zeros(w*l*h,1); 
c2n(cans(:,1))=1:length(cans); 

% The same, but will all skelvoxels
s2n=zeros(w*l*h,1);
s2n(nhi(:,14))=1:length(nhi); 

% group clusters of node voxels to nodes
node=[];
link=[];

% preallocate
tmp=false(w,l,h); 
tmp(nodes)=1; 
cc2=bwconncomp(tmp);  
num_realnodes = cc2.NumObjects; 

% The above gives six arrays:
%
% - nh: a Nx27 array with whether a voxel in its 27-NH is filled in
% - nhi: a Nx27 array of those, but in linear indices
% - cans: a Nx3 array with the filled-in canal voxel-id's and its two
% neighbors
% - ep: a Nx1 array of all end point voxel-id's
% - cc2.PixelIDxList: a list of all node voxels, with neighboring voxels in
% one entry

% preallocates a struc array for all nodes, and saves the x, y, and z values.
for i=1:cc2.NumObjects 
    node(i).idx = cc2.PixelIdxList{i}; 
    node(i).links = []; 
    node(i).conn = []; 
    [x,y,z]=ind2sub([w l h],node(i).idx); 
    node(i).comx = mean(x); 
    node(i).comy = mean(y); 
    node(i).comz = mean(z); 
    node(i).ep = 0; 
    % label these nodes with "2" or higher in the labeling skel array
    skel2(node(i).idx) = i+1;
end

tmp=false(w,l,h); 
tmp(ep)=1; 
cc3=bwconncomp(tmp); 

% make end node struct-object
for i=1:cc3.NumObjects
    ni = num_realnodes+i; 
    node(ni).idx = cc3.PixelIdxList{i};
    node(ni).links = [];
    node(ni).conn = [];
    [x,y,z]=ind2sub([w l h],node(ni).idx);
    node(ni).comx = mean(x);
    node(ni).comy = mean(y);
    node(ni).comz = mean(z);
    node(ni).ep = 1;
    
    skel2(node(ni).idx) = ni+1;
end

l_idx = 1;

for i=1:num_realnodes

    link_idx = s2n(node(i).idx);
    
    for j=1:length(link_idx) 
        
        link_cands = nhi(link_idx(j),nh(link_idx(j),:)==1); 
        link_cands = link_cands(skel2(link_cands)==1); 
        
        for k=1:length(link_cands) 
            [vox,n_idx,ep] = pk_follow_link(skel2,node,i,j,link_cands(k),cans,c2n); % follow a link until the new node
            skel2(vox(2:end-1))=0; 
            if( ep || (~ep && i~=n_idx)) % remove if shorter than threshold
                link(l_idx).n1 = int64(i); 
                link(l_idx).n2 = int64(n_idx); 
                link(l_idx).point = vox;
                node(i).links = [int64(node(i).links), int64(l_idx)]; 
                node(i).conn = [int64(node(i).conn), int64(n_idx)]; 
                node(n_idx).links = [int64(node(n_idx).links), int64(l_idx)]; 
                node(n_idx).conn = [int64(node(n_idx).conn), int64(i)]; 
                l_idx = l_idx + 1; 
            end
        end
    end
end

%% Clean up graph

[node, link] = firstclean(node,link,cc2.NumObjects,[w,l,h]);
        
%% transform back to non-padded coordinates

for i=1:length(node)
    [x,y,z] = ind2sub([w,l,h],node(i).idx);
    node(i).idx = sub2ind([w-2,l-2,h-2],x-1,y-1,z-1);
    node(i).comx = node(i).comx - 1;
    node(i).comy = node(i).comy - 1;
    node(i).comz = node(i).comz - 1;
end

for i=1:length(link)
    [x,y,z] = ind2sub([w,l,h],link(i).point);
    link(i).point = sub2ind([w-2,l-2,h-2],x-1,y-1,z-1);
end
