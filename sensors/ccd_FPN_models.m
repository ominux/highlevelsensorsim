%> @file ccd_FPN_models.m
%> @brief The routine contains various models on simulation of FPN
%> @author Mikhail V. Konnik
%> @date   8 February 2011, re-worked on 9 December 2014.
%> 
%> @section fpnsimmodels Models on Simulation of Fixed Pattern Noise
%> There are many models for simulation of the FPN: some of the models are suitable
%> for short-exposure time modelling (Gaussian),
%> while other models are more suitable for log-exposure modelling of dark current
%> FPN.
%> 
%> @subsection janesickfpn Gaussian model (Janesick-Gaussian)
%> Fixed-pattern noise (FPN) arises from changes in dark currents due to variations
%> in pixel geometry during fabrication of the sensor. FPN increases exponentially
%> with temperature and can be measured in dark conditions. 
%> Column FPN is caused by offset in the integrating amplifier,
%> size variations in the integrating capacitor CF, channel charge injection from
%> reset circuit. FPN components that are reduced by CDS.
%> Dark current FPN can be expressed as:
%> 
%> \f$ \sigma_{D_{FPN}} = D\cdot D_N,\f$ 
%> 
%> where \f$D_N\f$ is the dark current FPN quality, which is typically between 10\%
%> and 40\% for CCD and CMOS sensors\cite{photontransferbook}, and  \f$D = t_I D_R\f$ 
%> that is described in detail in @ref darkshot. There are other models of
%> dark FPN, for instance as a autoregressive process.
%> 
%> 
%> @subsection elgamalfpn El Gamal model of FPN with Autoregressive process
%> To capture the structure of FPN in a CMOS sensor we express \f$F_{i,j}\f$ as the
%> sum of a column FPN component \f$Y_j\f$ and a pixel FPN component \f$X_{i,j}\f$.
%> Thus, \f$ F_{i,j} = Y_j + X_{i,j},\f$ where the \f$Y_j\f$'s and the
%> \f$X_{i,j}\f$'s are zero mean random variables.
%> 
%> The first assumption is that the random processes
%> \f$Y_{j}\f$ and \f$X_{i,j}\f$ are uncorrelated. This assumption is reasonable
%> since the column and pixel FPN are caused by different device parameter
%> variations. We further assume that the column (and pixel) FPN processes are
%> isotropic.
%> 
%> The idea to use autoregressive processes to model FPN was proposed because their
%> parameters can be easily and efficiently estimated from data.
%> The simplest model, namely first order isotropic
%> autoregressive processes is considered (model can be extended to higher order
%> models, however, the results suggest that additional model complexity may not be
%> warranted.
%> 
%> The model assumes that the column FPN process \f$Y_{j}\f$ is a first order
%> isotropic autoregressive process of the form: @n
%> \f$Y_j = a(Y_{j-1}+Y_{j+1}) + U_j\f$ @n
%> where the \f$U_j\f$ s are zero mean, uncorrelated random variables with the same
%> variance \f$\sigma_U\f$ , and \f$0 \leq a \leq 1\f$ is a parameter that
%> characterises the dependency of \f$Y_{j}\f$ on its two neighbours.
%> 
%> The model assumes that the pixel FPN process \f$X_{i,j}\f$ is a two dimensional
%> first order isotropic autoregressive process of the form:@n
%>  \f$X_{i,j} = b(X_{i-1,j} + X_{i+1,j} +  X_{i,j-1} + X_{i,j+1} ) + V_{i,j}\f$ @n
%> where the \f$V_{i,j}\f$ s are zero mean uncorrelated random variables with the
%> same variance \f$\sigma_V\f$ , and  \f$0 \leq b \leq 1\f$ is a parameter that
%> characterises the dependency of \f$X_{i,j}\f$ on its four neighbours.
%> 
%======================================================================
%> @param ccd 				= input structure of signal.
%> @param sensor_signal_rows		= number of rows in the signal matrix.
%> @param sensor_signal_columns		= number of columns in the signal matrix.
%> @param noisetype			= type of noise to generate: valid are @b 'pixel' or @b 'column'
%> @param noisedistribution			= the probability distribution name.
%> @param noise_params			= a vector of parameters for the probability distribution name.
%> 
%> @retval noiseout			= generated noise of FPN
% ======================================================================
function noiseout = ccd_FPN_models(ccd, sensor_signal_rows, sensor_signal_columns, noisetype, noisedistribution, noise_params);


switch noisedistribution

%%% ### <---- AR-ElGamal FPN model
	case 'AR-ElGamal' %% runnig El Gamal white noise Autoregressive noise model.

        if strcmp(noisetype, 'pixel')
		x2 = randn(sensor_signal_rows,sensor_signal_columns); % g is a uniformly distributed White Gaussian Noise.
		noiseout = filter(1, noise_params, x2); % here y is observed (filtered) signal. Any WSS process y[n] can be of
        end
        
	    if strcmp(noisetype, 'column')
		x = filter(1, noise_params, randn(1,sensor_signal_columns)); % AR(1) model
		noiseout = repmat(x,sensor_signal_rows,1); %% making PRNU as a ROW-repeated noise, just like light FPN
	    end
%%% ### <---- AR-ElGamal FPN model


%%% ### <---- Janesick-Gaussian FPN model
	case 'Janesick-Gaussian' %% runnig El Gamal white noise Autoregressive noise model.
	    if strcmp(noisetype, 'pixel')
		noiseout = randn(sensor_signal_rows,sensor_signal_columns); % here y is observed (filtered) signal. Any WSS process y[n] can be of
        end
        
	    if strcmp(noisetype, 'column')
		x = randn(1,sensor_signal_columns);  %% dark FPN [e] <------ Konnik
		noiseout = repmat(x,sensor_signal_rows,1); %% making PRNU as a ROW-repeated noise, just like light FPN
        end
        
	    if strcmp(noisetype, 'row')
		x = randn(sensor_signal_rows,1);  %% dark FPN [e] <------ Konnik
		noiseout = repmat(x,1,sensor_signal_columns); %% making PRNU as a ROW-repeated noise, just like light FPN
	    end
%%% ### <---- Janesick-Gaussian FPN model


%%% ### <---- Wald FPN model
	case 'Wald' %% runnig El Gamal white noise Autoregressive noise model.
	    if strcmp(noisetype, 'pixel')
		noiseout = tool_rand_distributions_generator('wald',noise_params(1),...
            [sensor_signal_rows, sensor_signal_columns]) + rand(sensor_signal_rows, sensor_signal_columns);
        end
        
	    if strcmp(noisetype, 'column')
		x = tool_rand_distributions_generator('wald',noise_params(1),[1, sensor_signal_columns])...
            + rand(1, sensor_signal_columns);
		noiseout = repmat(x,sensor_signal_rows,1); %% making PRNU as a ROW-repeated noise, just like light FPN
	    end
%%% ### <---- Wald FPN model



%%% ### <---- lognorm FPN model
	case 'LogNormal' %% runnig El Gamal white noise Autoregressive noise model.
	    if strcmp(noisetype, 'pixel')
		noiseout = tool_rand_distributions_generator('lognorm',[noise_params(1),noise_params(2)],...
            [sensor_signal_rows, sensor_signal_columns]);
        end

        if strcmp(noisetype, 'column')
		x = tool_rand_distributions_generator('lognorm',[noise_params(1),noise_params(2)],...
            [1, sensor_signal_columns]);
		noiseout = repmat(x,sensor_signal_rows,1); %% making PRNU as a ROW-repeated noise, just like light FPN
	    end
%%% ### <---- lognorm FPN model


end %% switch ccd.noise.FPN.model