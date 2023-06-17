module image_compression #(
parameter pic_size = 64,
parameter pic_addr_width = 12)
(
output reg [14:0]                 odata,
//output reg [9:0]                  dwt_pixel,
//output reg [pic_addr_width - 1:0] oaddr,
//output reg [pic_addr_width - 1:0] iaddr,
//output reg [pic_addr_width - 1:0] csel, //memory select
output reg                        in_valid,
output reg                        o_valid,
//output reg                        m_valid, //memory valid
output reg                        end_flag,
output wire [2:0]                 now_state,
input  clk,
input  rst,
//input  ready,
input  start,
input  axis_enable,
input  out_stop,
//input  signed [9:0] idata,
input  signed [7:0] s_axis_data);

/////////////////////////////sub_module interface/////////////////////////////
wire signed [9:0] idata_w;
wire [14:0] odata_w;
wire [9:0]  dwt_pixel_w;
wire dwt_mode_w;
wire [pic_addr_width - 1:0] iaddr_c_w ,iaddr_d_w;
wire end_flag_c ,end_flag_d;
wire [pic_addr_width - 1:0] oaddr_w;
wire o_valid_c_w ,o_valid_d_w;
//reg m_valid,
reg [9:0]                  dwt_pixel;
reg [pic_addr_width - 1:0] oaddr;
reg [pic_addr_width - 1:0] iaddr;
///////////////////////////////////////////////////////////////////////////

//////////////////////////////memory interface/////////////////////////////
wire wea_0;
wire [pic_addr_width - 1:0] addra_0;
wire signed [9:0] dina_0;
wire [pic_addr_width - 1:0] addrb_0;
wire signed [9:0] doutb_0;
wire wea_1;
wire [pic_addr_width - 1:0] addra_1;
wire signed [9:0] dina_1;
wire [pic_addr_width - 1:0] addrb_1;
wire signed [9:0] doutb_1;

reg wea_0_r;
reg wea_1_r;
reg signed [9:0] dina_0_r;
reg signed [9:0] dina_1_r;
reg [pic_addr_width - 1:0] addra_0_r;
reg [pic_addr_width - 1:0] addra_1_r;
reg [pic_addr_width - 1:0] addrb_0_r;
reg [pic_addr_width - 1:0] addrb_1_r;
///////////////////////////////////////////////////////////////////////////

reg [2:0] c_state;
reg [2:0] n_state;
reg state_idle;
reg state_load;
reg state_dwt_mode;
reg state_compress_mode;
reg state_end;

reg ready_c ,ready_d;
reg ready_c_buff[0:2];
//reg csel; //memory select

reg [pic_addr_width - 1:0] mem_sp;
reg signed [9:0] idata;
reg axis_enable_buff;

wire mem_full;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            FSM parameters                                                     //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE           = 0;
localparam LOAD           = 1;
localparam DWT_MODE       = 2;
localparam COMPRESS_MODE  = 3;
localparam END            = 4;
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
			if(start) begin
				n_state = LOAD;
			end
			else begin
				n_state = IDLE;
			end
		end
		LOAD: begin
			if(mem_full) begin
				n_state = DWT_MODE;
			end
			else begin
				n_state = LOAD;
			end
		end
		DWT_MODE: begin
			if(end_flag_d) begin
				n_state = COMPRESS_MODE;
			end
			else begin
				n_state = DWT_MODE;
			end
		end
		COMPRESS_MODE: begin
			if(end_flag_c) begin
				n_state = END;
			end
			else begin
				n_state = COMPRESS_MODE;
			end
		end
		END: begin
			n_state = END;
		end
		default: begin
			n_state = IDLE;
		end
	endcase
end

