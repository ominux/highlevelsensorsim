%> @file ccd_adc.m
%> @brief This routine performs analogue-to-digital convertation of volts to DN.
%> @author Mikhail V. Konnik
%> @date   18 January 2011, improved on 10 December 2014.
%>

%======================================================================
%> @param ccd 		= structure of signal in Voltages that is ccd.Signal_CCD_voltage
%> @retval ccd 		= structure of signal in Digital Numbers that is ccd.Signal_CCD_DN
% ======================================================================
function ccd = ccd_adc(ccd);


if ( isfield(ccd.flag,'ADCnonlinearity') == 0 ) %% Just in case - if the field ccd.flag.Venonlinearity does NOT exist, make it zero to prevent the code from crashing.
    ccd.flag.ADCnonlinearity = 0;
end


N_max = 2^(ccd.N_bits); %% maximum number of DN.

ccd.A_ADC = N_max/(ccd.V_FW - ccd.V_min); %%% ADC gain, [DN/V].


%%%%%%%%%%%%% START::: ADC = Analogue-to-Digital Converter
if (ccd.flag.ADCnonlinearity == 1)

%%%%% <-- ###### ADC non-linearity
	A_ADC_NL = ccd.nonlinearity.ADCratio*ccd.A_ADC;
	nonlinearity_alpha = ( log(A_ADC_NL)/log(ccd.A_ADC)  - 1 )/ccd.V_FW;
	signal = ccd.V_REF - ccd.Signal_CCD_voltage; %%%%%% Removing the reference Voltage;
    
	A_ADC_new = (ccd.A_ADC)*ones(size(signal));
	A_ADC_new = A_ADC_new.^(1-nonlinearity_alpha.*signal);

    S_DN = round(ccd.S_ADC_OFFSET + A_ADC_new.*signal);  %% ADC convertation with NON-LINEARITY
%%%%% <-- ###### ADC non-linearity

else
    
	S_DN = round(ccd.S_ADC_OFFSET + ccd.A_ADC*(ccd.V_REF - ccd.Signal_CCD_voltage));  %% ADC convertation
    
end %% (ccd.flag.ADCnonlinearity == 1)
%%%%%%%%%%%%% END ::: ADC = Analogue-to-Digital Converter


S_DN (S_DN<=0) = 0; %%% ## Truncating the numbers that are less than 0:
S_DN (S_DN>=N_max) = N_max; %%% ## Truncating the numbers that are greater than N_max maximum signal for this bitrate.

ccd.Signal_CCD_DN = S_DN; %%%% END of ADC conversion: subtract the the signal from N_max to get the normal, non-inverted image.