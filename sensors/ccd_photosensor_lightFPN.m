%> @file ccd_photosensor_lightFPN.m
%> @brief This routine performs initial conversion of the light from the irradiance and photons to electrons.
%> @todo: make the Photon Shot Noise selectable and turn it on/off
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%>
%> @section prnusim Gain FPN or PRNU
%> Gain FPN is photo response non-uniformity (PRNU, or Light FPN) that is a pixel-to-pixel variation in the sensor responsivity. Gain FPN can be described as the gain or ratio between irradiance on a pixel versus the electrical signal output. For example, although a sensor may be quoted as having a \f$4\mu m \times 4\mu m\f$ pixel, in reality, there will be a variation in pixel size across the array.
%>
%> Each pixel has a slightly different sensitivity to light is commonly called ``Photo Response Non Uniformity'' or light FPN\cite{janesickscintificCCD} is due to limitations in the fabrication process such as variations in the photomask alignment\cite{irie2008model} and slight variations in pixel geometry and substrate material. The effect of PRNU is proportional to illumination, and is prominent under high illumination levels\cite{gamalCMOSimagesensors}.
%>
%> Since PRNU is caused by the physical properties of a sensor, it is nearly impossible to eliminate and usually considered a normal characteristic of the sensor array. Typically the non-uniformity is only 1-2\%~\cite{janesickscintificCCD} that is more difficult to remove \cite{hpsensorsnoise}. Usually single error factor the PRNU (2\%) is prominent, photon shot noise is secondly\cite{irie2008model}.  The PRNU can be simulated as a variance of the quantum efficiency matrix. For instance, we can have QE coefficient with \f$\mu = 1\f$ and \f$\sigma = PN\f$, where PN is FPN/PRNU factor in percent.
%>
%> It is measured at a given integration time, temperature, and gain under uniform lighting conditions (typically at half of the saturation level).  This area variation will contribute to Gain FPN.  For megapixel area arrays, PRNU is quantified\cite{pixelLinkCameraParams} as: @n 
%>  \f$PRNU = \frac{\sigma}{FrameMean} \% \f$
%>
%> Gain FPN can be pixel and column as well and depends on the type and architecture of the photosensor.
%======================================================================
%> @param ccd 		= structure without PRNU added to signal
%> @retval ccd	 	= signal with added PRNU to variable @b Signal_CCD_electrons that is signal of the photosensor in electrons [matrix NxM], [e].
% ======================================================================
function ccd = ccd_photosensor_lightFPN(ccd)

%%%%%%%%%% Section: Fixed Pattern NOISE
ccd = ccd_photosensor_FPN_modelling(ccd); %% call the function to calculate the AR(1) FPN model

ccd.Signal_CCD_electrons = ccd.Signal_CCD_electrons.*(1 + (ccd.FPN.pixelLight)*(ccd.PRNU_factor)); %% add pixel FPN dark noise.
%%%%%%%%%% END: Section: Fixed Pattern  NOISE