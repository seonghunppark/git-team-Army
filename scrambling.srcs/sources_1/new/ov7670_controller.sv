`timescale 1ns / 1ps

module ov7670_controller (
    input logic pclk,
    input logic reset,
    // ov7670 side
    input logic href,
    input logic vsync,
    input logic [7:0] data,
    // memory side
    output logic we,
    output logic [16:0] waddr,
    output logic [15:0] wdata
);
    logic [16:0] pixelcounter;
    logic [15:0] pixpeldata;


    assign wdata = pixpeldata;

    always_ff @(posedge pclk) begin : blockName
        if (reset) begin
            pixelcounter <= 0;
            pixpeldata <= 0;
            we <= 1'b0;
            waddr <= 0;
        end else begin
            if (href) begin
                if (pixelcounter[0] == 1'b0) begin
                    pixpeldata[15:8] <= data;
                    we <= 1'b0;
                end else begin
                    pixpeldata[7:0] <= data;
                    we <= 1'b1;
                    waddr <= waddr + 1;
                end
                pixelcounter <= pixelcounter + 1;
            end else if (vsync) begin
                pixelcounter <= 0;
                we = 1'b0;
                waddr <= 0;
            end
        end
    end
endmodule
