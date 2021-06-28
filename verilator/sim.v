`timescale 1ns / 1ps

module top(

	input clk_sys/*verilator public_flat*/,
	input reset/*verilator public_flat*/,
	
	input [31:0] joystick_0,
	input [31:0] joystick_1,
	input [31:0] joystick_2,
	input [31:0] joystick_3,
	input [31:0] joystick_4,
	input [31:0] joystick_5,
	
	input [15:0] joystick_analog_0,
	input [15:0] joystick_analog_1,
	input [15:0] joystick_analog_2,
	input [15:0] joystick_analog_3,
	input [15:0] joystick_analog_4,
	input [15:0] joystick_analog_5,

	input [7:0] paddle_0,
	input [7:0] paddle_1,
	input [7:0] paddle_2,
	input [7:0] paddle_3,
	input [7:0] paddle_4,
	input [7:0] paddle_5,

	input [8:0] spinner_0,
	input [8:0] spinner_1,
	input [8:0] spinner_2,
	input [8:0] spinner_3,
	input [8:0] spinner_4,
	input [8:0] spinner_5,

	// ps2 alternative interface.
	// [8] - extended, [9] - pressed, [10] - toggles with every press/release
	input [10:0] ps2_key,

	// [24] - toggles with every event
	input [24:0] ps2_mouse,
	input [15:0] ps2_mouse_ext, // 15:8 - reserved(additional buttons), 7:0 - wheel movements

	output [7:0] VGA_R/*verilator public_flat*/,
	output [7:0] VGA_G/*verilator public_flat*/,
	output [7:0] VGA_B/*verilator public_flat*/,
	
	output VGA_HS,
	output VGA_VS,
	output VGA_HB,
	output VGA_VB,
	
	input				ioctl_download,
	input				ioctl_wr,
	input [24:0]	ioctl_addr,
	input [7:0]		ioctl_dout,
	input [7:0]		ioctl_index,
	output reg		ioctl_wait=1'b0
);

// Clock divider from JTFRAME
wire ce_pix;
/* verilator lint_off PINMISSING */
jtframe_cen24 divider
(
	.clk(clk_sys),
	//.cen12(ce_pix), // <-- dodgy video speed for faster simulation, will cause bearable char map corruption
	.cen4(ce_pix) // <-- correct video speed
);
/* verilator lint_on PINMISSING */

system system(
	.clk_sys(clk_sys),
	.ce_pix(ce_pix),
	.reset(reset | ioctl_download),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_HB(VGA_HB),
	.VGA_VB(VGA_VB),
	.dn_addr(ioctl_addr[13:0]),
	.dn_data(ioctl_dout),
	.dn_wr(ioctl_wr),
	.dn_index(ioctl_index),
	
	.joystick({joystick_5,joystick_4,joystick_3,joystick_2,joystick_1,joystick_0}),
	.analog({joystick_analog_5,joystick_analog_4,joystick_analog_3,joystick_analog_2,joystick_analog_1,joystick_analog_0}),
	.paddle({paddle_5,paddle_4,paddle_3,paddle_2,paddle_1,paddle_0}),
	.spinner({7'b0,spinner_5,7'b0,spinner_4,7'b0,spinner_3,7'b0,spinner_2,7'b0,spinner_1,7'b0,spinner_0}),
	.ps2_key(ps2_key),
	.ps2_mouse({ps2_mouse_ext,7'b0,ps2_mouse})
);

endmodule 

