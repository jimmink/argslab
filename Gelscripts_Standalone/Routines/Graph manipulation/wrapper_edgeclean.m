function [skel2, Apath, node, link] = wrapper_edgeclean( skel, edge_thr, particlediameter, realpx, cl_thr )
% WRAPPER_EDGECLEAN is a wrapper script around
% SKEL2GRAPH_EDGECLEAN. This creates graph files from a skeleton, and 
% applies a thorough cleaning. 

%% Convert skeleton into nodes and links

w = size(skel,1);
l = size(skel,2);
h = size(skel,3);

% calculate box edge boundaries
boxedge_um = edge_thr * particlediameter;
boxedge_px = zeros(1,3);
boxedge_px(1,1) = boxedge_um / realpx(1);
boxedge_px(1,2) = boxedge_um / realpx(2);
boxedge_px(1,3) = boxedge_um / realpx(3);

% reform into a list of nodes and links
[init_node,init_link] = skel2graph_edgeclean(skel,boxedge_px,realpx);

% reshape into new skel array, and reform a node/link graph
% clean-up comprises removal of links to end nodes, that are shorter than
% threshold value in vx, and removal of rings from the skeleton.
skel2 = Graph2Skel3D(init_node,init_link,w,l,h);
[node,link] = skel2graph_edgeclean(skel2,boxedge_px,realpx);

% iterate process until network length no longer changes
done = 0;
while done == 0

	skeln = Graph2Skel3D(node,link,w,l,h);
    [node,link] = skel2graph_edgeclean(skeln,boxedge_px,realpx);
    if isequal(skel2,skeln)
        done = 1;
    end
    skel2 = skeln;
    
end


%% Collect clusternodes

[node,link] = collect_clusternodes(node,link,cl_thr,[w,l,h],realpx);

%% Add lengths to link

pyth_lut = mk_p_lut(realpx);

link(1).length = 0;
for i = 1:size(link,2)
    [x,y,z] = ind2sub([w,l,h],link(i).point);
    dist = 0;
    for j = 1:size(link(i).point,2)-1
        neightype = sub2ind([3,3,3],x(j) - x(j+1) + 2,y(j) - y(j+1) + 2,z(j) - z(j+1) + 2);
        dist = dist + pyth_lut(neightype);
    end
    link(i).length = dist;
end

%% Make adjencency matrix weighed on Euclidean node distance

% transform to padded coordinates
for i=1:length(node)
    [x,y,z] = ind2sub([w,l,h],node(i).idx);
    node(i).idx = sub2ind([w+2,l+2,h+2],x+1,y+1,z+1);
    node(i).comx = node(i).comx + 1;
    node(i).comy = node(i).comy + 1;
    node(i).comz = node(i).comz + 1;
end

for i=1:length(link)
    [x,y,z] = ind2sub([w,l,h],link(i).point);
    link(i).point = sub2ind([w+2,l+2,h+2],x+1,y+1,z+1);
end

node = add_com(node,[w+2,l+2,h+2]);
[node,link] = add_lengths(node,link,realpx,[w+2,l+2,h+2]);


% transform back to non-padded coordinates
for i=1:length(node)
    [x,y,z] = ind2sub([w+2,l+2,h+2],node(i).idx);
    node(i).idx = sub2ind([w,l,h],x-1,y-1,z-1);
    node(i).comx = node(i).comx - 1;
    node(i).comy = node(i).comy - 1;
    node(i).comz = node(i).comz - 1;
end

for i=1:length(link)
    [x,y,z] = ind2sub([w+2,l+2,h+2],link(i).point);
    link(i).point = sub2ind([w,l,h],x-1,y-1,z-1);
	[x,y,z] = ind2sub([w+2,l+2,h+2],link(i).pointextended);
	link(i).pointextended = sub2ind([w,l,h],x-1,y-1,z-1);
end

Apath = zeros(size(node,2));

for i = 1:size(link,2)
    Apath(link(i).n1,link(i).n2) = link(i).length;
	Apath(link(i).n2,link(i).n1) = link(i).length;
end

Apath = sparse(Apath);

end

