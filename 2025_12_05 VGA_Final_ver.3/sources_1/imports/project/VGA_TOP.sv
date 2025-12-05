`timescale 1ns / 1ps

module VGA_TOP (
    //global signals
    input  logic        clk,
    input  logic        reset,
    input  logic [11:0] code,         // switch key
    // ov7670 side
    output logic        xclk,
    input  logic        pclk,
    input  logic        href,
    input  logic        vsync,
    input  logic [ 7:0] data,
    // vga output
    output logic        h_sync,
    output logic        v_sync,
    output logic [ 3:0] r_port_vga,
    output logic [ 3:0] g_port_vga,
    output logic [ 3:0] b_port_vga,
    // From slave
    input  logic        rising_edge,
    output logic        pclk_s,
    output logic        h_sync_s,
    output logic        v_sync_s,
    output logic [ 3:0] r_port_s,
    output logic [ 3:0] g_port_s,
    output logic [ 3:0] b_port_s,
    // Master to Camera 
    output logic        SCL,
    output logic        SDA,
    input  logic        shot_btn
);


    logic        sys_clk;
    logic        DE;
    logic [ 9:0] x_pixel;
    logic [ 9:0] y_pixel;
    logic [14:0] rAddr;
    logic        we;
    logic [14:0] wAddr;
    logic [15:0] wData;
    logic        buffer_sel;
    logic [15:0] prev_data;
    logic [15:0] curr_data;

    logic [ 3:0] r_port;
    logic [ 3:0] g_port;
    logic [ 3:0] b_port;


    logic        o_shot_btn;

    logic [11:0] data_in = {r_port, g_port, b_port};


    assign r_port_vga = r_port;
    assign g_port_vga = g_port;
    assign b_port_vga = b_port;

    assign pclk_s     = sys_clk;
    assign xclk       = sys_clk;
    assign h_sync_s   = h_sync;
    assign v_sync_s   = v_sync;

    SCCB_MASTER U_SCCB_MASTER (
        .clk  (clk),
        .reset(reset),
        .SCL  (SCL),
        .SDA  (SDA)
    );

    pixel_clk_gen U_PXL_CLK_GEN (
        .clk  (clk),
        .reset(reset),
        .pclk (sys_clk)
    );

    VGA_Syncher U_VGA_Syncher (
        .clk    (sys_clk),
        .reset  (reset),
        .h_sync (h_sync),
        .v_sync (v_sync),
        .DE     (DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );

    OV7670_Mem_Controller #(
        .H_PIXELS(160),
        .V_PIXELS(120)
    ) U_OV7670_Mem_Controller (
        .clk       (pclk),
        .reset     (reset),
        .href      (href),
        .vsync     (vsync),
        .data      (data),
        .we        (we),
        .wAddr     (wAddr),
        .wData     (wData),
        .buffer_sel(buffer_sel)
    );

    buffer U_BUFFER (
        .wclk      (pclk),
        .we        (we),
        .wAddr     (wAddr),
        .wData     (wData),
        .buffer_sel(buffer_sel),
        .rclk      (sys_clk),
        .oe        (1'b1),
        .rAddr     (rAddr),
        .prev_data (prev_data),
        .curr_data (curr_data)
    );

    Core #(
        .THRESHOLD(8'd40)
    ) U_CORE (
        .clk      (sys_clk),
        .reset    (reset),
        .prev_data(prev_data),
        .curr_data(curr_data),
        .DE       (DE),
        .x_pixel  (x_pixel),
        .y_pixel  (y_pixel),
        .addr     (rAddr),
        .r_port   (r_port),
        .g_port   (g_port),
        .b_port   (b_port),
        .shot_btn (o_shot_btn)
    );

    vga_scrambler U_VGA_SCRAMBLER (
        .clk        (sys_clk),
        .code       (code),
        .data_in    (data_in),
        .red_port   (r_port_s),
        .green_port (g_port_s),
        .blue_port  (b_port_s),
        // From Slave 
        .rising_edge(rising_edge)
    );

    btn_debounce U_BTN_DEBOUNCE (
        .clk  (sys_clk),
        .reset(reset),
        .i_btn(shot_btn),
        .o_btn(o_shot_btn)
    );

endmodule


module btn_debounce (
    input  logic clk,
    input  logic reset,
    input  logic i_btn,
    output logic o_btn
);

    logic btn_1;
    logic btn_2;
    logic btn_3;
    logic btn_4;
    logic btn_5;
    logic btn_6;


    assign o_btn = (btn_1 & btn_2 & btn_3 & btn_4 & btn_5 & btn_6) ? 1'b1 : 1'b0;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            btn_1 <= 0;
            btn_2 <= 0;
            btn_3 <= 0;
            btn_4 <= 0;
            btn_5 <= 0;
            btn_6 <= 0;
        end else begin
            btn_1 <= i_btn;
            btn_2 <= btn_1;
            btn_3 <= btn_2;
            btn_4 <= btn_3;
            btn_5 <= btn_4;
            btn_6 <= btn_5;

        end
    end

endmodule
