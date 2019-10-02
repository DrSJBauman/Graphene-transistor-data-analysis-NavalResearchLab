function varargout = FETAnalysisv4(varargin)
% FETANALYSISV4 MATLAB code for FETAnalysisv4.fig
%      FETANALYSISV4, by itself, creates a new FETANALYSISV4 or raises the existing
%      singleton*.
%JULIANS!
%      H = FETANALYSISV4 returns the handle to a new FETANALYSISV4 or the handle to
%      the existing singleton*.
%
%      FETANALYSISV4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FETANALYSISV4.M with the given input arguments.
%
%      FETANALYSISV4('Property','Value',...) creates a new FETANALYSISV4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FETAnalysisv4_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FETAnalysisv4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% Current Issues:
% The image plot is a little finiki in that its limits are a little off. I want it to be
% fill from 0-1, 1-2, etc., but it does 0.5-1.5, 1.5-2.5...the issue is
% that I'm sing ceil on x and y values so when it gets to points in the
% final x+0.5 range it has an issue!  Look on line 700ish in the bitmap
% function
% --> Also, the fits for the lines that show up in the plot are done
% locally while the data is actually processed in readExcelData.m.
% Therefore, changes made to those fits happen here and are updated in the
% output only after the line is looked at on the bitmap.  Also, there is no
% way to change it right now.  
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FETAnalysisv4

% Last Modified by GUIDE v2.5 30-Jun-2017 09:49:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FETAnalysisv4_OpeningFcn, ...
                   'gui_OutputFcn',  @FETAnalysisv4_OutputFcn, ...
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


% --- Executes just before FETAnalysisv4 is made visible.
function FETAnalysisv4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles acnd user data (see GUIDATA)
% varargin   command line arguments to FETAnalysisv4 (see VARARGIN)

% Choose default command line output for FETAnalysisv4
handles.output = hObject;
global plotflag 
global plotflagVmu
global currFile
global currAppend
plotflag = true;
plotflagVmu = false;
currFile = 1;
currAppend = 1;

handles.directory = [];
handles.ext = 'F';
handles.plot3 = 'DrainI';
set(gcbf,'UserData',0);
% Update handles structure
guidata(hObject, handles);

% uiwait(handles.figure1);
% UIWAIT makes FETAnalysisv4 wait for user response (see UIRESUME)



% --- Outputs from this function are returned to the command line.
function varargout = FETAnalysisv4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure

varargout{1} = handles.output;
% delete(FETAnalysisv4);


% --- Executes on selection change in xvarpop.
function xvarpop_Callback(hObject, eventdata, handles)
% hObject    handle to xvarpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns xvarpop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from xvarpop

genbitmap(hObject,handles,1,1);

% --- Executes during object creation, after setting all properties.
function xvarpop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xvarpop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in yvarlist.
function yvarlist_Callback(hObject, eventdata, handles)
% hObject    handle to yvarlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Today!
selected = get(hObject,'Value');
strings = get(hObject,'String');
handles.plot3 = strings{selected}
guidata(hObject, handles)


% Hints: contents = cellstr(get(hObject,'String')) returns yvarlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yvarlist
% 

% --- Executes during object creation, after setting all properties.
function yvarlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yvarlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadFilesButton.
function LoadFilesButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
handles.ext = 'F';
ext = handles.ext ;
%Get Files
if isempty(handles.directory) %Returns 1 if empty array or 0
    handles.directory = pwd;
%      handles.directory = 'C:\Users\Julian McMorrow\Desktop\My Dropbox\Julian Share\Presentation Stuff';
%     handles.directory = '/Users/corycress/Documents/Research/Projects/Graphene/Thin SiO2/CCi120 and C2R28';
  % handles.directory = '/Users/corycress/Documents/Research/Projects/Graphene/';
end
[pathname tempfilename] = Choosefiles(handles.directory); % Allows user to select multiple files
handles.directory = pathname;
guidata(hObject, handles)

if isempty(tempfilename) == 1
    %     export = 'Program Aborted';
    return
end
set(handles.filelist,'String',tempfilename);
selectedfiles = get(handles.filelist,'Value')

[calcData, compData] = readExcelData(handles.directory, tempfilename);

handles.calcData = calcData;
handles.compData = compData;
assignin('base','please',compData);
%initialize the parameters to file 1, sheet 1
xvarlist = fields(handles.compData(1,1));
set(handles.xvarpop,'String',xvarlist); %This sets the Axes1 Contour Variable List
set(handles.xvarpop,'Value',4); %This selects the 4th variable (usualy Col) as the value plotted
set(handles.yvarlist,'String',xvarlist);
genbitmap(hObject,handles,1,1);

% % % % % % % setParams(hObject,handles,1,1);
% % % % % % % [n,m] = size(handles.compData);
% % % % % % % 
% % % % % % % for ff=1:n
% % % % % % %     for ss = 1:m
% % % % % % %         if ~isempty(handles.compData(ff,ss).pMu)
% % % % % % %             pMuSurf(ff,ss) = handles.compData(ff,ss).pMu;
% % % % % % %         else
% % % % % % %             pMuSurf(ff,ss) = 0;
% % % % % % %         end
% % % % % % %     end
% % % % % % % end
% % % % % % % axes(handles.axes1);
% % % % % % % imagesc(pMuSurf);
% % % % % % % set(gca,'YDir','normal');
%leg = {};
% for i = 1:5
%     plot(handles.axes3,handles.compData(1,i).GateV,handles.compData(1,i).DrainI);
%     leg = [leg [tempfilename handles.compData(1,i).sheet]]
%     legend(handles.axes3,leg);
%     hold all;
%     drawnow
%     REFRESH
% end
guidata(hObject, handles)
 

