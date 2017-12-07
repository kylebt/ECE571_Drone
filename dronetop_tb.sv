`timescale 100ns/100ns

module dt_tb();
logic clk, resetn;
logic [2:0] altcmd;
logic [2:0] dircmd [1:0];
shortint mot_set [3:0];
shortint rpm_sense [3:0];

int cmdinput;
reg [8:0] cmdmem [7:0]; // altitude, L&Rt, F&Rv
reg [8:0] cmdreg;
initial $readmemb("cmdinput.txt",cmdmem);
reg [15:0] target [7:0]; // target rpm 
initial $readmemh("targetrpm.txt",target);

dronectrl_top dt(.clk, .resetn, .altcmd, .dircmd(dircmd[1:0]), .mot_set(mot_set[3:0]), .rpm_sense(rpm_sense[3:0]));
	
initial begin
	clk = 1'b0; // define clock state
	forever #125 clk = ~clk; 	// 40kHz clk
end

initial begin
	$display("%d,altcmd:%d,dircmd0:%d,dircmd1:%d", $stime, altcmd, dircmd[0], dircmd[1]);
	$display("mot_set0:%d,mot_set1:%d,mot_set2:%d,mot_set3:%d", mot_set[0], mot_set[1], mot_set[2], mot_set[3]);
	$display("rpm_sense0:%d,rpm_sense1:%d,rpm_sense2:%d,rpm_sense3:%d", rpm_sense[0], rpm_sense[1], rpm_sense[2], rpm_sense[3]);
	//$monitor("%p,%p,%p,%p", $stime, altcmd, dircmd, rpm_set);
	#1000000;
end	


reg signed [15:0] xq [7:0];
reg signed [15:0] cq [7:0];	
initial begin	
		for(int i=0;i<8;i=i+2)begin
		cq[i] = 16'h0000;
		xq[i] = 16'h0000; 
	end
end

initial begin		// Left Motor--> 0, offset 0
	rpm_sense[0] = 16'h0000;
	while(1) begin
			@(posedge clk) begin
				cq[1] = cq[0];
				xq[1] = xq[0];
				xq[0] = mot_set[0]>>>3;	
				cq[0] = xq[1] + cq[1];
				if((rpm_sense[0] >= 16'h157c) && (rpm_sense[0] < 16'h8000)) rpm_sense[0] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[0] <= 16'h0000) && (rpm_sense[0] >= 16'h8000)) rpm_sense[0] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[0] = cq[0];
				//$display("mot_set0:%d, rpm_sense0:%d", mot_set[0],rpm_sense[0]);
				//$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end	
	end
end

initial begin		// Right Motor--> 1, offset 2
	rpm_sense[1] = 16'h0000;
	while(1) begin
			@(posedge clk) begin
				cq[2+1] = cq[2];
				xq[2+1] = xq[2];
				xq[2] = mot_set[1]>>>3;	
				cq[2] = xq[2+1] + cq[2+1];
				if((rpm_sense[1] >= 16'h157c) && (rpm_sense[1] < 16'h8000)) rpm_sense[1] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[1] <= 16'h0000) && (rpm_sense[1] >= 16'h8000)) rpm_sense[1] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[1] = cq[2];
				//$display("mot_set1:%d, rpm_sense1:%d", mot_set[1],rpm_sense[1]);
				//$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end	
	end
end

initial begin		// Forward Motor--> 2, offset 4
	rpm_sense[2] = 16'h0000;
	while(1) begin
			@(posedge clk) begin
				cq[4+1] = cq[4];
				xq[4+1] = xq[4];
				xq[4] = mot_set[2]>>>3;	
				cq[4] = xq[4+1] + cq[4+1];
				if((rpm_sense[2] >= 16'h157c) && (rpm_sense[2] < 16'h8000)) rpm_sense[2] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[2] <= 16'h0000) && (rpm_sense[2] >= 16'h8000)) rpm_sense[2] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[2] = cq[4];
				//$display("mot_set2:%d, rpm_sense2:%d", mot_set[2],rpm_sense[2]);
				//$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end	
	end
end

initial begin		// Reverse Motor--> 3, offset 6
	while(1) begin
			@(posedge clk) begin
				cq[6+1] = cq[6];
				xq[6+1] = xq[6];
				xq[6] = mot_set[3]>>>3;	
				cq[6] = xq[6+1] + cq[6+1];
				if((rpm_sense[3] >= 16'h157c) && (rpm_sense[3] < 16'h8000)) rpm_sense[3] = 16'h157c;		// max rpm of motor
				else if((rpm_sense[3] <= 16'h0000) && (rpm_sense[3] >= 16'h8000)) rpm_sense[3] = 16'h0000;	// don't allow the motor to run in reverse direction
				else rpm_sense[3] = cq[6];
				//$display("mot_set3:%d, rpm_sense3:%d", mot_set[3],rpm_sense[3]);
				//$display("               mot_set:%h,   xq[0]:%h, xq[1]:%h", mot_set, xq[0], xq[1]);
			end	
	end
end
initial begin
	while(1) begin
		@(posedge clk)begin
			//$display("rpm_sense0:%d,rpm_sense1:%d,rpm_sense2:%d,rpm_sense3:%d", rpm_sense[0],rpm_sense[1],rpm_sense[2],rpm_sense[3]);
			//$display("  mot_set0:%d,  mot_set1:%d,  mot_set2:%d,  mot_set3:%d", mot_set[0],mot_set[1], mot_set[2], mot_set[3]);
		end
	end
end


initial begin
	parameter window=5;
	altcmd = 3'b000;	// start at a hover
	dircmd[0] = 3'b000; 	// no lateral movement
	dircmd[1] = 3'b000; 	// no lateral movement
	resetn = 0;
	#500;
	resetn = 1;
	#500;
	altcmd = 3'b000;	// start at a hover
	dircmd[0] = 3'b000; 	// no lateral movement
	dircmd[1] = 3'b000; 	// no lateral movement
	#6000;
	for (int i=0;i<8;i=i+1)begin
		$display("+++++++++++++++++++++++++++++++ New Command +++++++++++++++++++++++++++++++++");
		cmdreg = cmdmem[i];
		altcmd = cmdreg[8:6];
		dircmd[0] = cmdreg[5:3];
		dircmd[1] = cmdreg[2:0];
		$display("altcmd: %b, dircmd[0]: %b, dircmd[1]: %b", altcmd, dircmd[0], dircmd[1]);
		#12500;	// 50 clock cycles
		if((rpm_sense[0] < target[i] +window) && (rpm_sense[0] > target[i]-window)) $display("****************** Passed ****************");
		else $display("----------------------- Failed -----------------------");
		$display("rpm_sense0:%d,rpm_sense1:%d,rpm_sense2:%d,rpm_sense3:%d", rpm_sense[0],rpm_sense[1],rpm_sense[2],rpm_sense[3]);
		$display("  mot_set0:%d,  mot_set1:%d,  mot_set2:%d,  mot_set3:%d", mot_set[0],mot_set[1], mot_set[2], mot_set[3]);
		#6000;
	end
	
end
	
endmodule



