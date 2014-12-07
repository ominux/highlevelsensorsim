%> @file ccd_cds.m
%> @brief Reducing the noise by Correlated Double Sampling, but right now the routine just adds the noise.
%>
%> @author Mikhail V. Konnik
%> @date   18 January 2011, improved 8 December 2014
%>
%> @section cds Correlated Double Sampling
%> Correlated Double Sampling (CDS) is a technique for measuring photovoltage values that removes an undesired noise. The sensor's output is measured twice. Correlated Double Sampling is used for compensation of Fixed pattern noise~\cite{canonfullframeCMOSwhitepaper} caused by dark current leakage, irregular pixel converters and the like. It appears on the same pixels at different times when images are taken. It can be suppressed with noise reduction and on-chip noise reduction technology. The main approach is CDS, having one light signal read by two circuits.@n
%> In CDS, a circuit measures the difference between the reset voltage and the signal voltage for each pixel, and assigns the resulting value of charge to the pixel. The additional step of measuring the output node reference voltage before each pixel charge is transferred makes it unnecessary to reset to the same level for each pixel\cite{hamamatsuflicker}.@n
%> First, only the noise is read. Next, it is read in combination with the light signal. When the noise component is subtracted from the combined signal, the fixed-pattern noise can be eliminated.@n
%> CDS is commonly used in image sensors to reduce FPN and reset noise. CDS only reduces offset FPN (gain FPN cannot be reduced using CDS). CDS in  in CCDs, PPS, and photogate APS, CDS reduces reset noise, in photodiode APS it increases it See Janesick's book and especially El Gamal lectures.
%======================================================================
%> @param ccd	= matrix [NxM] of signal in Volts before CDS [V].
%> @retval ccd 	= matrix [NxM] of signal in Volts after CDS [V].
% ======================================================================
function ccd = ccd_cds(ccd)


if ( isfield(ccd.flag,'darkcurrent_offsetFPN') == 0 ) %% Just in case - if the field ccd.flag.darkcurrent_offsetFPN does NOT exist, make it zero to prevent the code from crashing.
    ccd.flag.darkcurrent_offsetFPN = 0;
end



if  strcmp('CMOS',ccd.SensorType)

%%%%% <----- ### Start:: If the sensor is CMOS and the Column FPN is on  - add the column FPN noise  (CMOS only!)
	if (ccd.flag.darkcurrent_offsetFPN == 1)

        ccd.noise.darkFPN_offset.noisematrix = ccd_FPN_models(ccd, ccd.sensor_size(1), ccd.sensor_size(2), 'column', ccd.noise.darkFPN_offset.model, ccd.noise.darkFPN_offset.parameters);
        
		ccd.Signal_CCD_voltage = ccd.Signal_CCD_voltage.*( 1 +  ccd.noise.darkFPN_offset.noisematrix*(ccd.V_FW * ccd.noise.darkFPN_offset.DNcolumn)   ); %% add pixel FPN dark noise.
    end
%%%%% <----- ### Start:: If the sensor is CMOS and the Column FPN is on  - add the column FPN noise  (CMOS only!)

end

ccd.Signal_CCD_voltage = (ccd.Signal_CCD_voltage).*(ccd.A_CDS); 