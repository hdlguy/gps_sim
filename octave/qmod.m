% This is a little script to observe quadrature modulation, (I/Q), (real/imaginary)
% when bpsk is on the imaginary part of the baseband signal.
clear;

Fchip = 1;
Fmix = 10*Fchip;
Fsamp = 100*Fchip;

Nchip=2^10;
Nsamp = Nchip*Fsamp/Fchip;

s_chip = j*sign(rand(1,Nchip)-0.5);
s_up = repelems(s_chip, [(1:Nchip); (Fsamp/Fchip)*ones(1,Nchip)]);

s_mix = exp(j*2*pi*(Fmix/Fsamp)*(0:Nsamp-1));

s2 = s_mix .* s_up;

Nplot=1000; 
plot(real(s_mix(1:Nplot)), '.-r');
hold on;
plot(real(s2(1:Nplot)), '.-b');
plot(imag(s_up(1:Nplot)), '*-g');
hold off;
