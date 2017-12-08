module dronetop(clk, resetn, altcmd, dircmd, mot_set, rpm_sense);
input logic clk, resetn;
input logic [2:0] altcmd;
input logic [2:0] dircmd [1:0];			// dircmd [0]->L&R, dircmd[1] F&Rv
output logic signed [15:0] mot_set [3:0];		// motrpm [0]-> left motor, [1]-> right motor, [2]-> forward motor, [3]-> rear motor
input logic signed [15:0] rpm_sense [3:0];	// follows same definition as motrpm

wire signed [15:0] angle [3:0];
wire signed [15:0] alt_rpm;
wire signed [15:0] rpm_set [3:0];


dirctrl lrtcmd(.clk(clk), .resetn(resetn), .cmds(dircmd[0]), .left_frwd(angle[0]), .right_back(angle[1]));
dirctrl frvcmd(.clk(clk), .resetn(resetn), .cmds(dircmd[1]), .left_frwd(angle[2]), .right_back(angle[3]));

altctrl udcmd(.clk(clk), .resetn(resetn), .altcmd(altcmd), .alt_rpm(alt_rpm));

rpmctrl rpmL(.clk(clk), .resetn(resetn), .dir_rpm(angle[0]), .alt_rpm(alt_rpm), .rpm_set(rpm_set[0]));
rpmctrl rpmRt(.clk(clk), .resetn(resetn), .dir_rpm(angle[1]), .alt_rpm(alt_rpm), .rpm_set(rpm_set[1]));

rpmctrl rpmF(.clk(clk), .resetn(resetn), .dir_rpm(angle[2]), .alt_rpm(alt_rpm), .rpm_set(rpm_set[2]));
rpmctrl rpmRv(.clk(clk), .resetn(resetn), .dir_rpm(angle[3]), .alt_rpm(alt_rpm), .rpm_set(rpm_set[3]));

pidctrl pidL(.clk(clk), .resetn(resetn), .rpm_set(rpm_set[0]), .rpm_sense(rpm_sense[0]), .mot_set(mot_set[0]));
pidctrl pidRt(.clk(clk), .resetn(resetn), .rpm_set(rpm_set[1]), .rpm_sense(rpm_sense[1]), .mot_set(mot_set[1]));

pidctrl pidF(.clk(clk), .resetn(resetn), .rpm_set(rpm_set[2]), .rpm_sense(rpm_sense[2]), .mot_set(mot_set[2]));
pidctrl pidRv(.clk(clk), .resetn(resetn), .rpm_set(rpm_set[3]), .rpm_sense(rpm_sense[3]), .mot_set(mot_set[3]));


endmodule