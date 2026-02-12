//
module top (
    //
    output logic [14:0]     DDR_addr,
    output logic [2:0]      DDR_ba,
    output logic            DDR_cas_n,
    output logic            DDR_ck_n,
    output logic            DDR_ck_p,
    output logic            DDR_cke,
    output logic            DDR_cs_n,
    output logic [3:0]      DDR_dm,
    output logic [31:0]     DDR_dq,
    output logic [3:0]      DDR_dqs_n,
    output logic [3:0]      DDR_dqs_p,
    output logic            DDR_odt,
    output logic            DDR_ras_n,
    output logic            DDR_reset_n,
    output logic            DDR_we_n,
    output logic            FIXED_IO_ddr_vrn,
    output logic            FIXED_IO_ddr_vrp,
    output logic [53:0]     FIXED_IO_mio,
    input  logic            FIXED_IO_ps_clk,
    input  logic            FIXED_IO_ps_porb,
    input  logic            FIXED_IO_ps_srstb
);


    // Here add the software control path via Zynq.
    logic [39:0]    M00_AXI_araddr;
    logic [2:0]     M00_AXI_arprot;
    logic           M00_AXI_arready;
    logic           M00_AXI_arvalid;
    logic [39:0]    M00_AXI_awaddr;
    logic [2:0]     M00_AXI_awprot;
    logic           M00_AXI_awready;
    logic           M00_AXI_awvalid;
    logic           M00_AXI_bready;
    logic [1:0]     M00_AXI_bresp;
    logic           M00_AXI_bvalid;
    logic [31:0]    M00_AXI_rdata;
    logic           M00_AXI_rready;
    logic [1:0]     M00_AXI_rresp;
    logic           M00_AXI_rvalid;
    logic [31:0]    M00_AXI_wdata;
    logic           M00_AXI_wready;
    logic [3:0]     M00_AXI_wstrb;
    logic           M00_AXI_wvalid;

    logic           axi_aclk;
    logic [0:0]     axi_aresetn;
    
    // This is the IPI block diagram from system.tcl
    system system_i (
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        //
        .M00_AXI_araddr(M00_AXI_araddr),
        .M00_AXI_arprot(M00_AXI_arprot),
        .M00_AXI_arready(M00_AXI_arready),
        .M00_AXI_arvalid(M00_AXI_arvalid),
        .M00_AXI_awaddr(M00_AXI_awaddr),
        .M00_AXI_awprot(M00_AXI_awprot),
        .M00_AXI_awready(M00_AXI_awready),
        .M00_AXI_awvalid(M00_AXI_awvalid),
        .M00_AXI_bready(M00_AXI_bready),
        .M00_AXI_bresp(M00_AXI_bresp),
        .M00_AXI_bvalid(M00_AXI_bvalid),
        .M00_AXI_rdata(M00_AXI_rdata),
        .M00_AXI_rready(M00_AXI_rready),
        .M00_AXI_rresp(M00_AXI_rresp),
        .M00_AXI_rvalid(M00_AXI_rvalid),
        .M00_AXI_wdata(M00_AXI_wdata),
        .M00_AXI_wready(M00_AXI_wready),
        .M00_AXI_wstrb(M00_AXI_wstrb),
        .M00_AXI_wvalid(M00_AXI_wvalid),
        //
        .axi_aclk(axi_aclk),
        .axi_aresetn(axi_aresetn)
    );
    
    localparam int Nsat = 4;

    logic        gps_enable, gps_reset;
    logic[31:0]  sat_code_freq   [Nsat-1:0]; // the code frequency for each satellite.
    logic[31:0]  sat_freq        [Nsat-1:0]; // the doppler frequency for each satellite.
    logic[15:0]  sat_gain        [Nsat-1:0]; // the gain of each satellite
    logic[5:0]   sat_ca_sel      [Nsat-1:0]; // the C/A sequence of each satellite 0-35 corresponds to SV 1-36. SV 37 not supported.
    logic[15:0]  gps_noise_gain;             // gain of noise added to combined signal.
    
    // This register file gives software contol over unit under test (UUT).
    localparam int Nregs = 32;
    localparam int Naddr = $clog2(Nregs);
    localparam int Nstart = 8;
    localparam int Nstep = 4;
    logic [Nregs-1:0][31:0] slv_reg, slv_read;

    assign slv_read[0] = 32'hdeadbeef;
    assign slv_read[1] = 32'h76543210;
    
    assign gps_enable = slv_reg[6][0];
    assign gps_reset  = slv_reg[6][4];
    assign slv_read[6] = slv_reg[6];
    
    assign gps_noise_gain = slv_reg[7][15:0];
    assign slv_read[7] = slv_reg[7];
    
    genvar sat;
    generate for (sat=0; sat<Nsat; sat++) begin
        // the satellite channel control signals.
        assign sat_freq      [sat] = slv_reg[Nstart+Nstep*sat+0][31:0]; 
        assign sat_gain      [sat] = slv_reg[Nstart+Nstep*sat+1][15:0]; 
        assign sat_ca_sel    [sat] = slv_reg[Nstart+Nstep*sat+2][ 5:0]; 
        assign sat_code_freq [sat] = slv_reg[Nstart+Nstep*sat+3][31:0]; 
        // make them readable.
        assign slv_read[Nstart+Nstep*sat+0] =  slv_reg[Nstart+Nstep*sat+0];
        assign slv_read[Nstart+Nstep*sat+1] =  slv_reg[Nstart+Nstep*sat+1];
        assign slv_read[Nstart+Nstep*sat+2] =  slv_reg[Nstart+Nstep*sat+2];
    end endgenerate
    
    // assign slv_read[Naddr-1:2] = slv_reg[Naddr-1:2];

	axi_regfile_v1_0_S00_AXI #	(
		.C_S_AXI_DATA_WIDTH(32),
		.C_S_AXI_ADDR_WIDTH(Naddr+2) 
	) axi_regfile_inst (
        // register interface
        .slv_read(slv_read), 
        .slv_reg (slv_reg),  
        // axi interface
		.S_AXI_ACLK    (axi_aclk),
		.S_AXI_ARESETN (axi_aresetn),
        //
		.S_AXI_ARADDR  (M00_AXI_araddr ),
		.S_AXI_ARPROT  (M00_AXI_arprot ),
		.S_AXI_ARREADY (M00_AXI_arready),
		.S_AXI_ARVALID (M00_AXI_arvalid),
		.S_AXI_AWADDR  (M00_AXI_awaddr ),
		.S_AXI_AWPROT  (M00_AXI_awprot ),
		.S_AXI_AWREADY (M00_AXI_awready),
		.S_AXI_AWVALID (M00_AXI_awvalid),
		.S_AXI_BREADY  (M00_AXI_bready ),
		.S_AXI_BRESP   (M00_AXI_bresp  ),
		.S_AXI_BVALID  (M00_AXI_bvalid ),
		.S_AXI_RDATA   (M00_AXI_rdata  ),
		.S_AXI_RREADY  (M00_AXI_rready ),
		.S_AXI_RRESP   (M00_AXI_rresp  ),
		.S_AXI_RVALID  (M00_AXI_rvalid ),
		.S_AXI_WDATA   (M00_AXI_wdata  ),
		.S_AXI_WREADY  (M00_AXI_wready ),
		.S_AXI_WSTRB   (M00_AXI_wstrb  ),
		.S_AXI_WVALID  (M00_AXI_wvalid )
	);

    // make the data valid heartbeat.
    localparam Ndv = 64;  // We want to emulate these rates. 256MHz/4Msps = 64
    logic[7:0] dv_count;
    logic gps_dv_in;
    always_ff @(posedge axi_aclk) begin
        if(1==gps_enable) begin
            if (0==dv_count) begin  
                dv_count <= Ndv-1;
                gps_dv_in <= 1;
            end else begin
                dv_count <= dv_count-1;
                gps_dv_in <= 0;
            end
        end else begin
            dv_count <= Ndv-1;
            gps_dv_in <= 0;
        end
    end

    logic[7:0]  real_out,  imag_out;
    logic gps_dv_out;
    gps_emulator #(
        .Nsat(Nsat)
    ) uut (
        .clk        (axi_aclk),
        .reset      (gps_reset),
        .dv_in      (gps_dv_in),
        .code_freq  (sat_code_freq),
        .dop_freq   (sat_freq),
        .gain       (sat_gain),
        .ca_sel     (sat_ca_sel),
        .noise_gain (gps_noise_gain),
        .dv_out     (gps_dv_out),
        .real_out   (real_out),
        .imag_out   (imag_out)
    );
    
    // let's put an ILA to observe the output.
    output_ila output_ila_inst( .clk(axi_aclk), .probe0({real_out, imag_out}), .probe1(gps_dv_out) ); // 8+8
    
endmodule
    
