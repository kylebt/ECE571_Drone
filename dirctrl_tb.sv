module dirctrl_tb();
bit clk;
bit resetn = 0;
logic [2:0] cmds;
logic [15:0]left_frwd,right_back;


dirctrl dir(.clk, .resetn, .cmds, .left_frwd , .right_back);

localparam CLOCK_HALF_CYCLE = 5;
localparam CLOCK_PER = 2 * CLOCK_HALF_CYCLE;
localparam INITIAL_OFFSET = 1;
initial begin
forever #CLOCK_HALF_CYCLE clk = ~ clk;
end
 typedef struct{
  logic [15:0] expected_value_left_frwd;
  logic [15:0] expected_value_right_back;
 }expected_value;
function automatic logic[15:0] TwosComp(input logic [15:0] value);
     TwosComp = ~value + 16'b1;
     
     //return ~value + 16'b1;
 endfunction
 

expected_value resultlookuptable [logic [2:0]] =
	'{
		3'b000 : '{'0, '0},
		3'b001 : '{TwosComp(16'd102), 16'd102},
		3'b010 : '{TwosComp(16'd218), 16'd218},
		3'b011 : '{TwosComp(16'd402), 16'd402},
		3'b100 : '{'0 ,'0 },
		3'b101 : '{16'd102, TwosComp(16'd102)},
		3'b110 : '{16'd218 , TwosComp(16'd218)},
		3'b111 : '{16'd402 , TwosComp(16'd402)}
	};

initial begin
	#INITIAL_OFFSET;
	#CLOCK_PER;
	resetn = 1;
	
	$display("*******Starting test********");
	
	for (int i = 0; i < 8; i++) begin
		cmds = i;
		
		//#CLOCK_PER;
		@(posedge clk);
		@(posedge clk); //TODO: Remove this second clock once the race condition is resolved (using program should fix it)
		
		assert(left_frwd === resultlookuptable[cmds].expected_value_left_frwd)
			$display("command %d gave correct result for left forward",i);
		else 
			$display ("The expected  left_frwd value is %d , actual left_frwd value is %d ", resultlookuptable[cmds].expected_value_left_frwd, left_frwd);
		assert(right_back === resultlookuptable[cmds].expected_value_right_back)
			$display("command %d gave correct result for right back",i);
		else 
			$display ("The expected  right value is %d , actual right_back value is %d ", resultlookuptable[cmds].expected_value_right_back, right_back);

	end

	$display("*****done*****");
	$stop();
	


end




endmodule