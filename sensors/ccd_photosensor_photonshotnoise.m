%> @file ccd_photosensor_photonshotnoise.m
%> @brief This routine adds photon shot noise to the signal of the photosensor that is in photons.
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%>
%> @section ccdphotosensor Convesrion from photons to electrons: Photon shot noise
%> Due to the quantum character of light, the capture of photons is a Poisson process that arises from random fluctuations in sampling when discrete photons are measured. So the photon shot noise is due to quantum nature of light. The standard deviation of the photon shot noise is equal to the square root of the average number of photons, i.e.\f$\sigma_{ph} = \sqrt{N}\f$; where \f$N\f$ is the average number of photons shooting in one pixel~\cite{shwfsnoiseccd}.
%> 
%> Photon shot noise is described by Poisson probability distribution:
%> \f$p_i = \frac{P_I^i}{i!} e^{-P_I},\f$
%> 
%> where \f$p_i\f$ is the probability that there are \f$i\f$ interactions per pixel and \f$P_I\f$ number of interacting photons\cite{photontransferbook}. Then the signal-to-noise-ratio for shot noise is \f$SNR_{ph} = \sqrt{N}\f$. As the number of photons increases, the SNR will be enhanced. Then the shot noise is generated according to each signal value and added into the signal~\cite{shwfsnoiseccd}. Hence the shot noise is an issue only at low light level.
%> 
%> @subsection shotingen Shot noise in general
%> Shot noise\index{shot noise} is another white noise that arises from the discrete nature of the electrons themselves, i.e. the random arrival of particles of charge~\cite{hornseynoisebook}. This is the result of the random generation of carriers either by thermal generation within a depletion region (i.e. shot noise of the dark current) or by the random generation of photo-electrons, caused in turn by the random arrival of photons.
%======================================================================
%> @param sensor_signal	= irradiance matrix [matrix NxM], [photons].
%>
%> @retval signal 	= signal of the photosensor in photons  with added Poisson noise (photon shot noise) [matrix NxM], [photons].
% ======================================================================
function sensor_signal_out = ccd_photosensor_photonshotnoise(sensor_signal_in)

%%% Since this is a shot noise, it must be random every time we apply it, unlike the Fixed Pattern Noise (PRNU or DSNU).
                    rand('state', sum(100*clock));
                    randn('state', sum(100*clock));

%%% Apply the Poisson noise to the signal.
sensor_signal_out  = poissrnd(sensor_signal_in); %%% signal must be in PHOTONS - and it must be round numbers.