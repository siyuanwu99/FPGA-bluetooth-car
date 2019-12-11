`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/30 10:02:55
// Design Name: 
// Module Name: bt_decoder
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
// rules for 16-bit code
// 
// [pattern, speed, time]
// pattern: a: move forward; b: backward; 
//          c: trun left, d: turn right;
// speed: 0~10
// time: 0~10 -> 0~5s
// 
// rules for car command
//  1 2
//  3 4
// {[EnableMotor1, DirectionMotor1], [EnableMotor2, DirectionMotor2],
//  [EnableMotor3, DirectionMotor3], [EnableMotor4, DirectionMotor4],
//  [speed [3:0]],:250Hz~500Hz
//  [time[3:0]}: 0~8s
//////////////////////////////////////////////////////////////////////////////////


module bt_decoder(
    input           clk,
    input           rst,
    input           switch,
    input   [15:0]  input_data, // 16-bit input data from bluetooth module
    output  [15:0]  car_cmd
    );

    reg [3:0]   state;
    reg [1:0]   motor1;
    reg [1:0]   motor2;  
    reg [1:0]   motor3;  
    reg [1:0]   motor4;  
    reg [3:0]   speed_left;      // 0~10
    reg [3:0]   speed_right;
    reg [3:0]   Time; //0~5s
    // reg [15:0]  car_cmd_register;

    always @(*) begin
    if (!rst) begin
        state <= 4'b0;
        Time <= 4'h0;
    end
    else begin
        state <= input_data[15:12];
        Time <= input_data[7:4];        
    end
    end
    
    always @(*) begin
    if (!rst) begin
        speed_left = 4'b0;
        speed_right = 4'h0;
    end
    else 
    case (state)
        4'ha: begin
            speed_left <= input_data[11:8];
            speed_right <= input_data[11:8];
        end
        4'hb: begin
            speed_left <= input_data[11:8];
            speed_right <= input_data[11:8];  
        end
        4'hc: begin
            speed_left <= 4'd3;
            speed_right <= 4'd7;//input_data[11:8];  
            end
        4'hd: begin
            speed_left <= 4'd7;//input_data[11:8];
            speed_right <= 4'd3;
            end
        endcase
    end

    always @(posedge clk or negedge rst) begin
    if (!rst || ~switch) begin
        motor1 <= 2'b00;
        motor2 <= 2'b00;
        motor3 <= 2'b00;
        motor4 <= 2'b00;
    end
    case (state)
        4'ha: begin //move forward
            motor1 <= 2'b11;
            motor2 <= 2'b10;
            motor3 <= 2'b11;
            motor4 <= 2'b10;
            end 
        4'hb: begin // move backward
            motor1 <= 2'b10;
            motor2 <= 2'b11;
            motor3 <= 2'b10;
            motor4 <= 2'b11;
            end
        4'hc: begin // turn left
            motor1 <= 2'b11;
            motor2 <= 2'b10;
            motor3 <= 2'b11;
            motor4 <= 2'b10;
            end
        4'hd: begin // turn right
            motor1 <= 2'b11;
            motor2 <= 2'b10;
            motor3 <= 2'b11;
            motor4 <= 2'b10;
            end
        default: begin
            motor1 <= 2'b01;
            motor2 <= 2'b01;
            motor3 <= 2'b01;
            motor4 <= 2'b01;
            end
    endcase
    end

    assign car_cmd = {motor1, motor2, motor3, motor4, speed_left, speed_right};



endmodule
