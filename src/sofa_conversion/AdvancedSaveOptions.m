function varargout = AdvancedSaveOptions(varargin)
% ADVANCEDSAVEOPTIONS MATLAB code for AdvancedSaveOptions.fig
%      ADVANCEDSAVEOPTIONS, by itself, creates a new ADVANCEDSAVEOPTIONS or raises the existing
%      singleton*.
%
%      H = ADVANCEDSAVEOPTIONS returns the handle to a new ADVANCEDSAVEOPTIONS or the handle to
%      the existing singleton*.
%
%      ADVANCEDSAVEOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCEDSAVEOPTIONS.M with the given input arguments.
%
%      ADVANCEDSAVEOPTIONS('Property','Value',...) creates a new ADVANCEDSAVEOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AdvancedSaveOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AdvancedSaveOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AdvancedSaveOptions

% Last Modified by GUIDE v2.5 29-Oct-2018 11:49:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AdvancedSaveOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @AdvancedSaveOptions_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before AdvancedSaveOptions is made visible.
function AdvancedSaveOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AdvancedSaveOptions (see VARARGIN)

% Choose default command line output for AdvancedSaveOptions
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AdvancedSaveOptions wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AdvancedSaveOptions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);



function textfield_databaseName_Callback(hObject, eventdata, handles)
% hObject    handle to textfield_databaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textfield_databaseName as text
%        str2double(get(hObject,'String')) returns contents of textfield_databaseName as a double


% --- Executes during object creation, after setting all properties.
function textfield_databaseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textfield_databaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textfield_organization_Callback(hObject, eventdata, handles)
% hObject    handle to textfield_organization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textfield_organization as text
%        str2double(get(hObject,'String')) returns contents of textfield_organization as a double


% --- Executes during object creation, after setting all properties.
function textfield_organization_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textfield_organization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textfield_authorContact_Callback(hObject, eventdata, handles)
% hObject    handle to textfield_authorContact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textfield_authorContact as text
%        str2double(get(hObject,'String')) returns contents of textfield_authorContact as a double


% --- Executes during object creation, after setting all properties.
function textfield_authorContact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textfield_authorContact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function textfield_comments_Callback(hObject, eventdata, handles)
% hObject    handle to textfield_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textfield_comments as text
%        str2double(get(hObject,'String')) returns contents of textfield_comments as a double


% --- Executes during object creation, after setting all properties.
function textfield_comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textfield_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data.databaseName = get(handles.textfield_databaseName,'String');
data.organization = get(handles.textfield_organization,'String');
data.authorContact = get(handles.textfield_authorContact,'String');
data.comment = get(handles.textfield_comments,'String');

handles.output = data;

% Update handles structure
guidata(hObject, handles);

uiresume(handles.figure1);






