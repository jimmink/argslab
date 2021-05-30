function [skel2, Apath, node, link, init_node, init_link ] = wrapper_firstclean( skel, realpx)
%  WRAPPER_FIRSTCLEAN is a wrapper script around
% SKEL2GRAPH_FIRSTCLEAN. This creates graph files from a skeleton, and 
% applies a first cleaning. This is meant to serve for a cleaning procedure
% before the tortuosity determination.

%% Convert skeleton into nodes and links

w = size(skel,1);
l = size(skel,2);
h = size(skel,3);

% reform into a list of nodes and links
[init_node,init_link] = skel2graph_firstclean(skel);

% total length of the initial network
init_w = sum(cellfun('length',{init_node.links}));

% reshape into new skel array, and reform a node/link graph
% clean-up comprises removal of links to end nodes, that are shorter than
% threshold value in vx, and removal of rings from the skeleton.
skel2 = Graph2Skel3D(init_node,init_link,w,l,h);
[node,link] = skel2graph_firstclean(skel2);

% calculate new network length
w_end = sum(cellfun('length',{node.links}));

% iterate process until network length no longer changes
while(w_end~=init_w)

    init_w = w_end;   
    
     skel2 = Graph2Skel3D(node,link,w,l,h);
     [node,link] = skel2graph_firstclean(skel2);

     w_end = sum(cellfun('length',{node.links}));

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

