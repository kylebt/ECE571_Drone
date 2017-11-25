// Sameer Ghewari, Portland State University, Feb 2015 

// TBX PWM Example - testing a PWM signal generator
// This is the HVL testbench. Runs on the workstation. This is a very straightforward directed
// testbench and does not include better way of test case generation. You could use SV classes
// and constrained random test case generation to develop test cases 

class stimulus; 

virtual pwm_if pwm_vif;


function void set_vif (virtual pwm_if pwm_vif);
	this.pwm_vif = pwm_vif; 
endfunction

task run;
	int failedTests = 0;
	int	totalTests = 0;
	int currentPwmCount = 0;

	$display("HVL:%0t Waiting for reset", $time);
	pwm_vif.wait_for_reset();
	$display("HVL:%0t System is out of reset", $time);
	
	$display("Starting Tests");
	
	for(int i = 0; i < 2 ** ($bits(this.pwm_vif.RPM_TYPE)); i++) begin
		pwm_vif.do_test(i, currentPwmCount);
		assert(currentPwmCount == i)
		else begin
			$error("Expected PWM count (%d), actual (%d)", i, currentPwmCount);
			failedTests++;
		end
		totalTests++;
	end
	$display("Finished PWM Tests. Total fails: %d, total tests: %d", failedTests, totalTests);
endtask 

endclass; 


module pwm_top_tb;
stimulus inst; 

initial
  begin	
  
	inst = new;
	inst.set_vif(pwm_top_hdl.interf);
	inst.run();
	$stop;

  end

endmodule: pwm_top_tb
