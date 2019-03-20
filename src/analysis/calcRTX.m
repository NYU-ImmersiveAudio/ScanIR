function [ T ] = calcRTX( x_d, low, high, fs, linFit )
% calcRTX
%
% Calculate a reverberation parameter in an IR, can be used for EDT, RT60,
% RT30, etc...
% Uses a fitted regression line
% ---------------------------
% INPUTS
%
% x_d   :   Schroeder Decay Curve 1 x t
% low   :   Lower bound of estimation (dB)
% high  :   Higher bound of estimation (dB)
% fs    :   Sample Rate (Hz)
%
% OUTPUTS
% RT     :   Target Reverberation parameter (seconds)

if low < high
    temp = high;
    high = low;
    low = temp;
end
T = zeros(1,size(x_d,2));

for ch = 1:size(T,2)
    low_idx = find(x_d(:,ch)<=low,1,'first');
    high_idx = find(x_d(:,ch)<=high,1,'first');
    if isempty(low_idx) || isempty(high_idx)
        T(ch) = NaN;
        break
    end
    
    if linFit
        x = [low_idx:1:high_idx]';
        y = x_d(low_idx:high_idx,ch);
        p = polyfit(x,y,1);
        r_y = polyval(p,1:5*size(x_d,1));
        
        decay = find(r_y-max(r_y)<=-abs(high-low),1,'first')/fs;
    else
        decay = abs(high_idx-low_idx)/fs;
    end
    T(ch) = (60/abs(high-low))*decay;
end

end

