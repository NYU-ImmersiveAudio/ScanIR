function response = sweepZap_selectch(IpDeviceInfo, OpDeviceInfo,  ...
    outputChl, inputChl, srate, signalLength, responseLength, numRepeats, low, hi, scale, savewav)
%function response = fsweepZap(outputChl, inputChl, srate, signalLength, responseLength, numRepeats, low, hi, scale)
%
% Multichannel impulse response measurement function using logarithmic
% sinesweep
%
% Input:
%   IpDeviceInfo: audio device IO structure
%   OpDeviceInfo: audio device IO structure
%   outputChl: array of output channels
%   inputChl: number of input channels
%   srate: sampling rate, in Hz
%   signalLength: length of test signal, in seconds
%   responseLength: response signal length, in samples
%   numRepeats: number of measurement repetitions to average (for improved
%   SNR)
%   low: starting frequency of sinesweep, in Hz
%   hi: ending frequency of sinesweep, in Hz
%   scale: test signal scaling factor
%
% Output:
%   response: impulse response
%
% Typical use:
%   resp = sweepZap_selectch(1,[1 2],44100,2,2048,1, 20,20000, .9);
%
% Written by:
%   Frederick S. Scott, August 2007
% Modified by:
%   Agnieszka Roginska, August 2007
% Copyright Music Technology, New York University

if nargin < 12, savewav = 0; end
if nargin < 11, scale = .9; end
if nargin < 10, hi = 20000; end
if nargin < 9, low = 20; end
if nargin < 8, numRepeats = 1; end
if nargin < 7, responseLength = 2048; end
if nargin < 6, signalLength = 2; end
if nargin < 5, srate = 44100; end
if nargin < 4, inputChl = [1 2]; end
if nargin < 3, outputChl = 1; end
if (responseLength <= 0) || (round(responseLength) ~= responseLength)
    error('responseLength must be an integer > 0')
end
if (numRepeats <= 0) || (round(numRepeats) ~= numRepeats)
    error('numRepeats must be an integer > 0')
end
if (scale <= 0) || (scale > 1)
    error('scale must be > 0 && <= 1')
end

lic = length(inputChl);
loc = length(outputChl);

signal = gensweep(srate, signalLength, low, hi);
signal = signal(:);                             %column vectors - later we'll switch to row vectors
psig = signal;                                  %psig is played signal, keeps signal clean for deconv
psig = psig*ones(1,loc);                        %mults psig for # of output channels

% scale and zero pad
psig = psig.*scale;
zpd = .25*srate;    %zeropads a 1/4 seconds before and after
psig = [zeros(zpd, loc); psig;zeros(zpd, loc)];


% first playback/record
temp = playrec_selectch(IpDeviceInfo, OpDeviceInfo,  ...
    psig', srate, outputChl, inputChl, (length(psig)+responseLength)/srate);


if isfield(savewav, 'az')
    filename = strcat(savewav.dir,...
        sprintf('ID%i_Az%iEl%iDist%i.wav', savewav.ID, savewav.az, savewav.el, savewav.dist));
    fprintf('Saving WAV file to %s\n', filename);
    audiowrite(filename,temp',srate,'BitsPerSample',24);
end

for i = 1:size(temp,1)
    [m, ind] = max(max(abs(temp(i,:))));
    if (m>.99)
        fprintf('clipping occurred on channel %i, value %1.2f\n\n', i, m);
    end
end

i = 1;                                      %repeats and averages for better signal to noise ratio
while i < numRepeats
    peat = playrec_selectch(IpDeviceInfo, OpDeviceInfo, ...
        psig', srate, outputChl, inputChl, (length(psig)+responseLength)/srate);
    temp = temp+peat;
    i = i + 1;
end
temp = temp./numRepeats;
temp = temp';               % switch back to column vector
temp = temp(zpd+1:length(signal)+responseLength+zpd, 1:lic);        %takes off zeropadding before deconvolution

response = decsweep(temp, signal, lic, srate, signalLength, responseLength);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

function y = decsweep(recorded, sweep, lic, srate, signalLength, responseLength)
sweep = sweep*ones(1,lic);                                          %mults raw sweep
rsweep = [zeros(.5*srate, lic);sweep;zeros(.5*srate, lic)];         %zeropadding sweep before inverse removes artifacts
rsweep = real(ifft(1./fft(rsweep)));
la = length(recorded);
lb = length(rsweep);
rsweep = [rsweep; zeros(lb-1, lic)];                                %zeropadding before conv
recorded = [recorded; zeros(la-1, lic)];
a = fft(rsweep, 2^nextpow2(length(recorded)));                      %much faster than conv function because of pow2's
b= fft(recorded,  2^nextpow2(length(recorded)));
y = ifft(a.*b);
y= y(srate*(signalLength+.5)+1:srate*(signalLength+.5)+responseLength,1:lic);
end

