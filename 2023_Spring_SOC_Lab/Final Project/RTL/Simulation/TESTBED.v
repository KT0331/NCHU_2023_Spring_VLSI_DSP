`timescale 1ns/1ps

`define pic_size 256
`define pic_addr_width 16

module TESTBED;

wire clk, rst, o_valid ,end_flag ,out_stop ,start ,axis_enable;
wire [14:0] odata;
wire [2:0] now_state;
wire signed [7:0] s_axis_data;

image_compression #(
    .pic_size(`pic_size),
    .pic_addr_width(`pic_addr_width))
u_image_compression (
    .odata(odata),
    .o_valid(o_valid),
    .end_flag(end_flag),
    .now_state(now_state),
    .clk(clk),
    .rst(rst),
    .start(start),
    .axis_enable(axis_enable),
    .out_stop(out_stop),
    .s_axis_data(s_axis_data));
    
PATTERN #(
    .pic_size(`pic_size),
    .pic_addr_width(`pic_addr_width))
u_PATTERN (
    //Input Port
    .clk(clk),
    .rst_n(rst),
    .start(start),
    .axis_enable(axis_enable),
    .out_stop(out_stop),
    .s_axis_data(s_axis_data),

    //Output Port
    .odata(odata),
    .o_valid(o_valid),
    .end_flag(end_flag),
    .now_state(now_state));
  
 
endmodule