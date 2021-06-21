module dpram #(
	parameter address_width = 10,
	parameter data_width = 8
) (
	input	wire						clock_a,
	input	wire						wren_a,
	input	wire	[address_width-1:0]	address_a,
	input	wire	[data_width-1:0]	data_a,
	output	reg		[data_width-1:0]	q_a,

	input	wire						clock_b,
	input	wire						wren_b,
	input	wire	[address_width-1:0]	address_b,
	input	wire	[data_width-1:0]	data_b,
	output	reg		[data_width-1:0]	q_b
);
 
localparam ramLength = (2**address_width);
reg [data_width-1:0] mem [ramLength-1:0];

`ifdef SIMULATION
	integer j;
	initial
	begin
		for (j = 0; j < ramLength; j = j + 1)
		begin
			mem[j] = 0;
		end
	end
`endif

always @(posedge clock_a) begin
	q_a <= mem[address_a];
	if(wren_a) begin
		q_a <= data_a;
		mem[address_a] <= data_a;
	end
end

always @(posedge clock_b) begin
	q_b <= mem[address_b];
	if(wren_b) begin
		q_b <= data_b;
		mem[address_b] <= data_b;
	end
end

endmodule