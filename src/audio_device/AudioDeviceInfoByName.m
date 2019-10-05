function device = AudioDeviceInfoByName(name)
% returns struct containing audio device info 
    devs = PsychPortAudio('GetDevices');
    device = [];
    for i = 1:length(devs)
        if strcmp(name, devs(i).DeviceName)
            device = devs(i);
        end
    end
    if isempty(device)
        error('Audio Device by that name not found.');
    end
end