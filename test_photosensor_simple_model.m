%> @file test_photosensor_model.m
%> @brief This tesing routine is necessary for testing the correctness of the operation of photosensor and its noise performance.
%>
%> @author Mikhail V. Konnik
%> @date   17 January 2011, re-worked on 8 December 2014.


clc
clear all
close all


addpath('sensors', 'propagation');




%%%%%%%%#### Start: Irradiance parameters
ccd.lambda = 550*10^(-9); % optical wavelength [m]
%%%%%%%%#### END  : Irradiance parameters


%%%%% <----- ### Start :: General parameters of the photosensor
N  = 256;         % number of grid points in the observation plane, on photo sensor NxN pixels. %% changes size of spot: smaller number=smaller spot, larger number - larger spectral
M  = 256;

%  	ccd.SensorType		= 'CCD';
	ccd.SensorType		= 'CMOS';

	ccd.pixel_size = [5*10^(-6), 5*10^(-6)] ;  %% pixels size, in [m], ROWxCOLUMN size

	ccd.t_I	  = 1*10^(-2); %%% Exposure/Integration time, [sec].

	ccd.QE_I          = 0.8;  %% Quantum Efficiency of the photo sensor.
	ccd.FillFactor    = 0.5;  %% Pixel Fill Factor for CMOS photo sensors.
	ccd.QuantumYield  = 1;  %% quantum yeild (number of electrons per one photon interaction). QuantumYield = 1 for visible light.
    
	ccd.FW_e  = 2*10^4; %% full well of the pixel (how many electrons can be stored in one pixel), [e]
	ccd.V_REF = 3.1; %%% Reference voltage to reset the sense node. [V] typically 3-10 V.
%%%%% <----- ###### END :: General parameters of the photosensor


    
%%%%% <----- ### Start :: Sense Nose 
    ccd.A_SN		= 5*10^(-6); %% Sense node gain, A_SN [V/e]

    ccd.flag.Venonlinearity = 0;%%%%% <-- ###### Gain non-linearity  [CMOS ONLY!!!!]
		if (ccd.flag.Venonlinearity == 1)
			ccd.nonlinearity.A_SNratio = 0.05; %% in how many times should A_SF be increased due to non-linearity?
		end %%% if (ccd.flag.VVnonlinearity == 1)                
%%%%% <----- ###### END :: Sense Nose 
    


%%%%% <----- ### Start:: Source Follower 
	ccd.A_SF		= 1; %%% Source follower gain, [V/V], lower means amplify the noise.

	ccd.flag.VVnonlinearity = 0; %%%%% <-- ###### Gain non-linearity  [CMOS ONLY!!!!]
		if (ccd.flag.VVnonlinearity == 1)
			ccd.nonlinearity.A_SFratio = 1.05; %% signal gets lower
%  			ccd.nonlinearity.A_SFratio = 0.95; %% signal gets HIGHER
		end %%% if (ccd.flag.VVnonlinearity == 1)
%%%%% <----- ###### END:: Source Follower 

	ccd.A_CDS		= 1; %%% Correlated Double Sampling gain, [V/V], lower means amplify the noise.

%%%% <----- ### Start:: Analogue-to-Digital Converter (ADC)
 	ccd.N_bits		 = 12; %% noise is more apparent on high Bits
    
    ccd.S_ADC_OFFSET = 0; %%% Offset of the ADC, in DN

	ccd.flag.ADCnonlinearity = 0; %%% turn the non-linea
		if (ccd.flag.ADCnonlinearity == 1)
			ccd.nonlinearity.ADCratio = 1.1; %% in how many times should A_ADC be decreased due to non-linearity?
		end %%% if (ccd.flag.ADCnonlinearity == 1)
%%%%% <-- ###### END:: Analogue-to-Digital Converter (ADC)



%% <----- ### Start:: Light Noise parameters

%%% START:: Simulation of the photon shot noise.
ccd.flag.photonshotnoise	= 1;
%%% END :: Simulation of the photon shot noise.

