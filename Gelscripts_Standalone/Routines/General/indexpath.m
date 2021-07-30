function [ listing ] = indexpath( projectpath, exclude, extension )
% INDEXPATH lists paths in project folder with a specific extension.

% skip first two of directory, i.e. '.', '..'
skip = 2; 

% prepare arrays
mainlisting = dir(projectpath);
listing = cell(0);
c = 1;

% List all possible options in folder
for i = 1:(size(mainlisting,1)-skip) 
    if ~any(strcmp(exclude,{mainlisting(i+skip).name})) == 1
        listing{c} = [projectpath,'/',mainlisting(i+skip).name];
        c = c + 1;
    end
end

% remove file which do not contain extension
for i = 1:length(listing) 
    if isempty(regexp(listing{i},extension,'ignorecase'))
        listing{i} = [];
    end
end

% remove empty cells
listing = listing(~cellfun(@isempty, listing)); 

end

