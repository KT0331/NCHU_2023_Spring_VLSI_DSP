function [Q ,R] = QR_decomposition_desire_func(M)
    e = 2; %end row, sub by 1 at each round beginning
    RQ = [M eye(4, 4)];% eye(4, 4) = identity matrix 4*4
    for j = 1:4
        for i = 4:-1:e
            rotation_param = RQ(i-1:i, j);
            cos = rotation_param(1) / (rotation_param(1)^2 + rotation_param(2)^2)^0.5;
            sin = rotation_param(2) / (rotation_param(1)^2 + rotation_param(2)^2)^0.5;
            % creat unitary matrix q
            q = eye(4, 4);
            q(i-1, i-1) =  cos;
            q(i-1, i)   =  sin;
            q(i, i-1)   = -sin;
            q(i, i)     =  cos;
            % cal & update R
            RQ = q * RQ;
        end
        e = e + 1;
    end
    R = RQ(1:4,1:4);
    Q = RQ(1:4,5:8)';
end