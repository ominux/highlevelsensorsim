%> @file prop_fresnel_impulseresponse.m
%> @brief The Fresnel Impulse Response (propIR) propagator
%> @author David Voelz
%> @section fresnel_propIR One-step Fresnel Impulse Response (propIR) propagator
%> Another propagation approach~\cite{voelz2011computational} can be devised based on the impulse response:
%> 
%> \f$ U_2(x,y) = \mathcal{F}^{-1} \{ \mathcal{F}(U_1(x,y) ) \mathcal{F}(h(x,y)  \}, \mbox{ where } h(x,y) =  \frac{  \exp[ikz]  }{i \lambda z }  \exp\left[   \frac{e^{ik} }{2z} (x^2 +y^2) \right] \f$
%> 
%> Here in \f$\exp\left[   \frac{e^{ik} }{2z} (x^2 +y^2) \right]\f$ we apparently use the Fresnel approximation.
%> 
%> The propIR code is similar to the propTF function, where the source and observation planes assumed to have the same side length. 
%> 
%> Due to numerical artifacts, the IR approach turns out to be more limited in terms of the situations where it should be used than the TF approach, however, it provides a way to simulate propagation over longer distances and is useful for the discussion of simulation limitations and artifacts.
%> %======================================================================
%> @param Uin = input field passed through circular/rectangular aperture
%> @param lambda = \f$\lambda\f$, optical wavelength [meters]
%> @param delta1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing [meters]
%> @param Delta_zet = \f$\Delta z\f$ propagation distance [meters]
%>
%> @retval Uout = propagated light field using Fresnel diffraction integral.
% ======================================================================
function Uout = prop_fresnel_impulseresponse(Uin, lambda, delta1, Delta_zet)
N = size(Uin,1);    %> assume square grid
L = N*delta1;
k=2*pi/lambda;

x=-L/2:delta1:L/2-delta1; %spatial coords
[X,Y]=meshgrid(x,x);

% propagation - impulse response approach 
h=1/(i*lambda*Delta_zet) * exp(i*k/(2*Delta_zet)*(X.^2+Y.^2)); %impulse response

H=fft2(fftshift(h))*delta1^2; %create the transfer function

U1=fft2(fftshift(Uin)); %shift, fft src field

U2=H.*U1; %multiply

Uout = ifftshift(ifft2(U2)); %invervse fft, center obs field