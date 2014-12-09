%> @file ccd_sense_node_reset_noise.m
%> @brief This routine calculates the noise standard deviation for the sense node reset noise.
%>
%> @author Mikhail V. Konnik
%> @date   25 January 2011, re-worked on 10 December 2014.
%> 
%> @section sensenoderesetnoise Sense node Reset noise (kTC noise)
%> Prior to the measurement of each pixel's charge packet, the sense node capacitor
%> is reset to a reference voltage level. Noise is generated at the sense node by
%> an uncertainty in the reference voltage level due to thermal variations in the
%> channel resistance of the MOSFET reset transistor. The reference level of the
%> sense capacitor is therefore different from pixel to pixel. 
%> 
%> Because reset noise can be significant (about 50 rms electrons), most
%> high-performance photosensors incorporate a noise-reduction mechanism such as
%> correlated double sampling (CDS).
%> 
%> The kTC noise is occurs in CMOS sensors, while for CCD sensors the sense
%> node reset noise is removed~\cite{photontransferbook} by Correlated Double
%> Sampling (CDS). Random fluctuations of charge on the sense node during the reset
%> stage result in a corresponding photodiode reset voltage fluctuation. The sense
%> node reset noise is given by:
%> 
%> \f$\sigma_{RESET}  = \sqrt{\frac{k_B T}{C_{SN}}}.\f$
%> 
%> The simulation of the sense node reset noise may be performed as an addition of
%> non-symmetric probability distribution to the reference voltage \f$V_{REF}\f$.
%> However, the form of distribution depends on the sensor's architecture and the
%> reset technique. An Inverse-Gaussian distribution can be
%> used for the simulation of kTC noise which corresponds to a hard reset technique
%> in the CMOS sensor, and the Log-Normal distribution can be used for soft-reset
%> technique. The sense node reset noise can be simulated for each \f$(i,j)\f$-th pixel
%> for the soft-reset case as:
%> 
%> \f$ I_{SN.reset.V}  = ln\mathcal{N}(0,\sigma_{RESET}^2),\f$
%> 
%> then added to the matrix \f$I_{REF.V}\f$ in Volts that corresponds to the reference voltage.
%>  @note For CCD, the sense node reset noise is entirely removed by CDS.
%>  @note In CMOS photosensors, it is difficult to remove the reset noise for the specific CMOS pixels 
%> architectures even after application of CDS. Specifically, the difficulties
%> arise in ``rolling shutter'' and ``snap'' readout modes.
%> The reset noise is increasing after CDS by a factor of \f$\sqrt{2}\f$.
%> Elimination of reset noise in CMOS is quite challenging.
%======================================================================
%> @param ccd		= matrix [NxM] of signal in Volts.
%> @retval reset_noise	= sense node reset noise matrix [NxM].
% ======================================================================
function ccd = ccd_sense_node_reset_noise(ccd)

ccd.noise.sn_reset.sigma_ktc = sqrt( (ccd.Boltzman_Constant_JK)*(ccd.T)/(ccd.C_SN) ); %% in [V], see Janesick, Photon Transfer, page 166.

    %%% ranomising the state of the noise generators
                    rand('state', sum(100*clock));
                    randn('state', sum(100*clock));

%% Soft-Reset case for the CMOS sensor
ccd.noise.sn_reset.noisematrix =  exp( ccd.noise.sn_reset.sigma_ktc * randn( ccd.sensor_size ) ) - 1;