function [response, clipFlag] = MlsZap_selectch(IpDeviceInfo, OpDeviceInfo, ...
    outputChl, inputChl, srate, signalLength, responseLength, numRepeats, scale, savewav)

%function [response, clipFlag] = mlsZap(outputChl, inputChl, srate, signalLength, responseLength, scale, opt)
%
% Mutli-channel impulse response measurement function using Multiple Length
% Sequence (MLS)
%
% Input:
%   IpDeviceInfo: audio device IO structure
%   OpDeviceInfo: audio device IO structure
%   outputChl: signal output channel(s), as row vector (e.g. [1])
%   inputChl: signal input channel(s), as row vector (e.g. [1 2])
%   srate: sampling rate, in Hz
%   signalLength: order of MLS, where 2 <= order <=32, resulting length of
%                   signal is 2^signalLength-1
%   responseLength: response signal length, in samples
%   numRepeats: number of measurement repetitions to average (for improved
%   SNR)
%   scale: test signal scaling factor
%
% Output:
%   response: impulse response
%   clipFlag: flag if signal has been clipped
%
% Typical use:
%   resp = mlsZap(1,[1 2],44100,15,2048,.4);
%
% Written by:
%   Frederick S. Scott, August 2007
% Modified by:
%   Agnieszka Roginska, August 2007
%   Braxton Boren, October 2010
% Copyright Music Technology, New York University

%% checking arguments
if nargin < 10, savewav = 0; end
if nargin < 9, scale = .9; end
if nargin < 8, numRepeats = 1; end
if nargin < 7, responseLength = 2048; end
if nargin < 6, signalLength = 15; end
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

%% get signal and mult
loc = length(outputChl);
lic = length(inputChl);
signal = genmls(signalLength);
signal = signal(:);                             %column vectors required from here on out
psig = signal;                                  %psig is played signal, keeps signal clean for deconv
psig = psig*ones(1,loc);                        %mults psig for # of output channels, loc

if responseLength>length(signal)
    fprintf('The requested response length exceeds MLS period, maximum response length is: %i\n', length(signal));
end

%% scale and zero pad
psig = [psig; psig];                            %doubling mls up yields perfect middle section
psig = psig.*scale;
zpd = .25*srate;                                %zeropads a 1/4 seconds before and after
psig = [zeros(zpd, loc); psig;zeros(zpd, loc)];

%% record
    
temp = playrec_selectch(IpDeviceInfo, OpDeviceInfo,  ...
    psig', srate, outputChl, inputChl, (length(psig)+responseLength)/srate);

if isfield(savewav, 'az')
    filename = strcat(savewav.dir,...
        sprintf('ID%i_Az%iEl%iDist%i.wav', savewav.ID, savewav.az, savewav.el, savewav.dist));
    fprintf('Saving WAV file to %s\n', filename);
    audiowrite(filename,temp',srate,'BitsPerSample',24);
end

%{
clipFlag = 0;
if (max(abs(temp)) > 0.95), clipFlag = 1.0; end;
%}

i = 1;                                          %repeats and averages for better signal to noise ratio
while i < numRepeats
    %peat = playrec_selectch(psig', srate, outputChl, lic, (length(psig)+responseLength)/srate);
    playrec_selectch(IpDeviceInfo, OpDeviceInfo, ...
    psig', srate, outputChl, inputChl, (length(psig)+responseLength)/srate);
    temp = temp+peat;
    i = i + 1;
end
temp = temp./numRepeats;
temp = temp'; 

clipFlag = 0;
if (max(abs(temp(:))) > 0.95), clipFlag = 1.0; end
temp = temp(zpd+1:length(signal)+responseLength+zpd, 1:lic);        %takes off zeropadding before deconvolution

response = decmls(temp, signal, responseLength, lic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = decmls(recorded, mlss, responseLength, lic)
%deconvolves recorded mls into an impulse response
lm = length(mlss);
mlss = mlss*ones(1,lic);
lr = length(recorded);
pad = zeros(lr-lm,lic);
mlss = [mlss; pad];
    for k=1:lic
        y(:,k) = xcorr(recorded(:, k),mlss(:, k), 'biased');
    end
y = y(lr:lr+responseLength-1,1:lic);