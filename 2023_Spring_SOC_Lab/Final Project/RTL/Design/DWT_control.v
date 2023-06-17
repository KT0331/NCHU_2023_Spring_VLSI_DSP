module DWT_control #(
parameter pic_size = 64,
parameter pic_addr_width = 12)
(
output     [9:0]  				  dwt_pixel,
output reg [pic_addr_width - 1:0] oaddr,
output reg        				  o_valid,
output reg [pic_addr_width - 1:0] iaddr,
output reg 						  mode, // row_process == 0, column_process == 1;
output reg  					  end_flag,
input clk,
input rst,
input ready,
input [9:0] idata);

reg [(pic_addr_width / 2):0] iaddr_x;
reg [(pic_addr_width / 2):0] iaddr_y;
reg [1:0]  n_state;
reg [1:0]  c_state;
reg mode_change;
reg mode_change_buff_0;
reg mode_change_buff_1;
reg [3:0]  sp;
reg [1:0]  counter;
reg mode_buff;

reg state_idle;
reg state_load;
reg state_end;
reg sp_flag;
reg busy_l;
reg busy_h;

wire h_or_g;

DWT u_dwt(
.dwt_pixel(dwt_pixel),
.h_or_g(h_or_g),
.clk(clk),
.rst(rst),
.ready(ready),
.idata(idata),
.sp(sp));


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            FSM parameters                                                     //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE = 0;
localparam LOAD = 1;
localparam WAIT = 2;
localparam END  = 3;
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
		IDLE : begin
			if(ready) begin
				n_state = LOAD;
			end
			else begin
				n_state = IDLE;
			end
		end
		LOAD : begin
			if(mode_change) begin
				n_state = LOAD;
			end
			else begin
				n_state = WAIT;
			end
		end
		WAIT : begin
			if(counter == 3) begin
				n_state = END;
			end
			else begin
				n_state = WAIT;
			end
		end
		END : n_state = LOAD;
		default : n_state = LOAD;
	endcase
end

always @(*) begin
	case(c_state)
		IDLE : begin
			state_idle = 1;
			state_load = 0;
			state_end  = 0;
		end
		LOAD : begin
			state_idle = 0;
			state_load = 1;
			state_end  = 0;
		end
		END : begin
			state_idle = 0;
			state_load = 0;
			state_end  = 1;
		end
		default : begin
			state_idle = 0;
			state_load = 0;
			state_end  = 0;
		end
	endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            main circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		iaddr <= 0;	
	end
	else begin
		iaddr <= iaddr_x + (iaddr_y * pic_size);
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		iaddr_x <= 0;
		iaddr_y <= 0;
	end
	else begin
		if(state_idle) begin
			iaddr_x <= 0;
			iaddr_y <= 0;
		end
		else if(state_load) begin
			case(mode_buff)
				0 : begin 
						iaddr_x <= 4;
						if(busy_l) begin
							iaddr_y <= iaddr_y + 1;
						end
						else begin
							iaddr_y <= 0;
						end
					end
				1 : begin
						if(busy_h) begin
							iaddr_x <= iaddr_x + 1;
						end
						else begin
							iaddr_x <= 0;
						end
						iaddr_y <= 4;
					end
			endcase
		end
		else begin
			case({ready ,mode_buff ,sp_flag ,counter})
				5'b10000 : {iaddr_y ,iaddr_x} <= {iaddr_y ,iaddr_x} - 1;
				5'b10001 : {iaddr_y ,iaddr_x} <= {iaddr_y ,iaddr_x} - 1;
				5'b10100 : {iaddr_y ,iaddr_x} <= {iaddr_y ,iaddr_x} + 1;
				5'b10101 : {iaddr_y ,iaddr_x} <= {iaddr_y ,iaddr_x} + 1;
				5'b10110 : {iaddr_y ,iaddr_x} <= {iaddr_y ,iaddr_x} - 1;
				5'b11000 : {iaddr_x ,iaddr_y} <= {iaddr_x ,iaddr_y} - 1;
				5'b11001 : {iaddr_x ,iaddr_y} <= {iaddr_x ,iaddr_y} - 1;
				5'b11100 : {iaddr_x ,iaddr_y} <= {iaddr_x ,iaddr_y} + 1;
				5'b11101 : {iaddr_x ,iaddr_y} <= {iaddr_x ,iaddr_y} + 1;
				5'b11110 : {iaddr_x ,iaddr_y} <= {iaddr_x ,iaddr_y} - 1;
				default  : {iaddr_x ,iaddr_y} <= {iaddr_x ,iaddr_y};
			endcase
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		sp <= 0;
	end
	else begin
		if(state_idle || state_load) begin
			sp <= 0;
		end
		else if(sp == 14) begin
			sp <= sp;
		end
		else begin
			sp <= sp + 1;
		end
	end
