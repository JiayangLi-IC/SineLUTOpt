%Created by Jiayang Li, University College London. Copyright reserved.

clc;
clear;
close all;

% define parameters
p = 7;                     % Total pair of squarewaves to cancel the harmonic. 
                           % The oversampling rate equals to 4*(p+1)
R_max = 128;               % The maximum quatization steps in this analysis
LPF_bandwidth = 2;         % The ratio between the LPF corner frequency and signal frequency
LPF_order = 2;             % Order of the LPF

%other parameters
f = 5e5;                  % Original sine wave frequency
OSR = 4*(p+1);            % Oversampling rate
clock = f * OSR;          % Oversampling clock frequency
numCycles = 20;           % Number of cycles to generate
fs = 99999;               % Sampling frequency for THD calculation
NumHarmonics = 100;       % Number of harmonics for THD calculation


%generating S(t)
a=1:1:p;
b=1:1:p;
pi = 3.14159265359;
t = 0 : 1/(f * OSR) : numCycles/f;
y1 = square(2 * pi * f * t);
for i = 1:p
        a(i) = i*(2*pi)/(4*(p+1));
        b(i) = cos(i*2*pi/(4*(p+1)));
end

    for j = 1:p
        y1 = y1 + b(j)*square(2 * pi * f * t + a(j)) + b(j)*square(2 * pi * f * t - a(j));
    end
    ppy = max(y1) - min(y1);
    R_value = zeros([1 R_max]);
    THD = zeros([1 R_max]);
    error = zeros([1 R_max]);
for R = 4:1:R_max    
    y = R*(y1/ppy + 0.5);


    % Quantize to R-bit resolution
    quantizedSineWave = round(y);
  

    % Expand each data point by copying it 1000 times
    expandedQuantizedSineWave = repelem(quantizedSineWave, 100);
    N = length(expandedQuantizedSineWave); % Length of the expanded signal

    % Effective Sampling Rate
    effectiveSamplingRate = clock * 100; % Adjusted for the expanded signal

    % Low-pass filter design
    cutoffFrequency = LPF_bandwidth * f; % Filter cutoff frequency
    [filterB, filterA] = butter(LPF_order, cutoffFrequency/(effectiveSamplingRate/2), 'low');

    % Apply the filter
    filteredSignal = filter(filterB, filterA, expandedQuantizedSineWave);

    % Select mid-section of the filtered signal
    midStartPoint = floor(N * 0.25) + 1;
    midEndPoint = floor(N * 0.75);

    midSectionSignal = filteredSignal(midStartPoint:midEndPoint);

    %calculate THD and error
    R_value(R) = R;
    THD_P_values = zeros([1 NumHarmonics]);
    error_P = zeros([1 NumHarmonics]);
    for j=3:NumHarmonics
      THD1 = thd(midSectionSignal, fs, j);
      THD_P_values1 = 100 * (10^(THD1/20));
      THD2 = thd(midSectionSignal, fs, j-1);
      THD_P_values2 = 100 * (10^(THD2/20));
      THD_P_values(j)=sqrt((THD_P_values1/100)^2-(THD_P_values2/100)^2)*100;
      error_P(j)=THD_P_values(j)/j;
    end
  
 THD_P (3:NumHarmonics)= 20*log10(THD_P_values(3:NumHarmonics)/100);
 
 THD (R)= 100 * (10^(thd(midSectionSignal, fs, NumHarmonics)/20));

 error(R)= sum(error_P(3:100));

end




hPlot = plot(R_value(4:R_max), error(4:R_max), 'b-', R_value(4:R_max), THD(4:R_max), 'r-', 'LineWidth', 1); % Increase line width
xlabel('DAC Quantization Steps', 'FontName', 'Arial', 'FontWeight', 'bold','FontSize', 11); % X-axis label
ylabel('(%)', 'FontName', 'Arial', 'FontWeight', 'bold','FontSize', 11); % Y-axis label
legend('Error of Quantized S(t)', 'THD of Quantized S(t)', 'FontName', 'Arial', 'FontWeight', 'bold', 'Location', 'best','FontSize', 11); % Legend
set(gca, 'FontName', 'Arial', 'FontWeight', 'bold','FontSize', 11);



