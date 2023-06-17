function [ox ,oy] = fixed_rotation_mode(k ,ix ,iy ,d ,x_y_type ,x_y_computing_type)
%x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
%y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

%Initialize
F = fimath('RoundingMethod','Nearest','OverflowAction','Wrap');
ox = fi(ix ,x_y_computing_type);
oy = fi(iy ,x_y_computing_type);

for i = 1 : 12
    ox_temp = ox;
    oy_temp = oy;
    dx_computing = - d(1 ,i) * 2^(-(i-1)) * oy_temp;
    dx = fi(dx_computing ,x_y_computing_type ,F);
    ox = ox_temp + dx;
    dy_computing = d(1 ,i) * 2^(-(i-1)) * ox_temp;
    dy = fi(dy_computing ,x_y_computing_type ,F);
    oy = oy_temp + dy;
    ox = fi(ox ,x_y_computing_type);
    oy = fi(oy ,x_y_computing_type);
end

ox = ox * k;
oy = oy * k;
ox = fi(ox ,x_y_type);
oy = fi(oy ,x_y_type);