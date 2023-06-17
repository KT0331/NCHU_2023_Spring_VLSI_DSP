function [Q, R] = QR_decomposition_func(M)
    s = 2; % start row, adding by 1 at each round beginning
    R = M;
    Q = eye(8, 8);% eye(8, 8) = identity matrix 8*8
    % QR decomposition 
    for j = 1:8
        for i = s:8
            rotation_param = R(:, j);
            cos = rotation_param(j) / (rotation_param(j)^2 + rotation_param(i)^2)^0.5;
            sin = rotation_param(i) / (rotation_param(j)^2 + rotation_param(i)^2)^0.5;
            % creat unitary matrix q
            q = eye(8, 8);
            q(i, i) =  cos;
            q(j, i) =  sin;
            q(i, j) = -sin;
            q(j, j) =  cos;
            % cal & update R
            R = q * R;
            Q = q * Q;
        end
        s = s + 1;
    end
    Q = Q';
end