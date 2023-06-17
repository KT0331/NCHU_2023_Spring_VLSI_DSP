function [pic] = IDWT_row_processing(L ,input_l ,input_h)

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
in_l = zeros(L ,L + 6);
in_l( : ,4 : 2 : (L + 2)) = input_l;
in_l( : ,1 : 3) = [in_l( : ,7) in_l( : ,6) in_l( : ,5)];
in_l( : ,(L + 4) : (L + 6)) = [in_l( : , L + 2 ) in_l( : , L + 1 ) in_l( : , L + 0 )];

in_h = zeros(L ,L + 8);
in_h( : ,6 : 2 : (L + 4)) = input_h;
in_h( : ,1 : 4) = [in_h( : ,9) in_h( : ,8) in_h( : ,7) in_h( : ,6)];
in_h( : ,(L + 5) : (L + 8)) = [in_h( : , L + 3 ) in_h( : , L + 2 ) in_h( : , L + 1 ) in_h( : , L + 0 )];

%Compute output picture
for i = 1 : L
    temp_l = conv(in_l(i , : ) ,q);
    out_l(i ,1 : L)  = temp_l(1 ,7 : L + 6);

    temp_h = conv(in_h(i , : ) ,p);
    out_h(i ,1 : L)  = temp_h(1 ,9 : L + 8);
end

pic = out_l + out_h;

end