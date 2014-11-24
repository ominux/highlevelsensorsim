%> @file ccd_initialise_photosensor.m
%> @brief Initialisation of less important parameters and construction of the ccd structure for the photosensor.
%>
%> @author Mikhail V. Konnik
%> @date   16 June 2011
%>
%======================================================================
%> @param ccd 	= structure that contains initial parameters, such as exposure time.
%> @retval ccd  = structure that contains other parameters, such as Silicon bandgap and others.
% ======================================================================
function ccd = ccd_initialise_photosensor(ccd);

%%%%%%%%## Subsection: General photosensor settings
ccd.flag.darkframe 		= 0; %%%%%%%%%%% DARK NOISE EXPERIMENTS ONLY
ccd.flag.PRNUmeaserements	= 0; %%%%%%%%%%% PRNU NOISE EXPERIMENTS ONLY

%%%%%%%%## Subsection: General photosensor settings

	ccd.pixel_size		= [5*10^(-6), 5*10^(-6)] ;  %% pixels size, in [m], ROWxCOLUMN size

	ccd.QE_I		= 0.6;  %% quantum efficiency of the photo sensor.
	ccd.FillFactor		= 0.5;  %% Pixel Fill Factor for CMOS photo sensors.
	ccd.QuantumYield	= 1;  %% quantum yeild (number of electrons per one interaction). QuantumYield = 1 for visible light.
	ccd.V_REF		= 3.1; %%% Reference voltage to reset the sense node. [V] typically 3-10 V.

	ccd.Boltzman_Constant	= 8.617343*10^(-5); %%% Boltzman constant, [eV/K].
	ccd.Boltzman_Constant_JK= 1.3806504*10^(-23); %%% Boltzman constant, [J/K].
	ccd.q 			= 1.602176487*10^(-19); %% a charge of an electron [C], Cylon
	ccd.k1			= 10.909*10^(-15); %% a constant;

	ccd.A_SN		= 5*10^(-6); %% Sense node gain, A_SN [V/e]
	ccd.Eg_0		= 1.1557; %% bandgap energy for 0 K. [For Silicon, eV]
	ccd.alpha		= 7.021*10^(-4); %% material parameter, [eV/K].
	ccd.beta		= 1108; %% material parameter, [K].
	ccd.FW_e		= 2*10^4; %% full well of the pixel (how many electrons can be stored in one pixel), [e]

	ccd.flag.Venonlinearity = 0; %%%%% <-- ###### Gain non-linearity Subsection [CMOS ONLY!!!!]
		if (ccd.flag.Venonlinearity == 1)
			ccd.nonlinearity.A_SNratio = 0.00; %% in how many times should A_SF be increased due to non-linearity?
		end %%% if (ccd.flag.VVnonlinearity == 1)


%%%%% <----- ### Start:: Source Follower Subsection
	ccd.A_SF		= 1; %%% Source follower gain, [V/V], lower means amplify the noise.

	ccd.flag.VVnonlinearity = 0; %%%%% <-- ###### Gain non-linearity Subsection [CMOS ONLY!!!!]
		if (ccd.flag.VVnonlinearity == 1)
			ccd.nonlinearity.A_SFratio = 1.05; %% signal gets lower
%  			ccd.nonlinearity.A_SFratio = 0.95; %% signal gets HIGHER
		end %%% if (ccd.flag.VVnonlinearity == 1)
%%%%% <----- ### END:: Source Follower Subsection

	ccd.A_CDS		= 1; %%% Correlated Double Sampling gain, [V/V], lower means amplify the noise.

%%%%% <----- ### Start:: ADC Subsection
	ccd.S_ADC_OFFSET	= 0; %%% Offset of the ADC, in DN

	ccd.flag.ADCnonlinearity= 0; %%% turn the non-linea
		if (ccd.flag.ADCnonlinearity == 1)
			ccd.nonlinearity.ADCratio = 1.1; %% in how many times should A_ADC be decreased due to non-linearity?
		end %%% if (ccd.flag.ADCnonlinearity == 1)
%%%%% <-- ###### END:: ADC Subsection
%%%## END Subsection: General photosensor settings;

%%%%%%%%## Subsection: photosensor NOISE settings




ccd.flag.darkcurrent_offsetFPN	= 0;
if (ccd.flag.darkcurrent_offsetFPN == 1)
	ccd.noise.FPN.model	= 'Janesick-Gaussian';
	ccd.DNcolumn 		= 0.000;  %% percentage of (V_REF - V_SN)
end

ccd.flag.sourcefollowernoise	= 0;
if (ccd.flag.sourcefollowernoise== 1)
	ccd.noise.sf.t_s	= 10^(-6); %% is the CDS sample-to-sampling time [sec].
	ccd.noise.sf.f_c	= 10^6; %% flicker noise corner frequency $f_c$ in [Hz], where power spectrum of white and flicker noise are equal [Hz].
	ccd.f_clock_speed	= 20*10^(6); %%20 MHz data rate clocking speed.
	ccd.noise.sf.W_f	= 15*10^(-9); %% is the thermal white noise [\f$V/Hz^{1/2}\f$, typically \f$15 nV/Hz^{1/2}\f$ ]
	ccd.noise.sf.Delta_I	= 10^(-8); % [Amper] is the source follower current modulation induced by RTS [CMOS ONLY]
end %% if (ccd.flag.sourcefollowernoise == 1)

ccd.flag.sensenoderesetnoise	= 0; %%%<---- THIS NOISE IS WRONG!! ACTS QUIEER!!!!!!!!!!
	ccd.snresetnoiseFactor	= 0.1;
%%%%%%%%## END Subsection: photosensor NOISE settings