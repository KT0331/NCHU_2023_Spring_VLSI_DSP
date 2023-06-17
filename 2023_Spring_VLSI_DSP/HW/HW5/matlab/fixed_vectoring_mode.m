function [ox ,oy ,d] = fixed_vectoring_mode(k ,ix ,iy ,x_y_type ,x_y_computing_type)
%d(i)   = -sign(x(i) * y(i))
%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

%Initialize
F = fimath('RoundingMethod','Nearest','OverflowAction','Wrap');
ox = fi(ix ,x_y_computing_type);
oy = fi(iy ,x_y_computing_type);

%History of d ,x ,y
d = zeros(1 ,12);
x = zeros(1 ,13);
x(1 ,1) = ox;
y = zeros(1 ,13);
y(1 ,1) = oy;

for i = 1 : 12
    %Decide rotation direction : -1 means clockwise and +1 means counterclockwise
    if ox * oy > 0
        d(1 ,i) = -1;
    elseif ox * oy < 0
        d(1 ,i) = +1;
    else
        d(1 ,i) = -1;
    end
    % if i==2
        % disp(d(1 ,i));
    % end
    ox_temp = ox;
    % if i==2
        disp('ox_temp=');
        disp(bin(ox_temp));
        disp(ox_temp);
    % end
    oy_temp = oy;
    % if i==2
        disp('oy_temp=');
        disp(bin(oy_temp));
        disp(oy_temp);
    % end
    dx_computing = - d(1 ,i) * 2^(-(i-1)) * oy_temp;
    % if i==2
        disp('dx_computing');
        disp(bin(dx_computing));
        disp(dx_computing);
        disp(bin(fi( (-1 * 2^(-(i-1)) * oy_temp) ,x_y_computing_type ,F)));
        disp(fi( (-1 * 2^(-(i-1)) * oy_temp) ,x_y_computing_type ,F));
    % end
    dx = fi(dx_computing ,x_y_computing_type ,F);
    % if i==2
        disp('dx');
        disp(bin(dx));
        disp(dx);
    % end
    ox = ox_temp + dx;
    % if i==2
        disp('ox=');
        disp(bin(ox));
        disp(ox);
    % end
    dy_computing = d(1 ,i) * 2^(-(i-1)) * ox_temp;
        disp('yx_computing');
        disp(bin(fi( (2^(-(i-1)) * ox_temp) ,x_y_computing_type ,F)));
    dy = fi(dy_computing ,x_y_computing_type ,F);
    oy = oy_temp + dy;
    ox = fi(ox ,x_y_computing_type);
    % if i==2
        disp('ox=');
        disp(bin(ox));
        disp(ox);
    % end
    oy = fi(oy ,x_y_computing_type);
        disp('ox=');
        disp(bin(ox));
        disp(ox);
        disp('oy=');
        disp(bin(oy));
        disp(oy);
    x(1 ,i+1) = ox;
    y(1 ,i+1) = oy;
end

ox = k * ox;
oy = k * oy;
ox = fi(ox ,x_y_type);
oy = fi(oy ,x_y_type);
oy = fi(oy ,x_y_type);