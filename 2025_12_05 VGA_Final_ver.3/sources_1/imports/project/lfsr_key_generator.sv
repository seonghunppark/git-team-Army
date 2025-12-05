`timescale 1ns / 1ps

module lfsr_key_generator (
    input logic clk,       
    input logic rising,   
    output logic [11:0] key_stream 
);

    logic [11:0] lfsr;

    logic feedback_bit;
    assign feedback_bit = lfsr[11] ^ lfsr[5] ^ lfsr[3] ^ lfsr[0];

    
    always_ff @(posedge clk, posedge rising) begin
        if (rising) begin
            lfsr <= 12'b1100_1100_1100;
        end else begin

            lfsr <= {feedback_bit, lfsr[11:1]};
        end
    end

    assign key_stream = lfsr;

endmodule