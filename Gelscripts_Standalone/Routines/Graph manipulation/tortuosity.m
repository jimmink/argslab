function [ dxpath, dypath, dzpath, dxeucl, dyeucl, dzeucl, dxtortuosity, dytortuosity, dztortuosity] = tortuosity( G, node, skel, realpx , particlediameter, edgenode_dist)
%  TORTUOSITY calculates the directlength divided by the pathlength for all
%  nodes. It calculates this by obtaining all nodes in an edge region
%  defines as being $realpx$ * $particlediameter$ * $edgenode_dist$ from
%  the box edge, and calculating the distance to the nodes found in the
%  opposite side. Is performed seperately along the three directions. 

%% Preparation

[xl,yl,zl] = size(skel);

%% index all edge nodes one diameter from edge

nodeix1 = zeros(size(node,2),1);
nodeiy1 = zeros(size(node,2),1);
nodeix2 = zeros(size(node,2),1);
nodeiy2 = zeros(size(node,2),1);
nodeiz1 = zeros(size(node,2),1);
nodeiz2 = zeros(size(node,2),1);

particle_x = edgenode_dist * particlediameter / realpx(1);
particle_y = edgenode_dist * particlediameter / realpx(2);
particle_z = edgenode_dist * particlediameter / realpx(3);

for i =1:length(node)
    if (node(i).comx < particle_x && node(i).ep == 1)
        nodeix1(i) = i;
    elseif (node(i).comy < particle_y && node(i).ep == 1)
        nodeiy1(i) = i;
    elseif (node(i).comx > (xl - particle_x) && node(i).ep == 1)
        nodeix2(i) = i;
    elseif (node(i).comy > (yl - particle_y) && node(i).ep == 1)
        nodeiy2(i) = i;
    elseif (node(i).comz < particle_z && node(i).ep == 1)
        nodeiz1(i) = i;
    elseif (node(i).comz > (zl - particle_z) && node(i).ep == 1)
        nodeiz2(i) = i;
    end
end

nodeix1 = nodeix1(nodeix1~=0); 
nodeiy1 = nodeiy1(nodeiy1~=0); 
nodeix2 = nodeix2(nodeix2~=0); 
nodeiy2 = nodeiy2(nodeiy2~=0); 
nodeiz1 = nodeiz1(nodeiz1~=0); 
nodeiz2 = nodeiz2(nodeiz2~=0); 

%% Clean up node selections (x)
% Filter based on connections, with nodes that are not cirectly connected 
% to the outside are removed.

nodeix1 = clean_edgearea(nodeix1,node);
nodeix2 = clean_edgearea(nodeix2,node);
nodeiy1 = clean_edgearea(nodeiy1,node);
nodeiy2 = clean_edgearea(nodeiy2,node);
nodeiz1 = clean_edgearea(nodeiz1,node);
nodeiz2 = clean_edgearea(nodeiz2,node);

%% Calculate shortest path and directness

% in the x-direction
if isempty(nodeix1) == 0 && isempty(nodeix2) == 0
    dxpath = distances(G,nodeix1(:,1),nodeix2(:,1),'Method','positive'); % Dijkstra algorithm
    dxeucl = zeros(length(nodeix1),length(nodeix2));
    for i = 1:size(dxeucl,1)
        for j = 1:size(dxeucl,2)
            dxeucl(i,j) = length3Ddir( node, nodeix1(i), nodeix2(j), realpx );
        end
    end
    dxtortuosity = dxeucl./dxpath;
    dxtortuosity = dxtortuosity(dxtortuosity ~= 0);
    dxtortuosity = 1./dxtortuosity;
else
    dxpath = [];
    dxeucl = [];
    dxtortuosity = [];
end

% in the y-direction
if isempty(nodeiy1) == 0 && isempty(nodeiy2) == 0
    dypath = distances(G,nodeiy1(:,1),nodeiy2(:,1),'Method','positive');
    dyeucl = zeros(length(nodeiy1),length(nodeiy2));
    for i = 1:size(dyeucl,1)
        for j = 1:size(dyeucl,2)
            dyeucl(i,j) = length3Ddir( node, nodeiy1(i), nodeiy2(j), realpx );
        end
    end
    dytortuosity = dyeucl./dypath;
    dytortuosity = dytortuosity(dytortuosity ~= 0);
    dytortuosity = 1./dytortuosity;
else
    dypath = [];
    dyeucl = [];
    dytortuosity = [];
end

% in the z-direction

if ndims(skel) == 3
    if isempty(nodeiz1) == 0 && isempty(nodeiz2) == 0
        dzpath = distances(G,nodeiz1(:,1),nodeiz2(:,1),'Method','positive');
        dzeucl = zeros(length(nodeiz1),length(nodeiz2));
        for i = 1:size(dzeucl,1)
            for j = 1:size(dzeucl,2)
                dzeucl(i,j) = length3Ddir( node, nodeiz1(i), nodeiz2(j), realpx );
            end
        end
        dztortuosity = dzeucl./dzpath;
        dztortuosity = dztortuosity(dztortuosity ~= 0);
        dztortuosity = 1./dztortuosity;
    else
        dzpath = [];
        dzeucl = [];
        dztortuosity = [];
    end
end

end