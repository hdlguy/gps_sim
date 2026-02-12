// code_nco.sv - NCO for the CA code generator. This is needed for code tracking in the receiver.
// The code rom must receive a modulo 1023 count. This means that the top bits of a phase accumlator cannot just be used as the address.
// The 32 bit frequency is the code bit rate frequency, ie., the chipping rate.

module emu_code_nco (
    input  logic            clk,
    input  logic            reset,               // 
    input  logic[5:0]       ca_sel,
    input  logic            dv_in,              // this is really a clock enable to be pulsed at the sample rate.
    input  logic[31:0]      freq,               // phase increment (frequency). This input is used to maintain code lock.
    output logic            dv_out,
    output logic            q
);

    localparam integer Naddr = 10;
    localparam integer Nphase = 32;

    // select the phase increment based on whether jump_latch is true.
    logic[Nphase-1:0] ph_inc = 0; // initialize for simulation.
    //always_comb begin
    always_ff @(posedge clk) begin
        ph_inc <= freq;
    end

    // This is the phase accumulator. It is a strange thing because the top 10 bits are the address to the ca_rom and the lower 32 bits are the phase within a chip.
    // The 10 address bits must count modulo 1023 so in the positive direction addr=1023 must be detected and replaced by 0. In the negative direction it should be replaced by 1022.
    logic[Naddr+Nphase-1:0] accum;  // 42 bit accumulator.
    logic[Naddr+Nphase-1:0] pre_sum; 
    assign pre_sum = $signed(accum) + $signed(ph_inc);
    always_ff @(posedge clk) begin
        if (1 == reset) begin
            accum[Naddr+Nphase-1:Nphase] <= 0;
            accum[Nphase-1:0]            <= 0;
        end else begin
            if (1==dv_in) begin
                if((2**Naddr-1) == pre_sum[Naddr+Nphase-1:Nphase]) begin // detect special case of address bits == 1023.
                    if(0==ph_inc[Nphase-1]) begin 
                        accum[Naddr+Nphase-1:Nphase] <= 0; // if going positive.
                    end else begin
                        accum[Naddr+Nphase-1:Nphase] <= 2**Naddr-2; // if going negative.
                    end
                    accum[Nphase-1:0] <= pre_sum[Nphase-1:0];
                end else begin
                    accum <= pre_sum;
                end
            end else begin
            end
        end
    end

    // grab the top bits off the accumulator to be the address to the ca rom.
    logic[9:0] ca_addr;
    assign ca_addr = accum[Naddr+Nphase-1:Nphase];
    logic[31:0] ca_phase;
    assign ca_phase = accum[Nphase-1:0]; 

    // the block rom core.
    logic [35:0]  ca_seq;
    emu_ca_rom ca_rom_inst (.clka(clk), .addra(ca_addr), .douta(ca_seq));

    // selet the particular space vehicle code.
    always_ff @(posedge clk) begin
        q <= ca_seq[ca_sel];
    end

    // pipeline the dv.
    localparam integer Npipe = 6;
    logic[Npipe-1:0] dv_pipe;
    assign dv_pipe[0] = dv_in;
    always_ff @(posedge clk) begin
        dv_pipe[Npipe-1:1] <= dv_pipe[Npipe-2:0];
    end
    assign dv_out = dv_pipe[Npipe-1];

endmodule


