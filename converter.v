`timescale 1ns/1ps

module converter (
	input       clk_rx,
	input       rst_clk_rx,
	input       [31:0] data_in,			//*N10345022

	output  reg [15:0] data_out     // +/- freq time
);
	localparam 
		CIRCLE = 28,        // length of wheels
		DEGREE = 0.9,				// degree per step
		TWO_PI = 360;				// degree 2 $\pi$

reg [9:0] freq;		// 10 bit for frequency
reg direction;		// 1 bit for direction
reg [9:0] velocity;
reg [4:0] lapse;			// 5 bit for time 0.1 ~ 3.2s
reg [19:0] clk_ms;			// ms 100MHz -> 1000Hz
reg flag;
reg rst;			// set all to zero when lapse time is up

always @ (posedge clk_rx)
begin
	if (rst_clk_rx)
		clk_ms <= 0;
	else if (clk_ms < 1000000) begin // 10ms
		clk_ms <= clk_ms + 1;
	end
	else
		clk_ms <= 0;
end

always @ (posedge clk_rx)
	if (rst_clk_rx || rst)
		flag <= 0;
	else if (clk_ms == 1000000 || flag < lapse)
		flag = flag + 1;
	else
		flag = flag;

 // if lapse == flag ,rst all, and wait for another input.
always @ (posedge clk_rx) 
	if (rst_clk_rx)
		rst = 0;
	else if (flag == lapse)
		rst = 1;
	else
		rst = 0;


always @ (posedge clk_rx)
begin
	// convert velocity from 34.5 cm/s to 345 mm/s
	velocity = 100 * data_in[23:20] + 10 * data_in[19:16] + data_in[15:12];
	freq = velocity / 10 / CIRCLE * TWO_PI * DEGREE;		//freq for wheels
	lapse = 10 * data_in[7:4] + data_in[3:0];		//time lasting
	
	// direction for wheels, 1 for move forward, 0 for move backward
	case (data_in[31:28])
		4'b0001: direction <= 1'b1;
		4'b0000: direction <= 1'b0;
		default: direction <= 1'b0;
	endcase
end

always @ (posedge clk_rx)
begin
	if (rst_clk_rx || rst)
		data_out <= 0;
	else
		data_out <= {direction, freq, lapse};
end

endmodule // 