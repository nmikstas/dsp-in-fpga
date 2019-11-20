%Author Dr Chris Dick
%Modified by Nick Mikstas
clc;
clearvars;

N = 22;               %Number of filter coefficients.
numInputSamples = 2e3;%Number of filter input samples to process.
coeffNBits = 13;      %Coefficient precision.
coeffNBitsFrac = 12;
coeffNBitsInt = coeffNBits - coeffNBitsFrac;
dataNBits = 15;       %Filter input precision.
dataNBitsFrac = 13;
dataNBitsInt = dataNBits - dataNBitsFrac;

format long;
seed = 1;
rng(seed);
fig = 1; %Figure counter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Filter Design%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Design the LTE channel filter
chnl_fltr_len = 97;      %Filter length
fs_chnls_fltr = 30.72E6; %Signal sample rate
fc = 9E6;                %Corner frequency
Adb = 60;                %Filter sidelobe levels
fstp = 10E6;             %Stopband edge frequency
deltaF = fstp - fc;      %Width of filter transition band
designFrqs = [0, fc, fstp, fs_chnls_fltr/2]/fs_chnls_fltr;%Vector of design frequencies
amplitudeResponse = [1, 1, 0, 0];%Desired amplitude response corresponding to the design frequencies
coeff_lte_chnl_fltr = firpm(chnl_fltr_len-1, 2*designFrqs, amplitudeResponse, [10,20]);

%Quantize the channel filter coefficients.
coeff_lte_chnl_fltr = coeff_lte_chnl_fltr/max(coeff_lte_chnl_fltr);
[tmp,coeff_lte_chnl_fltr] = xquantize(coeff_lte_chnl_fltr, 1, 15, 'dontNormalizeData');

%Plot the channel filter impulse response
figure(fig);
fig = fig + 1;
subplot(1,2,1);
stem(coeff_lte_chnl_fltr);
axis([0, chnl_fltr_len+1, -0.2, 1.0]);
title('Quantized Channel Filter Impulse Response');
ylabel('Amplitude');
xlabel('Time');
grid on;

%Plot the channel filter frequency response
nFFT = 1024;%Use nFFT-length transform to compute filter frequency response
channel_filter_frq_rspns = abs(fftshift(fft(coeff_lte_chnl_fltr, nFFT)));
channel_filter_frq_rspns = channel_filter_frq_rspns / max(channel_filter_frq_rspns);
log_channel_filter_frq_rspns_floatp = 20*log10(channel_filter_frq_rspns);%Display magnitude response in dB

subplot(1,2,2);
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs_chnls_fltr;%Generate x-axis values for display
plot(x_axis, log_channel_filter_frq_rspns_floatp);
grid on;
hold on;

%Overlay design targets on plot
plot([fc, fc], [-80, 5], 'k');
plot([fstp, fstp], [-80, 5], 'm');
plot([-fs_chnls_fltr/2, fs_chnls_fltr/2], [-Adb, -Adb,], 'r');
hold off
title('Quantized Channel Filter Frequency Response');
ylabel('dB');
xlabel('Frequency');
axis([-fs_chnls_fltr/2, fs_chnls_fltr/2 -80, 5]);

%Design the halfband filter
fs = 2*30.72E6;      %Signal sample rate
fc = 9E6;            %Corner frequency
Adb = 60;            %Filter sidelobe levels
fstp = 10E6;         %Stopband edge frequency
channel_width = 10E6;
coeff = firhalfband(N, fc/(fs/2));
coeff
%Plot the halfband filter impulse response
figure(fig);
fig = fig + 1;
subplot(1,2,1);
stem(coeff);
axis([0, N+1, -0.1, 0.5]);
title('Filter Impulse Response');
ylabel('Amplitude');
xlabel('Time');

%Plot halfband filter frequency response
subplot(1,2,2);
nFFT = 1024;%Use nFFT-length transform to compute filter frequency response
hband_frq_rspns = abs(fftshift(fft(coeff, nFFT)));
hband_frq_rspns = hband_frq_rspns / max(hband_frq_rspns);
log_hband_frq_rspns_floatp = 20*log10(hband_frq_rspns);%Display magnitude response in dB
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs;%Generate x-axis values for display
plot(x_axis, log_hband_frq_rspns_floatp);
grid;
hold on;

%Overlay design targets on plot
plot([fc, fc], [-90, 5], 'k');
plot([fstp, fstp], [-90, 5], 'm');
plot([fs/2-channel_width, fs/2-channel_width], [-90, 5], 'm');
plot([fs/2-fc, fs/2-fc], [-90, 5], 'k');
plot([-fs/2, fs/2], [-Adb, -Adb,], 'r');
hold off;
title('Filter Frequency Response');
ylabel('dB');
xlabel('Frequency');
axis([-fs/2, fs/2 -90, 5]);

