function [Q ,R] = QR_decomposition_by_cordic_func(M)

    % tan(alpha) table
    alpha = [45 26.57 14.04 7.13 3.58 1.79 0.90 0.45 0.22 0.11 0.06 0.03;
             2^(-0) 2^(-1) 2^(-2) 2^(-3) 2^(-4) 2^(-5) 2^(-6) 2^(-7) 2^(-8) 2^(-9) 2^(-10) 2^(-11)];
    K = 1;
    for km = 1 : 12
        K = K * cosd(alpha(1,km));
    end

    e = 2; %end row, sub by 1 at each round beginning
    RQ = [M eye(4, 4)];% eye(4, 4) = identity matrix 4*4
    for j = 1:4
        for i = 4:-1:e
            rotation_param = RQ(i-1:i, j);
            [RQ(i-1, j) ,RQ(i, j) ,d] = vectoring_mode(K ,rotation_param(1) ,rotation_param(2));
            for j_1 = j+1 : 8
                [RQ(i-1, j_1) ,RQ(i, j_1)] = rotation_mode(K ,RQ(i-1, j_1) ,RQ(i, j_1) ,d);
            end
        end
        e = e + 1;
    end
    R = RQ(1:4,1:4);
    Q = RQ(1:4,5:8)';
    % R_max = max(max(R)');
    % Q_max = max(max(Q)');
    % R_min = min(min(R)');
    % Q_min = min(min(Q)');
end