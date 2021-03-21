%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SKELETONIZATION-BASED ANALYSIS ROUTINES FOR ARRESTED NETWORK STRUCTURES %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Jasper N. Immink and J. J. Erik Maris. Published in March 2021.

% This file is the main ArGSLab script. Running this script means running
% the entire package.
% Changing parameters should be done in 'parameters.m'. This file should 
% not be changed. 

%% Preparation

clear
addpath(genpath(fullfile(fileparts(mfilename('fullpath')),['.' filesep]))) 
cd(fileparts(mfilename('fullpath'))) 

%% Import parameters

run('parameters.m')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ;                        % Pixelradius of nodes in the 3D renderings. Has to be an integer, 0 turns it off. High integers cause very long calculation times.

%% Initialize

[sk_thr,cl_thr,filepaths,tort_data,shortestpaths,dtortuosity,ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio] = preloop_initialization(projectpath,exclude,term_skel_thr,coll_skel_thr,particlediameter,binsize,maxbin);

%% Working loops

for a = 1:size(filepaths,2)

    [pathstr, fname, extension] = fileparts(filepaths{a});
    disp(['Working on: ' fname])
    
    %% Transform coordinate diagrams into images
    
    if strcmp(extension,'.txt') || strcmp(extension,'.xyz')
        
        if strcmp(switch_outputlabeling,'yes') == 1
            tic;
        end
        coord2tif(realpx,particlediameter,filepaths{a},BoxSize_input,BoxSize_output,Point_spread_function);
        if strcmp(switch_outputlabeling,'yes') == 1
            print_timemin(toc, 'diagram to image stack');
        end
        
    end
    
    
    %% Preprocessing
    
    if strcmp(switch_outputlabeling,'yes') == 1
        tic;
    end

    [Ifl, Iraw, Ibin] = project_prep(a,filepaths,zframes,sigmablur,binThres,switch_outputlabeling,switch_optimizationtools,sesize,minfrac);

    if strcmp(switch_outputlabeling,'yes') == 1
        print_timemin(toc, 'preprocessing');
    end
    
    %% Skeletonization

    if strcmp(switch_outputlabeling,'yes') == 1
        tic;
    end

    skel_raw = skeleton3D(Ifl); 
    
    if strcmp(switch_optimizationtools,'yes') == 1 || strcmp(switch_tortuosity,'yes') == 1
        [skel_raw, Apath, node, ~, node_raw, link_raw] = wrapper_firstclean(skel_raw, realpx);
    end
    
	if strcmp(switch_outputlabeling,'yes') == 1
        print_timemin(toc, 'skeletonization');
    end

    %% Tortuosity

    if strcmp(switch_tortuosity,'yes') == 1
        if strcmp(switch_outputlabeling,'yes') == 1
            tic;
        end
               
        [tort_data,shortestpaths,dtortuosity,dxpath,dypath,dzpath,dxeucl,dyeucl,dzeucl,dxtortuosity,dytortuosity,dztortuosity] = project_tortuosity(a,Apath,node,skel_raw,realpx,particlediameter,edgenode_dist,tort_data,shortestpaths,dtortuosity);
        
        if strcmp(switch_outputlabeling,'yes') == 1
            print_timemin(toc, 'tortuosity');
        end
    end
    
    %% Uncleaned skeleton visualization
    
    if strcmp(switch_optimizationtools,'yes') == 1
        if strcmp(switch_outputlabeling,'yes') == 1
            tic;
        end
        
        visualize_preclean(skel_raw,node,Iraw,Ifl,swellskel,pathstr,fname,nodesize,realpx,output_type,switch_cubify);
        
        if strcmp(switch_outputlabeling,'yes') == 1
            vistime1 = toc;
        end
    end

    %% Thorough cleaning
    
    if strcmp(switch_outputlabeling,'yes') == 1
        tic;
    end

    [skel, Apath, node, link] = wrapper_thoroughclean(skel_raw, sk_thr, realpx, cl_thr);

    if strcmp(switch_outputlabeling,'yes') == 1
        print_timemin(toc, 'cleaning');
    end
    
    %% Remove all edge nodes and links, if required
    
    if strcmp(visualize_edges,'no') == 1
        [skel, Apath, node, link] = wrapper_edgeclean(skel, edgenode_dist, particlediameter, realpx);
    end
    
	%% Save skeleton, if required

    if strcmp(switch_optimizationtools,'yes') == 1
        save([pathstr,'/Output/',fname,'/skeleton.mat'],'skel','Apath','node','link');
    end

    %% Link length and node/link denisities

    if strcmp(switch_linklength,'yes') == 1 || ...
            strcmp(switch_visualize,'yes ') == 1 || strcmp(switch_optimizationtools,'yes') == 1
        if strcmp(switch_outputlabeling,'yes') == 1
            tic;
        end
        
        [ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio] = project_linklength(a,skel,node,link,realpx,particlediameter,switch_linklength,switch_visualize,maxbin,binsize,ll_distribution,pathstr,fname,N_N,N_L,rho_N,rho_L,LN_ratio);
        
        if strcmp(switch_outputlabeling,'yes') == 1
            print_timemin(toc, 'link length');
        end
    end

    %% Visualize skeletonized structures
    if strcmp(switch_visualize,'yes') == 1
        if strcmp(switch_outputlabeling,'yes') == 1
            tic;
        end
        
        visualize_skeletons(skel,node,Iraw,realpx,swellskel,nodesize,switch_cubify,output_type,pathstr,fname)
                
        if strcmp(switch_outputlabeling,'yes') == 1
            print_timemin(toc, 'visualization');
        end
    end
    
    %% Create optimization tool tiff stacks and skeletons
    
    if strcmp(switch_optimizationtools,'yes') == 1
        if strcmp(switch_outputlabeling,'yes') == 1
            tic;
        end
        
        visualize_optimizations(skel,node,skel_raw,node_raw,Iraw,Ibin,Ifl,swellskel,pathstr,fname,nodesize);
        
        if strcmp(switch_outputlabeling,'yes') == 1
            vistime = toc + vistime1;
            print_timemin(vistime, 'optimizing visualization');
        end
    end
    
    %% Save txt files, if requested
    
    if strcmp(switch_exporttxt,'yes') == 1
        if strcmp(switch_outputlabeling,'yes') == 1
            tic;
        end
        
        exporttxt_gen(skel,node,link,pathstr,fname)

        if strcmp(switch_tortuosity,'yes') == 1
            exporttxt_tort(tort_data,dtortuosity,dxpath,dypath,dzpath,dxeucl,dyeucl,dzeucl,dxtortuosity,dytortuosity,dztortuosity,switch_tortinfo,pathstr,fname)
        end
        
        if strcmp(switch_linklength,'yes') == 1
            exporttxt_ll(ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio,pathstr,fname)
        end

        if strcmp(switch_outputlabeling,'yes') == 1
            print_timemin(toc, '.txt writing');
        end
    end
    
