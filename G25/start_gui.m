function varargout = start_gui(varargin)
% start_gui MATLAB code for start_gui.fig
addpath('lib'); % add the path

% Initialitation
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @start_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @start_gui_OutputFcn, ...
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

function start_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Initialize variables
handles.output = hObject;
handles.flag = 1;
handles.flag2 = 1;
handles.method = 1;

% Update handles structure
guidata(hObject, handles);

function varargout = start_gui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% Choose path
scene_path = uigetdir('','Select directory of a files');
handles.scene_path = scene_path;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.

function pushbutton3_Callback(hObject, eventdata, handles)
% plot the original image
pathname = handles.scene_path;
filename1 = 'im0.png';
im0_name = fullfile(pathname,filename1);
im0 = imread(im0_name);
if(handles.flag == 1)
    imshow(im0,'Parent',handles.axes1);
end
filename2 = 'im1.png';
im1_name = fullfile(pathname,filename2);
im1 = imread(im1_name);
if(handles.flag == 0)
    imshow(im1,'Parent',handles.axes1);
end

% Update handles structure
handles.Image = im0;
guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% mapping 
scene_path = handles.scene_path;
method = handles.method;
tic

if(method == 1)
[Disparity,distancemap,R,T] = disparitymap_census(scene_path);
end

if(method == 2)
[Disparity,distancemap,R,T]  = disparitymap_SAD(scene_path);
end

if(method == 3)
[Disparity,distancemap,R,T] = disparitymap_GM(scene_path);
end

if(handles.flag2 == 1)
    imshow(Disparity{1},[],'Parent',handles.axes3)
end
if(handles.flag2 == 0)
    imshow(Disparity{2},[],'Parent',handles.axes3)
end
colormap(handles.axes3,jet);
colorbar(handles.axes3);

handles.Disparity = Disparity;
handles.distancemap = distancemap;
% R,T,PSNR calculation
filename = 'disp0.pfm';
filename_pfm = fullfile(scene_path,filename);
Groundtruth = pfmread(filename_pfm);
PSNR = validate_dmap(double(Disparity{1}),Groundtruth);
str = ['Mapping finished, the total time is ', num2str(toc),'s',10,...
       'The PSNR is ',num2str(PSNR),'dB',10,...
       'The R matrix is ', mat2str(round(R,2)),10,...
       'The T vector is ', mat2str(round(T,2))];
set(handles.text7, 'String', str);
guidata(hObject, handles);


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
set(handles.radiobutton2,'value',0);
handles.flag = 1;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
set(handles.radiobutton1,'value',0);
handles.flag = 0;

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% plot left disparity
set(handles.radiobutton4,'value',0);
handles.flag2 = 1;
imshow(handles.Disparity{1},[],'Parent',handles.axes3)
colormap(handles.axes3,jet);
colorbar(handles.axes3);
guidata(hObject, handles);

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% plot right disparity map
set(handles.radiobutton3,'value',0);
handles.flag2 = 0;
imshow(handles.Disparity{2},[],'Parent',handles.axes3);
colormap(handles.axes3,jet);
colorbar(handles.axes3);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% set(hObject,'xTick',[]);
% set(hObject,'ytick',[]);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% 3D reconstruction (need image toolbox)
distancemap = handles.distancemap;
Image = double(handles.Image);
width = size(Image,2);
height = size(Image,1);
[X,Y] = meshgrid(1:width,1:height);
A(:,:,1) = X;
A(:,:,2) = Y;
A(:,:,3) = distancemap;
figure(1)
ptCloud = pointCloud(A,'Color',Image/255);
pcshow(ptCloud,'VerticalAxis', 'y', 'VerticalAxisDir', 'down');


% --- Executes when selected object is changed in Method_group.
function Method_group_SelectionChangedFcn(hObject, eventdata, handles)
% choose method 
switch get(eventdata.NewValue,'Tag')
    case 'Census'
        method = 1;
    case 'BM'
        method = 2;
    case 'GM'
        method = 3;
end

% Update handles structure
handles.method = method;
guidata(hObject, handles);
