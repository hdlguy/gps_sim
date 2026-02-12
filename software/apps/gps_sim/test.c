#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <string.h>
#include <math.h>

#include "mem-io.h"
#include "utils.h"
#include "proto2_hw.h"


int main(int argc,char** argv)
{
    void* pcie_addr;

    uint32_t pcie_bar0_addr=BASE_ADDRESS;
    uint32_t pcie_bar0_size=PROTO_SIZE;

    pcie_addr=phy_addr_2_vir_addr(pcie_bar0_addr,pcie_bar0_size);
    if(pcie_addr==NULL)
    {
       fprintf(stderr,"can't mmap phy_addr 0x%08x with size 0x%08x to viraddr. you must be in root.\n",pcie_bar0_addr,pcie_bar0_size);
       exit(-1);
    }
    fprintf(stdout,"phy_addr 0x%08x with size 0x%08x to viraddr 0x%p.\n",pcie_bar0_addr,pcie_bar0_size, pcie_addr);
    fprintf(stdout,"FPGA ID: 0x%08X\n",read_reg(pcie_addr,FPGA_ID));
    fprintf(stdout,"VERSION: 0x%08X\n",read_reg(pcie_addr,FPGA_VERSION));

    // disable emu
    write_reg(pcie_addr, EMU_CONTROL,    0x10);

    // Setup the SV.
    int sat;
    for (sat=0; sat<N_SAT; sat++){
        write_reg(pcie_addr, EMU_REG_START+(sat*EMU_REG_STEP)+EMU_CODE_FREQ, 0);
        write_reg(pcie_addr, EMU_REG_START+(sat*EMU_REG_STEP)+EMU_DOPP_FREQ, 0);
        write_reg(pcie_addr, EMU_REG_START+(sat*EMU_REG_STEP)+EMU_DOPP_GAIN, 0);
        write_reg(pcie_addr, EMU_REG_START+(sat*EMU_REG_STEP)+EMU_DOPP_CA_SEL, sat);
    }

    // adjust SV 0.
    sat = 0;
    double Fs = 16.383e6/4;
    double dopp_freq = 100;
    double code_base_rate = 1.023e6;
    int32_t dopp_reg_val = (int32_t)(round(pow(2.0, 32.0)*dopp_freq/Fs));
    int32_t code_reg_val = (int32_t)(round(pow(2.0, 32.0)*(code_base_rate+dopp_freq/1540)/Fs));

    write_reg(pcie_addr, EMU_REG_START+(sat*EMU_REG_STEP)+EMU_CODE_FREQ, code_reg_val);
    write_reg(pcie_addr, EMU_REG_START+(sat*EMU_REG_STEP)+EMU_DOPP_FREQ, dopp_reg_val);
    write_reg(pcie_addr, EMU_REG_START+(sat*EMU_REG_STEP)+EMU_DOPP_GAIN, 0xffff);

    // Turn on the noise source.
    write_reg(pcie_addr, EMU_NOISE_GAIN, 0xffff);

    // release emulator from reset.
    write_reg(pcie_addr, EMU_CONTROL,    0x00);
    // enable the emulator
    write_reg(pcie_addr, EMU_CONTROL,    0x01);

    munmap(pcie_addr,pcie_bar0_size);

    return 0;
}
