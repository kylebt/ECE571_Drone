// Sameer Ghewari, Portland State University, Feb 2015 

// Top level HDL - Intantiates DUT, IF, BFM and generates clock and resets. Runs on the emulator. 
// The pragma below specifies that this module is an xrtl module 

module top_hdl; //pragma attribute top_hdl parition_module_xrtl 

bit clk, reset;

//Intantiate Interface+BFM
booth_if booth_port(clk, reset);

//Intantiate DUT 
booth_fsm DUT(.booth_port(booth_port));


// Free running clock
// tbx clkgen
initial
  begin
    clk = 0;
    forever begin
      #10 clk = ~clk;
    end
  end

// Reset
// tbx clkgen
initial
  begin
    reset = 1;
    #50 reset = 0;
  end

endmodule: top_hdl