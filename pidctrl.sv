module pidctrl(clk, resetn, rpm_set, rpm_sense, mot_set );
input clk, resetn;
input logic signed [15:0] rpm_set, rpm_sense;
output logic signed [15:0] mot_set;

// rpm_sense is the motor rpm feed back to the controller
// rpm_set is the desired motor rpm from the directional controller
//  motor_set should NOT be confused with the motor rpm, motor_set is the drive (reference) to the motor to reach the desired rpm
// for this model, the motor is assumed to contain the necessary mechanism (e.g. a PWM) to maintain the motor rpm
 
// et -> error from rpm_set-rpm_sense -> input
//  xt -> output

// signed subtract: rpm_sense from  from rpm_set--> err[0]
// apply compensator algorithm to err[0] to get mot_set xt[0]
// mot_set drives the motor to the rpm_set rpm. 

//logic signed [15:0] err [1:0];	// (0) -> current error, (1) -> previous error
//logic signed [15:0] xt [1:0];	// (0) -> current motor set, (1) -> previous motor set

logic signed [15:0] error;

always_ff@(posedge clk) begin
	if(!resetn) begin
		//err[0] <= 16'h0000;
		//err[1] <= 16'h0000;
		//xt[0] <= 16'h0000; 
		//xt[1] <= 16'h0000; 
		error <= '0;
		mot_set <= '0;
	end
	else begin
		//err[1] = err[0]; //err[1] gets old err[0]
		//err[0] = rpm_set-rpm_sense; //err[0] gets diff(set-sense)
		//xt[1] = xt[0]>>>2; //xt[1] gets old rpm/4
		//xt[0] = err[1] + xt[1]; //rpm gets old err[0] and old rpm/4
		
		error <= rpm_set - rpm_sense;
		mot_set <= error + (mot_set >>> 2);
	end
			
end

//assign	mot_set = xt[0];

endmodule