%> @file ccd_source_follower.m
%> @brief The amplification of the voltage from Sense Node by Source Follower.
%> 
%> @author Mikhail V. Konnik
%> @date   18 January 2011, reworked 8 December 2014.
%> 
%> @section sourcefollowerdescr Source Follower
%> Conventional sensor use a floating-diffusion sense node followed by a
%> charge-to-voltage amplifier, such as a @b source @b follower.
%> 
%>  @image html source_follower.png
%> 
%> Source follower is one of basic single-stage field effect transistor (FET)
%> amplifier topologies that is typically used as a voltage buffer. In such a
%> circuit, the gate terminal of the transistor serves as the input, the source is
%> the output, and the drain is common to both input and output. At low
%> frequencies, the source follower has voltage gain:
%> 
%> \f$    {A_{\text{v}}} = \frac{v_{\text{out}}}{v_{\text{in}}} = \frac{g_m R_{\text{S}}}{g_m R_{\text{S}} + 1} \approx 1 \qquad (g_m R_{\text{S}} \gg 1) \f$
%> 
%> Source follower is a voltage follower, its gain is less than 1. Source followers
%> are used to preserve the linear relationship between incident light, generated
%> photoelectrons and the output voltage.
%> 
%> 
%> @subsection sourcefollowernonlin V/V gain source follower non-linearity
%> The V/V non-linearity affect shot noise (but does not affect FPN curve) and can
%> cause some shot-noise probability density compression. The V/V
%> non-linearity non-linearity is caused by non-linear response in ADC or source
%> follower. 
%> 
%> The V/V non-linearity can be simulated as a change in source follower gain
%> \f$A_{SF}\f$ as 
%> a linear function of signal:
%> 
%>  \f$A_{SF_{new}} = \alpha \cdot \frac{V_{REF} - S(V_{SF}) }{V_{REF} } +
%> A_{SF},\f$ @n
%> 
%> where \f$\alpha = A_{SF}\cdot\frac{\gamma_{nlr} -1}{ V_{FW} }\f$ and
%> \f$\gamma_{nlr}\f$ is a non-linearity ratio of \f$A_{SF}\f$. In the simulation
%> we assume \f$A_{SF} = 1\f$ and \f$\gamma_{nlr} = 1.05\f$ i.e. 5\% of
%> non-linearity of \f$A_{SF}\f$. Then the voltage is multiplied on the new sense
%> node gain \f$A_{SF_{new}}\f$:
%> 
%>   \f$I_{V} = I_{V}\cdot A_{SF_{new}}\f$ @n
%> 
%>  After that, the voltage goes to ADC for quantisation to digital numbers.
%> 
%======================================================================
%> @param ccd	= matrix [NxM] of signal in Volts.
%> @retval ccd 	= matrix [NxM] of signal in Volts after source follower [V].
% ======================================================================
function ccd = ccd_source_follower(ccd)


if ( isfield(ccd.flag,'VVnonlinearity') == 0 ) %% Just in case - if the field ccd.flag.Venonlinearity does NOT exist, make it zero to prevent the code from crashing.
    ccd.flag.VVnonlinearity = 0;
end

%%%%% <-- ###### BEGIN:: adding Source Follower non-linearity
	if (ccd.flag.VVnonlinearity == 1) %%%%%% adds V/V non-linearity

		nonlinearity_alpha = (ccd.A_SF*(ccd.nonlinearity.A_SFratio - 1))/(ccd.V_FW);
		ccd.A_SF_new =  nonlinearity_alpha*((ccd.V_REF - ccd.Signal_CCD_voltage)/(ccd.V_REF)) + (ccd.A_SF)*ones(ccd.sensor_size(1), ccd.sensor_size(2)); 

        ccd.Signal_CCD_voltage = (ccd.Signal_CCD_voltage).*(ccd.A_SF_new);  %%% Signal of Source Follower [SF]

%%%%% <-- ###### END:::: adding Source Follower non-linearity
    else
        
		ccd.Signal_CCD_voltage = (ccd.Signal_CCD_voltage)*(ccd.A_SF);  %%% Signal of Source Follower [SF]

	end %%% if (ccd.flag.VVnonlinearity == 1)
