`timescale 1ns / 1ps
module sync_delay (
    input  logic       clk,
    input  logic       reset,
    input  logic       DE_in,
    input  logic [9:0] x_in,
    input  logic [9:0] y_in,
    input  logic       h_sync_in,
    input  logic       v_sync_in,
    output logic       DE_out,
    output logic [9:0] x_out,
    output logic [9:0] y_out,
    output logic       h_sync_out,
    output logic       v_sync_out
);

    always_ff @(posedge clk) begin
        if (reset) begin
            DE_out     <= 1'b0;
            x_out      <= 0;
            y_out      <= 0;
            h_sync_out <= 1'b0;
            v_sync_out <= 1'b0;
        end else begin
            DE_out     <= DE_in;
            x_out      <= x_in;
            y_out      <= y_in;
            h_sync_out <= h_sync_in;
            v_sync_out <= v_sync_in;
        end
    end

endmodule
