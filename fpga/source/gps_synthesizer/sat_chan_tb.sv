`timescale 1 ns / 1 ps

module sat_chan_tb ();

    logic        dv_in, reset;
    logic[31:0]  code_freq;
    logic[31:0]  dop_freq;
    logic[15:0]  gain;    
    logic[5:0]   ca_sel;
    logic        dv_out;
    logic[15:0]  real_out;
    logic[15:0]  imag_out;

    localparam clk_period = 10;
    logic clk = 0;
    always #(clk_period/2) clk = ~clk;
    
    sat_chan uut(.*);
  
    initial begin
        reset = 1;
        code_freq = 32'h12345678;
        dop_freq = 32'h01234567;
        gain = 16'h8000;
        ca_sel = 0;
        dv_in = 0;
        #(clk_period*10);
        reset = 0;
        forever begin
            dv_in = 0;
            #(clk_period*63);
            dv_in = 1;
            #(clk_period*1);
        end
     end

endmodule
