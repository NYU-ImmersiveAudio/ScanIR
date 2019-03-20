function [ C ] = calcCI( x_t, fs, thresh )
% calcC80
% Calculate the Clarity Index
%
%
% ---------------------------
% INPUTS
%
% x_t   :   Time Domain IR ( 1 x t )
% fs    :   Sample Rate (Hz)
% thresh:   time threshold values (set 0.05 for speech, 0.08 for music)
% OUTPUTS
% C     :   Clarity Index

idx = round(thresh*fs);
C = zeros(1,size(x_t,2));
if idx > size(x_t,1) - 1
    disp('Need more samples to calculate the clarity index')
    return
end
for ch = 1:size(x_t,2)
    E = sum(x_t(1:idx,ch).^2);
    L = sum(x_t(idx+1:end,ch).^2);
    C(ch) = 10*log10(E/L);
end

end


