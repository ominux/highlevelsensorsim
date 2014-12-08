%> @file tool_rand_distributions_generator.m
%> @brief The routine contains various models for simulation of FPN (DSNU or PRNU).
%> @author Alex Bar Guy
%> 
%> @section noisedistribgeneration Generation of Probability Distributions
%> This routine generates various types of random distributions, and is based on the code "randraw"
%> by Alex Bar Guy  &  Alexander Podgaetsky.
%> 
%> Version 1.0 - March 2005 -  Initial version
%>   Alex Bar Guy  &  Alexander Podgaetsky
%>     alex@wavion.co.il
%> 
%>  These programs are distributed in the hope that they will be useful,
%>  but WITHOUT ANY WARRANTY; without even the implied warranty of
%>  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%> 
%> Any comments and suggestions please send to:
%>     alex@wavion.co.il
%======================================================================
%> @param distribName       = name of the distribution (string).
%> @param distribParams     = parameters of the distribution in a single vector.
%> @param sampleSize        = size of the matrix/vector to be generated, [N,M].
%> 
%> @retval out      = generated random matrix according to the specified probability distribution, matrix [matrix NxM].
% ======================================================================
function out = tool_rand_distributions_generator(distribName, distribParams, sampleSize)

funcName = mfilename;

distribNameInner = lower( distribName( ~isspace( distribName ) ) );

