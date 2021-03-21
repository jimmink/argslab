function [node,link] = skel2graph_edgeclean(skel,boxedge_px,realpx)
% SKEL2GRAPH_EDGECLEAN creates graph files from a skeleton, and removes any
% nodes or links leading to the box edge. 

% Comments can be found in skel2graph_firstclean, except for the different
% parts.

% The graph file creation section is adapted from Philip Kollmannsberger's 
% skeletonization code.

skel=padarray(skel,[1 1 1]);

w=size(skel,1);
l=size(skel,2);
h=size(skel,3);

skel2 = uint16(skel);

list_canal=find(skel);

nh = logical(get_nh(skel,list_canal));

nhi = get_nh_idx(skel,list_canal);

sum_nh = sum(logical(nh),2);

nodes = list_canal(sum_nh>3);

ep = list_canal(sum_nh==2);

cans = list_canal(sum_nh==3);

can_nh_idx = get_nh_idx(skel,cans);
can_nh = get_nh(skel,cans);

can_nh_idx(:,14)=[];
can_nh(:,14)=[];

can_nb = sort(logical(can_nh).*can_nh_idx,2);

can_nb(:,1:end-2) = [];

cans = [cans can_nb];

c2n=zeros(w*l*h,1); 
c2n(cans(:,1))=1:length(cans); 

s2n=zeros(w*l*h,1);
s2n(nhi(:,14))=1:length(nhi); 

node=[];
link=[];

tmp=false(w,l,h); 
tmp(nodes)=1; 
cc2=bwconncomp(tmp);  
num_realnodes = cc2.NumObjects; 

for i=1:cc2.NumObjects 
    node(i).idx = cc2.PixelIdxList{i}; 
    node(i).links = []; 
    node(i).conn = []; 
    [x,y,z]=ind2sub([w l h],node(i).idx); 
    node(i).comx = mean(x); 
    node(i).comy = mean(y); 
    node(i).comz = mean(z); 
    node(i).ep = 0; 
    
    skel2(node(i).idx) = i+1;
end

tmp=false(w,l,h); 
tmp(ep)=1; 
cc3=bwconncomp(tmp); 

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
            [vox,n_idx,ep] = pk_follow_link(skel2,node,i,j,link_cands(k),cans,c2n); 
            skel2(vox(2:end-1))=0; 
            if( ep || (~ep && i~=n_idx)) 
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

%% Cleaning routine

[node, link] = edgeclean(node,link,cc2.NumObjects,[w,l,h],boxedge_px);
        
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
