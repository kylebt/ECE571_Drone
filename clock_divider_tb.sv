module clock_divider_tb();

bit clk = 1'b0;
bit resetn = 1'b1;
logic [7:0] derivedClocks;

localparam HALF_CLOCK = 5;
localparam CLOCK_PERIOD = 2 * HALF_CLOCK;

initial begin
forever #HALF_CLOCK clk = ~clk;
end

generate
	genvar i;
	for(i = 0; i < $bits(derivedClocks); i++) begin
		clock_divider #(.CLOCK_DIVIDER((i > 0 ? 2*i : 1))) clk_div(.clk, .resetn, .derivedClock(derivedClocks[i]));
		property clk_div_prop_trans_high;
			@(edge clk)
				disable iff(~resetn) $rose(derivedClocks[i]) |-> ##(i + 1) (derivedClocks[i] === 1'b0);
		endproperty
		
		a_high: assert property(clk_div_prop_trans_high);
		
		property clk_div_prop_trans_low;
			@(edge clk)
				disable iff(~resetn) $fell(derivedClocks[i]) |-> ##(i + 1) (derivedClocks[i] === 1'b1);
		endproperty
		
		b_low: assert property(clk_div_prop_trans_low);
	end
endgenerate

initial begin
	@(posedge clk);
	resetn = 1'b0;
	@(posedge clk);
	resetn = 1'b1;
	
	repeat($bits(derivedClocks) * 10) @(posedge clk); //10 times the longest clock 
	
	$stop();
end

endmodule