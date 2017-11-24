module pwm_tb();
	
bit clk;
bit resetn = 1;
bit set;
typedef logic[6:0] RPM_TYPE;
RPM_TYPE mot_rpm;
logic mot_pwm;

localparam HALF_CLOCK = 5;
localparam CLOCK_PERIOD = 2 * HALF_CLOCK;

initial begin
forever #HALF_CLOCK clk = ~clk;
end

localparam PwmCountBits = $bits(RPM_TYPE);

pwm_if #(.RPM_TYPE(RPM_TYPE)) interf(.clk, .resetn);
pwm  pwm1(interf);

RPM_TYPE currentPwmCount = '0;

int totalTests = 0;
int failedTests = 0;

initial begin
@(posedge clk) resetn = '0;
@(posedge clk) resetn = '1;
$display("Starting PWM Tests");

for(int i = 0; i < 2 ** PwmCountBits; i++) begin
	interf.do_test(i, currentPwmCount);
	assert(currentPwmCount == i)
	else begin
		$error("Expected PWM count (%d), actual (%d)", i, currentPwmCount);
		failedTests++;
	end
	totalTests++;
end

$display("Finished PWM Tests. Total fails: %d, total tests: %d", failedTests, totalTests);
$stop();

end

endmodule