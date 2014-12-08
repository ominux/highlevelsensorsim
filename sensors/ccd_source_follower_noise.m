%> @file ccd_source_follower_noise.m
%> @brief The source follower noise routine.
%> 
%> @author Mikhail V. Konnik
%> @date   25 January 2011, re-worked 9 December 2014.
%> @section sourcefollownoise Source Follower Noise
%> The pixel's source follower noise limits the read noise, however in high-end CCD and CMOS cameras the source follower noise has been driven down to one electron rms\cite{photontransferbook}.
%> Pixel source follower MOSFET noise consists of three types of noise:
%> -  white noise;
%> -  flicker noise;
%> -  random telegraph noise (RTS).
%> Each type of noise has its own physics that will be briefly sketched below.
%> @subsection johnsonnoise Johnson noise (white noise)
%> Similarly to the reset noise in sense node, the source-follower amplifier MOSFET has a resistance that generates thermal noise whose value is governed by the Johnson white noise equation\cite{hamamatsuflicker}. It is therefore either referred to as Johnson noise or simply as white noise, since its magnitude is independent of frequency. If the effective resistance is considered to be the output impedance of the source-follower amplifier, the white noise, in volts, is determined by the following equation:@n 
%> \f$N_{white} (V_{SF}) = \sqrt{4kTBR_{SF}}\f$ @n
%> where \f$k\f$ is Boltzmann's constant (J/K), \f$T\f$ is temperature [K], \f$B\f$ refers to the noise power bandwidth [Hz], and \f$R_{SF}\f$ is the output impedance of the source-follower amplifier.
%> @subsection flickernoise Flicker noise
%> The flicker noise is commonly referred to as \f$1/f\f$ noise because of its approximate inverse dependence on frequency. For cameras in which pixels are read out at less than approximately 1 megahertz, and with a characteristic \f$1/f\f$ noise spectrum, the read noise floor is usually determined by 1/f noise\cite{hamamatsuflicker}. Note that the noise continues to decrease at this rate until it levels off, at a frequency referred to as the \f$1/f\f$ \textit{corner frequency}. For the typical MOSFET amplifier, the white noise floor occurs at approximately 4.5  \f$nV/Hz^{1/2}\f$. @n
%> Prominent sources of \f$1/f\f$ noise in an image sensor are pink-coloured noise generated in the photo-diodes and the low-bandwidth analogue operation of MOS transistors due to imperfect contacts between two materials\cite{ott1988noise,nakamura2006image}. Flicker noise is generally accepted to originate due to the existence of interface states in the image sensor silicon that turn on and off randomly according to different time constants\cite{hamamatsuflicker}. All systems exhibiting 1/f behaviour have a similar collection of randomly-switching states. In the MOSFET, the states are traps at the silicon-oxide interface, which arise because of disruptions in the silicon lattice at the surface. The level of \f$1/f\f$ noise in a CCD sensor depends on the pixel sampling rate and from certain crystallographic orientations of silicon wafer\cite{hamamatsuflicker}.
%> @subsection rtsnoise Random Telegraph Signal (RTS) noise
%> As the CCD and CMOS pixels are shrinking in dimensions, the low-frequency noise increases\cite{kolhatkar2004separation}. In such devices, the low-frequency noise performance is dominated by Random Telegraph Signals (RTS) on top of the 1/f noise. The origin of such an RTS is attributed to the random trapping and de-trapping of mobile charge carriers in traps located in the oxide or at the interface. The RTS is observed in MOSFETs as a fluctuation in the drain current\cite{kolhatkar2004separation}. A pure two-level RTS is represented in the frequency domain by a Lorentzian spectrum\cite{machlup2009noise}.@n
%> Mathematically the source follower's noise power spectrum can be described as:
%> \f$ S_{SF}(f) = W(f)^2 \cdot \left(1 + \frac{f_c}{f}\right)+S_{RTS}(f),\f$ @n
%> where \f$W(f)\f$ is the thermal white noise [\f$V/Hz^{1/2}\f$, typically \f$15 nV/Hz^{1/2}\f$ ], flicker noise corner\footnote{flicker noise corner frequency is the frequency where power spectrum of white and flicker noise are equal} frequency \f$f_c\f$ in [Hz], and the RTS power spectrum is given\cite{photontransferbook}:@n
%> \f$S_{RTS}(f) = \frac{2\Delta I^2 \tau_{RTS}}{4+(2\pi f  \tau_{RTS})^2},\f$ @n
%> where \f$\tau_{RTS}\f$ is the RTS characteristic time constant [sec] and \f$\Delta I\f$ is the source follower current modulation induced by RTS [A].
%> 
%> The source follower noise can be approximated as:
%> \f$\sigma_{SF} = \frac{\sqrt{\int\limits_{0}^{\infty} S_{SF}(f) H_{CDS}(f) df }}{A_{SN}A_{SF}(1-\exp^{-t_s/\tau_D})} \f$ @n
%> where:
%> -  \f$\sigma_{SF} \f$ is the source follower noise [e- rms]
%> -  \f$f\f$ is the electrical frequency [Hz]
%> -  \f$t_s\f$ is the CDS sample-to-sampling time [sec]
%> -  \f$\tau_D\f$ is the CDS dominant time constant\cite{janesickscintificCCD} usually set as \f$\tau_D = 0.5t_s\f$ [sec].
%> The \f$H_{CDS}(f)\f$ function is the CDS transfer function is\cite{photontransferbook}:@n
%> \f$ H_{CDS}(f) = \frac{1}{2-2\cos(2\pi f t_s)} \cdot [1+(2\pi f \tau_D)^2]\f$ @n
%> First term sets the CDS bandwidth for the white noise rejection before sampling takes place through \f$B = 1/(4\tau_D)\f$, where \f$B\f$ is defined as the noise equivalent bandwidth [Hz].
%> @note In CCD photosensors, source follower noise is typically limited by the flicker noise.
%> @note In CMOS photosensors, source follower noise is typically limited by the RTS noise.
%> As a side note, such subtle kind of noises is visible only on high-end ADC like 16 bit and more. 
%======================================================================
%> @param ccd	= matrix [NxM] of signal in Volts without source follower noise [V].
%> @retval ccd 	= matrix [NxM] of signal in Volts after addition of source follower noise [V].
% ======================================================================
function ccd = ccd_source_follower_noise(ccd)

