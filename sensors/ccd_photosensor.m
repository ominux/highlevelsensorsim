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
function ccd = ccd_photosensor(Uin,lambda,ccd);

ccd = ccd_set_photosensor_constants(ccd,Uin); %%% defining the constants such as speed of light _c_, Plank's _h_ and others.


%%%%%%%%#### Section: complete darkness
if (ccd.flag.darkframe == 1)
    
    ccd.Signal_CCD_electrons = zeros(size(Uin));
    ccd.Signal_CCD_photons = ccd.Signal_CCD_electrons;
%%%%%%%%#### END Section: complete darkness

else %% if we don't measure the dark frame

           
    %%%%% Calculating the area of the pixel (in [m^2]).
    if (strcmp('CMOS',ccd.SensorType) == 1)
        PA = ccd.FillFactor*ccd.pixel_size(1)*ccd.pixel_size(2); %% PA is pixel area [m^2].
    else
        PA = ccd.pixel_size(1)*ccd.pixel_size(2); %% PA is pixel area, [m^2].
    end
    %%%%% END:: Calculating the area of the pixel (in [m^2]).



    %%%% Calculation of irradiance of the input light field. The input is the sensor irradiance  |Uin|^2  in [W/m^2].
    Uin_irradiance =  PA * abs(Uin).^2;  %% Converting to radiant flux per pixel in [W].

    P_photon = (ccd.h * ccd.c)/lambda;   %% Power of a single photon, in [Joule = Watt*s]
    ccd.Signal_CCD_photons = round(Uin_irradiance * ccd.t_I / P_photon); %% the result is the average number of photons (rounded).
    %%%% END:: Calculation of irradiance of the input light field. The input is the sensor irradiance  |Uin|^2  in [W/m^2].



    %%%%%%%%%%%######       Section: Photon Shot Noise
    if (ccd.flag.photonshotnoise == 1)
        ccd.Signal_CCD_photons = ccd_photosensor_photonshotnoise(ccd.Signal_CCD_photons);     %%% adding the Photon Shot noise to the Signal_CCD_photons.
    end
    %%%%%%%%%%%######### END Section: Photon Shot Noise



    %%%%%%% Converting the signal from Photons to Electrons:
    QE = (ccd.QE_I)*(ccd.QuantumYield);  %% Quantum Efficiency = Quantum Efficiency Interaction X Quantum Yield Gain.
    ccd.Signal_CCD_electrons = ccd.Signal_CCD_photons*QE; %% output signal of the CCD in electrons [e]


    %%%%%%%%%%%#####      Section: Photo Response Non-Uniformity
    if (ccd.flag.PRNU == 1)
       ccd = ccd_photosensor_lightFPN(ccd); %%introducing the PRNU that is QE non-uniformity
    end
    %%%%%%%%%%%####### END Section: Photo Response Non-Uniformity

      
end %%%if (ccd.flag.darkframe == 1)















%%%%%%%%####### Section: adding dark current noise
if (ccd.flag.darkcurrent == 1)
 ccd = ccd_photosensor_darkcurrentnoise(ccd);
end
%%%%%%%%####### END Section: adding dark current noise




%%%%%% Start: Adding dark current and noises to signal
ccd.Signal_CCD_electrons = round(ccd.Signal_CCD_electrons+ccd.dark_signal); %% making DFPN as a ROW-repeated noise, just like light FPN;
%%%%%% Start: Adding dark noises to signal



%%%%%%%%%%%######### Full-well checkup (if there more electrons than depth of the pixel - saturate the pixel)
    idx = (ccd.Signal_CCD_electrons>=ccd.FW_e); %%% find all of pixels that are saturated (there are more electrons that full-well of the pixel)
    ccd.Signal_CCD_electrons(idx) = ccd.FW_e;  %% saturate the pixel if there are more electrons than full-well.

    idx = (ccd.Signal_CCD_electrons<0); %%% find all of pixels that are less than zero
    ccd.Signal_CCD_electrons(idx) = 0; %%% truncate pixels that are less than zero to zero. (there no negative electrons).

    ccd.Signal_CCD_electrons = floor(ccd.Signal_CCD_electrons);  %% round the number of electrons.        
%%%%%%%%%%%######### END Full-well checkup

    
%% Up to here we have finished with ELECTRONS!


%%%%%%%%####### Section: Node sensing - charge-to-voltage conversion
ccd = ccd_sense_node_chargetovoltage(ccd); %%% Charge-to-Voltage conversion by Sense Node

ccd = ccd_source_follower(ccd); %%% Signal's Voltage amplification by Source Follower

ccd = ccd_cds(ccd); %%% Signal's amplification and denoising by Correlated Double Sampling
%%%%%%%%####### END Section: Node sensing - charge-to-voltage conversion


ccd = ccd_adc(ccd); %% Quantizator ADC