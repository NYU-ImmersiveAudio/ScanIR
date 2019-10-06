function varargout = ScanIR_v2(varargin)
%SCANIR_V2 MATLAB code file for ScanIR_v2.fig
%      SCANIR_V2, by itself, creates a new SCANIR_V2 or raises the existing
%      singleton*.
%
%      H = SCANIR_V2 returns the handle to a new SCANIR_V2 or the handle to
%      the existing singleton*.
%
%      SCANIR_V2('Property','Value',...) creates a new SCANIR_V2 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to ScanIR_v2_export_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SCANIR_V2('CALLBACK') and SCANIR_V2('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SCANIR_V2.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ScanIR_v2

%  Version 2 Written by Andrea Genovese and Julian Vanasse
%  NYU Music and Audio Research Lab
%  Copyright 2019
%
%  Version 1 Written by Agnieszka Roginska and Braxton Boren
%  NYU Music and Audio Research Lab
%  Copyright 2011


% Last Modified by GUIDE v2.5 05-Oct-2019 22:01:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ScanIR_v2_OpeningFcn, ...
    'gui_OutputFcn',  @ScanIR_v2_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before ScanIR_v2 is made visible.
function ScanIR_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ScanIR_v2 (see VARARGIN)

% Choose default command line output for ScanIR_v2
handles.output = hObject;

% open program source directories
addpath(genpath('src'))
addpath('api/');
addpath('WavFiles/');
disp(['ScanIR is a measurement tool developed by NYU Steinhardt`s Music',...
    ' and Audio Research Lab.']);

% add toolbar for zooming axes
set(hObject,'toolbar','figure');

handles.data = [];
handles.specs = [];
handles.app = [];

handles.specs.filtertype = 'fixed filters';
handles.specs.subjectName = [];
handles.specs.database = [];
handles.specs.comments = [];

handles.app.currID = 1;
handles.app.npositions = []; % number of total recording positions for HRIRs for each series of recordings
handles.app.sorted = 0; % 0 if unsorted, 1 if sorted
handles.app.azPositionData = [str2double(get(handles.az_start,'String')) str2double(get(handles.az_interval, 'String')) str2double(get(handles.az_end, 'String')) ];
handles.app.elPositionData = [str2double(get(handles.el_start,'String')) str2double(get(handles.el_interval, 'String')) str2double(get(handles.el_end, 'String')) ];
handles.app.seriesInfo = []; % stores the ID numbers of positions at the end of each series
handles.app.isBRIR = false; % distinguish HRIR from BRIR
handles.app.sig_level = 0.6;

handles.hrir_az = []; % row vector of azimuths for HRIR measurements
handles.hrir_el = []; % row vector of elevations for HRIR measurements
handles.sizeLoadedData = 0;
handles.numSeries = 1; % index of current series


% Step-motor pre-sets - change if needed
handles.motor.SPR = 200;
handles.motor.default_motorport = 2;
handles.motor.deltastep = 360/handles.motor.SPR;
handles.motor.def_pause = 1.0;
handles.motor.nsteps = 1;
handles.motor.stepsize = handles.motor.deltastep;
handles.motor.direction = -1;
handles.motor.inProgress = 0;
set(handles.stepsize_edit,'String',num2str(handles.motor.deltastep));

% Check that the appropriate toolboxes exist
handles = checkPackages(handles);

% Opening GUI
opening = welcome;
disp(opening);
if ( strcmp(opening, 'createNew') )
    ard = handles.ard_connected;
    save('src/setup/tempfile.mat','ard');
    setup = createNew;
    handles.app.inMode = setup.inMode;
    handles.specs.signalType = setup.signalType;
    handles.app.sigLength = setup.sigLength;
    handles.app.irLength = setup.irLength;
    handles.specs.sampleRate = setup.sampleRate;
    handles.app.numInputChls = 1:setup.numInputChls;
    handles.app.numOutputChls = setup.numOutputChls;
    handles.app.outMode = setup.outMode;
    handles.app.numPlays = setup.numPlays;
    % motor settings
    if handles.ard_connected
        handles.motor.SPR = setup.motor.spr;
        handles.motor.default_motorport = setup.motor.port;
        handles.motor.shield = addon(handles.motor.arduino, 'Adafruit\MotorShieldV2');
        handles.motor.stepper = stepper(handles.motor.shield,handles.motor.default_motorport,handles.motor.SPR,'StepType','Double');
        handles.motor.stepper.RPM = setup.motor.rpm;
    end
    % audio device selection
    handles.specs.IpDeviceInfo = setup.IpDevInfo;
    handles.specs.OpDeviceInfo = setup.OpDevInfo;
    handles.maxOuts = handles.specs.OpDeviceInfo.NrOutputChannels;
    handles.maxIns = handles.specs.IpDeviceInfo.NrInputChannels;
    
    handles.sessionName = setup.sessionName;
    set(handles.figure1, 'Name', ['ScanIR Session: ', handles.sessionName]);
    set(handles.sessionText,'String',handles.sessionName);
    set(handles.textAudioInputDevice,'String',setup.IpDevInfo.DeviceName);
    set(handles.textAudioOutputDevice,'String',setup.OpDevInfo.DeviceName);
    
    if (handles.app.sigLength == 1)
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' second'));
    else
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' seconds'));
    end
    set(handles.irLengthDisp, 'String', strcat(num2str(handles.app.irLength),' samples'));
    if (handles.app.inMode == 2)
        set(handles.hrir_panel, 'Visible', 'on');
    end
elseif ( strcmp(opening, 'loadSession') )
    handles = loadFile(hObject, handles);
    % find maximum number of output and input channels
    InitializePsychSound;
    dev = PsychPortAudio('GetDevices');
    [m n] = size(dev);
    handles.maxOuts = 0;
    handles.maxIns = 0;
    for k = 1:n
        testOuts = getfield(dev, {1,k}, 'NrOutputChannels');
        if (handles.maxOuts < testOuts)
            handles.maxOuts = testOuts;
        end
        testIns = getfield(dev, {1,k}, 'NrInputChannels');
        if (handles.maxIns < testIns)
            handles.maxIns = testIns;
        end
    end
    
end


if exist('handles.loaded')
    if ( strcmp(handles.loaded, 'fail') )
        error('User cancelled file load');
        return
    end
end

handles.app.outchl = 1:str2double(get(handles.outChannelEdit, 'String'));

% update 'setup' panel
set(handles.sigTypeDisp, 'String', handles.specs.signalType);
set(handles.srateDisp, 'String', strcat(num2str(handles.specs.sampleRate),' Hz'));
set(handles.numinchlsDisp, 'String', num2str(length(handles.app.numInputChls)));

% BRIR flag
if (handles.app.inMode == 2 && handles.app.irLength/handles.specs.sampleRate >= 1)
    handles.app.isBRIR = true;
end

% Setup GUI
if (handles.app.inMode == 1) % Mono IR
    set(handles.modeDisp, 'String', 'Mono IR        ');
    set(handles.text21, 'Visible', 'off');
    set(handles.chl_popup, 'Visible', 'off');
