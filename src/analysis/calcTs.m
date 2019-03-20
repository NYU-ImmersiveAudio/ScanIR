function [ Ts ] = calcTs( x_t, fs )
% calcTs
% Calculates the Central Time parameter for IR temporal weight
%
%
% ---------------------------
% INPUTS
%
% x_t   :   Time Domain IR ( 1 x t )
% fs    :   Sample Rate (Hz)
%
% OUTPUTS
% Ts   :   Central Time 

Ts = zeros(1,size(x_t,2));
t = 0:1/fs:(size(x_t,1))/fs-1/fs;
for ch = 1:size(Ts,2)
    H = x_t(:,ch);
    Ts(ch) = sum(t'.*H.^2)/sum(H.^2);
end
end


