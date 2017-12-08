//Interface definition for the drone_top module

interface drone_top_if(input logic clk, resetn);
	// pragma attribute drone_top_if partition_interface_xif
	
	parameter type RPM_TYPE = logic [6:0];
	
	//Inputs to DUT
	logic [2:0] altcmd;
	logic [2:0] dircmd [1:0];
	signed logic [15:0] rpm_sense [3:0];
	
	//Outputs from DUT
	logic [15:0] mot_set [3:0];
	
	task wait_for_reset(); // pragma tbx xtf
		@(posedge resetn);
	endtask
	
	task do_test(input logic [2:0] altcmd, 
					input logic [2:0] dircmd [1:0],
					input signed logic [15:0] rpm_sense [3:0], //this is initial sense value, doesn't direcly drive DUT
					output logic [15:0] mot_set [3:0]); // pragma tbx xtf

		@(posedge clk);
		
		this.altcmd <= altcmd;
		this.dircmd <= dircmd;
		this.rpm_sense <= rpm_sense;
		
		//TODO: need to figure out how to get initial rpm_sense value set.
		//And, need to figure out if initial settling period is needed.
		
		repeat(50) @(posedge clk); //Wait 50 clock cycles for output to stabilize
		mot_set <= this.mot_set;
	endtask
endinterface