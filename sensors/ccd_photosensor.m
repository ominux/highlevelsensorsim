%> @file ccd_photosensor.m
%> @brief This routine performs initial conversion of the light from the irradiance and photons to electrons.
%> @todo: make the Photon Shot Noise selectable and turn it on/off
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%> @section ccdphotosensor Convesrion from photons to electrons.
%> The process from incident photons to the digital numbers appeared on the image is outlined. 
%>
%> @section conversionphton Conversion to photons
%> Photon quantities of light energy are also common. They are related to the radiometric quantities by the relationship \f$Q_p = hc/\lambda\f$ where \f$Q_p\f$ is the energy of a photon at wavelength \f$\lambda\f$, \f$h\f$ is Planck's constant and \f$c\f$ is the velocity of light. At a wavelength of \f$1 \mu m\f$, there are approximately \f$5\times10^{18}\f$ photons per second in a watt. Conversely, a single photon has an energy of \f$2\times10^{-19}\f$ joules (W s) at \f$\lambda = 1 \mu m\f$.@n
%> Philosophical question. If we have 1.8 electrons - what does it mean? There is not enough energy to generate the electron. So the quantity must be floored.
%======================================================================
%> @param Uout		= light field incident on the photosensor [matrix NxM], [Watt/m2].
%> @param lambda	= optical wavelength [m]
%> @param ccd		= structure that contains parameters of the sensor (exposure time and so on).
%>
%> @retval ccd 		= structure with new variable @b Signal_CCD_electrons signal of the photosensor in electrons [matrix NxM], [e].
% ======================================================================
function ccd = ccd_photosensor(Uout,lambda,ccd);

%%%%%%% Section: Fundamental constants
h = 6.62606896*10^(-34); %%% Plank's constant, in [Joule*s]
c = 2.99792458*10^8; %% speed of light, in [m/s].
%%%%%%% END Section: Fundamental constants

if (ccd.flag.darkframe == 1)
%%%%%%%%#### Section: complete darkness
	ccd.Signal_CCD_electrons = zeros(size(Uout));
%%%%%%%%#### END Section: complete darkness
else 
    
%%%% Calculation of intensity of the light field.
Uout_irradiance =  abs(Uout).^2;
%%%%%%%%#### Section: Illumination and propagation

P_photon = (h*c)/lambda;   %% Power of a single photon, in [Joule = Watt*s]
ccd.Uout_irradiance = round(Uout_irradiance./P_photon); %% Converting radiant flux (radiant energy per second, [Watt]) into irradiance in photons, in [photons/(m^2 * sec)]. irradiance in photons, in [photons/(m^2 * sec)]


if (strcmp('CMOS',ccd.SensorType) == 1)
	PA = ccd.FillFactor*ccd.pixel_size(1)*ccd.pixel_size(2); %% pixel area, [m2]
else
	PA = ccd.pixel_size(1)*ccd.pixel_size(2); %% pixel area, [m2]
end %% if (strcmp('CMOS',ccd.SensorType) == 1)

%%%%%%% Section: Actually performing the conversion from the photons to electrons
ccd.Signal_CCD_photons = round(ccd.Uout_irradiance*PA*ccd.t_I); %% Now the signal is converted directly to PHOTONS, and the number is ROUNDED since there are no 3.2 photons.


  	%%%%%%%%#####      Subsection: FOR MEASURING PRNU
	if (ccd.flag.PRNUmeaserements == 1)  %%% this part makes gradient lightsource for PRNU measurements
		r = size(Uout,1);
		z = 0:(1/(r-1)):1;
		prnu_mask = repmat(z,(r),1); %%% make a matrix from the one string by repeating of the elements.
		ccd.Signal_CCD_photons = (ccd.Signal_CCD_photons).*prnu_mask;
	end
  	%%%%%%%%####### End Subsection: FOR MEASURING PRNU


%%%%%%%%%%%######       Section: Photon Shot Noise
if (ccd.flag.photonshotnoise == 1)
	ccd.Signal_CCD_photons = ccd_photosensor_photonshotnoise(ccd.Signal_CCD_photons); %%% Now adding Photon Shot noise: it cannot be turned off or on since this is inevitable noise due to quantum nature of light.
end
%%%%%%%%%%%######### END Section: Photon Shot Noise

	QE = (ccd.QE_I)*(ccd.QuantumYield);  %% Quantum Efficiency = Quantum Efficiency Interaction X Quantum Yield Gain.
	ccd.Signal_CCD_electrons = ccd.Signal_CCD_photons*QE; %% output signal of the CCD in electrons [e]

%%%%%%%%%%%#####      Section: Photo Response Non-Uniformity
if (ccd.flag.PRNU == 1)
	ccd = ccd_photosensor_lightFPN(ccd); %%introducing the PRNU that is QE non-uniformity
end
%%%%%%%%%%%####### END Section: Photo Response Non-Uniformity
%%%%%%% END Section: Actually performing the conversion from the photons to electrons
end %%%if (ccd.flag.darkframe == 1)



%%%%%%%%%%%######### Full-well checkup (if there more electrons than depth of the pixel - saturate the pixel)
idx = (ccd.Signal_CCD_electrons>=ccd.FW_e); %%% find all of pixels that are saturated (there are more electrons that full-well of the pixel)
ccd.Signal_CCD_electrons(idx) = ccd.FW_e;  %% saturate the pixel if there are more electrons than full-well.

idx = (ccd.Signal_CCD_electrons<0); %%% find all of pixels that are less than zero
ccd.Signal_CCD_electrons(idx) = 0; %%% truncate pixels that are less than zero to zero. (there no negative electrons).
%%%%%%%%%%%######### END Full-well checkup


ccd.Signal_CCD_electrons = floor(ccd.Signal_CCD_electrons);  %% round the number of electrons.


%%%%%%%%####### Section: adding dark current noise
if (ccd.flag.darkcurrent == 1)
 ccd = ccd_photosensor_darkcurrentnoise(ccd);
end
%%%%%%%%####### END Section: adding dark current noise


%%%%%%%%####### Section: Node sensing - charge-to-voltage conversion
ccd = ccd_sense_node_chargetovoltage(ccd); %%% Charge-to-Voltage conversion by Sense Node
ccd = ccd_source_follower(ccd); %%% Signal's Voltage amplification by Source Follower
ccd = ccd_cds(ccd); %%% Signal's amplification and denoising by Correlated Double Sampling
%%%%%%%%####### END Section: Node sensing - charge-to-voltage conversion


ccd = ccd_adc(ccd); %% Quantizator ADC