always @(*) begin
	case(c_state)
		IDLE: begin
			state_idle          = 1;
			state_load          = 0;
			state_dwt_mode      = 0;
			state_compress_mode = 0;
			state_end           = 0;
		end
		LOAD: begin
			state_idle          = 0;
			state_load          = 1;
			state_dwt_mode      = 0;
			state_compress_mode = 0;
			state_end           = 0;
		end
		DWT_MODE: begin
			state_idle          = 0;
			state_load          = 0;
			state_dwt_mode      = 1;
			state_compress_mode = 0;
			state_end           = 0;
		end
		COMPRESS_MODE: begin
			state_idle          = 0;
			state_load          = 0;
			state_dwt_mode      = 0;
			state_compress_mode = 1;
			state_end           = 0;
		end
		END: begin
			state_idle          = 0;
			state_load          = 0;
			state_dwt_mode      = 0;
			state_compress_mode = 0;
			state_end           = 1;
		end
		default: begin
			state_idle          = 0;
			state_load          = 0;
			state_dwt_mode      = 0;
			state_compress_mode = 0;
			state_end           = 0;
		end
	endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                            main circuit                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		ready_c <= 0;
		ready_d <= 0;
	end
	else begin
		if(state_idle) begin
			ready_c <= 0;
			ready_d <= 0;
		end
		else if(state_dwt_mode) begin
			ready_c <= 0;
			ready_d <= 1;
		end
		else if(state_compress_mode) begin
			ready_c <= 1;
			ready_d <= 0;
		end
		else begin
			ready_c <= 0;
			ready_d <= 0;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		end_flag <= 0;
	end
	else begin
		if(state_end) begin
			end_flag <= 1;
		end
		else begin
			end_flag <= 0;
		end
	end
end

assign wea_0 = wea_0_r;
assign wea_1 = wea_1_r;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		wea_0_r <= 0;
		wea_1_r <= 0;
	end
	else begin
		if(state_idle) begin
			wea_0_r <= 0;
			wea_1_r <= 0;
		end
		else if(state_load) begin
			wea_0_r <= axis_enable_buff;
			wea_1_r <= 0;
		end
		else if(state_dwt_mode) begin
			wea_0_r <= (dwt_mode_w && o_valid_d_w);
			wea_1_r <= (!dwt_mode_w && o_valid_d_w);
		end
		else begin
			wea_0_r <= 0;
			wea_1_r <= 0;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		axis_enable_buff <= 0;
	end
	else begin
		axis_enable_buff <= axis_enable;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		o_valid <= 0;
	end
	else begin
		if(state_idle) begin
			o_valid <= 0;
		end
		else if(state_dwt_mode) begin
			o_valid <= 0;
		end
		else if(state_compress_mode) begin
			if(out_stop) begin
				o_valid <= o_valid;
			end
			else begin
				o_valid <= o_valid_c_w;
			end
		end
		else begin
			o_valid <= 0;
		end
	end
end

/*always @(posedge clk or negedge rst) begin
	if (!rst) begin
		iaddr <= 0;
		oaddr <= 0;
	end
	else begin
		if(state_idle) begin
			iaddr <= 0;
			oaddr <= 0;
		end
		else if(state_dwt_mode) begin
			iaddr <= iaddr_d_w;
			oaddr <= oaddr_w;
		end
		else if(state_compress_mode) begin
			iaddr <= iaddr_c_w;
			oaddr <= 0;
		end
		else begin
			iaddr <= 0;
			oaddr <= 0;
		end
	end
end*/

assign addra_0 = addra_0_r;
assign addra_1 = addra_1_r;
assign addrb_0 = addrb_0_r;
assign addrb_1 = addrb_1_r;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		addra_0_r <= 0; //write addr
		addra_1_r <= 0;
		addrb_0_r <= 0; //read addr
		addrb_1_r <= 0;
	end
	else begin
		if(state_idle) begin
			addra_0_r <= 0;
			addra_1_r <= 0;
			addrb_0_r <= 0;
			addrb_1_r <= 0;
		end
		else if(state_load) begin
			addra_0_r <= mem_sp;
			addra_1_r <= 0;
			addrb_0_r <= 0;
			addrb_1_r <= 0;
		end
		else if(state_dwt_mode) begin
			addra_0_r <= oaddr_w;
			addra_1_r <= oaddr_w;
			addrb_0_r <= iaddr_d_w;
			addrb_1_r <= iaddr_d_w;
		end
		else if(state_compress_mode) begin
			addra_0_r <= 0;
			addra_1_r <= 0;
			addrb_0_r <= iaddr_c_w;
			addrb_1_r <= iaddr_c_w;
		end
		else begin
			addra_0_r <= 0;
			addra_1_r <= 0;
			addrb_0_r <= 0;
			addrb_1_r <= 0;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		odata <= 0;
	end
	else begin
		if(state_idle) begin
			odata <= 0;
		end
		else if(state_compress_mode) begin
			if(out_stop) begin
				odata <= odata;
			end
			else begin
				odata <= odata_w;
			end
		end
		else begin
			odata <= 0;
		end
	end
