%> @file test_noiselab_FPN_sensor.m
%> @brief Test function for study the influence of different noise probability density functions on FPN overall picture. Used as a preliminary groundtest for models on simulation of FPN
%> @author Mikhail V. Konnik
%> @date   8 February 2011

clear all
close all

addpath('/home/latitude/matlab/aorta/simulator/tools/');
sensor_signal_columns = 1000;
sensor_signal_rows = sensor_signal_columns;
DNcolumn = 0.2;

signallevel = 1000;

Signal_voltage = signallevel*ones(sensor_signal_rows);



%%%%%% Different models of noise: Gaussian noise for FPN
%  z = 50*(1+DNcolumn*randn([sensor_signal_rows, sensor_signal_columns]));


%%%%%% Different models of noise: LogNormal noise for FPN
lognorm_mu = 0;
lognorm_sigma = 0.8;
%  
%  x1 = fft2(1+DNcolumn*(stat_randraw('lognorm',[lognorm_msu, lognorm_sigma],[sensor_signal_rows, sensor_signal_columns])));
%  x2 = fft2(DNcolumn*rand(sensor_signal_rows, sensor_signal_columns));
%  z = 50*(ifft2(x1+x2));

z = 50*(1+DNcolumn*(stat_randraw('lognorm',[lognorm_mu, lognorm_sigma],[sensor_signal_rows, sensor_signal_columns])   ));

%  %%%%%% Different models of noise: Wald distribution noise for FPN
%  wald_parameter = 1.5; %% small parameters (w<1) produces estremely narrow distribution, large parameters (w>10) produces distribution with large tail.
%  z = 50*(1+DNcolumn*(stat_randraw('wald',wald_parameter,[sensor_signal_rows, sensor_signal_columns]) + rand(sensor_signal_rows, sensor_signal_columns))  );



%  %%%%%% Different models of noise: Logistics distribution noise for FPN
%  logistic_mu = 1; %% is the mean
%  logistic_sigma = 1.5; %%%is a parameter proportional to the standard deviation. Small sigma<0.5 leaads to dense pdf and centered; Large sigma > 2 leads to scattered
%  %
%  z = 50*(1+DNcolumn*(stat_randraw('logistic',[logistic_mu, logistic_sigma],[sensor_signal_rows, sensor_signal_columns]) + rand(sensor_signal_rows, sensor_signal_columns))  );
%  %  idx = (z<=0); %%% find all of pixels that are less than zero
%  %  z(idx) = 0; %%% truncate pixels that are less than zero to zero. (there no negative electrons).



%  Signal_voltage = Signal_voltage.*(1 + z*DNcolumn); %% <--- и это правильно!
%  %  Signal_voltage = Signal_voltage.*(1 + z*(DNcolumn^2));

%%%%%%%%%%%%%%%%%% FOR FPN MODELLING
%  Signal_voltage = signallevel*ones(sensor_signal_rows);
%  
%  x = randn(1,sensor_signal_columns);
%  y = filter(1, [1 0.5], x);
%  z = repmat(y,sensor_signal_rows,1);
%  
%  Signal_voltage = Signal_voltage.*(1 + z*(DNcolumn)); %% <--- и это правильно!
%  %  Signal_voltage = Signal_voltage.*(1 + z*(DNcolumn^2));
%%%%%%%%%%%%%%%%%% FOR FPN MODELLING

mean(z(:))
std(z(:))

figure, hist(z(1,1:sensor_signal_columns),200);
figure, imagesc(z);

%  mean(Signal_voltage(:))
%  std(Signal_voltage(:))
%  imagesc(Signal_voltage)
%  
