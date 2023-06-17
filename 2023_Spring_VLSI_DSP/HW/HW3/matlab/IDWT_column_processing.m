function [out_l ,out_h] = IDWT_column_processing(L ,input_ll ,input_lh ,input_hl ,input_hh)

%Filter coefficients
q = [-0.064538882629;
	 -0.040689417609;
	  0.418092273222;
	  0.788485616406;
	  0.418092273222;
	 -0.040689417609;
	 -0.064538882629];

p = [-0.037828455507;
	 -0.023849465020;
      0.110624404418;
      0.377402855613;
	 -0.852698679009;
	  0.377402855613;
	  0.110624404418;
	 -0.023849465020;
	 -0.037828455507];

%Symmetric extension at picture boundary and up-sampling
in_ll = zeros(L + 6 ,L / 2);
in_ll(4 : 2 : (L + 2) , : ) = input_ll;
in_ll(1 : 3 , : ) = [in_ll(7 , : ); in_ll(6 , : ); in_ll(5 , : )];
in_ll((L + 4) : (L + 6) , : ) = [in_ll(L + 2 , : ); in_ll(L + 1 , : ); in_ll(L + 0 , : )];

in_hl = zeros(L + 6 ,L / 2);
in_hl(4 : 2 : (L + 2) , : ) = input_hl;
in_hl(1 : 3 , : ) = [in_hl(7 , : ); in_hl(6 , : ); in_hl(5 , : )];
in_hl((L + 4) : (L + 6) , : ) = [in_hl(L + 2 , : ); in_hl(L + 1 , : ); in_hl(L + 0 , : )];

in_lh = zeros(L + 8 ,L / 2);
in_lh(6 : 2 : (L + 4) , : ) = input_lh;
in_lh(1 : 4 , : ) = [in_lh(9 , : ); in_lh(8 , : ); in_lh(7 , : ); in_lh(6 , : )];
in_lh((L + 5) : (L + 8) , : ) = [in_lh(L + 3 , : ); in_lh(L + 2 , : ); in_lh(L + 1 , : ); in_lh(L - 0 , : )];

in_hh = zeros(L + 8 ,L / 2);
in_hh(6 : 2 : (L + 4) , : ) = input_hh;
in_hh(1 : 4 , : ) = [in_hh(9 , : ); in_hh(8 , : ); in_hh(7 , : ); in_hh(6 , : )];
in_hh((L + 5) : (L + 8) , : ) = [in_hh(L + 3 , : ); in_hh(L + 2 , : ); in_hh(L + 1 , : ); in_hh(L - 0 , : )];

%Compute output picture
for i = 1 : (L / 2)
    temp_ll = conv(in_ll( : ,i) ,q);
    out_ll(1 : L ,i) = temp_ll(7 : L + 6 ,1);

    temp_hl = conv(in_hl( : ,i) ,q);
    out_hl(1 : L ,i) = temp_hl(7 : L + 6 ,1);

    temp_lh = conv(in_lh( : ,i) ,p);
    out_lh(1 : L ,i) = temp_lh(9 : L + 8 ,1);

    temp_hh = conv(in_hh( : ,i) ,p);
    out_hh(1 : L ,i) = temp_hh(9 : L + 8 ,1);
end

out_l = out_ll + out_lh;
out_h = out_hl + out_hh;

end