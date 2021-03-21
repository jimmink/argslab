function tort_summary = wrapup_tortuosity(tort_data,projectpath,dtortuosity,switch_exporttxt,pathstr)

tort_summary = zeros(1,2);

for i = size(tort_data,1):-1:1
    if isnan(tort_data(i,1))
        tort_data(i,:) = [];
    end
end

tort_summary(1,1) = mean(tort_data(:,1));

sumstds = sum(tort_data(:,2).^2);
summeans = sum((tort_data(:,1)-tort_summary(1,1)).^2);
totthings = size(tort_data,1);

tort_summary(1,2) = sqrt( (sumstds + summeans) / totthings);

save([projectpath,filesep,'Output/tortuosity_complete.mat'],'tort_data','tort_summary','dtortuosity')

if strcmp(switch_exporttxt,'yes') == 1
	fileid1 = fopen([pathstr,'/Output/tortuosity_xyz_perimage.txt'],'w');
    fprintf(fileid1, 'x-tortuosity\ty-tortuosity\tz-tortuosity\n');
    for i = 1:size(dtortuosity,1)
        fprintf(fileid1, [num2str(dtortuosity(i,1)),'\t',num2str(dtortuosity(i,2)),'\t',num2str(dtortuosity(i,3)),'\n']);
    end
    fclose(fileid1);
        
	fileid2 = fopen([pathstr,'/Output/tortuosity_combined_perimage.txt'],'w');
    fprintf(fileid2, 'tortuosity\tstandard deviation\n');
    for i = 1:size(tort_data,1)
        fprintf(fileid2, [num2str(tort_data(i,1)),'\t',num2str(tort_data(i,2)),'\n']);
    end
    fclose(fileid2);
    
	fileid3 = fopen([pathstr,'/Output/tortuosity_combined.txt'],'w');
	fprintf(fileid3, 'tortuosity\tstandard deviation\n');
	fprintf(fileid3, [num2str(tort_summary(1,1)),'\t',num2str(tort_summary(1,2)),'\n']);
    fclose(fileid3);
end


end