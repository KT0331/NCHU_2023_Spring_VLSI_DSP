clear all %clear workspace
clc       %clear command window
%clf       %clear figure
A = [ 15 -13  20  -8;
      -5 -15  -4  -4;
     -17  16  -2   9;
      10 -19 -14 -15;
      -7   8  -7  15;
      14  10  -8 -17;
      -5  -3  16  -2;
      13  -5 -10 -19];
b = [13; 10; -15; 9; 3; 18; 3; 20];
A_plus = pinv(A);
x_a = A_plus * b;
[Q, R] = qr(A);
R_u = R([1 2 3 4], : );
y = Q' * b; % Q' = Q transpose
y_u = y([1 2 3 4], : );
x_b = inv(R_u) *  y_u; % x_b = R \ y = R \ (Q \ b)