out = [];

    if prod(sampleSize) > 0
        
          switch lower( distribNameInner )
              
                  case {'exp','exponential'}
                    % START exp HELP START exponential HELP
                    % THE EXPONENTIAL DISTRIBUTION
                    %
                    % pdf = lambda * exp( -lambda*y );
                    % cdf = 1 - exp(-lambda*y);
                    %
                    %  Mean = 1/lambda;
                    %  Variance = 1/lambda^2;
                    %  Mode = lambda;
                    %  Median = log(2)/lambda;
                    %  Skewness = 2;
                    %  Kurtosis = 6;
                    %
                    % PARAMETERS:
                    %   lambda - inverse scale or rate (lambda>0)
                    %
                    % SUPPORT:
                    %   y,  y>= 0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %  The discrete version of the Exponential distribution is 
                    %  the Geometric distribution.
                    %
                    % USAGE:
                    %   randraw('exp', lambda, sampleSize) - generate sampleSize number
                    %         of variates from the Exponential distribution
                    %         with parameter 'lambda';
                    %   randraw('exp') - help for the Exponential distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('exp', 1, [1 1e5]);
                    %  2.   y = randraw('exp', 1.5, 1, 1e5);
                    %  3.   y = randraw('exp', 2, 1e5 );
                    %  4.   y = randraw('exp', 3, [1e5 1] );
                    %  5.   randraw('exp');
                    %
                    % SEE ALSO:
                    %   GEOMETRIC, GAMMA, POISSON, WEIBULL distributions
                    % END exp HELP END exponential HELP
                    
                    checkParamsNum(funcName, 'Exponential', 'exp', distribParams, [1]);  
                    lambda  = distribParams(1);
                    validateParam(funcName, 'Exponential', 'exp', 'lambda', 'lambda', lambda, {'> 0'});
                    
                    out = -log( rand( sampleSize ) ) / lambda;
                    
                    
               case { 'lognorm', 'lognormal', 'cobbdouglas', 'antilognormal' }
                    % START lognorm HELP START lognormal HELP START cobbdouglas HELP START antilognormal HELP
                    % THE LOG-NORMAL DISTRIBUTION
                    % (sometimes: Cobb-Douglas or antilognormal distribution)
                    %
                    % pdf = 1/(y*sigma*sqrt(2*pi)) * exp(-1/2*((log(y)-mu)/sigma)^2)
                    % cdf = 1/2*(1 + erf((log(y)-mu)/(sigma*sqrt(2))));
                    % 
                    % Mean = exp( mu + sigma^2/2 );
                    % Variance = exp(2*mu+sigma^2)*( exp(sigma^2)-1 );
                    % Skewness = (exp(1)+2)*sqrt(exp(1)-1), for mu=0 and sigma=1;
                    % Kurtosis = exp(4) + 2*exp(3) + 3*exp(2) - 6; for mu=0 and sigma=1;
                    % Mode = exp(mu-sigma^2);
                    %
                    % PARAMETERS:
                    %  mu - location
                    %  sigma - scale (sigma>0)
                    %
                    % SUPPORT:
                    %   y,  y>0
                    %
                    % CLASS:
                    %   Continuous skewed distribution                      
                    %
                    % NOTES:
                    %  1) The LogNormal distribution is always right-skewed
                    %  2) Parameters mu and sigma are the mean and standard deviation 
                    %     of y in (natural) log space.
                    %  3) mu = log(mean(y)) - 1/2*log(1 + var(y)/(mean(y))^2);
                    %  4) sigma = sqrt( log( 1 + var(y)/(mean(y))^2) );
                    %
                    % USAGE:
                    %   randraw('lognorm', [], sampleSize) - generate sampleSize number
                    %         of variates from the standard Lognormal distribution with 
                    %         loaction parameter mu=0 and scale parameter sigma=1;                    
                    %   randraw('lognorm', [mu, sigma], sampleSize) - generate sampleSize number
                    %         of variates from the Lognormal distribution with 
                    %         loaction parameter 'mu' and scale parameter 'sigma';
                    %   randraw('lognorm') - help for the Lognormal distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('lognorm', [], [1 1e5]);
                    %  2.   y = randraw('lognorm', [0, 4], 1, 1e5);
                    %  3.   y = randraw('lognorm', [-1, 10.2], 1e5 );
                    %  4.   y = randraw('lognorm', [3.2, 0.3], [1e5 1] );
                    %  5.   randraw('lognorm');                                           
                    %END lognorm HELP END lognormal HELP END cobbdouglas HELP END antilognormal HELP
                    
                    checkParamsNum(funcName, 'Lognormal', 'lognorm', distribParams, [0, 2]);
                    if numel(distribParams)==2
                         mu  = distribParams(1);
                         sigma  = distribParams(2);
                         validateParam(funcName, 'Lognormal', 'lognorm', '[mu, sigma]', 'sigma', sigma, {'> 0'});
                    else
                         mu = 0;
                         sigma = 1;
                    end

                    out = exp( mu + sigma * randn( sampleSize ) );
                    
                    
               case {'ig', 'inversegauss', 'invgauss'}                   
                    %
                    % START ig HELP START inversegauss HELP  START invgauss HELP
                    % THE INVERSE GAUSSIAN DISTRIBUTION
                    %
                    % The Inverse Gaussian distribution is left skewed distribution whose
                    % location is set by the mean with the profile determined by the
                    % scale factor.  The random variable can take a value between zero and
                    % infinity.  The skewness increases rapidly with decreasing values of
                    % the scale parameter.
                    %
                    %
                    % pdf(y) = sqrt(chi/(2*pi*y^3)) * exp(-chi./(2*y).*(y/theta-1).^2);
                    % cdf(y) = normcdf(sqrt(chi./y).*(y/theta-1)) + ...
                    %            exp(2*chi/theta)*normcdf(sqrt(chi./y).*(-y/theta-1));
                    %
                    %   where  normcdf(x) = 0.5*(1+erf(y/sqrt(2))); is the standard normal CDF
                    %         
                    % Mean     = theta;
                    % Variance = theta^3/chi;
                    % Skewness = sqrt(9*theta/chi);
                    % Kurtosis = 15*mean/scale;
                    % Mode = theta/(2*chi)*(sqrt(9*theta^2+4*chi^2)-3*theta);
                    %
                    % PARAMETERS:
                    %  theta - location; (theta>0)
                    %  chi - scale; (chi>0)
                    %
                    % SUPPORT:
                    %  y,  y>0
                    %
                    % CLASS:
                    %   Continuous skewed distribution
                    %
                    % NOTES:
                    %   1. There are several alternate forms for the PDF, 
                    %      some of which have more than two parameters
                    %   2. The Inverse Gaussian distribution is often called the Inverse Normal
                    %   3. Wald distribution is a special case of The Inverse Gaussian distribution
                    %      where the mean is a constant with the value one.
                    %   4. The Inverse Gaussian distribution is a special case of The Generalized
                    %        Hyperbolic Distribution
                    %
                    % USAGE:
                    %   randraw('ig', [theta, chi], sampleSize) - generate sampleSize number
                    %         of variates from the Inverse Gaussian distribution with 
                    %         parameters theta and chi;
                    %   randraw('ig') - help for the Inverse Gaussian distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('ig', [0.1, 1], [1 1e5]);
                    %  2.   y = randraw('ig', [3.2, 10], 1, 1e5);
                    %  3.   y = randraw('ig', [100.2, 6], 1e5 );
                    %  4.   y = randraw('ig', [10, 10.5], [1e5 1] );
                    %  5.   randraw('ig');
                    % 
                    % SEE ALSO:
                    %   WALD distribution
                    % END ig HELP END inversegauss HELP  END invgauss HELP 
                    
                    % Method:
                    %
                    % There is an efficient procedure that utilizes a transformation
                    % yielding two roots.
                    % If Y is Inverse Gauss random variable, then following to [1]
                    % we can write:
                    % V = chi*(Y-theta)^2/(Y*theta^2) ~ Chi-Square(1),
                    %
                    % i.e. V is distributed as a chi-square random variable with
                    % one degree of freedom.
                    % So it can be simply generated by taking a square of a
                    % standard normal random number.
                    % Solving this equation for Y yields two roots:
                    %
                    % y1 = theta + 0.5*theta/chi * ( theta*V - sqrt(4*theta*chi*V + ...
                    %      theta^2*V.^2) );
                    % and
                    % y2 = theta^2/y1;
                    %
                    % In [2] showed that  Y can be simulated by choosing y1 with probability
                    % theta/(theta+y1) and y2 with probability 1-theta/(theta+y1)
                    %
                    % References:
                    % [1] Shuster, J. (1968). On the Inverse Gaussian Distribution Function,
                    %         Journal of the American Statistical Association 63: 1514-1516.
                    %
                    % [2] Michael, J.R., Schucany, W.R. and Haas, R.W. (1976).
                    %     Generating Random Variates Using Transformations with Multiple Roots,
                    %     The American Statistician 30: 88-90.
                    %
                    %

                    checkParamsNum(funcName, 'Inverse Gaussian', 'ig', distribParams, [2]);
                    theta = distribParams(1);
                    chi = distribParams(2);
                    validateParam(funcName, 'Inverse Gaussian', 'ig', '[theta, chi]', 'theta', theta, {'> 0'});
                    validateParam(funcName, 'Inverse Gaussian', 'ig', '[theta, chi]', 'chi', chi, {'> 0'});

                    chisq1 = randn(sampleSize).^2;
                    out = theta + 0.5*theta/chi * ( theta*chisq1 - ...
                         sqrt(4*theta*chi*chisq1 + theta^2*chisq1.^2) );

                    l = rand(sampleSize) >= theta./(theta+out);
                    out( l ) = theta^2./out( l );
                    
               case {'logistic'}
                    % START logistic HELP
                    % THE LOGISTIC DISTRIBUTION
                    %   The logistic distribution is a symmetrical bell shaped distribution.
                    %   One of its applications is an alternative to the Normal distribution
                    %   when a higher proportion of the population being modeled is
                    %   distributed in the tails.
                    %
                    %  pdf(y) = exp((y-a)/k)./(k*(1+exp((y-a)/k)).^2);
                    %  cdf(y) = 1 ./ (1+exp(-(y-a)/k))
                    %
                    %  Mean = a;
                    %  Variance = k^2*pi^2/3;
                    %  Skewness = 0;
                    %  Kurtosis = 1.2;
                    %
                    % PARAMETERS:
                    %  a - location;
                    %  k - scale (k>0);
                    %
                    % SUPPORT:
                    %   y,  -Inf < y < Inf
                    %
                    % CLASS:
                    %   Continuous symmetric distribution                      
                    %
                    % USAGE:
                    %   randraw('logistic', [], sampleSize) - generate sampleSize number
                    %         of variates from the standard Logistic distribution with 
                    %         loaction parameter a=0 and scale parameter k=1;                    
                    %   randraw('logistic', [a, k], sampleSize) - generate sampleSize number
                    %         of variates from the Logistic distribution with 
                    %         loaction parameter 'a' and scale parameter 'k';
                    %   randraw('logistic') - help for the Logistic distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('logistic', [], [1 1e5]);
                    %  2.   y = randraw('logistic', [0, 4], 1, 1e5);
                    %  3.   y = randraw('logistic', [-1, 10.2], 1e5 );
                    %  4.   y = randraw('logistic', [3.2, 0.3], [1e5 1] );
                    %  5.   randraw('logistic');                       
                    % END logistic HELP
                    
                    % Method:
                    %
                    % Inverse CDF transformation method.

                    checkParamsNum(funcName, 'Logistic', 'logistic', distribParams, [0, 2]);
                    if numel(distribParams)==2
                         a  = distribParams(1);
                         k  = distribParams(2);
                         validateParam(funcName, 'Laplace', 'laplace', '[a, k]', 'k', k, {'> 0'});
                    else
                         a = 0;
                         k = 1;
                    end

                    u1 = rand( sampleSize );
                    out = a - k*log( 1./u1 - 1 );
                    
                    
                    
               case {'wald'}
                    % START wald HELP
                    % THE WALD DISTRIBUTION
                    %
                    % The Wald distribution is as special case of the Inverse Gaussian Distribution
                    % where the mean is a constant with the value one.
                    %
                    % pdf = sqrt(chi/(2*pi*y^3)) * exp(-chi./(2*y).*(y-1).^2);
                    %
                    % Mean     = 1;
                    % Variance = 1/chi;
                    % Skewness = sqrt(9/chi);
                    % Kurtosis = 3+ 15/scale;
                    %
                    % PARAMETERS:
                    %  chi - scale parameter; (chi>0)
                    %
                    % SUPPORT:
                    %  y,  y>0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('wald', chi, sampleSize) - generate sampleSize number
                    %         of variates from the Wald distribution with scale parameter 'chi';
                    %   randraw('wald') - help for the Wald distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('wald', 0.5, [1 1e5]);
                    %  2.   y = randraw('wald', 1, 1, 1e5);
                    %  3.   y = randraw('wald', 1.5, 1e5 );
                    %  4.   y = randraw('wald', 2, [1e5 1] );
                    %  5.   randraw('wald');                       
                    % END wald HELP
                                        
                    checkParamsNum(funcName, 'Wald', 'wald', distribParams, [1]);
                    chi = distribParams(1);
                    validateParam(funcName, 'Wald', 'wald', 'chi', 'chi', chi, {'> 0'});
                    
                    out = feval(funcName, 'ig', [1 chi], sampleSize);
                    
               otherwise
                    fprintf('\n RANDRAW: Unknown distribution name: %s \n', distribName);
                    
          end % switch lower( distribNameInner )
          
     end % if prod(sampleSize)>0


     
     
     
     

