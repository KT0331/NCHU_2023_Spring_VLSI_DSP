clear all %clear workspace
clc       %clear command window
  M = [ -2  16  -6 -16   3  15  -6 -19;
        16 -17  10  -2   7   8   3   5;
        -6  10  15  -1 -15 -18   9  -8;
       -16  -2  -1   9   0   0   0  18;
         3   7 -15   0  14  19 -12  11;
        15   8 -18   0  19  10  -8 -17;
        -6   3   9   0 -12  -8  15  20;
       -19   5  -8  18  11 -17  20  20];

[V, D]=eig(M);

for i = 1:2000
    [Q_mat, R_mat] = QR_decomposition_func(M);
    M = R_mat * Q_mat;
end