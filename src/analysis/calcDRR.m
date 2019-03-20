function [ DRR ] = calcDRR( x_t, fs )
% CALCDRR
% Calculate the Direct-To-Reverberant Ratio
%
%
% [1] Zahorik, P., 2002: 'Direct-to-reverberant energy ratio 
%      sensitivity', The Journal of the Acoustical Society of America, 
%      112, 2110-2117.
%
% ---------------------------
% INPUTS
%
% x_t   :   Time Domain IR ( 1 x t )
% fs    :   Sample Rate (Hz)
%
% OUTPUTS
% R   :   DRR

thresh = 0.0025;
idx = round(thresh*fs);
DRR = zeros(1,size(x_t,2));
if idx > size(x_t,1) - 1
    disp('Need more samples to calculate the DRR')
    return
end
for ch = 1:size(x_t,2)
    D = sum(x_t(1:idx,ch).^2);
    R = sum(x_t(idx+1:end,ch).^2);
    DRR(ch) = 10*log10(D/R);
end

end

