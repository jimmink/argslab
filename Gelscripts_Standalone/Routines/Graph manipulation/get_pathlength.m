function tot_length = get_pathlength(linkpath,pyth_lut,offsetmask)
% GET_PATHLENGTH provides a path length for a string of adjacent voxels.

dist_lut = zeros(1,max(offsetmask));
for i = 15:27
    dist_lut(1,offsetmask(i,1)) = pyth_lut(i,1);
end

tot_length = 0;
for i = 1:size(linkpath,2)-1
    
    vxd = abs(linkpath(1,i) - linkpath(1,i+1));
    tot_length = tot_length + dist_lut(1,vxd);

end