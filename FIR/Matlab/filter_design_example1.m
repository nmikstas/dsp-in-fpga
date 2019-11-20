%Author Dr Chris Dick
%Modified by Nick Mikstas

format long;
seed = 1;
rng(seed);

fs = 30720000;          % signal sample rate
fc = 9000000;           % corner frequency
Adb = 60;               % filter sidelobe levels
fstp = 10000000;        % stopband edge frequency
deltaF = fstp - fc;     % width of filter transition band

N = 97;
designFrqs = [0, fc, fstp, fs/2]/fs;% vector of design frequencies
amplitudeResponse = [1, 1, 0, 0];% desired amplitude response corresponding to the design frequencies
coeff = firpm(N-1, 2*designFrqs, amplitudeResponse, [10,20]);
coeffNBits = 16;
coeffNBitsFrac = 15;
coeffNBitsInt = coeffNBits - coeffNBitsFrac;

% filter input precision
dataNBits = 23;% bit-precision of the filter input samples
dataNBitsFrac = 15;
dataNBitsInt = dataNBits - dataNBitsFrac;
numInputSamples = 50000;% number of filter input samples to process

fig = 1;% figure counter

% plot filter impulse response for floating point coefficients
figure(fig);
fig = fig + 1;
subplot(1,2,1);
stem(coeff);
title('Filter Impulse Response - Floating Point');
ylabel('Amplitude');
xlabel('Time');

% plot filter frequency response for floating point filter
subplot(1,2,2);
nFFT = 1024;% use nFFT-length transform to compute filter frequency response
frq_rspns = abs(fftshift(fft(coeff, nFFT)));
frq_rspns = frq_rspns / max(frq_rspns);
log_frq_rspns = 20*log10(frq_rspns);% display magnitude response in dB
log_frq_rspns_fp = log_frq_rspns;% keep a copy of the frequency response for the floating-point coefficients
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs;% generate x-axis values for display
plot(x_axis, log_frq_rspns);
grid;
hold on

% overlay design targets on plot
plot([fc, fc], [-80, 5], 'k');
plot([fstp, fstp], [-80, 5], 'm');
plot([-fs/2, fs/2], [-Adb, -Adb,], 'r')
hold off
title('Filter Frequency Response - Floating Point');
ylabel('dB');
xlabel('Frequency');
axis([-fs/2, fs/2 -80, 5]);

% quantize the coefficients
scaledCoeff = coeff/max(coeff);
[tmp, coeffQ] = xquantize(scaledCoeff, coeffNBitsInt, coeffNBitsFrac, 'dontNormalizeData');

% plot time response of the quantized filter
figure(fig);
fig = fig + 1;
subplot(1,2,1);
stem(coeffQ);
title('Filter Impulse Response - Quantized');
ylabel('Amplitude');
xlabel('Time');

% plot filter frequency response
subplot(1,2,2);
nFFT = 1024;% use nFFT-length transform to compute filter frequency response
frq_rspns = abs(fftshift(fft(coeffQ, nFFT)));
frq_rspns = frq_rspns / max(frq_rspns);
log_frq_rspns = 20*log10(frq_rspns);% display magnitude response in dB
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs;% generate x-axis values for display
plot(x_axis, log_frq_rspns);
grid;
axis([-fs/2 fs/2 -80 5]);
hold on

% overlay design targets on plot
plot([fc, fc], [-80, 5], 'k');
plot([fstp, fstp], [-80, 5], 'm');
plot([-fs/2, fs/2], [-Adb, -Adb,], 'r')
hold off
title('Filter Frequency Response - Quantized');
ylabel('dB');
xlabel('Frequency');

% Overlay of floating-point and fixed-point filters
figure(fig)
fig = fig + 1;
nFFT = 1024; % use nFFT-length transform to compute filter frequency response
frq_rspns = abs(fftshift(fft(coeffQ, nFFT)));
frq_rspns = frq_rspns / max(frq_rspns);
log_frq_rspns = 20*log10(frq_rspns);    % display magnitude response in dB
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs;    % generate x-axis values for display
plot(x_axis, log_frq_rspns_fp, 'b', x_axis, log_frq_rspns, 'r');
grid;
hold on;        
% overlay design specifications on plot
plot([fc, fc], [-80, 5], 'k');
plot([fstp, fstp], [-80, 5], 'm');
plot([-fs/2, fs/2], [-Adb, -Adb,], 'r')
hold off;

title_hndl = title('Filter Frequency Response - Overlayed');
y_hndl = ylabel('dB');
x_hndl = xlabel('Frequency');
axis([-fs/2, fs/2 -80, 5]);

filterInputReal = 2*rand(1, numInputSamples)-1;
filterInputImag = 2*rand(1, numInputSamples)-1;
[tmp,filterInputRealQ] = xquantize(filterInputReal, dataNBitsInt, dataNBitsFrac, 'dontNormalizeData');
[tmp,filterInputImagQ] = xquantize(filterInputImag, dataNBitsInt, dataNBitsFrac, 'dontNormalizeData');

%Generate floating-point filter output data.
filterOutputReal = filter(scaledCoeff, 1, filterInputReal);
filterOutputImag = filter(scaledCoeff, 1, filterInputImag);

%Generate quantized filter output data.
filterOutputRealQ = filter(coeffQ, 1, filterInputRealQ);
filterOutputImagQ = filter(coeffQ, 1, filterInputImagQ);

figure(fig);
fig = fig + 1;
subplot(1,2,1);
plot(filterOutputReal);
grid on;
hold on;
plot(filterOutputRealQ);
hold off;
title('Filter Output Real - Overlayed');
xlabel('Time');
ylabel('Amplitude');

subplot(1,2,2);
plot(filterOutputImag);
grid on;
hold on;
plot(filterOutputImagQ);
hold off;
title('Filter Output Imanginary - Overlayed');
xlabel('Time');
ylabel('Amplitude');

%Save quantized filter coefficients
fp = fopen('./LTE_coeff.dat', 'w');
for n=1 : length(coeffQ)-1
    fprintf(fp, '%1.20f,\n', coeffQ(n));
end
fprintf(fp, '%1.20f\n', coeffQ(n+1));
fclose(fp);

%Save quantized filter real input data
fp = fopen('./LTE_input_real.dat', 'w');
for n=1 : length(filterInputRealQ)
    fprintf(fp, '%1.20f\n', filterInputRealQ(n));
end
fclose(fp);

%Save quantized filter imaginary input data
fp = fopen('./LTE_input_imag.dat', 'w');
for n=1 : length(filterInputImagQ)
    fprintf(fp, '%1.20f\n', filterInputImagQ(n));
end
fclose(fp);

%Save floating point filter output real data
fp = fopen('./LTE_output_real.dat', 'w');
for n=1 : length(filterOutputReal)
    fprintf(fp, '%1.20f\n', filterOutputReal(n));
end
fclose(fp);

%Save floating point filter output imaginary data
fp = fopen('./LTE_output_imag.dat', 'w');
for n=1 : length(filterOutputImag)
    fprintf(fp, '%1.20f\n', filterOutputImag(n));
end
fclose(fp);
