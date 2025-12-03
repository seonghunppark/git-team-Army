`timescale 1ns / 1ps

module motion_display (
    input  logic                         motion_flag,
    input  logic                         motion_valid,
    input  logic [                  9:0] com_x,
    input  logic [                  9:0] com_y,
    input  logic                         DE,
    input  logic [                  9:0] x_pixel,
    input  logic [                  9:0] y_pixel,
    output logic [$clog2(160*120)-1 : 0] addr,
    input  logic [                 15:0] imgData,
    output logic [                  3:0] r_port,
    output logic [                  3:0] g_port,
    output logic [                  3:0] b_port
);
    logic img_display_en;

    int diff_x, diff_y;
    int dist_sq;

    assign img_display_en = DE && (x_pixel < 640) && (y_pixel < 480);
    assign addr = img_display_en ? (160 * y_pixel[9:2] + x_pixel[9:2]) : 1'bz;

    always_comb begin
        diff_x  = (x_pixel > com_x) ? (x_pixel - com_x) : (com_x - x_pixel);
        diff_y  = (y_pixel > com_y) ? (y_pixel - com_y) : (com_y - y_pixel);
        dist_sq = (diff_x * diff_x) + (diff_y * diff_y);

        r_port  = 0;
        g_port  = 0;
        b_port  = 0;

        if (img_display_en) begin
            if ( motion_valid && (((dist_sq >= 64) && (dist_sq <= 169)) || ((diff_x <= 2 || diff_y <= 2) && (dist_sq <= 64)))) begin
                r_port = 4'b1111;
                g_port = 4'b0000;
                b_port = 4'b0;
            end else if (motion_flag) begin // 움직이는 위치 붉게, 필요없다고 판단하면 삭제
                r_port = imgData[15:12] + 4'd3;
                g_port = imgData[10:7];
                b_port = imgData[4:1];
            end else begin
                r_port = imgData[15:12];
                g_port = imgData[10:7];
                b_port = imgData[4:1];
            end
        end else begin
            r_port = 0;
            g_port = 0;
            b_port = 0;
        end
    end

endmodule

module motion_coordinate (
    // global signals
    input  logic       clk,
    input  logic       reset,
    // VGA
    input  logic       DE,
    input  logic [9:0] x_pixel,
    input  logic [9:0] y_pixel,
    // internal
    input  logic       motion_flag,
    // output
    output logic [9:0] com_x,        // center of mass :  (x_pixel, y_pixel)
    output logic [9:0] com_y,        // center of mass :  (x_pixel, y_pixel)
    output logic       motion_valid

);

    // 핵심로직
    // compare module에서 motion flag가 들어오면
    // motion flag 뜰 때의 x_pixel과 y_pixel값을 
    // sum값에 계속 더하고
    // 이때 나누기를 하기 위해서 sum을 몇 번 더했는지 counter값을 같이 세고
    // 픽셀을 전부 세고나면 motion flag가 뜬 pixel의 중심 좌표를 계산하고
    // 그 중심 좌표값을 motion display에 보내서
    // motion display에서 해당 중심 좌표에 원을 띄우게한다.

    logic [31:0] sum_x_reg;
    logic [31:0] sum_x_next;

    logic [31:0] sum_y_reg;
    logic [31:0] sum_y_next;

    logic [31:0] sum_counter_next;
    logic [31:0] sum_counter_reg;

    logic [9:0] com_x_reg;
    logic [9:0] com_x_next;

    logic [9:0] com_y_reg;
    logic [9:0] com_y_next;

    logic motion_valid_reg;
    logic motion_valid_next;

    assign com_x = com_x_reg[9:0];
    assign com_y = com_y_reg[9:0];
    assign motion_valid = motion_valid_reg;

    always_ff @(posedge clk) begin
        if (reset) begin
            sum_x_reg        <= 0;
            sum_y_reg        <= 0;
            sum_counter_reg  <= 0;
            com_x_reg        <= 0;
            com_y_reg        <= 0;
            motion_valid_reg <= 0;
        end else begin
            sum_x_reg        <= sum_x_next;
            sum_y_reg        <= sum_y_next;
            sum_counter_reg  <= sum_counter_next;
            com_x_reg        <= com_x_next;
            com_y_reg        <= com_y_next;
            motion_valid_reg <= motion_valid_next;
        end
    end

    always_comb begin
        sum_counter_next  = sum_counter_reg;
        sum_x_next        = sum_x_reg;
        sum_y_next        = sum_y_reg;
        com_x_next        = com_x_reg;
        com_y_next        = com_y_reg;
        motion_valid_next = motion_valid_reg;
        if (DE & (x_pixel < 640) & (y_pixel < 480)) begin
            if (motion_flag) begin
                sum_x_next       = sum_x_reg + x_pixel;
                sum_y_next       = sum_y_reg + y_pixel;
                sum_counter_next = sum_counter_reg + 1;
            end
        end

        if ((x_pixel == 640) & (y_pixel == 480)) begin
            sum_x_next       = 0;
            sum_y_next       = 0;
            sum_counter_next = 0;
            if (sum_counter_reg > 0) begin
                com_x_next = sum_x_reg / sum_counter_reg;
                com_y_next = sum_y_reg / sum_counter_reg;
                motion_valid_next = 1'b1;
            end else begin
                com_x_next = 0;
                com_y_next = 0;
                motion_valid_next = 1'b0;
            end
        end
    end
endmodule
