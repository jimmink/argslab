%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EDGEWEIGHT SUPERLOOP %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ll_distribution,N_N,N_L,rho_N,rho_L,LN_ratio] = project_linklength(a,skel,node,link,realpx,particlediameter,switch_linklength,switch_visualize,maxbin,binsize,ll_distribution,pathstr,fname,N_N,N_L,rho_N,rho_L,LN_ratio)

    %% Remove all links that connect to box edge
    
    nodes_true = zeros(1,2*size(node,2));
    
    lowceilx = (particlediameter / realpx(1));
    lowceily = (particlediameter / realpx(2));
    lowceilz = (particlediameter / realpx(3));
    highceilx = size(skel,1) - (particlediameter / realpx(1));
    highceily = size(skel,2) - (particlediameter / realpx(2));
    highceilz = size(skel,3) - (particlediameter / realpx(3));
    
    links_tbc = link;
    counter = 1;
    for i = size(links_tbc,2):-1:1
        n1 = links_tbc(i).n1;
        n2 = links_tbc(i).n2;
        if node(n1).comx < lowceilx
            links_tbc(:,i) = [];
        elseif node(n1).comy < lowceily
            links_tbc(:,i) = [];
        elseif node(n1).comz < lowceilz
            links_tbc(:,i) = [];
        elseif node(n1).comx > highceilx
            links_tbc(:,i) = [];
        elseif node(n1).comy > highceily
            links_tbc(:,i) = [];
        elseif node(n1).comz > highceilz
            links_tbc(:,i) = [];
        elseif node(n2).comx < lowceilx
            links_tbc(:,i) = [];
        elseif node(n2).comy < lowceily
            links_tbc(:,i) = [];
        elseif node(n2).comz < lowceilz
            links_tbc(:,i) = [];
        elseif node(n2).comx > highceilx
            links_tbc(:,i) = [];
        elseif node(n2).comy > highceily
            links_tbc(:,i) = [];
        elseif node(n2).comz > highceilz
            links_tbc(:,i) = [];
        else
            nodes_true(1,counter) = n1;
            nodes_true(1,counter + 1) = n2;
            counter = counter + 2;
        end
    end
    
    links_tbc = [links_tbc(1,:).length];
    nodes_true = unique(nodes_true(1,1:counter-1));

    %% Find node-to-node distance and node/link densities

    for i = 1:size(links_tbc,2)
        if links_tbc(1,i) > maxbin
            ll_distribution(binsize,a + 1) = ll_distribution(binsize,a + 1) + 1;
        else
            bin_tbu = ceil((links_tbc(1,i) / maxbin) * binsize);
            ll_distribution(bin_tbu,a + 1) = ll_distribution(bin_tbu,a + 1) + 1;
        end
    end
    ll_distribution(:,a + 1) = ll_distribution(:,a + 1) / max(ll_distribution(:,a + 1));
    N_N(1,a) = size(nodes_true,2);
    N_L(1,a) = size(links_tbc,2);
    vol_subbox = (size(skel,1) / (particlediameter / realpx(1))) * (size(skel,2) / (particlediameter / realpx(2))) * (size(skel,3) / (particlediameter / realpx(3)));
    rho_N(1,a) = N_N(1,a) / vol_subbox;
    rho_L(1,a) = N_L(1,a) / vol_subbox;
    LN_ratio(1,a) = N_L(1,a) / N_N(1,a);

    if strcmp(switch_visualize,'yes') && strcmp(switch_linklength,'yes')
        ntn = figure;
        bar(ll_distribution(:,1),ll_distribution(:,a + 1))
        axis([-inf maxbin 0 1.2])
        xlabel('Node-to-node distance \Lambda (\mum)')
        ylabel('Normalized number of nodes')
        set(gca,'fontsize',16)
        savefig(ntn,[pathstr,'/Output/',fname,'/Nodedistance.fig'])
        saveas(ntn,[pathstr,'/Output/',fname,'/Nodedistance.eps'],'epsc')
        close(ntn)
    end

end