%Quantize the coefficients. >>Half-band<<
scaledCoeff = coeff/max(coeff);
[tmp, coeffQ] = xquantize(scaledCoeff, coeffNBitsInt, coeffNBitsFrac, 'dontNormalizeData');

%-------------------------Save filter coefficients-------------------------
fp = fopen('./hb_coeffQ.dat', 'w');
for n=0 : (length(coeffQ)-1)/4
    fprintf(fp, '%1.20f,\n', coeffQ(2*n+1));
end
fclose(fp);
%--------------------------------------------------------------------------

%Plot time response of the quantized filter.
figure(fig);
fig = fig + 1;
subplot(1,2,1);
stem(coeffQ);
axis([0, N+1, -0.2, 1.0]);
title('Quantized Filter Impulse Response');
ylabel('Amplitude');
xlabel('Time');

%Plot filter frequency response
nFFT = 1024;%Use nFFT-length transform to compute filter frequency response
frq_rspns = abs(fftshift(fft(coeffQ, nFFT)));
frq_rspns = frq_rspns / max(frq_rspns);
log_frq_rspns = 20*log10(frq_rspns);%Display magnitude response in dB
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs;%Generate x-axis values for display
subplot(1,2,2);
plot(x_axis, log_frq_rspns);
grid on;
axis([-fs/2 fs/2 -90 5]);
hold on;

% overlay design targets on plot
plot([fc, fc], [-90, 5], 'k');
plot([fstp, fstp], [-90, 5], 'm');
plot([-fs/2, fs/2], [-Adb, -Adb,], 'r');
hold off;
title('Quantized Filter Frequency Response');
ylabel('dB');
xlabel('Frequency');

%Overlay of floating-point and fixed-point filters
figure(fig);
fig = fig + 1;
nFFT = 1024;%Use nFFT-length transform to compute filter frequency response
frq_rspns = abs(fftshift(fft(coeffQ, nFFT)));
frq_rspns = frq_rspns / max(frq_rspns);
log_frq_rspns = 20*log10(frq_rspns);%Display magnitude response in dB
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs;%Generate x-axis values for display
plot(x_axis, log_hband_frq_rspns_floatp, 'b', x_axis, log_frq_rspns, 'r');
grid;
hold on;

%Overlay design specifications on plot
plot([fc, fc], [-90, 5], 'k');
plot([fstp, fstp], [-90, 5], 'm');
plot([-fs/2, fs/2], [-Adb, -Adb,], 'r');
hold off;
title_hndl = title('Filter Frequency Response Overlay');
y_hndl = ylabel('dB');
x_hndl = xlabel('Frequency');
axis([-fs/2, fs/2 -90, 5]);%Adjust the plot axis settings to zoom in to the passband

%Form the composite frequency response of the channel filter and the
%halfband filter
zero_packed_channel_filter_tmp = zeros(2,length(coeff_lte_chnl_fltr));
zero_packed_channel_filter_tmp(1,:) = coeff_lte_chnl_fltr;
zero_packed_channel_filter = reshape(zero_packed_channel_filter_tmp,1,2*length(coeff_lte_chnl_fltr));
composite_filter_time_response = conv(zero_packed_channel_filter, coeffQ);

%Plot the impulse reponse of the combined channel and halfband filters.
%This can be reviewed as the aggregate, or composite, impulse response of the series
%connection of the channel and halfband filters
figure(fig);
fig = fig + 1;
subplot(1,2,1);
plot(composite_filter_time_response);
xlabel('Time');
ylabel('Amplitude');
title('Quantized Aggregate Impulse Response');
grid on;
axis([0, length(composite_filter_time_response),-0.25, 1.05]);

zp_chnl_fltr_frq_rspns = abs(fftshift(fft(zero_packed_channel_filter, nFFT)));
zp_chnl_fltr_frq_rspns = zp_chnl_fltr_frq_rspns / max(zp_chnl_fltr_frq_rspns);
log_zp_chnl_fltr_frq_rspns = 20*log10(zp_chnl_fltr_frq_rspns);%Display magnitude response in dB

%Compute frequency response of the composite filter
composite_filter_freq_response = abs(fftshift(fft(composite_filter_time_response, nFFT)));
composite_filter_freq_response = composite_filter_freq_response / max(composite_filter_freq_response);
log_composite_filter_freq_response = 20*log10(composite_filter_freq_response);    

%Plotting for composite filter and other overlays
subplot(1,2,2);
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs;    % generate x-axis values for display
plot(x_axis, log_zp_chnl_fltr_frq_rspns,x_axis,log_frq_rspns,x_axis,log_composite_filter_freq_response);
grid;

