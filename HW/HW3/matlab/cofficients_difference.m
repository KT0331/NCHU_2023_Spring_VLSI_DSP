clear all
close all
clc

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

W = 16;
h_error = zeros(W, 1);
g_error = zeros(W, 1);

for i = 8 : W
    h_fix = fi(h, 1, i, i-1);
    g_fix = fi(g, 1, i, i-1);
    h_error(i) = sum(abs(h - double(h_fix))) * 100;
    g_error(i) = sum(abs(g - double(g_fix))) * 100;
end

figure(1)
hold on
plot(h_error,'k*-');
plot(g_error,'bs-');
legend('h', 'g');
xlabel('coefficient word length');
ylabel('Coefficient difference (%)');
xlim([8 W]);
ylim([0 2.0]);
title('Filter coefficients difference');
hold off