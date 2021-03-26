

k = 2; % second harmonic
N = 32; % 32 samples 
nBits_input = 31;
nBits = 28;

in_cos = 2*cos(2*pi*k/N)
in_cos_q = floor(in_cos*2^nBits)

Wkn = -exp(-j*2*pi*k/N)
Wkn_q = floor(Wkn*2^nBits)
real(Wkn_q)

tVector = linspace(0,2*pi,N);
signal = floor(sin(tVector)*2^nBits_input);
stem(signal)

Ts = 1e-3
