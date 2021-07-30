function ll_summary = wrapup_linklength(ll_distribution,maxbin,switch_visualize,projectpath)
% WRAPUP_LINKLENGTH combines all linklength variables of all calculated
% files.

    ll_summary = zeros(size(ll_distribution,1),3);
    ll_summary(:,1) = ll_distribution(:,1);
    ll_summary(:,2) = mean(ll_distribution(:,2:end),2);
    ll_summary(:,3) = std(ll_distribution(:,2:end),0,2);

    if strcmp(switch_visualize,'yes') == 1
        ntn = figure;
        stdcurvesp = ll_summary(:,2) + ll_summary(:,3);
        stdcurvesm = ll_summary(:,2) - ll_summary(:,3);
        stdc = [stdcurvesp', fliplr(stdcurvesm')];
        fill([ll_summary(:,1)',fliplr(ll_summary(:,1)')],stdc,[0.8,0.8,0.8],'LineStyle','none')
        hold on;
        plot(ll_summary(:,1),ll_summary(:,2),'Linewidth',1.5,'Color','k')
        axis([-inf maxbin 0 1.2])
        xlabel('Node-to-node distance \Lambda (\mum)')
        ylabel('Normalized number of links')
        set(gca,'fontsize',16)
        savefig(ntn,[projectpath,'/Output/Linklength_averaged.fig'])
        saveas(ntn,[projectpath,'/Output/Linklength_averaged.eps'],'epsc')
        close(ntn)
    end

    Linklength_distribution = ll_distribution;
    Linklength_summary = ll_summary;
    save([projectpath,filesep,'Output/Analysis_output_combined.mat'],'Linklength_distribution','Linklength_summary','-append')
end