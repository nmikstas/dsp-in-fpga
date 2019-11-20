clearvars;
clc;

fig = 1;
nFFT = 1024;
fc = 9E6;    %Corner frequency
Adb = 60;    %Filter sidelobe levels
fstp = 10E6; %Stopband edge frequency

%%%%%%%%%%%%%%%%%%%%%%%%%%%Channel Filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Design the LTE channel filter
chnl_fltr_len = 97;      %Filter length
fs_chnls_fltr = 30.72E6; %Signal sample rate, channel filter.
deltaF = fstp - fc;      %Width of filter transition band
designFrqs = [0, fc, fstp, fs_chnls_fltr/2]/fs_chnls_fltr;%Vector of design frequencies
amplitudeResponse = [1, 1, 0, 0];%Desired amplitude response corresponding to the design frequencies
coeff_lte_chnl_fltr = firpm(chnl_fltr_len-1, 2*designFrqs, amplitudeResponse, [10,20]);

%Zero pack the channel filter coefficients.
zero_packed_channel_filter_tmp = zeros(4,length(coeff_lte_chnl_fltr));
zero_packed_channel_filter_tmp(1,:) = coeff_lte_chnl_fltr;
zero_packed_channel_filter = reshape(zero_packed_channel_filter_tmp,1,4*length(coeff_lte_chnl_fltr));

zp_chnl_fltr_frq_rspns = abs(fftshift(fft(zero_packed_channel_filter, nFFT)));
zp_chnl_fltr_frq_rspns = zp_chnl_fltr_frq_rspns / max(zp_chnl_fltr_frq_rspns);
log_zp_chnl_fltr_frq_rspns = 20*log10(zp_chnl_fltr_frq_rspns);%Display magnitude response in dB

%%%%%%%%%%%%%%%%%%%%%%%%%%Halfband Filter 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Design the halfband filter
N = 22;                 %Number of filter coefficients.
fs1 = 2*30.72E6;        %Signal sample rate
coeff1 = firhalfband(N, fc/(fs1/2));

%Zero pack the halfband filter coefficients.
zero_packed_hb1_filter_tmp = zeros(2,length(coeff1));
zero_packed_hb1_filter_tmp(1,:) = coeff1;
zero_packed_hb1_filter = reshape(zero_packed_hb1_filter_tmp,1,2*length(coeff1));

zp_hb1_fltr_frq_rspns = abs(fftshift(fft(zero_packed_hb1_filter, nFFT)));
zp_hbl_fltr_frq_rspns = zp_hb1_fltr_frq_rspns / max(zp_hb1_fltr_frq_rspns);
log_zp_hb1_fltr_frq_rspns = 20*log10(zp_hb1_fltr_frq_rspns);%Display magnitude response in dB

%%%%%%%%%%%%%%%%%%%%%%%%%%Halfband Filter 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Design the halfband filter
M = 14;               %Number of filter coefficients.
fs2 = 4*30.72E6;      %Signal sample rate, halfband filter 2.
coeff2 = firhalfband(M, fc/(fs2/2));

hb2_fltr_frq_rspns = abs(fftshift(fft(coeff2, nFFT)));
hb2_fltr_frq_rspns = hb2_fltr_frq_rspns / max(hb2_fltr_frq_rspns);
log_hb2_fltr_frq_rspns = 20*log10(hb2_fltr_frq_rspns);%Display magnitude response in dB

%%%%%%%%%%%%%%%%%%%%%%%%%%%Aggregate Filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
composite_filter_time_response = conv(zero_packed_channel_filter, zero_packed_hb1_filter);
composite_filter_time_response = conv(composite_filter_time_response, coeff2);

%Compute frequency response of the composite filter
composite_filter_freq_response = abs(fftshift(fft(composite_filter_time_response, nFFT)));
composite_filter_freq_response = composite_filter_freq_response / max(composite_filter_freq_response);
log_composite_filter_freq_response = 20*log10(composite_filter_freq_response);    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Plots%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plotting for composite filter and other overlays
figure(fig);
fig = fig+1;
x_axis = (-0.5 : 1/nFFT : 0.5-1/nFFT)*fs2;    % generate x-axis values for display
plot(x_axis, log_zp_chnl_fltr_frq_rspns, x_axis, log_zp_hb1_fltr_frq_rspns,...
     x_axis, log_hb2_fltr_frq_rspns, x_axis, log_composite_filter_freq_response);
grid;
ylim([-120 5]);
xlim([-fs2/2 fs2/2]);

%Overlay design targets on plot
hold on;
plot([fc, fc], [-120, 5], 'g');
plot([fstp, fstp], [-120, 5], 'g');
plot([-fs2/2, fs2/2], [-Adb, -Adb,], 'r')

hold off;
title('Composite Filter Frequency Response');
ylabel('dB');
xlabel('Frequency');
legend('zero-packed channel filter', 'zero-packed halfband1 filter',...
       'halfband2 filter', 'composite response','Location', 'SouthOutside');

