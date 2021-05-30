function visualize_skeletons(skel,node,Iraw,realpx,swellskel,nodesize,switch_cubify,output_type,pathstr,fname)
% VISUALIZE_SKELETONS visualizes skeletons as defined by the user.

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
        enlargednodes = zeros(size(skel),'logical');
    end
        
    minpx = min(realpx);
    pixeldimensions = realpx / minpx;
    
    enlargednodes = permute(enlargednodes,[2,1,3]);
    skel = permute(skel,[2,1,3]);
    Iraw = permute(Iraw,[2,1,3]);

	vis_raw_skel(Iraw,skel,enlargednodes,[pathstr,'/Output/',fname,'/Rawimage_skeleton.tif'])

	skel = flip(rot90(skel,3),3);
    enlargednodes = flip(rot90(enlargednodes,3),3);

    if strcmp(output_type,'matlab') == 1
        enlargednodes = flip(enlargednodes,2);
        skel = flip(skel,2);
        t = pixeldimensions(1);
        pixeldimensions(1) = pixeldimensions(2);
        pixeldimensions(2) = t;
        if strcmp(switch_cubify,'yes') == 1
            vis_projections(pathstr,fname,skel,enlargednodes,pixeldimensions,'cleaned');
        else
            vis_projections(pathstr,fname,skel,enlargednodes,[1 1 1],'cleaned');
        end
    elseif strcmp(output_type,'vtk') == 1
%         skel = flip(skel,2);
%         enlargednodes = flip(enlargednodes,2);
        if strcmp(switch_cubify,'yes') == 1
            vtkwrite([pathstr,'/Output/',fname,'/skeleton.vtk'],'structured_points','skeleton',skel,'spacing', pixeldimensions(1), pixeldimensions(2), pixeldimensions(3))
            vtkwrite([pathstr,'/Output/',fname,'/nodes.vtk'],'structured_points','skeleton',enlargednodes,'spacing', pixeldimensions(1), pixeldimensions(2), pixeldimensions(3))
        else
            vtkwrite([pathstr,'/Output/',fname,'/skeleton.vtk'],'structured_points','skeleton',skel)
            vtkwrite([pathstr,'/Output/',fname,'/nodes.vtk'],'structured_points','skeleton',enlargednodes)
        end
    end
end