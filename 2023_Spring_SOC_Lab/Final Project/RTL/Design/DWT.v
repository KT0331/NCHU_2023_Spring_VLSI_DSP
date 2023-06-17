module DWT(
output reg signed [9:0] dwt_pixel,
output reg h_or_g, // h == 0 ,g == 1
input clk,
input rst,
input ready,
input [9:0] idata,
input [3:0] sp);

reg [9:0]  data [0:8];
reg [10:0] mult_coe    [0:8];
reg [9:0]  mult_data   [0:8];

reg signed [20:0] mult_result_pipe [0:8];
reg signed [28:0] add_result;

wire signed [20:0] mult_result [0:8];


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            instantiation                                                      //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
generate
	genvar j;
		for(j = 0; j < 9; j = j + 1) begin: mult
			multiplier u_multiplier(
				.coe(mult_coe[j]),
				.pic(mult_data[j]),
				.mult_result(mult_result[j]));
		end
endgenerate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                           Filter declear                                                      //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire signed [10:0] h [0:8]; // lowpass filter
wire signed [10:0] g [0:8]; // highpass filter

assign h[0] = 11'b000_0010_0111;
assign h[1] = 11'b111_1110_1000;
assign h[2] = 11'b111_1000_1111;
assign h[3] = 11'b001_1000_0010;
assign h[4] = 11'b011_0110_1001;
assign h[5] = 11'b001_1000_0010;
assign h[6] = 11'b111_1000_1111;
assign h[7] = 11'b111_1110_1000;
assign h[8] = 11'b000_0010_0111;

assign g[0] = 0;
assign g[1] = 11'b111_1011_1110;
assign g[2] = 11'b000_0010_1010;
assign g[3] = 11'b001_1010_1100;
assign g[4] = 11'b100_1101_1001;
assign g[5] = 11'b001_1010_1100;
assign g[6] = 11'b000_0010_1010;
assign g[7] = 11'b111_1011_1110;
assign g[8] = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            main circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		data[0] <= 0;
	end
	else begin
		if(ready) begin
			data[0] <= idata;
		end
		else begin
			data[0] <= data[0];
		end
	end
end

genvar i;
generate
	for(i = 0; i < 8; i = i + 1) begin: data_array
		always @(posedge clk or negedge rst) begin
			if (!rst) begin
				data[i + 1] <= 0;
			end
			else begin
				if(ready) begin
					data[i + 1] <= data[i];
				end
				else begin
					data[i + 1] <= data[i + 1];
				end
			end
		end
	end
endgenerate

genvar k;
generate
	for(k = 0; k < 9; k = k + 1) begin: compute
		always @(*) begin
			if(h_or_g) begin
				mult_coe[k]    = g[k];
				mult_data[k]   = data[k];
			end
			else begin
				mult_coe[k]    = h[k];
				mult_data[k]   = data[k];
			end
		end

		always @(posedge clk or negedge rst) begin
			if (!rst) begin
				mult_result_pipe[k] <= 0;
			end
			else begin
				mult_result_pipe[k] <= mult_result[k];
			end
		end

		always @(*) begin
			add_result = mult_result_pipe[0] + mult_result_pipe[1] + mult_result_pipe[2]
						 + mult_result_pipe[3] + mult_result_pipe[4] + mult_result_pipe[5]
						 + mult_result_pipe[6] + mult_result_pipe[7] + mult_result_pipe[8];
		end
	end
endgenerate

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		dwt_pixel <= 0;
	end
	else begin
		if((!add_result[28]) && (|add_result[27:19])) begin
			dwt_pixel <= 10'd511;  /////modify
		end
		else begin
			dwt_pixel <= {add_result[28] ,add_result[18:10]} + add_result[9];
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		h_or_g <= 1;
	end
	else begin
		if(sp >= 12) begin
			h_or_g <= ~h_or_g;
		end
		else begin
			h_or_g <= 1;
		end
	end
end

endmodule