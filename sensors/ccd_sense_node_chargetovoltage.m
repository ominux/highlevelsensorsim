%> @file ccd_sense_node_chargetovoltage.m
%> @brief The charge to voltage conversion occurs inside this routine, which simulates Sense Node. After that, a new matrix ccd.Signal_CCD_voltage is created and the raw voltage signal is stored.
%>
%> @author Mikhail V. Konnik
%> @date   18 January 2011
%> @todo add the Reset noise to sense node capacitor: to the Reset Voltage
%> @section sensenode Sense Node: Converting charge to voltage
%> After the charge is generated in the pixel by photo-effect, it is moved row-by-row to the sense amplifier that is separated from the pixels in case of CCD. The packets of charge are being shifted to the output \textit{sense node}, where electrons are converted to voltage. The typical sense node region is presented on Fig.
%>
%> @image html CCD-sensenoderegion.png
%>
%> Sense node is the final collecting point at the end of the horizontal register of the CCD sensor. The CCD pixels are made with MOS devices used as reverse biased capacitors. The charge is readout by a MOSFET based charge to voltage amplifier. The output voltage is inversely proportional to the sense node capacitor. Typical example is that the sense node capacitor of the order \f$50fF\f$, which produces a gain of \f$3.2 \mu V/ e^-\f$. It is also important to minimize the noise of the output amplifier, \textbf{typically the largest noise source in the system}. Sense node converts charge to voltage with typical sensitivities \f$1\dots 4 \mu V/e^-\f$.@n
%> The charge collected in each pixel of a sensor array is converted to voltage by \textbf{sense capacitor} and \textbf{source-follower amplifier}. \textbf{Reset noise} is induced during such conversion. Prior to the measurement of each pixel's charge, the CCD sense capacitor is reset to a reference level. Sense node converts charge to voltage with typical sensitivities \f$1\dots 4 \mu V/e^-\f$. The charge collected in each pixel of a sensor array is converted to voltage by \textbf{sense capacitor} and \textbf{source-follower amplifier}. @b Reset noise is induced during such conversion. Prior to the measurement of each pixel's charge, the CCD sense node capacitor is reset to a reference level.
%>
%> @subsection snnonlin Sense Node gain non-linearity, or V/e non-linearity
%> The V/\f$e^-\f$ non-linearity affect both FPN and shot noise and can cause some shot-noise probability density compression. This type of non-linearity is due to sense node gain non-linearity. Then sense node sensitivity became non-linear\cite{photontransferbook}:@n
%> \f$S_{SN} ( V_{SN}/e^- ) = \frac{S(V_{SN}) }{(k_1/q)  \ln( V_{REF}/[V_{REF} - S(V_{SN})] )}\f$
%>
%> The V/\f$e^-\f$ non-linearity can be expressed as  a non-linear dependency of signals in electron and a sense-node voltage:
%> \f$ S[e^-] = \frac{k1}{q} \ln \left[ \frac{V_{REF}}{ V_{REF} -  S(V_{SN}) } \right]\f$
%> The V/\f$e^-\f$ non-linearity affects photon shot noise and skews the distribution, however this is a minor effect. The V/\f$e^-\f$ non-linearity can also be thought as a sense node capacitor non-linearity: when a small signal is measured, \f$C_{SN}\f$ is fixed or changes negligible; on the other hand, \f$C_SN\f$ changes significantly and that can affect the the signal being measured.
%>
%> For the simulation purpose, the V/\f$e^-\f$ non-linearity can be expressed from the Eq.\ref{eq:venonlinsignal} as: @n
%> \f$V_{SN} = V_{REF} - S(V_{SN}) = V_{REF}\exp\left[ - \frac{\alpha\cdot S[e^-]\cdot q }{k1} \right]\f$
%>
%> where \f$k1=10.909*10^{-15}\f$ and \f$q\f$ is the charge of an electron, and \f$\alpha\f$ is the coefficient of non-linearity strength.
%======================================================================
%> @param ccd	= matrix [NxM] of signal in electrons [e-].
%> @retval ccd 	= matrix [NxM] of signal in @b Volts [V].
% ======================================================================
function ccd = ccd_sense_node_chargetovoltage(ccd)


