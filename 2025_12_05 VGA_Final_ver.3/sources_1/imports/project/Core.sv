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
    output logic [                  3:0] b_port,
    input  logic                         shot_btn
);

    logic motion_flag;
    logic motion_valid;
    logic [9:0] com_x;
    logic [9:0] com_y;
    logic [9:0] shot_x;
    logic [9:0] shot_x1;
    logic [9:0] shot_x2;
    logic [9:0] shot_x3;
    logic [9:0] shot_x4;
    logic [9:0] shot_x5;
    logic [9:0] shot_y;
    logic [9:0] shot_y1;
    logic [9:0] shot_y2;
    logic [9:0] shot_y3;
    logic [9:0] shot_y4;
    logic [9:0] shot_y5;
    logic shot_trigger;
    logic shot_trigger1;
    logic shot_trigger2;
    logic shot_trigger3;
    logic shot_trigger4;
    logic shot_trigger5;


    motion_display U_MOTION_DISPLAY (
        .motion_flag  (motion_flag),
        .motion_valid (motion_valid),
        .com_x        (com_x),
        .com_y        (com_y),
        .DE           (DE),
        .x_pixel      (x_pixel),
        .y_pixel      (y_pixel),
        .addr         (addr),
        .imgData      (curr_data),
        .r_port       (r_port),
        .g_port       (g_port),
        .b_port       (b_port),
        .shot_x       (shot_x),
        .shot_x1      (shot_x1),
        .shot_x2      (shot_x2),
        .shot_x3      (shot_x3),
        .shot_x4      (shot_x4),
        .shot_x5      (shot_x5),
        .shot_y       (shot_y),
        .shot_y1      (shot_y1),
        .shot_y2      (shot_y2),
        .shot_y3      (shot_y3),
        .shot_y4      (shot_y4),
        .shot_y5      (shot_y5),
        .shot_trigger (shot_trigger),
        .shot_trigger1(shot_trigger1),
        .shot_trigger2(shot_trigger2),
        .shot_trigger3(shot_trigger3),
        .shot_trigger4(shot_trigger4),
        .shot_trigger5(shot_trigger5)
    );


    motion_coordinate U_MOTION_COORDINATE (
        .clk          (clk),
        .reset        (reset),
        .DE           (DE),
        .x_pixel      (x_pixel),
        .y_pixel      (y_pixel),
        .motion_flag  (motion_flag),
        .motion_valid (motion_valid),
        .com_x        (com_x),
        .com_y        (com_y),
        .shot_btn     (shot_btn),
        .shot_x       (shot_x),
        .shot_x1      (shot_x1),
        .shot_x2      (shot_x2),
        .shot_x3      (shot_x3),
        .shot_x4      (shot_x4),
        .shot_x5      (shot_x5),
        .shot_y       (shot_y),
        .shot_y1      (shot_y1),
        .shot_y2      (shot_y2),
        .shot_y3      (shot_y3),
        .shot_y4      (shot_y4),
        .shot_y5      (shot_y5),
        .shot_trigger (shot_trigger),
        .shot_trigger1(shot_trigger1),
        .shot_trigger2(shot_trigger2),
        .shot_trigger3(shot_trigger3),
        .shot_trigger4(shot_trigger4),
        .shot_trigger5(shot_trigger5)
    );

    motion_compare #(
        .THRESHOLD(THRESHOLD)
    ) U_MOTION_COMPARE (
        .prev_data  (prev_data),
        .curr_data  (curr_data),
        .motion_flag(motion_flag)
    );

endmodule
