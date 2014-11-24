%> @file demo_FPN_ARmodel.m
%> @brief The aim of the routine is to implement Autoregressive model of a stochastic signal
%> @author Mikhail V. Konnik
%> @date   5 January 2011
%>
%> @section ARmodel Autoregressive model of a stochastic signal in a nutshell
%> Assume we have a noise-alike discrete sequence \f$y[n]\f$ that we want to study. We can describe the signal in terms of autocorrelation or power spectrum density, but we can also describe it in the other way. We can actually describe the noised signal \f$y[n]\f$ as a result of passing a white noise \f$x[n]\f$ through a filter \f$h[n]\f$. The filter \f$h[n]\f$ can be described in Z-domain as following: @n
%> \f$ H(z) = \frac{B(z)}{A(z)} = \frac{\sum\limits_{k=0}^{q} b_k z^{-k} }{1+ \sum\limits_{k=0}^{p} a_k z^{-k} }\f$
%>
%> that is a stable shift-invariant linear system with \f$p\f$ poles and \f$q\f$ zeros. The autoregressive (AR) model is a case of the ARMA and is the following:@n
%> \f$H(z) = \frac{b_0}{1+ \sum\limits_{k=0}^{p} a_k z^{-k} }\f$
%>
%> Any WSS process \f$y[n]\f$ can be represented as the output of filter \f$h[n]\f$ that is driven by noise x[n]. Using that filter coefficients (arbitrary chosen - we just need to generate the signal), we design the signal which we are going to study. Then we describe the signal \f$y[n]\f$ in terms of filter function defined by AR coefficients.
%>
%> where \f$a_1, \dots, a_p\f$ are the parameters of the model. We can think\cite{ramadanadaptivefiltering} of the signal \f$y[n]\f$ being studied as a result of passing the white noise \f$x[n]\f$ with known variance \f$\sigma_x^2\f$ through the filter \f$H[z]\f$.
%>
%> The autocorrelation function \f$y[n]\f$ and the parameters of the filter \f$H[z]\f$ are related via Yule-Walker equation: @n
%>  \f$R_{yy}[k] +  \sum_{m=1}^p a_m R_{yy}[k-m] = \sigma_x^2 b_0^2 \delta_{m,0},\f$
%>
%> where \f$m = 0, ... , p,\f$ yielding \f$p+1\f$ equations. Those equations are usually written in matrix form:
%> \f$ \left[ \begin{matrix} R_{yy}(0) & R_{yy}(-1) & \dots R_{yy}(-p) \\ R_{yy}(1) & R_{yy}(0)  & \dots R_{yy}(-p+1) \\ \vdots    & \vdots     & \vdots           \\   R_{yy}(p) & R_{yy}(p-1)& \dots R_{yy}(0) \\   \end{matrix} \right] \left[  \begin{matrix}  1 \\ a_1 \\ \vdots \\ a_p  \end{matrix}\right] = \sigma_x^2 b_0^2  \left[  \begin{matrix}   1 \\ 0 \\ \vdots \\ 0  \end{matrix}\right] \f$ @n
%>  and we need to solve this matrix equation for coefficients \f$a_1 \dots a_p\f$. The above equations provide the way for estimation of the parameters of an AR(p) model. In order to solve the matrix equation, we must replace the theoretical covariances with estimated values such as \f$R_{yy}(0)\f$.
%>
%>  subsection toeplitzmat A note of Toeplitz matrices
%>  When we study a signal and calculate its autocorrelation sequence, we got a vector. In order to use these data in solving the matrix equation, we need to convert the autocorrelation vector into matrix. That can be performed by Toeplitz matrices. A Toeplitz matrix is a matrix in which each descending diagonal from left to right is constant: @n
%>  \f$    \begin{bmatrix} a & b & c & d & e \\ f & a & b & c & d \\ g & f & a & b & c \\ h & g & f & a & b \\ i & h & g & f & a \end{bmatrix}.\f$
%>  A Toeplitz matrix is defined by one row and one column. A symmetric Toeplitz matrix is defined by just one row. In order to generate the Toeplitz matrix, one can use \textbf{toeplitz} function in MATLAB that  generates Toeplitz matrices given just the row or row and column description.

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial parameters %%%%%%%%%%%%
signal_length = 2048;
filter_fft_length = 512;
show_signal_length = 256;
xcorr_maxlags =  6; %% calculates autocorrelation only on 15 points. Result will be the 2*xcorr_maxlags+1 vector of autocorrelation.
acorr_matrix_size = 10;
x_signal_variance = 0.2;
x_std = 0.2;
%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial parameters %%%%%%%%%%%%



%  x = sqrt(x_signal_variance)*(randn(1,signal_length)); % g is a uniformly distributed White Gaussian Noise.
%%% let's generate the signal Y from the white noise (it is a simulation of the real signal). Then we describe the signal Y in terms of filter function defined by ARMA coefficients.

%  x = (randn(1,signal_length)); % g is a uniformly distributed White Gaussian Noise.

%  y = filter(x_std, [1 0.5], x); % here y is observed (filtered) signal. Any WSS process y[n] can be represented as the output of filter h[n] that is driven by noise x[n]. Using that filter coefficients, we design the signal which we are going to study.
%  figure, imagesc(y) %%% this is for column FPN

x = (randn(1,signal_length)); % g is a uniformly distributed White Gaussian Noise.

y = filter(1, [1 0.5], x); % here y is observed (filtered) signal. Any WSS process y[n] can be represented as the output of
figure, imagesc(y*x_std^2) %%% this is for column FPN


x2 = (randn(signal_length,signal_length)); % g is a uniformly distributed White Gaussian Noise.
y2 = filter(1, [1 0.5], x2); % here y is observed (filtered) signal. Any WSS process y[n] can be represented as the output of
%  figure, imagesc(y2*x_std) %%% this is for pixel FPN
figure, imagesc(y2*x_std^2) %%% this is for pixel FPN


figure, hist(y,1000);
