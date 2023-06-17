fid_I_c0 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\I_data_c1.dat','wt');
fid_I_c1 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\I_data_c2.dat','wt');
fid_I_c2 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\I_data_c3.dat','wt');
fid_I_c3 = fopen('C:\Users\ASUS\Desktop\University\大四\Grad_Design of VLSI DSP Signal processing Architecture\HW\HW5\data\I_data_c4.dat','wt');
I=eye(4,4);
I_fixed=fi(I,1,8,0);
for i_M = 1 : 4
        fprintf(fid_I_c0 ,'%s\n' ,bin(I_fixed(i_M ,1)));
        fprintf(fid_I_c1 ,'%s\n' ,bin(I_fixed(i_M ,2)));
        fprintf(fid_I_c2 ,'%s\n' ,bin(I_fixed(i_M ,3)));
        fprintf(fid_I_c3 ,'%s\n' ,bin(I_fixed(i_M ,4)));
end
fclose(fid_I_c0);
fclose(fid_I_c1);
fclose(fid_I_c2);
fclose(fid_I_c3);