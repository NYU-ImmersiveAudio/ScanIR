function ILD = getILD(IR,fs)
%
% Returns the ILD in dB of an HRIR/BRIR after applying a low-pass
% filter.
%
% See:
% [1] Boyd, A. W., Whitmer, W. M., & Akeroyd, M. A. (2014). Recording and 
%   analysis of head movements, interaural level and time differences in 
%   rooms and real-world listening scenarios. ISRA 2013, P021.
%
% IR: an N x 2 matrix containing impulse response of 2 channels
% ILD: interaural level difference (in samples)

% Check data size
if (size(IR,2)~=2)
    disp('Error. Signal input must be an N x 2 matrix.');
    return;
end

% Bandpass filter 2-4 kHz
fc = [2000 4000]/(fs/2);
[b,a] = butter(4,fc,'bandpass');
IR = filtfilt(b,a,IR);


% Interaural power difference
pow1 = sum(IR(:,1).^2)/size(IR,1);
pow2 = sum(IR(:,2).^2)/size(IR,1);

ILD = 10*log10(pow1/pow2);

end
