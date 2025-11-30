`timescale 1ns / 1ps

module Slave_TOP (
    input  logic        clk,         // Slave 내부 clk:100Mhz
    input  logic [11:0] data,
    input  logic        reset,
    input  logic        i_href,
    input  logic        i_vsync,
    input  logic        pclk,        // Master가 보내주는 pclk
    output logic [ 3:0] red_port,
    output logic [ 3:0] green_port,
    output logic [ 3:0] blue_port,
    output logic        href,
    output logic        vsync,
    input  logic        reset_c,
    output logic        rising,
    input  logic [11:0] code
);

    logic reset_c_1, reset_c_2;
    logic [11:0] code_key;
    logic [11:0] scrambled_data;
    logic reset_sync_reg1;
    logic reset_sync_reg2;
    

    lfsr_code_generator_s U_CODE_GENS (
        .clk     (pclk),
        .rising  (rising),
        .code    (code),
        .code_key(code_key)
    );
    assign href = i_href;
    assign vsync = i_vsync;

    assign scrambled_data = data ^ code_key;
    assign rising_1 = reset_c_1 & ~reset_c_2;
    assign rising = reset_sync_reg2;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            reset_c_1 <= 0;
            reset_c_2 <= 0;
        end else begin
            reset_c_1 <= reset_c;
            reset_c_2 <= reset_c_1;
        end
    end

    always_ff @(posedge pclk, posedge rising_1) begin
        if (rising_1) begin
            reset_sync_reg1 <= 1'b1;
            reset_sync_reg2 <= 1'b1;
        end else begin
            reset_sync_reg1 <= 1'b0;
            reset_sync_reg2 <= reset_sync_reg1;
        end
    end



    assign red_port   = scrambled_data[11:8];
    assign green_port = scrambled_data[7:4];
    assign blue_port  = scrambled_data[3:0];


endmodule

module lfsr_code_generator_s (
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
