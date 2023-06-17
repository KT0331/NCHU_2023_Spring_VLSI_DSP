`timescale 1ns / 1ps

module M_AXIS
#(
    parameter M_AXIS_DATA_BYTES = 8
)(  
    //--------------------------------------------------------------------------
    //-- Interface of AXIS
    //--------------------------------------------------------------------------
    input                                  m_axis_aclk,
    input                                  m_axis_aresetn,
    input                                  m_axis_tready,
    output reg                             m_axis_tvalid,
    output reg                             m_axis_tlast,
    output     [(8*M_AXIS_DATA_BYTES)-1:0] m_axis_tdata,
    output reg [   M_AXIS_DATA_BYTES -1:0] m_axis_tstrb,
    output reg [   M_AXIS_DATA_BYTES -1:0] m_axis_tkeep,
    
    //--------------------------------------------------------------------------
    //-- Interface of User design
    //--------------------------------------------------------------------------
    output                            u_fifo_wready,
    input                             u_fifo_wen,
    input [(8*M_AXIS_DATA_BYTES)-1:0] u_fifo_wdata,
    input                             u_data_ending
);

//--------------------------------------------------------------------------
//-- Simple controller
//--------------------------------------------------------------------------
localparam [1:0] IDEL    = 2'd0;
localparam [1:0] STARTUP = 2'd1;
localparam [1:0] RD_FIFO = 2'd2;

reg [1:0] m_axis_cs, m_axis_ns;
reg m_axis_fifo_ren; //-- read from fifo

reg [6:0] counter;

//--------------------------------------------------------------------------
//-- Interface of FIFO
//--------------------------------------------------------------------------
wire                             fifo_half;
wire                             fifo_full;
wire                             fifo_empty;
wire                             fifo_almost_empty;
wire                             fifo_wen;
wire                             fifo_ren;
wire [(8*M_AXIS_DATA_BYTES)-1:0] fifo_in;
wire [(8*M_AXIS_DATA_BYTES)-1:0] fifo_out;


//--------------------------------------------------------------------------
//-- Simple controller
//--------------------------------------------------------------------------
always@(posedge m_axis_aclk)
begin
    if(~m_axis_aresetn)
        m_axis_cs <= 1'd0;
    else
        m_axis_cs <= m_axis_ns;
end

always@(*)
begin
    case(m_axis_cs)
        IDEL:
            if(~(|counter))   m_axis_ns = STARTUP;
            else              m_axis_ns = IDEL;
            
        STARTUP:              m_axis_ns = RD_FIFO;
        
        RD_FIFO:              
            if(fifo_empty &
               m_axis_tready) m_axis_ns = IDEL;
            else              m_axis_ns = RD_FIFO;
            
        default:
        begin
            m_axis_ns = IDEL;
        end
    endcase
end

always@(*)
begin
    m_axis_tvalid   = 1'd0; 
    m_axis_tkeep    = {(M_AXIS_DATA_BYTES){1'd0}};
    m_axis_tstrb    = {(M_AXIS_DATA_BYTES){1'd0}};
    m_axis_tlast    = 1'd0;
    m_axis_fifo_ren = 1'd0;
    
    case(m_axis_cs)
        STARTUP:
        begin
            m_axis_fifo_ren = 1'd1;
        end
        
        RD_FIFO:
        begin
            m_axis_tvalid   = 1'd1;
            m_axis_fifo_ren = m_axis_tready & m_axis_tvalid;
            m_axis_tlast    = fifo_empty & u_data_ending;
            m_axis_tkeep    = {(M_AXIS_DATA_BYTES){1'd1}};
            m_axis_tstrb    = {(M_AXIS_DATA_BYTES){1'd1}};
        end
        
        default:
        begin
            m_axis_tvalid   = 1'd0; 
            m_axis_tkeep    = {(M_AXIS_DATA_BYTES){1'd0}};
            m_axis_tstrb    = {(M_AXIS_DATA_BYTES){1'd0}};
            m_axis_tlast    = 1'd0;
            m_axis_fifo_ren = 1'd0;
        end
    endcase
end

assign m_axis_tdata = fifo_out;

//--------------------------------------------------------------------------
//-- User design
//--------------------------------------------------------------------------
assign u_fifo_wready = ~fifo_full;

always@(posedge m_axis_aclk)
begin
    if(~m_axis_aresetn)
        counter <= 7'd127;
    else
        if(~fifo_empty) begin
            counter <= counter - 1;
        end
        else begin
           counter <= 7'd127; 
        end
end

//--------------------------------------------------------------------------
//-- FIFO
//--------------------------------------------------------------------------
assign fifo_wen = u_fifo_wen;
assign fifo_ren = m_axis_fifo_ren;
assign fifo_in = u_fifo_wdata;

AXIS_FIFO
#(
    .FIFO_WORDS (64),
    .FIFO_BITS  (7),
    .FIFO_WIDTH (8*M_AXIS_DATA_BYTES)
)M_AXIS_FIFO_inst(
    .fifo_clk          (m_axis_aclk),
    .fifo_rstn         (m_axis_aresetn),
    .fifo_wen          (fifo_wen),
    .fifo_ren          (fifo_ren),
    .fifo_in           (fifo_in),
    .fifo_out          (fifo_out),
    .fifo_half         (fifo_half),
    .fifo_full         (fifo_full),
    .fifo_empty        (fifo_empty),
    .fifo_almost_empty (fifo_almost_empty)
);

endmodule

