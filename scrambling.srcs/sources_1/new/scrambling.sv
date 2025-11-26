`timescale 1ns / 1ps

module scrambling(
    input logic [11:0] code,
    input logic [11:0] data,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port
    );
    logic [11:0] scram;
    assign scram = (data^12'b1100_1100_1100)^code;
    assign red_port = scram[11:8];
    assign green_port = scram[7:4];
    assign blue_port = scram[3:0];
endmodule
