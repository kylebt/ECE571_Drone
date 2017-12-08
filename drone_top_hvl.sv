// Sameer Ghewari, Portland State University, Feb 2015 : original BOOTH example
// Kyle Thompson, Portland State University, Nov 2017 : modified to work with pwm module
// Kyle Thompson, Portland State University, Dec 2017 : modified to work with drone top module

// TBX Drone Top testbench - testing the top level drone module
// This is the HVL testbench. Runs on the workstation. This is a very straightforward directed
// testbench and does not include better way of test case generation. You could use SV classes
// and constrained random test case generation to develop test cases 

typedef struct {
	logic [2:0] altcmd;
	logic [2:0] dircmd [1:0];
	signed logic [15:0] rpm_sense [3:0];
	signed logic [15:0] exp_mot_set [3:0];
	signed logic [15:0] mot_set[3:0];
} test_t;

class stimulus;

const int WINDOW = 6; //Output needs to settle within plus or minus this RPM
virtual drone_top_if drone_top_vif;

function void set_vif (virtual drone_top_if drone_top_vif);
	this.drone_top_vif = drone_top_vif; 
endfunction

task generateNormalTestCases(input ref test_t tests[$]);
	//TODO: implement
	tests.push_back('{3'b000, 3'b000, 3'b000, '{'0,'0,'0,'0}, '{16'h0BB8, 16'h0BB8, 16'h0BB8, 16'h0BB8}, '{'0,'0,'0,'0}});
	
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
		drone_top_vif.do_test(test.altcmd, test.dircmd, test.rpm_sense, test.mot_set);
		failedCurrentTest = 0;
		for(int j = 0; j < 4; j++) begin
			assert(test.mot_set[j] < test.exp_mot_set[j] + WINDOW && test.mot_set[j] > test.exp_mot_set[j] - WINDOW)
			else begin
				$error("Test %d: Motor [%d] failed to settle. RPM=%d, %d < Expected < %d", i, j, test.mot_rpm[j], test.exp_mot_set[j] - WINDOW, test.exp_mot_set[j] + WINDOW);
				failedCurrentTest = 1;
			end
		end
		if(failedCurrentTest) failedTests += 1;
		totalTests++;
	end
	$display("Finished PWM Tests. Total fails: %d, total tests: %d", failedTests, totalTests);
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

endmodule: drone_top_tb
