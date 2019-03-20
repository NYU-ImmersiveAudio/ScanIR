function y = gensweep(srate, signalLength, lo, hi, sweepMethod)
%function y = gensweep(srate, signalLength, lo, hi)
%
%Generates sine sweep
% Input:
%   srate: sampling rate (Hz)
%   signalLength: length of signal (seconds)
%   lo: starting frequency (Hz)
%   hi: end frequency (Hz)
%   sweepMethod: sine sweep method - available are 'logarithmic' and
%   'linear'
% Output:
%   y: logarithmic sine sweep
%
% Typical use (and default values):
%   y = gensweep(44100, 2, 20, 20000, 'logarithmic');
%
% Written by:
%   Frederick S. Scott, August 2007
% Modified by:
%   Agnieszka Roginska, January 2008
%   Copyright Music Technology, New York University

if nargin < 5, sweepMethod = 'logarithmic'; end;
if nargin < 4, hi = 20000;end;
if nargin < 3, lo = 20; end;
if nargin < 2, signalLength = 2; end;
if nargin < 1, srate = 44100; end;

if (lo <= 0) || (hi <= 0), error('frequencies must be positive');end
if (lo >= hi), error('low frequency must be < high frequency'); end
if (signalLength <= 0), error('signalLength must be > 0'), end;
if (signalLength >= srate/4), error('signalLength is in seconds not samples'); end;
if (~(strcmp(sweepMethod, 'logarithmic') || strcmp(sweepMethod, 'linear'))), error('sweepMethod must be either "logarithmic" or "linear"'); end;

interval = 1/srate;
t = 0:interval:(signalLength-interval);                     %time index for sweep
if (strcmp(sweepMethod, 'logarithmic'))
    low = lo*2*pi;
    high = hi*2*pi;
    e1 = low*signalLength;                                      %these simplify the equation below
    e2 = log(high/low);
    e3 = t/signalLength;
    e4 = log(high/low);
    y(1:signalLength*srate) = sin((e1/e2)*(exp(e3*e4)-1));
else
    y = chirp(t,lo,signalLength,hi,'linear',270);
end;