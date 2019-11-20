clearvars;
clc;
format long;

nlen=8192; %Number of samples in the input.
fs = 245760000;

%------------------------------Load HLS Output-----------------------------
fp = fopen('./sin.dat', 'r');
sinDat = fscanf(fp, '%f');
fclose(fp);

fp = fopen('./cos.dat', 'r');
cosDat = fscanf(fp, '%f');
fclose(fp);
%--------------------------------------------------------------------------

s1=cosDat+j*sinDat;

ww=bkharris(nlen);
fs1=fft(s1.*ww,2*nlen);
fs1=abs(fs1); fs1m=max(fs1); fs1=20*log10(fs1/fs1m);

figure(1);
subplot(3,1,1);
vv=[0 50 -1 +1];

plot(1:200,imag(s1(1:200)),1:200,real(s1(1:200)),'r'); % plot output signal
grid;axis(vv);title('DDS OUTPUT WAVEFORM');xlabel('TIME');ylabel('AMPLITUDE');

subplot(3,1,2);
v=[0 0.5 -140 0];
plot(0:0.5/nlen:0.5-0.5/nlen,fs1(1:nlen));  % plot xfrm of output
grid;axis(v);title('SPECTRUM OF DDS SIGNAL');xlabel('NORMALIZED FREQUENCY');ylabel('DB');
hold on;

%Add in critical plot points.
plot([0,0.5],[-70,-70],'m')
plot([0,0.5],[-94,-94],'r')
hold off;

legend('DDS Frequency Spectrum', '-70 dB', '-94 dB', 'Location', 'NorthEast');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PSD Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fft_len = 4096;

% Plot PSD of filter output signal
sig_len = length(s1);
overlap = fft_len/8;
[pxx,f] = pwelch(s1,sig_len,overlap,fft_len,'centered','power',fs);
pxx_output = pxx/max(pxx);
output_magnitude_spectrum = 10*log10(pxx_output);

subplot(3,1,3);
plot(f,output_magnitude_spectrum, 'b');
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
axis([0 fs/2 -100 5]);
title('DDS Output PSD');
hold on;

%Add in critical plot points.
plot([0,fs/2],[-70,-70],'m')
plot([0,fs/2],[-94,-94],'r')
hold off;

legend('DDS PSD', '-70 dB', '-94 dB', 'Location', 'NorthEast');

