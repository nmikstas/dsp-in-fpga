clearvars;
clc;

fs = 30720000;%Signal sample rate

format long;
numSamps = 50000;

%Get real input filter data for PSD calcs.
fp = fopen('./LTE_input_real.dat', 'r');
filter_input_real = fscanf(fp, '%f');
fclose(fp);

%Get imaginary input filter data for PSD calcs.
fp = fopen('./LTE_input_imag.dat', 'r');
filter_input_imag = fscanf(fp, '%f');
fclose(fp);

%Get Vivado HLS simulation real output results.
fp = fopen('./LTE_result_real.dat', 'r');
filter_vivado_real = fscanf(fp, '%f');
fclose(fp);

%Get Vivado HLS simulation imaginary output results.
fp = fopen('./LTE_result_imag.dat', 'r');
filter_vivado_imag = fscanf(fp, '%f');
fclose(fp);

%Get MatLab real output results.
fp = fopen('./LTE_output_real.dat', 'r');
filter_matlab_real = fscanf(fp, '%f');
fclose(fp);

%Get MatLab imaginary output results.
fp = fopen('./LTE_output_imag.dat', 'r');
filter_matlab_imag = fscanf(fp, '%f');
fclose(fp);

%Convert column vectors to row vectors.
filter_vivado_real = filter_vivado_real';
filter_vivado_imag = filter_vivado_imag';
filter_matlab_real = filter_matlab_real';
filter_matlab_imag = filter_matlab_imag';

%Calculate RMS error.
RMS_real_err = sqrt(mean(filter_vivado_real-filter_matlab_real)^2)
RMS_imag_err = sqrt(mean(filter_vivado_imag-filter_matlab_imag)^2)

%Display RMS error results.
x = sprintf('RMS error, real = %f', RMS_real_err);
disp(x)
x = sprintf('%%RMS error, real = %f%%', RMS_real_err*100);
disp(x)
x = sprintf('RMS error, imaginary = %f', RMS_imag_err);
disp(x)
x = sprintf('%%RMS error, imaginary = %f%%', RMS_imag_err*100);
disp(x)

%Overlay the filter input and output PSDs
fft_len = 1024;
overlap = fft_len/8;

sig_len_real_in = length(filter_input_real);
[pRealIn,f] = pwelch(filter_input_real,sig_len_real_in,overlap,fft_len,'centered','power',fs);
pReal_input = pRealIn/max(pRealIn);
input_magnitude_spectrum_real = 10*log10(pReal_input);

%%%NOTE: Output had to be moved down 1.45 Db to line up with input!!%%%
sig_len_real_out = length(filter_vivado_real);
[pRealOut,f] = pwelch(filter_vivado_real,sig_len_real_out,overlap,fft_len,'centered','power',fs);
pReal_output = pRealOut/max(pRealOut);
output_magnitude_spectrum_real = 10*log10(pReal_output)-1.45;%HERE! WHY??

sig_len_imag_in = length(filter_input_imag);
[pImagIn,f] = pwelch(filter_input_imag,sig_len_imag_in,overlap,fft_len,'centered','power',fs);
pImag_input = pImagIn/max(pImagIn);
input_magnitude_spectrum_imag = 10*log10(pImag_input);

sig_len_imag_out = length(filter_vivado_imag);
[pImagOut,f] = pwelch(filter_vivado_imag,sig_len_imag_out,overlap,fft_len,'centered','power',fs);
pImag_output = pImagOut/max(pImagOut);
output_magnitude_spectrum_imag = 10*log10(pImag_output);

% Plot PSD of filter output signal
figure(5);

subplot(1,2,1);
plot(f,output_magnitude_spectrum_real, 'b', f, input_magnitude_spectrum_real, 'r');
grid on;
legend('Output PSD', 'Input PSD', 'Location', 'South');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
axis([-fs/2 fs/2 -80 5]);
title('Filter Output PSD - Real Part');

subplot(1,2,2);
plot(f,output_magnitude_spectrum_imag, 'b', f, input_magnitude_spectrum_imag, 'r');
grid on;
legend('Output PSD', 'Input PSD', 'Location', 'South');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
axis([-fs/2 fs/2 -80 5]);
title('Filter Output PSD - Imaginary Part');
