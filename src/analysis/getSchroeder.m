function [ x_d ] = getSchroeder( x_t )
%SCHROEDER_CURVE 
%  
% Take a time-domain IR signal and compute the logarithmic decay curve
% (Schroeder Curve)
% ---------------------------
% INPUTS
%
%    x_t: 1 x L array
%        input signal (mono)
%
% OUTPUTS
%    x_rev : 1 x L array
%        Schroeder Reverberation Curve

% denoise pre-processing

x_d = zeros(size(x_t));
for ch = 1:size(x_t,2) 
    
n_rms = rms(x_t(round(end-end/10):end,ch));
sig = (abs(x_t(:,ch)) - n_rms).^2;

%sig = x_t.^2;

z = cumsum(flip(sig));
z = flip(z);

z_log = 10*log10(z);
x_d(:,ch) = z_log - max(z_log);

% remove infinite values and pad to last non-inf value
inf_idx = find(isinf(x_d(:,ch)),1,'first')-1;
if ~isempty(inf_idx)
    x_d(inf_idx+1:end,ch) = x_d(inf_idx,ch); 
end


end

