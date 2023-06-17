module compression #(
parameter pic_size = 64,
parameter pic_addr_width = 12)
(
output reg [14:0]                 odata,
//output reg [pic_addr_width:0]     oaddr,
output reg [pic_addr_width - 1:0] iaddr,
output reg                        o_valid,
output reg                        end_flag,
input  clk,
input  rst,
input  ready,
input  out_stop,
input  signed [9:0] idata);

reg signed [7:0] data [0:1];
reg signed [7:0] diff;

reg [(pic_addr_width / 2) - 1:0] iaddr_x;
reg [(pic_addr_width / 2) - 1:0] iaddr_y;

reg [2:0] c_state;
reg [2:0] n_state;
reg state_idle;
reg state_load;
reg state_diff;
reg state_out;
reg state_end;

reg counter;
reg end_ready;

wire signed [9:0] idata_2_complement;
wire signed [7:0] idata_neg_div;
wire signed [7:0] idata_pos_div;
wire [3:0] diff_l;
wire [3:0] diff_r;
reg [14:0] huffman_l;
reg [14:0] huffman_r;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            FSM parameters                                                     //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE      = 0;
localparam LOAD      = 1;
localparam LOAD_WAIT = 2;
localparam DIFF      = 3;
localparam OUT       = 4;
localparam END       = 5;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                 FSM                                                           //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		c_state <= IDLE;
	end
	else begin
		c_state <= n_state;
	end
end

always @(*) begin
	case(c_state)
		IDLE: begin
			if(out_stop) begin
				n_state = IDLE;
			end
			else if(ready) begin
				n_state = LOAD;
			end
			else begin
				n_state = IDLE;
			end
		end
		LOAD: begin
			if(out_stop) begin
				n_state = LOAD;
			end
			else begin
				n_state = LOAD_WAIT;
			end
		end
		LOAD_WAIT: begin
			if(out_stop) begin
				n_state = LOAD_WAIT;
			end
			else begin
				n_state = DIFF;
			end
		end
		DIFF: begin
			if(out_stop) begin
				n_state = DIFF;
			end
			else begin
				n_state = OUT;
			end
		end
		OUT: begin
			if(out_stop) begin
				n_state = OUT;
			end
			else begin
				if((iaddr_x == 0) && (iaddr_y == 0) && end_ready) begin
					if(counter) begin
						n_state = END;
					end
					else begin
						n_state = OUT;
					end
				end
				else begin
					if(counter) begin
						n_state = LOAD;
					end
					else begin
						n_state = OUT;
					end
				end
			end
		end
		END: begin
			if(out_stop) begin
				n_state = END;
			end
			else begin
				n_state = END;
			end
		end
		default: begin
			n_state = LOAD;
		end
	endcase
end

always @(*) begin
	case(c_state)
		IDLE: begin
			state_idle = 1;
			state_load = 0;
			state_diff = 0;
			state_out  = 0;
			state_end  = 0;
		end
		LOAD: begin
			state_idle = 0;
			state_load = 1;
			state_diff = 0;
			state_out  = 0;
			state_end  = 0;
		end
		LOAD_WAIT: begin
			state_idle = 0;
			state_load = 0;
			state_diff = 0;
			state_out  = 0;
			state_end  = 0;
		end
		DIFF: begin
			state_idle = 0;
			state_load = 0;
			state_diff = 1;
			state_out  = 0;
			state_end  = 0;
		end
		OUT: begin
			state_idle = 0;
			state_load = 0;
			state_diff = 0;
			state_out  = 1;
			state_end  = 0;
		end
		END: begin
			state_idle = 0;
			state_load = 0;
			state_diff = 0;
			state_out  = 0;
			state_end  = 1;
		end
		default: begin
			state_idle = 0;
			state_load = 0;
			state_diff = 0;
			state_out  = 0;
			state_end  = 0;
		end
	endcase
end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            main circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign idata_2_complement = ~idata + 1'b1;
assign idata_neg_div = ~idata_2_complement[9:2] + 1'b1;
assign idata_pos_div = idata[9:2];

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		iaddr <= 0;
	end
	else begin
		if(out_stop) begin
			iaddr <= iaddr;
		end
		else if(state_idle) begin
			iaddr <= 0;
		end
		else begin
			iaddr <= iaddr_x + (iaddr_y * pic_size);
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		iaddr_x <= 0;
		iaddr_y <= 0;
	end
	else begin
		if(out_stop) begin
			iaddr_x <= iaddr_x;
			iaddr_y <= iaddr_y;
		end
		else if(state_idle) begin
			iaddr_x <= 0;
			iaddr_y <= 0;
		end
		else if(state_load) begin
			{iaddr_y ,iaddr_x} <= {iaddr_y ,iaddr_x} + 1;
		end
		else begin
			{iaddr_y ,iaddr_x} <= {iaddr_y ,iaddr_x};
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		end_ready <= 0;
	end
	else begin
		if(state_load) begin
			if((iaddr_x == pic_size - 1) && (iaddr_y == pic_size - 1)) begin
				end_ready <= 1;
			end
			else begin
				end_ready <= end_ready;
			end
		end
		else if(state_idle) begin
			end_ready <= 0;
		end
		else begin
			end_ready <= end_ready;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		o_valid <= 0;
	end
	else begin
		if(out_stop) begin
			o_valid <= o_valid;
		end
		else if(state_idle) begin
			o_valid <= 0;
		end
		else if(state_out) begin
			o_valid <= 1;
		end
		else begin
			o_valid <= 0;
		end
	end
