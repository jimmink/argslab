function [node, link] = thoroughclean(node, link, nonendnodes, sizes, threshold,realpx)
% THOROUGHCLEAN applies a thorough cleaning, removing only twice connected 
% nodes, non-connected nodes, unnecessarily kept node voxels, and terminal 
% nodes shorter than a threshold length. 

    %% Remove all unbranched nodes

    % prepare distance lookup matrix
    pyth_lut = mk_p_lut(realpx);
    offsetmask = make_osm(sizes);
    
    sw_clean = 1;
    while sw_clean == 1
        % find the links and nodes that should be merged and deleted
        % respectively
        nodes_ub = cellfun(@(x) size(x,2), {node(1:nonendnodes).links}) == 2;
        node_tbm = sort(find(nodes_ub==1)); % sort should not be necessary.
        links_tbm = {node(nodes_ub).links};
        if size(node_tbm,2) == 0
            sw_clean = 0;
        end

        % make sure no colliding links and nodes are merged in this run
        templist = zeros(size(links_tbm,2),1);
        counter = 1;
        counter2 = 1;
        while size(node_tbm,2) >= counter
            if sum(ismember(links_tbm{counter},templist)) > 0
                links_tbm(:,counter) = [];
                node_tbm(:,counter) = [];
            else
                counter = counter + 1;
                templist(2*counter2 - 1) = links_tbm{counter2}(1);
                templist(2*counter2) = links_tbm{counter2}(2);
                counter2 = counter2 + 1;
            end
        end

        % replace the links with its longer versions
        for i = 1:size(links_tbm,2)
            [link,node] = linkmerge(link,links_tbm{1,i},node,node_tbm(i),sizes,offsetmask);
        end

        % make a list of replacement link indices and label links to be deleted
        links_tbm = cellfun(@(x)x(2),links_tbm);
        link_replist = zeros(size(link,2),1);
        link_replist(links_tbm) = NaN;
        counter = 1;
        for i = 1:size(link,2)
            if ~isnan(link_replist(i))
                link_replist(i) = counter;
                counter = counter + 1;
            end
        end

        % make a list of replacement node indices and label nodes to be deleted
        node_replist = zeros(size(node,2),1);
        node_replist(node_tbm) = NaN;
        counter = 1;
        for i = 1:size(node,2)
            if ~isnan(node_replist(i))
                node_replist(i) = counter;
                counter = counter + 1;
            end
        end

        % remove labeled nodes, and give remaining nodes (and links in node 
        % struct array) new indices
        node = remove_nodes(node, node_replist, link_replist);

        % remove labeled links, and rename the remaining links
        link = remove_links(link, link_replist, node_replist);

        %% It can be that ring-loops are created by this while loop. 
        % The following removes them.

        link_replist = zeros(size(link,2),1);
        node_replist = zeros(size(node,2),1);
        for i = 1:size(node,2)
            if length(node(i).links) ~= length(unique(node(i).links))
                for j = 1:size(node(i).links,2)
                    if sum(node(i).links==node(i).links(j)) > 1
                        link_replist(node(i).links(j)) = NaN;
                    end
                end
                if length(unique(node(i).links)) == 1
                    node_replist(i) = NaN;
                end
            end
        end

        counter = 1;
        for i = 1:size(link_replist,1)
            if ~isnan(link_replist(i))
                link_replist(i) = counter;
                counter = counter + 1;
            end
        end

        counter = 1;
        for i = 1:size(node_replist,1)
            if ~isnan(node_replist(i))
                node_replist(i) = counter;
                counter = counter + 1;
            end
        end

        % remove labeled nodes, and give remaining nodes (and links in node 
        % struct array) new indices
        node = remove_ringlinks(node, node_replist, link_replist);

        % remove labeled links, and rename the remaining links
        link = remove_links(link, link_replist, node_replist);    

    end

    %% remove terminal branches smaller than the threshold value

    % label all terminal branch nodes with 2, and the point where they meet the
    % main cluster with 3
    temp = num2cell([node(:).ep]*2);
    [node.tn] = temp{:};
    node(1).dsn = [];
    node(1).path = [];

    old_tn = zeros(size(node));
    while ~isequal(old_tn,[node.tn])
        old_tn = [node.tn];
        newcons = [];
        for i = 1:size(node,2)
            if node(i).tn == 2
                newcons = [newcons node(i).conn];
            end
        end
        newcons = unique(newcons);
        for i = size(newcons,2):-1:1
            if node(newcons(1,i)).tn == 2
                newcons(:,i) = [];
            else
                node(newcons(1,i)).tn = 1;
            end
        end
        for i = 1:size(node,2)
            if node(i).tn == 1
                if sum([node(node(i).conn).tn] < 2) < 2
                    node(i).tn = 2;
                else
                    node(i).tn = 0;
                end
            end
        end
    end

    % label the beginning points of a branch with 3
    for i = 1:size(node,2)
        if node(i).tn == 2
            neighbors = node(i).conn;
            neighbors = neighbors([node(neighbors).tn] == 0);
            if isempty(neighbors)
                continue
            end
            node(neighbors).tn = 3;
        end
    end

    % for all terminal nodes, find the first node downstream
    for i = 1:size(node,2)
        if node(i).tn == 3
            neighbors = node(i).conn([node(node(i).conn).tn] == 2);
            for j = 1:size(neighbors,2)
                node(neighbors(j)).dsn = i;
            end
            done_nodes = i;
            notdone_nodes = setdiff(neighbors,done_nodes);
            while ~isempty(notdone_nodes)
                neighbors = node(notdone_nodes(1)).conn;
                neighbors = setdiff(setdiff(neighbors,done_nodes),notdone_nodes);
                % neighbors = neighbors([node(neighbors).tn] == 2);  redundant extra check
                for j = 1:size(neighbors,2)
                    node(neighbors(1,j)).dsn = notdone_nodes(1);
                end
                notdone_nodes = [notdone_nodes neighbors];
                done_nodes = [done_nodes notdone_nodes(1)];
                notdone_nodes(1) = [];
            end
        end
    end

    % for all terminal nodes, form the full downstream path
    for i = 1:size(node,2)
        if node(i).tn == 2 && ~isempty(node(i).dsn)
            onefurtherdown = node(i).dsn;
            node(i).path = [i onefurtherdown];
            while node(onefurtherdown).tn == 2
                onefurtherdown = node(onefurtherdown).dsn;
                node(i).path = [node(i).path onefurtherdown];
            end
        end
    end

    % get the pixels for the paths
    node(1).voxpath = [];
    node(1).termdist = [];
    for i = 1:size(node,2)
        if node(i).tn == 2 && ~isempty(node(i).dsn)
            for j = 1:size(node(i).path,2) - 1
                node1 = node(i).path(j);
                node2 = node(i).path(j + 1);
                linking_12 = intersect(node(node1).links,node(node2).links);
                if size(linking_12,2) > 1
                    linkvoxels = link(linking_12(1)).point;
                else
                    linkvoxels = link(linking_12).point;
                end
                if j == 1
                    voxelpath = linkvoxels;
                elseif size(node(node1).idx,1) > 1
                    prev_lastvox = intersect([voxelpath(1),voxelpath(end)],node(node1).idx');
                    curr_firstvox = intersect([linkvoxels(1),linkvoxels(end)],node(node1).idx');
                    if ~isequal(prev_lastvox,curr_firstvox)
                        overnode_path = connect_27(prev_lastvox,curr_firstvox,node(node1).idx,sizes,offsetmask);
                        if prev_lastvox == voxelpath(1)
                            voxelpath = [fliplr(overnode_path) voxelpath(2:end)];
                        elseif prev_lastvox == voxelpath(end)
                            voxelpath = [voxelpath overnode_path(2:end)];
                        end
                    end
                end
                if j ~= 1
                    [~, ilinkvx, ivxpath] = intersect(linkvoxels,voxelpath);
                    if ilinkvx == 1 && ivxpath == 1
                        voxelpath = [fliplr(linkvoxels(2:end)) voxelpath];
                    elseif ilinkvx == 1 && ivxpath == size(voxelpath,2)
                        voxelpath = [voxelpath linkvoxels(2:end)];
                    elseif ilinkvx == size(linkvoxels,2) && ivxpath == 1
                        voxelpath = [linkvoxels(1:end-1) voxelpath];
                    elseif ilinkvx == size(linkvoxels,2) && ivxpath == size(voxelpath,2)
                        voxelpath = [voxelpath fliplr(linkvoxels(1:end-1))];
                    end
                end
            end
            node(i).voxpath = voxelpath;

            % calculate the length of voxelpath

            [x,y,z] = ind2sub(sizes,voxelpath);
            dist = 0;
            for j = 1:size(node(i).voxpath,2)-1
                neightype = sub2ind([3,3,3],x(j) - x(j+1) + 2,y(j) - y(j+1) + 2,z(j) - z(j+1) + 2);
                dist = dist + pyth_lut(neightype);
            end
            node(i).termdist = dist;
        end
    end

    links_tbd = zeros(size(link,2),1);
    nodes_tbd = zeros(size(node,2),1);

    % if an edge branch node, smaller than threshold, and a current end node,
    % remove from connected node and label for deletion

    for i = 1:size(node,2)
        if ~isempty(node(i).termdist)
            if ((node(i).tn == 2) && (node(i).termdist < threshold) && (size(node(i).links,2) == 1))
                dsn = node(i).dsn;
                newconnlist = node(dsn).conn(node(dsn).conn ~= i);
                node(dsn).conn = newconnlist;
                newlinklist = node(dsn).links(node(dsn).links ~= node(i).links);
                node(dsn).links = newlinklist;
                links_tbd(i) = node(i).links;
                nodes_tbd(i) = i;
            end
        end 
    end

    links_tbd = sort(links_tbd(links_tbd~=0));
    nodes_tbd = sort(nodes_tbd(nodes_tbd~=0));

    link_replist = zeros(size(link,2),1);
    link_replist(links_tbd) = NaN;
    counter = 1;
    for i = 1:size(link,2)
        if ~isnan(link_replist(i))
            link_replist(i) = counter;
            counter = counter + 1;
        end
    end

    node_replist = zeros(size(node,2),1);
    node_replist(nodes_tbd) = NaN;
    counter = 1;
    for i = 1:size(node,2)
        if ~isnan(node_replist(i))
            node_replist(i) = counter;
            counter = counter + 1;
        end
    end

    node = rmfield(node,{'tn','dsn','path','voxpath','termdist'});
    node = remove_nodes(node, node_replist, link_replist);
    link = remove_links(link, link_replist, node_replist);    

    %% remove "speckle"- end nodes
    % the cleaning procedure might leave single voxels directly bordering a
    % node, as such seemingly disconnected in node/link. This removes them.

    nodes_tbd = zeros(size(node,2),1);
    counter = 1;
    for i = 1:size(node,2)
        if isempty(node(i).links) == 1
            nodes_tbd(counter) = i;
            counter = counter + 1;
        end
    end
    nodes_tbd = sort(nodes_tbd(nodes_tbd~=0));

    node_replist = zeros(size(node,2),1);
    node_replist(nodes_tbd) = NaN;
    counter = 1;
    for i = 1:size(node,2)
        if ~isnan(node_replist(i))
            node_replist(i) = counter;
            counter = counter + 1;
        end
    end

    node = remove_nodes(node, node_replist, (1:size(link,2))');
    link = remove_links(link, (1:size(link,2))', node_replist);

    %% remove unnecessarily filled voxels in multiple-voxel nodes

    for i = 1:size(node,2)
        if size(node(i).idx,1) > 1 

            % find all voxels that start a link originating from this node
            linkvoxels = zeros(1,size(node(i).links,2)); 
            for j = 1:size(node(i).links,2)
                linkvoxels(1,j) = intersect(node(i).idx,[link(node(i).links(j)).point(1),link(node(i).links(j)).point(end)]);            
            end
            linkvoxels = unique(linkvoxels);

            if length(linkvoxels) ~= length(node(i).idx)
                % get the cube encompassing all linkvoxels, and label each cluster
                % of linkvoxels with a unique id.
                clusterlist = label_clusters(linkvoxels,node(i).idx,sizes);

                % find and add the minimum amount of voxels necessary to connect
                % all clusters. The added voxels have to come from the original
                % node voxels. It does this by connecting a cluster to the first
                % cluster, one at a time.
                for j = 2:max(clusterlist(:,2))
                    cluster1 = clusterlist(clusterlist(:,2)==1);
                    cluster2 = clusterlist(clusterlist(:,2)==j);
                    pathways = cell(size(cluster1,1)*size(cluster2,1),1);
                    counter = 1;
                    for k = 1:size(cluster1,1)
                        for l = 1:size(cluster2,1)
                            pathways{counter,1} = connect_27(cluster1(k),cluster2(l),node(i).idx,sizes,offsetmask);
                            counter = counter + 1;
                        end
                    end
                    [~,minid] = min(cellfun('size', pathways, 2));
                    clusterlist(clusterlist(:,2)==j,2) = 1;
                    newvox = setdiff(pathways{minid},clusterlist(:,1)');
                    newvox = [newvox' ones(size(newvox'))];
                    clusterlist = vertcat(clusterlist,newvox);
                end


                % Remove all unused voxels.
                for j = size(node(i).idx,1):-1:1
                    if ismember(node(i).idx(j),clusterlist(:,1)) == 0
                        node(i).idx(j) = [];
                    end
                end
            end
        end
    end
end