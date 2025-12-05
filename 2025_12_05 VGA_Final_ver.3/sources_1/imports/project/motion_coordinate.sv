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
    output logic [                  3:0] b_port,
    input  logic [                  9:0] shot_x,
    input  logic [                  9:0] shot_x1,
    input  logic [                  9:0] shot_x2,
    input  logic [                  9:0] shot_x3,
    input  logic [                  9:0] shot_x4,
    input  logic [                  9:0] shot_x5,
    input  logic [                  9:0] shot_y,
    input  logic [                  9:0] shot_y1,
    input  logic [                  9:0] shot_y2,
    input  logic [                  9:0] shot_y3,
    input  logic [                  9:0] shot_y4,
    input  logic [                  9:0] shot_y5,
    input  logic                         shot_trigger,
    input  logic                         shot_trigger1,
    input  logic                         shot_trigger2,
    input  logic                         shot_trigger3,
    input  logic                         shot_trigger4,
    input  logic                         shot_trigger5
);
    logic img_display_en;

    int diff_x, diff_y;
    int dist_sq;

    int shot_diff_x;
    int shot_diff_y;
    int shot_dist_sq;

    int shot_diff_x1;
    int shot_diff_y1;
    int shot_dist_sq1;

    int shot_diff_x2;
    int shot_diff_y2;
    int shot_dist_sq2;

    int shot_diff_x3;
    int shot_diff_y3;
    int shot_dist_sq3;

    int shot_diff_x4;
    int shot_diff_y4;
    int shot_dist_sq4;

    int shot_diff_x5;
    int shot_diff_y5;
    int shot_dist_sq5;


    assign img_display_en = DE && (x_pixel < 640) && (y_pixel < 480);
    assign addr = img_display_en ? (160 * y_pixel[9:2] + x_pixel[9:2]) : 1'bz;

    always_comb begin
        diff_x = (x_pixel > com_x) ? (x_pixel - com_x) : (com_x - x_pixel);
        diff_y = (y_pixel > com_y) ? (y_pixel - com_y) : (com_y - y_pixel);
        dist_sq = (diff_x * diff_x) + (diff_y * diff_y);

        shot_diff_x  = (x_pixel > shot_x) ? (x_pixel - shot_x) : (shot_x - x_pixel);
        shot_diff_y  = (y_pixel > shot_y) ? (y_pixel - shot_y) : (shot_y - y_pixel);
        shot_dist_sq = (shot_diff_x * shot_diff_x) + (shot_diff_y * shot_diff_y);

        shot_diff_x1  = (x_pixel > shot_x1) ? (x_pixel - shot_x1) : (shot_x1 - x_pixel);
        shot_diff_y1  = (y_pixel > shot_y1) ? (y_pixel - shot_y1) : (shot_y1 - y_pixel);
        shot_dist_sq1 = (shot_diff_x1 * shot_diff_x1) + (shot_diff_y1 * shot_diff_y1);

        shot_diff_x2  = (x_pixel > shot_x2) ? (x_pixel - shot_x2) : (shot_x2 - x_pixel);
        shot_diff_y2  = (y_pixel > shot_y2) ? (y_pixel - shot_y2) : (shot_y2 - y_pixel);
        shot_dist_sq2 = (shot_diff_x2 * shot_diff_x2) + (shot_diff_y2 * shot_diff_y2);

        shot_diff_x3  = (x_pixel > shot_x3) ? (x_pixel - shot_x3) : (shot_x3 - x_pixel);
        shot_diff_y3  = (y_pixel > shot_y3) ? (y_pixel - shot_y3) : (shot_y3 - y_pixel);
        shot_dist_sq3 = (shot_diff_x3 * shot_diff_x3) + (shot_diff_y3 * shot_diff_y3);

        shot_diff_x4  = (x_pixel > shot_x4) ? (x_pixel - shot_x4) : (shot_x4 - x_pixel);
        shot_diff_y4  = (y_pixel > shot_y4) ? (y_pixel - shot_y4) : (shot_y4 - y_pixel);
        shot_dist_sq4 = (shot_diff_x4 * shot_diff_x4) + (shot_diff_y4 * shot_diff_y4);

        shot_diff_x5  = (x_pixel > shot_x5) ? (x_pixel - shot_x5) : (shot_x5 - x_pixel);
        shot_diff_y5  = (y_pixel > shot_y5) ? (y_pixel - shot_y5) : (shot_y5 - y_pixel);
        shot_dist_sq5 = (shot_diff_x5 * shot_diff_x5) + (shot_diff_y5 * shot_diff_y5);

        r_port = 0;
        g_port = 0;
        b_port = 0;

        if (img_display_en) begin
            if (motion_valid && (((dist_sq >= 256) && (dist_sq <= 400)) || ((diff_x <= 2 || diff_y <= 2) && (dist_sq <= 256)))) begin
                r_port = 4'b1111;
                g_port = 4'b0000;
                b_port = 4'b0;
            end
            else if ((shot_trigger && (shot_dist_sq <= 144)) ||
                (shot_trigger1 && (shot_dist_sq1 <= 144))|| 
                (shot_trigger2 && (shot_dist_sq2 <= 144))||
                (shot_trigger3 && (shot_dist_sq3 <= 144))||
                (shot_trigger4 && (shot_dist_sq4 <= 144))||
                (shot_trigger5 && (shot_dist_sq5 <= 144))) begin
                r_port = 4'd0;
                g_port = 4'd0;
                b_port = 4'd0;
            end
            else if (motion_flag) begin // 움직이는 위치 붉게, 필요없다고 판단하면 삭제
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
    output logic [9:0] com_x,          // center of mass :  (x_pixel, y_pixel)
    output logic [9:0] com_y,          // center of mass :  (x_pixel, y_pixel)
    output logic       motion_valid,
    // input button
    input  logic       shot_btn,
    output logic [9:0] shot_x,
    output logic [9:0] shot_x1,
    output logic [9:0] shot_x2,
    output logic [9:0] shot_x3,
    output logic [9:0] shot_x4,
    output logic [9:0] shot_x5,
    output logic [9:0] shot_y,
    output logic [9:0] shot_y1,
    output logic [9:0] shot_y2,
    output logic [9:0] shot_y3,
    output logic [9:0] shot_y4,
    output logic [9:0] shot_y5,
    output logic       shot_trigger,
    output logic       shot_trigger1,
    output logic       shot_trigger2,
    output logic       shot_trigger3,
    output logic       shot_trigger4,
    output logic       shot_trigger5
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

    // shot btn logic
    logic shot_btn_sync0, shot_btn_sync1;
    logic shot_btn_tick;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shot_btn_sync0 <= 1'b0;
            shot_btn_sync1 <= 1'b0;
        end else begin
            shot_btn_sync0 <= shot_btn;
            shot_btn_sync1 <= shot_btn_sync0;
        end
    end

    assign shot_btn_tick = shot_btn_sync0 & ~shot_btn_sync1;

    logic [9:0] shot_x_reg, shot_y_reg;
    logic [9:0] shot_x_reg1, shot_y_reg1;
    logic [9:0] shot_x_reg2, shot_y_reg2;
    logic [9:0] shot_x_reg3, shot_y_reg3;
    logic [9:0] shot_x_reg4, shot_y_reg4;
    logic [9:0] shot_x_reg5, shot_y_reg5;
    logic shot_trigger_reg;
    logic shot_trigger_reg1;
    logic shot_trigger_reg2;
    logic shot_trigger_reg3;
    logic shot_trigger_reg4;
    logic shot_trigger_reg5;

    assign shot_x = shot_x_reg;
    assign shot_x1 = shot_x_reg1;
    assign shot_x2 = shot_x_reg2;
    assign shot_x3 = shot_x_reg3;
    assign shot_x4 = shot_x_reg4;
    assign shot_x5 = shot_x_reg5;
    assign shot_y = shot_y_reg;
    assign shot_y1 = shot_y_reg1;
    assign shot_y2 = shot_y_reg2;
    assign shot_y3 = shot_y_reg3;
    assign shot_y4 = shot_y_reg4;
    assign shot_y5 = shot_y_reg5;
    assign shot_trigger = shot_trigger_reg;
    assign shot_trigger1 = shot_trigger_reg1;
    assign shot_trigger2 = shot_trigger_reg2;
    assign shot_trigger3 = shot_trigger_reg3;
    assign shot_trigger4 = shot_trigger_reg4;
    assign shot_trigger5 = shot_trigger_reg5;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shot_x_reg        <= 0;
            shot_y_reg        <= 0;
            shot_x_reg1       <= 0;
            shot_y_reg1       <= 0;
            shot_x_reg2       <= 0;
            shot_y_reg2       <= 0;
            shot_x_reg3       <= 0;
            shot_y_reg3       <= 0;
            shot_x_reg4       <= 0;
            shot_y_reg4       <= 0;
            shot_x_reg5       <= 0;
            shot_y_reg5       <= 0;
            shot_trigger_reg  <= 0;
            shot_trigger_reg1 <= 0;
            shot_trigger_reg2 <= 0;
            shot_trigger_reg3 <= 0;
            shot_trigger_reg4 <= 0;
            shot_trigger_reg5 <= 0;
        end else begin
            if (shot_btn_tick && motion_valid_reg) begin
                shot_x_reg        <= com_x_reg;
                shot_y_reg        <= com_y_reg;
                // 1
                shot_x_reg1       <= shot_x_reg;
                shot_y_reg1       <= shot_y_reg;
                // 2
                shot_x_reg2       <= shot_x_reg1;
                shot_y_reg2       <= shot_y_reg1;
                // 3
                shot_x_reg3       <= shot_x_reg2;
                shot_y_reg3       <= shot_y_reg2;
                // 4
                shot_x_reg4       <= shot_x_reg3;
                shot_y_reg4       <= shot_y_reg3;
                // 5
                shot_x_reg5       <= shot_x_reg4;
                shot_y_reg5       <= shot_y_reg4;

                shot_trigger_reg  <= 1;
                shot_trigger_reg1 <= shot_trigger_reg;
                shot_trigger_reg2 <= shot_trigger_reg1;
                shot_trigger_reg3 <= shot_trigger_reg2;
                shot_trigger_reg4 <= shot_trigger_reg3;
                shot_trigger_reg5 <= shot_trigger_reg4;
            end
        end
    end
