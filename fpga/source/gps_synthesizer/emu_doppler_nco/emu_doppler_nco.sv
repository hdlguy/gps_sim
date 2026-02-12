// a dds with complex output
module emu_doppler_nco (
    input  logic        clk,
    input  logic        reset,
    //
    input  logic        dv_in,
    input  logic[31:0]  freq,
    //
    output logic        dv_out,
    output logic[5:0]   real_out,
    output logic[5:0]   imag_out
);

    // Let's use 32 bit accummulators for the DDS. That gives a frequency resolution of >> Fs/(2^32).
    logic [31:0] phase;
    logic pre_dv_out;
    always_ff @(posedge clk) begin
        if (reset == 1) begin
            phase <= 0;
            pre_dv_out <= 0;
        end else begin
            if (1 == dv_in) begin
                phase <= phase + freq;
                pre_dv_out <= 1;
            end else begin
                pre_dv_out <= 0;
            end
        end;
    end;

    emu_dop_cos_rom dop_cos_rom_inst ( .clk(clk), .a(phase[31-:6]), .qspo(real_out));
    emu_dop_sin_rom dop_sin_rom_inst ( .clk(clk), .a(phase[31-:6]), .qspo(imag_out));
    
    always_ff @(posedge clk) dv_out <= pre_dv_out;

endmodule
