%> @file ccd_photosensor_darkFPN.m
%> @brief This routine for adding dark current noises that consist of Dark FPN and Dark shot noise.
%>
%> @author Mikhail V. Konnik
%> @date   17 January 2011, improved on 5 December 2014.
%>
%> @section darkfpnmodel Dark Fixed Pattern Noise
%> Pixels in a hardware photosensor cannot be manufactured exactly the same from
%> perfectly pure materials. There will always be variations in the photo detector
%> area that are spatially uncorrelated, surface defects at
%> the \f$SiO_2/Si\f$ interface\cite{sakaguchidarkcurrentreduction}, and discrete
%> randomly-distributed charge generation centres. These
%> defects provide a mechanism for thermally-excited carriers to move between the
%> valence and   conduction bands. Consequently, the average dark   signal is not
%> uniform but has a spatially-random and fixed-pattern noise (FPN) structure.  The
%> dark current FPN can be expressed as follows:
%> 
%> \f$ \sigma_{d.FPN} = t_I D_R \cdot D_N,\f$
%> 
%> where \f$t_I\f$ is the integration time, \f$D_R\f$ is the  average dark current,
%> and \f$D_N\f$ is the dark current FPN factor that is typically \f$0.1\dots 0.4\f$ for CCD and CMOS sensors. 
%> 
%> There are also so called ``outliers'' or ``dark spikes''; that is, some pixels generate a dark
%> signal values much higher than the mean value of the dark signal. The mechanism
%> of such ``dark spikes'' or ``outliers'' can be described by the Poole-Frenkel
%> effect (increase in emission rate from a defect in the presence of an electric field). 
%> 
%> @subsection darkfpnsimulaiton Simulation of dark current fixed pattern noise 
%> The dark current Fixed
%> Pattern Noise (FPN) is simulated using non-symmetric distributions to account
%> for the ``outliers'' or ``hot pixels''. It is usually assumed that the dark
%> current FPN can be described by Gaussian distribution. However, such an
%> assumption provides a poor approximation of a complicated noise picture. 
%> 
%> Studies show that a
%> more adequate model of dark current FPN is to use non-symmetric probability
%> distributions. The concept is to use two distributions to describe very
%> ``leaky'' pixels that exhibit higher noise level than others. The first
%> distribution is used for the main body of the dark current FPN, with a uniform
%> distribution  superimposed to model ``leaky'' pixels. For  simulations at
%> room-temperature (\f$25^\circ\f$ C) authors use a
%> @b logistic @b distribution, where a higher proportion of the population is
%> distributed in the tails. For higher
%> temperatures, inverse Gaussian and
%> Log-Normal distributions have been proposed. The Log-Normal distribution works well for
%> conventional 3T APS CMOS sensors with comparatively high dark current.
%> 
%> In our simulations we use the Log-Normal distribution for the simulation of dark
%> current FPN in the case of short integration times, and superimposing other
%> distributions for long integration times. The actual simulation code implements
%> various models, including Log-Normal, Gaussian, and Wald distribution to emulate
%> the dark current FPN noise for short- and long-term integration times.
%> 
%> The dark current FPN for each pixel of the matrix \f$I_{dc.shot.e^-}\f$ is computed as:
%> 
%> \f$I_{dc.FPN.e^-}  = I_{dc.shot.e^-}  + I_{dc.shot.e^-} \cdot ln\mathcal{N}(0,\sigma_{dc.FPN.e^-}^2)\f$
%> 
%> where \f$\sigma_{dc.FPN.e^-} = t_I D_R  D_N\f$, \f$D_R\f$ is the average dark current, 
%> and \f$D_N\f$ is the dark current FPN factor.
%> Since the dark current FPN does not change from one frame to the next,  the
%> matrix \f$ln \mathcal{N}\f$ is calculated once and then can be re-used similar to
%> the PRNU simulations.
%> 
%> The experimental results confirm
%> that non-symmetric models, and in particular the Log-Normal distribution, 
%> adequately  describe the dark current FPN in CMOS sensors, especially in the
%> case of a long integration time (longer than 30-60 seconds).  For long-exposure case, one
%> needs to superimpose two (or more, depending on the sensor) probability
%> distributions.
%======================================================================
%> @param dark_signal 	= matrix [NxM] of dark signals that contain @b only dark current noise [e-].
%> @retval dark_signal 	= matrix [NxM] of dark signals that contain Dark FPN [e-].
% ======================================================================
function ccd = ccd_photosensor_darkFPN(ccd)
  
%%% the random generator will be fixed on seed 362436128
                    rand( 'state', 362436128); %%% Fix the state of the rand  random generator
                    randn('state', 362436128); %%% Fix the state of the randn random generator
    
ccd.noise.darkFPN.noisematrix = ccd_FPN_models(ccd, ccd.sensor_size(1), ccd.sensor_size(2), 'pixel', ccd.noise.darkFPN.model, ccd.noise.darkFPN.parameters);

ccd.dark_signal = ccd.dark_signal.*(1 + (ccd.noise.darkFPN.DN)*(ccd.noise.darkFPN.noisematrix)); %% add pixel FPN dark noise.