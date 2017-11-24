module pidctrl(clk, resetn, rpm_set, rpm_sense, mot_rpm );
input clk, resetn;
input [15:0] rpm_set, rpm_sense;
output [15:0] mot_rpm;

// subtract rpm_sense from  from rpm_set--> rpm_err
// apply compensator algorithm to rpm_err to get mot_rpm
endmodule