tau_D = 0.5 * (ccd.noise.sf.t_s); %% is the CDS dominant time constant usually set as \f$\tau_D = 0.5t_s\f$ [sec].
tau_RTN = 0.1 * tau_D;

f = 1:ccd.noise.sf.sampling_delta_f:(ccd.noise.sf.f_clock_speed); %% frequency, with delta_f as a spacing.


%% CDS transfer function
H_CDS = ( 2-2*cos(2*pi*(ccd.noise.sf.t_s).*f) ) ./ ( 1 + (2*pi*(tau_D).*f).^2 );


%%%%%%%%%%%%% DEPENDING ON SENSOR TYPE, THE NOISE IS SLIGHTLY DIFFERENT
%% RTS noise power
S_RTN = 0; %%% In CCD photosensors, source follower noise is typically limited by the flicker noise.

if strcmp('CMOS',ccd.SensorType) %%  In CMOS photosensors, source follower noise is typically limited by the RTS noise.

    S_RTN = (2*((ccd.noise.sf.Delta_I)^2)*tau_RTN)./(4+(2*pi*tau_RTN.*f).^2);  %%% for CMOS sensors only

end
%%%%%%%%%%%%% DEPENDING ON SENSOR TYPE, THE NOISE IS SLIGHTLY DIFFERENT


S_SF = ((ccd.noise.sf.W_f)^2).*(1+(ccd.noise.sf.f_c)./f) + S_RTN;

%% Calculating the std of SF noise:
nomin = sqrt( ccd.noise.sf.sampling_delta_f *S_SF * H_CDS' );
denomin = ccd.A_SN*ccd.A_SF*(1-exp(-(ccd.noise.sf.t_s)/(tau_D)));

ccd.noise.sf.sigma_SF = nomin/denomin; %% the resulting source follower std noise