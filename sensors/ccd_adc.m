%> @file ccd_adc.m
%> @brief This routine performs analogue-to-digital convertation of volts to DN.
%> @author Mikhail V. Konnik
%> @date   18 January 2011, improved on 10 December 2014.
%>
%> @section adcdescribe Analogue to Digital converter
%> An analogue-to-digital converter (ADC) transforms a voltage signal into discrete
%> codes. An \f$N\f$-bit ADC has \f$2^N\f$ possible output codes with the difference between code
%> being \f$V_{ADC.REF}/2^N\f$. The resolution of the ADC indicates the number of
%> discrete values that can be produced over the range of analogue values and can
%> be expressed as:
%> 
%> \f$ K_{ADC} = \frac{V_{ADC.REF} - V_\mathrm {min}}{N_{max}}\f$
%> 
%> where \f$V_\mathrm{ADC.REF}\f$ is the maximum voltage that can be quantified,
%> \f$V_{min}\f$ is minimum quantifiable voltage, and \f$N_{max} = 2^N\f$ is the number of
%> voltage intervals. Therefore, the output of an ADC can be represented as:
%> 
%> \f$ADC_{Code} = \textrm{round}\left( \frac{V_{input}-V_{min}}{K_{ADC}} \right)\f$
%> 
%> The lower the reference voltage \f$V_{ADC.REF}\f$, the smaller the range of the
%> voltages one can measure.
%> 
%> 
%> @subsection adcsimulation Simulating ADC
%> After the electron matrix has been converted to voltages, the sense node reset
%> noise and offset FPN noise are  added, the V/V gain non-linearity is applied (if
%> desired), the ADC non-linearity is applied (if necessary). Finally the result is
%> multiplied by ADC gain and rounded to produce the signal as a digital number:
%> 
%> \f$I_{DN} =  round (A_{ADC}\cdot I_{total.V}),\f$
%> 
%> where \f$I_{total.V} = (V_{ADC.REF} - I_{V})\f$ is the total voltage signal
%> accumulated during one frame acquisition, \f$V_{ADC.REF}\f$ is the maximum voltage
%> that can be quantified by an ADC, and \f$I_V\f$ is the total voltage signal
%> accumulated by the end of the exposure (integration) time and conversion.
%> Usually \f$I_V = I_{SN.V}\f$ after the optional V/V non-linearity is applied. In
%> this case, the conversion from voltages to digital signal is linear. The
%> @ref adcnonlinearity "non-linear ADC case is considered below".
%> 
%> 
%> @subsection adcnoise ADC Noise an non-linearity
%> In terms of the ADC, the following non-linearity and noise should be considered
%> for the simulations of the photosensors: Integral Linearity Error, Differential
%> Linearity Error, quantisation error, and ADC offset.
%> 
%> @subsubsection adcdleadd Differential Linearity Error
%> The DLE indicates the deviation from the ideal 1 LSB (Least Significant Bit)
%> step size of the analogue input signal corresponding to a code-to-code
%> increment. Assume that the voltage that corresponds to a step of 1 LSB is
%> \f$V_{LSB}\f$. In the ideal case, a change in the input voltage of \f$V_{LSB}\f$ causes
%> a change in the digital code of 1 LSB. If an input voltage that is more than
%> \f$V_{LSB}\f$ is required to change a digital code by 1 LSB, then the ADC has @b DLE
%> @b error. In this case, the digital output remains constant when the input
%> voltage changes from, for example, \f$2 V_{LSB}\f$  to  \f$4 V_{LSB}\f$, therefore
%> corresponding the digital code can never appear at the output. That is, that
%> code is missing.
%> 
%>  @image html dle.png
%> 
%> In the illustration above, each input step should be precisely 1/8 of reference
%> voltage. The first code transition from 000 to 001 is caused by an input change
%> of 1 LSB as it should be. The second transition, from 001 to 010, has an input
%> change that is 1.2 LSB, so is too large by 0.2 LSB. The input change for the
%> third transition is exactly the right size. The digital output remains
%> constant when the input voltage changes from 4 LSB to 5 LSB, therefore the code
%> 101 can never appear at the output.
%> 
%> 
%> 
%> @subsubsection adcileadd Integral Linearity Error
%> The ILE is the maximum deviation of the input/output characteristic from a
%> straight line passed through its end points. For each voltage in the ADC input,
%> there is a corresponding code at the ADC output. If an ADC transfer function is
%> ideal, the steps are perfectly superimposed on a line. However, most real ADC's
%> exhibit deviation from the straight line, which can be expressed in percentage
%> of the reference voltage or in LSBs. Therefore, ILE is a measure of the
%> straightness of the transfer function and can be greater than the differential
%> non-linearity. Taking the ILE into account is important because it cannot be
%> calibrated out. 
%> 
%>  @image html ILE.png
%> 
%> For each voltage in the ADC input there is a corresponding word at the ADC
%> output. If an ADC is ideal, the steps are perfectly superimposed on a line. But
%> most of real ADC exhibit deviation from the straight line, which can be
%> expressed in percentage of the reference voltage or in LSBs.
%> 
%> 
%> @subsubsection adcnonlinearity ADC non-linearity simulation
%> In our model, we simulate the Integral Linearity Error (ILE) of the ADC as a
%> dependency of ADC gain \f$A_{ADC.linear}\f$ on the signal value. Denote
%> \f$\gamma_{ADC.nonlin}\f$ as an ADC non-linearity ratio (e.g., \f$\gamma_{ADC.nonlin}
%> = 1.04\f$). The linear ADC gain can be calculated from Eq.~\ref{eq:kadc} as
%> \f$A_{ADC} = 1/K_{ADC}\f$ and used as \f$A_{ADC.linear}\f$. The non-linearity
%> coefficient \f$\alpha_{ADC}\f$ is calculated as:
%> 
%> \f$\alpha_{ADC} = \frac{1}{V_{ADC.REF}} \left( \frac{ \log(\gamma_{ADC.nonlin}
%> \cdot A_{ADC.linear} )}{\log(A_{ADC.linear})} - 1 \right)\f$
%> 
%> where \f$V_\mathrm{ADC.REF}\f$ is the maximum voltage that can be quantified by an
%> ADC: 
%> 
%> \f$ A_{ADC.nonlin} = A_{ADC.linear}^{1-\alpha_{ADC} I_{total.V}},\f$
%> 
%> where \f$A_{ADC.linear}\f$ is the linear ADC gain. The new non-linear ADC conversion
%> gain \f$A_{ADC.nonlin}\f$ is then used for the simulations.
%> 
%> 
%> @subsection adcquantisationnoise Simulation of quantisation noise
%> Quantisation errors are caused by the rounding, since an ADC has a
%> finite precision. The probability distribution of quantisation noise is
%> generally assumed to be uniform. Hence we use the uniform distribution to model
%> the rounding errors.
%> 
%> It is assumed that the quantisation error is uniformly distributed between -0.5
%> and +0.5 of the LSB and uncorrelated with the signal.  Denote \f$q_{ADC}\f$ the
%> quantising step of the ADC. For the ideal DC, the quantisation noise is:
%> 
%>  \f$\sigma_{ADC} = \sqrt{ \frac{q_{ADC}^2 }{12}}.\f$
%> 
%> If \f$q_{ADC} = 1\f$ then the quantisation noise is \f$\sigma_{ADC} = 0.29\f$ DN. The
%> quantisation error has a uniform distribution. We do not assume any particular
%> architecture of the ADC in our high-level sensor model.
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