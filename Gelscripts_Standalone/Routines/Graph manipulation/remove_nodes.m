function node = remove_nodes(node, node_replist, link_replist)
% REMOVE_NODES removes nodes from the main node list, and rearranges the
% remaining nodes to have sequential node id's. Requires two lists where
% node-id's are replaced with new id's and link-id's to be replaced with
% new id's.

    counter = 1;
    for i = 1:size(node_replist,1)
        if isnan(node_replist(i))
            node(counter) = [];
        else
            for j = 1:size(node(counter).links,2)
                node(counter).links(j) = link_replist(node(counter).links(j));
            end
            for j = size(node(counter).conn,2):-1:1
                node(counter).conn(j) = node_replist(node(counter).conn(j));
            end
            counter = counter + 1;
        end
    end
    
end