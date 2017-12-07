`timescale 100ns/100ns
//`define NOIMPAIR
`define IMPAIR_BRANCH
//`define IMPAIR_BEARING
//`define IMPAIR_RANDOM

module pid_tb();
logic clk, resetn;
shortint rpm_set, rpm_sense;
shortint mot_set;

int pidout;
int pidinput;


//	integer i;
	reg [15:0] pidmem [19:0];                   	                            
	initial $readmemh("pid_input.csv", pidmem);

initial begin
	pidout = $fopen("pidimpair_1.csv");
	$fmonitor(pidout, $stime, clk,",%d,%d,%d", rpm_set, rpm_sense, mot_set);
	#1000000;
	$fclose(pidout);

end	

pidctrl pid(.*);
`ifdef NOIMPAIR	pidBench tb(.*);
`endif
`ifdef IMPAIR_BRANCH pidTBimpair_branch tbBranch(.*);
`endif
`ifdef IMPAIR_RANDOM pidTBimpair_random tbRandom(.*);
`endif
`ifdef IMPAIR_BEARING pidTBimpair_bearing tbBearing(.*);
`endif

initial begin
	clk = 1'b0; // define clock state
	forever #125 clk = ~clk; 	// 10kHz clk
//$stop();
end
initial begin
#1000000;	
$display("Program finished");
$stop();
end
endmodule

program pidBench
(input shortint mot_set, logic clk, [15:0] pidmem [19:0],  output logic resetn,shortint rpm_set, shortint rpm_sense);
int pidcnt;
int count;
initial begin

// x(t) -> input to motor (mot_set)
// x(t-T) -> previous input to motor
// c(t) -> output of motor (rpm_sense)
// c(t-T) -> previous output of motor (rpm_sense)

	reg signed [15:0] xq [1:0];
	reg signed [15:0] cq [1:0];
		
	cq[1] = 16'h0000;
	xq[1] = 16'h0000; 
	xq[0] = 16'h0000; 
	cq[0] = 16'h0000; 

	resetn = 1'b0;
	#500;
	resetn = 1'b1;
	#500;
	rpm_set = 16'h0000;
	rpm_sense = 16'h0000;
	#5000; 
	
	pidcnt = 0;
	repeat (20) begin
		rpm_set = pidmem[pidcnt];
		repeat (50) begin
			$display ("-------------- motor implementation -----------------");
			@(posedge clk) begin
				cq[1] = cq[0];
				xq[1] = xq[0];
				xq[0] = mot_set>>>3;	
				cq[0] = xq[1] + cq[1];
				if((rpm_sense >= 16'h157c) && (rpm_sense < 16'h8000)) rpm_sense = 16'h157c;		// max rpm of motor
				else if((rpm_sense <= 16'h0000) && (rpm_sense >= 16'h8000)) rpm_sense = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense = cq[0];
				$display("clk %b,set:%h, rpm_sense:%h, cq[0]:%h, cq[1]:%h", clk, rpm_set,rpm_sense, cq[0], cq[1]);
				$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end		
		end
		pidcnt = pidcnt+1;
	end

$display("Program finished");
$stop();

end

endprogram


program pidTBimpair_branch
(input shortint mot_set, logic clk, [15:0] pidmem [19:0],  output logic resetn,shortint rpm_set, shortint rpm_sense);
int pidcnt1;
shortint impair;
initial begin

// x(t) -> input to motor (mot_set)
// x(t-T) -> previous input to motor
// c(t) -> output of motor (rpm_sense)
// c(t-T) -> previous output of motor (rpm_sense)

	reg signed [15:0] xq [1:0];
	reg signed [15:0] cq [1:0];
		
	cq[1] = 16'h0000;
	xq[1] = 16'h0000; 
	xq[0] = 16'h0000; 
	cq[0] = 16'h0000; 

	resetn = 1'b0;
	#50000;
	resetn = 1'b1;
	#50000;
	rpm_set = 16'h0000;
	rpm_sense = 16'h0000;
	#50000; 
	//rpm_set = 16'h03e8;
	
	pidcnt1 = 0;
	repeat (20) begin
		rpm_set = pidmem[pidcnt1];
		repeat (50) begin
			$display ("-------------- begin loop -----------------");
			@(posedge clk) begin
				cq[1] = cq[0];
				xq[1] = xq[0];
				xq[0] = mot_set>>>3;	
				cq[0] = xq[1] + cq[1];
				//if((rpm_sense >= 16'h157c) && (rpm_sense < 16'h8000)) rpm_sense = 16'h157c;		// max rpm of motor
				//else if((rpm_sense <= 16'h0000) && (rpm_sense >= 16'h8000)) rpm_sense = 16'h0000;	// don't allow the motor to run in reverse direction
				//else rpm_sense = cq[0];
				if((pidcnt1 >= 15) && (pidcnt1 <= 17)) begin
					rpm_sense =16'h0000;
				end
				else rpm_sense = cq[0];
				$display("clk %b,set:%h, rpm_sense:%h, cq[0]:%h, cq[1]:%h", clk, rpm_set,rpm_sense, cq[0], cq[1]);
				$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end		
		end
		pidcnt1 = pidcnt1+1;
	end
