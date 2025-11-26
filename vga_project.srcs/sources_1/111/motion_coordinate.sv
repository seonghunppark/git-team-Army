`timescale 1ns / 1ps



module motion_display (
    input  logic                         motion_flag,
    input  logic                         DE,
    input  logic [                  9:0] x_pixel,
    input  logic [                  9:0] y_pixel,
    output logic [$clog2(160*120)-1 : 0] addr,
    input  logic [                 15:0] imgData,
    output logic [                  3:0] r_port,
    output logic [                  3:0] g_port,
    output logic [                  3:0] b_port
);
    logic img_display_en;

    assign img_display_en = DE && (x_pixel < 160) && (y_pixel < 120);
    assign addr = img_display_en ? (160 * y_pixel + x_pixel) : 'bz;

    assign r_port = img_display_en ? (motion_flag ? imgData[15:12] + 4'd3 : imgData[15:12]) : 0;
    assign g_port = img_display_en ? imgData[10:7] : 0;
    assign b_port = img_display_en ? imgData[4:1] : 0;

endmodule









module motion_coordinate (
    // global signals
    input logic       clk,
    input logic       reset,
    // VGA
    input logic       DE,
    input logic       h_sync,
    input logic       v_sync,
    input logic [9:0] x_pixel,
    input logic [9:0] y_pixel,
    // internal
    input logic       motion_flag
    // output

);

endmodule
