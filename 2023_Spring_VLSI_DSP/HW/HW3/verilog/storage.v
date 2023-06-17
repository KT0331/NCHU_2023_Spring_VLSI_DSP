module storage (
input      clk,
input      rst,
input      Din,
output reg Dout);

always @(posedge clk) begin
	if (!rst) begin
		Dout <= 1'b0;
	end
	else begin
		Dout <= Din;
	end
end

endmodule