% --- Executes on selection change in filelist.
function filelist_Callback(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filelist



% --- Executes during object creation, after setting all properties.
function filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
% function figure1_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% %Hint: delete(hObject) closes the figure
%  uiresume(hObject);
% delete(hObject);



function fileNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNameEdit as text
%        str2double(get(hObject,'String')) returns contents of fileNameEdit as a double


% --- Executes during object creation, after setting all properties.
function fileNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rowEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rowEdit as text
%        str2double(get(hObject,'String')) returns contents of rowEdit as a double


% --- Executes during object creation, after setting all properties.
function rowEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rowEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function colEdit_Callback(hObject, eventdata, handles)
% hObject    handle to colEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colEdit as text
%        str2double(get(hObject,'String')) returns contents of colEdit as a double


% --- Executes during object creation, after setting all properties.
function colEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lEdit as text
%        str2double(get(hObject,'String')) returns contents of lEdit as a double


% --- Executes during object creation, after setting all properties.
function lEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wEdit_Callback(hObject, eventdata, handles)
% hObject    handle to wEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wEdit as text
%        str2double(get(hObject,'String')) returns contents of wEdit as a double


% --- Executes during object creation, after setting all properties.
function wEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to toxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toxEdit as text
%        str2double(get(hObject,'String')) returns contents of toxEdit as a double


% --- Executes during object creation, after setting all properties.
function toxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epsrEdit_Callback(hObject, eventdata, handles)
% hObject    handle to epsrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epsrEdit as text
%        str2double(get(hObject,'String')) returns contents of epsrEdit as a double


% --- Executes during object creation, after setting all properties.
function epsrEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epsrEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function capEdit_Callback(hObject, eventdata, handles)
% hObject    handle to capEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of capEdit as text
%        str2double(get(hObject,'String')) returns contents of capEdit as a double


% --- Executes during object creation, after setting all properties.
function capEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to capEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pMuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pMuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pMuEdit as text
%        str2double(get(hObject,'String')) returns contents of pMuEdit as a double


% --- Executes during object creation, after setting all properties.
function pMuEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pMuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nMuEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nMuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nMuEdit as text
%        str2double(get(hObject,'String')) returns contents of nMuEdit as a double


% --- Executes during object creation, after setting all properties.
function nMuEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nMuEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function IdMInEdit_Callback(hObject, eventdata, handles)
% hObject    handle to IdMInEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IdMInEdit as text
%        str2double(get(hObject,'String')) returns contents of IdMInEdit as a double


% --- Executes during object creation, after setting all properties.
function IdMInEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IdMInEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cnpEdit_Callback(hObject, eventdata, handles)
% hObject    handle to cnpEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cnpEdit as text
%        str2double(get(hObject,'String')) returns contents of cnpEdit as a double


% --- Executes during object creation, after setting all properties.
function cnpEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cnpEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pVtEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pVtEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pVtEdit as text
%        str2double(get(hObject,'String')) returns contents of pVtEdit as a double


% --- Executes during object creation, after setting all properties.
function pVtEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pVtEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nVtEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nVtEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nVtEdit as text
%        str2double(get(hObject,'String')) returns contents of nVtEdit as a double


% --- Executes during object creation, after setting all properties.
function nVtEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nVtEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pOnOffEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pOnOffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pOnOffEdit as text
%        str2double(get(hObject,'String')) returns contents of pOnOffEdit as a double


% --- Executes during object creation, after setting all properties.
function pOnOffEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pOnOffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nOnOffEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nOnOffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nOnOffEdit as text
%        str2double(get(hObject,'String')) returns contents of nOnOffEdit as a double


% --- Executes during object creation, after setting all properties.
function nOnOffEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nOnOffEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pIdMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pIdMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pIdMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of pIdMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function pIdMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pIdMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nIdMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to nIdMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nIdMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of nIdMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function nIdMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nIdMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sheetNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sheetNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sheetNameEdit as text
%        str2double(get(hObject,'String')) returns contents of sheetNameEdit as a double


% --- Executes during object creation, after setting all properties.
function sheetNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sheetNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------
%----------------My Functions!---------
%--------------------------------------
function setParams(hObject, handles,file,sheet)
f = file; %Potential UPDATE: This could instead use the new global currFile and currAppend which were added 11/30/11;  
i = sheet;

ext = handles.ext; % Determines whether to plot forward or reverse data.
if isfield(handles.compData(f,i), 'hystp')
    set(handles.hystp,'String',num2str(handles.compData(f,i).hystp));
else
    set(handles.hystp,'String',num2str(0));
end

if isfield(handles.compData(f,i), 'hystn')
    set(handles.hystn,'String',num2str(handles.compData(f,i).hystn));
else
    set(handles.hystn,'String',num2str(0));
end

set(handles.noteEdit,'String',handles.compData(f,i).Notes);
set(handles.fileNameEdit,'String',handles.compData(f,i).file);
set(handles.sheetNameEdit,'String',handles.compData(f,i).sheet);

set(handles.toxEdit,'String',num2str(handles.calcData{f}.tox(i)));
set(handles.epsrEdit,'String',num2str(handles.calcData{f}.epsr(i)));

set(handles.wEdit,'String',num2str(handles.calcData{f}.W(i)));
set(handles.lEdit,'String',num2str(handles.calcData{f}.L(i)));

set(handles.rowEdit,'String',num2str(handles.calcData{f}.Row(i)));
set(handles.colEdit,'String',num2str(handles.calcData{f}.Col(i)));
set(handles.pVtEdit,'String',num2str(handles.compData(f,i).(['pVt' ext])));
set(handles.nVtEdit,'String',num2str(handles.compData(f,i).(['nVt' ext])));
set(handles.pMuEdit,'String',num2str(handles.compData(f,i).(['pMu'  ext])));
set(handles.nMuEdit,'String',num2str(handles.compData(f,i).(['nMu' ext])));
set(handles.IdMInEdit,'String',num2str(handles.compData(f,i).(['IdMin' ext])));
set(handles.cnpEdit,'String',num2str(handles.compData(f,i).(['cnp'  ext])));
set(handles.pIdMaxEdit,'String',num2str(handles.compData(f,i).(['pIdMax' ext])));
set(handles.nIdMaxEdit,'String',num2str(handles.compData(f,i).(['nIdMax' ext])));
set(handles.pOnOffEdit,'String',num2str(handles.compData(f,i).(['pOnOff'  ext])));
set(handles.nOnOffEdit,'String',num2str(handles.compData(f,i).(['nOnOff' ext])));   
set(handles.capEdit,'String',num2str(handles.compData(f,i).('CAP')));   

%If this is the first time, create 2 new variables to store the fit range
%information
% % % I removed this on 12/8
% % % if ~isfield(handles, 'fitMin'); %fitMin (and fitMax) will hold the range for the fits; hopefully I don't need to have one for both sweeps
% % %     [m,n] = size(handles.compData);
% % %     handles.fitMin(m,n) = range(1); %This is storing the values to the min/max range since they are just being created.
% % %     handles.fitMax(m,n) = range(2);
% % % end

%If a line hasn't been created yet - (handles.lmax stores the handle to the
%line) then the value of the max slide should be set to its maximum 

