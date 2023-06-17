module adder #(
parameter data_width = 20,
parameter out_width = 10)
(
input  signed [data_width - 1:0] data_a,
input  signed [data_width - 1:0] data_b,
output signed [out_width - 1:0]  result);

wire signed [data_width:0]  add_result;

assign add_result = data_a + data_b;
assign result = {add_result[data_width] ,add_result[out_width - 2:0]};

endmodule