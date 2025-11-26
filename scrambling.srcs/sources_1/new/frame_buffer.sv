`timescale 1ns / 1ps

module frame_buffer(
    // write side
    input logic wclk,
    input logic we,
    input logic [16:0]waddr,
    input logic [15:0]wdata,
    // read side
    input logic rclk,
    input logic oe,
    input logic [16:0]raddr,
    output logic [15:0] rdata
    );
    logic [15:0] mem [0:(320*240)-1];
    logic [15:0] old_data [0:(320*240)-1];
    // write side
    always_ff @( posedge wclk ) begin :write_side
        if (we) begin
            mem[waddr] <= wdata;
        end
    end

    // read side
    always_ff @( posedge rclk ) begin : blockName
        if (oe) begin
            rdata <= mem[raddr];
        end
    end
endmodule
