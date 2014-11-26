%> @file ccd_photosensor_FPN_modelling.m
%> @brief This routine generates the matrices for FPN.
%>
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%>
%> @section ccdfpnsim Simulation of FPN in CCD
%> In a CCD image sensor FPN is modelled as a sample from a spatial white noise process\cite{elgamalFPNmodeling}. This is justified by the fact that in a typical CCD sensor all pixels share the same output amplifier. As a result FPN is mainly due to variations in photodetector area and dark current, which are spatially uncorrelated. To estimate FPN for a CCD sensor output values are read out multiple times for each pixel at the same constant monochromatic illumination and an average pixel value is computed. The averaging reduces random noise and the remaining pixel output variations are the FPN. A single summary statistic of the FPN, usually the standard deviation of the averaged pixel values, is adequate to characterise the FPN since the output values are uncorrelated.
%>
%> @section cmosfpnsim Simulation of the FPN in CMOS
%> The white noise model, which is acceptable for CCD, is not adequate for characterising FPN in CMOS sensors because the readout circuitry for CMOS sensors and CCDs are different: the readout signal paths for both CMOS passive and active pixel sensors (PPS and APS) include several amplifiers some of which are shared by pixels and some are not. These amplifiers introduce additional FPN, which is not present in CCDs. In particular the FPN due to variations in column amplifier offsets and gains causes ``striped'' noise, which has a very different spatial structure than the white noise observed in CCDs. Even though the offset part of this column FPN is significantly reduced using correlated double sampling (CDS), the gain part is not. Therefore, to adequately characterise CMOS FPN, we must estimate separately factors associated with pixel to pixel variation, and column to column variation\cite{elgamalFPNmodeling}.
%======================================================================
%> @param ccd 				= input structure of signal.
%> @retval ccd.FPN.column 		= generated structure of the FPN column noise only is CMOS is selected.
%> @retval ccd.FPN.pixel		= generated structure of the FPN pixle noise for both CMOS and CCD.
% ======================================================================
function ccd = ccd_photosensor_FPN_modelling(ccd)

[sensor_signal_rows, sensor_signal_columns] = size(ccd.Signal_CCD_electrons);


%%%%##### adding Column FPN model - CMOS only!
	if (strcmp('CMOS',ccd.SensorType) == 1)
		ccd.FPN.column = ccd_FPN_models(ccd, sensor_signal_rows,sensor_signal_columns, 'column');
	end 
    

   