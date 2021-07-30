%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PARAMETER FILE FOR ARGSLAB %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This file is the parameter file for ArGSLab. This is the only file that
% should be changed. After the parameters are filled in, save the file
% and run 'main.m'.

%% Which actions or analyses are to be performed
% Set the following switches as 'yes' to perform their corresponding action.

switch_tortuosity = 'yes';                  % Calculates the tortuosity or directness for the skeleton.
switch_linklength = 'yes';                  % Calculates the link density as a function of link length, and all node/link density paramaters
switch_visualize = 'yes';                   % Creates a set of visualization files useful for interepretation and publication.
switch_outputlabeling = 'yes';              % Displays updates of the process, primarily calculation times.
switch_optimizationtools = 'yes';           % Creates several tif stacks at certain points of the process. Useful for optimizing the fine tuning parameters.
switch_exporttxt = 'yes';                   % Creates txt files for all calculated output.

%% Main input variables

projectpath = 'Werkfolder';                 % Will perform actions on all tiff stacks in $projectpath$.
exclude = {};                               % Excludes all files and directories in $exclude$.
zframes = 'all';                            % The highest slice of the tiff stack that will be considered. If 'all', all frames will be imaged.
realpx = [1,1,1];                           % Dimensions of a single voxel. Used to calculate sizes, choose units carefully. By default in micrometer.
particlediameter = 10;                      % Give the approximate particle diameter in µm

% Coodinate diagram parameters
BoxSize_input           = [31.44,31.44,31.44];          % Set the maximum dimensions of the coordinates in all three directions.
BoxSize_output          = [47.1,47.1,47.1];             % Set the output box size in units of sigma.
Point_spread_function   = [0.15,0.15,.5];               % Increase in apparent size of particles due to Point Spread Function of imaging technique.

%% Fine tuning parameters
% The following parameters finetune certain aspects of different analyses.
% All of these are set to 'auto' by default, which performs an action with
% an automatic solution. Fine tuning can improve analyses in specific
% cases.

% Pre-skeletonization parameters
sigmablur = 2;                              % Sigma in Gaussian blur kernel; (2 * sigmablur + 1) should ideally be smaller than a particle radius.
binThres = 'auto';                          % Set threshold for binarization. 'auto' for Otsu's method
sesize = [.5,.5,.5];                        % Diameter in each dimension of 3D spherical structuring element for morphological closing. Units in sigma. Values recommended not be larger than sigma.
minfrac = .001;                             % All objects smaller than minfrac*maxobject are removed before skeletonization.
h_fill_thr = 1;                             % Any holes smaller than this threshold value will be filled up. Unit is particle volume.

% Skeletonization parameters
term_skel_thr = 1.5;                        % Throws away all terminal skeleton links that are smaller than this threshold. Unit is particle diameter.
coll_skel_thr = 0.9;                        % Collects any nodes that are closer together than this threshold, units in particle diameter. It is recommended to have coll_skel_thr <= term_skel_thr.

% Tortuosity parameters
edgenode_dist = 1;                          % Sets the region in which nodes exist are defined as edge nodes, in units of µm. It is recommended to set this larger than 1.5 sigma.

% Link length parameters
binsize = 250;                              % Sets the bin number of \r in the link length calculations
maxbin = 250;                               % Sets the maximum bin in the link length calculations, in µm.

% Visualization parameters
visualize_edges = 'no';                     % If 'no', no nodes that are defined as edge nodes ($edgenode_dist) and links leading to those nodes will be visualized.  
output_type = 'matlab';                     % If 'matlab', outputs 3D renders from matlab, if 'vtk', outputs vtk files for external use.
switch_cubify = 'no';                       % If 'yes', voxels in the output will be rendered as cubes, rather than using the pixel dimensions set by realpx.
swellskel = 2;                              % Swells the skeleton backbone in 3D rendering, only in visualizations. Has to be an integer.
nodesize = 3;                               % Swells the node in 3D rendering, only in visualizations. Has to be an integer.
