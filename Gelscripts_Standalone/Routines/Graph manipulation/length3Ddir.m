function [ length3D ] = length3Ddir( node, startnode, endnode, realpx )
% LENGTH3DDIR calculates the distance between the endpoints of a link with
% given aspect ratios. Uses 3D-Pythagoras. 

length3D = 0;

% coordinates start node
x1 = node(startnode).comx;
y1 = node(startnode).comy;
z1 = node(startnode).comz;

% coordinates end node
x2 = node(endnode).comx;
y2 = node(endnode).comy;
z2 = node(endnode).comz;

% 3D pythagoras
length3D = length3D + sqrt((realpx(1)*(x2-x1))^2+(realpx(2)*(y2-y1))^2+(realpx(3)*(z2-z1))^2);

end