elseif (handles.app.inMode == 2) % HRIR or BRIR
    set(handles.modeDisp, 'String', 'HRIR           ');
    if handles.app.isBRIR
        set(handles.modeDisp, 'String', 'BRIR           ');
    end
    
    set(handles.az_edit, 'Enable', 'off');
    set(handles.el_edit, 'Enable', 'off');
    if (handles.app.outMode == 2)
        handles.app.npositions(1) = handles.app.numOutputChls;
        handles.app.seriesInfo(1) = handles.app.numOutputChls;
        set(handles.outChannelEdit, 'Enable', 'off');
        set(handles.outChannelEdit, 'String', strcat('1-',num2str(handles.app.npositions(handles.numSeries))));
        set(handles.az_end, 'Enable', 'off');
        set(handles.el_end, 'Enable', 'off');
    end
    handles = updateHRIR(hObject,handles);
    set(handles.hrir_panel, 'Title', strcat('HRIR Locations for 1-',num2str(handles.app.npositions(handles.numSeries))));
    if handles.app.isBRIR
        set(handles.hrir_panel, 'Title', strcat('BRIR Locations for 1-',num2str(handles.app.npositions(handles.numSeries))));
    end
elseif (handles.app.inMode == 3) % Multichannel IR
    set(handles.modeDisp, 'String', 'Multichannel IR');
end

% GUI Plotting pre-sets
if handles.app.inMode > 1
    set(handles.plottype_popup, 'String', 'Time-overlay|Frequency|Energy Decay Curve|Time-cascade|Frequency-cascade');
    set(handles.plottype_popup, 'Value', 4); % default to Time-cascade
else
    set(handles.plottype_popup, 'String', 'Time|Frequency|Energy Decay Curve');
end
for ch = 1:length(handles.app.numInputChls)
    channelLabels{ch} = strcat('|Chl: ',num2str(ch));
end
set(handles.chl_popup, 'String', ['All Channels',[channelLabels{:}]]);
handles.fftlen_popup.Enable = 'off';
set(handles.backButton, 'Enable', 'off');
if (size(handles.data,2) < 1)
    set(handles.forwardButton, 'Enable', 'off');
end
set(handles.smooth_popup,'String','No Smoothing|1/12 Octave|1/8 Octave|1/4 Octave|1/2 Octave|Full Octave');
set(handles.smooth_popup,'Value',1);
handles.smooth_popup.Enable = 'off';
handles.colors = get(handles.plotarea,'colororder');
% Arduino Initialization
if ~handles.ard_installed
    set(handles.arduino_text,'String','not installed');
else
    if ~handles.ard_connected
        set(handles.arduino_text,'String','not detected');
    else
        set(handles.arduino_text,'String','connected','FontWeight','bold','ForegroundColor',[0,153/256,0]);
    end
end

% GUI Dyanimc Resize Params
ref_ss(1) = (1100/72);
ref_ss(2) = (800/72);
ScreenUnits=get(0,'Units');
set(0,'Units','pixels');
p_ss=get(0,'ScreenSize');
set(0,'Units','inches');
i_ss=get(0,'ScreenSize');
res_ss = p_ss./i_ss;
set(0,'Units',ScreenUnits);
% Set GUI Dimensions
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
FigPos = get(hObject,'Position');
Width = max([round(ref_ss(1)*res_ss(3)),round(p_ss(3)*0.4)]);
Height = max([round(ref_ss(2)*res_ss(4)),round(p_ss(4)*0.5)]);
if (Width > p_ss(3)-50) Width = p_ss(3)-50; end
if (Height > p_ss(4)-100) Height = p_ss(4)-100; end
FigPos(3)= Width;
FigPos(4)= Height;
FigPos(1)= round((p_ss(3)-FigPos(3))/2);
FigPos(2)= round((p_ss(4)-FigPos(4))/2);
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% display MARL logo in axes_logo
axes(handles.plotLogo)
[img, map, alphachannel] = imread('MARL_logo.png');
image(img, 'AlphaData', alphachannel);
axis off
axis image

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ScanIR_v2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = goBackward(hObject, handles);


% --- Executes on selection change in fftlen_popup.
function fftlen_popup_Callback(hObject, eventdata, handles)
if (handles.app.currID<=size(handles.data,2))
    plotresponse(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function fftlen_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = measureIR(hObject, handles)

set(handles.measureButton, 'Enable', 'off');
if (handles.app.currID ~= 1)
    set(handles.backButton, 'Enable', 'off');
end
if (handles.app.currID <= size(handles.data,2))
    set(handles.forwardButton, 'Enable', 'off');
end
drawnow;

if ( handles.app.outMode == 1 )
    handles = measurePosition(hObject, handles);
elseif(handles.app.outMode == 2 && handles.app.currID > size(handles.data,2) )
    for k = 1:handles.app.npositions(handles.numSeries)
        handles.app.outchl = 1:k;
        handles = measurePosition(hObject, handles);
        drawnow;
        if (k < handles.app.npositions(handles.numSeries))
            handles = goForward(hObject, handles);
        end
    end
elseif ( handles.app.outMode == 2 && handles.app.currID <= size(handles.data,2) )
    handles = calcModID(hObject, handles);
    handles.app.outchl = 1:handles.modID;
    handles = measurePosition(hObject, handles);
end

set(handles.measureButton, 'Enable', 'on');
if (handles.app.currID ~= 1)
    set(handles.backButton, 'Enable', 'on');
end
if (handles.app.currID <= size(handles.data,2))
    set(handles.forwardButton, 'Enable', 'on');
end
% auto-save data after measurement%
if (get(handles.sort_checkbox, 'Value'))
    % sort data before saving
    len = size(handles.data,2); % overall number of measured positions
    pts = [];
    for i = 1:len
        pts = [pts; [handles.data(i).elevation handles.data(i).azimuth] ];
    end
    pts = sortrows(pts, [1 2]); % sort by elevation, then by azimuth when tied
    out = [];
    for j = 1:len % index over raw data
        for k = 1:len % index over sorted data file
            if ( (handles.data(j).elevation == pts(k,1)) && (handles.data(j).azimuth == pts(k,2)) )
                out(k).azimuth = handles.data(j).azimuth;
                out(k).elevation = handles.data(j).elevation;
                out(k).distance = handles.data(j).distance;
                out(k).IR = handles.data(j).IR;
                out(k).ITD = handles.data(j).ITD;
                out(k).comments = handles.data(j).comments;
            end
        end
    end
    tempData = out; % save sorted data
    handles.app.sorted = 1;
else
    tempData = handles.data; % save unsorted data
    handles.app.sorted = 0;
end

specs = handles.specs; % save entire specs struct
app = handles.app; % save entire ScanIR application-specific struct
save('ScanIR_AutoSave', 'tempData', 'specs', 'app');
guidata(hObject, handles); %updates the handles


% --- Executes on button press in measureButton.
function measureButton_Callback(hObject, eventdata, handles)
handles = measureIR(hObject,handles);
guidata(hObject, handles); %updates the handles



% --- Executes on button press in forwardButton.
function forwardButton_Callback(hObject, eventdata, handles)
handles = goForward(hObject, handles);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)

if (get(handles.sort_checkbox, 'Value'))
    % sort data before saving
    len = size(handles.data,2); % overall number of measured positions
    pts = [];
    for i = 1:len
        pts = [pts; [handles.data(i).elevation handles.data(i).azimuth] ];
    end
    pts = sortrows(pts, [1 2]); % sort by elevation, then by azimuth when tied
    out = [];
    for j = 1:len % index over raw data
        for k = 1:len % index over sorted data file
            if ( (handles.data(j).elevation == pts(k,1)) && (handles.data(j).azimuth == pts(k,2)) )
                out(k).azimuth = handles.data(j).azimuth;
                out(k).elevation = handles.data(j).elevation;
                out(k).distance = handles.data(j).distance;
                out(k).IR = handles.data(j).IR;
                out(k).rawIR = handles.data(k).rawIR;
                out(k).ITD = handles.data(j).ITD;
                out(k).comments = handles.data(j).comments;
            end
        end
    end
    data = out; % save sorted data
    handles.app.sorted = 1;
