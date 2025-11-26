`timescale 1ns / 1ps

module OV7670_CCTV (
    input  logic        clk,
    input  logic        reset,
    input logic reset_c,
    // ov7670side
    output logic        xclk,
    input  logic        pclk,
    input  logic        href,
    input  logic        vsync,
    input  logic [ 7:0] data,
    // vga port
    output logic        h_sync,
    output logic        v_sync,
    output logic [ 3:0] red_port,
    output logic [ 3:0] green_port,
    output logic [ 3:0] blue_port,
    input  logic [11:0] code
);
    logic de;
    logic [9:0] x_pixel, y_pixel;
    logic [16:0] raddr, waddr;
    logic [15:0] wdata, rdata;
    logic [3:0] sred_port, sgreen_port, sblue_port;
    pixel_clk_gen U_PIXEL_CLK_GEN (
        .clk  (clk),
        .reset(reset),
        .pclk (xclk)
    );
    VGA_decoder U_VGA_DECODER (
        .clk(xclk),
        .reset(reset),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .de(de),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel)
    );
    frame_buffer FRAME_BUFFER (
        // write side
        .wclk(pclk),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        // read side
        .rclk(xclk),
        .oe(1'b1),
        .raddr(raddr),
        .rdata(rdata)
    );
    ov7670_controller U_OV7670_CONTROLLER (
        .pclk(pclk),
        .reset(reset),
        .href(href),
        .vsync(vsync),
        .data(data),
        .we(we),
        .waddr(waddr),
        .wdata(wdata)
    );
    ImgMemReader_up U_IMGMEMREADER_UP (
        .de(de),
        .x_pixel(x_pixel),
        .y_pixel(y_pixel),
        .addr(raddr),
        .imgdata(rdata),
        .sred_port(sred_port),
        .sgreen_port(sgreen_port),
        .sblue_port(sblue_port)
    );


     vga_scrambler U_VGA_SCRAMBLER(
    .clk(xclk), 
    .reset_c(reset_c),
    .code(code),
    .data_in({sred_port, sgreen_port, sblue_port}),      // 12비트 평문 데이터 (RGB 합)
    .red_port(red_port),
    .green_port(green_port),
    .blue_port(blue_port)
);

    // scrambling U_SCARMBLING (
    //     .code(code),
    //     .data({sred_port, sgreen_port, sblue_port}),
    //     .red_port(red_port),
    //     .green_port(green_port),
    //     .blue_port(blue_port)
    // );
    // ImgMemReader U_IMGMEMREADER (
    //     .de(de),
    //     .x_pixel(x_pixel),
    //     .y_pixel(y_pixel),
    //     .addr(raddr),
    //     .imgdata(rdata),
    //     .red_port(red_port_nup),
    //     .green_port(green_port_nup),
    //     .blue_port(blue_port_nup)
    // );
    // mux_2x1 U_MUX_2X1 (
    //     .up_sel(up_sel),
    //     .a({red_port_up, green_port_up, blue_port_up}),
    //     .b({red_port_nup, green_port_nup, blue_port_nup}),
    //     .c({red_port, green_port, blue_port})
    // );

endmodule

// module mux_2x1 (
//     input logic up_sel,
//     input logic [11:0] a,
//     input logic [11:0] b,
//     output logic [11:0] c
// );
//     always_comb begin : blockName
//         c = 0;
//         case (up_sel)
//             1'b0: c = a;
//             1'b1: c = b;
//         endcase
//     end
// endmodule
