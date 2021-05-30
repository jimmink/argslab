function [link,node] = linkmerge(link,links_tbm,node,node_tbm,sizes,offsetmask)
%   LINKMERGE merges the two links originating from a single node, intended
%   for nodes that only possess two links. Intended for node/link graph
%   objects. Works by creating a distance cube from the initial node, and
%   walking backwards from the second node to find the first node.

    nodeindices = node(node_tbm).idx;
    part1 = link(links_tbm(1)).point;
    if ~ismember(part1(end),nodeindices)
        part1 = fliplr(part1);
    end
    part3 = link(links_tbm(2)).point;
    if ~ismember(part3(1),nodeindices)
        part3 = fliplr(part3);
    end

    if part1(end) == part3(1)
        newlink = [part1 part3(2:end)];
    elseif size(nodeindices,1) == 2
        newlink = [part1 part3];
    else % there are several options here; a method based on bwdistgeodesic fails due to it considering not 27-connectivity.

        part2 = connect_27(part1(end),part3(1),nodeindices,sizes,offsetmask);
        newlink = [part1 part2(2:end-1) part3];
        
    end

    linked_nodes = [link(links_tbm).n1,link(links_tbm).n2];
    linked_nodes(linked_nodes == node_tbm) = [];
    link(links_tbm(1)).n1 = linked_nodes(1,1);
    link(links_tbm(1)).n2 = linked_nodes(1,2);
    link(links_tbm(1)).point = newlink;
    
    newly_connected_nodes = node(node_tbm).conn;
    for i = 1:2
        tbr = ismember(node(newly_connected_nodes(1,i)).links,links_tbm(2));
        node(newly_connected_nodes(1,i)).links(tbr) = links_tbm(1);
        
        tbr = ismember(node(newly_connected_nodes(1,i)).conn,node_tbm);
        node(newly_connected_nodes(1,i)).conn(tbr) = newly_connected_nodes(1,mod(i,2)+1);
    end
    
end