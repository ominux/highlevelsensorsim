%> @file ccd_sense_node_reset_noise.m
%> @brief This routine calculates the noise standard deviation for the sense node reset noise.
%>
%> @author Mikhail V. Konnik
%> @date   25 January 2011
%> @section sensenodenoise Sense node Reset noise (kTC noise)
%> Reset noise is induced when the charge collected in each pixel of a sensor array is converted to the voltage domain by employing a sense capacitor. Prior to the measurement of each pixel's charge packet, the CCD sense capacitor is reset to a reference voltage level\cite{hamamatsuflicker}. Noise is generated at the sense node by an uncertainty in the reference voltage level due to thermal variations in the channel resistance of the MOSFET reset transistor. Hence the reset noise voltage is thermally generated by the channel resistance associated with the reset MOSFET induced on the sense node capacitor. This is the reason that the sense node reference voltage os different each time a pixel is reset. The reference level of the sense capacitor is therefore different from pixel to pixel. The reset noise voltage is given by\cite{photontransferbook} the following expression: @n
%>  \f$ \sigma_{RESET}(V_{SN}) = \sqrt{4kTBR} = \sqrt{\frac{kTC_{SN}}{q}},\f$@n
%> where \f$\sigma_{RESET}(V_{SN}) \f$ is reset noise voltage [V], \f$R\f$ is the MOSFET channel resistance [Ohms], \f$k\f$ is Boltzmann's constant, \f$B = 1/(4\tau) = 1/4RC_{SN}\f$ ,and \f$T\f$ is the operation temperature [K]. Using the notation of sense node gain, we can express\cite{photontransferbook} as:@n
%> \f$\sigma_{RESET}(V_{SN}) = \sqrt{\frac{kTA_{SN}}{q}},\f$
%> where \f$q\f$ is a charge of an electron. Because reset noise can be significant (about 50 rms electrons), most high-performance CCD cameras incorporate a mechanism to eliminate it, for instance, correlated double sampling (see \ref{sec:subsection:CDS}).
%>  @note For CCD, the sense node reset noise is entirely removed by CDS.
%>  @note In CMOS photosensors, it is difficult to remove the reset noise for the specific CMOS pixels architectures\footnote{Specifically, the difficulties arise in ``rolling shutter'' and ``snap'' readout modes\cite{photontransferbook, Janesickhighperformccdcmos,janesick2006cmos}} even after application of CDS. The reset noise is increasing after CDS by a factor of \f$\sqrt{2}\f$. Elimination of reset noise in CMOS is quite challenging.
%======================================================================
%> @param ccd		= matrix [NxM] of signal in Volts.
%> @retval reset_noise	= sense node reset noise matrix [NxM].
% ======================================================================
function ccd = ccd_sense_node_reset_noise(ccd)

ccd.noise.sn_reset_sigma_ktc = sqrt( (ccd.Boltzman_Constant_JK)*(ccd.T)/(ccd.C_SN) );

%% Soft-Reset case for the CMOS sensor
ccd.noise.sn_reset_noise_matrix = stat_randraw('lognorm',[0, ccd.noise.sn_reset_sigma_ktc],[ccd.sensor_size(1), ccd.sensor_size(2)]);


disp(ccd.noise.sn_reset_sigma_ktc)
% disp(mean(ccd.noise.sn_reset_noise_matrix(:)))