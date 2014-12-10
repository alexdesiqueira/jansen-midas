%%  JANSENMIDAS.M
%%
%%  Version: november 2014.
%%
%%  This file is part of the supplementary material to 'An automatic 
%% method for segmentation of fission tracks in epidote crystal 
%% photomicrographs, based on starlet wavelets'.
%%
%%  Author: 
%% Alexandre Fioravante de Siqueira, siqueiraaf@gmail.com
%%
%%  Description: this software (...)
%%
%%
%%
%%  Input: (...)
%%         (...)
%%
%%  Output: (...)
%%          (...)
%%          
%%  Other files required: (...)
%%
%%  Please cite:
%% (...)
%%

function varargout = JansenMIDAS(varargin)
%%% BEGIN INITIALIZATION CODE - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JansenMIDAS_OpeningFcn, ...
                   'gui_OutputFcn',  @JansenMIDAS_OutputFcn, ...
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
%%% END INITIALIZATION CODE - DO NOT EDIT

function JansenMIDAS_OpeningFcn(hObject, ~, handles, varargin)
%%% CHOOSE DEFAULT COMMAND LINE OUTPUT FOR JansenMIDAS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = JansenMIDAS_OutputFcn(~, ~, handles) 
%%% GET DEFAULT COMMAND LINE OUTPUT FROM HANDLES STRUCTURE
varargout{1} = handles.output;

function pushbutton1_Callback(~, ~, handles)

%%% GETTING MAIN IMAGE
global mat_image;

set(handles.text1,'String','Opening image...'); % change text

[filename, pathname] = uigetfile( ...
    {'*.tif', 'TIF files (*.tif)'; ...
     '*.png', 'PNG files (*.png)'; ...
     '*.jpg', 'JPEG files (*.jpg)'; ...
     '*.*','All files (*.*)'}, ...
    'Open image...');

if isequal([filename,pathname],[0,0])
    return
else
    name_image = fullfile(pathname,filename);
    
    mat_image = imread(name_image);
    axes(handles.axes1);
    imshow(mat_image);
    
    %%% CONVERT RGB TO GRAY
    if ~ismatrix(mat_image)
        mat_image = rgb2gray(mat_image);
    end

    %%% DISABLE BUTTONS
    set(handles.pushbutton1,'Visible','off');
    set(handles.pushbutton2,'Visible','on');
end

function pushbutton2_Callback(~, ~, handles)

%%% PRELIMINAR VARS
global mat_image;
global mat_gt;

set(handles.text1,'String','Processing...'); % change text

%%% OBTAINING FIRST AND LAST DECOMPOSITION LEVELS
initL = str2num(get(handles.edit1,'String'));
L = str2num(get(handles.edit2,'String'));

if (isempty(initL) || initL == 0 || isempty(L) || L == 0)
    set(handles.text1,'String','Assuming initial L = 1 and last L = 5...');
    set(handles.edit1,'String','1');
    set(handles.edit2,'String','5');

    initL = 1;
    L = 5;
end

%%% DISABLE EDIT BOXES
set(handles.edit1,'Enable','off');
set(handles.edit2,'Enable','off');

%%% APPLY MLSS
if (get(handles.checkbox1,'Value') == get(handles.checkbox1,'Min'))
    [D,R] = mlss(mat_image,initL,L,0);
else
    [D,R] = mlss(mat_image,initL,L,1);
end

%%% APPLY MLSOS?
if (get(handles.togglebutton1,'Value') == get(handles.togglebutton1,'Max'))
    
    set(handles.text1,'String','Opening GT image...'); % change text

	[filename, pathname] = uigetfile( ...
        {'*.tif', 'TIF files (*.tif)'; ...
        '*.png', 'PNG files (*.png)'; ...
        '*.jpg', 'JPEG files (*.jpg)'; ...
        '*.*','All files (*.*)'}, ...
        'Open ground truth (GT) image...');

    if isequal([filename,pathname],[0,0])
        return
    else
        name_gt = fullfile(pathname,filename);

        mat_gt = imread(name_gt);
        axes(handles.axes1);
        imshow(mat_gt);

        %%% CONVERT RGB TO GRAY
        if ~ismatrix(mat_gt)
            mat_gt = rgb2gray(mat_gt);
        end
    end
    
    %%% APPLYING MLSOS
    [COMP,MCC] = mlsos(R,mat_gt,initL,L);
end

%%% SHOW D RESULTS
if (get(handles.checkbox2,'Value') == get(handles.checkbox2,'Max'))
	for i = 1:L
        figure; imshow(D(:,:,i)); title(strcat('D =',32,num2str(i)));
    end
end

%%% SHOW R RESULTS
if (get(handles.checkbox3,'Value') == get(handles.checkbox3,'Max'))
    for i = initL:L
        figure; imshow(R(:,:,i)); title(strcat('R =',32,num2str(i)));
	end
end

%%% SHOW COMP RESULTS
if (get(handles.togglebutton1,'Value') == get(handles.togglebutton1,'Max'))
    for i = initL:L
        figure; imshow(COMP(:,:,:,i)); title(strcat('COMP =',32,num2str(i)));
    end
end

set(handles.text1,'String','Done'); % change text

function checkbox1_Callback(~, ~, ~)

function checkbox2_Callback(~, ~, ~)

function checkbox3_Callback(~, ~, ~)

function edit1_Callback(~, ~, ~)

function edit2_Callback(~, ~, ~)

function togglebutton1_Callback(~, ~, ~)

function edit1_CreateFcn(hObject, ~, ~)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_CreateFcn(hObject, ~, ~)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
