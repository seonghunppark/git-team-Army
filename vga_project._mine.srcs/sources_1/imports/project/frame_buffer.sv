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

    logic [15:0] gray_data;
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

    gray_filter U_GRAY_FILTER (
        .data     (wData),
        .gray_data(gray_data)
    );

    frame_buffer U_FB0 (
        .wclk (wclk),
        .we   (we && (buffer_sel == 1'b0)),
        .wAddr(wAddr),
        .wData(gray_data),
        .rclk (rclk),
        .oe   (oe),
        .rAddr(rAddr),
        .rData(rData0)
    );

    frame_buffer U_FB1 (
        .wclk (wclk),
        .we   (we&& (buffer_sel == 1'b1)),
        .wAddr(wAddr),
        .wData(gray_data),
        .rclk (rclk),
        .oe   (oe),
        .rAddr(rAddr),
        .rData(rData1)
    );

endmodule

module gray_filter (
    input  logic [15:0] data,
    output logic [15:0] gray_data
);

    logic [7:0] red, green, blue, gray;
    logic [15:0] R_gray, G_gray, B_gray, sum;

    always_comb begin
        red = {data[15:11], 3'b000};
        green = {data[10:5], 2'b00};
        blue = {data[4:0], 3'b000};

        R_gray = (red << 5) + (red << 4) + (red << 1) + red;
        G_gray = (green << 7) + (green << 5) + (green << 4) + (green << 1) + green;
        B_gray = (blue << 4) + (blue << 3) + (blue << 1);
        sum = R_gray + G_gray + B_gray;
        gray = sum[15:8];

        gray_data[15:11] = gray[7:3];
        gray_data[10:5] = gray[7:2];
        gray_data[4:0] = gray[7:3];
    end
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
        if (oe) rData <= mem[rAddr];
    end

endmodule
