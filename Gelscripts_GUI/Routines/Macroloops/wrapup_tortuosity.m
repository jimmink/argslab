function Tortuosity_summary = wrapup_tortuosity(tort_data,dtortuosity,switch_exporttxt,switch_xyzsep,pathstr)

Tortuosity_summary = zeros(1,2);

for i = size(tort_data,1):-1:1
    if isnan(tort_data(i,1))
        tort_data(i,:) = [];
    end
end

Tortuosity_summary(1,1) = mean(tort_data(:,1));

sumstds = sum(tort_data(:,2).^2);
summeans = sum((tort_data(:,1)-Tortuosity_summary(1,1)).^2);
totthings = size(tort_data,1);

Tortuosity_summary(1,2) = sqrt( (sumstds + summeans) / totthings);

if switch_exporttxt == 1
    if switch_xyzsep == 1
    	fileid1 = fopen([pathstr,'/Output/Tortuosity_xyz_perimage.txt'],'w');
        fprintf(fileid1, 'x-tortuosity\ty-tortuosity\tz-tortuosity\n');
        for i = 1:size(dtortuosity,1)
            fprintf(fileid1, [num2str(dtortuosity(i,1)),'\t',num2str(dtortuosity(i,2)),'\t',num2str(dtortuosity(i,3)),'\n']);
        end
        fclose(fileid1);
    end
    
	fileid3 = fopen([pathstr,'/Output/Tortuosity_combined.txt'],'w');
	fprintf(fileid3, 'tortuosity\tstandard deviation\n');
	fprintf(fileid3, [num2str(Tortuosity_summary(1,1)),'\t',num2str(Tortuosity_summary(1,2)),'\n']);
    fclose(fileid3);
end


end