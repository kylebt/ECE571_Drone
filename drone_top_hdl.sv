// Sameer Ghewari, Portland State University, Feb 2015 : original BOOTH example
// Kyle Thompson, Portland State University, Nov 2017 : modified to work with pwm module
// Kyle Thompson, Portland State University, Dec 2017 : modified to work with drone top module

// Top level HDL - Intantiates DUT, IF, BFM and generates clock and resets. Runs on the emulator. 
// The pragma below specifies that this module is an xrtl module 

module drone_top_hdl;
//pragma attribute drone_top_hdl parition_module_xrtl 

bit clk, resetn;

//Intantiate Interface+BFM
drone_top_if interf(.clk, .resetn);

//Intantiate DUT 
dronetop DUT(.clk(clk),
				.resetn(resetn),
				.altcmd(interf.altcmd),
				.dircmd(interf.dircmd),
				.rpm_sense(interf.rpm_sense),
				.mot_set(interf.mot_set));
				

genvar mf_index;
generate
	for(mf_index = 0; mf_index < 4; mf_index++) begin
		motor_feedback mf(.clk,
							.resetn,
							.set(interf.set),
							.rpm_set(interf.rpm_sense_set[mf_index]),
							.mot_rpm(interf.mot_set[mf_index]),
							.rpm_sense(interf.rpm_sense[mf_index]));
	end
endgenerate

// Free running clock
// tbx clkgen
initial
  begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end

// Reset
// tbx clkgen
initial
  begin
    resetn = 0;
    #20 resetn = 1;
  end

endmodule: drone_top_hdl