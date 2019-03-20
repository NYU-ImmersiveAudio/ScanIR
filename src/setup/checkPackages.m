function handles = checkPackages(handles)
toolboxes = ver;
pkg = matlabshared.supportpkg.getInstalled;

% Check Psychtoolbox
handles.tlbx = {toolboxes(:).Name};
if ~any(strcmp(handles.tlbx,'Psychtoolbox'))
    error(['Psychtoolbox check -> not detected. To run ScanIR you need to install the latest version of Psychtoolbox (v3.0 or higher)',...
        '<a href="http://psychtoolbox.org/">Download link</a>.']);
else
    disp('Psychtoolbox -> detected!');
end

% Check ARDUINO
if ~isempty(pkg)
    handles.pkg = {pkg(:).Name};
else
    handles.pkg = 'no packages installed';
end
if ~any(contains(handles.pkg,'Arduino'))
    disp(['Arduino Support Package -> not detected. Rotating motor feature not available. ',...
        '<a href="https://www.mathworks.com/hardware-support/arduino-matlab.html">More info</a>.']);
    handles.ard_installed = false;
    handles.ard_connected = false;
    handles.arduinoButton.Enable = 'off';
    handles.automeas_button.Enable = 'off';
else
    disp('Arduino Support Package -> detected');
    handles.ard_installed = true;
    handles.ard_connected = false;
    handles.arduinoButton.Enable = 'on';
    handles = ard_setup(handles);
end

% Check Signal Processing Toolbox
if ~any(contains(handles.tlbx,'Signal Processing'))
    disp('Signal Processing Toolbox -> not detected. Some parameters may not be computed.'); 
    handles.enhanced_analysis = false;
else
    disp('Signal Processing Toolbox -> detected');
    handles.enhanced_analysis = true;
end

% Add & Check SOFA API
cd api
folders = dir;
sofa_idx = find(contains({folders(:).name},'sofa-api'));
if ~isempty(sofa_idx)
    if length(sofa_idx)>1
        disp('Multiple SOFA APIs detected, choosing latest one')
        sofa_idx = sofa_idx(end);
    end
    addpath(genpath([folders(sofa_idx).name]));
end
try
    SOFAstart;
    disp('SOFA API -> detected');
catch
    disp(['SOFA API -> not detected or wrongly installed. SOFA saving features not available. ',...
        '<a href="https://www.sofaconventions.org/mediawiki/index.php/Software_and_APIs">Download link</a>.']);
end
cd ..
end