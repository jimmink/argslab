function vis_projections(pathstr,fname,skel,enlargednodes,pixeldimensions,type)

[fo,vo] = isosurface(skel,0.5);
[fe,ve,ce] = isocaps(skel,0.5);
[fon,von] = isosurface(enlargednodes,0.5);
[fen,ven,cen] = isocaps(enlargednodes,0.5);

figure(3)
p1 = patch('Faces', fo, 'Vertices', vo);
p1.FaceColor = 'black';
p1.EdgeColor = 'black';

p2 = patch('Faces', fe, 'Vertices', ve, 'FaceVertexCData', ce);
p2.FaceColor = 'interp';
p2.EdgeColor = 'none';
axis([0 size(skel,1) 0 size(skel,2) 0 size(skel,3)])
daspect(1./pixeldimensions)

p3 = patch('Faces', fon, 'Vertices', von);
p3.FaceColor = 'red';
p3.EdgeColor = 'red';

p4 = patch('Faces', fen, 'Vertices', ven, 'FaceVertexCData', cen);
p4.FaceColor = 'interp';
p4.EdgeColor = 'none';
axis([0 size(skel,1) 0 size(skel,2) 0 size(skel,3)])
daspect(1./pixeldimensions)


ax = gca;
ax.BoxStyle = 'full';
ax.LineWidth = 2;
ax.XTick = [];
ax.YTick = [];
ax.ZTick = [];
box on

view(45,45)
saveas(figure(3),[pathstr,'/Output/',fname,'/Projection_-xy-z_',type,'.png'])

view(-45,45)
saveas(figure(3),[pathstr,'/Output/',fname,'/Projection_xy-z_',type,'.png'])

view(45,-45)
saveas(figure(3),[pathstr,'/Output/',fname,'/Projection_-xyz_',type,'.png'])

view(-45,-45)
saveas(figure(3),[pathstr,'/Output/',fname,'/Projection_xyz_',type,'.png'])

view(90,90)
saveas(figure(3),[pathstr,'/Output/',fname,'/Projection_',type,'.fig'])

close all