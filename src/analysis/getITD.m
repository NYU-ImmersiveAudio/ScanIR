function ITD = getITD(IR,fs)
%
% Returns the ITD in seconds of an HRIR/BRIR after applying a low-pass
% filter.
%
% See:
% [1] Katz, Brian FG, and Markus Noisternig. "A comparative study of 
%   interaural time delay estimation methods." The Journal of the  
%   Acoustical Society of America 135.6 (2014): 3530-3540.
%
% IR: an N x 2 matrix containing impulse response of 2 channels
% ITD: interaural time difference (in samples)

% Check data size
if (size(IR,2)~=2)
    disp('Error. Signal input must be an N x 2 matrix.');
    return;
end

% Filter to 3 kHz
fc = 3000/(fs/2);
[b,a] = butter(4,fc,'low');
IR = filtfilt(b,a,IR);


% Interaural X-Corr
c = xcorr(IR(:,1),IR(:,2));
[~,i] = max(c);
ITD = (length(IR)/2 - (i - length(IR)/2))/fs;

end