end
/*
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		oaddr <= 0;
	end
	else begin
		if(out_stop) begin
			oaddr <= oaddr;
		end
		else if(state_idle) begin
			oaddr <= 0;
		end
		else if(o_valid) begin
			oaddr <= oaddr + 1;
		end
		else begin
			oaddr <= oaddr;
		end
	end
end
*/
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		data[0] <= 0;
	end
	else begin
		if(out_stop) begin
			data[0] <= data[0];
		end
		else if(state_idle) begin
			data[0] <= 0;
		end
		else if(state_load) begin
			if(iaddr_x == 0) begin
				data[0] <= 0;
			end
			else if(iaddr_x == pic_size/2) begin
				data[0] <= 0;
			end
			else begin
				data[0] <= data[1];
			end
		end
		else begin
			data[0] <= data[0];
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		data[1] <= 0;
	end
	else begin
		if(out_stop) begin
			data[1] <= data[1];
		end
		else if(state_idle) begin
			data[1] <= 0;
		end
		else if(state_load) begin
			if(idata[9]) begin
				data[1] <= idata_neg_div;
			end
			else begin
				data[1] <= idata_pos_div;
			end
		end
		else begin
			data[1] <= data[1];
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		diff <= 0;
	end
	else begin
		if(out_stop) begin
			diff <= diff;
		end
		else if(state_idle) begin
			diff <= 0;
		end
		else if(state_diff) begin
			diff <= data[1] - data[0];
		end
		else begin
			diff <= diff;
		end
	end
end

assign diff_l = diff[7:4];
assign diff_r = diff[3:0];

always @(*) begin
	case(diff_l)
		4'b0000: huffman_l = 15'b000_0000_0000_0000;
		4'b0001: huffman_l = 15'b000_0000_0000_0110;
		4'b0010: huffman_l = 15'b000_0000_0001_1110;
		4'b0011: huffman_l = 15'b000_0000_0111_1110;
		4'b0100: huffman_l = 15'b000_0000_1111_1110;
		4'b0101: huffman_l = 15'b000_0011_1111_1110;
		4'b0110: huffman_l = 15'b000_1111_1111_1110;
		4'b0111: huffman_l = 15'b011_1111_1111_1110;
		4'b1000: huffman_l = 15'b111_1111_1111_1111;
		4'b1001: huffman_l = 15'b111_1111_1111_1110;
		4'b1010: huffman_l = 15'b001_1111_1111_1110;
		4'b1011: huffman_l = 15'b000_0111_1111_1110;
		4'b1100: huffman_l = 15'b000_0001_1111_1110;
		4'b1101: huffman_l = 15'b000_0000_0011_1110;
		4'b1110: huffman_l = 15'b000_0000_0000_1110;
		4'b1111: huffman_l = 15'b000_0000_0000_0010;
	endcase
end

always @(*) begin
	case(diff_r)
		4'b0000: huffman_r = 15'b000_0000_0000_0000;
		4'b0001: huffman_r = 15'b000_0000_0000_0110;
		4'b0010: huffman_r = 15'b000_0000_0001_1110;
		4'b0011: huffman_r = 15'b000_0000_0111_1110;
		4'b0100: huffman_r = 15'b000_0000_1111_1110;
		4'b0101: huffman_r = 15'b000_0011_1111_1110;
		4'b0110: huffman_r = 15'b000_1111_1111_1110;
		4'b0111: huffman_r = 15'b011_1111_1111_1110;
		4'b1000: huffman_r = 15'b111_1111_1111_1111;
		4'b1001: huffman_r = 15'b111_1111_1111_1110;
		4'b1010: huffman_r = 15'b001_1111_1111_1110;
		4'b1011: huffman_r = 15'b000_0111_1111_1110;
		4'b1100: huffman_r = 15'b000_0001_1111_1110;
		4'b1101: huffman_r = 15'b000_0000_0011_1110;
		4'b1110: huffman_r = 15'b000_0000_0000_1110;
		4'b1111: huffman_r = 15'b000_0000_0000_0010;
	endcase
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		counter <= 0;
	end
	else begin
		if(out_stop) begin
			counter <= counter;
		end
		else if(state_out) begin
			counter <= counter + 1'b1;
		end
		else begin
			counter <= 0;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		odata <= 0;
	end
	else begin
		if(out_stop) begin
			odata <= odata;
		end
		else if(state_idle) begin
			odata <= 0;
		end
		else if(state_out) begin
			if(counter) begin
				odata <= huffman_r;
			end
			else begin
				odata <= huffman_l;
			end
		end
		else begin
			odata <= odata;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		end_flag <= 0;
	end
	else begin
		if(out_stop) begin
			end_flag <= end_flag;
		end
		else if(state_end) begin
			end_flag <= 1;
		end
		else begin
			end_flag <= 0;
		end
	end
end



endmodule