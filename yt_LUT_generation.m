%Created by Jiayang Li, University College London. Copyright reserved.
clc;
clear;
close all;

% Global parameters


Num_bit = 4;
pi = 3.14159265359;
f = 5e5;                  % Original sine wave frequency
OSR = 30 ;                % Oversampling rate
clock = f * OSR;          % Oversampling clock frequency
numCycles = 20;           % Number of cycles to generate

t = 0 : 1/(f * OSR) : numCycles/f;
y1=  square(2 * pi * f * t)+1/2*(square(2 * pi * f * t-pi/3))+1/2*(square(2 * pi * f * t+pi/3));
y2=(1/2)*[square(2 * pi * f * t+pi/5)+1/2*(square(2 * pi * f * t-pi/3+pi/5))+1/2*(square(2 * pi * f * t+pi/3+pi/5))];
y3=(1/2)*[square(2 * pi * f * t-pi/5)+1/2*(square(2 * pi * f * t-pi/3-pi/5))+1/2*(square(2 * pi * f * t+pi/3-pi/5))];
y=y1+y2+y3;
  
% Quantize to R-bit resolution
 quantizedSineWave = 2*(y+3.5);

% Convert to binary code and format for LUT
binarySineWave = dec2bin(quantizedSineWave, Num_bit);
lutEntries = strings(OSR, 1);

for i = 1:OSR
    formattedBinary = pad(binarySineWave(i, :), Num_bit, 'right', '0'); 
    lutEntries(i) = sprintf("assign LUT [%d] = %d'b %s ;",i-1, Num_bit, formattedBinary);
end

% Optionally, write to a file
fileName = 'pseudo_sine_wave_LUT_full.txt';
fileID = fopen(fileName, 'w');
fprintf(fileID, '%s\n', lutEntries);
fclose(fileID);

disp('LUT entries written to file: pseudo_sine_wave_LUT_full.txt');
