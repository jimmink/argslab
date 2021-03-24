function [node, link] = firstclean(node, link, nonendnodes, sizes)
% FIRSTCLEAN is a graph cleaning routine that removes unbranched nodes 
% connected to only two nodes, non-connected nodes and unnecessarily filled
% voxels contributing to nodes. Note that single-connected nodes and their
% links are removed in the later used THOROUGHCLEAN.

%% Remove all unbranched nodes

offsetmask = make_osm(sizes);

sw_clean = 1;
while sw_clean == 1
    % find the links and nodes that should be merged and deleted
    % respectively. 
    nodes_ub = cellfun(@(x) size(x,2), {node(1:nonendnodes).links}) == 2;
    node_tbm = sort(find(nodes_ub==1)); % sort should not be necessary.
    links_tbm = {node(nodes_ub).links};
    
    % If there are no links or nodes that are found to be deleted, label
    % this cycle to be the final one.
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
            [~,ind,~] = unique(node(i).links);
            temp = node(i).links;
            temp(ind) = [];
            link_replist(temp) = NaN;
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
            linkvoxels(1,j) = intersect(node(i).idx,link(node(i).links(j)).point);            
        end
        linkvoxels = unique(linkvoxels);
        
        if length(node(i).idx) ~= length(linkvoxels)

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