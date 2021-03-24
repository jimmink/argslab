function debugger(node,link)

nlswitch = 0;
for i = 1:size(node,2)
    involved_nodes = [i, node(i).conn];
    linked_nodes = [i];
    for j = 1:size(node(i).links,2)
        linked_nodes = [linked_nodes,link(node(i).links(j)).n1];
        linked_nodes = [linked_nodes,link(node(i).links(j)).n2];
    end
    involved_nodes = unique(involved_nodes);
    linked_nodes = unique(linked_nodes);
    if ~isequal(involved_nodes,linked_nodes)
        disp(['Conns of node ',num2str(i), ' do not correspond to its link entries'])
        nlswitch = 1;
    end
end

if nlswitch == 0
    disp('All nodes are connected to their appropriate links')
end

lswitch = 0;
for i = 1:size(link,2)
    if ismember(i,node(link(i).n1).links) == 0
        disp('Link ',num2str(i),' is not found in the links of node ',num2str(link(i).n1))
        lswitch = 1;
    elseif ismember(i,node(link(i).n2).links) == 0
        disp('Link ',num2str(i),' is not found in the links of node ',num2str(link(i).n2))
        lswitch = 1;
    end
end

if lswitch == 0
    disp('All links are correctly connected to its nodes')
end

infswitch = 0;
for i = 1:size(link,2)
    if sum(isinf(link(i).point)) > 0
        infswitch = 1;
        disp('Link ',num2str(i),' has strange entries.')
    elseif sum(isnan(link(i).point)) > 0
        infswitch = 1;
        disp('Link ',num2str(i),' has strange entries.')
    end
end

if infswitch == 0
    disp('No faulty link instances were found.')
end


linkswitch = 0;
for i = 1:size(link,2)
    if ismember(link(i).point(1),node(link(i).n1).idx) == 0
        disp(['Beginvoxel of link ',num2str(i), ' is not found in voxels of node ',num2str(link(i).n1)])
        linkswitch = 1;
    elseif ismember(link(i).point(end),node(link(i).n2).idx) == 0
        disp(['Endvoxel of link ',num2str(i), ' is not found in voxels of node ',num2str(link(i).n2)])
        linkswitch = 1;
    end
end

if linkswitch == 0
    disp('All begin- and endvoxels of links exist in its appropriate nodes')
end

if isfield(link,'pointextended')
    linkswitch2 = 0;
    for i = 1:size(link,2)
        if ismember(link(i).pointextended(1),node(link(i).n1).idx) == 0
            disp(['Beginvoxel of link ',num2str(i), ' is not found in voxels of node ',num2str(link(i).n1)])
            linkswitch2 = 1;
        elseif ismember(link(i).pointextended(end),node(link(i).n2).idx) == 0
            disp(['Endvoxel of link ',num2str(i), ' is not found in voxels of node ',num2str(link(i).n2)])
            linkswitch2 = 1;
        end
    end

    if linkswitch2 == 0
        disp('All begin- and endvoxels of links exist in its appropriate nodes for pointextended')
    end
end