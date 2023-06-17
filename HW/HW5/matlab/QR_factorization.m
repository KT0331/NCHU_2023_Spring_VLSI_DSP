clear
close all
clc

% Define test number
test_number = 1;
% fid_0 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\matrix.dat','wt');
% fid_1 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\golden_Q.dat','wt');
% fid_2 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\golden_R.dat','wt');
% fprintf(fid_0 ,'%d' ,test_number);
% fprintf(fid_0 ,'\n');

% fid_M_c0 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\M_data_c1.dat','wt');
% fid_M_c1 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\M_data_c2.dat','wt');
% fid_M_c2 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\M_data_c3.dat','wt');
% fid_M_c3 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\M_data_c4.dat','wt');
fid_R_c1 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\R_data_c1.dat','wt');
fid_R_c2 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\R_data_c2.dat','wt');
fid_R_c3 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\R_data_c3.dat','wt');
fid_R_c4 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\R_data_c4.dat','wt');
fid_Q_c1 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\Q_data_c1.dat','wt');
fid_Q_c2 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\Q_data_c2.dat','wt');
fid_Q_c3 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\Q_data_c3.dat','wt');
fid_Q_c4 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\Q_data_c4.dat','wt');

delta_R = zeros(test_number ,1);
delta_Q = zeros(test_number ,1);
% max_Q = zeros(test_number ,1);
% min_Q = zeros(test_number ,1);
% max_R = zeros(test_number ,1);
% min_R = zeros(test_number ,1);

for k = 1 : test_number
% Input matrix : each element's value in this matrix must between -128 to
% 127
M = [ -21 39 45 39;
       106 65 65 -85;
       74 89  62  52;
      117 111 52 -120];
% M = randi([-128 ,127] ,4 ,4);

% % QR decomposition desire
% [Q_d ,R_d] = QR_decomposition_desire_func(M);

% % Verify
% [Q,R] = qr(M);

% QR decomposition by floating point cordic
[Q_c ,R_c] = QR_decomposition_by_cordic_func(M);
% maximum of Q will be less than 1
% minimun of Q will be not less than -1
% maximum of R will be less than 255
% minimun of R will be not less than -256

% Define fixed point precision
Q_fixed = numerictype(true, 12, 11);
R_fixed = numerictype(true, 12, 3);
Q_computing_fixed = numerictype(true, 20, 18);
R_computing_fixed = numerictype(true, 20, 10);
M_fixed = fi(M ,1 ,8 ,0);
% for i_M = 1 : 4
%     for j_M = 1 : 4
%         fprintf(fid_0 ,'%s' ,bin(M_fixed(i_M ,j_M)));
%         fprintf(fid_0 ,' //M[%d][%d]' ,i_M ,j_M);
%         fprintf(fid_0 ,'\n');
%     end
% end
% fprintf(fid_0 ,'\n');

% for i_M = 1 : 4
%         fprintf(fid_M_c0 ,'%s\n' ,bin(M_fixed(i_M ,1)));
%         fprintf(fid_M_c1 ,'%s\n' ,bin(M_fixed(i_M ,2)));
%         fprintf(fid_M_c2 ,'%s\n' ,bin(M_fixed(i_M ,3)));
%         fprintf(fid_M_c3 ,'%s\n' ,bin(M_fixed(i_M ,4)));
% end

% QR decomposition by fixed point cordic
[Q_c_fixed ,R_c_fixed] = QR_decomposition_by_fixed_cordic_func(M_fixed ,Q_fixed ,R_fixed ,Q_computing_fixed ,R_computing_fixed);

% for i_Q = 1 : 4
%     for j_Q = 1 : 4
%         fprintf(fid_1 ,'%s' ,bin(Q_c_fixed(i_Q ,j_Q)));
%         fprintf(fid_1 ,' //Q[%d][%d]' ,i_Q ,j_Q);
%         fprintf(fid_1 ,'\n');
%     end
% end
% fprintf(fid_1 ,'\n');
% 
% for i_R = 1 : 4
%     for j_R = 1 : 4
%         fprintf(fid_2 ,'%s' ,bin(R_c_fixed(i_R ,j_R)));
%         fprintf(fid_2 ,' //R[%d][%d]' ,i_R ,j_R);
%         fprintf(fid_2 ,'\n');
%     end
% end
% fprintf(fid_2 ,'\n');
for i_R = 1 : 4
        fprintf(fid_R_c1 ,'%s\n' ,bin(R_c_fixed(i_R ,1)));
        fprintf(fid_R_c2 ,'%s\n' ,bin(R_c_fixed(i_R ,2)));
        fprintf(fid_R_c3 ,'%s\n' ,bin(R_c_fixed(i_R ,3)));
        fprintf(fid_R_c4 ,'%s\n' ,bin(R_c_fixed(i_R ,4)));
end
for i_Q = 1 : 4
        fprintf(fid_Q_c1 ,'%s\n' ,bin(Q_c_fixed(i_Q ,1)));
        fprintf(fid_Q_c2 ,'%s\n' ,bin(Q_c_fixed(i_Q ,2)));
        fprintf(fid_Q_c3 ,'%s\n' ,bin(Q_c_fixed(i_Q ,3)));
        fprintf(fid_Q_c4 ,'%s\n' ,bin(Q_c_fixed(i_Q ,4)));
end

% Computing delta
R_diff = (abs(R_c) - abs(double(R_c_fixed))) .^ 2;
sum_R_diff = sum(R_diff(1,:)) + sum(R_diff(2, 2:4)) + sum(R_diff(3, 3:4)) + sum(R_diff(4, 4));
R_c_square = R_c .^ 2;
sum_R = sum(R_c_square(1,:)) + sum(R_c_square(2, 2:4)) + sum(R_c_square(3, 3:4)) + sum(R_c_square(4, 4));
delta_R(k,1) = sqrt(sum_R_diff)/sqrt(sum_R);
if delta_R(k,1) > 0.01
    break;
end
Q_diff = (abs(Q_c) - abs(double(Q_c_fixed))) .^ 2;
sum_Q_diff = sum((Q_diff));
Q_c_square = Q_c .^ 2;
sum_Q = sum((Q_c_square));
delta_Q(k,1) = sqrt(sum_Q_diff)/sqrt(sum_Q);
if delta_Q(k,1) > 0.01
    break;
end
end

% Q_max = max(max_Q);
% R_max = max(max_R);
% Q_min = min(min_Q);
% R_min = min(min_R);

% fclose(fid_0);
% fclose(fid_1);
% fclose(fid_2);
fclose(fid_R_c1);
fclose(fid_R_c2);
fclose(fid_R_c3);
fclose(fid_R_c4);
fclose(fid_Q_c1);
fclose(fid_Q_c2);
fclose(fid_Q_c3);
fclose(fid_Q_c4);
% fclose(fid_M_c3);
% fclose(fid_M_c4);

delta_R_max = max(delta_R);
delta_Q_max = max(delta_Q);
% disp('M =');
% disp(M);
% disp('M_fixed =');
% disp(M_fixed);
% disp('desire R =');
% disp(R_c);
% disp('Cordic R =');
% disp(R_c_fixed);
% disp('desire Q =');
% disp(Q_c);
% disp('Cordic Q =');
% disp(Q_c_fixed);
disp(['delta(R) = ',num2str(delta_R_max)]);
disp(['delta(Q) = ',num2str(delta_Q_max)]);
