function device_names = AudioDevice_inputNames
% function returns string array containing names of audio units that have
% NrInputChannels > 0
    dev = PsychPortAudio('GetDevices');
    device_names = [];
    count = 1;
    for i = 1:length(dev);
        if dev(i).NrInputChannels > 0
            device_names{count} = dev(i).DeviceName;
            count = count + 1;
        end
    end
end