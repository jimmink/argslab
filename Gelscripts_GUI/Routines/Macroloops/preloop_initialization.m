%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INITIALIZATION PRELOOP %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sk_thr,cl_thr,filepaths,tort_data,shortestpaths,dtortuosity,ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio] = preloop_initialization(projectpath,exclude,term_skel_thr,coll_skel_thr,particlediameter,binsize,maxbin)

%% Initialize

if exist([projectpath,'/Output'], 'dir') > 0
   mkdir([projectpath,'/Output'])
end

sk_thr = term_skel_thr * particlediameter;
cl_thr = coll_skel_thr * particlediameter;

filepaths = indexpath(projectpath,exclude,'.txt');
if isempty(filepaths)
    filepaths = indexpath(projectpath,exclude,'.xyz');
end    
if isempty(filepaths)
    filepaths = indexpath(projectpath,exclude,'.tif');
end

for i = 1:size(filepaths,2)
    [~, fname, ~] = fileparts(filepaths{i});
    if ~exist([projectpath,'/Output/',fname], 'dir')
        mkdir([projectpath,'/Output/',fname])
    end
end

%% Preallocate matrices for summarized data

tort_data = zeros(size(filepaths,2),2);
shortestpaths = zeros(size(filepaths,2),3);
dtortuosity = zeros(size(filepaths,2),3);

ll_distribution = zeros(binsize,size(filepaths,2) + 1,'double');
dm = maxbin / binsize;
for i = 1:binsize
    ll_distribution(i,1) = dm .* (i - 1);
end

N_N = zeros(1,size(filepaths,2),'double');
N_L = zeros(1,size(filepaths,2),'double');
rho_N = zeros(1,size(filepaths,2),'double');
rho_L = zeros(1,size(filepaths,2),'double');
LN_ratio = zeros(1,size(filepaths,2),'double');