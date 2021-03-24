function node = remove_ringlinks(node, node_replist, link_replist)
% REMOVE_RINGLINKS is a script that specifically removes ringlinks from the
% node list. This is a slightly altered version of REMOVE_NODES with checks
% for possible removing of connected nodes and links in case of ring links.

    counter = 1;
    for i = 1:size(node_replist,1)
        if isnan(node_replist(i))
            node(counter) = [];
        else
            for j = size(node(counter).links,2):-1:1
                if isnan(link_replist(node(counter).links(j)))
                    node(counter).links(j) = [];
                else
                    node(counter).links(j) = link_replist(node(counter).links(j));
                end
            end
            for j = size(node(counter).conn,2):-1:1
                if node(counter).conn(j) == counter
                    node(counter).conn(j) = [];
                else
                    node(counter).conn(j) = node_replist(node(counter).conn(j));
                end
            end
            counter = counter + 1;
        end
    end
    


end