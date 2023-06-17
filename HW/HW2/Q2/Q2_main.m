clear all
clc
clf

%Read image
test_image = double(imread('HW2_test_image.bmp'));

%Define output result matrix
DWT_out = zeros(512,512);

%Define image process length
L = 512;

%DWT
[out_l ,out_h] = DWT_row_processing(L ,test_image);
[out_ll ,out_hl ,out_lh ,out_hh] = DWT_column_processing(L ,out_l ,out_h);
DWT_out(1 : 256 ,257 : 512)   = out_hl;
DWT_out(257 : 512 ,1 : 256)   = out_lh;
DWT_out(257 : 512 ,257 : 512) = out_hh;

[out_l_2 ,out_h_2] = DWT_row_processing(256 ,out_ll);
[out_ll_2 ,out_hl_2 ,out_lh_2 ,out_hh_2] = DWT_column_processing(256 ,out_l_2 ,out_h_2);
DWT_out(1 : 128 ,129 : 256)   = out_hl_2;
DWT_out(129 : 256 ,1 : 128)   = out_lh_2;
DWT_out(129 : 256 ,129 : 256) = out_hh_2;

[out_l_3 ,out_h_3] = DWT_row_processing(128 ,out_ll_2);
[out_ll_3 ,out_hl_3 ,out_lh_3 ,out_hh_3] = DWT_column_processing(128 ,out_l_3 ,out_h_3);
DWT_out(1 : 64 ,1 : 64)     = out_ll_3;
DWT_out(1 : 64 ,65 : 128)   = out_hl_3;
DWT_out(65 : 128 ,1 : 64)   = out_lh_3;
DWT_out(65 : 128 ,65 : 128) = out_hh_3;

%IDWT
[I_out_l_2 ,I_out_h_2] = IDWT_column_processing(128 ,out_ll_3 ,out_lh_3 ,out_hl_3 ,out_hh_3);
[inv_pic_2] = IDWT_row_processing(128 ,I_out_l_2 ,I_out_h_2);

[I_out_l_1 ,I_out_h_1] = IDWT_column_processing(256 ,inv_pic_2 ,out_lh_2 ,out_hl_2 ,out_hh_2);
[inv_pic_1] = IDWT_row_processing(256 ,I_out_l_1 ,I_out_h_1);

[I_out_l ,I_out_h] = IDWT_column_processing(L ,inv_pic_1 ,out_lh ,out_hl ,out_hh);
[inv_pic] = IDWT_row_processing(L ,I_out_l ,I_out_h);

[I_out_l_0 ,I_out_h_0] = IDWT_column_processing(L ,inv_pic_1 ,0 ,0 ,0);
[inv_pic_b] = IDWT_row_processing(L ,I_out_l_0 ,I_out_h_0);

%PSNR
MSE = 0;
for i = 1 : 512
    for j = 1 : 512
	    MSE = MSE + ((test_image(i ,j) - inv_pic(i ,j)) ^ 2);
    end
end
MSE = MSE / (512 ^ 2);
PSNR = 10 * (log10((255 ^ 2) / MSE));
disp(['(a) PSNR = ',num2str(PSNR) ,' dB']);

MSE_b = 0;
for i = 1 : 512
    for j = 1 : 512
	    MSE_b = MSE_b + ((test_image(i ,j) - inv_pic_b(i ,j)) ^ 2);
    end
end
MSE_b = MSE_b / (512 ^ 2);
PSNR_b = 10 * (log10((255 ^ 2) / MSE_b));
disp(['(b) PSNR = ',num2str(PSNR_b) ,' dB']);

%Display image after processing
figure(1)
imshow(mat2gray(test_image));

figure(2)
imshow(mat2gray(DWT_out));

figure(3)
imshow(mat2gray(inv_pic,[0,255]));

figure(4)
imshow(mat2gray(inv_pic_b,[0,255]));
