`timescale 1ns / 1ps

module motion_compare #(
    parameter THRESHOLD = 8'd10
) (
    input  logic [15:0] prev_data,
    input  logic [15:0] curr_data,
    output logic        motion_flag
);


    logic [7:0] prev_gray;
    logic [7:0] curr_gray;
    logic [7:0] diff;

    always_comb begin
        // green data
        prev_gray = {prev_data[10:5], 2'b00};  
        curr_gray = {curr_data[10:5], 2'b00};

        // |curr_data - prev_data|
        if (curr_gray > prev_gray)
            diff = curr_gray - prev_gray;
        else
            diff = prev_gray - curr_gray;
        
        // motion_flag
        motion_flag = (diff > THRESHOLD);
    end

endmodule


