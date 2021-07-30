function [Node_number_summary,Link_number_summary,Node_density_summary,Link_density_summary,Link_to_node_ratio_summary] = wrapup_noderho(N_N,N_L,rho_N,rho_L,LN_ratio,projectpath)
% WRAPUP_NODERHO combines all skeleton variables of all calculated
% files.

Node_number_summary = zeros(1,2);
Node_number_summary(1,1) = mean(N_N,2);
Node_number_summary(1,2) = std(N_N);

Link_number_summary = zeros(1,2);
Link_number_summary(1,1) = mean(N_L,2);
Link_number_summary(1,2) = std(N_L);

Node_density_summary = zeros(1,2);
Node_density_summary(1,1) = mean(rho_N,2);
Node_density_summary(1,2) = std(rho_N);

Link_density_summary = zeros(1,2);
Link_density_summary(1,1) = mean(rho_L,2);
Link_density_summary(1,2) = std(rho_L);

Link_to_node_ratio_summary = zeros(1,2);
Link_to_node_ratio_summary(1,1) = mean(LN_ratio,2);
Link_to_node_ratio_summary(1,2) = std(LN_ratio);

Node_number = N_N;
Link_number = N_L;
Node_density = rho_N;
Link_density = rho_L;
Link_to_node_ratio = LN_ratio;

save([projectpath,filesep,'Output/Analysis_output_combined.mat'],'Node_number','Node_number_summary','Link_number'...
    ,'Link_number_summary','Node_density','Node_density_summary','Link_density','Link_density_summary',...
    'Link_to_node_ratio','Link_to_node_ratio_summary','-append')

end