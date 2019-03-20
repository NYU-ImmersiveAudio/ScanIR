function [ D50 ] = calcD50( x_t, fs )
% calcD50
% Calculate the Deutlichkeit
%
%
% ---------------------------
% INPUTS
%
% x_t   :   Time Domain IR ( 1 x t )
% fs    :   Sample Rate (Hz)
%
% OUTPUTS
% D50   :   Definition (Deutlichkeit)

thresh = 0.05;
idx = round(thresh*fs);
D50 = zeros(1,size(x_t,2));
if idx > size(x_t,1) - 1
    disp('Need more samples to calculate the definition')
    return
end
for ch = 1:size(x_t,2)
    E = sum(x_t(1:idx,ch).^2);
    L = sum(x_t(:,ch).^2);
    D50(ch) = (E/L);
end
end

