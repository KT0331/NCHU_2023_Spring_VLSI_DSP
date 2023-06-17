module top #(
parameter pic_size = 256,
parameter pic_addr_width = 16,
parameter S_AXIS_DATA_BYTES = 1,
parameter M_AXIS_DATA_BYTES = 4,
parameter S_AXI_DATA_BYTES = 4,
parameter S_AXI_ADDR_WIDTH = 32
)
(
 input  wire                             s_axis_aclk
,input  wire                             s_axis_aresetn
,input  wire                             s_axis_tvalid
,input  wire                             s_axis_tlast
,input  wire [(8*S_AXIS_DATA_BYTES)-1:0] s_axis_tdata
,input  wire [   S_AXIS_DATA_BYTES -1:0] s_axis_tstrb
,input  wire [   S_AXIS_DATA_BYTES -1:0] s_axis_tkeep
,output wire                             s_axis_tready

,input  wire                             m_axis_aclk
,input  wire                             m_axis_aresetn
,input  wire                             m_axis_tready
,output wire                             m_axis_tvalid
,output wire                             m_axis_tlast
,output wire [(8*M_AXIS_DATA_BYTES)-1:0] m_axis_tdata
,output wire [   M_AXIS_DATA_BYTES -1:0] m_axis_tstrb
,output wire [   M_AXIS_DATA_BYTES -1:0] m_axis_tkeep

,input  wire                             s_axi_lite_aclk
,input  wire                             s_axi_lite_aresetn
//-- Write address
,input  wire                             s_axi_lite_awvalid
,input  wire [S_AXI_ADDR_WIDTH-1:0]      s_axi_lite_awaddr
,input  wire [2:0]                       s_axi_lite_awprot
,output wire                             s_axi_lite_awready
//-- Write data
,input  wire                             s_axi_lite_wvalid
,input  wire [(8*S_AXI_DATA_BYTES)-1:0]  s_axi_lite_wdata
,input  wire [(  S_AXI_DATA_BYTES)-1:0]  s_axi_lite_wstrb
,output wire                             s_axi_lite_wready
//-- Write response
,input  wire                             s_axi_lite_bready
,output wire                             s_axi_lite_bvalid
,output wire  [1:0]                      s_axi_lite_bresp
//-- Read address
,input  wire                             s_axi_lite_arvalid
,input  wire [S_AXI_ADDR_WIDTH-1:0]      s_axi_lite_araddr
,input  wire [2:0]                       s_axi_lite_arprot
,output wire                             s_axi_lite_arready
//-- Read data
,input  wire                             s_axi_lite_rready
,output wire                             s_axi_lite_rvalid
,output wire  [(8*S_AXI_DATA_BYTES)-1:0] s_axi_lite_rdata
,output wire  [1:0]                      s_axi_lite_rresp
);

wire       end_flag;
wire [2:0] now_state;
wire u_data_ending_rx;

////////////////////////////////Axis interface///////////////////////////////
//////////////Slave AXIS//////////////
wire                             u_fifo_ren;
wire                             u_fifo_rready;
wire [(8*S_AXIS_DATA_BYTES)-1:0] u_fifo_rdata;

//////////////Master AXIS//////////////
wire                             u_fifo_wready;
wire                             u_fifo_wen;
wire [(8*M_AXIS_DATA_BYTES)-1:0] u_fifo_wdata;

//////////////AXIS Lite//////////////
wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_0;
wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_status;

/////////////////////////////////////////////////////////////////////////////

assign u_cnn_acc_status = {{(32-4){1'b0}} ,end_flag ,now_state};
assign u_fifo_wdata[(8*M_AXIS_DATA_BYTES)-1:15] = 17'd0;
assign u_data_ending_rx = end_flag;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     sub_module instantiation                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
image_compression #(
.pic_size(pic_size),
.pic_addr_width(pic_addr_width))
u_image_compression(
	.odata(u_fifo_wdata[14:0]),
    .in_valid(u_fifo_ren),
	.o_valid(u_fifo_wen),
	.end_flag(end_flag),
	.now_state(now_state),
	.clk(s_axis_aclk),
	.rst(s_axis_aresetn),
	.start(u_cnn_acc_setup_0[0]),
	.axis_enable(u_fifo_rready),
	.out_stop(~u_fifo_wready),
	.s_axis_data(u_fifo_rdata));

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    AXI_interface instantiation                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
S_AXIS #(
	.S_AXIS_DATA_BYTES(S_AXIS_DATA_BYTES))
u_S_AXIS(  
    //-- AXIS
    .s_axis_aclk(s_axis_aclk),
    .s_axis_aresetn(s_axis_aresetn),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tstrb(s_axis_tstrb),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tready(s_axis_tready),
    //-- User design
    .u_fifo_ren(u_fifo_ren),
    .u_fifo_rready(u_fifo_rready),
    .u_fifo_rdata(u_fifo_rdata) 
);

M_AXIS #(
	.M_AXIS_DATA_BYTES(M_AXIS_DATA_BYTES))
u_M_AXIS(  
    //--------------------------------------------------------------------------
    //-- Interface of AXIS
    //--------------------------------------------------------------------------
    .m_axis_aclk(m_axis_aclk),
    .m_axis_aresetn(m_axis_aresetn),
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tstrb(m_axis_tstrb),
    .m_axis_tkeep(m_axis_tkeep),
    
    //--------------------------------------------------------------------------
    //-- Interface of User design
    //--------------------------------------------------------------------------
    .u_fifo_wready(u_fifo_wready),
    .u_fifo_wen(u_fifo_wen),
    .u_fifo_wdata(u_fifo_wdata),
    .u_data_ending(u_data_ending_rx)
);

S_AXI_Lite u_S_AXI_Lite (   
    //-- Global signal
    .s_axi_lite_aclk(s_axi_lite_aclk),
    .s_axi_lite_aresetn(s_axi_lite_aresetn),
    //-- Write address
    .s_axi_lite_awvalid(s_axi_lite_awvalid),
    .s_axi_lite_awaddr(s_axi_lite_awaddr),
    .s_axi_lite_awprot(s_axi_lite_awprot),
    .s_axi_lite_awready(s_axi_lite_awready),
    //-- Write data
    .s_axi_lite_wvalid(s_axi_lite_wvalid),
    .s_axi_lite_wdata(s_axi_lite_wdata),
    .s_axi_lite_wstrb(s_axi_lite_wstrb),
    .s_axi_lite_wready(s_axi_lite_wready),
    //-- Write response
    .s_axi_lite_bready(s_axi_lite_bready),
    .s_axi_lite_bvalid(s_axi_lite_bvalid),
    .s_axi_lite_bresp(s_axi_lite_bresp),
    //-- Read address
    .s_axi_lite_arvalid(s_axi_lite_arvalid),
    .s_axi_lite_araddr(s_axi_lite_araddr),
    .s_axi_lite_arprot(s_axi_lite_arprot),
    .s_axi_lite_arready(s_axi_lite_arready),
    //-- Read data
    .s_axi_lite_rready(s_axi_lite_rready),
    .s_axi_lite_rvalid(s_axi_lite_rvalid),
    .s_axi_lite_rdata(s_axi_lite_rdata),
    .s_axi_lite_rresp(s_axi_lite_rresp),
    //-- user design
    .u_cnn_acc_setup_0(u_cnn_acc_setup_0), //start circuit
    .u_cnn_acc_status(u_cnn_acc_status)
);


endmodule