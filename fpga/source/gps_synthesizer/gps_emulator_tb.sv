`timescale 1 ns / 1 ps

module gps_emulator_tb();

    localparam Nsat = 4;

    logic         enable;
    logic [31:0]  freq        [Nsat-1:0]; // the doppler frequency for each satellite.
    logic [15:0]  gain        [Nsat-1:0]; // the gain of each satellite
    logic [5:0]   ca_sel      [Nsat-1:0]; // the C/A sequence of each satellite 0-35 corresponds to SV 1-36. SV 37 not supported.
    logic [15:0]  noise_gain;             // gain of noise added to combined signal.
    logic [2:0]   real_out;  
    logic [2:0]   imag_out;


    localparam clk_period = 10;
    logic clk = 0;
    always #(clk_period/2) clk = ~clk;
    
    gps_emulator #( .Nsat(Nsat)) uut (.*);
  
    initial begin
        enable = 0;
        for (int i =0; i<Nsat; i++) freq[i] = 0;
        for (int i =0; i<Nsat; i++) gain[i] = 0;
        for (int i =0; i<Nsat; i++) ca_sel[i] = i;
        freq[0] = 32'd536871; // (2**32)*(0.5KHz/4Msps);
        gain[0] = 16'h1000;    // 0xffff ~= +1.0
        noise_gain = 16'h8000; // 0xffff ~= +1.0
        #(clk_period*10);
        enable = 1;
     end

endmodule
