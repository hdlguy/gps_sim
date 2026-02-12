`timescale 1 ns / 1 ps

module gng_cmplx #(
    // real seeds
    parameter INIT_Z1 = 64'd5030521883283424767,
    parameter INIT_Z2 = 64'd18445829279364155008,
    parameter INIT_Z3 = 64'd18436106298727503359, 
    // imaginary seeds, not last two switched
    parameter INIT_Z4 = 64'd5030521883283424767,
    parameter INIT_Z5 = 64'd18436106298727503359,
    parameter INIT_Z6 = 64'd18445829279364155008
)
(
    // System signals
    input logic   clk,                    // system clock
    input logic   rstn,                   // system synchronous reset, active low

    // Data interface
    input logic        ce,                     // clock enable
    output logic       valid_out,             // output data valid
    output logic[15:0] real_out, imag_out        // output data, s<16,11>
);

    logic pre_valid_out;
    gng #(
       .INIT_Z1(INIT_Z1),
       .INIT_Z2(INIT_Z2),
       .INIT_Z3(INIT_Z3)
    )
    gng_real (
        .clk(clk),
        .rstn(rstn),
        .ce(ce),
        .valid_out(pre_valid_out),
        .data_out(real_out)
    );
    
    gng #(
       .INIT_Z1(INIT_Z4),
       .INIT_Z2(INIT_Z5),
       .INIT_Z3(INIT_Z6)
    )
    gng_imag (
        .clk(clk),
        .rstn(rstn),
        .ce(ce),
        .valid_out(),
        .data_out(imag_out)
    );
    
    always_ff @(posedge clk) valid_out <= pre_valid_out;

endmodule
