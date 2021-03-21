function [NN_summary,NL_summary,rhoN_summary,rhoL_summary,LNr_summary] = wrapup_noderho(N_N,N_L,rho_N,rho_L,LN_ratio,projectpath)

NN_summary = zeros(1,2);
NN_summary(1,1) = mean(N_N,2);
NN_summary(1,2) = std(N_N);

NL_summary = zeros(1,2);
NL_summary(1,1) = mean(N_L,2);
NL_summary(1,2) = std(N_L);

rhoN_summary = zeros(1,2);
rhoN_summary(1,1) = mean(rho_N,2);
rhoN_summary(1,2) = std(rho_N);

rhoL_summary = zeros(1,2);
rhoL_summary(1,1) = mean(rho_L,2);
rhoL_summary(1,2) = std(rho_L);

LNr_summary = zeros(1,2);
LNr_summary(1,1) = mean(LN_ratio,2);
LNr_summary(1,2) = std(LN_ratio);

save([projectpath,filesep,'Output/noderho_summary.mat'],'N_N','NN_summary','N_L','NL_summary','rho_N','rhoN_summary','rho_L','rhoL_summary','LN_ratio','LNr_summary')

end