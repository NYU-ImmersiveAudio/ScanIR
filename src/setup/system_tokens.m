function handles = system_tokens(handles)
%SYSTEM_TOKENS 
devices = PsychPortAudio('GetDevices');
if ismac
    handles.system = 'macOS';
    handles.built_IP = 'Built-in Microphone';
    handles.built_OP = 'Built-in Output';
end
if ispc
    handles.system = 'windows';
    devs = devices(contains({devices.HostAudioAPIName},'WASAPI'));
    opName = devs(contains({devs.DeviceName},'Speakers')).DeviceName;
    ipName = devs(contains({devs.DeviceName},'Microphone')).DeviceName;
    handles.built_IP = ipName;
    handles.built_OP = opName;
end
if IsLinux % linux tokens yet to be validated
    handles.system = 'linux';
    handles.built_IP = '';
    handles.built_OP = '';
end


end

