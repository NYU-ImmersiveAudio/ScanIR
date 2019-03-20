function device_names = AudioDevice_outputNames
% function returns string array containing names of audio units that have
% NrOutputChannels > 0
    dev = PsychPortAudio('GetDevices');
    device_names = [];
    count = 1;
    for i = 1:length(dev);
        if dev(i).NrOutputChannels > 0
            device_names{count} = dev(i).DeviceName;
            count = count + 1;
        end
    end
end