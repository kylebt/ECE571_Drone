//Interface definition for the drone_top module

interface drone_top_if(input logic clk, resetn);
	// pragma attribute drone_top_if partition_interface_xif
	
	//Inputs to DUT
	logic [2:0] altcmd;
	logic [2:0] dircmd [1:0];
	logic signed [15:0] rpm_set [3:0];
	logic set;
	
	//Outputs from DUT
	logic signed [15:0] mot_set [3:0];
	
	task wait_for_reset(); // pragma tbx xtf
		@(posedge resetn);
		altcmd <= '0;
		dircmd[0] <= '0;
		dircmd[1] <= '0;
		set <= '0;
	endtask
	
	task do_test(input logic [2:0] altcommand, 
					input logic [1:0][2:0] dircommand,
					input logic signed [3:0][15:0] revpm_set, //this is initial sense value, doesn't direcly drive DUT
					output logic signed [3:0][15:0] motor_set); // pragma tbx xtf

		@(posedge clk);
		$display("HDL altcmd=%b, dircmd[0]=%b, dircmd[1]=%b", altcommand, dircommand[0], dircommand[1]);
		altcmd <= altcommand;
		{>>{dircmd}} <= dircommand;
		{>>{rpm_set}} <= revpm_set;
		
		//Hold the RPM sense lines for a small number of clock cycles
		//Holding set high causes the feedback loop to be broken; allowing for the motor set
		//	to propagate through the top module.
		set <= 1'b1;
		repeat(10) @(posedge clk);
		set <= 1'b0;
		
		//At this point, the feedback loop is closed. The test is now running
		repeat(50) @(posedge clk); //Wait 50 clock cycles for output to stabilize
		motor_set = {>>{mot_set}};
	endtask
endinterface