function exporttxt_gen(skel,node,link,pathstr,fname)
% EXPORTTXT_GEN exports the skeleton, the node list, and the link list as
% .txt files.

fileid = fopen([pathstr,'/Output/',fname,'/Skeleton.txt'],'w');
for z = 1:size(skel,3)
    for y = 1:size(skel,2)
        line = repmat('0 ',[1 size(skel,1)]);
        for x = 1:size(skel,1)
            if skel(x,y,z) == 1
                line(1,(x*2)-1) = 1;
            end
        end
        fprintf(fileid,line);
        fprintf(fileid, '\n'); 
    end
    fprintf(fileid, '\n');
end
fclose(fileid);

fileid2 = fopen([pathstr,'/Output/',fname,'/Nodelist.txt'],'w');
line = 'node\tvoxel\tlinks\tconnected nodes\tx-coordinate\ty-coordinate\tz-coordinate\n';
fprintf(fileid2, line);
for i = 1:size(node,2)
    linksep = sprintf('%i;', node(1,i).links);
    linksep = linksep(1:end-1);
	connsep = sprintf('%i;', node(1,i).conn);
    connsep = connsep(1:end-1);
    line = horzcat(num2str(node(1,i).CoM),'\t',linksep,'\t',connsep,'\t',num2str(node(1,i).comx),'\t',num2str(node(1,i).comy),'\t',num2str(node(1,i).comz),'\n');
    fprintf(fileid2, line);
end
fclose(fileid2);

fileid3 = fopen([pathstr,'/Output/',fname,'/Linklist.txt'],'w');
line = 'node 1\tnode 2\tlink length\tlink voxels\n';
fprintf(fileid3, line);
for i = 1:size(link,2)
    voxelsep = sprintf('%i;', link(1,i).pointextended);
    voxelsep = voxelsep(1:end-1);
    line = horzcat(num2str(link(1,i).n1),'\t',num2str(link(1,i).n2),'\t',num2str(link(1,i).length),'\t',voxelsep,'\n');
    fprintf(fileid3, line);
end
fclose(fileid3);
