module dirctrl(clk, resetn, cmds, left_frwd,right_back);
	input clk, resetn;
	input [2:0] cmds;
	output logic [15:0] left_frwd, right_back;
	
	typedef enum {STOP, SLOW, MEDIUM, FAST} speed_t;

	logic [15:0] speedLookupTable[speed_t] = 
		'{
			STOP :		16'd0,		//No change in direction
			SLOW : 		16'd102,	//3000 * (1 - cos(15))   15 degree tilt	
			MEDIUM : 	16'd218,	//3000 * (1 - cos(22.5)) 22.5 degree tilt
			FAST :		16'd402		//3000 * (1 - cos(30))   30 degree tilt
		};

	function automatic logic [15:0] TwosComp(input logic [15:0] value);
		TwosComp = ~value + 16'b1;	
	endfunction

	always_ff @(posedge clk) begin
		if(~resetn) begin
			left_frwd <= '0;
			right_back <= '0;
		end else begin 
			unique case (cmds)
				3'b000 : {left_frwd,right_back} <= {TwosComp(speedLookupTable[STOP]), speedLookupTable[STOP]};
				3'b001 : {left_frwd,right_back} <= {TwosComp(speedLookupTable[SLOW]), speedLookupTable[SLOW]};
				3'b010 : {left_frwd,right_back} <= {TwosComp(speedLookupTable[MEDIUM]), speedLookupTable[MEDIUM]};
				3'b011 : {left_frwd,right_back} <= {TwosComp(speedLookupTable[FAST]), speedLookupTable[FAST]};
				3'b100 : {left_frwd,right_back} <= {speedLookupTable[STOP], TwosComp(speedLookupTable[STOP])};
				3'b101 : {left_frwd,right_back} <= {speedLookupTable[SLOW], TwosComp(speedLookupTable[SLOW])};
				3'b110 : {left_frwd,right_back} <= {speedLookupTable[MEDIUM], TwosComp(speedLookupTable[MEDIUM])};
				3'b111 : {left_frwd,right_back} <= {speedLookupTable[FAST], TwosComp(speedLookupTable[FAST])};
			endcase
		end
	end

endmodule