% Update needed!  12-13-2011  I don't this  should be here in setParams!
% % % % % % currFitMax =  get(handles.sliderMax,'Value');
% % % % % % currFitMin =  get(handles.sliderMin,'Value');
% % % % % % if ~isfield(handles,'lmax')  %If lmax then also lmin
% % % % % %      set(handles.sliderMax,'Value',range(2)); %Sets slideMax to max value 
% % % % % %      set(handles.textMax,'String',num2str(range(2)));%Sets the max indicator
% % % % % %      handles.lmax = line([range(2),range(2)],[range(3),range(4)],'color',[0 1 0]);
% % % % % %      set(handles.sliderMin,'Value',range(1)); %Sets slideMax to max value 
% % % % % %      set(handles.textMin,'String',num2str(range(1)));%Sets the max indicator
% % % % % %      handles.lmin = line([range(1),range(1)],[range(3),range(4)],'color',[1 0 0])
% % % % % % end

guidata(hObject, handles)

%--------------------------------------
%--------------------------------------
function genbitmap(hObject,handles,file,sheet)

setParams(hObject,handles,1,1); %initialize the params to file 1 and sheet 1
[n,m] = size(handles.compData);
val = get(handles.xvarpop,'Value');
valList = get(handles.xvarpop,'String');
if ~isstr(handles.compData(1,1).(valList{val}))
    for f=1:n
        for s = 1:m
            if isfield(handles.compData(f,s),valList{val}) && ~isempty(handles.compData(f,s).(valList{val}))
                bitmap(f,s) = handles.compData(f,s).(valList{val});
            else
                bitmap(f,s) = 0;
            end
        end
    end
      y = 1:n;
      x = 1:m;
    axes(handles.axes1);
     imagesc(x,y,bitmap);
%     imagesc(bitmap);
    set(gca,'YDir','normal');
    colorbar;
   % axis([x(1) x(m) y(1) y(n)])
else
    display('Sorry, can''t display the string');
end
handles.bitmap = bitmap;
drawnow;
guidata(hObject, handles)
%--------------------------------------
%--------------------------------------


%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
%----------------Mouse Over Contour!---------
%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

% --- Executes on mouse press over axes background.Doesn't seem to do
% anything!
% % % function axes1_ButtonDownFcn(hObject, eventdata, handles)
% % % % hObject    handle to axes1 (see GCBO)
% % % % eventdata  reserved - to be defined in a future version of MATLAB
% % % % handles    structure with handles and user data (see GUIDATA)
% % % axes(handles.axes1);
% % % lim = axis
% % % pause;
% % % x = round((currPt(1)-graphPos(1))/graphPos(3)*(lim(2) - lim(1))+lim(1))
% % % y = round((currPt(2)-graphPos(2))/graphPos(4)*(lim(4) - lim(3))+lim(3))
% % % 
% % %  
% % % flds = fields(handles.compData(x,y));
% % % for i = l:length(flds)
% % %     handles.compData(x,y).(flds{i}) = [];
% % % end
% % % % if ~exist currPt
% % % %     hits = 1;
% % % % end
% % % %axes(handles.axes1);
% % % %zoom on;
% % % %hits = currPt(1,1);
% % % % % % % % x = 1:5:50;
% % % % % % % % y =x;
% % % % % % % % plot(handles.axes1,x,y);
% % % % % % % % set(handles.axes1,'DrawMode','fast','layer','bottom');
% % % % % % % % currPt = get(handles.axes1,'CurrentPoint');
% % % % % % % % display(currPt)
% % % % % % % % %hold all;
% % % % % % % % drawnow;
% % % % % % % % refresh;
% % % guidata(hObject, handles)


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%% Jeff's Get Position Function so the values of the axes are hard
%%%%%%%%% wired in.
function val = isCursorInArea(butPos, cursorPos)
    val = false;
    if(cursorPos(1) >= butPos(1) && cursorPos(1) <= butPos(1) + butPos(3) && cursorPos(2) >= butPos(2) && cursorPos(2) <= butPos(2) + butPos(4))
       val = true;
    end
