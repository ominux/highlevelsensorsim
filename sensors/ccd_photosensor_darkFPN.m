%> @file ccd_photosensor_darkFPN.m
%> @brief This routine for adding dark current noises that consist of Dark FPN and Dark shot noise.
%>
%> @author Mikhail V. Konnik
%> @date   17 January 2011
%>
%> @section darkfpn Dark Fixed Pattern Noise: general desciption
%> Fixed pattern noise (FPN) is the spatial variation in pixel output values under uniform illumination due to device and interconnect parameter variations (mismatches) across the sensor\cite{elgamalFPNlecture}. FPN is due to pixel-to-pixel variations in pixel geometry during fabrication of the sensor~\cite{hornseynoisebook}. Generally the problem arises from small differences in the individual responsitivity of the sensor array that might be caused by variations in the pixel size during fabrication of the sensor, variations in substrate material  or interference with the local circuitry.
%>
%> FPN increases with illumination adn exponentially increases with temperature\cite{nakamura2006image,irie2008model} that causes more degradation in image quality at low illumination levels. FPN is fixed for a given sensor, but varies from sensor to sensor.
%>
%> FPN consists of \textbf{offset}\footnote{Offset FPN is referred also as Dark Signal Non-Uniformity [DSNU], Dark FPN)} and \textbf{gain}\footnote{Gain FPN is referred also as Photoresponse Non-Uniformity [PRNU], or Light FPN} components. PRNU and dark FPN can be considered as analogous to each other: \textbf{FPN is an offset; PRNU is a gain}\cite{pixelLinkCameraParams}.
%>
%> @subsection typesfpn Types of FPN noise
%> The pixel output voltage \f$v_o\f$ and FPN \f$\sigma_{Vo}\f$ vary with illumination. Assuming linear sensor response (which we found to be reasonable) and photocurrent density \f$j_{ph}\f$ \f$A/cm^2\f$, we can express the pixel output voltage as \f$v_0 = h \cdot jph + v_{offset}\f$, where \f$h\f$ is the gain in \f$V\cdot cm^2/A\f$ (not to be confused with sensor conversion gain g) and \f$v_{offset}\f$ is the offset (which includes the dark signal as well as the offset voltages due to the amplifiers used, e.g., \f$v_{offset}\f$ for PPS).
%>
%> We can now write the pixel output voltage variation as \f$\sigma^2_{Vo} = j_{ph}\cdot\sigma^2 + \sigma^2_{v_{offset}}\f$ and and define gain FPN as \f$\sigma_H \cdot j_{ph}\f$ and offset FPN as \f$\sigma_{V_offset}\f$.
%>
%> In modelling, the FPN can be modelled as zero mean random variable and can be represented as sum of pixel and column components: \f$Q_f = (X + Y )\f$
%>
%> In general we can distinguish three major contributions @n
%>  \f$N_{FPN} = N_{dark-offset-FPN-pixel} + N_{dark-offset-FPN-column} + N_{light-gain-PRNU}\f$
%>
%> The offset \f$N_{dark-offset-FPN-pixel}\f$ is caused by semiconductor variations\cite{darkcurrentcompens}. It varies with temperature T but is independent otherwise.
%>
%> Each pixel has a slightly different sensitivity which is commonly called ``Photo Response Non Uniformity'' noise Nprnu. It is caused by variations in size and position of the photo site electronics and depends on the amount of light I. A model as shown in\cite{fowler1998method} assumes a fixed multiplicative gain G per pixel.
%>
%> @subsection offsetfpn Offset FPN
%> Offset FPN is a dark signal non-uniformity (Dark FPN), which is the offset from the average dark current across the imaging array at a particular setting (temperature, integration time) in the absence of illumination. The main cause of FPN in CMOS imagers is variations in \f$V_T\f$ between reset and buffer MOSFETs in the pixel and between MOSFETs in the column circuits. FPN can also arise from repeating irregularities in the array clocking allowing small variations in integration time, device mismatches in the pixels and color filters, variations in column amplifiers, and mismatches between multiple PGAs and ADCs.
%>
%> So the offset FPN is the one that affects dark current. Offset FPN can be column noise and pixel noise according to various noise models\cite{elgamalFPNmodeling,kelly2008fixed}.
%>  Mathematically, Dark current FPN can be expressed\cite{photontransferbook} as@n
%> \f$ \sigma_{D_{FPN}} = D\cdot D_N,\f$
%> where \f$D_N\f$ is the dark current FPN quality, which is typically between 10\% and 40\% for CCD and CMOS sensors. There are other models of dark FPN, for instance as a autoregressive process\cite{elgamalFPNmodeling}. A subtraction of the fixed noise then leads to an improvement in image quality\cite{malueg1976detector}.
%>
%> FPN is measured under dark conditions at a given integration time, temperature and gain. Dark current is linear with respect to integration time and doubles with every \f$6-8^{\circ}C\f$ increase in temperature.
%>
%> @subsection gainFPN Gain FPN
%> Gain FPN is photo response non-uniformity (PRNU, or Light FPN) that is a pixel-to-pixel variation in the sensor responsivity. Gain FPN can be described as the gain or ratio between irradiance on a pixel versus the electrical signal output. For example, although a sensor may be quoted as having a \f$4\mu m \times 4\mu m\f$ pixel, in reality, there will be a variation in pixel size across the array.
%>
%> Each pixel has a slightly different sensitivity to light is commonly called ``Photo Response Non Uniformity'' or light FPN\cite{janesickscintificCCD} is due to limitations in the fabrication process such as variations in the photomask alignment\cite{irie2008model} and slight variations in pixel geometry and substrate material. The effect of PRNU is proportional to illumination, and is prominent under high illumination levels\cite{gamalCMOSimagesensors}.
%>
%> Since PRNU is caused by the physical properties of a sensor, it is nearly impossible to eliminate and usually considered a normal characteristic of the sensor array. Typically the non-uniformity is only 1-2\%~\cite{janesickscintificCCD} that is more difficult to remove \cite{hpsensorsnoise}. Usually single error factor the PRNU (2\%) is prominent, photon shot noise is secondly\cite{irie2008model}.  The PRNU can be simulated as a variance of the quantum efficiency matrix. For instance, we can have QE coefficient with \f$\mu = 1\f$ and \f$\sigma = PN\f$, where PN is FPN/PRNU factor in percent.
%>
%> It is measured at a given integration time, temperature, and gain under uniform lighting conditions (typically at half of the saturation level).  This area variation will contribute to Gain FPN.  For megapixel area arrays, PRNU is quantified\cite{pixelLinkCameraParams} as: @n
%> \f$ PRNU = \frac{\sigma}{FrameMean} \% \f$
%>
%> Gain FPN can be pixel and column as well and depends on the type and architecture of the photosensor.
%>
%> @subsection fpncmosccd FPN for CCD and CMOS
%> FPN for CCD image sensors appears random. But CMOS (PPS and APS) sensors have higher FPN than CCDs and suffer from column FPN, which appears as ``stripes'' in the image and can result in significant image quality degradation. The difference is shown on Fig.~\ref{fig:FPNdifference_CMOS_CCD}.
%>
%> @subsection{Fixed Pattern Noise in CCD}
%> FPN for CCD image sensors appears random. CCD image sensors only suffer from \textit{pixel FPN} due to spatial variation in photodetector geometry and dark current - neither the CCDs nor the output amplifier (which is shared by all pixels) cause FPN.
%>
%======================================================================
%> @param dark_signal 	= matrix [NxM] of dark signals that contain @b only dark current noise [e-].
%> @retval dark_signal 	= matrix [NxM] of dark signals that contain Dark FPN [e-].
% ======================================================================
function ccd = ccd_photosensor_darkFPN(ccd)

ccd = ccd_photosensor_FPN_modelling(ccd); %% call the function to calculate the AR(1) FPN model
ccd.dark_signal = ccd.dark_signal.*(1 + (ccd.FPN.pixelDark)*(ccd.noise.FPN.DN)); %% add pixel FPN dark noise.