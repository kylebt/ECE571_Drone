module dirctrl(clk, resetn, cmds, left_frwd,right_back);
input clk, resetn;
input [2:0] cmds;
output reg signed [15:0] left_frwd,right_back;

// based on cmds output angle value

function logic [15:0] TwosComp(input logic [15:0] value);
	TwosComp = ~value + 16'b1;	
	//return (~value + 16'b1);
endfunction

always_ff @(posedge clk) begin
	if(~resetn) begin
		left_frwd <= '0 ; right_back <= '0 ;
	end else begin 
		unique case (cmds)
			3'b000 :{left_frwd,right_back}<={'0 ,'0 };
			3'b001 : {left_frwd,right_back}<={TwosComp(16'd102), 16'd102};
			3'b010 : {left_frwd,right_back}<={ ~(16'd218)+16'd1, 16'd218 };
			3'b011 : {left_frwd,right_back}<={ TwosComp(16'd402), 16'd402 };
			3'b100 : {left_frwd,right_back}<={ '0 , '0};
			3'b101 : {left_frwd,right_back}<={ (16'd102) ,TwosComp(16'd102)};
			3'b110 : {left_frwd,right_back}<={ 16'd218 , TwosComp(16'd218)};
			3'b111 : {left_frwd,right_back}<={ 16'd402 , TwosComp(16'd402)};
		endcase
	end
end

endmodule

