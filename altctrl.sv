module altctrl(clk, resetn, altcmd, alt_rpm);
input logic clk, resetn;
input logic [2:0] altcmd;
output logic [15:0] alt_rpm;
parameter   [15:0]rpm = 16'd3000;
parameter  [15:0] step = 16'd300; 

// see notes on DroneController module drawing


always_ff @(posedge clk) begin
	if(~resetn) begin
		alt_rpm <= rpm ;
	end else begin 
		unique case (altcmd)
			3'b000 : alt_rpm <= rpm;
			3'b001 : alt_rpm <= rpm + step;
			3'b010 : alt_rpm <= rpm + (2 * step);
			3'b011 : alt_rpm <= rpm + (3 * step);
			3'b100 : alt_rpm <= rpm;
			3'b101 : alt_rpm <= rpm - step;
			3'b110 : alt_rpm <= rpm - (2 * step);
			3'b111 : alt_rpm <= rpm - (3 * step);
		endcase
	end
end



endmodule