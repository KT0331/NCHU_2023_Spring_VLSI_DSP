`timescale 1ns / 1ps

module S_AXIS
#(
    parameter S_AXIS_DATA_BYTES = 8
)(  
    //-- AXIS
     input                             s_axis_aclk
    ,input                             s_axis_aresetn
    ,input                             s_axis_tvalid
    ,input                             s_axis_tlast
    ,input [(8*S_AXIS_DATA_BYTES)-1:0] s_axis_tdata
    ,input [   S_AXIS_DATA_BYTES -1:0] s_axis_tstrb
    ,input [   S_AXIS_DATA_BYTES -1:0] s_axis_tkeep
    ,output                            s_axis_tready
    //-- User design
    ,input                              u_fifo_ren
    ,output                             u_fifo_rready
    ,output [(8*S_AXIS_DATA_BYTES)-1:0] u_fifo_rdata   
);

//--------------------------------------------------------------------------
//-- Interface of FIFO
//--------------------------------------------------------------------------
wire                             fifo_full;
wire                             fifo_empty;
wire                             fifo_wen;
wire                             fifo_ren;
wire [(8*S_AXIS_DATA_BYTES)-1:0] fifo_in;
wire [(8*S_AXIS_DATA_BYTES)-1:0] fifo_out;

//--------------------------------------------------------------------------
//-- AXIS
//--------------------------------------------------------------------------
assign s_axis_tready = ~fifo_full;

//--------------------------------------------------------------------------
//-- User design
//--------------------------------------------------------------------------
assign u_fifo_rdata = fifo_out;
assign u_fifo_rready = ~fifo_empty;

//--------------------------------------------------------------------------
//-- FIFO
//--------------------------------------------------------------------------
assign fifo_wen = s_axis_tready & s_axis_tvalid;
assign fifo_ren = u_fifo_ren;
assign fifo_in = s_axis_tdata;

AXIS_FIFO
#(
    .FIFO_WORDS (64),
    .FIFO_BITS  (7),
    .FIFO_WIDTH (8*S_AXIS_DATA_BYTES)
)S_AXIS_FIFO_inst(
    .fifo_clk          (s_axis_aclk),
    .fifo_rstn         (s_axis_aresetn),
    .fifo_wen          (fifo_wen),
    .fifo_ren          (fifo_ren),
    .fifo_in           (fifo_in),
    .fifo_out          (fifo_out),
    .fifo_half         (),
    .fifo_full         (fifo_full),
    .fifo_empty        (fifo_empty),
    .fifo_almost_empty ()
);
endmodule

