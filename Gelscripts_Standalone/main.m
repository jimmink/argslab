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
        
        if strcmp(switch_outputlabeling,'yes')
            tic;
        end
        coord2tif(realpx,particlediameter,filepaths{a},BoxSize_input,BoxSize_output,Point_spread_function);
        if strcmp(switch_outputlabeling,'yes')
            print_timemin(toc, 'diagram to image stack');
        end
        
    end
    
    
    %% Preprocessing
    
    if strcmp(switch_outputlabeling,'yes')
        tic;
    end

    [Ifl, Iraw, Ibin] = project_prep(a,filepaths,zframes,sigmablur,binThres,switch_outputlabeling,switch_optimizationtools,sesize,minfrac);

    skel_raw = skeleton3D(Ifl); 
    
    if strcmp(switch_outputlabeling,'yes')
        print_timemin(toc, 'preprocessing');
    end
    
    %% Skeletonization

    if strcmp(switch_outputlabeling,'yes')
        tic;
    end
    
    if strcmp(switch_optimizationtools,'yes') || strcmp(switch_tortuosity,'yes')
        [skel_raw, Apath, node, ~, node_raw, link_raw] = wrapper_firstclean(skel_raw, realpx);
    end
    
	if strcmp(switch_outputlabeling,'yes')
        print_timemin(toc, 'skeletonization');
    end

    %% Tortuosity

    if strcmp(switch_tortuosity,'yes')
        if strcmp(switch_outputlabeling,'yes')
            tic;
        end
               
        [tort_data,shortestpaths,dtortuosity,dxpath,dypath,dzpath,dxeucl,dyeucl,dzeucl,dxtortuosity,dytortuosity,dztortuosity] = project_tortuosity(a,Apath,node,skel_raw,realpx,particlediameter,edgenode_dist,tort_data,shortestpaths,dtortuosity);
        
        if strcmp(switch_outputlabeling,'yes')
            print_timemin(toc, 'tortuosity');
        end
    end
    
    %% Uncleaned skeleton visualization
    
    if strcmp(switch_optimizationtools,'yes')
        if strcmp(switch_outputlabeling,'yes')
            tic;
        end
        
        visualize_preclean(skel_raw,node,Iraw,Ifl,swellskel,pathstr,fname,nodesize,realpx,output_type,switch_cubify);
        
        if strcmp(switch_outputlabeling,'yes')
            vistime1 = toc;
        end
    end

    %% Thorough cleaning
    
    if strcmp(switch_outputlabeling,'yes')
        tic;
    end

    [skel, Apath, node, link] = wrapper_thoroughclean(skel_raw, sk_thr, realpx, cl_thr);

    if strcmp(switch_outputlabeling,'yes')
        print_timemin(toc, 'cleaning');
    end
    
    %% Remove all edge nodes and links, if required
    
    if strcmp(visualize_edges,'no')
        [skel, Apath, node, link] = wrapper_edgeclean(skel, edgenode_dist, particlediameter, realpx, cl_thr);
    end
    
    %% Link length and node/link densities

    if strcmp(switch_linklength,'yes') || strcmp(switch_visualize,'yes') || strcmp(switch_optimizationtools,'yes')
        if strcmp(switch_outputlabeling,'yes')
            tic;
        end
        
        [ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio] = project_linklength(a,skel,node,link,realpx,particlediameter,switch_linklength,switch_visualize,maxbin,binsize,ll_distribution,pathstr,fname,N_N,N_L,rho_N,rho_L,LN_ratio);
        
        if strcmp(switch_outputlabeling,'yes')
            print_timemin(toc, 'link length');
        end
    end
    
	%% Save variables, if required

    if strcmp(switch_optimizationtools,'yes')
        save_var(rho_L,N_L,ll_distribution,LN_ratio,rho_N,N_N,tort_data,...
            skel,node,link,Ibin,Ifl,[pathstr,'/Output/',fname,'/'])
    end


    %% Visualize skeletonized structures
    if strcmp(switch_visualize,'yes')
        if strcmp(switch_outputlabeling,'yes')
            tic;
        end
        
        visualize_skeletons(skel,node,Iraw,realpx,swellskel,nodesize,switch_cubify,output_type,pathstr,fname)
                
        if strcmp(switch_outputlabeling,'yes')
            print_timemin(toc, 'visualization');
        end
    end
    
    %% Create optimization tool tiff stacks and skeletons
    
    if strcmp(switch_optimizationtools,'yes')
        if strcmp(switch_outputlabeling,'yes')
            tic;
        end
        
        visualize_optimizations(skel,node,skel_raw,node_raw,Iraw,Ibin,Ifl,swellskel,pathstr,fname,nodesize);
        
        if strcmp(switch_outputlabeling,'yes')
            vistime = toc + vistime1;
            print_timemin(vistime, 'optimizing visualization');
        end
    end
    
    %% Save txt files, if requested
    
    if strcmp(switch_exporttxt,'yes')
        if strcmp(switch_outputlabeling,'yes')
            tic;
        end
        
        exporttxt_gen(skel,node,link,pathstr,fname)

        if strcmp(switch_tortuosity,'yes')
            exporttxt_tort(tort_data,dtortuosity,dxpath,dypath,dzpath,dxeucl,dyeucl,dzeucl,dxtortuosity,dytortuosity,dztortuosity,pathstr,fname)
        end
        
        if strcmp(switch_linklength,'yes')
            exporttxt_ll(ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio,pathstr,fname)
        end

        if strcmp(switch_outputlabeling,'yes')
            print_timemin(toc, '.txt writing');
        end
    end
    
end

%% wrap-up and data-saving

if strcmp(switch_outputlabeling,'yes')
    tic;
end

dummy = 0;
save([projectpath,filesep,'Output/Analysis_output_combined.mat'],'dummy')

if strcmp(switch_tortuosity,'yes')
    tort_summary = wrapup_tortuosity(tort_data,projectpath,dtortuosity,switch_exporttxt);
end

if strcmp(switch_linklength,'yes')
    ll_summary = wrapup_linklength(ll_distribution,maxbin,switch_visualize,projectpath);
	[NN_summary,NL_summary,rhoN_summary,rhoL_summary,LNr_summary] = wrapup_noderho(N_N,N_L,rho_N,rho_L,LN_ratio,projectpath);
end

if strcmp(switch_exporttxt,'yes')
    if strcmp(switch_tortuosity,'yes')
        wrapup_tort(tort_summary,pathstr);
    end
    if strcmp(switch_linklength,'yes')
        wrapup_ll(ll_distribution,ll_summary,NN_summary,NL_summary,rhoN_summary,rhoL_summary,LNr_summary,pathstr);
    end
end

if strcmp(switch_outputlabeling,'yes')
    print_timemin(toc, 'wrap-up');
end

load chirp.mat;
y = y / 20;
player = audioplayer(y,Fs);
play(player);
