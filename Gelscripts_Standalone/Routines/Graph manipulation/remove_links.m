function link = remove_links(link, link_replist, node_replist)
% REMOVE_LINKS removes links from the main link list, and rearranges the
% remaining links to have sequential link id's. Requires two lists where
% node-id's are replaced with new id's and link-id's to be replaced with
% new id's.

    counter = 1;
    for i = 1:size(link_replist,1)
        if isnan(link_replist(i))
            link(counter) = [];
        else
            link(counter).n1 = node_replist(link(counter).n1);
            link(counter).n2 = node_replist(link(counter).n2);
            counter = counter + 1;
        end
    end
end