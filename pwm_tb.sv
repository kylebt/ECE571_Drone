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

localparam PwmCountBits = 7;

pwm #(.RPM_TYPE(RPM_TYPE)) pwm1(.clk, .resetn, .set, .mot_rpm, .mot_pwm);

logic [PwmCountBits : 0] currentPwmCount = '0;

int totalTests = 0;
int failedTests = 0;

initial begin
@(posedge clk) resetn = '0;
@(posedge clk) resetn = '1;
$display("Starting PWM Tests");

for(int i = 0; i < 2 ** PwmCountBits; i++) begin
	mot_rpm = i;
	set = '1;
	currentPwmCount = '0;
	for(int j = 0; j < 2 ** PwmCountBits; j++) begin
		@(posedge clk);
		set = '0;
		if(mot_pwm) currentPwmCount++;
	end
	assert(currentPwmCount == mot_rpm)
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