else
    data = handles.data; % save unsorted data
    handles.app.sorted = 0;
end

% Save file size if raw not desired
if ~(get(handles.raw_checkbox,'Value'))
    data.rawIR = [];
end

[filename,pathname] = uiputfile(strcat(handles.sessionName, '.mat'), 'Save...');

specs = handles.specs; % save entire specs struct
app = handles.app; % save entire ScanIR application-specific struct

% Save a first time and avoid losing data in case of SOFA API crashing
save(strcat(pathname, filename), 'data', 'specs', 'app');
% --- SOFA save
if get(handles.checkbox_SaveSOFA, 'Value')
    try
        SOFAstart;
        scanIR2sofa(handles.app, handles.data, handles.specs, ...
            strcat(pathname, filename(1:end-4), '.sofa'), ...
            get(handles.checkbox_isAdvancedSOFA, 'Value'));
    catch
        warning(['ATTENTION: SOFA saving feature failed!',  sprintf('\n'), ...
            'You need to download the SOFA API for MATLAB/Octave from:', ...
            '<a href="https://www.sofaconventions.org/mediawiki/index.php/Software_and_APIs">SOFA website</a>. ',  sprintf('\n'), ...
            'Please add the directory to the ScanIR_v2 parent folder to use the SOFA functions']);
    end
end

delete 'ScanIR_AutoSave.mat';


function az_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function az_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function el_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function el_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dist_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function dist_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotDomainListBox.
function plotDomainListBox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function plotDomainListBox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
handles = loadFile(hObject, handles);

% function for loading files
function handles = loadFile(hObject, handles)
[filename,pathname] = uigetfile('*.mat;*.sofa', 'Load Session');

if contains(filename, '.mat');
    load(strcat(pathname,filename));
    handles.loaded = 'succeed';
elseif contains(filename, '.sofa');
    [app, data, specs] = sofa2scanIR(strcat(pathname, filename));
    handles.loaded = 'succeed';
else
    handles.loaded = 'fail';
    return
end

handles.data = data;
num = length(data);
for j = 1:num
    if ( handles.data(j).ITD > 0 )
        prepend = zeros( handles.data(j).ITD, 1 );
        append = prepend;
        ch1 = [ prepend; handles.data(j).IR(:,1) ];
        ch2 = [ handles.data(j).IR(:,2); append ];
        handles.data(j).IR = [ch1 ch2];
    elseif ( handles.data(j).ITD < 0 )
        prepend = zeros( handles.data(j).ITD, 1 );
        append = prepend;
        ch1 = [ handles.data(j).IR(:,1); append ];
        ch2 = [ prepend; handles.data(j).IR(:,2) ];
        handles.data(j).IR = [ch1 ch2];
    end
end

handles.specs = specs;
handles.numSeries = 1;
handles.sizeLoadedData = size(data,2);
% check size of loaded data
if (handles.sizeLoadedData >= 1)
    set(handles.forwardButton, 'Enable', 'on');
end
set(handles.backButton, 'Enable', 'off');
handles.internal = exist('app','var');
if (handles.internal) % if we're loading a file made in ScanIR, the 'app' struct should exist in the load file
    handles.app = app;
    % BRIR flag
    if (handles.app.inMode == 2 && handles.app.irLength/handles.specs.sampleRate >= 1)
        handles.app.isBRIR = true;
    end
    if (app.inMode == 1)
        modeString = 'Mono IR        ';
    elseif (app.inMode == 2)
        modeString = 'HRIR           ';
        if handles.app.isBRIR
            modeString = 'BRIR           ';
        end
        if (handles.app.sorted == 1)
            set(handles.hrir_panel, 'Visible', 'off');
            disp('1');
        else
            set(handles.hrir_panel, 'Visible', 'on');
            set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
            if handles.app.isBRIR
                set(handles.hrir_panel,'Title',['BRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
            end
            set(handles.az_start,'String', num2str(handles.app.azPositionData(handles.numSeries,1)));
            set(handles.az_interval,'String', num2str(handles.app.azPositionData(handles.numSeries,2)));
            set(handles.az_end,'String', num2str(handles.app.azPositionData(handles.numSeries,3)));
            set(handles.el_start,'String', num2str(handles.app.elPositionData(handles.numSeries,1)));
            set(handles.el_interval,'String', num2str(handles.app.elPositionData(handles.numSeries,2)));
            set(handles.el_end,'String', num2str(handles.app.elPositionData(handles.numSeries,3)));
        end
    elseif (app.inMode == 3)
        modeString = 'Multichannel IR';
    end
    if (handles.app.sigLength == 1)
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' second'));
    else
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' seconds'));
    end
    set(handles.irLengthDisp, 'String', strcat(num2str(handles.app.irLength), ' samples'));
    set(handles.outChannelEdit, 'String',handles.app.outchl);
else % if we're loading HRIRs from a different database with no ScanIR-specific 'app' struct
    set(handles.hrir_panel, 'Visible', 'off');
    modeString = 'HRIR           ';
    if handles.app.isBRIR
        modeString = 'BRIR           ';
    end
    handles.app.numInputChls = 1:2;
    disp('Loading HRIR database - you must have 2 active input channels to record extra HRIR positions.');
    if handles.app.isBRIR
        modeString = 'BRIR           ';
    end
    handles.app.inMode = 2;
    handles.app.outMode = 1;
    handles.app.irLength = size(handles.data(1).IR,1);
    if ~exist('handles.app.sigLength')
        handles.app.sigLength = 1;
        disp('No value for test signal length detected - for all measurements, a 1-second signal will be used.');
    end
    set(handles.sigLengthDisp, 'String', 'unknown');
    handles.app.numPlays = 1;
    
end
handles.app.currID = 1;
set(handles.modeDisp, 'String', modeString);
set(handles.sigTypeDisp, 'String', handles.specs.signalType);
set(handles.irLengthDisp, 'String', strcat(num2str(handles.app.irLength), ' samples'));

guidata(hObject, handles); %updates the handles
updatefields(hObject,handles);


