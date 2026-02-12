// gps_emulator.sv
// This block provides a gps emulator that can be instantiated inside
// an FPGA to provide a well controlled signal source for receiver development.

module gps_emulator #(
    parameter int Nsat = 4
)(
    input  logic        clk,                    // this is the system clock.
    input  logic        reset,                  // active high reset. to be controlled by software and released at time zero.
    input  logic        dv_in,                  // this sets the sample cadence.
    input  logic[31:0]  code_freq   [Nsat-1:0], // the code rate for each satellite.
    input  logic[31:0]  dop_freq    [Nsat-1:0], // the doppler frequency for each satellite.
    input  logic[15:0]  gain        [Nsat-1:0], // the gain of each satellite
    input  logic[5:0]   ca_sel      [Nsat-1:0], // the C/A sequence of each satellite 0-35 corresponds to SV 1-36. SV 37 not supported.
    input  logic[15:0]  noise_gain,             // gain of noise added to combined signal.
    // quantized baseband
    output logic       dv_out,
    output logic[7:0]  real_out,  imag_out
);

    
    // generate the individual satellite channel blocks.
    logic[15:0]  sat_real_out   [Nsat-1:0];
    logic[15:0]  sat_imag_out   [Nsat-1:0];
    logic[Nsat-1:0] sat_dv_out;
    genvar sat;
    generate for (sat=0; sat<Nsat; sat++) begin
        sat_chan sat_chan_inst (
            .clk        (clk),
            .reset      (reset),
            .dv_in      (dv_in),
            .dop_freq   (dop_freq[sat]),
            .code_freq  (code_freq[sat]),
            .gain       (gain[sat]),
            .ca_sel     (ca_sel[sat]),
            .dv_out     (sat_dv_out[sat]),
            .real_out   (sat_real_out[sat]),
            .imag_out   (sat_imag_out[sat])
        );
    end endgenerate


    // sum the Nsat satellite outputs.
    // It is a parameterized number of inputs so let's do it with a for loop.
    logic[15:0] temp_real, temp_imag;
    always_comb begin
        temp_real = 0;
        temp_imag = 0;
        for (int i=0; i<Nsat; i++) begin
            temp_real += sat_real_out[i];
            temp_imag += sat_imag_out[i];
        end
    end
    // Here are some registers to allow synthesis pipeline rebalancing.
    logic[15:0] temp_real_reg, temp_imag_reg;
    logic[15:0] temp_real_reg_reg, temp_imag_reg_reg;
    always_ff @(posedge clk) begin
        temp_real_reg <= temp_real; 
        temp_imag_reg <= temp_imag;
        temp_real_reg_reg <= temp_real_reg; 
        temp_imag_reg_reg <= temp_imag_reg;
    end
    

    // instantiate the noise source.
    // This noise is a very good approximation to Gaussian with standard deviation = 1.0 using 16.11 fixed point interpretation.
    logic signed [15:0] noise_real, noise_imag;
    logic noise_dv_out;
    gng_cmplx gng_cmplx_inst (.clk(clk), .rstn(~reset), .ce(dv_in), .valid_out(noise_dv_out), .real_out(noise_real), .imag_out(noise_imag));
    // adjust the noise level
    logic signed [31:0] noise_scaled_real, noise_scaled_imag;
    always_ff @(posedge clk) begin
        noise_scaled_real <= $signed(noise_real)*$signed({1'b0, noise_gain});  
        noise_scaled_imag <= $signed(noise_imag)*$signed({1'b0, noise_gain});
    end


    // Add the Gaussian noise source
    logic[15:0] dither_real, dither_imag;
    assign dither_real = noise_scaled_real[31-:16]; // we should have rounding here.
    assign dither_imag = noise_scaled_imag[31-:16];
    logic[15:0] bb_with_noise_real, bb_with_noise_imag;
    always_ff @(posedge clk) begin
        if (1==noise_dv_out) begin
            bb_with_noise_real <= dither_real + temp_real_reg_reg;  // We should have saturation logic here.
            bb_with_noise_imag <= dither_imag + temp_imag_reg_reg;
        end
    end


    // Let's put an ILA core here to observe the synthesized signal before quantization.
    // This will also prevent all logic being synthesized away when nothing is on the output.
    bb_ila bb_ila_inst (.clk(clk), .probe0({bb_with_noise_real, bb_with_noise_imag})); // 16+16
    

    // Quantize
    // This should include rounding and saturation at desired levels.
    // For now let's just map to the most significant bits.
    always_ff @(posedge clk) begin
        real_out <= bb_with_noise_real[15-:8];
        imag_out <= bb_with_noise_imag[15-:8];
    end
    
    logic pre_dv_out;
    always_ff @(posedge clk) begin
        pre_dv_out <= noise_dv_out;
        dv_out <= pre_dv_out;
    end

endmodule

