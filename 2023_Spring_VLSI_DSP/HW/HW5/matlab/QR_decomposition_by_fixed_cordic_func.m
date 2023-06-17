function [Q ,R] = QR_decomposition_by_fixed_cordic_func(M ,Q_fixed ,R_fixed ,Q_computing_fixed ,R_computing_fixed)

    % tan(alpha) table
    alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03;
             2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11)];
    K = 1;
    for km = 1 : 12
        K = K * cosd(alpha(1,km));
    end
    K_fix = fi(K, 1, 22 ,21);
    e = 2; %end row, sub by 1 at each round beginning
    R = M ;
    R = fi(R ,R_fixed);
    Q = fi(eye(4, 4) ,Q_fixed);% eye(4, 4) = identity matrix 4*4
    for j = 1:4
        for i = 4:-1:e
            rotation_param = R(i-1:i, j);
            [R(i-1, j) ,R(i, j) ,d] = fixed_vectoring_mode(K_fix ,rotation_param(1) ,rotation_param(2) ,R_fixed ,R_computing_fixed);
            for j_1 = j+1 : 8
                if j_1 <= 4
                    [R(i-1, j_1) ,R(i, j_1)] = fixed_rotation_mode(K_fix ,R(i-1, j_1) ,R(i, j_1) ,d ,R_fixed ,R_computing_fixed);
                else
                    [Q(i-1, j_1-4) ,Q(i, j_1-4)] = fixed_rotation_mode(K_fix ,Q(i-1, j_1-4) ,Q(i, j_1-4) ,d ,Q_fixed ,Q_computing_fixed);
                end
            end
        end
        e = e + 1;
    end
    R = fi(R(1:4,1:4)  ,R_fixed);
    Q = fi(Q(1:4,1:4)' ,Q_fixed);
end