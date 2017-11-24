// Sameer Ghewari, Portland State University, Feb 2015 

// TBX BFM Example - Simple ALU 
// This is the HVL testbench. Runs on the workstation. This is a very straightforward directed
// testbench and does not include better way of test case generation. You could use SV classes
// and constrained random test case generation to develop test cases 

//Import alu_pkg definitions for struct data type and parameters
import booth_pkg::*;

class stimulus; 

virtual booth_if booth_vif;


function void set_vif (virtual booth_if booth_vif);
	this.booth_vif = booth_vif; 
endfunction

task run; 
//Create temporary variables to generate test cases and record responses 
mult_data req, resp;
$display("HVL:%0t", $time, "Waiting for reset");
//Wait for reset
booth_vif.wait_for_reset();
$display("HVL:%0t", $time, "System is out of reset");
//generate a test case 
$display("Starting Tests");
req = {32'd5,32'd7,64'd0};
//Invoke bus transaction 
booth_vif.do_item(req,resp);
//Display result	
$display("%p",resp);
endtask 

endclass; 


module top_tb;
stimulus inst; 

initial
  begin	
  
	inst = new;
	inst.set_vif(top_hdl.booth_port);
	inst.run();
	$stop;

  end

endmodule: top_tb
