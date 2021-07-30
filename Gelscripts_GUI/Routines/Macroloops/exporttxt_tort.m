function exporttxt_tort(tort_data,dtortuosity,dxpath,dypath,dzpath,dxeucl,dyeucl,dzeucl,dxtortuosity,dytortuosity,dztortuosity,switch_tortinfo,pathstr,fname)
% EXPORTTXT_TORT exports all the different possible data relating to the
% tortuosity data.

if switch_tortinfo == 1
    fileidx = fopen([pathstr,'/Output/',fname,'/Tortuosity_xpaths.txt'],'w');
    fprintf(fileidx, 'Euclidean distance\tGel path distance\tTortuosity\n');
    for i = 1:size(dxtortuosity,1)
        fprintf(fileidx,[num2str(dxeucl(i)),'\t',num2str(dxpath(i)),'\t',num2str(dxtortuosity(i)),'\n']);
    end
    fclose(fileidx);

    fileidy = fopen([pathstr,'/Output/',fname,'/Tortuosity_ypaths.txt'],'w');
    fprintf(fileidy, 'Euclidean distance\tGel path distance\tTortuosity\n');
    for i = 1:size(dytortuosity,1)
        fprintf(fileidy,[num2str(dyeucl(i)),'\t',num2str(dypath(i)),'\t',num2str(dytortuosity(i)),'\n']);
    end
    fclose(fileidy);

    fileidz = fopen([pathstr,'/Output/',fname,'/Tortuosity_zpaths.txt'],'w');
    fprintf(fileidz, 'Euclidean distance\tGel path distance\tTortuosity\n');
    for i = 1:size(dztortuosity,1)
        fprintf(fileidz,[num2str(dzeucl(i)),'\t',num2str(dzpath(i)),'\t',num2str(dztortuosity(i)),'\n']);
    end
    fclose(fileidz);
end

fileidsum = fopen([pathstr,'/Output/',fname,'/Tortuosity_summarized.txt'],'w');
fprintf(fileidsum, 'Average tortuosity\tStandard Deviation\n');
fprintf(fileidsum,[num2str(tort_data(1,1)),'\t',num2str(tort_data(1,2)),'\n']);
fprintf(fileidsum,'\n');
fprintf(fileidsum,'In x-direction\tIn y-direction\tIn z-direction\n');
fprintf(fileidsum,[num2str(dtortuosity(1,1)),'\t',num2str(dtortuosity(1,2)),'\t',num2str(dtortuosity(1,3)),'\n']);
fclose(fileidsum);