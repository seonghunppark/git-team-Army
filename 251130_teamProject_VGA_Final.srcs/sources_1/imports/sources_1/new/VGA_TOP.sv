`timescale 1ns / 1ps

module VGA_TOP (
    //global signals
    input  logic        clk,
    input  logic        reset,
    input  logic        reset_c,      // key reset btn
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
    output logic        h_sync_s,
    output logic        v_sync_s,
    // output logic [ 3:0] r_port,
    // output logic [ 3:0] g_port,
    // output logic [ 3:0] b_port,
    output logic [ 3:0] r_port_vga,
    output logic [ 3:0] g_port_vga,
    output logic [ 3:0] b_port_vga,
    output logic [ 3:0] r_port_s,
    output logic [ 3:0] g_port_s,
    output logic [ 3:0] b_port_s,

    // From slave
    input  logic        rising_edge,
    output logic        pclk_s,
    // Master to Camera 
    output logic SCL,
    output logic SDA
);


    logic        sys_clk;
    logic        DE;
    logic [ 9:0] x_pixel;
    logic [ 9:0] y_pixel;
    logic [ 9:0] com_x;
    logic [ 9:0] com_y;
    logic [14:0] rAddr;
    logic [15:0] rData;
    logic        we;
    logic [14:0] wAddr;
    logic [15:0] wData;
    logic        buffer_sel;
    logic        motion_flag;
    logic [15:0] prev_data;
    logic [15:0] curr_data;

    logic [3:0] r_port;
    logic [3:0] g_port;
    logic [3:0] b_port;


    logic [11:0] data_in;

    assign pclk_s   = sys_clk;
    assign xclk     = sys_clk;
    assign h_sync_s = h_sync;
    assign v_sync_s = v_sync;
    assign r_port_s = r_port;
    assign g_port_s = g_port;
    assign b_port_s = b_port;
    assign r_port_vga = data_in[11:8];
    assign g_port_vga = data_in[7:4];
    assign b_port_vga = data_in[3:0];

    SCCB_MASTER U_SCCB_MASTER (
    .clk(clk),
    .reset(reset),
    .SCL(SCL),
    .SDA(SDA)
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

    motion_compare #(
        .THRESHOLD(8'd10)
    ) U_MOTION_COMPARE (
        .prev_data  (prev_data),
        .curr_data  (curr_data),
        .motion_flag(motion_flag)
    );

    motion_coordinate U_motion_coordinate (
        // global signals
        .clk(pclk),
        .reset(reset),
        // VGA
        .DE(DE),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        // internal
        .motion_flag(motion_flag),
        // output
        .com_x(com_x),
        .com_y(com_y)

    );

    motion_display U_MOTION_DISPLAY (
        .motion_flag(motion_flag),
        .com_x      (com_x),
        .com_y      (com_y),
        .DE         (DE),
        .x_pixel    (x_pixel),
        .y_pixel    (y_pixel),
        .addr       (rAddr),
        .imgData    (curr_data),
        .r_port     (data_in[11:8]),
        .g_port     (data_in[7:4]),
        .b_port     (data_in[3:0])
        // .r_port     (r_port),
        // .g_port     (g_port),
        // .b_port     (b_port)
    );

    vga_scrambler U_VGA_SCRAMBLER (
        .clk(sys_clk),
        .reset_c(reset_c),
        .reset(reset),
        .sys_clk(),
        .code(code),
        .data_in(data_in),
        .red_port(r_port),
        .green_port(g_port),
        .blue_port(b_port),
        // .red_port(),
        // .green_port(),
        // .blue_port()
        // From Slave 
        .rising_edge(rising_edge)
    );



endmodule
