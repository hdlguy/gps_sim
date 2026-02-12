`timescale 1 ns / 1 ps

module emu_doppler_nco_tb();

    logic        reset;
    logic        dv_in;
    logic[31:0]  freq;
    logic        dv_out;
    logic[5:0]   real_out, imag_out;


    localparam clk_period = 10;
    logic clk = 0;
    always #(clk_period/2) clk = ~clk;
    
    emu_doppler_nco uut(.*);
  
    initial begin
        reset = 1;      
        dv_in = 0;          
        #(clk_period*10);
        reset = 0;     
        #(clk_period*10);
        
        freq = 32'h01234567;
        for (int i=0; i<1000; i++) begin
            dv_in = 1;
            #(clk_period*1);
            dv_in = 0;
            #(clk_period*15);
        end
        
        freq = 32'h04468ace;
        for (int i=0; i<1000; i++) begin
            dv_in = 1;
            #(clk_period*1);
            dv_in = 0;
            #(clk_period*15);
        end
        $stop;
        
     end

endmodule
