function varargout = welcome(varargin)
% WELCOME M-file for welcome.fig
%      WELCOME by itself, creates a new WELCOME or raises the
%      existing singleton*.
%
%      H = WELCOME returns the handle to a new WELCOME or the handle to
%      the existing singleton*.
%
%      WELCOME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WELCOME.M with the given input arguments.
%
%      WELCOME('Property','Value',...) creates a new WELCOME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before welcome_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to welcome_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help welcome

% Last Modified by GUIDE v2.5 18-Feb-2019 21:35:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @welcome_OpeningFcn, ...
                   'gui_OutputFcn',  @welcome_OutputFcn, ...
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

% --- Executes just before welcome is made visible.
function welcome_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to welcome (see VARARGIN)

% Choose default command line output for welcome
handles.output = 'No';


% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
% GUI Dyanimc Resize Params
ref_ss(1) = (200/72);
ref_ss(2) = (160/72);
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
Width = max([round(ref_ss(1)*res_ss(3)),round(p_ss(3)*0.15)]);
Height = max([round(ref_ss(2)*res_ss(4)),round(p_ss(4)*0.2)]);
if (Width > p_ss(3)) Width = p_ss(3); end
if (Height > p_ss(4)) Height = p_ss(4); end
FigPos(3)= Width;
FigPos(4)= Height;
FigPos(1)= round((p_ss(3)-FigPos(3))/2);
FigPos(2)= round((p_ss(4)-FigPos(4))/2);
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

% display MARL logo in axes_logo 
axes(handles.axes_logo)
[img, map, alphachannel] = imread('MARL_Logo.png');
image(img, 'AlphaData', alphachannel);
axis off
axis image


IconData=questIconData;
questIconMap(256,:) = get(handles.figure1, 'Color');
IconCMap=questIconMap;


set(handles.figure1, 'Colormap', IconCMap);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes welcome wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = welcome_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in createButton.
function createButton_Callback(hObject, eventdata, handles)
handles.output = 'createNew';

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = 'createNew';
guidata(hObject, handles);
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"    
if ( isequal(get(hObject,'CurrentKey'),'return') || isequal(get(hObject,'CurrentKey'),'escape') )
    handles.output = 'createNew';
    guidata(hObject, handles);
    uiresume(handles.figure1);
end    


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)handles.output = 'createNew';
handles.output='loadSession';
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);
