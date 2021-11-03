function save_var(a,rho_L,N_L,ll_distribution,LN_ratio,rho_N,N_N,tort_data,skel,node,link,Ibin,Ifl,path,switch_optimizationtools)
% SAVE_VAR renames variables, so that users can clearly see what variable 
% contains what. It also saves these variables in a .mat file.

    Link_density = rho_L(1,a);
    Link_number = N_L(1,a);
    Linklength_distribution = [ll_distribution(:,1),ll_distribution(:,a+1)];
    Links_per_node = LN_ratio(1,a);
    Node_density = rho_N(1,a);
    Node_number = N_N(1,a);
    Tortuosity_data = tort_data(a,:);
    
    Linklist = link;
    Nodelist = node;
    Skeleton = skel;
    
    Initial_binarization = Ibin;
    Processed_binarization = Ifl;

    save([path,'Analysis_variables.mat'],'Link_density','Link_number','Linklength_distribution',...
        'Links_per_node','Node_density','Node_number','Tortuosity_data');
	save([path,'Skeleton_variables.mat'],'Linklist','Nodelist','Skeleton');
	if strcmp(switch_optimizationtools,'yes')
        save([path,'Preparation_variables.mat'],'Initial_binarization','Processed_binarization');
	end
end
