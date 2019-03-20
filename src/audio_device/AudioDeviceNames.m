function device_names = AudioDeviceNames
    dev = PsychPortAudio('GetDevices');
    device_names = [];
    for i = 1:length(dev);
        device_names{i} = dev(i).DeviceName;
    end
end