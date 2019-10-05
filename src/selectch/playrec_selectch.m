function signal = playrec_selectch (IpDeviceInfo, OpDeviceInfo, out_signal, ...
    srate, out_ch, in_ch, rec_len)
% This function plays the measurement signal and records the response
%
% audioInputDeviceInfo:
% - structure containing which audio device to be used to record
%
% audioOutputDeviceInfo:
% - structure containing which audio device to be used to broadcast the
%   signal
% 
% signal:
% - the recorded signal
% - an [M x N] matrix where each row specifies one sound
%   channel and each column contains one sample per channel

% out_signal:
% - the signal to be output
% - an [M x N] matrix where each row specifies one sound
%   channel and each column contains one sample per channel
% - samples need to be within -1 to +1

% srate:
% - the sample rate

% out_ch:
% - an array of output channels

% in_ch:
% - the number of input channels
% - each channel up to in_ch will be active for recording
%
% e.g. y = playrec_selectch(mysignal, 44100, 1, 1, 3); plays mysignal on
% channel 1, and records a 3-sec signal

% rec_len
% - how long to record, in seconds

[M N] = size(out_signal);


% check arguments; provide default values for those not given
% out_signal must be passed, so an error is thrown if it is not
if (nargin < 3) error('Must provide an output signal'); end
if (nargin < 4) srate = 44100; end
if (nargin < 5) out_ch = [1:M]; end
if (nargin < 6) in_ch = 1; end
if (nargin < 7) rec_len = N / srate;
elseif (nargin > 7) error('Too many inputs to function'); end


% the total number of output channels
num_out_ch = length(out_ch);
in_ch = length(in_ch);

% a zero matrix of size: num_out_ch x N
out_matrix = zeros(num_out_ch, N);

% the channels specified by the array out_ch will be replaced with
% audio data; the rest will be left as silence. this is a work-around
% because the 'selectchannels' option provided by PsychAudioPort is
% only supported for MS-Windows


% out_signal[i] will be played through out_ch[i]
% for i=1:length(out_ch)
%     out_matrix(out_ch(i),1:N) = out_signal(i,1:N);
% end

% ----- 10/01/2019 A.Genovese
% Temporary workaround: IT is assumed that only one channel playback is
% desired to be used. Hence only the latest O/P channel is filled with data
out_matrix(out_ch(end),1:N) = out_signal(1,1:N);
% -----

% if the number of output channels as specified implicitly by out_signal
% exceeds the explicit number of output channels specified by out_ch,
% throw an error
if (M ~= length(out_ch))
    disp(M);
    disp(out_ch);
    error('Number of channels in out_signal must equal length of out_ch');
end

% if the duration of out_signal is less than the specified record duration,
% zero-pad the end of out_signal to achieve the correct duration
if (N < (rec_len*srate))
    pad = zeros(num_out_ch,round(rec_len*srate) - N);
    out_matrix = [out_matrix, pad];
end

if (num_out_ch == 1)
    out_matrix = [ out_matrix; zeros( 1, length(out_matrix) ) ];
    num_out_ch = 2;
end


% perform simultaneous playback and recording

InitializePsychSound;
PsychPortAudio('GetDevices');
out_pahandle = PsychPortAudio('Open', OpDeviceInfo.DeviceIndex, 1, 0, srate, num_out_ch);
in_pahandle = PsychPortAudio('Open', IpDeviceInfo.DeviceIndex, 2, 0, srate, in_ch);
PsychPortAudio('FillBuffer', out_pahandle, out_matrix);
PsychPortAudio('GetAudioData', in_pahandle, rec_len);
PsychPortAudio('Start', in_pahandle);
PsychPortAudio('Start', out_pahandle);
WaitSecs(rec_len);
PsychPortAudio('Stop', in_pahandle, 1);
PsychPortAudio('Stop', out_pahandle, 1);
[signal] = PsychPortAudio('GetAudioData', in_pahandle);
PsychPortAudio('Close', in_pahandle);
PsychPortAudio('Close', out_pahandle);
