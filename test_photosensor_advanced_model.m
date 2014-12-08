%> @file test_photosensor_advanced_model.m
%> @brief This is the _COMPREHENSIVE_ model of a CMOS/CCD photosensor, with non-linearities.
%>
%> @author Mikhail V. Konnik
%> @date   17 January 2011, re-worked on 8 December 2014.

clc
clear all
close all



addpath('sensors');
[m, cm, mm, mum, nm, rad, mrad] = tool_define_metrics; 
 

%%%%% <----- ### Start :: Illumination parameters  
    ccd.illumination.input_screen_size = 1*m;
    ccd.illumination.input_screen_hole_size = 0.7*m;
    ccd.illumination.input_screen_blur = 0.2*m;

    ccd.illumination.amplitude_coeff = 0.1;
    
    ccd.lambda = 550*nm; % optical wavelength [m]
%%%%% <----- ###### END :: Illumination parameters
 

%%%%% <----- ### Start :: General parameters of the photosensor
N  = 256;         % size of the input plane and sensor pixels, NxM pixels. 
M  = 256;

%% Select (uncomment) the type of a photo sensor
% ccd.SensorType        = 'CCD';
ccd.SensorType      = 'CMOS';
 
    ccd.pixel_size = [5*mum, 5*mum] ;  %% pixels size, in [m], ROWxCOLUMN size
 
    ccd.t_I   = 1*10^(-2); %%% Exposure/Integration time, [sec].
 
    ccd.QE_I          = 0.8;  %% Quantum Efficiency of the photo sensor.
    ccd.FillFactor    = 0.5;  %% Pixel Fill Factor for CMOS photo sensors.
    ccd.QuantumYield  = 1;  %% quantum yield (number of electrons per one photon interaction). QuantumYield = 1 for visible light.
    
    ccd.FW_e  = 2*10^4; %% full well of the pixel (how many electrons can be stored in one pixel), [e]
    ccd.V_REF = 3.1; %%% Reference voltage to reset the sense node. [V] typically 3-10 V.
%%%%% <----- ###### END :: General parameters of the photosensor
 

    
%%%%% <----- ### Start :: Sense Nose 
    ccd.A_SN		= 5*10^(-6); %% Sense node gain, A_SN [V/e]

    ccd.flag.Venonlinearity = 0;%%%%% <-- ###### Gain non-linearity  [CMOS ONLY!!!!]
		ccd.nonlinearity.A_SNratio = 0.05; %% in how many times should A_SF be increased due to non-linearity?
%%%%% <----- ###### END :: Sense Nose 
    


%%%%% <----- ### Start:: Source Follower 
	ccd.A_SF		= 1; %%% Source follower gain, [V/V], lower means amplify the noise.

	ccd.flag.VVnonlinearity = 0; %%%%% <-- ###### Gain non-linearity  [CMOS ONLY!!!!]
        ccd.nonlinearity.A_SFratio = 1.05; %% signal gets lower
%  		ccd.nonlinearity.A_SFratio = 0.95; %% signal gets HIGHER
%%%%% <----- ###### END:: Source Follower 


%%%%% <----- ### Start:: Correlated Double Sampling
    ccd.A_CDS       = 1; %%% Correlated Double Sampling gain, [V/V], lower means amplify the noise.
%%%%% <----- ###### END:: Correlated Double Sampling


%%%% <----- ### Start:: Analogue-to-Digital Converter (ADC)
 	ccd.N_bits		 = 12; %% noise is more apparent on high Bits
    
    ccd.S_ADC_OFFSET = 0; %%% Offset of the ADC, in DN

	ccd.flag.ADCnonlinearity = 0; %%% turn the non-linea
			ccd.nonlinearity.ADCratio = 1.1; %% in how many times should A_ADC be decreased due to non-linearity?
%%%%% <-- ###### END:: Analogue-to-Digital Converter (ADC)



%% <----- ### Start:: Light Noise parameters

%%% START:: Simulation of the photon shot noise.
ccd.flag.photonshotnoise = 1;
%%% END :: Simulation of the photon shot noise.


%%% START:: Simulation of the photo response non-uniformity noise (PRNU), or also called light Fixed Pattern Noise (light FPN)
ccd.flag.PRNU  = 1; 
    ccd.noise.PRNU.model    = 'Janesick-Gaussian'; ccd.noise.PRNU.parameters = [];
    ccd.noise.PRNU.factor   = 0.01;  %% PRNU factor in percent [typically about 1\% for CCD and up to 5% for CMOS];
