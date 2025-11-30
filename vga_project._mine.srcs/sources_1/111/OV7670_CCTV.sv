`timescale 1ns / 1ps


module OV7670_CCTV (
    //global signals
    input  logic       clk,
    input  logic       reset,
    // ov7670 side
    output logic       xclk,
    input  logic       pclk,
    input  logic       href,
    input  logic       vsync,
    input  logic [7:0] data,
    // vga output
    output logic       h_sync,
    output logic       v_sync,
    output logic [3:0] r_port,
    output logic [3:0] g_port,
    output logic [3:0] b_port
);
    logic        sys_clk;
    logic        DE;
    logic [ 9:0] x_pixel;
    logic [ 9:0] y_pixel;
    logic [16:0] rAddr;
    logic [15:0] rData;
    logic        we;
    logic [16:0] wAddr;
    logic [15:0] wData;


    assign xclk = sys_clk;

    pixel_clk_gen U_PXL_CLK_GEN (
        .*,
        .pclk(sys_clk)
    );

    VGA_Syncher U_VGA_Syncher (
        .*,
        .clk(sys_clk)
    );

    ImgMemReader U_IMG_Reader (
        .*,
        .addr   (rAddr),
        .imgData(rData)
    );

    frame_buffer U_Frame_Buffer (
        .*,
        .wclk(pclk),
        .rclk(sys_clk),
        .oe  (1'b1)
    );

    OV7670_Mem_Controller U_OV7670_Mem_Controller (
        .*,
        .clk(pclk)
    );

endmodule


