`timescale 1ns / 1ps

module Core #(
    parameter THRESHOLD = 8'd10
) (
    // global signals
    input  logic                         clk,
    input  logic                         reset,
    // buffer
    input  logic [                 15:0] prev_data,
    input  logic [                 15:0] curr_data,
    // VGA
    input  logic                         DE,
    input  logic [                  9:0] x_pixel,
    input  logic [                  9:0] y_pixel,
    output logic [$clog2(160*120)-1 : 0] addr,
    // output
    output logic [                  3:0] r_port,
    output logic [                  3:0] g_port,
    output logic [                  3:0] b_port
);

    logic motion_flag;
    logic motion_valid;
    logic [9:0] com_x;
    logic [9:0] com_y;

    motion_display U_MOTION_DISPLAY (
        .motion_flag (motion_flag),
        .motion_valid(motion_valid),
        .com_x       (com_x),
        .com_y       (com_y),
        .DE          (DE),
        .x_pixel     (x_pixel),
        .y_pixel     (y_pixel),
        .addr        (addr),
        .imgData     (curr_data),
        .r_port      (r_port),
        .g_port      (g_port),
        .b_port      (b_port)
    );

    motion_coordinate U_MOTION_COORDINATE (
        .clk         (clk),
        .reset       (reset),
        .DE          (DE),
        .x_pixel     (x_pixel),
        .y_pixel     (y_pixel),
        .motion_flag (motion_flag),
        .motion_valid(motion_valid),
        .com_x       (com_x),
        .com_y       (com_y)
    );

    motion_compare #(
        .THRESHOLD(THRESHOLD)
    ) U_MOTION_COMPARE (
        .prev_data  (prev_data),
        .curr_data  (curr_data),
        .motion_flag(motion_flag)
    );

endmodule