%%%%%%%%% 
%%%%%%%%% 
    
    
% --- Executes on button press in export.
function export_Callback(hObject, eventdata, handles)
% hObject    handle to export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tempFile = get(handles.exportFileName,'String');
exportFile = [handles.directory tempFile];

if isfield(handles.compData, 'pIdMaxR')
header = {'File' 'Sheet' 'Row' 'Col' 'L (\fm\nm)' 'W (\fm\nm)' 'Tox (nm)' 'EpsR' 'IdMinF (A)'...
    'CNPF (V)' 'pIdMaxF (A)' 'pMuF (cm\u2\n/Vs)' 'pVtF (V)' 'pOnOffF' 'nIdMaxF' 'nMuF (cm\u2\n/Vs)'...
    'nVtF (V)' 'nOnOff' 'IdMinR (A)' 'CNPR (V)' 'pIdMaxR (A)' 'pMuR (cm\u2\n/Vs)' 'pVtR (V)'...
    'pOnOffR' 'nIdMaxR (A)' 'nMuR (cm\u2\n/Vs)' 'nVtR (V)' 'nOnOffR' 'Hysteresis p (V)' 'Hysteresis n (V)' 'Cap F/cm2'};

data = {{handles.compData.file} {handles.compData.sheet} {handles.compData.Row}...
    {handles.compData.Col} {handles.compData.L} {handles.compData.W} {handles.compData.tox}...
    {handles.compData.epsr} {handles.compData.IdMinF} {handles.compData.cnpF}...
    {handles.compData.pIdMaxF} {handles.compData.pMuF} {handles.compData.pVtF} {handles.compData.pOnOffF}...
    {handles.compData.nIdMaxF} {handles.compData.nMuF} {handles.compData.nVtF} {handles.compData.nOnOffF}...
    {handles.compData.IdMinR} {handles.compData.cnpR}...
    {handles.compData.pIdMaxR} {handles.compData.pMuR} {handles.compData.pVtR} {handles.compData.pOnOffR}...
    {handles.compData.nIdMaxR} {handles.compData.nMuR} {handles.compData.nVtR} {handles.compData.nOnOffR}...
    {handles.compData.hystp} {handles.compData.hystn}};
else
%     header = {'File' 'Sheet' 'Row' 'Col' 'L (\fm\nm)' 'W (\fm\nm)' 'Tox (nm)' 'EpsR' 'IdMinF (A)'...
%     'CNPF (V)' 'pIdMaxF (A)' 'pMuF (cm\u2\n/Vs)' 'pVtF (V)' 'pOnOffF' 'nIdMaxF' 'nMuF (cm\u2\n/Vs)'...
%     'nVtF (V)' 'nOnOff' 'IdMinR (A)' 'CNPR (V)' 'pIdMaxR (A)' 'pMuR (cm\u2\n/Vs)' 'pVtR (V)'...
%     'pOnOffR' 'nIdMaxR (A)' 'nMuR (cm\u2\n/Vs)' 'nVtR (V)' 'nOnOffR' 'Hysteresis (V)' 'Cap F/cm2'};

data = {{handles.compData.file} {handles.compData.sheet} {handles.compData.Row}...
    {handles.compData.Col} {handles.compData.L} {handles.compData.W} {handles.compData.tox}...
    {handles.compData.epsr} {handles.compData.IdMinF} {handles.compData.cnpF}...
    {handles.compData.pIdMaxF} {handles.compData.pMuF} {handles.compData.pVtF} {handles.compData.pOnOffF}...
    {handles.compData.nIdMaxF} {handles.compData.nMuF} {handles.compData.nVtF} {handles.compData.nOnOffF}};
header = {'File' 'Sheet' 'Row' 'Col' 'L (\fm\nm)' 'W (\fm\nm)' 'Tox (nm)' 'EpsR' 'IdMinF (A)'...
    'CNPF (V)' 'pIdMaxF (A)' 'pMuF (cm\u2\n/Vs)' 'pVtF (V)' 'pOnOffF' 'nIdMaxF' 'nMuF (cm\u2\n/Vs)'...
    'nVtF (V)' 'nOnOffF' 'Cap F/cm2'};
end
printCellArray4(header,data,[tempFile num2str(floor(rand*1e4)) '.txt']);
guidata(hObject, handles)




function exportFileName_Callback(hObject, eventdata, handles)
% hObject    handle to exportFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exportFileName as text
%        str2double(get(hObject,'String')) returns contents of exportFileName as a double


% --- Executes during object creation, after setting all properties.
function exportFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exportFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reverseCheck.
function reverseCheck_Callback(hObject, eventdata, handles)
% hObject    handle to reverseCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value');
    handles.ext = 'R';    
