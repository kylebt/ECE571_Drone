module rpmctrl_tb();
bit clk=1;
bit resetn = 1;
logic [15:0] rpm_set;
logic [15:0] dir_rpm,alt_rpm;
integer i,j;


rpmctrl  rpm(.clk , .resetn , .rpm_set , .dir_rpm , .alt_rpm);

localparam CLOCK_HALF_CYCLE = 5;
localparam CLOCK_PER = 2 * CLOCK_HALF_CYCLE;
localparam INITIAL_OFFSET = 1;

initial begin
forever #CLOCK_HALF_CYCLE clk = ~ clk;
end
initial
begin
for (i=3000; i <= 3000+2 ** 4; i = i+1)	// chianna changed to test neg

begin
for (j=0 ; j <= 2 ** 4; j = j+1)
begin
dir_rpm =i;
alt_rpm =-j;
@(posedge clk);
assert (rpm_set === i+j)
else $display (" Output rpm mismatch  , expected rpm %d, actual rpm %d ", i+j , rpm_set );
end
end
$display("Done with RPM testing");
end

endmodule





