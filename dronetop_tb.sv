`timescale 100ns/100ns

// 
// each motor has it's own initial block. the motors free run continuously
module dt_tb();
parameter LENMEM = 106;
parameter WINDOW=6;
logic clk, resetn;
logic [2:0] altcmd;
logic [2:0] dircmd [1:0];
shortint mot_set [3:0];
shortint rpm_sense [3:0];

// reg's for commands and target rpm values
reg [11:0] cmdmem [LENMEM-1:0]; // altitude, L&Rt, F&Rv
reg [11:0] cmdreg; 	// used for partial select of cmdmem
reg [63:0] target [LENMEM-1:0]; // target rpm 

initial begin
	$readmemb("cmdinput.txt",cmdmem);
	$readmemh("targetrpm.txt",target);
end

dronectrl_top dt(.clk, .resetn, .altcmd, .dircmd(dircmd[1:0]), .mot_set(mot_set[3:0]), .rpm_sense(rpm_sense[3:0]));
	
initial begin
	clk = 1'b0; // define clock state
	forever #125 clk = ~clk; 	// 40kHz clk
end

reg signed [15:0] xq [7:0];
reg signed [15:0] cq [7:0];
reg signed [15:0] randnoise;
initial begin	// get things initialized and reset
	for(int i=0;i<8;i=i+2)begin
		cq[i] = 16'h0000;
		xq[i] = 16'h0000; 
	end
	altcmd = 3'b000;	// start at a hover
	dircmd[0] = 3'b000; 	// no lateral movement
	dircmd[1] = 3'b000; 	// no lateral movement
	randnoise = 0;
	resetn = 0;
	#500;
	resetn = 1;
	#500;
end

initial begin		// Left Motor--> 0, offset 0
	rpm_sense[0] = 16'h0000;
	forever begin
			@(posedge clk) begin
				cq[1] = cq[0];
				xq[1] = xq[0];
				xq[0] = mot_set[0]>>>3;	
				cq[0] = xq[1] + cq[1];
				if((rpm_sense[0] >= 16'h157c) && (rpm_sense[0] < 16'h8000)) rpm_sense[0] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[0] <= 16'h0000) && (rpm_sense[0] >= 16'h8000)) rpm_sense[0] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[0] = cq[0];
			end	
	end
end

initial begin		// Right Motor--> 1, offset 2
	rpm_sense[1] = 16'h0000;
	forever begin
			@(posedge clk) begin
				cq[2+1] = cq[2];
				xq[2+1] = xq[2];
				xq[2] = mot_set[1]>>>3;	
				cq[2] = xq[2+1] + cq[2+1];
				if((rpm_sense[1] >= 16'h157c) && (rpm_sense[1] < 16'h8000)) rpm_sense[1] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[1] <= 16'h0000) && (rpm_sense[1] >= 16'h8000)) rpm_sense[1] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[1] = cq[2];
			end	
	end
end

initial begin		// Forward Motor--> 2, offset 4
	rpm_sense[2] = 16'h0000;
	forever begin
			@(posedge clk) begin
				cq[4+1] = cq[4];
				xq[4+1] = xq[4];
				xq[4] = mot_set[2]>>>3;	
				cq[4] = xq[4+1] + cq[4+1];
				if((rpm_sense[2] >= 16'h157c) && (rpm_sense[2] < 16'h8000)) rpm_sense[2] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[2] <= 16'h0000) && (rpm_sense[2] >= 16'h8000)) rpm_sense[2] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[2] = cq[4];
			end	
	end
end

initial begin		// Reverse Motor--> 3, offset 6
	forever begin
			@(posedge clk) begin
				cq[6+1] = cq[6];
				xq[6+1] = xq[6];
				xq[6] = mot_set[3]>>>3;	
				cq[6] = xq[6+1] + cq[6+1];
				if((rpm_sense[3] >= 16'h157c) && (rpm_sense[3] < 16'h8000)) rpm_sense[3] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[3] <= 16'h0000) && (rpm_sense[3] >= 16'h8000)) rpm_sense[3] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[3] = cq[6];
			end	
	end
end

// this feeds commands into the controller
// also compares motor rpm with a target rpm
initial begin
	#1000; // wait for resetn
	for (int i=0;i<LENMEM;i=i+1)begin
		//$display("+++++++++++++++++++++++++++++++ New Command +++++++++++++++++++++++++++++++++");
		cmdreg = cmdmem[i];				// extract item
		altcmd = cmdreg[8:6];			// partial select item
		dircmd[0] = cmdreg[5:3];
		dircmd[1] = cmdreg[2:0];
		$display("altcmd: %b, dircmd[0]: %b, dircmd[1]: %b", altcmd, dircmd[0], dircmd[1]);
		#12500;	// 50 clock cycles
		if((rpm_sense[0] > target[i][63:48] + WINDOW) || (rpm_sense[0] < target[i][63:48]-WINDOW)) $display("*** Motor L   Failed *** rpm_sense[0]:%d, target:%d",rpm_sense[0], target[i][63:48]);
		if((rpm_sense[1] > target[i][47:32] + WINDOW) || (rpm_sense[1] < target[i][47:32]-WINDOW)) $display("*** Motor Rt  Failed *** rpm_sense[1]:%d, target:%d",rpm_sense[1], target[i][47:32]);
		if((rpm_sense[2] > target[i][31:16] + WINDOW) || (rpm_sense[2] < target[i][31:16]-WINDOW)) $display("*** Motor F   Failed *** rpm_sense[2]:%d, target:%d",rpm_sense[2], target[i][31:16]);
		if((rpm_sense[3] > target[i][15:0]  + WINDOW) || (rpm_sense[3] < target[i][15:0]-WINDOW))  $display("*** Motor Rv  Failed *** rpm_sense[4]:%d, target:%d",rpm_sense[3], target[i][15:0]);
		#6000;
	end
	
end
	
endmodule