%%% END :: Simulation of the photo response non-uniformity noise (PRNU)

%%%%% <-- ###### END:: Light Noise parameters 


    
%% <----- ### Start:: Dark Current Noise parameters

%%% START:: Simulation of the dark signal
ccd.flag.darkcurrent  = 1;
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

        ccd.noise.darkFPN.DN = 0.3; %% the dark current FPN quality factor, which is typically between 10\% and 40\% for CCD and CMOS sensors
 
%         ccd.noise.darkFPN.model = 'Janesick-Gaussian'; ccd.noise.darkFPN.parameters = [];
 
      ccd.noise.darkFPN.model      = 'LogNormal'; %%% suitable for long exposures
      ccd.noise.darkFPN.parameters = [0, 0.4]; %%first is lognorm_mu; second is lognorm_sigma.

%  	ccd.noise.darkFPN.model	= 'AR-ElGamal';
%  	ccd.noise.darkFPN.parameters = [1 0.5];

%       ccd.noise.darkFPN.model       = 'Wald';
%       ccd.noise.darkFPN.parameters  = 2; %% small parameters (w<1) produces extremely narrow distribution, large parameters (w>10) produces distribution with large tail.

%%% END :: Simulation of the dark current Fixed Pattern Noise 


%%% START:: Simulation of the dark current Offset Fixed Pattern Noise 
ccd.flag.darkcurrent_offsetFPN	= 1;
        ccd.noise.darkFPN_offset.model  = 'Janesick-Gaussian'; ccd.noise.darkFPN_offset.parameters = [];
        ccd.noise.darkFPN_offset.DNcolumn       = 0.0005;  %% percentage of (V_REF - V_SN)
%%% END :: Simulation of the dark current Offset Fixed Pattern Noise 



%%% START:: Simulation of the source follower noise.
ccd.flag.sourcefollowernoise  = 1;
    ccd.noise.sf.t_s            = 10^(-6); %% is the CDS sample-to-sampling time [sec].
	ccd.noise.sf.f_c            = 10^6; %% flicker noise corner frequency $f_c$ in [Hz], where power spectrum of white and flicker noise are equal [Hz].
	ccd.noise.sf.f_clock_speed	= 20*10^(6); %%20 MHz data rate clocking speed.
	ccd.noise.sf.W_f            = 15*10^(-9); %% is the thermal white noise [\f$V/Hz^{1/2}\f$, typically \f$15 nV/Hz^{1/2}\f$ ]
	ccd.noise.sf.Delta_I        = 10^(-8); % [Amper] is the source follower current modulation induced by RTS [CMOS ONLY]
    ccd.noise.sf.sampling_delta_f = 10000; %% sampling spacing for the frequencies (e.g., sample every 10kHz);

%%% END :: Simulation of the source follower noise.


%%% START:: Simulation of the sense node reset noise.
ccd.flag.sensenoderesetnoise  = 1; 
       ccd.noise.sn_reset.Factor = 0.8; %% the compensation factor of the Sense Node Reset Noise: 
                                     %%    1 - no compensation from CDS for Sense node reset noise.
                                     %%    0 - fully compensated SN reset noise by CDS.
%%% END :: Simulation of the sense node reset noise.




%%%## Subsection: Sensor noises and signal visualisators
ccd.flag.plots.irradiance	= 1;
ccd.flag.plots.electrons	= 1;
ccd.flag.plots.volts		= 1;
ccd.flag.plots.DN		    = 1;
%%%## Subsection: Sensor noises and signal visualisators

%%% For testing and measurements only:
ccd.flag.writetotiff		= 0; %%% output of the image to TIFF file
ccd.flag.darkframe          = 0;
%%%%%%%%############### END Section: selectable parameters %%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%#### Start Illumination
if (ccd.flag.darkframe == 0) %% that is, we have light illumination for our software sensor    

    Uin = ccd_illumination_prepare(ccd, N, M);

else  %% we simulate the dark frame only

    Uin = zeros(N);

end%% if (ccd.flag.darkframe == 1)
%%%%%%%%#### End Illumination





% break %% <--- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




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


%%%%%%%%%%####        Section: Write down the image to TIFF file
if (ccd.flag.writetotiff == 1)
tool_photosensor_image_output(ccd); %%% Write down files in TIFF FORMAT
end
%%%%%%%%%%####### END Section: Write down the image to TIFF file