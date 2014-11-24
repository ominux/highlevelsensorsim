%> @file ccd_adc.m
%> @brief This routine performs analogue-to-digital convertation of volts to DN.
%> @author Mikhail V. Konnik
%> @date   18 January 2011
%>
%> @section adc Analogue to Digital converter
%> Analogue to digital converter (ADC) is an electronic device that converts an input analogue voltage or current to a digital numbers (DN) that are proportional to the magnitude of the voltage or current. One of the main parameters is the the resolution of the ADC: the resolution indicates the number of discrete values that can be produced over the range of analogue values. Since digital numbers are stored in binary form, the resolution is expressed in bits. Consequently, the number of discrete values (levels) is usually a power of two.@n
%> Minimal change in voltage that can be detected in the output voltage level is called the \textit{least significant bit}. The resolution (sensitivity, \f$K_{ADC}\f$ Volts/DN) of an ADC can be expressed as: @n
%> \f$K_{ADC} = \frac{V_ \mathrm {max} - V_ \mathrm {min}}{N_{max}},\f$
%> where:
%> - \f$V_ \mathrm {max}\f$ is maximum voltage that can be quantified;
%> - \f$V_ \mathrm {min}\f$ is minimum voltage that can be quantified;
%> - \f$N_{max}\f$ is the number of voltage intervals given by \f$N_{max} = 2^M\f$ (here \f$M\f$ is the ADC's resolution in bits).
%> 
%>  Usually the quantiy \f$V_ \mathrm {max} - V_ \mathrm {min}\f$ is denoted as \f$V_{FSR}\f$ that is full scale voltage range of the ADC. Minimal output signal in most ADCs represents a voltage range which is \f$0.5 K_{ADC}\f$ that is half the ADC voltage resolution. Maximal output signal represents a range of \f$1.5 K_{ADC}\f$. Other \f$N_{max} - 2\f$ output signals are all equal in width and represent the ADC voltage resolution \f$K_{ADC}\f$. Such procedure centres the output on an input voltage that represents the \f$M-th\f$ division of the input voltage range (this practice is called \textit{mid-tread operation}) and represented as:@n
%> \f$ ADC_ \mathrm {Code} = \textrm{round}\left[ \left( \frac{2^M} {V_{FSR}}\right) \cdot (V_ \mathrm {input}-V_ \mathrm {min}) \right] \f$ @n
%> In practice useful resolution of an ADC is limited by the best signal-to-noise ratio (SNR) that can be achieved for a digitised signal. The minimum signal (one electron) can be calculated from the shot noise on sense node as: \f$\sigma_{SHOT}(V_{SN}) = \sqrt{S(V_{SN})/K_{SN}} = \sqrt{S(V_{SN})\cdot A_{SN}} = \sqrt{q \cdot A_{SN} / C_{SN}}\f$.
%> @subsection adcnonlin Voltage - to - Voltage non-linearity [TBD]
%======================================================================
%> @param ccd 		= structure of signal in Voltages that is ccd.Signal_CCD_voltage
%> @retval ccd 		= structure of signal in Digital Numbers that is ccd.Signal_CCD_DN
% ======================================================================
function ccd = ccd_adc(ccd);

N_max = 2^(ccd.N_bits);
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
	%%%%%% Removing the reference Voltage;
end %% (ccd.flag.ADCnonlinearity == 1)
%%%%%%%%%%%%% END ::: ADC = Analogue-to-Digital Converter


S_DN (S_DN<=0) = 0; %%% ## Truncating the numbers that are less than 0:
S_DN (S_DN>=N_max) = N_max; %%% ## Truncating the numbers that are less than 0:


ccd.Signal_CCD_DN = S_DN; %%%% END of ADC conversion: subtract the the signal from N_max to get the normal, non-inverted image.