module line_buf_ctrl_top(
  input      		   clk		,
  input      		   rstn		,
  input      		   i_vsync	,
  input      		   i_hsync	,
  input      		   i_de		,     
  input  		[9:0]  i_r_data ,
  input  		[9:0]  i_g_data ,
  input  		[9:0]  i_b_data ,
  output	reg		   o_vsync  ,
  output	reg 	   o_hsync  ,
  output 	reg 	   o_de		,
  output	reg	[9:0]  o_r_data ,
  output	reg [9:0]  o_g_data ,
  output	reg [9:0]  o_b_data
  );
  
  reg [4:0] vcount,hcount;
  
  reg [15:0] hcount_reg,hcount_next;  
  parameter IDLE =0  , ODD = 1, EVEN = 2;
  
  reg [2:0] c_state, n_state;
  
  always @(posedge clk, negedge rstn) begin
    if (!rstn) begin
      c_state <= IDLE;
      hcount_reg <=0;
    end else begin
    c_state <= n_state;
    hcount_reg <= hcount_next;
  end
  end
      
  always @(*) begin
    hcount_next = hcount_reg;
    if (i_hsync) begin
      hcount_next = hcount_reg+1;
  end
    case (c_state)
        IDLE : begin
            i_cs = 1'b0;
            i_we = 1'b0;
            if (hcount_reg = 3) begin
                n_state = ODD;
                hcount_next = 0;
            end
        end 
        ODD: begin
            i_cs = 1'b1;
            i_we = 1'b1;
            if ()
        end
    endcase
      
    end
  
  
  
 
  single_port_ram u_ram11 (
    .clk(clk),
    .i_cs(),
    .i_we(i_de),
    .i_addr(),
    .i_din(),
    .o_dout()
  );
  
  single_port_ram u_ram2 (
    .clk(),
    .i_cs(),
    .i_we(),
    .i_addr(),
    .i_din(),
    .o_dout()
  );
  
  assign o_vsync  = i_vsync	 ;
  assign o_hsync  = i_hsync	 ;
  assign o_de 	  = i_de	 ;
  assign o_r_data = i_r_data ;
  assign o_g_data = i_g_data ;
  assign o_b_data = i_b_data ;

  
endmodule