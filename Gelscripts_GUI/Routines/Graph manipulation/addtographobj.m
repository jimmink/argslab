function [ G ] = addtographobj( G , node )
% ADDTOGRAPHOBJ adds a single node to the graph object.

% Erik Maris 17-7-2020
fn = fieldnames(node); % get names of property
S = squeeze(struct2cell(node))'; % put in cell array

idx = 1:size(S,2); % prepare indices over which should be looped
idx(ismember(fn,{'links','ep'})) = [];

for ii = idx
    G.Nodes.(fn{ii}) = S(:,ii); % assign to graph
end

% set all edge values to zero. (Note: in 'node' they are not all zero.)
dummy = cell(size(S,1),1);
dummy(:) = {0};
G.Nodes.edge = dummy;

end