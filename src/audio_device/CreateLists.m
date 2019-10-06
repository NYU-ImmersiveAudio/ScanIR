function [handles] = CreateLists(handles)
%CREATELISTS 
% Separate I/O devices into separate lists
D = handles.availableDevices;
count_ip = 1;
count_op = 1;

for i = 1:length(D)
    if D(i).NrInputChannels > 0
        list_ip(count_ip) = D(i);
        count_ip = count_ip + 1;
    end
    if D(i).NrOutputChannels > 0
        list_op(count_op) = D(i);
        count_op = count_op + 1;
    end
end

handles.availableIP = list_ip;
handles.availableOP = list_op;

