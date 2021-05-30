function [node,link] = collect_clusternodes(node,link,cl_thr,sizes,realpx)
% COLLECT_CLUSTERNODES collects sets nodes into a single node, if these
% nodes are linked by links shorter than a theshold value.
    
    for i=1:length(node)
        [x,y,z] = ind2sub(sizes,node(i).idx);
        node(i).idx = sub2ind([sizes(1)+2,sizes(2)+2,sizes(3)+2],x+1,y+1,z+1);
        node(i).comx = node(i).comx + 1;
        node(i).comy = node(i).comy + 1;
        node(i).comz = node(i).comz + 1;
    end

    for i=1:length(link)
        [x,y,z] = ind2sub(sizes,link(i).point);
        link(i).point = sub2ind([sizes(1)+2,sizes(2)+2,sizes(3)+2],x+1,y+1,z+1);
    end
    
    sizes = sizes + 2;
    pyth_lut = mk_p_lut(realpx);
    offsetmask = make_osm(sizes);
    
    % find all nodes that have links smaller than the threshold
    ntbc_x = zeros(size(link,2),1);
    ntbc_y = ntbc_x;
    link(1).length = 0;
    counter = 1;
    for i = 1:size(link,2)
        [x,y,z] = ind2sub(sizes,link(i).point);
        dist = 0;
        for j = 1:size(link(i).point,2)-1
            neightype = sub2ind([3,3,3],x(j) - x(j+1) + 2,y(j) - y(j+1) + 2,z(j) - z(j+1) + 2);
            dist = dist + pyth_lut(neightype);
        end
        link(i).length = dist;
        if dist < cl_thr
            ntbc_x(counter) = link(i).n1;
            ntbc_y(counter) = link(i).n2;
            counter = counter + 1;
        end
    end
    ntbc_x = ntbc_x(1:counter-1);
    ntbc_y = ntbc_y(1:counter-1);

    % for each node, make a list of each node it is connected to, via short
    % links.
    connection_list = unique(vertcat(ntbc_x,ntbc_y));

    % make look-up table for this array
    c_lut = zeros(max(connection_list(:,1)),1);
    for i = 1:size(connection_list,1)
        c_lut(connection_list(i,1),1) = i;
    end
    c_lut = horzcat(c_lut,2*ones(size(c_lut)));

    for i = 1:size(ntbc_x,1)
        locx1 = c_lut(ntbc_x(i,1),1);
        locx2 = c_lut(ntbc_x(i,1),2);
        connection_list(locx1,locx2) = ntbc_y(i,1);

        locy1 = c_lut(ntbc_y(i,1),1);
        locy2 = c_lut(ntbc_y(i,1),2);
        connection_list(locy1,locy2) = ntbc_x(i,1);

        c_lut(ntbc_x(i,1),2) = c_lut(ntbc_x(i,1),2) + 1;
        c_lut(ntbc_y(i,1),2) = c_lut(ntbc_y(i,1),2) + 1;
    end

    % group these together in sets of linked clusters
    clusterlist = cell(size(connection_list,1),8);
    counter = 1;
    while counter <= size(connection_list,1)
        cn_counter = 2;
        conn_nodes = nonzeros(connection_list(counter,:))';
        while cn_counter <= size(conn_nodes,2)
            new_cn = nonzeros(connection_list(c_lut(conn_nodes(1,cn_counter)),:))';
            new_cn = new_cn(~ismember(new_cn,conn_nodes));
            if ~isempty(new_cn)
                conn_nodes = [conn_nodes, new_cn]; %#ok<AGROW>
            end
            cn_counter = cn_counter + 1;
        end
        clusterlist{counter,1} = conn_nodes;
        counter = counter + 1;
    end

    % remove duplicates from clusterlist
    c_lut(:,2) = 0;
    counter = 1;
    while counter <= size(clusterlist,1)
        if any(c_lut(clusterlist{counter,1},2) == 0)
            c_lut(clusterlist{counter,1},2) = 1;
            counter = counter + 1;
        else
            clusterlist(counter,:) = [];
        end
    end

    % build clusterlist:
    % 1 - all nodes to be related to combined node
    % 2 - center of mass of combined node
    % 3 - links to be extending from the combined node
    % 4 - all nodes the combined node will be connecting to
    % 5 - coordinates of the combined node center
    % 6 - intra-node links, to be merged into the combined node
    % 7 - all voxels of the old nodes, the intra-node links and the
    % external links
    % 8 - all voxels of the old nodes and intra-node links (for now)
    for i = 1:size(clusterlist,1)
        linkpernode = [];
        for j = 1:size(clusterlist{i,1},2)
            linkpernode = [linkpernode node(clusterlist{i,1}(j)).links]; %#ok<AGROW>
        end
        linkpernode = unique(linkpernode);
        for j = 1:size(linkpernode,2)
            linkednodes = [link(linkpernode(j)).n1, link(linkpernode(j)).n2];
            if sum(ismember(linkednodes,clusterlist{i,1})) == 2
                clusterlist{i,6} = [clusterlist{i,6}, linkpernode(j)];
            else
                clusterlist{i,3} = [clusterlist{i,3}, linkpernode(j)];
            end
        end
        clusterlist{i,4} = setdiff(unique([node(clusterlist{i,1}).conn]),clusterlist{i,1});
        clusterlist{i,7} = unique([[link(clusterlist{i,3}).point] [link(clusterlist{i,6}).point] vertcat(node(clusterlist{i,1}).idx)']);
        clusterlist{i,8} = unique([[link(clusterlist{i,6}).point] vertcat(node(clusterlist{i,1}).idx)']);
        [x,y,z] = ind2sub(sizes,clusterlist{i,8});
        means = [mean(x),mean(y),mean(z)];

        [~,temp3] = min(sum(abs([x;y;z]' - means),2));
        if length(temp3) > 1
            temp3 = temp3(1);
        end
        clusterlist{i,5} = [x(temp3),y(temp3),z(temp3)];
        clusterlist{i,2} = sub2ind(sizes,x(temp3),y(temp3),z(temp3));
    end

    % make look up list for non-primary nodes, which they will be
    npn_lut = zeros(size(node,2),2);
    for i = 1:size(clusterlist,1)
        for j = 1:size(clusterlist{i,1},2)
            npn_lut(clusterlist{i,1}(j),1) = clusterlist{i,1}(1);
            npn_lut(clusterlist{i,1}(j),2) = i;
        end
    end
    
    % rewrite the primary nodes and links to include new information, and label
    % links to be removed
    node_replist = zeros(size(node,2),1);
    link_replist = zeros(size(link,2),1);

    for i = 1:size(clusterlist,1)

        primary_node = clusterlist{i,1}(1);
        non_primary_nodes = clusterlist{i,1}(2:end);
        node_replist(clusterlist{i,1}(2:end)) = NaN;
        link_replist(clusterlist{i,6}) = NaN;
        
        for j = 1:size(clusterlist{i,3},2)
            oldvox1 = link(clusterlist{i,3}(j)).n1;
            oldvox2 = link(clusterlist{i,3}(j)).n2;
            if primary_node ~= oldvox1 && primary_node ~= oldvox2
                if ismember(oldvox1,clusterlist{i,1}) == 1
                    newvox = [primary_node,oldvox2];
                    newvoxidx = [clusterlist{i,2},link(clusterlist{i,3}(j)).point(end)];
                elseif ismember(oldvox2,clusterlist{i,1}) == 1
                    newvox = [oldvox1,primary_node];
                    newvoxidx = [link(clusterlist{i,3}(j)).point(1),clusterlist{i,2}];
                end
            elseif primary_node == oldvox1
                newvox = [primary_node,oldvox2];
                newvoxidx = [clusterlist{i,2},link(clusterlist{i,3}(j)).point(end)];
            elseif primary_node == oldvox2
                newvox = [oldvox1,primary_node];
                newvoxidx = [link(clusterlist{i,3}(j)).point(1),clusterlist{i,2}];
            end

            allowed_voxels = clusterlist{i,7};
            noncl_node = setdiff(newvox,primary_node);
            if npn_lut(noncl_node,1) ~= 0
                allowed_voxels = [allowed_voxels clusterlist{npn_lut(noncl_node,2),7}]; %#ok<AGROW>
            end
            % allowed_voxels = unique([[link(clusterlist{i,3}).point] [link(clusterlist{i,6}).point] clusterlist{i,7} vertcat(node(clusterlist{i,1}).idx)']);
            link(clusterlist{i,3}(j)).point = connect_27(newvoxidx(1),newvoxidx(2),allowed_voxels',sizes,offsetmask);
            link(clusterlist{i,3}(j)).n1 = newvox(1);
            link(clusterlist{i,3}(j)).n2 = newvox(2);
            
            outercon = newvox(newvox ~= primary_node);
            node(outercon).conn(ismember(node(outercon).conn,non_primary_nodes)) = primary_node;
        end
    
        newconn = clusterlist{i,4};
        for j = 1:size(newconn,2)
            if npn_lut(newconn(1,j),1) ~= 0
                newconn(1,j) = npn_lut(newconn(1,j),1);
            end
        end
        
        node(primary_node).idx = clusterlist{i,2};
        node(primary_node).links = clusterlist{i,3};
        node(primary_node).conn = newconn;
        node(primary_node).comx = clusterlist{i,5}(1);
        node(primary_node).comy = clusterlist{i,5}(2);
        node(primary_node).comz = clusterlist{i,5}(3);
        
    end

    % remove labeled nodes and rewrite node id's    
    counter = 1;
    for i = 1:size(node_replist,1)
        if ~isnan(node_replist(i,1))
            node_replist(i,1) = counter;
            counter = counter + 1;
        end
    end

    % remove labeled links and rewrite link id's
    counter = 1;
    for i = 1:size(link_replist,1)
        if ~isnan(link_replist(i,1))
            link_replist(i,1) = counter;
            counter = counter + 1;
        end
    end

    link = remove_links(link, link_replist, node_replist);
    node = remove_nodes(node, node_replist, link_replist);
    
    for i=1:length(node)
        [x,y,z] = ind2sub([sizes(1),sizes(2),sizes(3)],node(i).idx);
        node(i).idx = sub2ind([sizes(1)-2,sizes(2)-2,sizes(3)-2],x-1,y-1,z-1);
        node(i).comx = node(i).comx - 1;
        node(i).comy = node(i).comy - 1;
        node(i).comz = node(i).comz - 1;
    end

    for i=1:length(link)
        [x,y,z] = ind2sub([sizes(1),sizes(2),sizes(3)],link(i).point);
        link(i).point = sub2ind([sizes(1)-2,sizes(2)-2,sizes(3)-2],x-1,y-1,z-1);
    end
