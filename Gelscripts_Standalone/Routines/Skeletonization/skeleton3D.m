function skel = skeleton3D(img)
% SKELETON3D Calculate the 3D skeleton of the precleaned gel structure using 
% parallel medial axis thinning.
%
% This routine is based on MATLAB code from Kerschnitzki, Kollmannsberger
% et al., J. Bone. Miner. Res., 28(8):1837-1845, 2013. This code is based 
% on algorithms published in Lee et al., Comput. Gr. Image Process., 
% 56(6):462-478, 1994.

% Pad volume with zeros to avoid edge effects
skel = padarray(img,[1 1 1]);

% Fill Euler characteristic LookUp Table
% This look-up table allows quick and easy looking up and calculation of 
% the Euler characteristic of the polygon that the voxel and its 26
% surrounding neighbors form; and comparison with the Euler characteristic
% should the central voxel be removed. If the characteristic changes, the
% voxel should not be removed.
eulerLUT = FillEulerLUT;

width = size(skel,1);
height = size(skel,2);
depth = size(skel,3);

% Marker for checking whether a skeletonization loop made a difference 
unchangedBorders = 0;

% !! forward en backward kan misschien weg gesloopt worden voor tijdsoptimalizatie!

% Main skeletonization loop. Perform action until one of the six directions
% does not change anymore; the six directions are the three dimensions,
% both forward and backward.
while( unchangedBorders < 6 )
    unchangedBorders = 0; % Reset marker
    for currentBorder=1:6 % Loop over all six directions
        cands=zeros(width,height,depth); % preallocate array for the candidates to be removed

        switch currentBorder % switch between the six possible directions   
            case 4 % x-backward
                x=2:size(skel,1); 
                cands(x,:,:)=skel(x,:,:) - skel(x-1,:,:); % declare as a candidate, if the voxel's content is not equal to the previous voxel's content.
            case 3 % x-forward
                x=1:size(skel,1)-1;
                cands(x,:,:)=skel(x,:,:) - skel(x+1,:,:); % declare as a candidate, if the voxel's content is not equal to the next voxel's content.
            case 1 % y-backward
                y=2:size(skel,2);
                cands(:,y,:)=skel(:,y,:) - skel(:,y-1,:);
            case 2 % y-forward
                y=1:size(skel,2)-1;
                cands(:,y,:)=skel(:,y,:) - skel(:,y+1,:);
            case 6 % z-backward
                z=2:size(skel,3);
                cands(:,:,z)=skel(:,:,z) - skel(:,:,z-1);
            case 5 % z-forward
                z=1:size(skel,3)-1;
                cands(:,:,z)=skel(:,:,z) - skel(:,:,z+1);
        end
        
        % write the candidates as voxel indices
        cands = intersect(find(cands(:)==1),find(skel(:)==1));
        
        noChange = true;
                    
        if(~isempty(cands))
            % find and write all x, y and z coordinates of all candidate
            % indices
            [x,y,z]=ind2sub([width height depth],cands);
            
            % Obtain the local surrounding of every candidate
            nhood = logical(get_nh(skel,cands));
            
            % remove any end points from the list of candidates, i.e. 
            % all 27-pt arrays with only two filled-in voxels
            di1 = find(sum(nhood,2)==2)';
            nhood(di1,:)=[];
            cands(di1)=[];
            x(di1)=[];
            y(di1)=[];
            z(di1)=[];
            
            % This step removes all non-Euler invariant points from the
            % list of candidates. This means that if the central point 
            % would lead to a change in the Euler characteristic of local 
            % surrounding of a voxel, and therefore lead to a change in 
            % topology, the voxel should not be removed.
            di2 = find(~p_EulerInv(nhood, eulerLUT'));
            nhood(di2,:)=[];
            cands(di2)=[];
            x(di2)=[];
            y(di2)=[];
            z(di2)=[];
            
            % This step removes Euler simple points from the candidate list.
            di3 = find(~p_is_simple(nhood));
            nhood(di3,:)=[];
            cands(di3)=[];
            x(di3)=[];
            y(di3)=[];
            z(di3)=[];
            
            
            % als er kandidaten over zijn, verspreid over acht sublijsten.
            % Voxels in één sublijst kunnen niet aan elkaar liggen.
            if(~isempty(x))
                x1 = find(mod(x,2)); % alle oneven x-waardes
                x2 = find(~mod(x,2)); % alle even x-waardes
                y1 = find(mod(y,2)); % etc.
                y2 = find(~mod(y,2));
                z1 = find(mod(z,2));
                z2 = find(~mod(z,2));
                ilst(1).l = intersect(x1,intersect(y1,z1)); % lijst van alle kandidaten met even x, y, en z
                ilst(2).l = intersect(x2,intersect(y1,z1)); % etc.
                ilst(3).l = intersect(x1,intersect(y2,z1));
                ilst(4).l = intersect(x2,intersect(y2,z1));
                ilst(5).l = intersect(x1,intersect(y1,z2));
                ilst(6).l = intersect(x2,intersect(y1,z2));
                ilst(7).l = intersect(x1,intersect(y2,z2));
                ilst(8).l = intersect(x2,intersect(y2,z2));
                
                idx = [];
                
                % do parallel re-checking for all points in each subvolume
                for i = 1:8 % voor elke sublijst
                    if(~isempty(ilst(i).l)) % als de sublijst niet leeg is
                        idx = ilst(i).l; % kopieer over sublijst
                        li = sub2ind([width height depth],x(idx),y(idx),z(idx)); % vind voxelindex (computergegenereerd) voor elke voxel in deze sublijst
                        skel(li)=0; % verwijder de punten met die specifieke computergegenereerde voxelindex
                        nh = logical(get_nh(skel,li)); % SUBROUTINE: vind lokale omgeving van de zojuist verwijderde punten
                        di_rc = find(~p_is_simple(nh)); % SUBROUTINE: vind alle enkele punten in de lijst
                        if(~isempty(di_rc)) % als er een enkel punt is gevonden: 
                            skel(li(di_rc))=1; % revert
                        else
                            noChange = false; % flag dat er minstens een voxel verwijderd is
                        end
                    end
                end
            end
        end
        
        if( noChange )
            unchangedBorders = unchangedBorders + 1;
        end
        
    end
end

% get rid of padded zeros
skel = skel(2:end-1,2:end-1,2:end-1);


