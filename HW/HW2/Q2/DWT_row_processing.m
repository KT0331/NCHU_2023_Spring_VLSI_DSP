function [out_l ,out_h] = DWT_row_processing(L ,pic)

%Filter coefficients
h = [ 0.037828455507;
     -0.023849465020;
     -0.110624404418;
      0.377402855613;
      0.852698679009;
      0.377402855613;
     -0.110624404418;
     -0.023849465020;
      0.037828455507];

g = [-0.064538882629;
      0.040689417609;
      0.418092273222;
     -0.788485616406;
      0.418092273222;
      0.040689417609;
     -0.064538882629];

%Symmetric extension at picture boundary
p_l = zeros(L ,L + 8);
p_l = [pic( : ,5) pic( : ,4) pic( : ,3) pic( : ,2) pic pic( : ,L - 1) pic( : ,L - 2) pic( : ,L - 3) pic( : ,L - 4)];
p_h = zeros(L ,L + 6);
p_h = [pic( : ,4) pic( : ,3) pic( : ,2) pic pic( : ,L - 1) pic( : ,L - 2) pic( : ,L - 3)];

%Compute output picture
for i = 1 : L
    %Lowpass filter
    temp_l  = conv(p_l(i , :) ,h);
    out_l(i , 1 : (L / 2)) = temp_l(1 ,9 : 2 : (L + 7));

    %Highpass filter
    temp_h  = conv(p_h(i , :) ,g);
    out_h(i , 1 : (L / 2)) = temp_h(1 ,8 : 2 : (L + 6));
end

end