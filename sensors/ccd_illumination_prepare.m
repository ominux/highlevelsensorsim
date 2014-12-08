%> @file ccd_illumination_prepare.m
%> @brief This routine performs initial conversion of the light from the irradiance and photons to electrons.
%> @author Mikhail V. Konnik
%> @date   9 December 2014.
%> 
%> @section ccdphotosensor Convesrion from photons to electrons.
%> The process from incident photons to the digital numbers appeared on the image is outlined. See @ref secphoton2electron "this page" about particular implementation.
%>
%======================================================================
%> @param Uin		= light field incident on the photosensor [matrix NxM], [Watt/m2].
%> @param ccd		= structure that contains parameters of the sensor (exposure time and so on).
%>
%> @retval ccd 		= structure with new variable @b Signal_CCD_electrons signal of the photosensor in electrons [matrix NxM], [e].
% ======================================================================
function ccd = ccd_photosensor(Uin,ccd);