if ( isfield(ccd.flag,'Venonlinearity') == 0 ) %% Just in case - if the field ccd.flag.Venonlinearity does NOT exist, make it zero to prevent the code from crashing.
    ccd.flag.Venonlinearity = 0;
end

    
%%%%%%%%%%%%% SN = Sense node, the capacitor area.
ccd.C_SN = (ccd.q)/ccd.A_SN; %%%% Sense node capacitance, parameter, [F] Farad
ccd.V_FW = ccd.FW_e*ccd.q/(ccd.C_SN); %% Voltage on the Full Well
ccd.V_min = ccd.q*ccd.A_SN/(ccd.C_SN);
%%%%%%%%%%%%% SN = Sense node, the capacitor area.



if  strcmp('CMOS',ccd.SensorType) %%%%% Sense Noide Reset Noise (KTC noise) must be here
    
%% <--- BEGIN:: the CMOS sensor case
	if (ccd.flag.sensenoderesetnoise == 1)  %%% If the reset noise is turned on - ADD THE SENSE NOISE
        
        
        %%% START:: Sanitizing the input for ccd.snresetnoiseFactor
        if (ccd.snresetnoiseFactor > 1)

            ccd.snresetnoiseFactor = 1;
            fprintf('Sensor Simulator::: Warning! The compensation factor you entered %2.3e for \n the Sense Node Reset Noise cannot be more than 1! The factor is set to 1.', ccd.snresetnoiseFactor);

        else if (ccd.snresetnoiseFactor < 0)

            ccd.snresetnoiseFactor = 0;
            fprintf('Sensor Simulator::: Warning! The compensation factor you entered %2.3e for \n the Sense Node Reset Noise cannot be negative! The factor is set to 0, SNReset noise is not simulated.', ccd.snresetnoiseFactor);

            end
        end
        %%% END:: Sanitizing the input for ccd.snresetnoiseFactor


        %%% Obtain the matrix for the Sense Node Reset Noise:
        ccd = ccd_sense_node_reset_noise(ccd); %%% the actual noise matrix is in   ccd.noise.sn_reset_noise_matrix
        
		if (ccd.flag.Venonlinearity == 1)
           ccd.Signal_CCD_voltage = (ccd.V_REF + ccd.snresetnoiseFactor*ccd.noise.sn_reset_noise_matrix).*(exp(-ccd.nonlinearity.A_SNratio*ccd.q*ccd.Signal_CCD_electrons./ccd.k1)); %% non-linearity
        else
           ccd.Signal_CCD_voltage = (ccd.V_REF + ccd.snresetnoiseFactor*ccd.noise.sn_reset_noise_matrix) - (ccd.Signal_CCD_electrons * ccd.A_SN);   %%% Node signal voltage.
		end %%% if (ccd.flag.Venonlinearity == 1)

                
	else %% if (ccd.flag.sensenoderesetnoise == 0)  %%% if we DO NOT want to add the Sense Node Reset Noise
        
		if (ccd.flag.Venonlinearity == 1)
            ccd.Signal_CCD_voltage = ccd.V_REF*(exp(-ccd.nonlinearity.A_SNratio*ccd.q*ccd.Signal_CCD_electrons./ccd.k1)); %% non-linearity
		else
	    	ccd.Signal_CCD_voltage = ccd.V_REF -  (ccd.Signal_CCD_electrons * ccd.A_SN);   %%% Sense Node voltage.
		end %%% if (ccd.flag.Venonlinearity == 1)

    end  %%strcmp('CMOS',ccd.SensorType)

%% <--- END::: :: the CMOS sensor case
    





%% <--- BEGIN:: the CCD sensor
else %% The sensor is CCD

    if (ccd.flag.Venonlinearity == 1)
            ccd.Signal_CCD_voltage  = ccd.V_REF*(exp(-ccd.nonlinearity.A_SNratio*ccd.q*ccd.Signal_CCD_electrons./ccd.k1)); %% non-linearity
    else
            ccd.Signal_CCD_voltage  = ccd.V_REF - ccd.Signal_CCD_electrons * ccd.A_SN;   %%% Sense Node voltage.
	end %%% if (ccd.flag.Venonlinearity == 1)

%% <--- END:::: the CCD sensor

end %% (ccd.flag.sensenoderesetnoise == 1)