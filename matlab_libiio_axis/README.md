# MATLAB LibIIO example
Example project that shows how to design a Goertzel filter with AXI4 Stream interface with MATLAB and LibIIO. The project contains the next files.
- **matlab/compute_constants.m** Script to generate the constants used on the goertzel filter model.
- **matlab/gm_model_biquad_wfa_interface_modified.xxx** Interface model modified with the corresponding blocks.
- **matlab/gm_model_biquad_wfa_interface.xxx** Interface model generated by MATLAB.
- **matlab/goertzel_model.slx** Goertzel filter model.
- **matlab/goertzel_split.slx** Goertzel filter model with real and imaginary parts.
- **matlab/ip_test.m** MATLAB script to read AXIS input and output and compare them to the model.
- **matlab/model_biquad_wfa.slx** Model used to generate the IP on WFA.
- **matlab/model_biquad.slx** Goertzel filter model using biquad block.
- **matlab/signal_to_test_generate.m** Script to generate test signal to compare model and implementation behavior.
- **vivado/ip_repo/axis_goertzel_ip_v1_0** IP repository.
