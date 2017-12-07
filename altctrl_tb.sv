module altctrl_tb();
bit clk;
bit resetn = 0;
logic [2:0] altcmd;
logic [15:0] alt_rpm;
const logic [15:0]rpm = 16'd 3000;
const logic [15:0] step = 16'd 300;


altctrl alt(.clk, .resetn, .altcmd, .alt_rpm);

localparam CLOCK_HALF_CYCLE = 5;
localparam CLOCK_PER = 2 * CLOCK_HALF_CYCLE;
localparam INITIAL_OFFSET = 1;
initial begin
forever #CLOCK_HALF_CYCLE clk = ~ clk;
end


logic [15:0] resultlookuptable [logic [2:0]] =
	'{
		3'b000 : rpm,
		3'b001 : rpm + step,
		3'b010 : rpm + (2 *step),
		3'b011 : rpm + (3 *step),
		3'b100 : rpm,
		3'b101 : rpm - step,
		3'b110 : rpm - (2 *step),
		3'b111 : rpm - (3 * step)
	};

initial begin
    
	#INITIAL_OFFSET;
	#CLOCK_PER;
	resetn = 1;
	
	$display("****Starting test*******");
	
	for (int i = 0 ; i < 8 ; i++) begin
	altcmd = i ;
	
	#CLOCK_PER;
	assert(alt_rpm === resultlookuptable[altcmd])
	$display("test %d is passed",i); 
	else $error("altitude rpm does not match expected %d , got %d ", (resultlookuptable[altcmd]), (alt_rpm));
	
	end

	$display("*************done**************");
	$stop();
	


end




endmodule