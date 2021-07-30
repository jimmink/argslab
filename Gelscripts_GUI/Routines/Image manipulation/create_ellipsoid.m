function ellipsoid = create_ellipsoid( sigmasize, particlediameter, realpx )
%  CREATE_ELLIPSOID creates an ellipsoid in a matrix as an 3D structural
%  element for morphologiccal closing suring PROJECT_PREP.

diamx = sigmasize(1)*(particlediameter/realpx(1));
diamy = sigmasize(2)*(particlediameter/realpx(2));
diamz = sigmasize(3)*(particlediameter/realpx(3));
ellipsoid = zeros(round(diamx), round(diamy), round(diamz));
rad_x = (diamx+1)/2;
rad_y = (diamy+1)/2;
rad_z = (diamz+1)/2;
radx2 = rad_x^2;
rady2 = rad_y^2;
radz2 = rad_z^2;
for x = 1:diamx
    for y = 1:diamy
        for z = 1:diamz
            if ((((rad_x-x)^2) / radx2) + (((rad_y-y)^2) / rady2) + (((rad_z-z)^2) / radz2)) <= 1
                ellipsoid(x,y,z) = 1;
            end            
        end
    end
end