end

always @(*) begin
	if(sp < 4) begin
		sp_flag = 0;
	end
	else begin
		sp_flag = 1;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		counter <= 0;
	end
	else begin
		if(state_idle || state_load) begin
			counter <= 0;
		end
		else if((mode_buff == 1'b0) && (iaddr_x == pic_size - 9) && (counter == 0)) begin
			counter <= counter + 1;
		end
		else if((mode_buff == 1'b1) && (iaddr_y == pic_size - 9) && (counter == 0)) begin
			counter <= counter + 1;
		end
		else if((mode_buff == 1'b0) && (iaddr_x == pic_size - 2) && (counter == 1)) begin
			counter <= counter + 1;
		end
		else if((mode_buff == 1'b1) && (iaddr_y == pic_size - 2) && (counter == 1)) begin
			counter <= counter + 1;
		end
		else if((mode_buff == 1'b0) && (iaddr_x == pic_size - 10) && (counter == 2)) begin
			counter <= counter + 1;
		end
		else if((mode_buff == 1'b1) && (iaddr_y == pic_size - 10) && (counter == 2)) begin
			counter <= counter + 1;
		end
		else begin
			counter <= counter;
		end
	end
end

always @(*) begin
	if (counter == 0) begin
		mode_change_buff_0 = 0;
	end
	else if(({state_end ,mode_buff} == 2'b10) && (iaddr_y == pic_size - 1)  && (iaddr_x == pic_size - 11)) begin
		mode_change_buff_0 = 1;
	end
	else if(({state_end ,mode_buff} == 2'b11) && (iaddr_y == pic_size - 11)  && (iaddr_x == pic_size - 1)) begin
		mode_change_buff_0 = 1;
	end
	else begin
		mode_change_buff_0 = 0;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		mode_change_buff_1 <= 0;
	end
	else begin
		mode_change_buff_1 <= mode_change_buff_0;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		mode_change <= 0;
	end
	else begin
		mode_change <= mode_change_buff_0 || mode_change_buff_1;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		o_valid <= 0;
	end
	else begin
		if(state_idle || state_load || state_end) begin
			o_valid <= 0;
		end
		else if(sp == 14) begin
			o_valid <= 1;
		end
		else begin
			o_valid <= 0;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		oaddr <= 0;
	end
	else begin
		if(sp == 1) begin
			if(mode_buff) begin
				oaddr <= iaddr_x;
			end
			else begin
				oaddr <= iaddr_y * pic_size;
			end
		end
		else if(o_valid) begin
			if(mode_buff) begin
				case(h_or_g)
					0 : oaddr <= oaddr + ((pic_size / 2) * pic_size);
					1 : oaddr <= oaddr - (((pic_size / 2) - 1) * pic_size);
					default : oaddr <= oaddr;
				endcase
			end
			else begin
				case(h_or_g)
					0 : oaddr <= oaddr + (pic_size / 2);
					1 : oaddr <= oaddr - ((pic_size / 2) - 1);
					default : oaddr <= oaddr;
				endcase
			end	
		end
		else begin
			oaddr <= oaddr;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		mode <= 0;
	end
	else begin
		if({mode_change ,counter} == {1'b1 ,2'b11}) begin
			mode <= ~mode;
		end
		else begin
			mode <= mode;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		busy_l <= 1'b0;
	end
	else begin
		if(mode_buff) begin
			busy_l <= 1'b0;
		end
		else if(iaddr_x == 4) begin
			busy_l <= 1'b1;
		end
		else begin
			busy_l <= busy_l;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		busy_h <= 1'b0;
	end
	else begin
		if(mode_buff == 0) begin
			busy_h <= 1'b0;
		end
		else if(iaddr_y == 4) begin
			busy_h <= 1'b1;
		end
		else begin
			busy_h <= busy_h;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		mode_buff <= 0;
	end
	else begin
		mode_buff <= mode;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		end_flag <= 1'b0;
	end
	else begin
		end_flag <= mode & mode_change & sp_flag;
	end
end

endmodule