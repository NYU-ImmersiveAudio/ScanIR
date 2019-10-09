function handles = system_devices(handles)
% SYSTEM_TOKENS 
devices = PsychPortAudio('GetDevices');
if ismac
    handles.system = 'macOS';
    devs = devices;
    try
        opName = devs(contains({devs.DeviceName},'Built-in Microphone')).DeviceName;
        handles.built_OP = opName;
    catch
        handles.built_OP = '';
    end
    try 
        ipName = devs(contains({devs.DeviceName},'Built-in Output')).DeviceName;
        handles.built_IP = ipName;
    catch
        handles.built_IP = '';
    end
end
if ispc
    handles.system = 'windows';
    devs = devices(contains({devices.HostAudioAPIName},'WASAPI'));
    try
        opName = devs(contains({devs.DeviceName},'Speakers (Realtek')).DeviceName;
        handles.built_OP = opName;
    catch
        handles.built_OP = '';
    end
    try 
        ipName = devs(contains({devs.DeviceName},'Microphone Array (Realtek')).DeviceName;
        handles.built_IP = ipName;
    catch
        handles.built_IP = '';
    end
end
if IsLinux % linux tokens yet to be validated
    devs = devices;
    handles.system = 'linux';
    handles.built_IP = '';
    handles.built_OP = '';
end

% DEVICE_LISTS
handles.allDevices = devices;
handles.availableDevices = devs;
handles = CreateLists(handles);
handles.deviceNames = AudioDeviceNames(devices);
handles.availableNames = AudioDeviceNames(devs);
handles.IpDevNames = AudioDeviceNames(handles.availableIP);
handles.OpDevNames = AudioDeviceNames(handles.availableOP);
end

