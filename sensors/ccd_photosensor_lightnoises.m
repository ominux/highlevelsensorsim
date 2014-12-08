%> @file ccd_photosensor_lightnoises.m
%> @brief This routine for adding light noise (photon shot noise and photo response non-uniformity, PRNU).
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011, reworked on 5 December 2014
%> 
%> @section secphoton2electron From Photon to Charge
%> The input to the model of the photosensor is assumed to be a matrix \f$U_{in}\in \mathbb{C}^{N\times M} \f$ 
%> that corresponds to the opical field.  Then the
%> sensor's irradiance \f$I_{irrad} = |U_{in}|^2\f$, which is in units of 
%> [W/m\f$^2\f$], converted to the average number of photons \f$I_{ph}\f$ collected
%> by each pixel during the integration (exposure) time:
%> 
%> \f$ I_{ph}  =  round \left( \frac{ I_{irrad} \cdot P_A  \cdot t_I }{ Q_p} \right),\f$
%> 
%> where \f$P_A\f$ is the area of a pixel [m\f$^2\f$],  \f$t_{I}\f$ is integration
%> (exposure) time, \f$Q_p = \frac{h\cdot c}{\lambda}\f$ is the energy of a single
%> photon at wavelength \f$\lambda\f$, \f$h\f$ is Planck's constant and \f$c\f$ is
%> the speed of light. 
%> 
%> @subsection photonshotnoiseadd Photon Shot noise simulation
%> The process of photon capturing has an uncertainty that arises from random
%> fluctuations when photons are collected by the photodiode. Such uncertainty
%> leads to photon shot noise and is described by the Poisson process. In the case
%> of a high level  of light  (more than 1000 arrival events of photons), the
%> Poisson distribution may be approximated by a Gaussian distribution. However,
%> this is not justified for low-light conditions. The simulation of photon shot
%> noise is described @ref photonshotnoisesimulation "here".
%> 
%> @subsection PRNUadd Photo response non-uniformity
%> The Photo Response Non-Uniformity (PRNU) is the spatial variation in pixel
%> output under uniform illumination mainly due to variations in the surface area
%> of the photodiodes. This occurs due to variations in substrate material during
%> the fabrication of the sensor. The PRNU is signal-dependent (proportional to the
%> input signal) and is fixed-pattern (time-invariant). The PRNU factor is
%> typically \f$0.01\dots 0.02\f$ for a given sensor, but varies from one sensor to
%> another. The simulation of the PRNU noise is described @ref prnusim "here".
%======================================================================
%> @param ccd 		= structure of signal without dark current noises.
%> @param Uin       = the matrix [NxM] of the input optical field.
%> @retval ccd 		= constants added to the ''ccd.'' structure
% ======================================================================
function ccd = ccd_photosensor_lightnoises(ccd, Uin)


%%%%% <----- ### Start:: Calculating the area of the pixel (in [m^2]).
if (strcmp('CMOS',ccd.SensorType) == 1)
    PA = ccd.FillFactor*ccd.pixel_size(1)*ccd.pixel_size(2); %% for CMOS, taking into account the Fill Factor.
else
    PA = ccd.pixel_size(1)*ccd.pixel_size(2);
end
%%%%% <----- ### END:: Calculating the area of the pixel (in [m^2]).



%%%%% <----- ### Start:: Calculation of irradiance of the input light field. The input is the sensor irradiance  |Uin|^2  in [W/m^2].
Uin_irradiance =  PA * abs(Uin).^2;  %% Converting to radiant flux per pixel in [W].

P_photon = (ccd.h * ccd.c)/ ccd.lambda;   %% Power of a single photon, in [Joule = Watt*s]
ccd.Signal_CCD_photons = round(Uin_irradiance * ccd.t_I / P_photon); %% the result is the average number of photons (rounded).
%%%%% <----- ### END:: Calculation of irradiance of the input light field. The input is the sensor irradiance  |Uin|^2  in [W/m^2].



%%%%% <----- ### Start:: adding Photon Shot Noise
if (ccd.flag.photonshotnoise == 1)
    ccd.Signal_CCD_photons = ccd_photosensor_photonshotnoise(ccd.Signal_CCD_photons);     %%% adding the Photon Shot noise to the Signal_CCD_photons.
end
%%%%% <----- ### END:: adding Photon Shot Noise



%%%%% <----- ### Start:: Converting the signal from Photons to Electrons
    QE = (ccd.QE_I)*(ccd.QuantumYield);  %% Quantum Efficiency = Quantum Efficiency Interaction X Quantum Yield Gain.

    ccd.light_signal = ccd.Signal_CCD_photons*QE; %% output signal of the CCD in electrons [e]
%%%%% <----- ### END:: Converting the signal from Photons to Electrons


%%%%% <----- ### Start:: adding Photo Response Non-Uniformity
if (ccd.flag.PRNU == 1)
   ccd = ccd_photosensor_lightFPN(ccd); %%introducing the PRNU that is QE non-uniformity
end
%%%%% <----- ### END:: adding Photo Response Non-Uniformity