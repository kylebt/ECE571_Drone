// Sameer Ghewari, Portland State University, Feb 2015 

// Top level HDL - Intantiates DUT, IF, BFM and generates clock and resets. Runs on the emulator. 
// The pragma below specifies that this module is an xrtl module 

module pwm_top_hdl; //pragma attribute top_hdl parition_module_xrtl 

bit clk, resetn;

//Intantiate Interface+BFM
pwm_if interf(.clk, .resetn);

//Intantiate DUT 
pwm DUT(.interf(interf));


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

endmodule: pwm_top_hdl