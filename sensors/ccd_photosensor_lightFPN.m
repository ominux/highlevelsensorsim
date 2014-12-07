%> @file ccd_photosensor_lightFPN.m
%> @brief Adding the PRNU light noise to the sensor signal.
%> @author Mikhail V. Konnik
%> @date   17 January 2011, improved 5 December 2014
%>
%> @section prnusim Simulation of photo response non-uniformity (PRNU)
%> The Photo Response Non-Uniformity (PRNU) is the spatial variation in pixel output under uniform illumination mainly due to variations in the surface area of the photodiodes. This occurs due to variations in substrate material during the fabrication of the sensor.
%> 
%> The PRNU is signal-dependent (proportional to the input signal) and is fixed-pattern (time-invariant). The PRNU factor is typically \f$0.01\dots 0.02\f$ for a given sensor, but varies from one sensor to another.
%> 
%> The photo response non-uniformity (PRNU) is considered in our numerical model as a temporally-fixed light signal non-uniformity. According to our experimental results, the PRNU can be modelled using a Gaussian distribution for each \f$(i,j)\f$-th pixel of the matrix \f$I_{e^-}\f$:
%> 
%> \f$I_{PRNU.e^-}  = I_{e^-} +I_{e^-} \cdot \mathcal{N}(0,\sigma_{PRNU}^2)\f$
%> 
%> where \f$\sigma_{PRNU}\f$ is the PRNU factor value. 
%======================================================================
%> @param ccd 		= structure without PRNU added to signal
%> @retval ccd	 	= signal with added PRNU to variable @b Signal_CCD_electrons that is signal of the photosensor in electrons [matrix NxM], [e].
% ======================================================================
function ccd = ccd_photosensor_lightFPN(ccd)

%%% the random generator will be fixed on seed 362436069
                    rand( 'state', 362436069); %%% Fix the state of the rand  random generator
                    randn('state', 362436069); %%% Fix the state of the randn random generator
% % % % %                     rand('state', sum(100*clock));
% % % % %                     randn('state', sum(100*clock));


ccd.noise.PRNU.noisematrix = ccd_FPN_models(ccd, ccd.sensor_size(1), ccd.sensor_size(2), 'pixel', ccd.noise.PRNU.model); %% getting the matrix for the PRNU

ccd.light_signal = ccd.light_signal.*(1 + (ccd.noise.PRNU.noisematrix)*(ccd.noise.PRNU.factor)); %% apply the PRNU noise to the light signal of the photosensor.