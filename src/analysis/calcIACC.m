function IACC = calcIACC(IR,fs)
%
% Returns the interaural cross correlation
%
% See:
% [1] Schroeder, M., Rossing, T. D., Dunn, F., Hart-mann,   W.,   
%   Campbell, D., and  Fletcher, N.,?Springer handbook of acoustics,? 2007
%
% IR: an N x 2 matrix containing impulse response of 2 channels

% Check data size
if (size(IR,2)~=2)
    disp('Error. Signal input must be an N x 2 matrix.');
    return;
end

% +-1ms of max lag 
lag = ceil(0.001*fs);

% Interaural X-Corr, normalized
r = xcorr(IR(:,1),IR(:,2),lag,'coeff');
[maxCC,~] = max(r);
IACC = 1 - maxCC;
if IACC < 0.0001
    IACC = 0;
end

end
