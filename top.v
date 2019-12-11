`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/13 17:00:19
// Design Name: 
// Module Name: top
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

module motor_control(
input clk,
input rst,
input   [15:0]      command,
output  [15:0]      StepDrive
);
reg [1:0]   Motor1; // motor control signal {enable, direction}
reg [1:0]   Motor2;
reg [1:0]   Motor3;
reg [1:0]   Motor4;
reg [3:0]   Speed_left; // speed 0 ~ 9
reg [3:0]   Speed_right;
wire [3:0]   MotorDrive1, MotorDrive2, MotorDrive3, MotorDrive4;


always @ (*)
{Motor1, Motor2, Motor3, Motor4, Speed_left, Speed_right} = command;

step_motor drive_1(
    .clk(clk),
    .Dir(Motor1[0]),
    .StepEnable(Motor1[1]),
    .rst(rst),
    .StepDrive(MotorDrive1),
    .speed(Speed_left)
);

step_motor drive_2(
    .clk(clk),
    .Dir(Motor2[0]),
    .StepEnable(Motor2[1]),
    .rst(rst),
    .StepDrive(MotorDrive2),
    .speed(Speed_right)
);

step_motor drive_3(
    .clk(clk),
    .Dir(Motor3[0]),
    .StepEnable(Motor3[1]),
    .rst(rst),
    .StepDrive(MotorDrive3),
    .speed(Speed_left)
);

step_motor drive_4(
    .clk(clk),
    .Dir(Motor4[0]),
    .StepEnable(Motor4[1]),
    .rst(rst),
    .StepDrive(MotorDrive4),
    .speed(Speed_right)
);

assign StepDrive = {MotorDrive1, MotorDrive2, MotorDrive3, MotorDrive4};

endmodule
