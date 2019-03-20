function handles = ard_setup(handles)
% Arduino connection
try 
    disp('Connecting to Arduino board...')
    temp_ard = arduino;
    port = temp_ard.Port;
    board = temp_ard.Board;
    clear('temp_ard');
    handles.motor.arduino = arduino(port,board,'Libraries','Adafruit/MotorShieldV2');
    handles.ard_connected = true;
    disp(['Found Arduino model ', board, ' on port: ', port]);
catch
    disp('No Arduino currently connected');
    handles.motor.arduino = [];
    handles.ard_connected = false;
end
% Stepper-shield setup
if handles.ard_connected
    handles.automeas_button.Enable = 'on';
    handles.nsteps_edit.Enable = 'on';
    handles.stepsize_edit.Enable = 'on';
    handles.clockradio.Enable = 'on';
    handles.antiradio.Enable = 'on';
    handles.sstext.Enable = 'on';
    handles.nstext.Enable = 'on';
    handles.rot_button.Enable = 'on';
end

end

