%> @file ccd_photosensor_photonshotnoise.m
%> @brief This routine adds photon shot noise to the signal of the photosensor that is in photons.
%> @author Mikhail V. Konnik
%> @date   17 January 2011, improved 2 December 2014
%>
%> @section ccdphotosensor Convesrion from photons to electrons: Photon shot noise
The photon shot noise is due to the random arrival of photons and can be described by a Poisson process as discussed in Subsection~\ref{sec:photonshot}. \label{review:20R1}Therefore, for each $(i,j)$-th element of the matrix $I_{ph}$ that contains the number of collected photons, a photon shot noise  is simulated as a Poisson process $\mathcal{P}$   with mean $\Lambda$:

    $I_{ph.shot}  = \mathcal{P}(\Lambda), \,\,\,\,\mbox{ where   } \Lambda = I_{ph} .$

In MATLAB, we   use the \texttt{poissrnd} function that generates Poisson random numbers with mean $\Lambda$.  \label{review:23R1} That is, the number of collected photons in \label{review:21R1} $(i,j)$-th pixel of the simulated photosensor in the matrix $I_{ph}$ is used as the mean $\Lambda$ for the generation of Poisson random numbers to simulate the photon shot noise. The input of the \texttt{poissrnd} function will be the matrix $I_{ph}$ that contains the number of collected photons. The output will be the matrix $I_{ph.shot} \rightarrow I_{ph}$, i.e., the signal  with added photon shot noise.  \label{review:21-7R1} The matrix $I_{ph.shot}$ is recalculated each time the simulations are started, which corresponds to the temporal nature of the photon shot noise.
%======================================================================
%> @param sensor_signal	= irradiance matrix [matrix NxM], [photons].
%>
%> @retval signal 	= signal of the photosensor in photons  with added Poisson noise (photon shot noise) [matrix NxM], [photons].
% ======================================================================
function sensor_signal_out = ccd_photosensor_photonshotnoise(sensor_signal_in)

%%% Since this is a shot noise, it must be random every time we apply it, unlike the Fixed Pattern Noise (PRNU or DSNU).
                    rand('state', sum(100*clock));
                    randn('state', sum(100*clock));

%%% Apply the Poisson noise to the signal.
sensor_signal_out  = poissrnd(sensor_signal_in); %%% signal must be in PHOTONS - and it must be round numbers.