% --- Executes on selection change in plottype_popup.
function plottype_popup_Callback(hObject, eventdata, handles)
if (handles.app.currID<=size(handles.data,2))
    plottype = get(handles.plottype_popup, 'Value');
    if (plottype == 3 || plottype == 4)
        set(handles.chl_popup,'Value',1);
    end
    handles = displayFields(handles);
    plotresponse(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function plottype_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clearButton.
function clearButton_Callback(hObject, eventdata, handles)

cla(handles.plotarea,'reset')
handles = resetFields(handles);
guidata(hObject, handles); %updates the handles

% --- Plotting functions -----------------
function plotresponse(hObject,handles)

cla(handles.plotarea,'reset')
axes(handles.plotarea)

if get(handles.rawplot_checkbox,'Value')
    plot_data = handles.data(handles.app.currID).rawIR;
else
    plot_data = handles.data(handles.app.currID).IR;
end

plottype = get(handles.plottype_popup, 'Value');
plotchls = get(handles.chl_popup,'Value')-1;
if (plotchls == 0 || plottype == 4|| plottype == 5)
    plotchls = 1:length(handles.app.numInputChls);
end
offset = 50;

smth_amnt = [12,8,4,2,1];

fftlens = [512 1024 2048 4096 8192 16384 32768];
fftlen = fftlens(get(handles.fftlen_popup, 'Value'));
lgnd = 0;

%plot
if (plottype == 1) %time domain overlay
    handles.fftlen_popup.Enable = 'off';
    handles.chl_popup.Enable = 'on';
    set(handles.smooth_popup,'Value',1);
    handles.smooth_popup.Enable = 'off';
    hold off
    for i = plotchls
        if i<=size(handles.colors,1)
            col = handles.colors(i,:);
        else
            col = rand(1,3);
        end
        plot(handles.plotarea, plot_data(:, i),...
            'Color',col);
        hold on
    end
    xlabel('Time (samples)');
    ylabel('Amplitude');
    lgnd = 1;
    
elseif (plottype == 2) %frequency - overlay
    %    fftlen =  2^nextpow2(length(handles.data(handles.app.currID).IR));
    %    RESP = 20*log10(abs(fft(handles.data(handles.app.currID).IR(:,:),fftlen)));
    handles.fftlen_popup.Enable = 'on';
    handles.chl_popup.Enable = 'on';
    handles.smooth_popup.Enable = 'on';
    hold off
    smooth_option = get(handles.smooth_popup,'Value');
    if smooth_option > 1
        if fftlen >= 8192
            set(handles.warn_text,'String','Wait: Computing smothed FFT');
            handles.warn_text.Visible = 'on';
            drawnow;
        end
    end
    for i = plotchls
        if i<=size(handles.colors,1)
            col = handles.colors(i,:);
        else
            col = rand(1,3);
        end
        r = plot_data(:,i);
        [m, ind] = max(abs(r(:)));
        strt = max(1, ind-offset);
        r = r(strt:min(strt+fftlen-1, length(r)));
        RESP = 20*log10(abs(fft(r,fftlen)));
        % Apply smoothing if selected
        if smooth_option > 1
            RESP = LogWinOctaveSmooth(RESP,smth_amnt(smooth_option-1))';
        end
        semilogx([0:1/(length(RESP)/2):1]*((handles.specs.sampleRate/1000)/2), ...
            RESP(1:length(RESP)/2+1), 'Parent', handles.plotarea, ...
            'Color',col);
        ylim([-60 10]);
        hold on
    end
    xlabel('Frequency (kHz)');
    ylabel('dB');
    grid on
    lgnd = 1;
    set(handles.warn_text,'String','');
    handles.warn_text.Visible = 'off';
    drawnow;
    
elseif (plottype == 3)
    handles.chl_popup.Enable = 'on';
    handles.fftlen_popup.Enable = 'off';
    set(handles.smooth_popup,'Value',1);
    handles.smooth_popup.Enable = 'off';
    hold off
    interval = 1/handles.specs.sampleRate;
    t = [0:interval:(length(handles.data(handles.app.currID).IR(:,1))/handles.specs.sampleRate)-interval];
    for i = plotchls
        if i<=size(handles.colors,1)
            col = handles.colors(i,:);
        else
            col = rand(1,3);
        end
        plot(t,handles.data(handles.app.currID).EDC(:,i),...
            'Parent',handles.plotarea,'LineWidth',1.5,'Color',col);
        hold on
    end
    xlabel('Time (seconds)');
    ylabel('Energy Decay (dB)');
    lgnd = 1;
    drawnow
    
elseif (plottype == 4) %time domain cascade
    handles.chl_popup.Enable = 'on';
    handles.fftlen_popup.Enable = 'off';
    set(handles.smooth_popup,'Value',1);
    handles.smooth_popup.Enable = 'off';
    hold off
    maxVal = 0;
    for k = plotchls
        maxVal = max(maxVal, max(abs(plot_data(:,k))));
    end
    yScale = .5/maxVal;
    for i = plotchls
        plot(handles.plotarea, yScale * plot_data(:,i)+i);
        hold on;
    end
    set(handles.plotarea,'ytick', [1:length(handles.app.numInputChls)]);
    xlabel('Time (samples)');
    ylabel('Channel');
    yL = get(handles.plotarea, 'ylim');
    lgnd = 1;
    
elseif (plottype == 5) %frequency - cascade
    handles.fftlen_popup.Enable = 'on';
    handles.chl_popup.Enable = 'on';
    set(handles.smooth_popup,'Value',1);
    handles.smooth_popup.Enable = 'off';
    if (length(handles.app.numInputChls) == 1)
        set(handles.plottype_popup, 'Value', 2);
        plotresponse(hObject,handles);
    else
        resp = [];
        for i = plotchls
            r = plot_data(:,i);
            [m, ind] = max(abs(r(:)));
            strt = max(1, ind-offset);
            r = r(strt:min(strt+fftlen-1, length(r)));
            resp = [resp, r];
        end
        RESP = 20*log10(abs(fft(resp,fftlen)));
        mesh([1:size(RESP(1:length(RESP)/4+1,:),2)], ...
            [0:1/(length(RESP)/2):.5]*(handles.specs.sampleRate/1000/2), ...
            RESP(1:length(RESP)/4+1,:), ...
            'Parent', handles.plotarea);%, [-60, 0]);
        caxis([-60 0]);
        colorbar;
        view([120 20]);
        xlabel('Channel');
        set(gca,'Xdir','reverse');
        ylabel('Frequency (kHz)');
        zlabel('dB');
        set(handles.plotarea,'xtick', [1:length(handles.app.numInputChls)]);
    end
end


%legend
if (lgnd)
    str = [];
    for i = plotchls
        str = strvcat(str, sprintf('Chl %i', i));
    end
    legend(str);
end
guidata(hObject,handles);

%----------------------------------

function updatefields(hObject,handles)
set(handles.currID_txt, 'String', handles.app.currID);
if (handles.app.currID>size(handles.data,2))
    cla(handles.plotarea,'reset');
    handles = resetFields(handles);
    set(handles.comments_edit, 'String', ' ');
    return
end
plotresponse(hObject,handles);
if (handles.app.currID <= size(handles.data,2))
    set(handles.az_edit, 'String', num2str(handles.data(handles.app.currID).azimuth));
    set(handles.el_edit, 'String', num2str(handles.data(handles.app.currID).elevation));
    set(handles.dist_edit, 'String', num2str(handles.data(handles.app.currID).distance));
    set(handles.comments_edit, 'String', handles.data(handles.app.currID).comments);
    handles = displayFields(handles);
end
guidata(hObject,handles);



function comments_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function comments_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = updateHRIR(hObject, handles) % updates array of az and el values
% update az/el start/int/end
azStart = str2double(get(handles.az_start, 'String'));
azInt = str2double(get(handles.az_interval, 'String') );

elStart = str2double(get(handles.el_start, 'String') );
elInt = str2double(get(handles.el_interval, 'String') );
if (handles.app.outMode == 1) % mono output mode
    azEnd = str2double(get(handles.az_end, 'String') );
    elEnd = str2double(get(handles.el_end, 'String') );
elseif (handles.app.outMode == 2) % multichannel output mode
    azEnd = azStart + (handles.app.npositions(handles.numSeries) - 1) * azInt;
    elEnd = elStart + (handles.app.npositions(handles.numSeries) - 1) * elInt;
    set(handles.az_end,'String', num2str(azEnd));
    set(handles.el_end,'String', num2str(elEnd));
