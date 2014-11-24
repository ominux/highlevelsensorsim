%> @file prop_absorbing_window_supergaussian.m
%> @brief Boundary absorbing window with the Super-Gaussian function for multi-step propagation.
%> 
%> @author Mikhail Konnik (based on the work by Jason D. Schmidt)
%> @date   8 July 2014
%>
%> @section supergaussian Super-Gaussian window
%> The attenuation of optical field is performed by multiplication of optical filed by data window at each propagation step. Therefore, we find the maximum propagation distance and split the whole $\Delta z$ on portions, and on each step we apply the absorbing (apodization) window function. The difference between data windowing and absorbing boundaries is to preserve the data in low spatial frequencies and attenuate only high-frequency data. Thus we need very broad windows like Super-Gaussian and Tukey.
%> 
%> The super-Gaussian~\cite{supergaussfunc} window function is:
%> 
%> \f$w_{sg}(x,y) = \exp \left[ -\frac{r}{\sigma} \right]^n \f$
%> 
%> where \f$n>2\f$. The \f$\sigma\f$ is the \f$1/e\f$ radius of the function, also referred as half-width of function. The lesser \f$n\f$, the more Super-Gaussian is looks like normal Gaussian window; greater values of \f$n\f$ make Super-Gaussian more step and rectangular.
%> 
%======================================================================
%> @param N = the size of the super-Gaussian matrix [NxN].
%> @param n = the power n of the \f$[(x^2+y^2)/\sigma]^n \f$.
%> @param beta = the parameter of boundaries sharpness, default is beta = 0.47*N;
%>
%> @retval absorbe_supergauss = the NxN matrix that contains the numerical approximation of the Super-Gaussian function.
% ======================================================================
function [absorbe_supergauss] = prop_absorbing_window_supergaussian(N, n, beta)

[nx ny] = meshgrid((-N/2 : 1 : N/2 - 1));
nsq = nx.^2 + ny.^2;

switch nargin
    case 2
        beta = 0.47; %% parameter in the power of sigma of the Super-Gaussian function;
    case 1
        beta = 0.47; %% parameter in the power of sigma of the Super-Gaussian function;
        n = 16; %%% the power of the sigma
    case 0
        error('AORTA:: Super Gaussian absorbtion function needs at least the size of the matrix as a parameter!');
end

%%%%%%% super-Gaussian absorbing boundary
w = beta*N;
absorbe_supergauss = exp( -nsq.^(n/2)  /   w^(n)  ); %% absorbe_supergauss -> super gaussian absorbtion function
%%%%%%% super-Gaussian absorbing boundary