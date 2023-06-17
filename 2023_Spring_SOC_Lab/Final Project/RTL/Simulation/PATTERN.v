`define CYCLE_TIME 10.0 //cycle
`define INPUT_DELAY_CYCLE 1
`define IMAGE	   "C:/Xilinx/project/SOC_final/data/test_pic.dat"
`define HUFFMAN    "C:/Xilinx/project/SOC_final/data/huffman_code_ans.dat"

module PATTERN#(
parameter pic_size = 64,
parameter pic_addr_width = 12)
(
    //Input Port
    clk,
	rst_n,
	start,
	axis_enable,
	out_stop,
	s_axis_data,

    //Output Port
    odata,
    o_valid,
	end_flag,
	now_state
    );

/* Input to design */
output reg              clk; 
output reg              rst_n;
output reg              start;
output reg 		        axis_enable;
output reg 		        out_stop;
output reg signed [7:0] s_axis_data;

/* Output to pattern */
input signed [14:0]     odata;
input                   o_valid;
input                   end_flag;
input signed [2:0]      now_state;

/* define clock cycle */
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;

/* parameter and integer*/
integer mem_in_count;
integer mem_out_count;
integer check_ans;
integer num_huff_error;

/* reg declaration */
reg        [7:0]  IMG            [0:(pic_size * pic_size) - 1];
reg        [14:0] IMG_ANS_GOLDEN [0:(pic_size * pic_size * 2) - 1];
reg signed [14:0] IMG_0          [0:(pic_size * pic_size * 2) - 1];

initial begin
	start = 0;
	num_huff_error = 0;
	mem_out_count = 0;
	mem_in_count  = 0;
	$readmemb(`IMAGE ,IMG);
	$readmemb(`HUFFMAN ,IMG_ANS_GOLDEN);
	reset_task;
	repeat(3) @(posedge clk); start = 1;
	repeat(1) @(posedge clk); start = 0;
	data_in_task;
	#CYCLE; axis_enable = 1'b0;
end

initial begin
	forever @(posedge clk) begin
		if(o_valid && (!out_stop)) begin
			check_huffman_task;
			output_write_task;
		end
	end
end

initial begin
	forever @(posedge clk) begin
		if(end_flag) begin
			end_check_task;
		end
	end
end

initial begin
	out_stop <= 1'b0;
	//#1000; out_stop <= 1'b1;
	//#10000; out_stop <= 1'b0;
	//#5406900; out_stop <= 1'b1;
	//#6806559; out_stop <= 1'b1;
	//#6944300; out_stop <= 1'b0;
end

/* task */
task reset_task; begin
	$display("-----------------------------------------------------\n");
 	$display("              START!!! Simulation Start              \n");
 	$display("-----------------------------------------------------\n");

	rst_n = 'b1;
	axis_enable = 1'b0;
	s_axis_data = 8'bxxxx_xxxx;

	force clk = 0;

	#(3*CYCLE); rst_n = 0;
	#CYCLE; release clk;
	#CYCLE; #1; rst_n = 1;

end endtask

task data_in_task; begin
	while(mem_in_count < pic_size*pic_size) begin
		axis_enable <= 1'b1;
		#10;
		s_axis_data <= IMG[mem_in_count];
		mem_in_count = mem_in_count + 1;
		@(posedge clk);
	end
end endtask

task check_huffman_task; begin
	if(odata !== IMG_ANS_GOLDEN[mem_out_count]) begin
		$display("************************************************************");   
    	$display("*                           FAIL!                          *");   
    	$display("*                  Recieve signal is %d                *" ,odata);
    	$display("*    Golden signal should be %d as huffman coding at %d  *" ,IMG_ANS_GOLDEN[mem_out_count] ,mem_out_count);
    	$display("************************************************************");
    	repeat(1) #CYCLE;
    	$finish;
	end
end endtask

task end_check_task; begin
	num_huff_error = 0;
    repeat(1) #CYCLE;
    for(check_ans = 0; check_ans < (pic_size * pic_size * 2); check_ans = check_ans + 1) begin : check_huff_ans_loop
    	if(IMG_0[check_ans] !== IMG_0[check_ans]) begin
    		num_huff_error = num_huff_error + 1;
    		$display("WRONG! R/G = %d/%d at memory 0 at y = %d ,x = %d ,oaddr = %d", IMG_0[check_ans], IMG_0[check_ans], check_ans/1024 ,check_ans%1024 ,check_ans);
    	end
    end
    
    if(num_huff_error === 0) begin
    	$display("\n");
    	$display("        ----------------------------               ");
    	$display("        --                        --       |\__||  ");
    	$display("        --  Congratulations !!    --      / O.O  | ");
    	$display("        --                        --    /_____   | ");
    	$display("        --  Simulation PASS!!     --   /^ ^ ^ \\  |");
    	$display("        --                        --  |^ ^ ^ ^ |w| ");
    	$display("        ----------------------------   \\m___m__|_|");
    	$display("\n");
    	repeat(3) @(negedge clk);
    	$finish;
    end
    else begin
    	$display("There are %d error", num_huff_error);
    	repeat(3) @(negedge clk);
    	$finish;
    end
end endtask

task output_write_task; begin
	IMG_0[mem_out_count] <= odata;
	mem_out_count <= mem_out_count + 1;
end endtask

endmodule