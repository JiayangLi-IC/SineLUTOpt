%Created by Jiayang Li, University College London. Copyright reserved.
clc;
clear;
close all;

% Global parameters
R=214;                    % DAC quantization step
p = 15;                   % Number of square wave pairs
                          % Oversampling rate =  4*(p+1); 
Num_bit = 9;              % Number of bits in the LUT data. Should be adjusted according to R 


%other parameters
f = 5e5;                  % Original sine wave frequency
OSR = 4*(p+1);            % Oversampling rate
clock = f * OSR;          % Oversampling clock frequency
a=1:1:p;
b=1:1:p;
pi = 3.14159265359;
t = 0 : 1/(f * OSR) : 1/f;
y1 = square(2 * pi * f * t);
for i = 1:p
        a(i) = i*(2*pi)/(4*(p+1));
        b(i) = cos(i*2*pi/(4*(p+1)));
end

for j = 1:p
        y1 = y1 + b(j)*square(2 * pi * f * t + a(j)) + b(j)*square(2 * pi * f * t - a(j));
end

 ppy = max(y1) - min(y1);    
 y = R*(y1/ppy + 0.5);
 quantizedSineWave = round(y);

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
