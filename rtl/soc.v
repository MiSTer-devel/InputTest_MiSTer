`timescale 1ns / 1ps
module soc (
	input			clk_sys,
	input 			clk_pix,
	input			reset,
	input [13:0]	dn_addr,
	input			dn_wr,
	input [7:0]		dn_data,
	input [7:0]		dn_index,
	input [7:0]		inputs,
	output			VGA_HS,
	output			VGA_VS,
	output [7:0]	VGA_R,
	output [7:0]	VGA_G,
	output [7:0]	VGA_B,
	output			VGA_HB,
	output			VGA_VB
);

wire _hb;
wire _vb;
assign VGA_HB = ~_hb;
assign VGA_VB = ~_vb;

wire [8:0] hcnt;
wire [8:0] vcnt;
wire hinit;
wire vinit;

// Display timing module from JTFRAME
jtframe_vtimer #(
	.HB_START(9'd320),
	.VB_START(9'd240)
) vtimer 
(
	.clk(clk_sys),
	.pxl_cen(clk_pix),
	.V(vcnt),
	.H(hcnt),
	.Hinit(hinit),
	.Vinit(vinit),
	.LHBL(_hb),
	.LVBL(_vb),
	.HS(VGA_HS),
	.VS(VGA_VS)
);

// DEBUG OUTPUT
assign VGA_R = hcnt[7:0];
assign VGA_G = vcnt[7:0];
assign VGA_B = voff;

// reg [7:0] hoff;
reg [7:0] voff;

always @(posedge clk_sys)
begin
	if(vinit == 1'b1) voff <= voff + 8'b1;
// 	//if(hinit == 1'b1) hoff <= hoff + 8'b1;
// 	$display("%d %d", vrender, vrender1);
end



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

// RAM bank data outs
wire [7:0] pgrom_data_out;
wire [7:0] chrom_data_out;
wire [7:0] wkram_data_out;
wire [7:0] chram_data_out;

// RAM bank data outs
wire [10:0] chrom_addr;

// CPU address decodes
wire pgrom_cs = cpu_addr[15:14] == 2'b00;
wire chrom_cs = cpu_addr[15:14] == 2'b00;
wire wkram_cs = cpu_addr[15] == 1'b1;
wire chram_cs = cpu_addr[15] == 1'b1;
wire in0_cs = cpu_addr == 16'h4000;
wire in1_cs = cpu_addr == 16'h4001;

// CPU data mux
assign cpu_din = pgrom_cs ? pgrom_data_out :
				 wkram_cs ? wkram_data_out :
				 wkram_cs ? wkram_data_out :
				 in0_cs ? {VGA_HS, VGA_VS, 6'b101000} :
				 in1_cs ? inputs :
				 8'b00000000;

// Rom upload write enables
wire pgrom_wr = dn_wr && dn_index == 8'b0;
wire chrom_wr = dn_wr && dn_index == 8'b1;


// MEMORY
// ------

// Program ROM - 0x0000 - 0x3FFF (0x4000 / 16384 bytes)
dpram #(14,8) pgrom
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

// Char ROM - 0x4000 - 0x43FF (0x0400 / 1024 bytes)
dpram #(11,8) chrom
(
	.clock_a(clk_sys),
	.address_a(chrom_addr),
	.wren_a(1'b0),
	.data_a(),
	.q_a(chrom_data_out),

	.clock_b(clk_sys),
	.address_b(dn_addr[10:0]),
	.wren_b(chrom_wr),
	.data_b(dn_data),
	.q_b()
);

// Work RAM - 0x8000 - 0xBFFF (0x4000 / 16384 bytes)
spram #(14,8) wkram
(
	.clock(clk_sys),
	.address(cpu_addr[13:0]),
	.wren(!cpu_wr_n && wkram_cs),
	.data(cpu_dout),
	.q(wkram_data_out)
);

// Char RAM - 0xC000 - 0xDFFF (0x2000 / 8192 bytes)
dpram #(13,8) chram
(
	.clock_a(clk_sys),
	.address_a(cpu_addr[12:0]),
	.wren_a(!cpu_wr_n && chram_cs),
	.data_a(cpu_dout),
	.q_a(chram_data_out),

	.clock_b(clk_sys),
	.address_b(),
	.wren_b(1'b0),
	.data_b(),
	.q_b()
);


endmodule
