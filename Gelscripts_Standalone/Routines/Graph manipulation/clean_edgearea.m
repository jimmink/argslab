function nodeic = clean_edgearea(nodeic,node)
% CLEAR_EDGEAREA removes node connections in the node list should they be
% wrongly leading to the edge.

    for i = size(nodeic,1):-1:1
        nodeconn = node(nodeic(i)).conn;
        if ((size(nodeconn,2) == 1) && (ismember(nodeconn,nodeic) == 1)) 
            nodeic(i,1) = [];
        elseif any(ismember(nodeconn,nodeic) == 1)
            nodeic(i,2) = [];
        end
    end

end