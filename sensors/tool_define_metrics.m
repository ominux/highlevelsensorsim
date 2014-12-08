%> @file tool_define_metrics.m
%> @brief This simple routine defines various handy shorthand for cm and mm in the code. 
%>
%> @author Mikhail V. Konnik
%> @date   9 December 2014.
function [m, cm, mm, mum, nm, rad, mrad] = tool_define_metrics ()
 
m  = 1;
cm = 1e-2*m;
mm = 1e-3*m;
 
mum = 1e-6*m;
nm = 1e-9*m;
 
rad = 1;
mrad = 1e-3*rad;
