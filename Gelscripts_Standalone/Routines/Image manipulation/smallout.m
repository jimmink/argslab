function [ Iout, CC ] = smallout( Ibin, conn, minfrac, switch_outputlabeling )
%  SMALLOUT Removes objects smaller than minfrac*maxobject. Similar to 
%  bwareaopen, but with list of areas in output.

    CC = bwconncomp(Ibin, conn);
    S = regionprops(CC, 'Area');
    L = labelmatrix(CC);

    %% remove small objects

    histvalues = cell2mat(struct2cell(S));
    minsize = max(histvalues)*minfrac;
    Iout = ismember(L, find([S.Area] >= minsize));

    %% display info

    if strcmp(switch_outputlabeling,'yes') == 1
        cmin = nnz(histvalues(:) < minsize);
        cmax = nnz(histvalues(:) >= minsize);
        fprintf('%d small object(s) removed; %d large object(s) kept \n',cmin,cmax);
    end
end

