`timescale 1ns / 1ps


module Core (
    input logic        clk,
    input logic        reset,
    input logic [15:0] prev_data,
    input logic [15:0] curr_data

);

    logic motion_flag;



    motion_compare #(
        .THRESHOLD(8'd10)
    ) U_MOTION_COMPARE (
        .prev_data  (prev_data),
        .curr_data  (curr_data),
        .motion_flag(motion_flag)
    );




endmodule
