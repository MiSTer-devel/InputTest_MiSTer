/*============================================================================
	Aznable (custom 8-bit computer system) - Moroboshi (starfield)

	Author: Jim Gregory - https://github.com/JimmyStones/
	Version: 1.0
	Date: 2021-11-06

    Based on Project F: Ad Astra - Starfield
    (C)2021 Will Green, open source hardware released under the MIT License
    Learn more at https://projectf.io

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

`default_nettype none
`timescale 1ns / 1ps

module starfield #(
    parameter [LEN-1:0] H=800,
    parameter [LEN-1:0] V=525,
    parameter LEN=25,
    parameter TAPS=25'b1010000000000000000000000,
    parameter SEED=25'b1111111111111110000000000,
    parameter MASK=25'b1111111111111111111111111
    ) (
    input  wire         clk,
    input  wire         en,
    input  wire         pause,
    input  wire         rst,
    input  wire         vblank,
    input  wire [2:0]   addr,   // Write address - 0 = enable, 1 = horizontal direction + speed msbs, 2 = horizontal speed lsbs, 3 = vertical direction + speed msbs, 4 = vertical speed lsbs
    input  wire [7:0]   data_in,
    input  wire         write,
    output wire         sf_on,  // star on (alpha)
    output wire [7:0]   sf_star // star brightness
    );

    reg     [LEN-1:0] RST_CNT;  // counter starts at zero, so sub 1
    reg     [LEN-1:0] seed;
    reg               enabled;

    reg               vdirection;
    reg         [14:0] vspeed_set;
    reg          [7:0] vincrement;
    reg         [15:0] vtimer;
    wire        [14:0] vspeed_actual = pause ? 15'b0 : vspeed_set;

    reg               hdirection;
    reg         [14:0] hspeed_set;
    reg          [7:0] hincrement;
    reg         [15:0] htimer;
    wire        [14:0] hspeed_actual = pause ? 15'b0 : hspeed_set;

    wire [LEN-1:0] sf_reg;
    reg  [LEN-1:0] sf_cnt;

    always @(posedge clk) 
    begin

        // Reset seed
        if(rst)
        begin
            seed <= SEED;
            RST_CNT <= (H * V) - 1'b1;
        end

        // CPU write
        if(write)
        begin
            case(addr)
                3'd0: enabled <= data_in[0];
                3'd1: begin hdirection <= data_in[7]; hspeed_set[14:8] <= data_in[6:0]; end
                3'd2: hspeed_set[7:0] <= data_in;
                3'd3: begin vdirection <= data_in[7]; vspeed_set[14:8] <= data_in[6:0]; end
                3'd4: vspeed_set[7:0] <= data_in;
                default:
                begin
                    
                end
            endcase
        end

        if (en)
        begin
            sf_cnt <= sf_cnt + 1'b1;
            
            if(sf_cnt == RST_CNT)
            begin
                
                htimer = htimer + hspeed_actual;
                hincrement = 8'b0;
                if(htimer >= 16'hFF)
                begin
                    hincrement = htimer[15:8] > 8'b0 ? htimer[15:8] : 8'b1;
                    htimer = htimer - {hincrement[7:0], 8'b0};
                end
                vtimer = vtimer + vspeed_actual;
                vincrement = 8'b0;
                if(vtimer >= 16'hFF)
                begin
                    vincrement = vtimer[15:8] > 8'b0 ? vtimer[15:8] : 8'b1;
                    vtimer = vtimer - {vincrement[7:0], 8'b0};
                end

                /* verilator lint_off WIDTH */
                if(pause)
                    RST_CNT <= (H * V) - 1'b1;
                else
                    RST_CNT <= (H * (vdirection ? V + vincrement : V - vincrement)) + (hdirection ? hincrement : -hincrement) - 1'b1;
            
                /* verilator lint_on WIDTH */
                sf_cnt <= 0;
            end
        end
        if (rst) sf_cnt <= 0;
    end

    assign sf_on = &{sf_reg | MASK} & enabled;
    assign sf_star = sf_reg[7:0];

    lfsr #(
        .LEN(LEN),
        .TAPS(TAPS)
        ) lsfr_sf (
        .clk(clk),
        .rst(sf_cnt == {LEN{1'b0}} ),
        .en(en),
        .seed(seed),
        .sreg(sf_reg)
    );
endmodule