# SineLUTOpt
Optimize the LUT data of on-chip sinusoidal signal with harmonic cancellation technique

This project include 3 files. 

1: The "StOptimization" is used for find the optimized LUT data under different oversampling rate and DAC quantization steps based on S(t) equation. Users can adjust the oversampling ratio by change the value "p", where OSR = 4(P+1). R is the maximum DAC quantization step.

2: After get the optimized "p" and "R", users can use the "St_LUT_generation" file to generate the required LUT data.

3: "yt_LUT_generation" is an example of generating the LUT data based on y(t) function with an oversampling rate of 30 and DAC quantization step of 14.
