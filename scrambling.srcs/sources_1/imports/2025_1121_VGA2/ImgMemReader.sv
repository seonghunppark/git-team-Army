`timescale 1ns / 1ps

module ImgMemReader (
    input  logic                       de,
    input  logic [                9:0] x_pixel,
    input  logic [                9:0] y_pixel,
    output logic [$clog2(320*240)-1:0] addr,
    input  logic [               15:0] imgdata,
    output logic [                3:0] sred_port,
    output logic [                3:0] sgreen_port,
    output logic [                3:0] sblue_port
);
    logic img_en;

    assign img_en = de && (x_pixel <320) && (y_pixel <240);
    
    assign addr = img_en ? (y_pixel * 320 + x_pixel) : 1'bz;
    assign {sred_port,sgreen_port,sblue_port} = img_en ? {imgdata[15:12],imgdata[10:7],imgdata[4:1]} : 0 ;
    
endmodule


module ImgMemReader_up (
    input  logic                       de,
    input  logic [                9:0] x_pixel,
    input  logic [                9:0] y_pixel,
    output logic [$clog2(320*240)-1:0] addr,
    input  logic [               15:0] imgdata,
    output logic [                3:0] sred_port,
    output logic [                3:0] sgreen_port,
    output logic [                3:0] sblue_port
);
    
    
    assign addr = de ? (y_pixel[9:1] * 320 + x_pixel[9:1]) : 1'bz;
    assign {sred_port,sgreen_port,sblue_port} = de ? {imgdata[15:12],imgdata[10:7],imgdata[4:1]} : 0 ;
    
endmodule
