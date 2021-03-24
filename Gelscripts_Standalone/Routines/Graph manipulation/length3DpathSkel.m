function [ length3D, link] = length3DpathSkel( link, skelsize, nnode, node, idxj, realpx )
% LENGTH3DPATHSKEL calculates the length of a link with given aspect ratios
% Includes center of mass of voxels. input nlink, e.g. node(i).links(idx(j))

    nlink = node(nnode).links(idxj);

    length3D = 0;

    % path of voxels in link
    for i = 1:(length(link(nlink).point)-1)
        [x1,y1,z1] = ind2sub(skelsize,link(nlink).point(i)); % coordinates voxel i
        [x2,y2,z2] = ind2sub(skelsize,link(nlink).point(i+1)); % coordinates voxel i+1
        length3D = length3D + sqrt((realpx(1)*(x2-x1))^2+(realpx(2)*(y2-y1))^2+(realpx(3)*(z2-z1))^2); % 3D pythagoras
    end

    % first and last voxels to center of mass of node

    if(nnode==link(node(nnode).links(idxj)).n1) % if we are the starting point of a link//if link index == n1
        [x1,y1,z1] = ind2sub(skelsize,link(nlink).point(1)); % coordinates first voxel
        x2 = node(nnode).comx; % coordinates start node
        y2 = node(nnode).comy;
        z2 = node(nnode).comz;
        length3D = length3D + sqrt((realpx(1)*(x2-x1))^2+(realpx(2)*(y2-y1))^2+(realpx(3)*(z2-z1))^2); % 3D pythagoras
        [x1,y1,z1] = ind2sub(skelsize,link(nlink).point(length(link(nlink).point))); % coordinates last voxel
        endnode = node(nnode).conn(idxj); % number of endnode
        x2 = node(endnode).comx; % coordinates end node
        y2 = node(endnode).comy;
        z2 = node(endnode).comz;
        length3D = length3D + sqrt((realpx(1)*(x2-x1))^2+(realpx(2)*(y2-y1))^2+(realpx(3)*(z2-z1))^2); % 3D pythagoras
    end
    if(nnode==link(node(nnode).links(idxj)).n2) % if we are the end point//if link index == n2
        [x1,y1,z1] = ind2sub(skelsize,link(nlink).point(length(link(nlink).point))); % coordinates last voxel
        x2 = node(nnode).comx; %coordinates start node
        y2 = node(nnode).comy;
        z2 = node(nnode).comz;
        length3D = length3D + sqrt((realpx(1)*(x2-x1))^2+(realpx(2)*(y2-y1))^2+(realpx(3)*(z2-z1))^2); % 3D pythagoras
        [x1,y1,z1] = ind2sub(skelsize,link(nlink).point(1)); % coordinates first voxel
        endnode = node(nnode).conn(idxj); % number of endnode
        x2 = node(endnode).comx; % coordinates end node
        y2 = node(endnode).comy;
        z2 = node(endnode).comz;
        length3D = length3D + sqrt((realpx(1)*(x2-x1))^2+(realpx(2)*(y2-y1))^2+(realpx(3)*(z2-z1))^2); % 3D pythagoras
    end


end