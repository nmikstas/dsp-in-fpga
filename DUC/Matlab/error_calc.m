clearvars;
clc;
format long;

fs = 245760000; %Sampling frequency.

%Get original input data.
fp = fopen('./inQ.dat', 'r');
in = fscanf(fp, '%f');
fclose(fp);

filter_input_real = zeros(1, length(in)/2);
filter_input_imag = zeros(1, length(in)/2);

%Separate the imaginary and real parts.
for i=1 : length(in)/2
    filter_input_real(i) = in(2*i-1); 
    filter_input_imag(i) = in(2*i);
end

%Get Vivado HLS simulation real output results.
fp = fopen('./out.dat', 'r');
out = fscanf(fp, '%f');
fclose(fp);

filter_vivado_real = zeros(1, length(out)/2);
filter_vivado_imag = zeros(1, length(out)/2);

%Separate the imaginary and real parts.
for i=1 : length(out)/2
    filter_vivado_real(i) = out(2*i-1); 
    filter_vivado_imag(i) = out(2*i);
end

%Get golden real results.
fp = fopen('./golden.dat', 'r');
golden = fscanf(fp, '%f');
fclose(fp);

filter_matlab_real = zeros(1, length(golden)/2);
filter_matlab_imag = zeros(1, length(golden)/2);

%Separate the imaginary and real parts.
for i=1 : length(golden)/2
    filter_matlab_real(i) = golden(2*i-1); 
    filter_matlab_imag(i) = golden(2*i);
end

%Print difference calculations.
for i = 1 : length(filter_vivado_real)
    x = sprintf('Ref=%f%+fi,Calc=%f%+fi,Difr=%1.20f,Difi=%1.20f',...
        filter_matlab_real(i),filter_matlab_imag(i),...
        filter_vivado_real(i),filter_vivado_imag(i),...
        filter_vivado_real(i)-filter_matlab_real(i),...
        filter_vivado_imag(i)-filter_matlab_imag(i));
    disp(x);
end

%Display number of samples.
x = sprintf('Number of output samples = %d', length(filter_vivado_real));
disp(x);

%Calculate RMS error.
RMS_real_err = sqrt(mean((filter_vivado_real-filter_matlab_real).^2));
RMS_imag_err = sqrt(mean((filter_vivado_imag-filter_matlab_imag).^2));

%Display RMS error results.
x = sprintf('RMS error, real = %f', RMS_real_err);
disp(x);
x = sprintf('%%RMS error, real = %f%%', RMS_real_err*100);
disp(x);
x = sprintf('RMS error, imaginary = %f', RMS_imag_err);
disp(x);
x = sprintf('%%RMS error, imaginary = %f%%', RMS_imag_err*100);
disp(x);

%Overlay golden data with Vivado output data.
figure(1);
subplot(1,2,1);
plot(filter_vivado_real);
grid on;
hold on;
plot(filter_matlab_real);
title('Filter Output Overlay - Real');
ylabel('Amplitude');
xlabel('Sample');
legend('Vivado Output', 'MatLab Output', 'Location', 'SouthOutside');
ylim([-2 2]);

subplot(1,2,2);
plot(filter_vivado_imag);
grid on;
hold on;
plot(filter_matlab_imag);
title('Filter Output Overlay - Imaginary');
ylabel('Amplitude');
xlabel('Sample');
legend('Vivado Output', 'MatLab Output', 'Location', 'SouthOutside');
ylim([-2 2]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PSD Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmp = zeros(2,length(filter_input_real));
tmp(1,:) = filter_input_real;
filter_input_real = reshape(tmp,1,2*length(filter_input_real));

tmp = zeros(2,length(filter_input_imag));
tmp(1,:) = filter_input_imag;
filter_input_imag = reshape(tmp,1,2*length(filter_input_imag));

% Overlay the filter input and output PSDs
figure(2)
subplot(1,2,1);
fft_len = 1024;
sig_len = length(filter_input_real);
overlap = fft_len/8;
[pxx,f] = pwelch(filter_input_real,sig_len,overlap,fft_len,'centered','power',fs);
pxx_input = pxx/max(pxx);
input_magnitude_spectrum = 10*log10(pxx_input);

% Plot PSD of filter output signal
sig_len = length(filter_vivado_real);
overlap = fft_len/8;
[pxx,f] = pwelch(filter_vivado_real,sig_len,overlap,fft_len,'centered','power',fs);
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
sig_len = length(filter_input_imag);
overlap = fft_len/8;
[pxx,f] = pwelch(filter_input_imag,sig_len,overlap,fft_len,'centered','power',fs);
pxx_input = pxx/max(pxx);
input_magnitude_spectrum = 10*log10(pxx_input);

% Plot PSD of filter output signal
sig_len = length(filter_vivado_imag);
overlap = fft_len/8;
[pxx,f] = pwelch(filter_vivado_imag,sig_len,overlap,fft_len,'centered','power',fs);
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
