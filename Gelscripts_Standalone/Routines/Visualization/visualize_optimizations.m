function visualize_optimizations(skel, node, skel_raw, node_raw, Iraw, Ibin, Ifl, swellskel, pathstr, fname, nodesize)
% VISUALIZE_OPTIMIZATIONS is a wrapper for visualizing images and skeletons
% after the cleaning routines are applied. The images produced are intended
% for aiding optimizing parameter choice.

    struc_el = strel('cube',swellskel);
    skel = imdilate(skel(:,:,:),struc_el);
    skel_raw = imdilate(skel_raw(:,:,:),struc_el);
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
    
	if nodesize > 0
        enlargednodesraw = zeros(size(skel_raw),'logical');
        for i = 1:size(node_raw,2)
            enlargednodesraw(round(node_raw(i).comx),round(node_raw(i).comy),round(node_raw(i).comz)) = 1;
        end
        struc_el = strel('sphere',nodesize);
        enlargednodesraw = imdilate(enlargednodesraw(:,:,:),struc_el);
    else
        enlargednodesraw = zeros(size(skel_raw),'logical');
    end
    
    enlargednodes = permute(enlargednodes,[2,1,3]);
    skel = permute(skel,[2,1,3]);
	enlargednodesraw = permute(enlargednodesraw,[2,1,3]);
    skel_raw = permute(skel_raw,[2,1,3]);
    Iraw = permute(Iraw,[2,1,3]);
    Ibin = permute(Ibin,[2,1,3]);
    Ifl = permute(Ifl,[2,1,3]);
    
    % vis_bin_raw(Iraw,Ibin,[pathstr,'/Output/',fname,'/Rawimage_initialbinarized.tif'])
	vis_skel_cleaning(Iraw,skel,enlargednodes,skel_raw,enlargednodesraw,[pathstr,'/Output/',fname,'/Rawimage_skeletoncleaning.tif'])
    vis_bin_raw(Iraw,Ibin,[pathstr,'/Output/',fname,'/Rawimage_binarized.tif'])
    vis_bin_skel(skel,enlargednodes,Ifl,[pathstr,'/Output/',fname,'/Binarized_skeleton.tif'])
    vis_bin_bin(Ibin,Ifl,[pathstr,'/Output/',fname,'/Binarized_cleaning.tif'])
    
end