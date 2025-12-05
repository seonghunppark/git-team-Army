`timescale 1ns / 1ps

module buffer (
    // write side
    input  logic                         wclk,
    input  logic                         we,
    input  logic [$clog2(160*120) - 1:0] wAddr,
    input  logic [                 15:0] wData,
    input  logic                         buffer_sel,
    // read side
    input  logic                         rclk,
    input  logic                         oe,
    input  logic [$clog2(160*120) - 1:0] rAddr,
    output logic [                 15:0] prev_data,
    output logic [                 15:0] curr_data
);

    logic [15:0] rData0, rData1;

    // CDC
    logic buf_sel_d, buf_sel_q;

    always_ff @(posedge rclk) begin
        buf_sel_d <= buffer_sel;
        buf_sel_q <= buf_sel_d;
    end

    // buffer sel값에 따른 curr_data, prev_data 출력 구분
    assign curr_data = (buf_sel_q == 1'b0) ? rData0 : rData1;
    assign prev_data = (buf_sel_q == 1'b0) ? rData1 : rData0;

    frame_buffer U_FB0 (
        .wclk (wclk),
        .we   (we && (buffer_sel == 1'b0)),
        .wAddr(wAddr),
        .wData(wData),
        .rclk (rclk),
        .oe   (oe),
        .rAddr(rAddr),
        .rData(rData0)
    );

    frame_buffer U_FB1 (
        .wclk (wclk),
        .we   (we&& (buffer_sel == 1'b1)),
        .wAddr(wAddr),
        .wData(wData),
        .rclk (rclk),
        .oe   (oe),
        .rAddr(rAddr),
        .rData(rData1)
    );

endmodule

module frame_buffer (
    // write side
    input  logic                         wclk,
    input  logic                         we,
    input  logic [$clog2(160*120) - 1:0] wAddr,
    input  logic [                 15:0] wData,
    // read side
    input  logic                         rclk,
    input  logic                         oe,
    input  logic [$clog2(160*120) - 1:0] rAddr,
    output logic [                 15:0] rData
);

    logic [15:0] mem[0:(160*120)-1];

    // write side
    always_ff @(posedge wclk) begin
        if (we) mem[wAddr] <= wData;
    end

    //read side
    always_ff @(posedge rclk) begin
        if (oe) begin
            if (rAddr % 160 == 0) begin
                rData <= 16'b0;
            end else begin
                rData <= mem[rAddr];
            end
        end
    end
endmodule
