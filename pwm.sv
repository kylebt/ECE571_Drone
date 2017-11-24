// converrt 16 bit rpm value to a duty cycle
// duty cycle is a count from 0 to 90
// This is a 4kHz PWM
// Duty cycle (from fig. 2) = (rpm-500)/60.8 
// if you feel like you want to take on the dividion...ok
// this is mostly approximation, so round up the 60.8 to 61
// OR
// dividing by 60.8 is close to dividing by 64...much easier and I don't think it will 
// create that much error
// just a thought...

// something we should discuss Thursday...
// system clock is 10kHz, and PWM is 4kHz
// for a 0 to 90 DC, system clock should be operating around 400kHz
// if we want to divide the 4kHz into 100 counts
// hmm
module pwm(pwm_if interf);
    
    localparam PERIOD_BIT_COUNT = $bits(interf.mot_rpm);
	

    logic [PERIOD_BIT_COUNT - 1 : 0] pwmCount, setDutyCycle;

    always_ff @(posedge interf.clk) begin
        if(~interf.resetn) begin
            pwmCount <= '0;
            setDutyCycle <= '0;
        end else begin
            if(interf.set) begin //Set resets the PWM cycle
				setDutyCycle <= interf.mot_rpm;
				pwmCount <= '0;
			end else begin
				pwmCount <= pwmCount + 1; //Relying on overflow behavior to reset back to 0
			end
        end
    end
    
    assign interf.mot_pwm = (pwmCount < setDutyCycle);
endmodule