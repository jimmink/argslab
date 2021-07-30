function wrapup_tort(tort_summary,pathstr)
% WRAPUP_TORT combines all tortuosity variables and saves as txt files.

fileid = fopen([pathstr,'/Output/Tortuosity_combined.txt'],'w');
fprintf(fileid, 'Tortuosity\tStandard Deviation\n');
fprintf(fileid, [num2str(tort_summary(1,1)),'\t',num2str(tort_summary(1,2)),'\n']);
fclose(fileid);