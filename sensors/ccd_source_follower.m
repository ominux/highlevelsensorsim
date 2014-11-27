%> @file ccd_source_follower.m
%> @brief The amplification of the voltage from Sense Node by Source Follower.
%> 
%> @author Mikhail V. Konnik
%> @date   18 January 2011
%> @section sourcefollow V/V gain source follower non-linearity
%> The V/V non-linearity affect shot noise (but does not affect FPN curve) and can cause some shot-noise probability density compression. \textbf{The V/V non-linearity non-linearity is caused by non-linear response in ADC or source follower\cite{photontransferbook}}. 
%> 
%> The V/V non-linearity can be simulated as a change in source follower gain \f$A_{SF}\f$ as a linear function of signal:
%> \f$A_{SF_{new}} = \alpha \cdot \frac{V_{REF} - S(V_{SF}) }{V_{REF} } + A_{SF},\f$ @n
%> where \f$\alpha = A_{SF}\cdot\frac{\gamma_{nlr} -1}{ V_{FW} }\f$ and \f$\gamma_{nlr}\f$ is a non-linearity ratio of \f$A_{SF}\f$. In the simulation we assume \f$A_{SF} = 1\f$ and \f$\gamma_{nlr} = 1.05\f$ i.e. 5\% of non-linearity of \f$A_{SF}\f$. Then the voltage is multiplied on the new sense node gain \f$A_{SF_{new}}\f$:
%>  \f$I_{V} = I_{V}\cdot A_{SF_{new}}\f$ @n
%> After that, the voltage goes to ADC for quantisation to digital numbers.
%======================================================================
%> @param ccd	= matrix [NxM] of signal in Volts.
%> @retval ccd 	= matrix [NxM] of signal in Volts after source follower [V].
% ======================================================================
function ccd = ccd_source_follower(ccd)

% % % [sensor_signal_rows,sensor_signal_columns] = size(ccd.Signal_CCD_voltage);


% % % % if (ccd.flag.sourcefollowernoise == 1)

% % % % %%%%%%%%%%%%% Adding Source Follower noise
% % % % 	ccd = ccd_source_follower_noise(ccd); %% caclulation of the source follower noise.
% % % %     
% % % % 	source_follower_noise = 1+(ccd.V_min*ccd.noise.sf.sigma_SF)*randn(sensor_signal_rows,sensor_signal_columns);
% % % % 	ccd.Signal_CCD_voltage = (ccd.Signal_CCD_voltage)*(ccd.A_SF).*(source_follower_noise);  %%% Signal of Source Follower [SF]
% % % % %%%%%%%%%%%%% Adding Source Follower noise

% % % % else 

%%%%% <-- ###### BEGIN:: adding Source Follower non-linearity
	if (ccd.flag.VVnonlinearity == 1) %%%%%% adds V/V non-linearity

		nonlinearity_alpha = (ccd.A_SF*(ccd.nonlinearity.A_SFratio - 1))/(ccd.V_FW);
		ccd.A_SF_new =  nonlinearity_alpha*((ccd.V_REF - ccd.Signal_CCD_voltage)/(ccd.V_REF)) + (ccd.A_SF)*ones(sensor_signal_rows,sensor_signal_columns);

        ccd.Signal_CCD_voltage = (ccd.Signal_CCD_voltage).*(ccd.A_SF_new);  %%% Signal of Source Follower [SF]

%%%%% <-- ###### END:::: adding Source Follower non-linearity
    else
        
		ccd.Signal_CCD_voltage = (ccd.Signal_CCD_voltage)*(ccd.A_SF);  %%% Signal of Source Follower [SF]

	end %%% if (ccd.flag.VVnonlinearity == 1)

% % % % end %%% (ccd.flag.sourcefollowernoise==1)