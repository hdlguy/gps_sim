% This program generates produces a text file of the C/A code sequences in a format for compilation into an FPGA memory.
clear;
SV = (1:36); % FPGA brams are 36 bits wide so we leave out code 37.

ca = cacode(SV, 1);  % get the 36 sequences, one sample per chip.

fp = fopen("ca_rom.coe", "w");

fprintf(fp, "memory_initialization_radix=2;\n");
fprintf(fp, "memory_initialization_vector=\n");
for i=1:1023
    for j= 36:-1:1
        fprintf(fp, "%d", ca(j,i));
    endfor
    if (1023 != i)
        fprintf(fp, ",\n");
    else
        fprintf(fp, ";\n");
    endif
endfor

fclose(fp);

%memory_initialization_radix=2;
%memory_initialization_vector=
%1111,
%1111,
%1111,
%1111,
%1111;