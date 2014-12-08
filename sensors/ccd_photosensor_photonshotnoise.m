%> @file ccd_photosensor_photonshotnoise.m
%> @brief This routine adds photon shot noise to the signal of the photosensor that is in photons.
%> @author Mikhail V. Konnik
%> @date   17 January 2011, improved 2 December 2014
%>
%> @section photonshotnoisesimulation Photon shot noise
%> The photon shot noise is due to the random arrival of photons and can be
%> described by a Poisson process. Therefore, for each \f$(i,j)\f$-th element of
%> the matrix \f$I_{ph}\f$ that contains the number of collected photons, a photon
%> shot noise  is simulated as a Poisson process \f$\mathcal{P}\f$   with mean
%> \f$\Lambda\f$:
%> 
%>     \f$I_{ph.shot}  = \mathcal{P}(\Lambda), \,\,\,\,\mbox{ where   } \Lambda = I_{ph} .\f$
%> 
%> In MATLAB, we use the @b poissrnd function that generates Poisson random numbers
%> with mean \f$\Lambda\f$.  That is, the number of collected photons in 
%> \f$(i,j)\f$-th pixel of the simulated photosensor in the matrix \f$I_{ph}\f$ is
%> used as the mean \f$\Lambda\f$ for the generation of Poisson random numbers to
%> simulate the photon shot noise. The input of the \texttt{poissrnd} function will
%> be the matrix \f$I_{ph}\f$ that contains the number of collected photons. The
%> output will be the matrix \f$I_{ph.shot} \rightarrow I_{ph}\f$, i.e., the signal
%>  with added photon shot noise.  The matrix \f$I_{ph.shot}\f$ is recalculated
%> each time the simulations are started, which corresponds to the temporal nature
%> of the photon shot noise.
%======================================================================
%> @param sensor_signal_in	= irradiance matrix [matrix NxM], [photons].
%> @retval sensor_signal_out 	= signal of the photosensor in photons  with added Poisson noise (photon shot noise) [matrix NxM], [photons].
% ======================================================================
function sensor_signal_out = ccd_photosensor_photonshotnoise(sensor_signal_in)

%%% Since this is a shot noise, it must be random every time we apply it, unlike the Fixed Pattern Noise (PRNU or DSNU).
                    rand('state', sum(100*clock));
                    randn('state', sum(100*clock));

%%% Apply the Poisson noise to the signal.
sensor_signal_out  = poissrnd(sensor_signal_in); %%% signal must be in PHOTONS - and it must be round numbers.