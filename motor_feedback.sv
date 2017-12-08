module motor_feedback(
				input logic clk,
				input logic resetn,
				input logic set,
				input logic signed  [15:0] rpm_set,
				input logic signed  [15:0] mot_rpm,
				output logic signed [15:0] rpm_sense);
	
	logic signed [15:0] old_rpm;
	
	wire signed [15:0] calcNewSense = rpm_sense + ((old_rpm) >>> 3);
	
	always_ff @(posedge clk) begin
		if(~resetn) begin //TODO: Update reset state to be more inline with module reset expectations?
			rpm_sense <= '0;
			old_rpm <= '0;
		end else begin
			if(set) begin
				rpm_sense <= rpm_set;
				old_rpm <= '0;
			end else begin
				old_rpm <= mot_rpm;
				
				if(calcNewSense >= 16'h157c) begin
					rpm_sense <= 16'h157c;		// max rpm of motor
				end else if(calcNewSense <= 16'h0000) begin
					rpm_sense <= 16'h0000;	// don't allow the motor to run in reverse direction
				end else begin
					rpm_sense <= calcNewSense;
				end
				
				//Used to be:
				//cq[1] = cq[0]; //new cq[1] gets old cq[0]
				//xq[1] = xq[0]; //new xq[1] gets old xq[0]
				//xq[0] = mot_rpm >>> 3;	//new xq[0] gets mot_set/8
				//cq[0] = xq[1] + cq[1]; //new cq[0] gets old xq[0] and old cq[0]
				//if((rpm_sense[3] >= 16'h157c) && (rpm_sense[3] < 16'h8000)) rpm_sense[3] = 16'h157c;		// max rpm of motor
				//else if((rpm_sense[3] <= 16'h0000) && (rpm_sense[3] >= 16'h8000)) rpm_sense[3] = 16'h0000;	// don't allow the motor to run in reverse direction
				//else rpm_sense[3] = cq[6];
			end
		end
	end
				
endmodule