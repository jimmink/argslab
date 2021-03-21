function wrapup_tort(tort_summary,pathstr)

fileid = fopen([pathstr,'/Output/tort_combined.txt'],'w');
fprintf(fileid, 'Tortuosity\tStandard Deviation\n');
fprintf(fileid, [num2str(tort_summary(1,1)),'\t',num2str(tort_summary(1,2)),'\n']);
fclose(fileid);