function checkParamsNum(funcName, distribName, runDistribName, distribParams, correctNum)
if ~any( numel(distribParams) == correctNum )
     error('%s Variates Generation:\n %s%s%s%s%s', ...
          distribName, ...
          'Wrong numebr of parameters (run ',...
          funcName, ...
          '(''', ...
          runDistribName, ...
          ''') for help) ');
end
return;


     
function validateParam(funcName, distribName, runDistribName, distribParamsName, paramName, param, conditionStr)
condLogical = 1;
eqCondStr = [];
for nn = 1:length(conditionStr)
     if nn==1
          eqCondStr = [eqCondStr conditionStr{nn}];
     else
          eqCondStr = [eqCondStr ' and ' conditionStr{nn}];          
     end
     eqCond = conditionStr{nn}(1:2);
     eqCond = eqCond(~isspace(eqCond));
     switch eqCond
          case{'<'}
               condLogical = condLogical & (param<str2num(conditionStr{nn}(3:end)));
          case{'<='}
               condLogical = condLogical & (param<=str2num(conditionStr{nn}(3:end)));               
          case{'>'}
               condLogical = condLogical & (param>str2num(conditionStr{nn}(3:end))); 
          case{'>='}
               condLogical = condLogical & (param>=str2num(conditionStr{nn}(3:end)));
          case{'~='}
               condLogical = condLogical & (param~=str2num(conditionStr{nn}(3:end)));
          case{'=='}
               if strcmp(conditionStr{nn}(3:end),'integer')
                    condLogical = condLogical & (param==floor(param));                    
               else
                    condLogical = condLogical & (param==str2num(conditionStr{nn}(3:end)));
               end
     end
end

if ~condLogical
     error('%s Variates Generation: %s(''%s'',%s, SampleSize);\n Parameter %s should be %s\n (run %s(''%s'') for help)', ...
          distribName, ...
          funcName, ...
          runDistribName, ...
          distribParamsName, ...
          paramName, ...
          eqCondStr, ...
          funcName, ...
          runDistribName);
end
return;     