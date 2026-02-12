`timescale 1 ns / 1 ps

module emu_code_nco_tb();

    logic            reset;
    logic[5:0]       ca_sel;
    logic            dv_in;
    logic[31:0]      freq;  // phase increment (frequency).
    logic            dv_out;
    logic            q;

    localparam clk_period = 10;
    logic clk = 0;
    always #(clk_period/2) clk = ~clk;
    
    emu_code_nco uut(.*);
  
    localparam clocks_per_sample = 64;
    initial begin
        reset = 1;
        ca_sel =3;
        freq = (2.0**32)*(1.0/4.0);
        #(clk_period*10);
        reset = 0;
        #(clk_period*10);

        freq = (2.0**32)*(1.0/4.0);
        for (int i=0; i<1023*5; i++) begin
            dv_in = 1;
            #(clk_period*1);
            dv_in = 0;
            #(clk_period*(clocks_per_sample-1));
        end

        freq = (2.0**32)*(1.0/4.25);
        for (int i=0; i<200; i++) begin
            dv_in = 1;
            #(clk_period*1);
            dv_in = 0;
            #(clk_period*(clocks_per_sample-1));
        end
        
        $stop;

     end

endmodule