%Overlay design targets on plot
hold on;
plot([fc, fc], [-80, 5], 'k');
plot([fstp, fstp], [-80, 5], 'm');
plot([-fs/2, fs/2], [-Adb, -Adb,], 'r')
hold off;
title('Quantized Composite Filter Frequency Response');
ylabel('dB');
xlabel('Frequency');
axis([-fs/2, fs/2 -80, 5]);
legend('zero-packed channel filter', 'halfband', 'composite response','Location', 'SouthOutside');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Sample Generation%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filterInputReal = 2*rand(1, numInputSamples)-1;
[tmp,filterInputRealQ] = xquantize(filterInputReal, dataNBitsInt, dataNBitsFrac, 'dontNormalizeData');
filterInputImag = 2*rand(1, numInputSamples)-1;
[tmp,filterInputImagQ] = xquantize(filterInputImag, dataNBitsInt, dataNBitsFrac, 'dontNormalizeData');

%------------------------------Save Input Data-----------------------------
fp = fopen('./inQ.dat', 'w');
for n=1 : length(filterInputRealQ)
    fprintf(fp, '%1.20f %1.20f\n', filterInputRealQ(n), filterInputImagQ(n));
end
fclose(fp);

%--------------------------------------------------------------------------
%Zero-pack the unquantized input data, used normalized coefficients.
tmp = zeros(2,length(filterInputReal));
tmp(1,:) = filterInputReal;
filterInputReal = reshape(tmp,1,2*length(filterInputReal));
filterOutputReal = filter(scaledCoeff, 1, filterInputReal);

%Zero-pack the unquantized input data, used normalized coefficients.
tmp = zeros(2,length(filterInputImag));
tmp(1,:) = filterInputImag;
filterInputImag = reshape(tmp,1,2*length(filterInputImag));
filterOutputImag = filter(scaledCoeff, 1, filterInputImag);

%------------------------------Save output Data----------------------------
fp = fopen('./golden.dat', 'w');
for n=1 : length(filterOutputReal)
    fprintf(fp, '%1.20f %1.20f\n', filterOutputReal(n), filterOutputImag(n));
end
fclose(fp);
%--------------------------------------------------------------------------

%Plot the output of the half-band filter.
figure(fig)
fig = fig + 1;
subplot(1,2,1);
plot(filterOutputReal);
grid on;
title('Filter Output - Real');
xlabel('Time');
ylabel('Amplitude');
ylim([-2 2]);

subplot(1,2,2);
plot(filterOutputImag);
grid on;
title('Filter Output - Imaginary');
xlabel('Time');
ylabel('Amplitude');
ylim([-2 2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PSD Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Overlay the filter input and output PSDs
figure(fig)
fig = fig + 1;
subplot(1,2,1);
fft_len = 1024;
sig_len = length(filterInputReal);
overlap = fft_len/8;
[pxx,f] = pwelch(filterInputReal,sig_len,overlap,fft_len,'centered','power',fs);
pxx_input = pxx/max(pxx);
input_magnitude_spectrum = 10*log10(pxx_input);

% Plot PSD of filter output signal
sig_len = length(filterOutputReal);
overlap = fft_len/8;
[pxx,f] = pwelch(filterOutputReal,sig_len,overlap,fft_len,'centered','power',fs);
pxx_output = pxx/max(pxx);
output_magnitude_spectrum = 10*log10(pxx_output);
plot(f,output_magnitude_spectrum, 'b', f, input_magnitude_spectrum, 'r');
grid on;
legend('Output PSD', 'Input PSD', 'Location', 'South');
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
axis([-fs/2 fs/2 -80 5]);
title('Filter Output PSD - Real');
hold off;

subplot(1,2,2);
fft_len = 1024;
sig_len = length(filterInputImag);
overlap = fft_len/8;
[pxx,f] = pwelch(filterInputImag,sig_len,overlap,fft_len,'centered','power',fs);
pxx_input = pxx/max(pxx);
input_magnitude_spectrum = 10*log10(pxx_input);

% Plot PSD of filter output signal
sig_len = length(filterOutputImag);
overlap = fft_len/8;
[pxx,f] = pwelch(filterOutputImag,sig_len,overlap,fft_len,'centered','power',fs);
pxx_output = pxx/max(pxx);
output_magnitude_spectrum = 10*log10(pxx_output);
plot(f,output_magnitude_spectrum, 'b', f, input_magnitude_spectrum, 'r');
grid on;
legend('Output PSD', 'Input PSD', 'Location', 'South');
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
axis([-fs/2 fs/2 -80 5]);
title('Filter Output PSD - Imaginary');
hold off;
