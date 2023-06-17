`timescale 1ns / 1ps

module AXIS_FIFO
#(
     parameter FIFO_WORDS = 64
    ,parameter FIFO_BITS  = 7
    ,parameter FIFO_WIDTH = 64
)(
     fifo_clk
    ,fifo_rstn
    ,fifo_wen
    ,fifo_ren
    ,fifo_in
    ,fifo_out
    ,fifo_half
    ,fifo_full
    ,fifo_empty
    ,fifo_almost_empty
);

//-- Synchronous FIFO implementation
input fifo_clk;
input fifo_rstn;
input fifo_wen;
input fifo_ren;

//-- FIFO states
output fifo_half;
output fifo_full;
output fifo_empty;
output fifo_almost_empty;

//-- FIFO data ports
input      [FIFO_WIDTH-1:0] fifo_in;
output reg [FIFO_WIDTH-1:0] fifo_out;

//-- FIFO memory
reg [FIFO_WIDTH-1:0] fifo_mem [FIFO_WORDS-1:0];
reg [ FIFO_BITS-1:0] fifo_read_ptr;
reg [ FIFO_BITS-1:0] fifo_write_ptr;

assign fifo_half = (fifo_read_ptr[FIFO_BITS-2] != fifo_write_ptr[FIFO_BITS-2]) && (fifo_read_ptr[FIFO_BITS-3:0] == fifo_write_ptr[FIFO_BITS-3:0]);
assign fifo_full = (fifo_read_ptr[FIFO_BITS-1] != fifo_write_ptr[FIFO_BITS-1]) && (fifo_read_ptr[FIFO_BITS-2:0] == fifo_write_ptr[FIFO_BITS-2:0]);
assign fifo_empty = fifo_read_ptr == fifo_write_ptr;
assign fifo_almost_empty = fifo_read_ptr == (fifo_write_ptr - 1'd1);

//-- FIFO memory implement
always@(posedge fifo_clk)
begin:FIFO_Memory_Implement

    integer fifo_mem_i;
    
    if(~fifo_rstn)
        for(fifo_mem_i=0; fifo_mem_i<FIFO_WORDS; fifo_mem_i=fifo_mem_i+1)
            fifo_mem[fifo_mem_i] <= {(FIFO_WIDTH){1'd0}};
    
    else if(fifo_wen & ~fifo_full)
        fifo_mem[fifo_write_ptr[FIFO_BITS-2:0]] <= fifo_in;
end

//-- FIFO write pointer
always@(posedge fifo_clk)
begin:Write_Pointer

    if(~fifo_rstn)
        fifo_write_ptr <= {(FIFO_BITS){1'd0}};
    
    else if(fifo_wen & ~fifo_full)
        fifo_write_ptr <= fifo_write_ptr + 1'd1;
end

//-- FIFO read pointer
always@(posedge fifo_clk)
begin:Read_Pointer

    if(~fifo_rstn)
        fifo_read_ptr <= {(FIFO_BITS){1'd0}};
    
    else if(fifo_ren & ~fifo_empty)
        fifo_read_ptr <= fifo_read_ptr + 1'd1;
end

//-- FIFO read out register
always@(posedge fifo_clk)
begin:Output_register

    if(~fifo_rstn)
        fifo_out <= {(FIFO_WIDTH){1'd0}};
    
    else if(fifo_ren & ~fifo_empty)
        fifo_out <= fifo_mem[fifo_read_ptr[FIFO_BITS-2:0]];
end

endmodule