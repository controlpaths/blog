# custom axi ip for acceleration

## Description
On this project I will show you how we can accelerate some algorithms, executing them partially or entirely on FPGA, and the time saved that we can achieve. The algorithm that I will use as an example is an iterative square root finder. This algorithm is used for compute an integer square root of a value. The algorithm, performs an iterative loop multiplying each number by itself, and the result is compared with the input value. When the result number is greater than the input value, the square root result is corresponding with the value that we multiplied by itself less 1.

Project developed for Digilent's Genesys ZU

## Files
- **c/app_square_root.c.** C application to manage root finder ip from petalinux.
- **c/root_finder.c.** Demo application used to verify the behavior on scope.
- **c/square_root_finder.h.** Library for demo application.
- **doc/acceleration.drawio.** Diagram on the post
- **ip_repo/.** IP repository for root finder IP.
- **tb/square_root_finder_tb.v** Verilog module for test.
