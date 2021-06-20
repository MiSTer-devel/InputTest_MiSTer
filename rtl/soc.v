`timescale 1ns / 1ps
module soc (
	input			clk_sys,
	input 			clk_pix,
	input [13:0]	dn_addr,
	input			dn_wr,
	input [7:0]		dn_data,
	input [7:0]		inputs,
	output			VGA_HS,
	output			VGA_VS,
	output [7:0]	VGA_R,
	output [7:0]	VGA_G,
	output [7:0]	VGA_B,
	output			VGA_HB,
	output			VGA_VB,
	output			VGA_DE
);

// Video subsystem
video video (
	.pclk     ( clk_pix ),
	.cpu_clk  ( clk_sys ),
	.cpu_wr   ( !cpu_wr_n && !cpu_addr[15] ),
	.cpu_addr ( cpu_addr[15:0] ),
	.cpu_data ( cpu_dout ),
	.hs	(VGA_HS),
	.vs	(VGA_VS),
	.r	(VGA_R),
	.g	(VGA_G),
	.b	(VGA_B),
	.hb	(VGA_HB),
	.vb	(VGA_VB),
	.de	(VGA_DE)
);

// The CPU is kept in reset for 256 cycles after power on
reg [7:0] cpu_reset_cnt = 8'h00;
wire cpu_reset = (cpu_reset_cnt != 255);
always @(posedge clk_sys)
	if(cpu_reset_cnt != 255)
		cpu_reset_cnt <= cpu_reset_cnt + 8'd1;

// CPU control signals
wire [15:0] cpu_addr;
wire [7:0] cpu_din;
wire [7:0] cpu_dout;
wire cpu_rd_n;
wire cpu_wr_n;
wire cpu_mreq_n;

// include Z80 CPU
tv80s T80x  (
	.reset_n   ( !cpu_reset    ),
	.clk       ( clk_sys       ),
	.wait_n    ( 1'b1          ),
	.int_n     ( 1'b1          ),
	.nmi_n     ( 1'b1          ),
	.busrq_n   ( 1'b1          ),
	.mreq_n    ( cpu_mreq_n    ),
	.rd_n      ( cpu_rd_n      ), 
	.wr_n      ( cpu_wr_n      ),
	.A         ( cpu_addr      ),
	.di        ( cpu_din       ),
	.dout      ( cpu_dout      ),
	.m1_n      (),
	.iorq_n    (),
	.rfsh_n    (),
	.halt_n    (),
	.busak_n   ()
  );


wire [7:0] ram_data_out;
wire [7:0] rom_data_out;

wire rom_cs = cpu_addr[15:14] == 2'b00;
wire ram_cs = cpu_addr[15] == 1'b1;
wire in0_cs = cpu_addr == 16'h4000;
wire in1_cs = cpu_addr == 16'h4001;

assign cpu_din = ram_cs ? ram_data_out :
				 rom_cs ? rom_data_out :
				 in0_cs ? {VGA_HS, VGA_VS, 6'b101000} :
				 in1_cs ? inputs :
				 8'b00000000;

always @(posedge clk_sys)
begin
	//$display("%b %x %d", cpu_addr, cpu_addr, cpu_addr);
	//$display("%x = %x", cpu_addr, cpu_din);
	// $display("rom_cs %b ram_cs %b in1_cs %b", rom_cs, ram_cs, in1_cs);
end

dpram #(12,8) rom
(
	.clock_a(clk_sys),
	.address_a(cpu_addr[11:0]),
	.wren_a(1'b0),
	.data_a(),
	.q_a(rom_data_out),

	.clock_b(clk_sys),
	.address_b(dn_addr[11:0]),
	.wren_b(dn_wr),
	.data_b(dn_data),
	.q_b()
);

dpram #(12,8) ram
(
	.clock_a(clk_sys),
	.address_a(cpu_addr[11:0]),
	.wren_a(!cpu_wr_n && ram_cs),
	.data_a(cpu_dout),
	.q_a(ram_data_out),

	.clock_b(clk_sys),
	.address_b(cpu_addr[11:0]),
	.wren_b(1'b0),
	.data_b(),
	.q_b()
);

endmodule
