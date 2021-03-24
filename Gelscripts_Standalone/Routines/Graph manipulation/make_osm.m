function offsetmask = make_osm(arraysize)
% MAKE_OSM creates an offset mask for any index number, to obtain its
% neighboring voxels. Used to minimize using computation-intensive ind2sub
% and sub2ind.

    framesize = arraysize(1) * arraysize(2);
    linesize = arraysize(1);
    
    offsetmask = zeros(27,1);
    offsetmask(1,1) = -framesize - linesize - 1;
    offsetmask(2,1) = -framesize - linesize;
    offsetmask(3,1) = -framesize - linesize + 1;
    offsetmask(4,1) = -framesize - 1;
    offsetmask(5,1) = -framesize;
    offsetmask(6,1) = -framesize + 1;
    offsetmask(7,1) = -framesize + linesize - 1;
    offsetmask(8,1) = -framesize + linesize;
    offsetmask(9,1) = -framesize + linesize + 1;
    offsetmask(10,1) = -linesize - 1;
    offsetmask(11,1) = -linesize;
    offsetmask(12,1) = -linesize + 1;
    offsetmask(13,1) = -1;
    offsetmask(14,1) = 0;
    offsetmask(15,1) = +1;
    offsetmask(16,1) = linesize - 1;
    offsetmask(17,1) = linesize;
    offsetmask(18,1) = linesize + 1;
    offsetmask(19,1) = framesize - linesize - 1;
    offsetmask(20,1) = framesize - linesize;
    offsetmask(21,1) = framesize - linesize + 1;
    offsetmask(22,1) = framesize - 1;
    offsetmask(23,1) = framesize;
    offsetmask(24,1) = framesize + 1;
    offsetmask(25,1) = framesize + linesize - 1;
    offsetmask(26,1) = framesize + linesize;
    offsetmask(27,1) = framesize + linesize + 1;
    