else
    handles.ext = 'F';
end
% if ~isfield(handles.compData,'TID')
%     for a = 1:length(handles.compData)
%         handles.compData(1,a).TID = handles.calcData{1}.TID(a);
%     end
% end
%cnp2F,R are the Vg,min like Chen's paper 

header = [{'TID' 'pMuF' 'nMuF' 'pMuR' 'nMuR' 'cnp2F' 'cnp2R' 'qintcnpF'...
    'qintcnpR' 'idcnp2F' 'idcnp2R' 'sigmaMinF' 'sigmaMinR' 'sigmaResF' 'sigmaResR'...
    'pVtF' 'nVtF' 'pVtR' 'nVtR'}] 
data = {{handles.compData.TID} {handles.compData.pMuF} {handles.compData.nMuF}...
{handles.compData.pMuR} {handles.compData.nMuR}...
{handles.compData.cnp2F} {handles.compData.cnp2R}...
{handles.compData.qintcnpF} {handles.compData.qintcnpR}...
{handles.compData.idcnp2F} {handles.compData.idcnp2R}...
{handles.compData.sigmaMinF} {handles.compData.sigmaMinR}...
{handles.compData.sigmaResF} {handles.compData.sigmaResR}...
{handles.compData.pVtF} {handles.compData.nVtF}...
{handles.compData.pVtR} {handles.compData.nVtR}};

printCellArray4(header,data,'CCi150 1@3 data1.txt');

% Hint: get(hObject,'Value') returns toggle state of reverseCheck
guidata(hObject, handles)


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotflag

if strcmpi(get(handles.axes3,'YScale'),'log')
    set(handles.axes3,'YScale','lin');
    plotflag = false;
else
    set(handles.axes3,'YScale','log');
    plotflag = true;
end
guidata(hObject,handles)


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plotflag
global plotflagVmu
global currFile
global currAppend

%set(gcbo,'UserData',0)
%get(gcbf,'UserData')
% set(gcbf,'UserData',0);
% % if get(gcbf,'UserData');
% %     display('Waitingfor');
% %     pause(.1)
% %     display('Done Waiting');
% %     drawnow;
% % end

currPt = get(hObject,'CurrentPoint');
initial = get(handles.filelist,'String'); %This will be filelist until a file is selected
graphPos = get(handles.axes1,'Position');  %[x, y, width, height]
ext = handles.ext;

if ~strcmp(initial, 'filelist') %If it still says 'filelist' it won't enter the loop
    if(isCursorInArea(graphPos, currPt))%if currPt(1) >50 && currPt(1) <86 && currPt(2) >35 && currPt(2) <53
        axes(handles.axes1);
        lim = axis;
        a = round((currPt(1)-graphPos(1)-eps)/graphPos(3)*(lim(2) - lim(1))+lim(1)); %Append number
        f = round((currPt(2)-graphPos(2)-eps)/graphPos(4)*(lim(4) - lim(3))+lim(3)); %File number
       
        currFile = f;
        currAppend = a;
        handles.compData = plot2Axis3(handles);
        setParams(hObject, handles,f,a); 
        drawnow;
    end
    
end

guidata(hObject, handles)




function hystp_Callback(hObject, eventdata, handles)
% hObject    handle to hystp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hystp as text
%        str2double(get(hObject,'String')) returns contents of hystp as a double


% --- Executes during object creation, after setting all properties.
function hystp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hystp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hystn_Callback(hObject, eventdata, handles)
% hObject    handle to hystn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hystn as text
%        str2double(get(hObject,'String')) returns contents of hystn as a double


% --- Executes during object creation, after setting all properties.
function hystn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hystn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noteEdit_Callback(hObject, eventdata, handles)
% hObject    handle to noteEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noteEdit as text
%        str2double(get(hObject,'String')) returns contents of noteEdit as a double


% --- Executes during object creation, after setting all properties.
function noteEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noteEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in VMu.
function VMu_Callback(hObject, eventdata, handles)
% hObject    handle to VMu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of VMu
global plotflagVmu;

if get(hObject,'Value')
    %set(handles.axes3,'YScale','lin');
    plotflagVmu = true;
else
    %set(handles.axes3,'YScale','log');
    plotflagVmu = false;
end
guidata(hObject,handles)


% --- Executes on slider movement.
function sliderMin_Callback(hObject, eventdata, handles)
% hObject    handle to sliderMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global currFile
global currAppend

f = currFile;
a = currAppend;

axes(handles.axes3)
%set(handles.axes3, 'NextPlot', 'Add');

axes3Lines = get(handles.axes3,'children');
valsliderMax = get(handles.sliderMax,'Value');
valsliderMin = get(handles.sliderMin,'Value');
set(handles.textMax,'String',num2str(valsliderMax));%Sets the indicator values
set(handles.textMin,'String',num2str(valsliderMin));%Sets the indicator values

range=axis();
xRange = range([1,2]);
yRange = range([3,4]);

try
[ind,~,~]=find(axes3Lines == handles.lmin);
delete(axes3Lines(ind));
catch
    display('didnt find a handles.lmin');
end
handles.lmin = line([valsliderMin,valsliderMin],yRange,'color',[1 0 0]);
%calcF(hObject,handles,f,a);
%calcR(hObject,handles,f,a);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function sliderMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderMax_Callback(hObject, eventdata, handles)
% hObject    handle to sliderMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global currFile
global currAppend

