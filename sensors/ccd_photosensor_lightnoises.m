%> @file ccd_photosensor_lightnoises.m
%> @brief This routine for adding light noise (photon shot noise and photo response non-uniformity, PRNU).
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%> 
%> @section secphoton2electron From Photon to Charge
%> The input to the model of the photosensor is assumed to be a matrix $U_{in} \in \mathbb{C}^{N\times M} $ that corresponds to the opical field. 
Then the sensor's irradiance $I_{irrad} = |U_{in}|^2$, which is in units of  [W/m$^2$], converted to the average number of photons $I_{ph}$ collected by each pixel during the integration (exposure) time:
\begin{equation}\label{eq:photonsignal}
 I_{ph}  =  round \left( \frac{ I_{irrad} \cdot P_A  \cdot t_I }{ Q_p} \right),
\end{equation}
where $P_A$ is the area of a pixel [m$^2$],  $t_{I}$ is integration (exposure) time, $Q_p = \frac{h\cdot c}{\lambda}$ is the energy of a single photon at wavelength $\lambda$, $h$ is Planck's constant and $c$ is the speed of light. 


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