endmodule



// `timescale 1ns / 1ps

// module motion_display (
//     input  logic                         motion_flag,
//     input  logic                         motion_valid,
//     input  logic [                  9:0] com_x,
//     input  logic [                  9:0] com_y,
//     input  logic                         DE,
//     input  logic [                  9:0] x_pixel,
//     input  logic [                  9:0] y_pixel,
//     output logic [$clog2(160*120)-1 : 0] addr,
//     input  logic [                 15:0] imgData,
//     output logic [                  3:0] r_port,
//     output logic [                  3:0] g_port,
//     output logic [                  3:0] b_port,
//     input  logic [                  9:0] shot_x,
//     input  logic [                  9:0] shot_x1,
//     input  logic [                  9:0] shot_x2,
//     input  logic [                  9:0] shot_x3,
//     input  logic [                  9:0] shot_x4,
//     input  logic [                  9:0] shot_x5,
//     input  logic [                  9:0] shot_y,
//     input  logic [                  9:0] shot_y1,
//     input  logic [                  9:0] shot_y2,
//     input  logic [                  9:0] shot_y3,
//     input  logic [                  9:0] shot_y4,
//     input  logic [                  9:0] shot_y5,
//     input  logic                         shot_trigger,
//     input  logic                         shot_trigger1,
//     input  logic                         shot_trigger2,
//     input  logic                         shot_trigger3,
//     input  logic                         shot_trigger4,
//     input  logic                         shot_trigger5
// );
//     logic img_display_en;