f = currFile;
a = currAppend;

axes(handles.axes3)
%set(handles.axes3, 'NextPlot', 'Add');

axes3Lines = get(handles.axes3,'children');
valsliderMax = get(handles.sliderMax,'Value');
valsliderMin = get(handles.sliderMin,'Value');
set(handles.textMax,'String',num2str(valsliderMax));%Sets the indicator values
set(handles.textMin,'String',num2str(valsliderMin));%Sets the indicator values


range=axis();
xRange = range([1,2]);
yRange = range([3,4]);

try
[ind,~,~]=find(axes3Lines == handles.lmax);
delete(axes3Lines(ind));
catch
    display('didnt find a handles.lmax');
end

handles.lmax = line([valsliderMax,valsliderMax],yRange,'color',[0 1 0])
drawnow;

%calcF(hObject,handles,f,a);
%calcR(hObject,handles,f,a);
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function sliderMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in updatebutton.
function updatebutton_Callback(hObject, eventdata, handles)
% hObject    handle to updatebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.axes3,'next','replace');
%plot(handles.axes3,1:10,[1:10].*[1:10]);
global currFile;
global currAppend;
f = currFile
j = currAppend


%calcF(hObject,handles,f,j);
%calcR(hObject,handles,f,j);
handles.compData= calcF(hObject,handles,f,j)
handles.compData= calcR(hObject,handles,f,j)
setParams(hObject, handles,f,j);
guidata(hObject,handles)

% --- This is my function for plotting to axes3
%%function plot2Axis3(hObject, handles,file,append)
function compData = plot2Axis3(handles)
% hObject   does nothing, this is my funciton
%handles    strucure with handles and my data
global plotflagVmu
global plotflag
global currFile
global currAppend

% set(gcbf,'UserData',1)
% guidata(hObject,handles)
% display(get(gcbf,'UserData'));


f = currFile
a = currAppend
eventdata = 1;

%--------------------------------------------------------
%---This can be used to generate the data to plot the points
%--------------------------------------------------------
try
paramPointsx(1) = handles.compData(f,a).pVMuF;
paramPointsy(1) = handles.compData(f,a).DrainIF(handles.compData(f,a).indpMuF);
catch
    paramPointsx(1) = 0;
    paramPointsy(1) = 0;
end
try
paramPointsx(2) = handles.compData(f,a).pVMuR;
paramPointsy(2) = handles.compData(f,a).DrainIR(handles.compData(f,a).indpMuR)
catch
    paramPointsx(2) = 0;
    paramPointsy(2) = 0;
end
try
paramPointsx(3) = handles.compData(f,a).nVMuF;
paramPointsy(3) = handles.compData(f,a).DrainIF(handles.compData(f,a).indnMuF);
catch
    paramPointsx(3) = 0;
    paramPointsy(3) = 0;
end
try
paramPointsx(4) = handles.compData(f,a).nVMuR;
paramPointsy(4) = handles.compData(f,a).DrainIR(handles.compData(f,a).indnMuR)
catch
    paramPointsx(4) = 0;
    paramPointsy(4) = 0;
end
%--------------------------------------------------------
%--------------------------------------------------------
axes(handles.axes3)
set(handles.axes3,'SortMethod','childorder');
if plotflagVmu
    plot(handles.axes3, [handles.compData(f,a).pVtF,paramPointsx(1)], [0, paramPointsy(1)],...
        [handles.compData(f,a).nVtF,paramPointsx(3)],[0, paramPointsy(3)],...
        [handles.compData(f,a).pVtR,paramPointsx(2)], [0, paramPointsy(2)],...
        [handles.compData(f,a).nVtR,paramPointsx(4)],[0, paramPointsy(4)],...
        handles.compData(f,a).GateV,handles.compData(f,a).(handles.plot3),...
        paramPointsx, paramPointsy, '.','MarkerSize',15);
else
    plot(handles.axes3, handles.compData(f,a).GateV,handles.compData(f,a).(handles.plot3),...
        paramPointsx, paramPointsy, '.','MarkerSize',15);
end
   set(handles.axes3,'Xlim',[min(handles.compData(f,a).GateV),max(handles.compData(f,a).GateV)]);
    
if plotflag
    currYlim = ylim;
    set(handles.axes3,'Ylim', [0.9*abs(min(handles.compData(f,a).(handles.plot3))),currYlim(2)]);
    set(handles.axes3,'YScale','log');
else
    set(handles.axes3,'YScale','lin');
end
drawnow;
% sliderMax_Callback(hObject, eventdata, handles)
%set the range for the sliders
range=axis();
xRange = range([1,2]);
yRange = range([3,4]);
set(handles.sliderMax,'Min',xRange(1));
set(handles.sliderMax,'Max',xRange(2));
set(handles.sliderMin,'Min',xRange(1));
set(handles.sliderMin,'Max',xRange(2));
currMaxSlide = get(handles.sliderMax,'Value');
currMinSlide = get(handles.sliderMin,'Value');

%Update value of slider to make sure it is in range.
nMin = max(xRange(1),currMinSlide); %Takes the larger of the min x-limit and the current value
nMax = min(xRange(2),currMaxSlide); %Takes the smaller of the max x-limit and the current value
set(handles.sliderMax,'Value',nMax);
set(handles.sliderMin,'Value',nMin);
set(handles.textMax,'String',num2str(nMax));%Sets the indicator values
set(handles.textMin,'String',num2str(nMin));%Sets the indicator values

