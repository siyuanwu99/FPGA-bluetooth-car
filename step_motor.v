`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/13 17:00:52
// Design Name: 
// Module Name: step_motor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module step_motor(speed, StepDrive, clk, Dir, StepEnable, rst);
  input clk;         // system clk
  input Dir;        // direction which motor moves
  input StepEnable; 
  input rst;
  input [3:0] speed; 
  output    [3:0]   StepDrive;   
  reg       [3:0]   StepDrive=4'b0000;
  reg       [2:0]   state=3'b000; 
  reg       [31:0]  StepCounter = 32'b0; 
  reg       [31:0]   StepLockOut = 32'd100000;             //250HZ
  reg 				InternalStepEnable = 1'b0; 

    always @(*) begin
      case(speed)
        4'd0:StepLockOut = 32'd333333; //300Hz
        4'd1:StepLockOut = 32'd285714; //350Hz
        4'd2:StepLockOut = 32'd250000; //400Hz
        4'd3:StepLockOut = 32'd222222; //450Hz
        4'd4:StepLockOut = 32'd200000; //500Hz
        4'd5:StepLockOut = 32'd181818; //550Hz
        4'd6:StepLockOut = 32'd166666; //600Hz
        4'd7:StepLockOut = 32'd153846; //650Hz
        default: StepLockOut = 32'd400000; // 250Hz
      endcase
    end

	always @(*) begin
		case (state)
			3'b000 :    StepDrive <= 4'b1000 ; 
			3'b001 :    StepDrive <= 4'b1010 ; 
			3'b010 :    StepDrive <= 4'b0010 ; 
			3'b011 :    StepDrive <= 4'b0110 ; 
			3'b100 :    StepDrive <= 4'b0100 ; 
			3'b101 :    StepDrive <= 4'b0101 ; 
			3'b110 :    StepDrive <= 4'b0001 ; 
			3'b111 :    StepDrive <= 4'b1001 ;  
			default:	StepDrive <= 4'b0000;
		endcase 
	end

	always @ (posedge clk or negedge rst) begin
	if (!rst) begin
		StepDrive <= 4'b0;
		state <= 3'b0;
		StepCounter <= 32'b0;
	end
	else begin
		StepCounter <= StepCounter + 1'b1;
		if (StepEnable == 1'b1 && StepCounter >= StepLockOut) begin
			StepCounter <= 32'b0;
			if (Dir == 1'b1)
				state <= state + 3'b001 ; 
			else if (Dir == 1'b0)
				state <= state - 3'b001 ; 
		end
	end


	end
endmodule