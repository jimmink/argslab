function [node,link] = add_lengths(node,link,realpx,sizes)

realpx2 = [realpx(2),realpx(1),realpx(3)];
pyth_lut = mk_p_lut(realpx2);
offsetmask = make_osm(sizes);

link(1).pointextended = [];
link(1).length = [];
for i = 1:size(link,2)
    if size(node(link(i).n1).idx,1) > 1                                                 % if node 1 has multiple idx
        link_beginend = [link(i).point(1),link(i).point(end)];
        n1_CoM = node(link(i).n1).CoM;
        if ~ismember(n1_CoM,link_beginend)                                              % check whether CoM(node 1) is at beginning or end
            n1_idx = node(link(i).n1).idx';                                             % if no
            [voxel_from_link,~,begin_or_end] = intersect(n1_idx,link_beginend);         % find whether beginning or end of link is in node 1.idx
            if begin_or_end == 1                                                        % add the nodes necessary to reach node 1 CoM 
                fullpath = connect_27(n1_CoM,voxel_from_link,n1_idx,sizes,offsetmask);
                link(i).pointextended = [fullpath(1:end-1) link(i).point];
            else
                fullpath = connect_27(voxel_from_link,n1_CoM,n1_idx,sizes,offsetmask);
                link(i).pointextended = [link(i).point fullpath(2:end)];
            end            
        end
    end
    
    if size(node(link(i).n2).idx,1) > 1                                                 % if node 1 has multiple idx
        link_beginend = [link(i).point(1),link(i).point(end)];
        n2_CoM = node(link(i).n2).CoM;
        if ~ismember(n2_CoM,link_beginend)                                              % check whether CoM(node 1) is at beginning or end
            n2_idx = node(link(i).n2).idx';                                             % if no
            [voxel_from_link,~,begin_or_end] = intersect(n2_idx,link_beginend);         % find whether beginning or end of link is in node 1.idx
            if begin_or_end == 1                                                        % add the nodes necessary to reach node 1 CoM 
                fullpath = connect_27(n2_CoM,voxel_from_link,n2_idx,sizes,offsetmask);
                link(i).pointextended = [fullpath(1:end-1) link(i).point];
            else
                fullpath = connect_27(voxel_from_link,n2_CoM,n2_idx,sizes,offsetmask);
                link(i).pointextended = [link(i).point fullpath(2:end)];
            end            
        end
    end

    if isempty(link(i).pointextended)
        link(i).pointextended = link(i).point;
    end
            
    link(i).length = get_pathlength(link(i).pointextended,pyth_lut,offsetmask);
        
end