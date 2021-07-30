function img_sy = cubify(img_asy, vxsize, cubify_strfc)
% CUBIFY takes arrays from input with strongly asymmetric voxels and
% creates an array that aproximates a voxel dimension ratios of unity.
% It does this by simply repeating each slice in a each dimension by a
% certain factor such that the voxel values approach unity.

    % find factors
    lng = max(vxsize);
    
    xf = min(round(lng / vxsize(1)),cubify_strfc); % find factors in each direction
    yf = min(round(lng / vxsize(2)),cubify_strfc);
    zf = min(round(lng / vxsize(3)),cubify_strfc);
    
    counter = 1;
    
    if xf > 1 % in the x-direction, if the factor is 2 or larger
        img_sy = zeros(size(img_asy,1) * xf, size(img_asy,2), size(img_asy,3)); % make a new array
        for i = 1:size(img_asy,1) % for every slice in the old skeleton
            for j = 1:xf % for xf times
                img_sy(counter,:,:) = img_asy(i,:,:); 
                counter = counter + 1;
            end                
        end
        img_asy = img_sy;
    end
        
    counter = 1;
    if yf > 1 % in the y-direction
        img_sy = zeros(size(img_asy,1), size(img_asy,2) * yf, size(img_asy,3));
        for i = 1:size(img_asy,2) 
            for j = 1:yf
                img_sy(:,counter,:) = img_asy(:,i,:); 
                counter = counter + 1;
            end                
        end
        img_asy = img_sy;
    end

    counter = 1;
    if zf > 1 % in the z-direction
        img_sy = zeros(size(img_asy,1) * xf, size(img_asy,2), size(img_asy,3));
        for i = 1:size(img_asy,3)
            for j = 1:zf
                img_sy(:,:,counter) = img_asy(:,:,i); 
                counter = counter + 1;
            end                
        end
        img_asy = img_sy;
    end

    img_sy = img_asy;
    
end