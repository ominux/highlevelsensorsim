%> @file ccd_photosensor_darkFPN.m
%> @brief This routine for adding dark current noises that consist of Dark FPN and Dark shot noise.
%>
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%>
%> @section darkfpn Dark Fixed Pattern Noise

%======================================================================
%> @param dark_signal 	= matrix [NxM] of dark signals that contain @b only dark current noise [e-].
%> @retval dark_signal 	= matrix [NxM] of dark signals that contain Dark FPN [e-].
% ======================================================================
function ccd = ccd_photosensor_darkFPN(ccd)
  
%%% the random generator will be fixed on seed 362436128
                    rand( 'state', 362436128); %%% Fix the state of the rand  random generator
                    randn('state', 362436128); %%% Fix the state of the randn random generator


ccd.FPN.pixelDark = ccd_FPN_models(ccd, ccd.sensor_size(1), ccd.sensor_size(2), 'pixel');

ccd.dark_signal = ccd.dark_signal.*(1 + (ccd.noise.FPN.DN)*(ccd.FPN.pixelDark)); %% add pixel FPN dark noise.