end
if (azInt == 0)  % make a full vector of the same azimuth if interval is zero
    handles.hrir_az = [azStart];
    for k = 1:(handles.app.npositions(handles.numSeries) - 1)
        handles.hrir_az = [handles.hrir_az azStart];
    end
else  % set up vector of azimuths for non-zero intervals
    if (azEnd > 360)
        azEnd = 360;      % max of 360 (later changed to 0 for simplicity)
    elseif (azEnd < -360)
        azEnd = -360;     % min of -360 (later changed to 0)
    end
    if (azStart > 360)     % same bounds for azStart
        azStart = 360;
    elseif (azStart < -360)
        azStart = -360;
    end
    
    handles.hrir_az = (azStart:azInt:azEnd);
    if (azEnd == 360 || azEnd == -360)
        handles.hrir_az(end) = 0;
        set(handles.az_end, 'String', '0');
    end
    if (azStart == 360 || azStart == -360)
        handles.hrir_az(1) = 0;
        set(handles.az_start, 'String', '0');
    end
end
if (elInt == 0)  % make a full vector of the same azimuth if interval is zero
    handles.hrir_el = [elStart];
    for k = 1:(handles.app.npositions(handles.numSeries) - 1)
        handles.hrir_el = [handles.hrir_el elStart];
    end
else
    if (elEnd > 90)
        elEnd = 90;       % max of 90
        set(handles.el_end, 'String', '90');
    elseif (elEnd < -90)
        elEnd = -90;     % min of -90
        set(handles.el_end, 'String', '-90');
    end
    if (elStart > 90)    % same bounds for elStart
        elStart = 90;
        set(handles.el_start, 'String', '90');
    elseif (elStart < -90)
        elStart = -90;
        set(handles.el_start, 'String', '-90');
    end
    handles.hrir_el = (elStart:elInt:elEnd);
end

% store this series's position data in global arrays
handles.app.azPositionData(handles.numSeries,1) = azStart;
handles.app.azPositionData(handles.numSeries,2) = azInt;
handles.app.azPositionData(handles.numSeries,3) = azEnd;
handles.app.elPositionData(handles.numSeries,1) = elStart;
handles.app.elPositionData(handles.numSeries,2) = elInt;
handles.app.elPositionData(handles.numSeries,3) = elEnd;

% update npositions and seriesInfo
if (handles.app.outMode == 1) % mono output mode
    handles.app.npositions(handles.numSeries) = length(handles.hrir_az) * length(handles.hrir_el);
    
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
    
    set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
    if handles.app.isBRIR
        set(handles.hrir_panel,'Title',['BRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
    end
    handles = calcModID(hObject, handles);
    
    elIndex = ceil(handles.modID/length(handles.hrir_az));
    
    if (mod(handles.modID,length(handles.hrir_az)) == 0)
        azIndex = length(handles.hrir_az);
    else
        azIndex = mod(handles.modID,length(handles.hrir_az));
    end
elseif (handles.app.outMode == 2) % multichannel output mode
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
    handles = calcModID(hObject, handles);
    
    azIndex = handles.modID;
    elIndex = handles.modID;
end
currentAz = handles.hrir_az(azIndex);
currentEl = handles.hrir_el(elIndex);
set(handles.az_edit, 'String', num2str(currentAz));
set(handles.el_edit, 'String', num2str(currentEl));

guidata(hObject,handles);


function handles = az_start_fun(hObject,handles)
if (handles.app.outMode == 1)
    testVal = str2num(get(handles.az_interval, 'String'));
    startVal = str2num(get(handles.az_start, 'String'));
    stopVal = str2num(get(handles.az_end, 'String'));
    testSign = sign(stopVal - startVal);
    
    if (sign(testVal) ~= testSign && testSign ~= 0)
        testVal = testVal * -1;
        set(handles.az_interval, 'String', num2str(testVal) );
    end
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.az_start, 'String', num2str(handles.app.azPositionData(handles.numSeries,1)));
        return
    end
end
handles = updateHRIR(hObject,handles);

function az_start_Callback(hObject, eventdata, handles)
handles = az_start_fun(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function az_start_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = az_interval_fun(hObject,handles)
if (handles.app.outMode == 1)
    testVal = str2num(get(handles.az_interval, 'String'));
    startVal = str2num(get(handles.az_start, 'String'));
    stopVal = str2num(get(handles.az_end, 'String'));
    testSign = sign(stopVal - startVal);
    
    if (testVal == 0)
        if (testSign == 0)
            testVal = 1;
        else
            testVal = testSign;
        end
        set(handles.az_interval, 'String', num2str(testVal));
    elseif (sign(testVal) ~= testSign && testSign ~= 0)
        testVal = testVal * -1;
        set(handles.az_interval, 'String', num2str(testVal) );
    end
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.az_interval, 'String', num2str(handles.app.azPositionData(handles.numSeries,2)));
        return
    end
end
handles = updateHRIR(hObject,handles);

function az_interval_Callback(hObject, eventdata, handles)
handles = az_interval_fun(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function az_interval_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = az_end_fun(hObject,handles)
testVal = str2num(get(handles.az_interval, 'String'));
startVal = str2num(get(handles.az_start, 'String'));
stopVal = str2num(get(handles.az_end, 'String'));
testSign = sign(stopVal - startVal);

if (sign(testVal) ~= testSign && testSign ~= 0)
    testVal = testVal * -1;
    set(handles.az_interval, 'String', num2str(testVal) );
end

if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.az_end, 'String', num2str(handles.app.azPositionData(handles.numSeries,3)));
        return
    end
end
handles = updateHRIR(hObject,handles);

function az_end_Callback(hObject, eventdata, handles)
handles = az_end_fun(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function az_end_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function el_start_Callback(hObject, eventdata, handles)
if (handles.app.outMode == 1)
    testVal = str2num(get(handles.el_interval, 'String'));
    startVal = str2num(get(handles.el_start, 'String'));
    stopVal = str2num(get(handles.el_end, 'String'));
    testSign = sign(stopVal - startVal);
    
    if (sign(testVal) ~= testSign && testSign ~= 0)
        testVal = testVal * -1;
        set(handles.el_interval, 'String', num2str(testVal) );
    end
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.el_start, 'String', num2str(handles.app.elPositionData(handles.numSeries,1)));
        return
    end
end
handles = updateHRIR(hObject,handles);

% --- Executes during object creation, after setting all properties.
function el_start_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function el_interval_Callback(hObject, eventdata, handles)
if (handles.app.outMode == 1)
    testVal = str2num(get(handles.el_interval, 'String'));
    startVal = str2num(get(handles.el_start, 'String'));
    stopVal = str2num(get(handles.el_end, 'String'));
    testSign = sign(stopVal - startVal);
    
    if (testVal == 0)
        if (testSign == 0)
            testVal = 1;
        else
            testVal = testSign;
        end
        set(handles.el_interval, 'String', num2str(testVal));
    elseif (sign(testVal) ~= testSign && testSign ~= 0)
        testVal = testVal * -1;
        set(handles.el_interval, 'String', num2str(testVal) );
    end
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.el_interval, 'String', num2str(handles.app.elPositionData(handles.numSeries,2)));
        return
    end
end
handles = updateHRIR(hObject,handles);


