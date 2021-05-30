function wrapup_ll(ll_distribution,ll_summary,NN_summary,NL_summary,rhoN_summary,rhoL_summary,LNr_summary,pathstr)

fileid = fopen([pathstr,'/Output/Summary_combined.txt'],'w');
fprintf(fileid, 'Node number\tStandard Deviation\n');
fprintf(fileid, [num2str(NN_summary(1,1)),'\t',num2str(NN_summary(1,2)),'\n']);
fprintf(fileid,'\n');
fprintf(fileid, 'Link number\tStandard Deviation\n');
fprintf(fileid, [num2str(NL_summary(1,1)),'\t',num2str(NL_summary(1,2)),'\n']);
fprintf(fileid,'\n');
fprintf(fileid, 'Node density\tStandard Deviation\n');
fprintf(fileid, [num2str(rhoN_summary(1,1)),'\t',num2str(rhoN_summary(1,2)),'\n']);
fprintf(fileid,'\n');
fprintf(fileid, 'Link density\tStandard Deviation\n');
fprintf(fileid, [num2str(rhoL_summary(1,1)),'\t',num2str(rhoL_summary(1,2)),'\n']);
fprintf(fileid,'\n');
fprintf(fileid, 'Link/node ratio\tStandard Deviation\n');
fprintf(fileid, [num2str(LNr_summary(1,1)),'\t',num2str(LNr_summary(1,2)),'\n']);
fclose(fileid);

fileid2 = fopen([pathstr,'/Output/Summary_linklength.txt'],'w');
fprintf(fileid2, 'Lambda\tÑ(Lambda)\tStandard Deviation\n');
for i = 1:size(ll_summary,1)
    fprintf(fileid2,[num2str(ll_summary(i,1)),'\t',num2str(ll_summary(i,2)),'\t',num2str(ll_summary(i,3)),'\n']);
end
fclose(fileid2);

fileid3 = fopen([pathstr,'/Output/Linklength_perimage.txt'],'w');
fprintf(fileid3, 'Lambda');
for i = 1:size(ll_distribution,2)-1
    fprintf(fileid3, ['\t Ñ(Lambda), file ',num2str(i)]);    
end
fprintf(fileid3,'\n');
for i = 1:size(ll_distribution,1)
    fprintf(fileid3,[num2str(ll_distribution(i,1)),'\t']);
    for j = 2:size(ll_distribution,2)
        fprintf(fileid3,[num2str(ll_distribution(i,j)),'\t']);
    end
    fprintf(fileid3,'\n');
end
fclose(fileid3);
    
    