module dirctrl(clk, resetn, cmds, left_frwd,right_back);
	input logic clk, resetn;
	input logic [2:0] cmds;
	output logic [15:0] left_frwd, right_back;
	
	const logic [15:0] STOP = 16'd0;
	const logic [15:0] SLOW = 16'd102;
	const logic [15:0] MEDIUM = 16'd218;
	const logic [15:0] FAST = 16'd402;

	function automatic logic [15:0] TwosComp(input logic [15:0] value);
		TwosComp = ~value + 16'b1;	
	endfunction

	always_ff @(posedge clk) begin
		if(~resetn) begin
			left_frwd <= '0;
			right_back <= '0;
		end else begin
			dirctrl1: assert(!$isunknown(cmds)) else $error("cmds=%b", cmds);
			unique case (cmds)
				3'b000 : {left_frwd,right_back} <= {TwosComp(STOP), STOP};
				3'b001 : {left_frwd,right_back} <= {TwosComp(SLOW), SLOW};
				3'b010 : {left_frwd,right_back} <= {TwosComp(MEDIUM), MEDIUM};
				3'b011 : {left_frwd,right_back} <= {TwosComp(FAST), FAST};
				3'b100 : {left_frwd,right_back} <= {STOP, TwosComp(STOP)};
				3'b101 : {left_frwd,right_back} <= {SLOW, TwosComp(SLOW)};
				3'b110 : {left_frwd,right_back} <= {MEDIUM, TwosComp(MEDIUM)};
				3'b111 : {left_frwd,right_back} <= {FAST, TwosComp(FAST)};
			endcase
		end
	end

endmodule