% --- Executes during object creation, after setting all properties.
function el_interval_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function el_end_Callback(hObject, eventdata, handles)
testVal = str2num(get(handles.el_interval, 'String'));
startVal = str2num(get(handles.el_start, 'String'));
stopVal = str2num(get(handles.el_end, 'String'));
testSign = sign(stopVal - startVal);

if (sign(testVal) ~= testSign && testSign ~= 0)
    testVal = testVal * -1;
    set(handles.el_interval, 'String', num2str(testVal) );
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.el_end, 'String', num2str(handles.app.elPositionData(handles.numSeries,3)));
        return
    end
end
handles = updateHRIR(hObject,handles);


% --- Executes during object creation, after setting all properties.
function el_end_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function outChannelEdit_Callback(hObject, eventdata, handles)
currentValue = str2double(get(handles.outChannelEdit, 'String'));
if (currentValue < 1 || isnan(currentValue))
    disp('Invalid Entry; outchl will default to 1');
    handles.app.outchl = 1;
    set(handles.outChannelEdit, 'String', num2str(1));
elseif (currentValue > handles.maxOuts)
    handles.app.outchl = 1:handles.maxOuts;
    set(handles.outChannelEdit, 'String', num2str(handles.maxOuts));
elseif (currentValue ~= round(currentValue))
    handles.app.outchl = 1:floor(currentValue);
    set(handles.outChannelEdit, 'String', num2str(handles.app.outchl));
else
    handles.app.outchl = 1:currentValue;
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function outChannelEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Function to measure a single position
function handles = measurePosition(hObject, handles)
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite measurement?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        return;
    end
end

if (get(handles.savewav_checkbox, 'Value'))
    savewav.az = str2num(get(handles.az_edit, 'String'));
    savewav.el = str2num(get(handles.el_edit, 'String'));
    savewav.dist = str2num(get(handles.dist_edit, 'String'));
    savewav.ID = handles.app.currID;
    savewav.session = handles.sessionName;
    savewav.dir = ['WavFiles/', handles.sessionName '/'];
    if ~isfolder(savewav.dir)
        mkdir(savewav.dir);
    end
else savewav = 0;
end

%measure
disp('outchl: ');
disp(handles.app.outchl);

%if (handles.app.irLength > handles.specs.sampleRate)
recLen = handles.app.irLength+handles.specs.sampleRate;
showTime=(recLen/handles.specs.sampleRate);% record an additional second more than we need
%else
%    recLen = handles.specs.sampleRate*2;
%end

fprintf('RECORDING IN PROGRESS...\n\n')
fprintf('Recording Length: %d seconds',showTime);

% Send signal
if ( strcmpi (handles.specs.signalType, 'Sine Sweep') || strcmpi (handles.specs.signalType, 'Sine-Sweep'))
    % Sinesweep
    y = sweepZap_selectch(handles.specs.IpDeviceInfo, ...
        handles.specs.OpDeviceInfo, ...
        handles.app.outchl, ...
        handles.app.numInputChls, ...
        handles.specs.sampleRate, ...
        handles.app.sigLength, ...
        recLen,handles.app.numPlays,...
        20, ...
        handles.specs.sampleRate/2, ...
        handles.app.sig_level,  ...
        savewav);
elseif ( strcmpi (handles.specs.signalType, 'MLS') )
    % Minimum length sequence
    mlsLen = nextpow2(handles.app.sigLength * handles.specs.sampleRate + 1);
    y = MlsZap_selectch(handles.specs.IpDeviceInfo, ...
        handles.specs.OpDeviceInfo, ...
        handles.app.outchl,...
        handles.app.numInputChls,...
        handles.specs.sampleRate,...
        mlsLen,recLen,...
        handles.app.numPlays,...
        handles.app.sig_level,savewav);
elseif ( strcmpi (handles.specs.signalType, 'Golay Codes') || strcmpi (handles.specs.signalType, 'Golay-Codes'))
    % Golay code
    golayLen = nextpow2(handles.app.sigLength * handles.specs.sampleRate + 1);
    y = golayZap_selectch(handles.specs.IpDeviceInfo,...
        handles.specs.OpDeviceInfo, ...
        handles.app.outchl, ...
        handles.app.numInputChls,...
        handles.specs.sampleRate,...
        golayLen,recLen,...
        handles.app.numPlays,...
        1,handles.app.sig_level,savewav);
end

handles.data(handles.app.currID).rawIR = y;

% Set beginning to direct sound (will update in future version)
offset = 50;
[~, ind]= max(abs(y));
firstIRind = min(ind);

fprintf('Recording completed! \n\n')

if ( firstIRind < handles.specs.sampleRate + 1 )
    handles.data(handles.app.currID).IR = y(firstIRind-offset:firstIRind-offset+handles.app.irLength-1, :);
    handles.lowSNR = 0;
    set(handles.warn_text,'String','');
else
    set(handles.warn_text,'String','ATTENTION: LOW SNR - retake the measurement to compute analysis parameters');
    warning('LOW SNR - THE EXCITATION SIGNAL MAY NOT BE STRONG ENOUGH');
    beep;
    handles.data(handles.app.currID).IR = y(handles.specs.sampleRate + 1:end);
    handles.lowSNR = 1;
end
handles.data(handles.app.currID).azimuth = str2double(get(handles.az_edit, 'String'));
handles.data(handles.app.currID).elevation = str2double(get(handles.el_edit, 'String'));
handles.data(handles.app.currID).distance = str2double(get(handles.dist_edit, 'String'));
handles.data(handles.app.currID).ITD = 0; % ITD parameter for marl standard, but it's zero because ScanIR's HRIRs include delay
handles.data(handles.app.currID).comments = get(handles.comments_edit, 'String');

if (handles.app.currID == size(handles.data,2))
    set(handles.forwardButton, 'Enable', 'on');
end

set(handles.warn_text,'Visible','on');
set(handles.warn_text,'String','Computing analysis parameters');
drawnow;
if ~handles.lowSNR
    handles = runAnalysis(handles);
    disp('Running Analysis ...');
    set(handles.warn_text,'String','');
else
    warning('THE SNR IS TOO LOW TO COMPUTE THE ANALYSIS');
    set(handles.warn_text,'String','ATTENTION: LOW SNR - retake the measurement to compute analysis parameters');
    handles = resetFields(handles);
end
drawnow;
plotresponse(hObject,handles);
set(handles.warn_text,'Visible','off');
guidata(hObject, handles);

% when we go forward
function handles = goForward(hObject, handles)
if (handles.app.currID<=size(handles.data,2))
    handles.app.currID = handles.app.currID+1;
end
if (handles.app.currID == 2)
    set(handles.backButton, 'Enable', 'on');
end
% reactivate hrir position panel if you've moved past sorted data
if ( (handles.app.inMode == 2) && (handles.app.sorted == 1) && ( handles.app.currID - 1 == handles.sizeLoadedData ) )
    handles = updateHRIR(hObject,handles);
    set(handles.hrir_panel, 'Visible', 'on');
