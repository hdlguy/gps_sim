#define     BASE_ADDRESS        0x40000000
#define     PROTO_SIZE          0x04000000

#define     REGFILE_OFFSET      0x00000000

#define     TEST_BRAM_OFFSET    0x00010000
#define     TEST_BRAM_SIZE      0x00001000 // 4KB

#define     FPGA_ID             REGFILE_OFFSET+0x04*0  // Currently returns 0xDEADBEEF
#define     FPGA_VERSION        REGFILE_OFFSET+0x04*1  // Returns major and minor version numbers.
    
// The registers of the GPS emulator.
#define     EMU_CONTROL         REGFILE_OFFSET+0x04*6  // bit[0] = gps emulator enable.
                                                       // bit[4] = gps emulator reset.

#define     EMU_NOISE_GAIN      REGFILE_OFFSET+0x04*7  // Noise level of combined satellite signals.

// These are constants to define the location of registers that are repeated for each SV.
#define     N_SAT               4
#define     EMU_REG_START       REGFILE_OFFSET+0x04*8
#define     EMU_REG_STEP        0x04*4
// These are the registers within the set for each satelite
#define     EMU_DOPP_FREQ       0x04*0 // bits[31:0] = (2^32)*Fdop/Fs where Fdop is the doppler frequency desired and Fs is the sampling rate of the system.
#define     EMU_DOPP_GAIN       0x04*1 // bits[15:0] = gain in 1.15 unsigned format. Ie., 0xffff ~ 1.0;
#define     EMU_DOPP_CA_SEL     0x04*2 // bits[5:0] = SV Gold Code
#define     EMU_CODE_FREQ       0x04*3 // bits[31:0] = (2^32)*Fcode/Fs where Fcode is the chipping rate desired and Fs is the sampling rate of the system.

