%%  JANSENMIDAS.M
%%
%%  This file is part of the supplementary material to 'Jansen-MIDAS: a
%% multi-level photomicrograph segmentation software based on isotropic
%% undecimated wavelets'.
%%
%%  Jansen-MIDAS is a software developed to provide Multi-Level Starlet
%% Segmentation (MLSS) and Multi-Level Starlet Optimal Segmentation
%% (MLSOS) techniques. These methods are based on the starlet transform,
%% an isotropic undecimated wavelet, in order to determine the location
%% of objects in photomicrographs. Using Jansen-MIDAS, a scientist can
%% obtain a multi-level threshold segmentation of his/hers
%% photomicrographs.
%%
%%  Author:
%% Alexandre Fioravante de Siqueira, siqueiraaf@gmail.com
%%
%%  Description: JANSENMIDAS applies the algorithms MLSS and MLSOS on an
%% input image, returning D (the detail wavelet coefficients), R (the
%% multi-level segmentation corresponding to D), COMP (a color comparison
%% between the input image and its ground truth), and MCC (the Matthews
%% correlation coefficient) for each level.
%%
%%  Input: none (all input is asked during runtime).
%%
%%  Output: D, starlet detail levels.
%%          R, the MLSS segmentation levels.
%%          COMP, a color comparison between IMG and IMGGT.
%%          MCC, the Matthews correlation coefficient.
%%
%%  Other files required: binarize.m, confusionmatrix.m, mattewscc.m,
%% mlsos.m, mlss.m, mlssorigaux.m, mlssvaraux.m, starlet.m, twodimfilt.m
%%
%%  Version: april 2016.
%%
%%  Please cite:
%%
%% [1] de Siqueira, A.F. et al. Jansen-MIDAS: a multi-level photomicrograph
%% segmentation software based on isotropic undecimated wavelets, 2016.
%% [2] de Siqueira, A.F. et al. Estimating the concentration of gold
%% nanoparticles incorporated on Natural Rubber membranes using Multi-Level
%% Starlet Optimal Segmentation. Journal of Nanoparticle Research, 2014,
%% 16; 2809. doi: 10.1007/s11051-014-2809-0.
%% [3] de Siqueira, A.F. et al. An automatic method for segmentation
%% of fission tracks in epidote crystal photomicrographs. Computers and
%% Geosciences, 2014, 69; 55-61. doi: 10.1016/j.cageo.2014.04.008.
%% [4] de Siqueira, A.F. et al. Segmentation of scanning electron
%% microscopy images from natural rubber samples with gold nanoparticles
%% using starlet wavelets. Microscopy Research and Technique, 2014, 77(1);
%% 71-78. doi: 10.1002/jemt.22314.
%%
%% Jansen-MIDAS is free software: you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
