function [out_ll ,out_hl ,out_lh ,out_hh] = DWT_column_processing(L ,input_l ,input_h ,fixed_size)

%Filter coefficients
h_floating = [ 0.037828455507;
              -0.023849465020;
              -0.110624404418;
               0.377402855613;
               0.852698679009;
               0.377402855613;
              -0.110624404418;
              -0.023849465020;
               0.037828455507];

g_floating = [-0.064538882629;
               0.040689417609;
               0.418092273222;
              -0.788485616406;
               0.418092273222;
               0.040689417609;
              -0.064538882629];

%Fixed point coefficients
h = fi(h_floating ,1 ,11 ,10);
g = fi(g_floating ,1 ,11 ,10);

%Symmetric extension at picture boundary
input_l_extension_for_l = zeros(L + 8 ,L / 2 ,'like', fi([], fixed_size));
input_l_extension_for_l = [input_l(5 , : ); input_l(4 , : ); input_l(3 , : ); input_l(2 , : ); input_l; input_l(L - 1 , : ); input_l(L - 2 , : ); input_l(L - 3, : ); input_l(L - 4, : )];
input_l_extension_for_h = zeros(L + 6 ,L / 2 ,'like', fi([], fixed_size)); 
input_l_extension_for_h = [input_l(4 , : ); input_l(3 , : ); input_l(2 , : ); input_l; input_l(L - 1 , : ); input_l(L - 2 , : ); input_l(L - 3, : )];
input_h_extension_for_l = zeros(L + 8 ,L / 2 ,'like', fi([], fixed_size));
input_h_extension_for_l = [input_h(5 , : ); input_h(4 , : ); input_h(3 , : ); input_h(2 , : ); input_h; input_h(L - 1 , : ); input_h(L - 2 , : ); input_h(L - 3, : ); input_h(L - 4, : )];
input_h_extension_for_h = zeros(L + 6 ,L / 2 ,'like', fi([], fixed_size)); 
input_h_extension_for_h = [input_h(4 , : ); input_h(3 , : ); input_h(2 , : ); input_h; input_h(L - 1 , : ); input_h(L - 2 , : ); input_h(L - 3, : )];

%Compute output picture
for i = 1 : L/2
    %Lowpass filter
    temp_ll = conv(input_l_extension_for_l( : ,i) ,h);
    out_ll(1 : (L / 2) ,i) = fi(temp_ll(9 : 2 : (L + 7) ,1) ,fixed_size);

    temp_hl = conv(input_h_extension_for_l( : ,i) ,h);
    out_hl(1 : (L / 2) ,i) = fi(temp_hl(9 : 2 : (L + 7) ,1) ,fixed_size);

    %Highpass filter
    temp_lh = conv(input_l_extension_for_h( : ,i) ,g);
    out_lh(1 : (L / 2) ,i) = fi(temp_lh(8 : 2 : (L + 6) ,1) ,fixed_size);

    temp_hh = conv(input_h_extension_for_h( : ,i) ,g);
    out_hh(1 : (L / 2) ,i) = fi(temp_hh(8 : 2 : (L + 6) ,1) ,fixed_size);
end

end