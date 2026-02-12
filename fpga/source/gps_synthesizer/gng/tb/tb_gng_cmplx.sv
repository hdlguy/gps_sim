`timescale 1 ns / 1 ps

module tb_gng_cmplx ();

    logic rstn;                   // system synchronous reset, active low
    logic ce;                     // clock enable
    logic valid_out;             // output data valid
    logic [15:0] real_out, imag_out;       // output data, s<16,11>

    gng_cmplx uut(.*);

    localparam clk_period = 10;
    logic clk = 0;
    always #(clk_period/2) clk = ~clk;

    initial begin
        ce = 0;
        rstn = 0;
        #(clk_period*10);
        rstn = 1;
        #(clk_period*10);
        ce = 1;
    end

endmodule
