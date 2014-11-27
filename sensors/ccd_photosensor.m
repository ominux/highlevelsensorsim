%> @file ccd_photosensor.m
%> @brief This routine performs initial conversion of the light from the irradiance and photons to electrons.
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
function ccd = ccd_photosensor(Uin,ccd);

ccd = ccd_set_photosensor_constants(ccd,Uin); %%% defining the constants such as speed of light _c_, Plank's _h_ and others.


%%%%% <----- ### Start:: adding light noises
if (ccd.flag.darkframe ~= 1) %%%%%%%%#### Section: if this is NOT a complete darkness
    ccd = ccd_photosensor_lightnoises(ccd, Uin); 
end 
%%%%% <----- ### END:: adding light noises


%%%%% <----- ### Start:: adding dark current noise
if (ccd.flag.darkcurrent == 1)
     ccd = ccd_photosensor_darknoises(ccd);
end
%%%%% <----- ### END:: adding dark current noise


% FIXME: the sense node reset noise must be LOG-NORMAL!


%%%%% <----- ### Start:: adding dark current and light electrons 
ccd.Signal_CCD_electrons = ccd.light_signal + ccd.dark_signal;

% figure, imagesc(ccd.light_signal);
% figure, imagesc(ccd.dark_signal);

    %%%%%%%%%%%######### Full-well checkup (if there more electrons than depth of the pixel - saturate the pixel)
        idx = (ccd.Signal_CCD_electrons>=ccd.FW_e); %%% find all of pixels that are saturated (there are more electrons that full-well of the pixel)
        ccd.Signal_CCD_electrons(idx) = ccd.FW_e;  %% saturate the pixel if there are more electrons than full-well.

        idx = (ccd.Signal_CCD_electrons<0); %%% find all of pixels that are less than zero
        ccd.Signal_CCD_electrons(idx) = 0; %%% truncate pixels that are less than zero to zero. (there no negative electrons).
    %%%%%%%%%%%######### END Full-well checkup

ccd.Signal_CCD_electrons = floor(ccd.Signal_CCD_electrons);  %% round the number of electrons.        
%%%%% <----- ### END:: adding dark current and light electrons     


%%%%% <----- ### Start:: Sense Node - charge-to-voltage conversion
ccd = ccd_sense_node_chargetovoltage(ccd); %%% Charge-to-Voltage conversion by Sense Node
%%%%% <----- ### END:: Sense Node - charge-to-voltage conversion


%%%%% <----- ### Start:: Source Follower - Voltages
ccd = ccd_source_follower(ccd); %%% Signal's Voltage amplification by Source Follower
%%%%% <----- ### END:: Source Follower - Voltages


%%%%% <----- ### Start:: Correlated Double Sampling
ccd = ccd_cds(ccd); %%% Signal's amplification and denoising by Correlated Double Sampling
%%%%% <----- ### END:: Correlated Double Sampling


%%%%% <----- ### Start:: Analogue-To-Digital Converter
ccd = ccd_adc(ccd); %% Quantizator ADC
%%%%% <----- ### END:: Analogue-To-Digital Converter