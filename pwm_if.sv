//Interface definition for the PWM module

interface pwm_if(input logic clk, resetn);
	// pragma attribute pwm_if partition_interface_xif
	
	parameter type RPM_TYPE = logic [6:0];
	
	logic set;
    RPM_TYPE mot_rpm;
    logic mot_pwm;
	
	task wait_for_reset(); // pragma tbx xtf
		@(posedge resetn);
	endtask
	
	task do_test(input RPM_TYPE rpm, output RPM_TYPE pwmCount); // pragma tbx xtf
		int currentPwmCount;
		@(posedge clk);
		
		mot_rpm <= rpm;
		set <= '1;
		
		@(posedge clk);
		set <= '0;
		
		currentPwmCount = '0;
		
		for(int i = 0; i < 2 ** $bits(RPM_TYPE); i++) begin
			@(posedge clk);
			if(mot_pwm) currentPwmCount++;
		end
		
		pwmCount = currentPwmCount;
	endtask
endinterface