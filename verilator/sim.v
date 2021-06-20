`timescale 1ns / 1ps
//
// top end ff for verilator
//

//`define sdl_display
`define USE_VGA
//`define USE_CGA

module top(VGA_R,VGA_B,VGA_G,VGA_HS,VGA_VS,VGA_HB,VGA_VB,reset,clk_sys,clk_vid,inputs,ioctl_download,ioctl_addr,ioctl_dout,ioctl_index,ioctl_wait,ioctl_wr);

   input clk_sys/*verilator public_flat*/;
   input clk_vid/*verilator public_flat*/;
   input reset/*verilator public_flat*/;
   input [11:0]  inputs/*verilator public_flat*/;

   output [7:0] VGA_R/*verilator public_flat*/;
   output [7:0] VGA_G/*verilator public_flat*/;
   output [7:0] VGA_B/*verilator public_flat*/;
   
   output VGA_HS;
   output VGA_VS;
   
   output VGA_HB;
   output VGA_VB;
   
   input        ioctl_download;
   input        ioctl_wr;
   input [24:0] ioctl_addr;
   input [7:0] ioctl_dout;
   input [7:0]  ioctl_index;
   output  reg     ioctl_wait=1'b0;
   
      wire btn_start = inputs[6];
   wire btn_coin = inputs[8];
   wire m_bomb = inputs[5];
   wire m_fire = inputs[4];
   wire m_right = inputs[0];
   wire m_left = inputs[1];
   wire m_down = inputs[2];
   wire m_up = inputs[3];

wire VGA_DE;
soc soc(
   .clk_sys(clk_sys),
   .clk_pix(clk_sys),
   .VGA_HS(VGA_HS),
   .VGA_VS(VGA_VS),
   .VGA_R(VGA_R),
   .VGA_G(VGA_G),
   .VGA_B(VGA_B),
   .VGA_HB(VGA_HB),
   .VGA_VB(VGA_VB),
   .VGA_DE(VGA_DE),
   .dn_addr(ioctl_addr[13:0]),
   .dn_data(ioctl_dout),
   .dn_wr(ioctl_wr),
   .inputs({btn_coin, btn_start, m_bomb, m_fire, m_right, m_left, m_down, m_up})
);

endmodule 

