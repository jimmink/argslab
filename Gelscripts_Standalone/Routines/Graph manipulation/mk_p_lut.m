function pyth_lut = mk_p_lut(realpx)
% MK_P_LUT creates a lookup table for the euclidean distances between two
% neighboring pixels, using the pythagorean theorem.

    pyth_lut = zeros(27,1);
    x = realpx(1);
    y = realpx(2);
    z = realpx(3);
    
    pyth_lut(1) = sqrt(x^2 + y^2 + z^2);
    pyth_lut(2) = sqrt(y^2 + z^2);
    pyth_lut(3) = pyth_lut(1);
    pyth_lut(4) = sqrt(x^2 + z^2);
    pyth_lut(5) = z;
    pyth_lut(6) = pyth_lut(4);
    pyth_lut(7) = pyth_lut(1);
    pyth_lut(8) = pyth_lut(2);
    pyth_lut(9) = pyth_lut(1);
    
    pyth_lut(10) = sqrt(x^2 + y^2);
    pyth_lut(11) = y;
    pyth_lut(12) = pyth_lut(10);
    pyth_lut(13) = x;
    
	pyth_lut(15) = x;
    pyth_lut(16) = pyth_lut(10);
    pyth_lut(17) = y;
    pyth_lut(18) = pyth_lut(10);
    
    pyth_lut(19) = pyth_lut(1);
    pyth_lut(20) = pyth_lut(2);
    pyth_lut(21) = pyth_lut(1);
    pyth_lut(22) = pyth_lut(4);
    pyth_lut(23) = z;
    pyth_lut(24) = pyth_lut(4);
    pyth_lut(25) = pyth_lut(1);
    pyth_lut(26) = pyth_lut(2);
    pyth_lut(27) = pyth_lut(1);

end