%%% START:: Simulation of the photo response non-uniformity noise (PRNU), or also called light Fixed Pattern Noise (light FPN)
ccd.flag.PRNU			= 1;

    ccd.noise.FPN.model	= 'Janesick-Gaussian';
 	ccd.PRNU_factor		= 0.01;  %% PRNU factor in percent [typically about 1\% for CCD and up to 5% for CMOS];
%%% END :: Simulation of the photo response non-uniformity noise (PRNU)
%%%%% <-- ###### END:: Light Noise parameters 


    
%% <----- ### Start:: Dark Current Noise parameters

%%% START:: Simulation of the dark signal
ccd.flag.darkcurrent		= 1;
        	ccd.T			= 300; %% operating temperature, [K]
            ccd.DFM			= 1;  %% dark current figure of merit, [nA/cm^2]. %%%% For very poor sensors, add DFM
%  Increasing the DFM more than 10 results to (with the same exposure time of 10^-6):
%  Hence the DFM increases the standard deviation and does not affect the mean value.
%%% END :: Simulation of the dark signal


%%% START:: Simulation of the dark current shot noise.
ccd.flag.darkcurrent_Dshot	= 1; 
%%% END :: Simulation of the dark current shot noise.


%%% START:: Simulation of the dark current Fixed Pattern Noise 
ccd.flag.darkcurrent_DarkFPN_pixel = 1;

if (ccd.flag.darkcurrent_DarkFPN_pixel == 1) %% uncomment the desirable model of dark current FPN below.

    ccd.noise.FPN.DN	= 0.3; %% the dark current FPN quality factor, which is typically between 10\% and 40\% for CCD and CMOS sensors

 	ccd.noise.FPN.model	= 'Janesick-Gaussian';

%  	ccd.noise.FPN.model	= 'LogNormal'; %%% suitable for long exposures
%  	ccd.noise.FPN.lognorm_parameter = [0, 0.4]; %%first is lognorm_mu; second is lognorm_sigma.

%  	ccd.noise.FPN.model	= 'AR-ElGamal';
%  	ccd.noise.FPN.ar_elgamal= [1 0.5];

% 	ccd.noise.FPN.model	= 'Wald';
% 	ccd.noise.FPN.wald_parameter = 2; %% small parameters (w<1) produces extremely narrow distribution, large parameters (w>10) produces distribution with large tail.

end %%  if (ccd.flag.darkcurrent_DarkFPN_pixel == 1)
%%% END :: Simulation of the dark current Fixed Pattern Noise 


%%% START:: Simulation of the dark current Offset Fixed Pattern Noise 
ccd.flag.darkcurrent_offsetFPN	= 1;

    if (ccd.flag.darkcurrent_offsetFPN == 1)
        ccd.noise.FPN.model	= 'Janesick-Gaussian';
        ccd.DNcolumn 		= 0.0005;  %% percentage of (V_REF - V_SN)
    end
%%% END :: Simulation of the dark current Offset Fixed Pattern Noise 


%%% START:: Simulation of the source follower noise.
ccd.flag.sourcefollowernoise	= 0;
if (ccd.flag.sourcefollowernoise == 1)
	ccd.noise.sf.t_s	= 10^(-6); %% is the CDS sample-to-sampling time [sec].
	ccd.noise.sf.f_c	= 10^6; %% flicker noise corner frequency $f_c$ in [Hz], where power spectrum of white and flicker noise are equal [Hz].
	ccd.f_clock_speed	= 20*10^(6); %%20 MHz data rate clocking speed.
	ccd.noise.sf.W_f	= 15*10^(-9); %% is the thermal white noise [\f$V/Hz^{1/2}\f$, typically \f$15 nV/Hz^{1/2}\f$ ]
	ccd.noise.sf.Delta_I	= 10^(-8); % [Amper] is the source follower current modulation induced by RTS [CMOS ONLY]
