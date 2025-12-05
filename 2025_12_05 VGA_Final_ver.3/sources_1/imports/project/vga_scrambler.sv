`timescale 1ns / 1ps
module vga_scrambler (
    input  logic        clk,
    input  logic [11:0] code,
    input  logic [11:0] data_in,
    output logic [ 3:0] red_port,
    output logic [ 3:0] green_port,
    output logic [ 3:0] blue_port,
    /// From Slave
    input  logic        rising_edge

);

    logic [11:0] key_stream;
    logic [11:0] code_key;
    lfsr_key_generator key_gen (
        .clk       (clk),
        .rising    (rising_edge),
        .key_stream(key_stream)
    );

    lfsr_code_generator U_CODE_GEN (
        .clk     (clk),
        .rising  (rising_edge),
        .code    (code),
        .code_key(code_key)
    );


    logic [11:0] scrambled_data;
    assign scrambled_data = (data_in ^ key_stream) ^ code_key;


    assign red_port = scrambled_data[11:8];
    assign green_port = scrambled_data[7:4];
    assign blue_port = scrambled_data[3:0];

endmodule

module lfsr_code_generator (
    input logic clk,
    input logic rising,
    input logic [11:0] code,
    output logic [11:0] code_key
);

    logic [11:0] lfsr;
    logic feedback_bit;

    assign feedback_bit = lfsr[11] ^ lfsr[5] ^ lfsr[3] ^ lfsr[0];

    always_ff @(posedge clk, posedge rising) begin
        if (rising) begin
            lfsr <= code;
        end else begin
            lfsr <= {feedback_bit, lfsr[11:1]};
        end
    end

    assign code_key = lfsr;

endmodule
