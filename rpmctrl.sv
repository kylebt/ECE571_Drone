module rpmctrl(clk, resetn, dir_rpm, alt_rpm, rpm_set);
input clk, resetn;
input [15:0] dir_rpm, alt_rpm;
output reg [15:0] rpm_set;			// output reg [31:0] rpm_set;

// multiply alt_rpm by angle

always_ff @(posedge clk)
begin
	if(~resetn)
	rpm_set <= alt_rpm;
	else
	rpm_set <= dir_rpm + alt_rpm;
end
endmodule