$display("Program finished");
$stop();
end

endprogram

program pidTBimpair_bearing
(input shortint mot_set, logic clk, [15:0] pidmem [19:0],  output logic resetn,shortint rpm_set, shortint rpm_sense);
int pidcnt1;
shortint impair;
initial begin

// x(t) -> input to motor (mot_set)
// x(t-T) -> previous input to motor
// c(t) -> output of motor (rpm_sense)
// c(t-T) -> previous output of motor (rpm_sense)

	reg signed [15:0] xq [1:0];
	reg signed [15:0] cq [1:0];
		
	cq[1] = 16'h0000;
	xq[1] = 16'h0000; 
	xq[0] = 16'h0000; 
	cq[0] = 16'h0000; 

	resetn = 1'b0;
	#50000;
	resetn = 1'b1;
	#50000;
	rpm_set = 16'h0000;
	rpm_sense = 16'h0000;
	#50000; 
	//rpm_set = 16'h03e8;
	
	pidcnt1 = 0;
	repeat (20) begin
		rpm_set = pidmem[pidcnt1];
		repeat (50) begin
			$display ("-------------- begin loop -----------------");
			@(posedge clk) begin
				cq[1] = cq[0];
				xq[1] = xq[0];
				xq[0] = mot_set>>>3;	
				cq[0] = xq[1] + cq[1];
				//if((rpm_sense >= 16'h157c) && (rpm_sense < 16'h8000)) rpm_sense = 16'h157c;		// max rpm of motor
				//else if((rpm_sense <= 16'h0000) && (rpm_sense >= 16'h8000)) rpm_sense = 16'h0000;	// don't allow the motor to run in reverse direction
				//else rpm_sense = cq[0];
				if((pidcnt1 >= 15) && (pidcnt1 <= 18)) begin
					rpm_sense =cq[0] - 16'h1000;
					$display("------------------------------- pidcnt window");
				end
				else rpm_sense = cq[0];
				$display("clk %b,set:%h, rpm_sense:%h, cq[0]:%h, cq[1]:%h", clk, rpm_set,rpm_sense, cq[0], cq[1]);
				$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end		
		end
		pidcnt1 = pidcnt1+1;
	end
$display("Program finished");
$stop();
end

endprogram

program pidTBimpair_random
(input shortint mot_set, logic clk, [15:0] pidmem [19:0],  output logic resetn,shortint rpm_set, shortint rpm_sense);
int pidcnt1;
shortint impair;
initial begin

// x(t) -> input to motor (mot_set)
// x(t-T) -> previous input to motor
// c(t) -> output of motor (rpm_sense)
// c(t-T) -> previous output of motor (rpm_sense)

	reg signed [15:0] xq [1:0];
	reg signed [15:0] cq [1:0];
		
	cq[1] = 16'h0000;
	xq[1] = 16'h0000; 
	xq[0] = 16'h0000; 
	cq[0] = 16'h0000; 

	resetn = 1'b0;
	#50000;
	resetn = 1'b1;
	#50000;
	rpm_set = 16'h0000;
	rpm_sense = 16'h0000;
	#50000; 
	//rpm_set = 16'h03e8;
	
	pidcnt1 = 0;
	repeat (20) begin
		rpm_set = pidmem[pidcnt1];
		repeat (50) begin
			$display ("-------------- begin loop -----------------");
			@(posedge clk) begin
				cq[1] = cq[0];
				xq[1] = xq[0];
				xq[0] = mot_set>>>3;	
				cq[0] = xq[1] + cq[1];
				//if((rpm_sense >= 16'h157c) && (rpm_sense < 16'h8000)) rpm_sense = 16'h157c;		// max rpm of motor
				//else if((rpm_sense <= 16'h0000) && (rpm_sense >= 16'h8000)) rpm_sense = 16'h0000;	// don't allow the motor to run in reverse direction
				//else rpm_sense = cq[0];
				if((pidcnt1 >= 15) && (pidcnt1 <= 18)) begin
					rpm_sense =cq[0] - 16'h1000;
					$display("------------------------------- pidcnt window");
				end
				else rpm_sense = cq[0];
				$display("clk %b,set:%h, rpm_sense:%h, cq[0]:%h, cq[1]:%h", clk, rpm_set,rpm_sense, cq[0], cq[1]);
				$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end		
		end
		pidcnt1 = pidcnt1+1;
	end
$display("Program finished");
$stop();
end

endprogram