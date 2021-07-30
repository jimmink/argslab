function save_var(rho_L,N_L,ll_distribution,LN_ratio,rho_N,N_N,tort_data,skel,node,link,Ibin,Ifl,path)
% SAVE_VAR renames variables, so that users can clearly see what variable 
% contains what. It also saves these variables in a .mat file.

    Link_density = rho_L;
    Link_number = N_L;
    Linklength_distribution = ll_distribution;
    Links_per_node = LN_ratio;
    Node_density = rho_N;
    Node_number = N_N;
    Tortuosity_data = tort_data;
    
    Linklist = link;
    Nodelist = node;
    Skeleton = skel;
    
    Initial_binarization = Ibin;
    Processed_binarization = Ifl;

    save([path,'Analysis_variables.mat'],'Link_density','Link_number','Linklength_distribution',...
        'Links_per_node','Node_density','Node_number','Tortuosity_data');
    save([path,'Skeleton_variables.mat'],'Linklist','Nodelist','Skeleton');
    save([path,'Preparation_variables.mat'],'Initial_binarization','Processed_binarization');
    
end