%m and b correspond with slope and intercept
mpF = (0-paramPointsy(1))/(handles.compData(f,a).pVtF-paramPointsx(1))
mnF = (0-paramPointsy(3))/(handles.compData(f,a).nVtF-paramPointsx(3))
bpF = -handles.compData(f,a).pVtF*mpF
bnF = -handles.compData(f,a).nVtF*mnF
cnp2F = (bnF - bpF)/(mpF - mnF)  %Charge neutrality point based on intersect of p and n branch fits FORWARD
idcnp2F = cnp2F*mpF + bpF         % current at the charge neutrality point, use this to get sigma res.
idcnp2F2 = cnp2F*mnF + bnF         %testing to make sure its the same.

mpR = (0-paramPointsy(2))/(handles.compData(f,a).pVtR-paramPointsx(2))
mnR = (0-paramPointsy(4))/(handles.compData(f,a).nVtR-paramPointsx(4))

bpR = -handles.compData(f,a).pVtR*mpR
bnR = -handles.compData(f,a).nVtR*mnR
cnp2R = (bnR - bpR)/(mpR - mnR)  %Charge neutrality point based on intersect of p and n branch fits REVERSE
idcnp2R = cnp2R*mpR + bpR         % current at the charge neutrality point, use this to get sigma res.
idcnp2R2 = cnp2R*mnR + bnR         %testing to make sure its the same.

handles.compData(f,a).cnp2F = cnp2F     %Forward CNP
handles.compData(f,a).cnp2R = cnp2R     %Reverse CNP
handles.compData(f,a).idcnp2F = idcnp2F %Forward drain current at CNP2
handles.compData(f,a).idcnp2R = idcnp2R %Reverse drain current at CNP2
handles.compData(f,a).sigmaResF = idcnp2F*handles.compData(f,a).L/(handles.compData(f,a).DrainV(1)*handles.compData(f,a).W)*25812.8046 %Forward minimum conductivity @CNP2
handles.compData(f,a).sigmaResR = idcnp2R*handles.compData(f,a).L/(handles.compData(f,a).DrainV(1)*handles.compData(f,a).W)*25812.8046 %Reverse minimum conductivity @CNP2

handles.compData(f,a).sigmaMinF = handles.compData(f,a).qintIdMinF*handles.compData(f,a).L/(handles.compData(f,a).DrainV(1)*handles.compData(f,a).W)*25812.8046 %Forward minimum conductivity @CNP2
handles.compData(f,a).sigmaMinR = handles.compData(f,a).qintIdMinR*handles.compData(f,a).L/(handles.compData(f,a).DrainV(1)*handles.compData(f,a).W)*25812.8046 %Reverse minimum conductivity @CNP2

display(handles.compData(f,a).sigmaResF);
display(handles.compData(f,a).sigmaResR);
% set(gcbf,'UserData',0)
%guidata(hObject,handles)
%isfield(handles.compData,'sigmaResR')
compData = handles.compData;

%--------------------------------------------------------
%--------------------------------------------------------
%--------------------------------------------------------
function compData=calcF(hObject,handles,f,j)
compData = handles.compData;
calcData = handles.calcData;
maxVg = get(handles.sliderMax,'Value');
minVg = get(handles.sliderMin,'Value');
[indmaxVg,~,~] = find(compData(f,j).GateVF >= maxVg,1);
[indminVg,~,~] = find(compData(f,j).GateVF < minVg,1,'last');

        [compData(f,j).IdMinF,indMinF] = min(abs(compData(f,j).DrainIF));
        compData(f,j).indMinF = indMinF; 
        %make sure min isn't at last or first point
        if indMinF<length(compData(f,j).DrainIF) & indMinF>1 
            scale = compData(f,j).GateVF(2)-compData(f,j).GateVF(1);
            %This fits the area near zero with a quadradic function and
            %gets the min voltage (qintcnp) and current qintIdminF
            [p, compData(f,j).qintIdMinF,~] = qint(compData(f,j).DrainIF(indMinF-1),compData(f,j).DrainIF(indMinF),compData(f,j).DrainIF(indMinF+1),scale,0);
            %this is needed to shift the p to the minvalue that was assumed
            %to be x=0.  
            compData(f,j).qintcnpF= p + compData(f,j).GateVF(indMinF);
        end  
        compData(f,j).cnpF = compData(f,j).GateVF(indMinF);
        if compData(f,j).cnpF > compData(f,j).GateVF(indminVg) %Make sure there is a p-branch
            compData(f,j).pIdMaxF = max(abs(compData(f,j).DrainIF([1:indMinF])));
            [maxGMpF, indpMuF] = max(abs(compData(f,j).GMF([indminVg:indMinF]))); %#ok<*AGROW>
            compData(f,j).pMuF = maxGMpF*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
            compData(f,j).CAP = 8.854e-14*calcData{f}.epsr(j)/(calcData{f}.tox(j)*1e-7);
            compData(f,j).indpMuF = indpMuF+indminVg-1;
            compData(f,j).pVMuF = compData(f,j).GateVF(indpMuF+indminVg-1);
            compData(f,j).pVtF = -compData(f,j).DrainIF(indpMuF+indminVg-1)/-maxGMpF + compData(f,j).GateVF(indpMuF+indminVg-1);
            compData(f,j).pOnOffF = compData(f,j).pIdMaxF / compData(f,j).IdMinF;
            noP = 10;
        else
            compData(f,j).pIdMaxF = 0;
            compData(f,j).pMuF = 0;
            compData(f,j).pVtF = 0;
            compData(f,j).pOnOffF = 0;
            noP = 1;
        end
        if compData(f,j).cnpF < maxVg %Make sure there is a n-branch
            compData(f,j).nIdMaxF = max(abs(compData(f,j).DrainIF([indMinF:end])));
            [maxGMnF, indnMuF] = max(abs(compData(f,j).GMF([indMinF:indmaxVg])));
            compData(f,j).nMuF = maxGMnF*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
                     
            compData(f,j).indnMuF = indMinF+indnMuF-1; %The minus one is needed because the min becomes index 1 in the new series but it could be last value in sweep.
            compData(f,j).nVMuF = compData(f,j).GateVF(indnMuF+indMinF-1);
            
            compData(f,j).nVtF = -compData(f,j).DrainIF(indnMuF+indMinF-1)/maxGMnF + compData(f,j).GateVF(indnMuF+indMinF-1);
            compData(f,j).nOnOffF = compData(f,j).nIdMaxF / compData(f,j).IdMinF;
            noN = 0;
        else
            compData(f,j).nIdMaxF = 0;
            compData(f,j).nMuF = 0;
            compData(f,j).nVtF = 0;
            compData(f,j).nOnOffF = 0;
            noN = 1;
        end
