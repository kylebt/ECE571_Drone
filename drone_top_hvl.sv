// Sameer Ghewari, Portland State University, Feb 2015 : original BOOTH example
// Kyle Thompson, Portland State University, Nov 2017 : modified to work with pwm module
// Kyle Thompson, Portland State University, Dec 2017 : modified to work with drone top module

// TBX Drone Top testbench - testing the top level drone module
// This is the HVL testbench. Runs on the workstation. This is a very straightforward directed
// testbench and does not include better way of test case generation. You could use SV classes
// and constrained random test case generation to develop test cases 

typedef struct {
	logic [2:0] altcmd;
	logic [1:0][2:0] dircmd;
	logic signed [3:0][15:0] rpm_sense;
	logic signed [3:0][15:0] exp_mot_set;
	logic signed [3:0][15:0] mot_set;
} test_t;

class stimulus;

const logic signed [15:0] UPPER_WINDOW_LIMIT = 10; //Output needs to settle within plus or minus this RPM
const logic signed [15:0] LOWER_WINDOW_LIMIT = -10;
virtual drone_top_if drone_top_vif;

function void set_vif (virtual drone_top_if drone_top_vif);
	this.drone_top_vif = drone_top_vif; 
endfunction

task generateNormalTestCases(ref test_t tests[$]);
	//Given the motor_feedback module, the expected mot_set value is always zero.
	//This is because motor_feedback will eventually cause rpm_sense to converge to the desired RPM,
	//which causes the pidctrl module output to converge to 0.
	
	//This would not be true for other feedback models. We're going with this assumption though because
	//that's what the mathematical model tells us.
	tests.push_back('{3'b000, {3'b000, 3'b000}, {16'b0, 16'b0, 16'b0, 16'b0}, {16'h0, 16'h0, 16'h0, 16'h0}, {16'b0, 16'b0, 16'b0, 16'b0}});
	
endtask

task run;
	int failedTests = 0;
	int	totalTests = 0;
	int currentPwmCount = 0;
	test_t testsToRun[$] = {};
	test_t test;
	bit failedCurrentTest = 0;

	$display("HVL:%0t Waiting for reset", $time);
	drone_top_vif.wait_for_reset();
	$display("HVL:%0t System is out of reset", $time);
	
	$display("Starting Tests");
	
	generateNormalTestCases(testsToRun);
	
	for(int i = 0; i < testsToRun.size(); i++) begin
		test = testsToRun.pop_front();
		$display("Testing altcmd=%b, dircmd[0]=%b, dircmd[1]=%b", test.altcmd, test.dircmd[0], test.dircmd[1]);
		drone_top_vif.do_test(test.altcmd, test.dircmd, test.rpm_sense, test.mot_set);
		failedCurrentTest = 0;
		for(int j = 0; j < 4; j++) begin
			if(($signed(test.mot_set[j]) > $signed(UPPER_WINDOW_LIMIT)) || ($signed(test.mot_set[j]) < $signed(LOWER_WINDOW_LIMIT))) begin
				$error("Test %d: Motor [%d] failed to settle. RPM=%h, %h < Expected < %h", i, j, test.mot_set[j], LOWER_WINDOW_LIMIT, UPPER_WINDOW_LIMIT);
				failedCurrentTest = 1;
			end
		end
		if(failedCurrentTest) failedTests += 1;
		totalTests++;
	end
	$display("Finished Drone Top Tests. Total fails: %d, total tests: %d", failedTests, totalTests);
endtask 

endclass; 


module drone_top_hvl;
stimulus inst; 

initial
  begin	
  
	inst = new;
	inst.set_vif(drone_top_hdl.interf);
	inst.run();
	$stop;

  end

endmodule: drone_top_hvl