end
/*
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		dwt_pixel <= 0;
	end
	else begin
		if(state_idle) begin
			dwt_pixel <= 0;
		end
		else if(state_dwt_mode) begin
			dwt_pixel <= dwt_pixel_w;
		end
		else begin
			dwt_pixel <= 0;
		end
	end
end
*/
assign dina_0 = dina_0_r;
assign dina_1 = dina_1_r;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		dina_0_r <= 0;
		dina_1_r <= 0;
	end
	else begin
		if(state_load) begin
			dina_0_r <= {2'b00 ,s_axis_data};
			dina_1_r <= 0;
		end
		else if(state_dwt_mode) begin
			dina_0_r <= dwt_pixel_w;
			dina_1_r <= dwt_pixel_w;
		end
		else begin
			dina_0_r <= 0;
			dina_1_r <= 0;
		end
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		in_valid <= 0;
	end
	else begin
		if(state_load) begin
			in_valid <= 1;
		end
		else begin
			in_valid <= 0;
		end
	end
end

assign idata_w = idata;

always @(*) begin
	if(state_idle) begin
		idata <= 0;
	end
	else if(state_dwt_mode) begin
		if(dwt_mode_w) begin
			idata <= doutb_1;
		end
		else begin
			idata <= doutb_0;
		end
	end
	else if(state_compress_mode) begin
		idata <= doutb_0;
	end
	else begin
		idata <= 0;
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		ready_c_buff[0] <= 0;
		ready_c_buff[1] <= 0;
		ready_c_buff[2] <= 0;
	end
	else begin
		ready_c_buff[0] <= ready_c;
		ready_c_buff[1] <= ready_c_buff[0];
		ready_c_buff[2] <= ready_c_buff[1];
	end
end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		mem_sp <= 0;
	end
	else begin
		if(state_idle) begin
			mem_sp <= 0;
		end
		else if(state_load && axis_enable_buff) begin
			mem_sp <= mem_sp + 1;
		end
		else begin
			mem_sp <= mem_sp;
		end
	end
end

assign mem_full = (&mem_sp) && axis_enable_buff;
assign now_state = c_state;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     sub_module instantiation                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
DWT_control #(
.pic_size(pic_size),
.pic_addr_width(pic_addr_width)) 
u_DWT_control (
	.dwt_pixel(dwt_pixel_w),
	.oaddr(oaddr_w),
	.o_valid(o_valid_d_w),
	.iaddr(iaddr_d_w),
	.mode(dwt_mode_w),
	.end_flag(end_flag_d),
	.clk(clk),
	.rst(rst),
	.ready(ready_d),
	.idata(idata_w));

compression #(
.pic_size(pic_size),
.pic_addr_width(pic_addr_width))
u_compression (
	.odata(odata_w),
	//.oaddr(),
	.iaddr(iaddr_c_w),
	.o_valid(o_valid_c_w),
	.end_flag(end_flag_c),
	.clk(clk),
	.rst(rst),
	.ready(ready_c_buff[2]),
	.out_stop(out_stop),
	.idata(idata_w));

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                             Memory instantiation                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
blk_mem_gen_0 BRAM0 (
  .clka(clk),    // input wire clka
  .wea(wea_0),      // input wire [0 : 0] wea write enable
  .addra(addra_0),  // input wire [17 : 0] addra write addr
  .dina(dina_0),    // input wire [9 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(addrb_0),  // input wire [17 : 0] addrb read addr
  .doutb(doutb_0)  // output wire [9 : 0] doutb
);

blk_mem_gen_0 BRAM1 (
  .clka(clk),    // input wire clka
  .wea(wea_1),      // input wire [0 : 0] wea write enable
  .addra(addra_1),  // input wire [17 : 0] addra
  .dina(dina_1),    // input wire [9 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(addrb_1),  // input wire [17 : 0] addrb
  .doutb(doutb_1)  // output wire [9 : 0] doutb
);




endmodule