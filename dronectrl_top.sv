module droneCtrl_top(clk, resetn, lr_cmds, fr_cmds, alt_ctrl, rpm_sense, pwm_drv);
input clk, resetn
input [2:0] lr_cmds, fr_cmds, alt_ctrl;
input [15:0] rpm_sense [3:0];
output pwm_drv;

endmodule
