module multiplier (
input  signed [10:0] coe,
input  signed [9:0]  pic,
output signed [20:0] mult_result);

assign mult_result = coe * pic;

endmodule