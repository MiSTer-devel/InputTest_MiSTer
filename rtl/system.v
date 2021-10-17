`timescale 1ns / 1ps
/*============================================================================
	Aznable (custom 8-bit computer system) - System module

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 1.0
	Date: 2021-07-03

	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 3 of the License, or (at your option)
	any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program. If not, see <http://www.gnu.org/licenses/>.
===========================================================================*/

module system (
	input			clk_sys,
	input 			ce_pix,
	input			reset,
	input [13:0]	dn_addr,
	input			dn_wr,
	input [7:0]		dn_data,
	input [7:0]		dn_index,

	// 6 devices, 32 buttons each
	input [191:0]	joystick,

	// 6 devices, 16 bits each - -127..+127, Y: [15:8], X: [7:0]
	input [95:0]	analog_l,

	// 6 devices, 16 bits each - -127..+127, Y: [15:8], X: [7:0]
	input [95:0]	analog_r,
	
	// 6 devices, 8 bits each - paddle 0..255
	input [47:0]	paddle,

	// 6 devices, 16 bits eachspinner [7:0] -128..+127, [8] - toggle with every update, [9-15] padding
	input [95:0]	spinner,

	// ps2 alternative interface.
	// [8] - extended, [9] - pressed, [10] - toggles with every press/release
	input [10:0]	ps2_key,

	// [0-23] mouse data, [24] - toggles with every event, [25-31] - padding,
	// [32-39] - wheel movements, [40-47] - reserved(additional buttons)
	input [47:0]	ps2_mouse,

	// [31:0] - seconds since 1970-01-01 00:00:00, [32] - toggle with every change
	input [32:0]	timestamp,
	
	output			VGA_HS,
	output			VGA_VS,
	output [7:0]	VGA_R,
	output [7:0]	VGA_G,
	output [7:0]	VGA_B,
	output			VGA_HB,
	output			VGA_VB
);

localparam [8:0] VGA_WIDTH = 9'd320;
localparam [8:0] VGA_HEIGHT = 9'd240;

wire _hb;
wire _vb;
assign VGA_HB = ~_hb;
assign VGA_VB = ~_vb;

wire [8:0] hcnt;
wire [8:0] vcnt;

// Display timing module from JTFRAME
jtframe_vtimer #(
	.HB_START(VGA_WIDTH - 1'b1),
	.VB_START(VGA_HEIGHT- 1'b1)
) vtimer 
(
	.clk(clk_sys),
	.pxl_cen(ce_pix),
	.V(vcnt),
	.H(hcnt),
	.Hinit(),
	.Vinit(),
	.LHBL(_hb),
	.LVBL(_vb),
	.HS(VGA_HS),
	.VS(VGA_VS)
);

// Millisecond timer
reg  [15:0]	timer;
reg  [14:0]	timer_divider = 15'd0;

always @(posedge clk_sys) 
begin
	if(timer_cs == 1'b1 && cpu_wr_n == 1'b0)
	begin
		timer <= 16'd0;
		timer_divider <= 15'd0;
	end
	else
	begin
		if(timer_divider==15'd24000)
		begin
			timer <= timer + 16'd1;
			timer_divider <= 15'd0;
		end
		else
		begin
			timer_divider <= timer_divider + 15'd1;
	 	end
	end
end

// Character map
wire [3:0] chpos_x = 4'd7 - hcnt[2:0];
wire [2:0] chpos_y = vcnt[2:0];
wire [5:0] chram_x = hcnt[8:3];
wire [5:0] chram_y = vcnt[8:3];
wire [11:0] chram_addr = {chram_y, chram_x};
wire [11:0] chrom_addr = {1'b0, chmap_data_out[7:0], chpos_y};
wire chpixel = chrom_data_out[chpos_x[2:0]];

// RGB mixer
wire [2:0] r_temp = chpixel ? fgcolram_data_out[2:0] : bgcolram_data_out[2:0];
wire [2:0] g_temp = chpixel ? fgcolram_data_out[5:3] : bgcolram_data_out[5:3];
wire [1:0] b_temp = chpixel ? fgcolram_data_out[7:6] : bgcolram_data_out[7:6];

// Convert RGb to 24bpp
assign VGA_R = {{2{r_temp}},2'b0};
assign VGA_G = {{2{g_temp}},2'b0};
assign VGA_B = {{3{b_temp}},2'b0};

// CPU control signals
wire [15:0] cpu_addr;
wire [7:0] cpu_din;
wire [7:0] cpu_dout;
wire cpu_rd_n;
wire cpu_wr_n;
wire cpu_mreq_n;

// include Z80 CPU
tv80s T80x  (
	.reset_n   ( !reset ),
	.clk       ( clk_sys ),
	.wait_n    ( 1'b1 ),
	.int_n     ( 1'b1 ),
	.nmi_n     ( 1'b1 ),
	.busrq_n   ( 1'b1 ),
	.mreq_n    ( cpu_mreq_n ),
	.rd_n      ( cpu_rd_n ), 
	.wr_n      ( cpu_wr_n ),
	.A         ( cpu_addr ),
	.di        ( cpu_din ),
	.dout      ( cpu_dout ),
	.m1_n      (),
	.iorq_n    (),
	.rfsh_n    (),
	.halt_n    (),
	.busak_n   ()
  );

// RAM data to CPU
wire [7:0] pgrom_data_out;
wire [7:0] chrom_data_out;
wire [7:0] wkram_data_out;
wire [7:0] chram_data_out;
wire [7:0] fgcolram_data_out;
wire [7:0] bgcolram_data_out;

// RAM data to GFX
wire [7:0] chmap_data_out;

// Hardware inputs
wire [7:0] in0_data_out = {VGA_HS, VGA_VS,VGA_HB, VGA_VB, 4'b1000};
wire [7:0] joystick_data_out = joystick[cpu_addr[7:0] +: 8];
wire [7:0] analog_l_data_out = analog_l[cpu_addr[6:0] +: 8];
wire [7:0] analog_r_data_out = analog_r[cpu_addr[6:0] +: 8];
wire [7:0] paddle_data_out = paddle[cpu_addr[5:0] +: 8];
wire [7:0] spinner_data_out = spinner[cpu_addr[6:0] +: 8];
wire [7:0] ps2_key_data_out = ps2_key[cpu_addr[3:0] +: 8];
wire [7:0] ps2_mouse_data_out = ps2_mouse[cpu_addr[5:0] +: 8];
wire [7:0] timestamp_data_out = timestamp[cpu_addr[5:0] +: 8];
wire [7:0] timer_data_out = timer[cpu_addr[3:0] +: 8];

// CPU address decodes
wire pgrom_cs = cpu_addr[15:14] == 2'b00;
//wire chrom_cs = cpu_addr[15:12] == 4'b0100;  // CPU never accesses the character ROM data directly
wire chram_cs = cpu_addr[15:11] == 5'b10000;
wire fgcolram_cs = cpu_addr[15:11] == 5'b10001;
wire bgcolram_cs = cpu_addr[15:11] == 5'b10010;
wire wkram_cs = cpu_addr[15:14] == 2'b11;
wire in0_cs = cpu_addr == 16'h6000;
wire joystick_cs = cpu_addr[15:8] == 8'b01110000;
wire analog_l_cs = cpu_addr[15:8] == 8'b01110001;
wire analog_r_cs = cpu_addr[15:8] == 8'b01110010;
wire paddle_cs = cpu_addr[15:8] == 8'b01110011;
wire spinner_cs = cpu_addr[15:8] == 8'b01110100;
wire ps2_key_cs = cpu_addr[15:8] == 8'b01110101;
wire ps2_mouse_cs = cpu_addr[15:8] == 8'b01110110;
wire timestamp_cs = cpu_addr[15:8] == 8'b01110111;
wire timer_cs = cpu_addr[15:8] == 8'b01111000;

// always @(posedge timestamp[32]) begin
// 	$display("%b", timestamp);
// end
//always @(posedge clk_sys) begin
// 	if(pgrom_cs) $display("%x pgrom o %x", cpu_addr, pgrom_data_out);
// 	if(wkram_cs) $display("%x wkram i %x o %x w %b", cpu_addr, cpu_dout, wkram_data_out, wkram_wr);
// 	if(chram_cs) $display("%x chram i %x o %x w %b", cpu_addr, cpu_dout, chram_data_out, chram_wr);
// 	if(fgcolram_cs) $display("%x fgcolram i %x o %x w %b", cpu_addr, cpu_dout, fgcolram_data_out, fgcolram_wr);
// 	if(in0_cs) $display("%x in0 i %x o %x", cpu_addr, cpu_dout, in0_data_out);
//  	if(joystick_cs) $display("joystick %b  %b", joystick_bit, joystick_data_out);
//  	if(analog_l_cs) $display("analog_l %b  %b", analog_l_bit, analog_l_data_out);
//  	if(analog_r_cs) $display("analog_r %b  %b", analog_r_bit, analog_r_data_out);
// 	 if(paddle_cs) $display("paddle %b", paddle_data_out);
// 	if(ps2_key_cs) $display("ps2_key %b %x", ps2_key_data_out, cpu_addr[3:0]);
// 	$display("%x", cpu_addr);
//end

// CPU data mux
assign cpu_din = pgrom_cs ? pgrom_data_out :
				 wkram_cs ? wkram_data_out :
				 chram_cs ? chram_data_out :
				 fgcolram_cs ? fgcolram_data_out :
				 bgcolram_cs ? bgcolram_data_out :
				 in0_cs ? in0_data_out :
				 joystick_cs ? joystick_data_out :
				 analog_l_cs ? analog_l_data_out :
				 analog_r_cs ? analog_r_data_out :
				 paddle_cs ? paddle_data_out :
				 spinner_cs ? spinner_data_out :
				 ps2_key_cs ? ps2_key_data_out :
				 ps2_mouse_cs ? ps2_mouse_data_out :
				 timestamp_cs ? timestamp_data_out :
				 timer_cs ? timer_data_out :
				 8'b00000000;

// Rom upload write enables
wire pgrom_wr = dn_wr && dn_index == 8'b0;
wire chrom_wr = dn_wr && dn_index == 8'b1;

// Ram write enables
wire wkram_wr = !cpu_wr_n && wkram_cs;
wire chram_wr = !cpu_wr_n && chram_cs;
wire fgcolram_wr = !cpu_wr_n && fgcolram_cs;
wire bgcolram_wr = !cpu_wr_n && bgcolram_cs;


// MEMORY
// ------

// Program ROM - 0x0000 - 0x3FFF (0x4000 / 16384 bytes)
dpram #(14,8, "rom.hex") pgrom
(
	.clock_a(clk_sys),
	.address_a(cpu_addr[13:0]),
	.wren_a(1'b0),
	.data_a(),
	.q_a(pgrom_data_out),

	.clock_b(clk_sys),
	.address_b(dn_addr[13:0]),
	.wren_b(pgrom_wr),
	.data_b(dn_data),
	.q_b()
);

// Char ROM - 0x4000 - 0x47FF (0x0400 / 2048 bytes)
dpram #(11,8, "font.hex") chrom
(
	.clock_a(clk_sys),
	.address_a(chrom_addr[10:0]),
	.wren_a(1'b0),
	.data_a(),
	.q_a(chrom_data_out),

	.clock_b(clk_sys),
	.address_b(dn_addr[10:0]),
	.wren_b(chrom_wr),
	.data_b(dn_data),
	.q_b()
);


// Char RAM - 0x8000 - 0x87FF (0x0800 / 2048 bytes)
dpram #(11,8) chram
(
	.clock_a(clk_sys),
	.address_a(cpu_addr[10:0]),
	.wren_a(chram_wr),
	.data_a(cpu_dout),
	.q_a(chram_data_out),

	.clock_b(clk_sys),
	.address_b(chram_addr[10:0]),
	.wren_b(1'b0),
	.data_b(),
	.q_b(chmap_data_out)
);

// Char foreground color RAM - 0x8800 - 0x8FFF (0x0800 / 2048 bytes)
dpram #(11,8) fgcolram
(
	.clock_a(clk_sys),
	.address_a(cpu_addr[10:0]),
	.wren_a(fgcolram_wr),
	.data_a(cpu_dout),
	.q_a(),

	.clock_b(clk_sys),
	.address_b(chram_addr[10:0]),
	.wren_b(1'b0),
	.data_b(),
	.q_b(fgcolram_data_out)
);

// Char background color RAM - 0x9000 - 0x97FF (0x0800 / 2048 bytes)
dpram #(11,8) bgcolram
(
	.clock_a(clk_sys),
	.address_a(cpu_addr[10:0]),
	.wren_a(bgcolram_wr),
	.data_a(cpu_dout),
	.q_a(),

	.clock_b(clk_sys),
	.address_b(chram_addr[10:0]),
	.wren_b(1'b0),
	.data_b(),
	.q_b(bgcolram_data_out)
);

// Work RAM - 0xC000 - 0xFFFF (0x4000 / 16384 bytes)
spram #(14,8) wkram
(
	.clock(clk_sys),
	.address(cpu_addr[13:0]),
	.wren(wkram_wr),
	.data(cpu_dout),
	.q(wkram_data_out)
);

endmodule
