function exporttxt_ll(ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio,pathstr,fname)

fileid4 = fopen([pathstr,'/Output/',fname,'/ll_distribution.txt'],'w');
line = 'Lambda\tÑ(Lambda)\n';
fprintf(fileid4, line);
for i = 1:size(ll_distribution,1)
    line = horzcat(num2str(ll_distribution(i,1)),'\t',num2str(ll_distribution(i,2)),'\n');
    fprintf(fileid4, line);
end
fclose(fileid4);

fileid5 = fopen([pathstr,'/Output/',fname,'/skel_parameters.txt'],'w');
line = 'N_N\tN_L\trho_N\trho_L\tN_L/N_N\n';
fprintf(fileid5, line);
line = horzcat(num2str(N_N(1,1)),'\t',num2str(N_L(1,1)),'\t',num2str(rho_N(1,1)),'\t',num2str(rho_L(1,1)),'\t',num2str(LN_ratio(1,1)),'\n');
fprintf(fileid5, line);
fclose(fileid5);