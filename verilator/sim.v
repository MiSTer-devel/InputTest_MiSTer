`timescale 1ns / 1ps
//
// top end ff for verilator
//

//`define sdl_display
`define USE_VGA
//`define USE_CGA

module top(

	input clk_sys/*verilator public_flat*/,
	input clk_vid/*verilator public_flat*/,
	input reset/*verilator public_flat*/,
	
	// 6 joysticks, 32 buttons each
	input [31:0] joystick_0,
	input [31:0] joystick_1,
	input [31:0] joystick_2,
	input [31:0] joystick_3,
	input [31:0] joystick_4,
	input [31:0] joystick_5,
	
	// analog -127..+127, Y: [15:8], X: [7:0]
	input [15:0] joystick_analog_0,
	input [15:0] joystick_analog_1,
	input [15:0] joystick_analog_2,
	input [15:0] joystick_analog_3,
	input [15:0] joystick_analog_4,
	input [15:0] joystick_analog_5,

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

soc soc(
	.clk_sys(clk_sys),
	.ce_pix(clk_sys),
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
	.analog({joystick_analog_5,joystick_analog_4,joystick_analog_3,joystick_analog_2,joystick_analog_1,joystick_analog_0})
);

endmodule 

