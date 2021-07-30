function Ifl = fill_holes(Iso, fill_thres, particlediameter, realpx)
% FILL_HOLES fills all hols in a structure that are completely enclosed in
% all three dimensions, should the hole be smaller than
% fill_thres * particle volume.

    pixelsizes = particlediameter ./ realpx;
    thresh_volume = pi * (4/3) * pixelsizes(1) * pixelsizes(2) * pixelsizes(3);
    thresh_volume = fill_thres * thresh_volume;
    
    Itemp = imfill(Iso,'holes');
    if ~isequal(Itemp,Iso)
        Ifl = Iso;
        Iholes = Itemp - Iso;
        temp = bwconncomp(Iholes);
        for i = 1:size(temp.PixelIdxList,2)
            if size(temp.PixelIdxList{1,i},1) < thresh_volume
                for j = 1:size(temp.PixelIdxList{1,i},1)
                    Ifl(temp.PixelIdxList{1,i}(j,1)) = 1;
                end
            end
        end
    else
        Ifl = Iso;
    end
end

    