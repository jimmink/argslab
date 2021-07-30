function [ G ] = makeGraphobj( A )
%MAKEGRAPHOBJ makes a labelled Graph object from an adjencency matrix.

%% mark nodes for trace back

nnames = cell(length(A),1);
for i = 1:length(A)
    nnames{i} = num2str(i);
end

%% Make graph object

G = graph(A,nnames,'upper');

end

