%> @file demo_photosensor_simple_model.m
%> @brief Original code from Janesick book that simulates the noise in CMOS sensor.
%> 
%> @author James Janesick
%> @date   17 January 2011
%> 
clc
clear all
close all


PIX = 1000; % number of pixels sampled
DATA = 100; %% number of data points


%%%%%%%% Parameters %%
pixel_size = 8*10^(-4);  %% pixel size in [cm].

edn = 2; %% Conversion constant K[e/DN]
RN_e = 3; %% read noise [e]
RN = RN_e/edn; %% read noise [DN]

FW_e = 10^5; %% full well of pixel, [e]
FW = FW_e/edn; %% full well in DN

SCALE = DATA/log10(FW);  %% full well scale factor;

PN = 0.02;  %% FPN factor;

T = 300; %% operating temperature, [K]

k1 = 8.62*10^(-5); %%% Boltzman constant, [eV/K].

DFM = 0.5;  %% dark current figure of merit, [nA/cm^2].

DN = 0.3; %% dark FPN factor

PA = pixel_size^2;  %% pixel area [cm^2]

t_I = 0.3; 	%% integration time

Eg = 1.1557 - ( 7.021*T^2*10^(-4) )/(1108+T);  %% silicon band gap energy;

DARK_e = t_I*2.55*10^(15)*PA*DFM*T^(1.5)*exp(-Eg/(2*k1*T)); %% dark current [e]
DARK = DARK_e/edn; %% dark current [DN]



%%%%%%%% Program
randn('state', sum(100*clock));  %randomize the number generation
C = randn(PIX,1); %% random number generation for FPN number
F = randn(PIX,1);

for i=1:DATA
sig = 10^(i/SCALE);  %% signal step

A = randn(PIX,DATA); %% random number generation
B = randn(PIX,DATA); %% random number generation
D = randn(PIX,DATA); %% random number generation

read = RN*A(1:PIX,i); %%% read noise [DN]
shot = (sig/edn)^(0.5)*B(1:PIX,i); %% shot noise [DN]

FPN = sig*PN*C(1:PIX,1); %% FPN [DN]

Dshot = (DARK/edn)^(0.5)*D(1:PIX,i); %% dark shot noise [DN]

DFPN = DARK*DN*F(1:PIX,1);  %% dark FPN [DN]

SIG1(1:PIX,i) = sig+read+shot+FPN + Dshot + DFPN;  %% read noise + shot noise + FPN + dark shot noise + dark FPN [DN]
SIG2(1:PIX,i) = sig+read+shot+FPN + Dshot;  %% read noise + shot noise + FPN + dark shot noise + dark FPN [DN]
SIG3(1:PIX,i) = sig+read+shot+Dshot;  %% read noise + shot noise + FPN + dark shot noise + dark FPN [DN]
SIG4(1:PIX,i) = sig+read+shot;  %% read noise + shot noise + FPN + dark shot noise + dark FPN [DN]
SIG5(1:PIX,i) = sig+read+shot+FPN;  %% read noise + shot noise + FPN + dark shot noise + dark FPN [DN]
end

SIGNAL = mean(SIG1);  %% signal [DN]
NOISE1 = std(SIG1);  %% noise
NOISE2 = std(SIG1);  %% noise
NOISE3 = std(SIG1);  %% noise
NOISE4 = std(SIG1);  %% noise
NOISE5 = std(SIG1);  %% noise

SIGNAL_e = SIGNAL*edn;  %% signal [e]
NOISE1_e = NOISE1*edn;
NOISE2_e = NOISE2*edn;
NOISE3_e = NOISE3*edn;
NOISE4_e = NOISE4*edn;
NOISE5_e = NOISE5*edn;

%%%  PTC Plot [DN]
figure, plot(SIGNAL, NOISE1), title('Photon transfer curve for CCD in WFS'), xlabel('Signal, Digital numbers [DN]'), ylabel('Noise (std), DN'), axis([0 10^4 0 10^3]);

figure, loglog(SIGNAL, NOISE1), title('Photon transfer curve for CCD in WFS'), xlabel('Signal, Digital numbers [DN]'), ylabel('Noise (std), DN'), axis([1 10^5 1 10^4]);
