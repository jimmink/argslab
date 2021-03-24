function visualize_preclean(skel, node, Iraw, Ifl, swellskel, pathstr, fname, nodesize, realpx, output_type, switch_cubify)

    struc_el = strel('cube',swellskel);
    skel = imdilate(skel(:,:,:),struc_el);
    if nodesize > 0
        enlargednodes = zeros(size(skel),'logical');
        for i = 1:size(node,2)
            enlargednodes(round(node(i).comx),round(node(i).comy),round(node(i).comz)) = 1;
        end
        struc_el = strel('sphere',nodesize);
        enlargednodes = imdilate(enlargednodes(:,:,:),struc_el);
    else
        enlargednodes = zeros(size(skel));
    end
    
    minpx = min(realpx);
    pixeldimensions = realpx / minpx;
    
    enlargednodes = permute(enlargednodes,[2,1,3]);
    skel = permute(skel,[2,1,3]);
    Iraw = permute(Iraw,[2,1,3]);
    Ifl = permute(Ifl,[2,1,3]);

	vis_raw_skel(Iraw,skel,enlargednodes,[pathstr,'/Output/',fname,'/Rawimage_uncleaned-skeleton.tif'])
    vis_prepost_skel(skel,enlargednodes,Ifl,[pathstr,'/Output/',fname,'/Post-skeletonization_uncleaned.tif'])
       
    enlargednodes = flip(rot90(enlargednodes,3),3);
    skel = flip(rot90(skel,3),3);
        
    if strcmp(output_type,'matlab') == 1
        enlargednodes = flip(enlargednodes,2);
        skel = flip(skel,2);
        t = pixeldimensions(1);
        pixeldimensions(1) = pixeldimensions(2);
        pixeldimensions(2) = t;
        if switch_cubify
            vis_projections(pathstr,fname,skel,enlargednodes,pixeldimensions,'uncleaned');
        else
            vis_projections(pathstr,fname,skel,enlargednodes,[1 1 1],'uncleaned');
        end
    elseif strcmp(output_type,'vtk') == 1
        if strcmp(switch_cubify,'yes') == 1
            vtkwrite([pathstr,'/Output/',fname,'/skeleton_uncleaned.vtk'],'structured_points','skeleton',skel,'spacing', pixeldimensions(1), pixeldimensions(2), pixeldimensions(3))
            vtkwrite([pathstr,'/Output/',fname,'/nodes_uncleaned.vtk'],'structured_points','skeleton',enlargednodes,'spacing', pixeldimensions(1), pixeldimensions(2), pixeldimensions(3))
        else
            vtkwrite([pathstr,'/Output/',fname,'/skeleton_uncleaned.vtk'],'structured_points','skeleton',skel)
            vtkwrite([pathstr,'/Output/',fname,'/nodes_uncleaned.vtk'],'structured_points','skeleton',enlargednodes)
        end
    end
    

end