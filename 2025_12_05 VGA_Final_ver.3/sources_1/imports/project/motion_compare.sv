`timescale 1ns / 1ps

module motion_compare #(
    parameter THRESHOLD = 8'd10
) (
    input  logic [15:0] prev_data,
    input  logic [15:0] curr_data,
    output logic        motion_flag
);


    logic [15:0] prev_gray;
    logic [15:0] curr_gray;
    logic [ 7:0] prev_gray_8bit;
    logic [ 7:0] curr_gray_8bit;

    logic [ 7:0] diff;

    always_comb begin
        // green data
        prev_gray_8bit = {prev_gray[10:5], 2'b00};
        curr_gray_8bit = {curr_gray[10:5], 2'b00};

        // |curr_data - prev_data|
        if (prev_gray_8bit > curr_gray_8bit)
            diff = prev_gray_8bit - curr_gray_8bit;
        else diff = curr_gray_8bit - prev_gray_8bit;

        // motion_flag
        motion_flag = (diff > THRESHOLD);
    end

    gray_filter U_PREV_GRAY (
        .data     (prev_data),
        .gray_data(prev_gray)
    );

    gray_filter U_CURR_GRAY (
        .data     (curr_data),
        .gray_data(curr_gray)
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