end

%% wrap-up and data-saving

if strcmp(switch_outputlabeling,'yes') == 1
    tic;
end

if strcmp(switch_tortuosity,'yes') == 1
    tort_summary = wrapup_tortuosity(tort_data,projectpath,dtortuosity,switch_exporttxt,pathstr);
end

if strcmp(switch_linklength,'yes') == 1
    ll_summary = wrapup_linklength(ll_distribution,maxbin,switch_visualize,projectpath);
	[NN_summary,NL_summary,rhoN_summary,rhoL_summary,LNr_summary] = wrapup_noderho(N_N,N_L,rho_N,rho_L,LN_ratio,projectpath);
end

if strcmp(switch_optimizationtools,'yes') == 1
    save([pwd,filesep,projectpath,filesep,'Output/all_variables.mat']);
end

if strcmp(switch_exporttxt,'yes') == 1
    if strcmp(switch_tortuosity,'yes') == 1
        wrapup_tort(tort_summary,pathstr);
    end
    if strcmp(switch_linklength,'yes') == 1
        wrapup_ll(ll_summary,NN_summary,NL_summary,rhoN_summary,rhoL_summary,LNr_summary,pathstr);
    end
end

if strcmp(switch_outputlabeling,'yes') == 1
    print_timemin(toc, 'wrap-up');
end

load chirp.mat;
y = y / 20;
player = audioplayer(y,Fs);
play(player);