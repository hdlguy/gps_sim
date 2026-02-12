// This module provides the signal from an individual Space Vehicle (SV).
// Multiple SV outputs are combined with noise at the next level.
module sat_chan (
    input  logic            clk,
    input  logic            reset,
    input  logic            dv_in,
    input  logic[31:0]      dop_freq,  // (2^32)*(Fdop/Fs)
    input  logic[31:0]      code_freq, // The code rate = (base code rate = 1.023Mbps) + (doppler frequency)/1540. (2^32)*(code rate)/Fs
    input  logic[15:0]      gain,
    input  logic[5:0]       ca_sel,
    output logic            dv_out,
    output logic[15:0]      real_out,
    output logic[15:0]      imag_out
);

    // Doppler NCO
    logic [5:0] dop_nco_real, dop_nco_imag;    
    logic dopp_dv_out;
    emu_doppler_nco doppler_nco_inst ( .clk(clk), .reset(reset), .dv_in(dv_in), .freq(dop_freq), .dv_out(dopp_dv_out), .real_out(dop_nco_real), .imag_out(dop_nco_imag) ); // 2 pipe delays


    // Code NCO
    logic sat_ca;
    logic code_dv_out;
    emu_code_nco code_nco_inst (.clk(clk), .reset(reset), .ca_sel(ca_sel), .dv_in(dv_in), .freq(code_freq), .dv_out(code_dv_out), .q(sat_ca)); // 5 pipe delays


    // Change the sign on the doppler based on the CA sequence.
    logic [5:0] bpsk_imag, bpsk_real;
    always_ff @(posedge clk) begin
        if (1==code_dv_out) begin
            if (1 == sat_ca) begin
                bpsk_imag <= -$signed(dop_nco_imag);
                bpsk_real <= -$signed(dop_nco_real);
            end else begin
                bpsk_imag <= +$signed(dop_nco_imag);
                bpsk_real <= +$signed(dop_nco_real);
            end     
        end   
    end

    
    // Now let's scale the output by the gain.
    logic [22:0] scaled_real, scaled_imag;
    always_ff @(posedge clk) begin
        scaled_real <= $signed(bpsk_real)*$signed({1'b0, gain});
        scaled_imag <= $signed(bpsk_imag)*$signed({1'b0, gain});
    end
    assign real_out = scaled_real[22-:16];
    assign imag_out = scaled_imag[22-:16];

    // Data valid
    logic[3:0] dv_pipe;
    assign dv_pipe[0] = code_dv_out;
    always_ff @(posedge clk) begin
        dv_pipe[3:1] <= dv_pipe[2:0];
    end
    assign dv_out = dv_pipe[2]; 

    
endmodule