//     int diff_x, diff_y;
//     int dist_sq;

//     int shot_diff_x, shot_diff_y;
//     int shot_dist_sq;


//     assign img_display_en = DE && (x_pixel < 640) && (y_pixel < 480);
//     assign addr = img_display_en ? (160 * y_pixel[9:2] + x_pixel[9:2]) : 1'bz;

//     always_comb begin
//         diff_x = (x_pixel > com_x) ? (x_pixel - com_x) : (com_x - x_pixel);
//         diff_y = (y_pixel > com_y) ? (y_pixel - com_y) : (com_y - y_pixel);
//         dist_sq = (diff_x * diff_x) + (diff_y * diff_y);

//         shot_diff_x  = (x_pixel > shot_x) ? (x_pixel - shot_x) : (shot_x - x_pixel);
//         shot_diff_y  = (y_pixel > shot_y) ? (y_pixel - shot_y) : (shot_y - y_pixel);
//         shot_dist_sq = (shot_diff_x * shot_diff_x) + (shot_diff_y * shot_diff_y);

//         r_port = 0;
//         g_port = 0;
//         b_port = 0;

//         if (img_display_en) begin
//             if (shot_trigger) begin
//                 if (shot_dist_sq <= 36) begin
//                     r_port = 4'd0;
//                     g_port = 4'd0;
//                     b_port = 4'd0;
//                 end
//                  else if ((shot_dist_sq <= 256) && (~(shot_diff_x[2] ^ shot_diff_y[2]))) begin
//                     r_port = 4'd8;
//                     g_port = 4'd8;
//                     b_port = 4'd8;
//                 end
//             end
//             else if (motion_valid && (((dist_sq >= 64) && (dist_sq <= 169)) || ((diff_x <= 2 || diff_y <= 2) && (dist_sq <= 64)))) begin
//                 r_port = 4'b1111;
//                 g_port = 4'b0000;
//                 b_port = 4'b0;
//             end
//             else if (motion_flag) begin // 움직이는 위치 붉게, 필요없다고 판단하면 삭제
//                 r_port = imgData[15:12] + 4'd3;
//                 g_port = imgData[10:7];
//                 b_port = imgData[4:1];
//             end else begin
//                 r_port = imgData[15:12];
//                 g_port = imgData[10:7];
//                 b_port = imgData[4:1];
//             end
//         end else begin
//             r_port = 0;
//             g_port = 0;
//             b_port = 0;
//         end
//     end

