function visualize_opt_prep(Iraw, Ibin, Ifl, pathstr, fname)
    
    vis_bin_raw(Iraw,Ibin,[pathstr,'/Output/',fname,'/Rawimage_binarized.tif'])
    vis_bin_bin(Ibin,Ifl,[pathstr,'/Output/',fname,'/Binarized_cleaning.tif'])
    
end