end %% if (ccd.flag.sourcefollowernoise == 1)
%%% END :: Simulation of the source follower noise.


%%% START:: Simulation of the sense node reset noise.
ccd.flag.sensenoderesetnoise	= 1; 
	ccd.snresetnoiseFactor	= 0.8; %% the compensation factor of the Sense Node Reset Noise: 
                                   %%    1 - fully compensated, 
                                   %%    0 - no compensation from CDS for Sense node reset noise.
%%% END :: Simulation of the sense node reset noise.




%%%## Subsection: Sensor noises and signal visualisators
ccd.flag.plots.irradiance	= 1;
ccd.flag.plots.electrons	= 1;
ccd.flag.plots.volts		= 1;
ccd.flag.plots.DN		    = 1;
%%%## Subsection: Sensor noises and signal visualisators

%%% For testing and measurements only:
ccd.flag.darkframe          = 0;
%%%%%%%%############### END Section: selectable parameters %%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%#### Start Illumination
if (ccd.flag.darkframe == 0)

    %%%%%%%%#### Section: Illumination
    amplitude_coeff = 0.1;

    % Uin = amplitude_coeff*ones(N,M);

    Uin = amplitude_coeff*ones(N).*prop_absorbing_window_supergaussian(N, 6, 0.4); %% input (source) optical field, possibly a complex matrix.


	%%%%%%%%%%%% Visualisation subsection.
	if (ccd.flag.plots.irradiance == 1)
	Uin_irradiance = abs(Uin).^2; %% computing the Irradiance [W/m^2] of the input optical field Uin.
    
	figure, imagesc(Uin_irradiance), title('Irradiance map of the light field [W/m^2].'); %% Irradiance map of the optical field.
	figure, plot(Uin_irradiance(round(N/2),1:M)), title('profile of the Irradiance map of the light field [W/m^2].'), xlabel('Number of Pixel on the photo sensor'), ylabel('Irradiance, [W/m^2]');  %% the profile of the Irradiance map

    end %% if (ccd.flag.plots.irradiance
	%%%%%%%%%%%% Visualisation subsection.

else  %% we simulate the dark frame only

    Uin = zeros(N);

end%% if (ccd.flag.darkframe == 1)
%%%%%%%%#### End Illumination


% break <--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%####### BEGIN::: Light registration with the model of the CCD/CMOS sensor  %%%%%%%%%%%%%%%%

    ccd = ccd_photosensor(Uin, ccd); %% here the Photon-to-electron conversion occurred.

%%%%%%%%####### END: Light registration with the model of the CCD/CMOS sensor      %%%%%%%%%%%%%%%%





%%%%%%%%%%%% Visualisation subsection.
if (ccd.flag.plots.irradiance == 1)
figure, imagesc(ccd.Signal_CCD_photons), title('Signal from the photosensor in Photons.'), colorbar;
end

if (ccd.flag.plots.electrons == 1)
figure, imagesc(ccd.Signal_CCD_electrons), title('Signal from the photosensor in electrons.'), colorbar; %%
figure, imagesc(log10(abs(ccd.Signal_CCD_electrons))), title('Log-log Signal from the photosensor in electrons.'), colorbar;
end

if (ccd.flag.plots.volts == 1)
figure, imagesc(ccd.Signal_CCD_voltage), title('Signal from the photosensor in Volts.'), colorbar; %%
figure, imagesc(log10(abs(ccd.Signal_CCD_voltage))), title('Log-Log Signal from the photosensor in Volts.'), colorbar; %%
end

if (ccd.flag.plots.DN == 1)
figure, imagesc(ccd.Signal_CCD_DN), title('Signal from the photosensor in DN.'), colorbar; %%
figure, imagesc(log10(abs(ccd.Signal_CCD_DN))), title('Log-Log Signal from the photosensor in DN.'); %%
end
%%%%%%%%%%%% END Visualisation subsection.