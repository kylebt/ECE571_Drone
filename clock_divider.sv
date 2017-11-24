module clock_divider(input logic clk, input logic resetn, output logic derivedClock);
	parameter CLOCK_DIVIDER = 10;
	localparam CLOCK_DIVIDER_MAX_COUNT = CLOCK_DIVIDER/2;
	
	//Divider | Divider Count
	// 1	  |    0
	// 2      |    1
	// 4      |    2
	// 6      |    3
	
	logic [7:0] dividerCount;
	
	always_ff @(edge clk) begin
		if(~resetn) begin
			dividerCount <= '0;
			derivedClock <= clk;
		end else begin
			assert((CLOCK_DIVIDER === 1) || (CLOCK_DIVIDER % 2 === 0));
			if(dividerCount >= CLOCK_DIVIDER_MAX_COUNT) begin
				derivedClock <= ~derivedClock;
				dividerCount <= '0;
			end else begin
				dividerCount <= dividerCount + 1;
			end
		end
	end
	
endmodule