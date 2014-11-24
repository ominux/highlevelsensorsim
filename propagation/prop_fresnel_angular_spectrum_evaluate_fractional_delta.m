%> @file prop_fresnel_angular_spectrum_evaluate_fractional_delta.m
%> @brief Evaluation of propagation in turbulent media.
%> @author Jason D. Schmidt, Mikhail Konnik (improvements)
%> @date   28 July 2014
%>
%> @section fractionaldelta Evaluation of fractional grid spacing for the propagation 
%> Using those broad window functions, it is possible to reduce aliasing and consequently relax sampling constraints in Angular Spectrum propagation method. The partial propagation uses the angular spectrum propagation with the following definitions:
%> 
%> - \f$\Delta z_1\f$ is the distance between source plane and the middle plane; 
%> - \f$\Delta z_2\f$ is the distance between middle plane and the observation plane; 
%> - \f$\alpha = \Delta z_1/\Delta z\f$ fractional distance of first propagation. 
%> 
%======================================================================
%> @param layers_z = propagation plane locations, augmenting propagation altitudes  [meters].
%> @param delta_1 = \f$\delta_1 =\frac{L}{N}\f$ grid spacing  in the source plane [meters].
%> @param delta_n = \f$\delta_2 = m\cdot\delta_1 \f$ grid spacing in the observation plane  [meters].
%>
%> @retval m_frac       = fractional part of the grid spacing for each layer.
%> @retval n            = number of propagation planes
%> @retval delta_frac   = current grid spacing for i-th layer - _frac_ grid spacing.
%> @retval Delta_z_frac = propagation distances [m]
% ======================================================================
function [m_frac,n,delta_frac,Delta_z_frac] = prop_fresnel_angular_spectrum_evaluate_fractional_delta(layers_z,delta1,delta_n)

z = [0 layers_z]; % propagation plane locations, augmenting propagation altitudes with ZERO that is observation plane
n = length(z);

% propagation distances
Delta_z_frac = z(2:n) - z(1:n-1);

% grid spacings
alpha = z / z(n);  %%fractional distance from plane 1 to plane i+1
delta_frac = (1-alpha) * delta1 + alpha * delta_n; %% current grid spacing for i-th layer - _frac_ grid spacing.
m_frac = delta_frac(2:n) ./ delta_frac(1:n-1);