end
if (handles.app.inMode == 2) % in HRIR mode
    if ( handles.app.currID - 1 == handles.app.seriesInfo(handles.numSeries) ) % moving forward to another series (may or may not be new)
        handles.numSeries = handles.numSeries + 1;
        if ( (handles.app.currID > size(handles.data,2) ) &&(handles.numSeries ~= length(handles.app.npositions)) ) % going forward to a new series
            handles = newSeries(hObject, handles);
        end
        set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
        if handles.app.isBRIR
            set(handles.hrir_panel,'Title',['BRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
        end
        set(handles.az_start,'String', num2str(handles.app.azPositionData(handles.numSeries,1)));
        set(handles.az_interval,'String', num2str(handles.app.azPositionData(handles.numSeries,2)));
        set(handles.az_end,'String', num2str(handles.app.azPositionData(handles.numSeries,3)));
        set(handles.el_start,'String', num2str(handles.app.elPositionData(handles.numSeries,1)));
        set(handles.el_interval,'String', num2str(handles.app.elPositionData(handles.numSeries,2)));
        set(handles.el_end,'String', num2str(handles.app.elPositionData(handles.numSeries,3)));
    end    
    if (handles.app.currID > size(handles.data,2)) % when we're going forward to a new recording index
        set(handles.forwardButton, 'Enable', 'off');
        handles = calcModID(hObject, handles);        
        if (handles.app.outMode == 1) % single channel output mode
            elIndex = ceil(handles.modID/length(handles.hrir_az));            
            if (mod(handles.modID,length(handles.hrir_az)) == 0)
                azIndex = length(handles.hrir_az);
            else
                azIndex = mod(handles.modID,length(handles.hrir_az));
            end
        elseif (handles.app.outMode == 2 ) % multichannel output mode
            azIndex = handles.modID;
            elIndex = handles.modID;
        end
        currentAz = handles.hrir_az(azIndex);
        currentEl = handles.hrir_el(elIndex);
        set(handles.az_edit, 'String', num2str(currentAz));
        set(handles.el_edit, 'String', num2str(currentEl));
    end
else % in Mono or Multi-input mode    
    if (handles.app.currID > size(handles.data,2)) % when we're going forward to a new position
        set(handles.forwardButton, 'Enable', 'off');
    end
end
updatefields(hObject,handles);
guidata(hObject, handles);



% when we go backward
function handles = goBackward(hObject, handles)
%disp('GO BACKWARD');
if (handles.app.currID>1)
    handles.app.currID = handles.app.currID-1;
end

if (handles.app.currID == 1)
    set(handles.backButton, 'Enable', 'off');
end

if (handles.app.currID <= size(handles.data,2))
    set(handles.forwardButton, 'Enable', 'on')
end

% deactivate hrir position panel if you've moved into sorted data
if ( (handles.app.inMode == 2 ) && (handles.app.sorted == 1) && ( handles.app.currID == handles.sizeLoadedData ) )
    set(handles.hrir_panel, 'Visible', 'off');
end

if ( (handles.numSeries ~= 1) && (handles.app.inMode == 2) && (handles.app.currID == handles.app.seriesInfo(handles.numSeries-1)) )
    handles.numSeries = handles.numSeries - 1;
    set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID-(handles.app.npositions(handles.numSeries)-1)) '-' num2str(handles.app.currID)]);
    if handles.isBRIR
        set(handles.hrir_panel,'Title',['BRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
    end
    set(handles.az_start,'String', num2str(handles.app.azPositionData(handles.numSeries,1)));
    set(handles.az_interval,'String', num2str(handles.app.azPositionData(handles.numSeries,2)));
    set(handles.az_end,'String', num2str(handles.app.azPositionData(handles.numSeries,3)));
    set(handles.el_start,'String', num2str(handles.app.elPositionData(handles.numSeries,1)));
    set(handles.el_interval,'String', num2str(handles.app.elPositionData(handles.numSeries,2)));
    set(handles.el_end,'String', num2str(handles.app.elPositionData(handles.numSeries,3)));
end

guidata(hObject, handles);
updatefields(hObject,handles);


function handles = newSeries(hObject,handles)
% going forward to a new series
% update npositions and seriesInfo
if (handles.app.outMode == 1) % mono output mode
    handles.app.npositions(handles.numSeries) = length(handles.hrir_az) * length(handles.hrir_el);
    disp('npos array:'); disp(handles.app.npositions);
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
    
    set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
    if handles.app.isBRIR
        set(handles.hrir_panel,'Title',['BRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
    end
elseif (handles.app.outMode == 2) % multichannel output mode
    handles.app.npositions(handles.numSeries) = handles.app.npositions(handles.numSeries-1);
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
end

handles.app.azPositionData(handles.numSeries,1) = handles.app.azPositionData(handles.numSeries-1,1);
handles.app.azPositionData(handles.numSeries,2) = handles.app.azPositionData(handles.numSeries-1,2);
handles.app.azPositionData(handles.numSeries,3) = handles.app.azPositionData(handles.numSeries-1,3);
handles.app.elPositionData(handles.numSeries,1) = handles.app.elPositionData(handles.numSeries-1,1);
handles.app.elPositionData(handles.numSeries,2) = handles.app.elPositionData(handles.numSeries-1,2);
handles.app.elPositionData(handles.numSeries,3) = handles.app.elPositionData(handles.numSeries-1,3);

%disp('Az position data:');
%disp(handles.app.azPositionData);

currentAz = handles.hrir_az(1);
currentEl = handles.hrir_el(1);
set(handles.az_edit, 'String', num2str(currentAz));
set(handles.el_edit, 'String', num2str(currentEl));
guidata(hObject,handles);


function handles = calcModID(hObject, handles)
if (handles.numSeries == 1)
    handles.modID = mod( handles.app.currID, handles.app.npositions(handles.numSeries)); % ID within the given series
else
    handles.modID = mod( (handles.app.currID-handles.app.seriesInfo(handles.numSeries-1)), handles.app.npositions(handles.numSeries)); % ID within the given series
end
if (handles.modID == 0)
    handles.modID = handles.app.npositions(handles.numSeries);
end


% --- Executes on button press in savewav_checkbox.
function savewav_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to savewav_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of savewav_checkbox


% --- Executes on button press in sort_checkbox.
function sort_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to sort_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sort_checkbox


% --- Executes on button press in checkbox_SaveSOFA.
function checkbox_SaveSOFA_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_SaveSOFA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_SaveSOFA


% --- Executes on button press in checkbox_isAdvancedSOFA.
function checkbox_isAdvancedSOFA_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_isAdvancedSOFA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_isAdvancedSOFA


% --- Executes on selection change in chl_popup.
function chl_popup_Callback(hObject, eventdata, handles)
% hObject    handle to chl_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chl_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chl_popup
plottype = get(handles.plottype_popup, 'Value');
if (handles.app.currID<=size(handles.data,2))
    if (plottype~=4 && plottype ~=5)
        plotresponse(hObject,handles);
    end
    handles = displayFields(handles);
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function chl_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chl_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in smooth_popup.
function smooth_popup_Callback(hObject, eventdata, handles)
% hObject    handle to smooth_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns smooth_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smooth_popup
if (handles.app.currID<=size(handles.data,2))
    plotresponse(hObject,handles);
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function smooth_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smooth_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in arduinoButton.
function arduinoButton_Callback(hObject, eventdata, handles)
% hObject    handle to arduinoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.ard_installed && ~handles.ard_connected
    handles = ard_setup(handles);
    if handles.ard_connected
        set(handles.arduino_text,'String','connected','FontWeight','bold','ForegroundColor',[0,153/256,0]);
    else
        set(handles.arduino_text,'String','not detected');
    end
end
guidata(hObject,handles);


% --- Executes on button press in raw_checkbox.
function raw_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to raw_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of raw_checkbox

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rawplot_checkbox.
function rawplot_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to rawplot_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.app.currID<=size(handles.data,2))
    plotresponse(hObject,handles);
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of rawplot_checkbox

% --- Function to rotate platform by a given number of degrees (CM addition)
function rotate(handles, n)
steps = round(handles.motor.stepsize/handles.motor.deltastep) * handles.motor.direction;
disp(['Rotation ',num2str(n),' -> rotating motor by ', num2str(handles.motor.stepsize), ' degrees']);
disp(['Rotation progress: ',num2str(n*handles.motor.stepsize),'/',...
    num2str(handles.motor.stepsize*handles.motor.nsteps),' degrees'])
release(handles.motor.stepper);
move(handles.motor.stepper,-1);
pause(0.1);
move(handles.motor.stepper,steps+1);
pause(handles.motor.def_pause);

return


% --- Executes on button press in automeas_button.
function automeas_button_Callback(hObject, eventdata, handles)
% hObject    handle to automeas_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = quickEnable(handles,'off');
handles.motor.inProgress = 1;
handles.warn_text.Visible = 'on';
% start new measurement
if handles.app.currID <= size(handles.data,2)
    handles.app.currID = size(handles.data,2);
    handles = goForward(hObject,handles);
end
% set-up abort button
old_bcol = get(handles.automeas_button,'BackgroundColor');
old_fcol = get(handles.automeas_button,'ForegroundColor');
bcol = get(handles.measureButton,'BackgroundColor');
fcol = get(handles.measureButton,'ForegroundColor');
set(handles.automeas_button,'String','Click to Abort');
set(handles.automeas_button,'BackgroundColor',fcol);
set(handles.automeas_button,'ForegroundColor',bcol);
% update hrir fields
angle = handles.motor.stepsize * handles.motor.direction;
start_pos = str2double(get(handles.az_start,'String'));
end_pos = start_pos - (angle * handles.motor.nsteps);
if handles.app.inMode == 2 && handles.app.outMode == 1
    set(handles.az_interval,'String',num2str(angle));
    set(handles.az_end,'String',end_pos);
    handles = az_start_fun(hObject,handles);
    handles = az_interval_fun(hObject,handles);
    handles = az_end_fun(hObject,handles);
end
for k = 0:handles.motor.nsteps
    if get(handles.automeas_button,'Value')
        set(handles.warn_text,'String','PLEASE WAIT! Auto-measurement in progress...');
        drawnow;
        guidata(hObject,handles);
        % measure
        handles = measureIR(hObject, handles);
        % rotate
        if k < handles.motor.nsteps
            rotate(handles, k+1);
            handles = goForward(hObject, handles);
            if handles.app.inMode~=2 % update info
                azVal = get(handles.az_edit,'String');
                newAz = str2double(azVal)-angle;
                newAz = wrapTo360(newAz);
                set(handles.az_edit,'String',num2str(newAz));
            end
            if handles.app.inMode == 2 && handles.app.outMode ~=1
                start_pos = str2double(get(handles.az_start,'String'));
                set(handles.az_start,'String',num2str(start_pos-angle));
                handles = az_start_fun(hObject,handles);
            end
            guidata(hObject,handles);
        end
    else
        disp('Aborting auto-measurement!');
        break;
    end
end
release(handles.motor.stepper);
set(handles.warn_text,'String','');
handles = quickEnable(handles,'on');
set(handles.automeas_button,'BackgroundColor',old_bcol);
set(handles.automeas_button,'ForegroundColor',old_fcol);
set(handles.automeas_button,'Value',0);
set(handles.automeas_button,'String','AUTOMEASURE');
handles.motor.inProgress = 0;
guidata(hObject,handles);

% Quick button enabler
function handles = quickEnable(handles,status)
handles.arduinoButton.Enable = status;
handles.measureButton.Enable = status;
handles.backButton.Enable = status;
handles.forwardButton.Enable = status;
handles.saveButton.Enable = status;
handles.rot_button.Enable = status;
handles.loadButton.Enable = status;
handles.stepsize_edit.Enable = status;
handles.az_start.Enable = status;
handles.az_interval.Enable = status;
handles.az_end.Enable = status;
handles.el_start.Enable = status;
handles.el_interval.Enable = status;
handles.el_end.Enable = status;
handles.nsteps_edit.Enable = status;
handles.clockradio.Enable = status;
handles.antiradio.Enable = status;

function stepsize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to stepsize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepsize_edit as text
%        str2double(get(hObject,'String')) returns contents of stepsize_edit as a double
currentValue = str2double(get(handles.stepsize_edit, 'String'));
if (currentValue < handles.motor.deltastep || isnan(currentValue))
    warning(['Invalid Entry; motor step size will default to minimum degree step amount:', num2str(handles.motor.deltastep)]);
    handles.motor.stepsize = handles.motor.deltastep;
    set(handles.stepsize_edit, 'String', num2str(handles.motor.deltastep));
else
    if mod(currentValue,handles.motor.deltastep)~=0
        currentValue = round(currentValue/handles.motor.deltastep)*handles.motor.deltastep;
        warning(['Chosen step size value not permissible on this motor.',...
            ' Approximating the step size to closest possible step '...
            'multiple: ', num2str(currentValue)]);
    end
    handles.motor.stepsize = wrapTo360(currentValue);
    set(handles.stepsize_edit, 'String', num2str(currentValue));
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function stepsize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepsize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nsteps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to nsteps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsteps_edit as text
%        str2double(get(hObject,'String')) returns contents of nsteps_edit as a double
currentValue = str2double(get(handles.nsteps_edit, 'String'));
if (currentValue < 1 || isnan(currentValue))
    warning('Invalid Entry; number of steps set to 1');
    set(handles.nsteps_edit, 'String', num2str(1));
else
    currentValue = round(currentValue);
    set(handles.nsteps_edit, 'String', num2str(currentValue));
    handles.motor.nsteps = currentValue;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function nsteps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsteps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rot_button.
function rot_button_Callback(hObject, eventdata, handles)
% hObject    handle to rot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotate(handles,1);
release(handles.motor.stepper);
guidata(hObject,handles);

% --- Executes on button press in clockradio.
function clockradio_Callback(hObject, eventdata, handles)
% hObject    handle to clockradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clockradio
handles.motor.direction = 1;
set(handles.antiradio,'Value',0);
guidata(hObject,handles);

% --- Executes on button press in antiradio.
function antiradio_Callback(hObject, eventdata, handles)
% hObject    handle to antiradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of antiradio
handles.motor.direction = -1;
set(handles.clockradio,'Value',0);
guidata(hObject,handles);


% --- Executes on button press in git_validator.
function git_validator_Callback(hObject, eventdata, handles)
% hObject    handle to git_validator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function level_slider_Callback(hObject, eventdata, handles)
% hObject    handle to level_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
lev = get(handles.level_slider,'Value');
handles.app.sig_level = lev;
set(handles.edit_level,'String',num2str(lev));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function level_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to level_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_level_Callback(hObject, eventdata, handles)
% hObject    handle to edit_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_level as text
%        str2double(get(hObject,'String')) returns contents of edit_level as a double
lev = str2double(get(handles.edit_level,'String'));
if (lev > 1 || lev < 0 || isnan(lev))
    warning('Excitation level must be set to a value between 0 and 1');
    set(handles.edit_level,'String',handles.app.sig_level);
else
    set(handles.level_slider,'Value',lev);
    handles.app.sig_level = lev;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
