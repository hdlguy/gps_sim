#define		BASE_ADDRESS		0x40000000
#define		PROTO_SIZE		0x04000000

#define 	REGFILE_OFFSET		0x00000000

#define 	FPGA_ID     		REGFILE_OFFSET+0x04*0  // Currently returns 0xDEADBEEF
#define 	FPGA_VERSION		REGFILE_OFFSET+0x04*1  // Returns major and minor version numbers.
    
#define         TEST_BRAM_OFFSET    0x00010000
#define         TEST_BRAM_SIZE      0x00001000 // 4KB

