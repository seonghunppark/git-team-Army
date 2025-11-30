`timescale 1ns / 1ps

// module Slave_TOP_t (
//     input  logic        clk,
//     input  logic        reset,
//     input  logic [11:0] data,
//     input  logic        i_hsync,
//     input  logic        i_vsync,
//     input  logic        DE,
//     output logic [ 3:0] red_port,
//     output logic [ 3:0] green_port,
//     output logic [ 3:0] blue_port,
//     output logic        o_hsync,
//     output logic        o_vsync
// );

//     always_ff @(posedge clk, posedge reset) begin
//         if (reset) begin
//             red_port   <= 0;
//             green_port <= 0;
//             blue_port  <= 0;
//         end else begin
//             if (DE) begin
//                 red_port   <= {data[11:8]};
//                 green_port <= {data[7:4]};
//                 blue_port  <= {data[3:0]};
//             end else begin
//                 red_port   <= 0;
//                 green_port <= 0;
//                 blue_port  <= 0;
//             end
//         end

//     end

//     assign o_hsync = i_hsync;
//     assign o_vsync = i_vsync;

// endmodule


module Slave_TOP (
    input logic clk,
    input logic [11:0] data,
    input logic reset,
    input logic i_href,
    input logic i_vsync,
    input logic pclk,
    output logic [3:0] red_port,
    output logic [3:0] green_port,
    output logic [3:0] blue_port,
    output logic href,
    output logic vsync,
    input logic reset_c,
    output logic rising,
    input logic [11:0] code
);

    logic reset_c_1,reset_c_2;
    logic [11:0] code_key;
    logic [11:0] scrambled_data;
    lfsr_code_generator_s U_CODE_GENS (
        .clk(pclk),
        .rising(rising),
        .code(code),
        .code_key(code_key)
    );
    assign href = i_href;
    assign vsync = i_vsync;

    assign scrambled_data = data ^ code_key;
    assign rising = reset_c_1 & ~reset_c_2;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            reset_c_1 <= 0;
            reset_c_2 <=0;
        end else begin
            reset_c_1 <= reset_c;
            reset_c_2 <= reset_c_1;
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
