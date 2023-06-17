`timescale 1ns / 1ps

module S_AXI_Lite
#(
     parameter                              S_AXI_DATA_BYTES = 4
    ,parameter                              S_AXI_ADDR_WIDTH = 32
)(   
    //-- Global signal
     input  wire                            s_axi_lite_aclk
    ,input  wire                            s_axi_lite_aresetn
    //-- Write address
    ,input  wire                            s_axi_lite_awvalid
    ,input  wire [S_AXI_ADDR_WIDTH-1:0]     s_axi_lite_awaddr
    ,input  wire [2:0]                      s_axi_lite_awprot
    ,output reg                             s_axi_lite_awready
    //-- Write data
    ,input  wire                            s_axi_lite_wvalid
    ,input  wire [(8*S_AXI_DATA_BYTES)-1:0] s_axi_lite_wdata
    ,input  wire [(  S_AXI_DATA_BYTES)-1:0] s_axi_lite_wstrb
    ,output reg                             s_axi_lite_wready
    //-- Write response
    ,input  wire                            s_axi_lite_bready
    ,output reg                             s_axi_lite_bvalid
    ,output reg  [1:0]                      s_axi_lite_bresp
    //-- Read address
    ,input  wire                            s_axi_lite_arvalid
    ,input  wire [S_AXI_ADDR_WIDTH-1:0]     s_axi_lite_araddr
    ,input  wire [2:0]                      s_axi_lite_arprot
    ,output reg                             s_axi_lite_arready
    //-- Read data
    ,input  wire                            s_axi_lite_rready
    ,output reg                             s_axi_lite_rvalid
    ,output reg  [(8*S_AXI_DATA_BYTES)-1:0] s_axi_lite_rdata
    ,output reg  [1:0]                      s_axi_lite_rresp
    //-- user design
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_0
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_1
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_2
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_3
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_4
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_5
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_6
    ,output wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_setup_7
    ,input  wire [(8*S_AXI_DATA_BYTES)-1:0] u_cnn_acc_status
);

//-- Byte Aligned
localparam integer BYTE_ALIGN = $clog2(S_AXI_DATA_BYTES);

//-- AXI response
localparam  [1:0]                  OKAY   = 2'd0;
localparam  [1:0]                  EXOKAY = 2'd1;
localparam  [1:0]                  SAVERR = 2'd2;
localparam  [1:0]                  DECERR = 2'd3;
reg         [1:0]                  bresp_state;

//-- Address offset
reg [7:0]                          waddr_offset;
reg [7:0]                          raddr_offset;

//-- Register Space
reg                                rs_reg00_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg00;
reg                                rs_reg04_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg04;
reg                                rs_reg08_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg08;
reg                                rs_reg0c_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg0c;
reg                                rs_reg10_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg10;
reg                                rs_reg14_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg14;
reg                                rs_reg18_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg18;
reg                                rs_reg1c_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg1c;
reg                                rs_reg20_wen;
reg [(8*S_AXI_DATA_BYTES)-1:0]     rs_reg20;


//-- user design signal read from regif.
assign u_cnn_acc_setup_0 = rs_reg00;
assign u_cnn_acc_setup_1 = rs_reg04;
assign u_cnn_acc_setup_2 = rs_reg08;
assign u_cnn_acc_setup_3 = rs_reg0c;
assign u_cnn_acc_setup_4 = rs_reg10;
assign u_cnn_acc_setup_5 = rs_reg14;
assign u_cnn_acc_setup_6 = rs_reg18;
assign u_cnn_acc_setup_7 = rs_reg1c;

//-- awready / wready responses after awvalid / wvalid.
always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn)
    begin
        s_axi_lite_awready <= 1'd0;
        s_axi_lite_wready  <= 1'd0;
    end
    
    else
    begin
        s_axi_lite_awready <= s_axi_lite_awvalid;
        s_axi_lite_wready  <= s_axi_lite_wvalid;
    end
end

// Write Address Decoder
always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn)
        waddr_offset <= 8'd0;
        
    else if(s_axi_lite_awvalid)
        waddr_offset <= (s_axi_lite_awaddr[7:0] >> BYTE_ALIGN) << BYTE_ALIGN;
end

// Read Address Decoder
always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn)
        raddr_offset <= 8'd0;

    else if(s_axi_lite_arvalid)
        raddr_offset <= (s_axi_lite_araddr[7:0] >> BYTE_ALIGN) << BYTE_ALIGN;
end

//-- AXI registers write
always@(*)
begin
    rs_reg00_wen = 1'd0;
    rs_reg04_wen = 1'd0;
    rs_reg08_wen = 1'd0;
    rs_reg0c_wen = 1'd0;
    rs_reg10_wen = 1'd0;
    rs_reg14_wen = 1'd0;
    rs_reg18_wen = 1'd0;
    rs_reg1c_wen = 1'd0;
    rs_reg20_wen = 1'd0;
    bresp_state  = DECERR;
    
    if(s_axi_lite_wvalid & s_axi_lite_wready)
        case(waddr_offset)
            8'h00: begin rs_reg00_wen = 1'd1; bresp_state = OKAY; end
            8'h04: begin rs_reg04_wen = 1'd1; bresp_state = OKAY; end
            8'h08: begin rs_reg08_wen = 1'd1; bresp_state = OKAY; end
            8'h0c: begin rs_reg0c_wen = 1'd1; bresp_state = OKAY; end
            8'h10: begin rs_reg10_wen = 1'd1; bresp_state = OKAY; end
            8'h14: begin rs_reg14_wen = 1'd1; bresp_state = OKAY; end
            8'h18: begin rs_reg18_wen = 1'd1; bresp_state = OKAY; end
            8'h1c: begin rs_reg1c_wen = 1'd1; bresp_state = OKAY; end
            //-- 20 is a state register(READ-ONLY)  
            8'h20: begin rs_reg20_wen = 1'd0; bresp_state = DECERR; end
            
            default:
            begin
                rs_reg00_wen = 1'd0;
                rs_reg04_wen = 1'd0;
                rs_reg08_wen = 1'd0;
                rs_reg0c_wen = 1'd0;
                rs_reg10_wen = 1'd0;
                rs_reg14_wen = 1'd0;
                rs_reg18_wen = 1'd0;
                rs_reg1c_wen = 1'd0;
                rs_reg20_wen = 1'd0;
                bresp_state  = DECERR;
            end
        endcase
end

always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn) 
    begin
        rs_reg00 <= {(8*S_AXI_DATA_BYTES){1'd0}};
        rs_reg04 <= {(8*S_AXI_DATA_BYTES){1'd0}};
        rs_reg08 <= {(8*S_AXI_DATA_BYTES){1'd0}};
        rs_reg0c <= {(8*S_AXI_DATA_BYTES){1'd0}};
        rs_reg10 <= {(8*S_AXI_DATA_BYTES){1'd0}};
        rs_reg14 <= {(8*S_AXI_DATA_BYTES){1'd0}};
        rs_reg18 <= {(8*S_AXI_DATA_BYTES){1'd0}};
        rs_reg1c <= {(8*S_AXI_DATA_BYTES){1'd0}}; 
        rs_reg20 <= {(8*S_AXI_DATA_BYTES){1'd0}}; 
    end
    
    else 
    begin
        if(rs_reg00_wen) rs_reg00 <= s_axi_lite_wdata; 
        if(rs_reg04_wen) rs_reg04 <= s_axi_lite_wdata; 
        if(rs_reg08_wen) rs_reg08 <= s_axi_lite_wdata; 
        if(rs_reg0c_wen) rs_reg0c <= s_axi_lite_wdata; 
        if(rs_reg10_wen) rs_reg10 <= s_axi_lite_wdata; 
        if(rs_reg14_wen) rs_reg14 <= s_axi_lite_wdata; 
        if(rs_reg18_wen) rs_reg18 <= s_axi_lite_wdata; 
        if(rs_reg1c_wen) rs_reg1c <= s_axi_lite_wdata; 
        //-- 20 is a status register(READ-ONLY)
        //-- Reset when CPU reading transaction handshaking 
        rs_reg20 <= u_cnn_acc_status[7:0];
    end
end

//-- AXI write response
always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn)
        s_axi_lite_bvalid <= 1'd0;
        
    else if(s_axi_lite_wvalid & s_axi_lite_wready)
        s_axi_lite_bvalid <= 1'd1;
        
    else if(s_axi_lite_bready)
        s_axi_lite_bvalid <= 1'd0;
end

always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn)
        s_axi_lite_bresp <= DECERR;
    else if(s_axi_lite_wvalid & s_axi_lite_wready)
        s_axi_lite_bresp <= bresp_state;
    else if(s_axi_lite_bvalid & s_axi_lite_bready)
        s_axi_lite_bresp <= DECERR;
end

//-- arready set high after s_axi_lite_arvalid
always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn)
        s_axi_lite_arready <= 1'd0;
    else
        s_axi_lite_arready <= s_axi_lite_arvalid;
end

//-- rvalid is asserted only after read address handshaking
always@(posedge s_axi_lite_aclk)
begin
    if(~s_axi_lite_aresetn)
        s_axi_lite_rvalid <= 1'd0;
    else if(s_axi_lite_arvalid & s_axi_lite_arready)
        s_axi_lite_rvalid <= 1'd1;
    else if(s_axi_lite_rready)
        s_axi_lite_rvalid <= 1'd0;
end

//-- AXI registers read
always@(*)
begin
    if(s_axi_lite_rvalid & s_axi_lite_rready)
        case(raddr_offset)
            8'h00: begin s_axi_lite_rdata = rs_reg00; s_axi_lite_rresp = OKAY; end
            8'h04: begin s_axi_lite_rdata = rs_reg04; s_axi_lite_rresp = OKAY; end
            8'h08: begin s_axi_lite_rdata = rs_reg08; s_axi_lite_rresp = OKAY; end
            8'h0c: begin s_axi_lite_rdata = rs_reg0c; s_axi_lite_rresp = OKAY; end
            8'h10: begin s_axi_lite_rdata = rs_reg10; s_axi_lite_rresp = OKAY; end
            8'h14: begin s_axi_lite_rdata = rs_reg14; s_axi_lite_rresp = OKAY; end
            8'h18: begin s_axi_lite_rdata = rs_reg18; s_axi_lite_rresp = OKAY; end
            8'h1c: begin s_axi_lite_rdata = rs_reg1c; s_axi_lite_rresp = OKAY; end
            8'h20: begin s_axi_lite_rdata = rs_reg20; s_axi_lite_rresp = OKAY; end
            
            default: 
            begin
                s_axi_lite_rdata = {(8*S_AXI_DATA_BYTES){1'd0}};
                s_axi_lite_rresp = DECERR;
            end
        endcase
        
    else 
    begin
        s_axi_lite_rdata = {(8*S_AXI_DATA_BYTES){1'd0}};
        s_axi_lite_rresp = DECERR;
    end
end

endmodule
