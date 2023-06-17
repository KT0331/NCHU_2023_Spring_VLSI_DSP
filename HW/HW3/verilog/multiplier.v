module multiplier #(
parameter pic_width = 9)
(
input  signed [10:0] 			coe,
input  signed [pic_width - 1:0] pic,
output signed [10 + pic_width:0] mult_result);

assign mult_result = coe * pic;

endmodule