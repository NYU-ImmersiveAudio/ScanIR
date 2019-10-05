function [response, clipFlag] = golayZap_selectch(IpDeviceInfo, OpDeviceInfo,...
    outputChl, inputChl, srate, signalLength, responseLength, numRepeats, delay, scale, savewav)

%function [response, clipFlag] = golayZap(outputChl, inputChl, srate, signalLength, responseLength, delay, scale)
%
% Mutli-channel impulse response measurement function using Golay codes
%
% Input:
%   IpDeviceInfo: audio device IO structure
%   OpDeviceInfo: audio device IO structure
%   outputChl: signal output channel(s), as row vector (e.g. [1])
%   inputChl: signal input channel(s), as row vector (e.g. [1 2])
%   srate: sampling rate, in Hz
%   signalLength: log length of test signal, 1 to 32, yields 2^signalLength samples
%   responseLength: response signal length, in samples
%   numRepeats: number of measurement repetitions to average (for improved
%   SNR)
%   delay: delay between code pair playback, in seconds
%   scale: test signal scaling factor
%
% Output:
%   response: impulse response
%   clipFlag: flag if signal has been clipped
%
% Typical use:
%   resp = golayZap(1,[1 2],44100,12,2048,1, .9);
%
% Written by:
%   Frederick S. Scott, August 2007
% Modified by:
%   Agnieszka Roginska, August 2007
% Copyright Music Technology, New York University

%% checking arguments
if nargin < 11, savewav = 0; end
if nargin < 10, scale = .9; end
if nargin < 9, delay = 1; end
if nargin < 8, numRepeats = 1; end
if nargin < 7, responseLength = 2048; end
if nargin < 6, signalLength = 11; end
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

% lic/loc
lic = length(inputChl);
loc = length(outputChl);

%% get golayPair
golayPair = gengolay(signalLength);
signalLength = length(golayPair);           % signalLength changes to the actual length, not log length
fprintf('\nSignal length in samples: %d\n', signalLength);

golayPair = golayPair*scale;
golayPair = golayPair';                     % switch to row vectors before feeding into playrec

% length of recorded signal, in samples
rsignalLength = 2^nextpow2(responseLength + signalLength);
% length of recorded signal, in seconds
recLength = rsignalLength / srate;

%% golay play back
SA = playrec_selectch(IpDeviceInfo, OpDeviceInfo, ones(loc,1)*golayPair(1,:), srate, outputChl, inputChl ,recLength);
[a b] = size(SA);
% disp('size of SA:');    % currently having a problem with this -
% disp(a);                % when running golayZap_selectch([1 2],1), SA/SB alternate between a size of 2048 and 3072
% disp(b);
%SA = AuProbe(golayPair(:,1)*ones(1,length(outputChl)), [signalLength,srate;rsignalLength,srate],outputChl,inputChl);
clipFlag = 0;
if (max(abs(SA(:))) > 0.95), clipFlag = 1.0; end
pause(delay);
SB = playrec_selectch(IpDeviceInfo, OpDeviceInfo, ones(loc,1)*golayPair(2,:), srate, outputChl, inputChl ,recLength);
[a b] = size(SB);
%SB = AuProbe(golayPair(:,2)*ones(1,length(outputChl)), [signalLength,srate;rsignalLength,srate],outputChl,inputChl);
if (max(abs(SB(:))) > 0.95), clipFlag = 1.0; end


if isfield(savewav, 'az')
    filename = strcat(savewav.dir,...
        sprintf('ID%i_Az%iEl%iDist%i.wav', savewav.ID, savewav.az, savewav.el, savewav.dist));
    fprintf('Saving WAV file to %s\n', filename);
    %wavwrite(temp, srate, 24, filename);
    audiowrite(filename,SB',srate,'BitsPerSample',24);
end

i = 1;
while i < numRepeats
    pause(delay)
    temp = playrec_selectch(IpDeviceInfo, OpDeviceInfo, golayPair(1,:)*ones(loc,1), srate, outputChl, lic,recLength);
    if (max(abs(temp)) > 0.95), clipFlag = 1.0; end;
    SA = SA+temp;
    pause(delay);
    temp = playrec_selectch(IpDeviceInfo, OpDeviceInfo, golayPair(2,:)*ones(loc,1), srate, outputChl, lic,recLength);
    if (max(abs(temp)) > 0.95), clipFlag = 1.0; end;
    SB = SB+temp;
    i = i+1;
end
SA = SA./numRepeats;
SB = SB./numRepeats;

% switch back to column vectors
SA = SA';
SB = SB';

golayPair = golayPair';
[a b] = size(golayPair);

% deconvolve to obtain IR
response = decgolay(SA,SB,golayPair,responseLength,inputChl,lic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = decgolay(SA,SB,golayPair,responseLength,inputChl,lic)
if length(SA)~=length(SB)
   diff = abs(length(SA)-length(SB));
   pad_corr = zeros(diff,lic);
   if length(SA) > length(SB)
       SB = [SB; pad_corr];
   elseif length(SB) > length(SA)
       SA = [SA; pad_corr];
   end
end

lrec = length(SA);
lsig = length(golayPair);
pad = zeros(lrec-lsig, lic);
golayPair = [golayPair; pad];

for k=1:lic;
    temp(:,k) = xcorr(SA(:,k), golayPair(:,1), 'biased')+xcorr(SB(:,k), golayPair(:,2),'biased');
end

y = temp((length(temp)+1)/2:(length(temp)+1)/2+responseLength-1, 1:lic);

