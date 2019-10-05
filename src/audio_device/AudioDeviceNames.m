function deviceNames = AudioDeviceNames(deviceData) 
    deviceNames = [];
    for i = 1:length(deviceData)
        deviceNames{i} = deviceData(i).DeviceName;
    end
end