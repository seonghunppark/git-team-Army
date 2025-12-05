`timescale 1ns / 1ps

module OV7670_Mem_Controller #(
    parameter H_PIXELS   = 160,                 //QQVGA      
    parameter V_PIXELS   = 120,                 //QQVGA      
    parameter FRAME_SIZE = H_PIXELS * V_PIXELS
) (
    input  logic                            clk,
    input  logic                            reset,
    // OV7670 side
    input  logic                            href,
    input  logic                            vsync,
    input  logic [                     7:0] data,
    // memory side
    output logic                            we,
    output logic [$clog2(FRAME_SIZE) - 1:0] wAddr,
    output logic [                    15:0] wData,
    output logic                            buffer_sel
);

    logic        byte_sel;
    logic [15:0] pixelData;
    logic        vsync_d;

    assign wData = pixelData;

    // buffer_sel
    always_ff @(posedge clk, posedge reset) begin
        if (reset) vsync_d <= 1'b0;
        else vsync_d <= vsync;
    end

    wire frame_start = (~vsync_d && vsync);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            buffer_sel <= 1'b0;
        end else if (frame_start) begin
            buffer_sel <= ~buffer_sel;
        end
    end

    // data
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            byte_sel  <= 0;
            pixelData <= 0;
            we        <= 1'b0;
            wAddr     <= 0;
        end else begin
            if (href) begin
                if (byte_sel == 1'b0) begin
                    pixelData[15:8] <= data;
                    we              <= 1'b0;
                    byte_sel        <= 1'b1;
                end else begin
                    we             <= 1'b1;
                    pixelData[7:0] <= data;
                    wAddr          <= wAddr + 1;
                    byte_sel       <= 1'b0;
                end
            end else if (vsync) begin
                we       <= 1'b0;
                byte_sel <= 0;
                wAddr    <= 0;
            end
        end
    end
endmodule
