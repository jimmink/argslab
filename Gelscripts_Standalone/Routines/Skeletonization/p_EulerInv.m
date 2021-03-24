function EulerInv =  p_EulerInv(nbhood,LUT)

% EulerInv splits a 27-voxel neighborhood into eight octants, and gets the
% Euler characteristic for that octant, and sums them up to get the overall
% Euler characteristic. The characteristic for an octant is found in a
% look-up table provided for by FillEulerLUT.
%
% This routine is taken from Kerschnitzki, Kollmannsberger
% et al., J. Bone. Miner. Res., 28(8):1837-1845, 2013. This code is based 
% on algorithms published in Lee et al., Comput. Gr. Image Process., 
% 56(6):462-478, 1994.

eulerChar = zeros(size(nbhood,1),1); % preallocate voor alle roi's.
% Octant SWU 
n = ones(size(nbhood,1),1); 
n(nbhood(:,25)==1) = bitor(n(nbhood(:,25)==1),128); 
n(nbhood(:,26)==1) = bitor(n(nbhood(:,26)==1),64);
n(nbhood(:,16)==1) = bitor(n(nbhood(:,16)==1),32);
n(nbhood(:,17)==1) = bitor(n(nbhood(:,17)==1),16);
n(nbhood(:,22)==1) = bitor(n(nbhood(:,22)==1),8);
n(nbhood(:,23)==1) = bitor(n(nbhood(:,23)==1),4);
n(nbhood(:,13)==1) = bitor(n(nbhood(:,13)==1),2);
eulerChar = eulerChar + LUT(n);
% Octant SEU
n = ones(size(nbhood,1),1);
n(nbhood(:,27)==1) = bitor(n(nbhood(:,27)==1),128);
n(nbhood(:,24)==1) = bitor(n(nbhood(:,24)==1),64);
n(nbhood(:,18)==1) = bitor(n(nbhood(:,18)==1),32);
n(nbhood(:,15)==1) = bitor(n(nbhood(:,15)==1),16);
n(nbhood(:,26)==1) = bitor(n(nbhood(:,26)==1),8);
n(nbhood(:,23)==1) = bitor(n(nbhood(:,23)==1),4);
n(nbhood(:,17)==1) = bitor(n(nbhood(:,17)==1),2);
eulerChar = eulerChar + LUT(n);
% Octant NWU
n = ones(size(nbhood,1),1);
n(nbhood(:,19)==1) = bitor(n(nbhood(:,19)==1),128);
n(nbhood(:,22)==1) = bitor(n(nbhood(:,22)==1),64);
n(nbhood(:,10)==1) = bitor(n(nbhood(:,10)==1),32);
n(nbhood(:,13)==1) = bitor(n(nbhood(:,13)==1),16);
n(nbhood(:,20)==1) = bitor(n(nbhood(:,20)==1),8);
n(nbhood(:,23)==1) = bitor(n(nbhood(:,23)==1),4);
n(nbhood(:,11)==1) = bitor(n(nbhood(:,11)==1),2);
eulerChar = eulerChar + LUT(n);
% Octant NEU
n = ones(size(nbhood,1),1);
n(nbhood(:,21)==1) = bitor(n(nbhood(:,21)==1),128);
n(nbhood(:,24)==1) = bitor(n(nbhood(:,24)==1),64);
n(nbhood(:,20)==1) = bitor(n(nbhood(:,20)==1),32);
n(nbhood(:,23)==1) = bitor(n(nbhood(:,23)==1),16);
n(nbhood(:,12)==1) = bitor(n(nbhood(:,12)==1),8);
n(nbhood(:,15)==1) = bitor(n(nbhood(:,15)==1),4);
n(nbhood(:,11)==1) = bitor(n(nbhood(:,11)==1),2);
eulerChar = eulerChar + LUT(n);
% Octant SWB
n = ones(size(nbhood,1),1);
n(nbhood(:,7)==1) = bitor(n(nbhood(:,7)==1),128);
n(nbhood(:,16)==1) = bitor(n(nbhood(:,16)==1),64);
n(nbhood(:,8)==1) = bitor(n(nbhood(:,8)==1),32);
n(nbhood(:,17)==1) = bitor(n(nbhood(:,17)==1),16);
n(nbhood(:,4)==1) = bitor(n(nbhood(:,4)==1),8);
n(nbhood(:,13)==1) = bitor(n(nbhood(:,13)==1),4);
n(nbhood(:,5)==1) = bitor(n(nbhood(:,5)==1),2);
eulerChar = eulerChar + LUT(n);
% Octant SEB
n = ones(size(nbhood,1),1);
n(nbhood(:,9)==1) = bitor(n(nbhood(:,9)==1),128);
n(nbhood(:,8)==1) = bitor(n(nbhood(:,8)==1),64);
n(nbhood(:,18)==1) = bitor(n(nbhood(:,18)==1),32);
n(nbhood(:,17)==1) = bitor(n(nbhood(:,17)==1),16);
n(nbhood(:,6)==1) = bitor(n(nbhood(:,6)==1),8);
n(nbhood(:,5)==1) = bitor(n(nbhood(:,5)==1),4);
n(nbhood(:,15)==1) = bitor(n(nbhood(:,15)==1),2);
eulerChar = eulerChar + LUT(n);
% Octant NWB
n = ones(size(nbhood,1),1);
n(nbhood(:,1)==1) = bitor(n(nbhood(:,1)==1),128);
n(nbhood(:,10)==1) = bitor(n(nbhood(:,10)==1),64);
n(nbhood(:,4)==1) = bitor(n(nbhood(:,4)==1),32);
n(nbhood(:,13)==1) = bitor(n(nbhood(:,13)==1),16);
n(nbhood(:,2)==1) = bitor(n(nbhood(:,2)==1),8);
n(nbhood(:,11)==1) = bitor(n(nbhood(:,11)==1),4);
n(nbhood(:,5)==1) = bitor(n(nbhood(:,5)==1),2);
eulerChar = eulerChar + LUT(n);
% Octant NEB
n = ones(size(nbhood,1),1);
n(nbhood(:,3)==1) = bitor(n(nbhood(:,3)==1),128);
n(nbhood(:,2)==1) = bitor(n(nbhood(:,2)==1),64);
n(nbhood(:,12)==1) = bitor(n(nbhood(:,12)==1),32);
n(nbhood(:,11)==1) = bitor(n(nbhood(:,11)==1),16);
n(nbhood(:,6)==1) = bitor(n(nbhood(:,6)==1),8);
n(nbhood(:,5)==1) = bitor(n(nbhood(:,5)==1),4);
n(nbhood(:,15)==1) = bitor(n(nbhood(:,15)==1),2);
eulerChar = eulerChar + LUT(n);

EulerInv(eulerChar==0) = true;