% handles.compData=compData;
% handles.calcData=calcData;
% guidata(hObject, handles);
%plot2Axis3(hObject,handles);
%drawnow;
        
        % Calculate the reverse mobilty values
function compData=calcR(hObject,handles,f,j)
compData = handles.compData;
calcData = handles.calcData;
maxVg = get(handles.sliderMax,'Value');
minVg = get(handles.sliderMin,'Value');

[indmaxVg,~,~] = find(compData(f,j).GateVR > maxVg,1);
[indminVg,~,~] = find(compData(f,j).GateVR < minVg,1,'last');
[compData(f,j).IdMinR,indMinR] = min(abs(compData(f,j).DrainIR));
compData(f,j).indMinR = indMinR;
compData(f,j).cnpR = compData(f,j).GateVR(indMinR);
if compData(f,j).cnpR >compData(f,j).GateVR(indminVg) %Make sure there is a p-branch
    compData(f,j).pIdMaxR = max(abs(compData(f,j).DrainIR([1:indMinR])));
    [maxGMpR, indpMuR] = max(abs(compData(f,j).GMR([indminVg:indMinR]))); %#ok<*AGROW>
    compData(f,j).pMuR = maxGMpR*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
    compData(f,j).indpMuR = indpMuR+indminVg-1;
    compData(f,j).pVMuR = compData(f,j).GateVR(indpMuR+indminVg-1);
    compData(f,j).pVtR = -compData(f,j).DrainIR(indpMuR+indminVg-1)/-maxGMpR + compData(f,j).GateVR(indpMuR+indminVg-1);
    compData(f,j).pOnOffR = compData(f,j).pIdMaxR / compData(f,j).IdMinR;
    noP = 0;
    compData(f,j).hystp = compData(f,j).pVMuR - compData(f,j).pVMuF;
else
    compData(f,j).pIdMaxR = 0;
    compData(f,j).pMuR = 0;
    compData(f,j).pVtR = 0;
    compData(f,j).pOnOffR = 0;
    noP = 1;
    compData(f,j).hystp = 0;
end
if compData(f,j).cnpR < compData(f,j).GateVR(indmaxVg) %Make sure there is a n-branch
    compData(f,j).nIdMaxR = max(abs(compData(f,j).DrainIR([indMinR:end])));
    [maxGMnR, indnMuR] = max(abs(compData(f,j).GMR([indMinR:indmaxVg])));
    compData(f,j).nMuR = maxGMnR*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
    compData(f,j).indnMuR = indnMuR+indMinR-1; %Again, -1 needed because the indnMuR and indMinR could be same point but since indexes start at 1 they would be off by 1. Same as n-branch above
    compData(f,j).nVMuR = compData(f,j).GateVR(indnMuR+indMinR-1);
    compData(f,j).nVtR = -compData(f,j).DrainIR(indnMuR+indMinR-1)/maxGMnR + compData(f,j).GateVR(indnMuR+indMinR-1);
    compData(f,j).nOnOffR = compData(f,j).nIdMaxR / compData(f,j).IdMinR;
    noN = 0;
    if isfield(compData,'nVMuF')% This is to account for there being a n branch on reverse but not foward sweep.
        compData(f,j).hystn = compData(f,j).nVMuR - compData(f,j).nVMuF;
    else
        compData(f,j).nVMuF = max(compData(f,j).GateVR);
        compData(f,j).hystn = compData(f,j).nVMuR - compData(f,j).nVMuF;
    end
else
    compData(f,j).nIdMaxR = 0;
    compData(f,j).nMuR = 0;
    compData(f,j).nVtR = 0;
    compData(f,j).nOnOffR = 0;
    noN = 1;
    compData(f,j).hystn = 0;
end
% handles.compData=compData;
% handles.calcData=calcData;
% guidata(hObject, handles);
%plot2Axis3(hObject,handles);
%drawnow;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function LoadFilesButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LoadFilesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
