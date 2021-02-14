
close all
clear all
clc

%% Fir taps compute

taps = fir1(8,0.9)

%% AXI registers configuration
h = aximaster('Xilinx')

enable = 0;

% FIR configuration
b0 = 0.567;
b1 = 0;%taps(2);
b2 = 0;%taps(3);
b3 = 0;%taps(4);
b4 = 0;%taps(5);
b5 = 0;%taps(6);
b6 = 0;%taps(7);
b7 = 0;%taps(8);
b8 = 0;%taps(9);

% Convert to fixed point
b0_qq = floor(b0*2^24);
b1_qq = floor(b1*2^24);
b2_qq = floor(b2*2^24);
b3_qq = floor(b3*2^24);
b4_qq = floor(b4*2^24);
b5_qq = floor(b5*2^24);
b6_qq = floor(b6*2^24);
b7_qq = floor(b7*2^24);
b8_qq = floor(b8*2^24);

% write AXI registers
h.writememory('40010118',0)

h.writememory('40010104',b0_qq)
h.writememory('40010108',b1_qq)
h.writememory('4001011C',b2_qq)
h.writememory('4001010C',b3_qq)
h.writememory('40010110',b4_qq)
h.writememory('40010100',b5_qq)
h.writememory('40010114',b6_qq)
h.writememory('40010120',b7_qq)
h.writememory('40010124',b8_qq)

h.writememory('40010118',enable)

release(h);