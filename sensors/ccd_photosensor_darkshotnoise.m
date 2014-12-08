%> @file ccd_photosensor_darkshotnoise.m
%> @brief This routine adds dark shot noise in electrons.
%> 
%> @author Mikhail V. Konnik
%> @date   17 January 2011, re-worked on 9 December 2014.
%> 
%> @section darkshotnoisesim Dark Shot Noise
%> Similar to the photon shot noise, the dark current shot noise is due to the
%> random arrival of the generated electrons and therefore described by a Poisson
%> process. The dark current shot noise can be simulated as a Poisson process
%> \f$\mathcal{P}\f$   with mean \f$\Lambda\f$ as follows:
%> 
%> \f$I_{dc.shot.e^-}  = \mathcal{P}(\Lambda), \,\,\,\,\mbox{ where   } \Lambda = I_{dc.e^-}.\f$
%> 
%> We use the @b poissrnd function that generates Poisson random numbers with mean
%> \f$\Lambda\f$ for each \f$(i,j)\f$-th element of the matrix \f$I_{dc.e^-}\f$ from @ref "readnoise" here 
%> that contains dark signal in electrons. The input of the @b poissrnd
%> function will be the matrix \f$I_{dc.e^-}\f$ that contains the number of electrons,
%> and the output will be the matrix \f$I_{dc.shot.e^-}\f$ with added dark current shot
%> noise. The matrix \f$I_{dc.shot.e^-}\f$ that corresponds to
%> the dark current shot noise is recalculated each time the simulations are
%> started, which corresponds to the temporal nature of the dark current shot
%> noise.
%======================================================================
%> @param dark_signal 	= matrix [NxM] of dark signals that contain @b only dark current noise [e-].
%> @retval dark_signal 	= matrix [NxM] of dark signals that contain Dark shot noise [e-].
% ======================================================================
function ccd = ccd_photosensor_darkshotnoise(ccd)

%%% Since this is a dark current shot noise, it must be random every time we apply it, unlike the Fixed Pattern Noise (PRNU or DSNU).
                    rand('state', sum(100*clock));
                    randn('state', sum(100*clock));

%%% Apply the Poisson noise to the dark signal.
ccd.dark_signal = poissrnd(ccd.dark_signal); %% adding shot noise to the dark signal