// endmodule

// module motion_coordinate (
//     // global signals
//     input  logic       clk,
//     input  logic       reset,
//     // VGA
//     input  logic       DE,
//     input  logic [9:0] x_pixel,
//     input  logic [9:0] y_pixel,
//     // internal
//     input  logic       motion_flag,
//     // output
//     output logic [9:0] com_x,          // center of mass :  (x_pixel, y_pixel)
//     output logic [9:0] com_y,          // center of mass :  (x_pixel, y_pixel)
//     output logic       motion_valid,
//     // input button
//     input  logic       shot_btn,
//     output logic [9:0] shot_x,
//     output logic [9:0] shot_x1,
//     output logic [9:0] shot_x2,
//     output logic [9:0] shot_x3,
//     output logic [9:0] shot_x4,
//     output logic [9:0] shot_x5,
//     output logic [9:0] shot_y,
//     output logic [9:0] shot_y1,
//     output logic [9:0] shot_y2,
//     output logic [9:0] shot_y3,
//     output logic [9:0] shot_y4,
//     output logic [9:0] shot_y5,
//     output logic       shot_trigger,
//     output logic       shot_trigger1,
//     output logic       shot_trigger2,
//     output logic       shot_trigger3,
//     output logic       shot_trigger4,
//     output logic       shot_trigger5
// );

//     // 핵심로직
//     // compare module에서 motion flag가 들어오면
//     // motion flag 뜰 때의 x_pixel과 y_pixel값을 
//     // sum값에 계속 더하고
//     // 이때 나누기를 하기 위해서 sum을 몇 번 더했는지 counter값을 같이 세고
//     // 픽셀을 전부 세고나면 motion flag가 뜬 pixel의 중심 좌표를 계산하고
//     // 그 중심 좌표값을 motion display에 보내서
//     // motion display에서 해당 중심 좌표에 원을 띄우게한다.

//     logic [31:0] sum_x_reg;
//     logic [31:0] sum_x_next;

//     logic [31:0] sum_y_reg;
//     logic [31:0] sum_y_next;

//     logic [31:0] sum_counter_next;
//     logic [31:0] sum_counter_reg;

//     logic [9:0] com_x_reg;
//     logic [9:0] com_x_next;

//     logic [9:0] com_y_reg;
//     logic [9:0] com_y_next;


//     logic motion_valid_reg;
//     logic motion_valid_next;

//     assign com_x = com_x_reg[9:0];
//     assign com_y = com_y_reg[9:0];
//     assign motion_valid = motion_valid_reg;

//     always_ff @(posedge clk) begin
//         if (reset) begin
//             sum_x_reg        <= 0;
//             sum_y_reg        <= 0;
//             sum_counter_reg  <= 0;
//             com_x_reg        <= 0;
//             com_y_reg        <= 0;
//             motion_valid_reg <= 0;
//         end else begin
//             sum_x_reg        <= sum_x_next;
//             sum_y_reg        <= sum_y_next;
//             sum_counter_reg  <= sum_counter_next;
//             com_x_reg        <= com_x_next;
//             com_y_reg        <= com_y_next;
//             motion_valid_reg <= motion_valid_next;
//         end
//     end

//     always_comb begin
//         sum_counter_next  = sum_counter_reg;
//         sum_x_next        = sum_x_reg;
//         sum_y_next        = sum_y_reg;
//         com_x_next        = com_x_reg;
//         com_y_next        = com_y_reg;
//         motion_valid_next = motion_valid_reg;
//         if (DE & (x_pixel < 640) & (y_pixel < 480)) begin
//             if (motion_flag) begin
//                 sum_x_next       = sum_x_reg + x_pixel;
//                 sum_y_next       = sum_y_reg + y_pixel;
//                 sum_counter_next = sum_counter_reg + 1;
//             end
//         end

