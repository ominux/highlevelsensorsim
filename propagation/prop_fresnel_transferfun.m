%> @file prop_fresnel_transferfun.m
%> @brief The Fresnel Transfer function (propTF) propagator based on the Fourier transform
%> @author David Voelz
%> @section fresnel_propTF One-step Fresnel Transfer Function (propTF) propagator
%> The Fresnel diffraction expression is often the approach of choice for simulations since it applies to a wide range of propagation scenarios and is relatively straightforward to compute~\cite{voelz2011computational}. A common propagation routine is based on the quation:
%> 
%> \f$U_2(x,y) = \mathcal{F}^{-1} \{ \mathcal{F}(U_1(x,y)) H(f_X, f_Y)   \},\f$
%> 
%> where the transfer function \f$H\f$ is given by:
%> 
%> \f$ H(f_X, f_Y)   = \exp[ikz]  \exp\left[-i\pi  \lambda z (f_X^2+ f_Y^2)  \right]\f$
%> 
%> Implemented as propTF in the book~\cite{voelz2011computational} (Chapter 5, Section 5.1), this propagator function takes the source field \f$u_1\f$ (in the spatial domain) and produces the observation field \f$u_2\f$, where the source and observation side lengths and sample coordinates are identical.
%> %======================================================================
%> @param Uin = input field passed through circular/rectangular aperture
%> @param lambda = \f$\lambda\f$, optical wavelength [meters]
%> @param delta1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing [meters]
%> @param Delta_zet = \f$\Delta z\f$ propagation distance [meters]
%>
%> @retval Uout = propagated light field using Fresnel diffraction integral.
% ======================================================================
function [Uout, out]  = prop_fresnel_transferfun(Uin, lambda, delta1, Delta_zet)
N = size(Uin,1);    %> assume square grid
L = N*delta1;

fx = -1/(2*delta1):1/L:1/(2*delta1)-1/L; %freq coords
[FX,FY]=meshgrid(fx,fx);


% propagation - transfer function approach
H=exp(-i*pi*lambda*Delta_zet*(FX.^2+FY.^2)); %trans func
H=fftshift(H); %shift trans func

out.H = H; %% temporary, FIXME.

U1=fft2(fftshift(Uin)); %shift, fft src field
U2=H.*U1;

Uout = ifftshift(ifft2(U2)); %invervse fft, center obs field