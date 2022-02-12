/*  This file is part of JTFRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 6-12-2019 */

// Input clock must be 24 MHz
// Generates various clock enable signals

// Modifed by Jim Gregory - @mrjimmystones to remove redundant signals and add 2Mhz enable

`timescale 1ps / 1ps

module jtframe_cen24(
    input   clk,    // 24 MHz
    output  reg cen12,
    output  reg cen6,
    output  reg cen2
);

reg [3:0] cencnt =4'd0;
reg [3:0] cencnt2=4'd0;

always @(posedge clk) begin
    cencnt  <= cencnt+4'd1;
    cencnt2 <= cencnt2==4'd12 ? 4'd0 : (cencnt2+4'd1);
end

always @(posedge clk) begin
    cen12  <= cencnt[0] == 1'd0;
    cen6   <= cencnt[1:0] == 2'd0;
    cen2   <= cencnt2 == 4'd0;
end
endmodule