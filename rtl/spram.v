module spram #(
	parameter address_width = 10,
	parameter data_width = 8
) (
	input	wire						clock,
	input	wire						wren,
	input	wire	[address_width-1:0]	address,
	input	wire	[data_width-1:0]	data,
	output	reg		[data_width-1:0]	q
);
 
localparam ramLength = (2**address_width);
reg [data_width-1:0] mem [ramLength-1:0];

// `ifdef SIMULATION
// 	integer j;
// 	initial
// 	begin
// 		for (j = 0; j < ramLength; j = j + 1)
// 		begin
// 			mem[j] = 0;
// 		end
// 	end
// `endif

always @(posedge clock) begin
	q <= mem[address];
	if(wren) begin
		q <= data;
		mem[address] <= data;
	end
end

endmodule