//         if ((x_pixel == 640) & (y_pixel == 480)) begin
//             sum_x_next       = 0;
//             sum_y_next       = 0;
//             sum_counter_next = 0;
//             if (sum_counter_reg > 0) begin
//                 com_x_next = sum_x_reg / sum_counter_reg;
//                 com_y_next = sum_y_reg / sum_counter_reg;
//                 motion_valid_next = 1'b1;
//             end else begin
//                 com_x_next = 0;
//                 com_y_next = 0;
//                 motion_valid_next = 1'b0;
//             end
//         end
//     end

//     // shot btn logic
//     logic shot_btn_sync0, shot_btn_sync1;
//     logic shot_btn_tick;

//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             shot_btn_sync0 <= 1'b0;
//             shot_btn_sync1 <= 1'b0;
//         end else begin
//             shot_btn_sync0 <= shot_btn;
//             shot_btn_sync1 <= shot_btn_sync0;
//         end
//     end

//     assign shot_btn_tick = shot_btn_sync0 & ~shot_btn_sync1;

//     logic [9:0] shot_x_reg, shot_y_reg;
//     logic [9:0] shot_x_reg1, shot_y_reg1;
//     logic [9:0] shot_x_reg2, shot_y_reg2;
//     logic [9:0] shot_x_reg3, shot_y_reg3;
//     logic [9:0] shot_x_reg4, shot_y_reg4;
//     logic [9:0] shot_x_reg5, shot_y_reg5;
//     logic shot_trigger_reg;
//     logic shot_trigger_reg1;
//     logic shot_trigger_reg2;
//     logic shot_trigger_reg3;
//     logic shot_trigger_reg4;
//     logic shot_trigger_reg5;

//     assign shot_x = shot_x_reg;
//     assign shot_x1 = shot_x_reg1;
//     assign shot_x2 = shot_x_reg2;
//     assign shot_x3 = shot_x_reg3;
//     assign shot_x4 = shot_x_reg4;
//     assign shot_x5 = shot_x_reg5;
//     assign shot_y = shot_y_reg;
//     assign shot_y1 = shot_y_reg1;
//     assign shot_y2 = shot_y_reg2;
//     assign shot_y3 = shot_y_reg3;
//     assign shot_y4 = shot_y_reg4;
//     assign shot_y5 = shot_y_reg5;
//     assign shot_trigger = shot_trigger_reg;
//     assign shot_trigger1 = shot_trigger_reg1;
//     assign shot_trigger2 = shot_trigger_reg2;
//     assign shot_trigger3 = shot_trigger_reg3;
//     assign shot_trigger4 = shot_trigger_reg4;
//     assign shot_trigger5 = shot_trigger_reg5;

//     always_ff @(posedge clk or posedge reset) begin
//         if (reset) begin
//             shot_x_reg        <= 0;
//             shot_y_reg        <= 0;
//             shot_x_reg1       <= 0;
//             shot_y_reg1       <= 0;
//             shot_x_reg2       <= 0;
//             shot_y_reg2       <= 0;
//             shot_x_reg3       <= 0;
//             shot_y_reg3       <= 0;
//             shot_x_reg4       <= 0;
//             shot_y_reg4       <= 0;
//             shot_x_reg5       <= 0;
//             shot_y_reg5       <= 0;
//             shot_trigger_reg  <= 0;
//             shot_trigger_reg1 <= 0;
//             shot_trigger_reg2 <= 0;
//             shot_trigger_reg3 <= 0;
//             shot_trigger_reg4 <= 0;
//             shot_trigger_reg5 <= 0;
//         end else begin
//             if (shot_btn_tick && motion_valid_reg) begin
//                 shot_x_reg        <= com_x_reg;
//                 shot_y_reg        <= com_y_reg;
//                 // 1
//                 shot_x_reg1       <= shot_x_reg;
//                 shot_y_reg1       <= shot_x_reg;
//                 // 2
//                 shot_x_reg2       <= shot_x_reg1;
//                 shot_y_reg2       <= shot_x_reg1;
//                 // 3
//                 shot_x_reg3       <= shot_x_reg2;
//                 shot_y_reg3       <= shot_x_reg2;
//                 // 4
//                 shot_x_reg4       <= shot_x_reg3;
//                 shot_y_reg4       <= shot_x_reg3;
//                 // 5
//                 shot_x_reg5       <= shot_x_reg4;
//                 shot_y_reg5       <= shot_x_reg4;

//                 shot_trigger_reg  <= 1;
//                 shot_trigger_reg1 <= 1;
//                 shot_trigger_reg2 <= 1;
//                 shot_trigger_reg3 <= 1;
//                 shot_trigger_reg4 <= 1;
//                 shot_trigger_reg5 <= 1;
//             end
//         end
//     end
// endmodule

