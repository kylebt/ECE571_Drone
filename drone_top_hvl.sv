// Sameer Ghewari, Portland State University, Feb 2015 : original BOOTH example
// Kyle Thompson, Portland State University, Nov 2017 : modified to work with pwm module
// Kyle Thompson, Portland State University, Dec 2017 : modified to work with drone top module

// TBX Drone Top testbench - testing the top level drone module
// This is the HVL testbench. Runs on the workstation. This is a very straightforward directed
// testbench and does not include better way of test case generation. You could use SV classes
// and constrained random test case generation to develop test cases 

//Macro borrowed from Prof. Faust's slides
`define SV_RAND_CHECK(r) \
 do begin \
 if (!(r)) begin \
	 $display("%s:%0d: Randomization failed \"%s\"", \
	 `__FILE__, `__LINE__, `"r`"); \
	 $finish; \
	 end \
 end while (0)

typedef struct {
	logic [2:0] altcmd;
	logic [1:0][2:0] dircmd;
	logic signed [3:0][15:0] rpm_sense_set;
	logic signed [3:0][15:0] exp_rpm_sense;
	logic signed [3:0][15:0] mot_set;
	logic signed [3:0][15:0] rpm_sense;
} test_t;

class stimulus;

	const logic signed [15:0] WINDOW = 10; //Output needs to settle within plus or minus this RPM
	const int RANDOM_HOVER_CASES = 10000;

	virtual drone_top_if drone_top_vif;

	function void set_vif (virtual drone_top_if drone_top_vif);
		this.drone_top_vif = drone_top_vif; 
	endfunction

	task calcExpectedRpmSense(ref test_t test);
		shortint left, right, forward, backward;
		shortint speedLR, speedFB;
		unique case(test.altcmd) //See altctrl module
			3'b000: {left,right,forward,backward} = {4{16'd3000}};
			3'b001: {left,right,forward,backward} = {4{16'd3300}};
			3'b010: {left,right,forward,backward} = {4{16'd3600}};
			3'b011: {left,right,forward,backward} = {4{16'd3900}};
			3'b100: {left,right,forward,backward} = {4{16'd3000}};
			3'b101: {left,right,forward,backward} = {4{16'd2700}};
			3'b110: {left,right,forward,backward} = {4{16'd2400}};
			3'b111: {left,right,forward,backward} = {4{16'd2100}};
		endcase
		
		unique case(test.dircmd[0][1:0]) //See dirctrl module
			2'b00: speedLR = 0;
			2'b01: speedLR = 102;
			2'b10: speedLR = 218;
			2'b11: speedLR = 402;
		endcase
		if(test.dircmd[0][2]) begin
			left = left + speedLR;
			right = right - speedLR;
		end else begin
			left = left - speedLR;
			right = right + speedLR;
		end
		
		unique case(test.dircmd[1][1:0]) //See dirctrl module
			2'b00: speedFB = 0;
			2'b01: speedFB = 102;
			2'b10: speedFB = 218;
			2'b11: speedFB = 402;
		endcase
		if(test.dircmd[1][2]) begin
			forward = forward + speedFB;
			backward = backward - speedFB;
		end else begin
			forward = forward - speedFB;
			backward = backward + speedFB;
		end
		
		test.exp_rpm_sense[0] = left;
		test.exp_rpm_sense[1] = right;
		test.exp_rpm_sense[2] = forward;
		test.exp_rpm_sense[3] = backward;
	endtask

	task generateNormalTestCases(ref test_t tests[$]);
		test_t test;
		for(int i = 0; i < 8; i++) begin
			for(int j = 0; j < 8; j++) begin
				for(int k = 0; k < 8; k++) begin
					test.altcmd = i[2:0];
					test.dircmd[0] = j[2:0];
					test.dircmd[1] = k[2:0];
					test.rpm_sense_set = {4{16'b0}}; //No sense measurement spikes
					calcExpectedRpmSense(test);
					test.mot_set = {4{16'b0}};
					test.rpm_sense = {4{16'b0}};
					tests.push_back(test);
					//tests.push_back('{i[2:0], {k[2:0], j[2:0]}, {16'b0, 16'b0, 16'b0, 16'b0}, {16'h0, 16'h0, 16'h0, 16'h0}, {16'b0, 16'b0, 16'b0, 16'b0}, {16'b0, 16'b0, 16'b0, 16'b0}});
				end
			end
		end
		//Given the motor_feedback & pidctrl modules, the expected mot_set value is always zero.
		//This is because motor_feedback will eventually cause rpm_sense to converge to the desired RPM,
		//which causes the pidctrl module output to converge to 0.
		
		//This would not be true for other feedback models. We're going with this assumption though because
		//that's what the mathematical model tells us.
		//tests.push_back('{3'b000, {3'b000, 3'b000}, {16'b0, 16'b0, 16'b0, 16'b0}, {16'h0, 16'h0, 16'h0, 16'h0}, {16'b0, 16'b0, 16'b0, 16'b0}});
		
		//This doesn't make total sense... I think the output rpm term should be something like desired + mot_set.
		//I think we've got the derivative of what we need. However, the point of this project is to demonstrate
		//SystemVerilog concepts and get a design running on the emulator, not specifically to make an accurate
		//drone control module. So, we're going to leave it as-is and change the meaning of that output.
	endtask
	
	class RandomNoise;
		rand shortint noiseL, noiseR, noiseF, noiseB;
		randc bit [2:0] altcmd, lrDirCmd, fbDirCmd; //constrained random to force direction changes
		shortint MAX_RPM = 5500;
		shortint MIN_RPM = 0;
		constraint noiseLimits {
			noiseL <= MAX_RPM; noiseL >= MIN_RPM;
			noiseR <= MAX_RPM; noiseR >= MIN_RPM;
			noiseF <= MAX_RPM; noiseF >= MIN_RPM;
			noiseB <= MAX_RPM; noiseB >= MIN_RPM;
		}
	endclass
	
	task generateRandomNoiseHoverTestCases(ref test_t tests[$]);
		test_t test;
		for(int i = 0; i < RANDOM_HOVER_CASES; i++) begin
			RandomNoise noise;
			noise = new();
			`SV_RAND_CHECK(noise.randomize());
			test.altcmd = 3'b000;
			test.dircmd = {2{3'b000}};
			test.rpm_sense_set = {noise.noiseB, noise.noiseF, noise.noiseR, noise.noiseL};
			calcExpectedRpmSense(test);
			test.mot_set = {4{16'b0}};
			test.rpm_sense = {4{16'b0}};
			tests.push_back(test);
		end
	endtask
	
	task generateRandomNoiseAndMovementTestCases(ref test_t tests[$]);
		test_t test;
		for(int i = 0; i < RANDOM_HOVER_CASES; i++) begin
			RandomNoise noise;
			noise = new();
			`SV_RAND_CHECK(noise.randomize());
			test.altcmd = noise.altcmd;
			test.dircmd = {noise.fbDirCmd, noise.lrDirCmd};
			test.rpm_sense_set = {noise.noiseB, noise.noiseF, noise.noiseR, noise.noiseL};
			calcExpectedRpmSense(test);
			test.mot_set = {4{16'b0}};
			test.rpm_sense = {4{16'b0}};
			tests.push_back(test);
		end
	endtask

	task run;
		int failedTests = 0;
		int	totalTests = 0;
		int currentPwmCount = 0;
		test_t testsToRun[$] = {};
		test_t test;
		bit failedCurrentTest = 0;
		int testVectorSize = 0;

		$display("HVL:%0t Waiting for reset", $time);
		drone_top_vif.wait_for_reset();
		$display("HVL:%0t System is out of reset", $time);
		
		$display("Starting Tests");
		
		generateNormalTestCases(testsToRun);
		generateRandomNoiseHoverTestCases(testsToRun);
		generateRandomNoiseAndMovementTestCases(testsToRun);
		
		testVectorSize = testsToRun.size();
		for(int i = 0; i < testVectorSize; i++) begin
			test = testsToRun.pop_front();
			//$display("Testing altcmd=%b, dircmd[0]=%b, dircmd[1]=%b", test.altcmd, test.dircmd[0], test.dircmd[1]);
			drone_top_vif.do_test(test.altcmd, test.dircmd, test.rpm_sense_set, test.mot_set, test.rpm_sense);
			failedCurrentTest = 0;
			for(int j = 0; j < 4; j++) begin
				//mot_set is expected to converge to 0 if the system is stable
				if(($signed(test.mot_set[j]) > WINDOW) || ($signed(test.mot_set[j]) < -WINDOW)) begin
					$error("Test %d: Motor [%d] failed to settle. RPM=%d, %d < Expected < %d", i, j, $signed(test.mot_set[j]), -WINDOW, WINDOW);
					failedCurrentTest = 1;
				end
				//rpm_sense is expected to converge to the target RPM if stable and feedback works
				if(($signed(test.rpm_sense[j]) > $signed(test.exp_rpm_sense[j]) + WINDOW) ||
							($signed(test.rpm_sense[j]) < $signed(test.exp_rpm_sense[j]) - WINDOW))
				begin
					$error("Test %d: Motor [%d] failed to reach expected RPM. RPM=%d, %d < Expected < %d", 
								i, j, $signed(test.rpm_sense[j]),
								($signed(test.exp_rpm_sense[j]) - WINDOW),
								($signed(test.exp_rpm_sense[j]) + WINDOW));
					$display("%d", $signed(test.exp_rpm_sense[j]));
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
