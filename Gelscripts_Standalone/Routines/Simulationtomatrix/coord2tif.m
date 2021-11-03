function coord2tif(VoxelSizes,SigmaSize,filename,BoxSize_input,BoxSize_output,Point_spread_function)
% COORD2TIF transforms a coordinate diagram into a .tiff image stack.

%% Input

data = importdata(filename);
[pathstr, fname, ~] = fileparts(filename);

if size(data,2) ~= 3
    error("The data should be formatted to three columns, one for each dimension.")
end

data = (data./BoxSize_input).*BoxSize_output;  % Transform coordinates into units of sigma

VoxelXSize = VoxelSizes(1);
VoxelYSize = VoxelSizes(2);
VoxelZSize = VoxelSizes(3);

BoxSizeX = BoxSize_output(1);
BoxSizeY = BoxSize_output(2);
BoxSizeZ = BoxSize_output(3);

Point_spread_functionX = Point_spread_function(1);
Point_spread_functionY = Point_spread_function(2);
Point_spread_functionZ = Point_spread_function(3);

%% Prepare total array

partvoxx = SigmaSize/VoxelXSize;                        % Particle diameter along x-axis in units of x-dimension voxel width
partvoxy = SigmaSize/VoxelYSize;                        % y
partvoxz = SigmaSize/VoxelZSize;                        % z
partpsfx = Point_spread_functionX/VoxelXSize;           % Point spread function size along x-axis in units of x-dimension voxel width
partpsfy = Point_spread_functionY/VoxelYSize;
partpsfz = Point_spread_functionZ/VoxelZSize;

r_ellipsx2 = ((partvoxx)/2)^2;                          % Radius of the ellipsoid along x-axis in units of x-dimension voxel width, squared
r_ellipsy2 = ((partvoxy)/2)^2;
r_ellipsz2 = ((partvoxz)/2)^2;

data_transf = data;
data_transf(:,1)= data_transf(:,1) .* partvoxx;         % Transform coordinates into voxel size units 
data_transf(:,2)= data_transf(:,2) .* partvoxy;
data_transf(:,3)= data_transf(:,3) .* partvoxz;

Array = zeros(round(partvoxx*BoxSizeX),round(partvoxy*BoxSizeY),round(partvoxz*BoxSizeZ),'uint8');
middle = round([partvoxx,partvoxy,partvoxz]/2);         % Ellipsoid particle centre

for i = 1:size(data_transf,1)
    Ellip_binarray = zeros(round(partvoxx),round(partvoxy),round(partvoxz));                % preallocate a small array for a single particle
	coord = round(data_transf(i,:));                                                        
    remainder = data_transf(i,:)-coord;
    middlepoint = middle + remainder;                                                       % get exact middlepoint, i.e. not exactly the center of the central particle voxel
    for x = 1:size(Ellip_binarray,1)
        for y = 1:size(Ellip_binarray,2)
            for z = 1:size(Ellip_binarray,3)
                dx2 = (x - middlepoint(1))^2; 
                dy2 = (y - middlepoint(2))^2;
                dz2 = (z - middlepoint(3))^2;
                ellip_cond = (dx2/r_ellipsx2) + (dy2/r_ellipsy2) + (dz2/r_ellipsz2);        % ellipsoid interior is given by x^2/r_x^2 + y^2/r_y^2 + z^2/r_z^2 <= 1
                if ellip_cond <= 1.0
                    Ellip_binarray(x,y,z) = 1;
                    arrayx = coord(1) + (x-middle(1));                                      % find coordinate of the determined ellipsoid voxel in actual, to be constructed array
                    arrayy = coord(2) + (y-middle(2));
                    arrayz = coord(3) + (z-middle(3));
                    if arrayx > 0 && arrayx <= size(Array,1) && arrayy > 0 && arrayy <= size(Array,2) && arrayz > 0 && arrayz <= size(Array,3)      % disregard if outside of actual array
                        Array(arrayx,arrayy,arrayz) = 255;
                    end
                end
            end
        end
    end
end

Array = imgaussfilt3(Array,[partpsfx,partpsfy,partpsfz]);                                   % virtual PSF

Array = permute(Array,[2,1,3]);                                                             % permute x and y axes because read-in and export switches these around

imwrite(Array(:,:,1), [pathstr, filesep, fname, '.tif'])
for k = 2:size(Array,3)
    imwrite(Array(:,:,k), [pathstr, filesep, fname, '.tif'], 'writemode', 'append');
end

end
