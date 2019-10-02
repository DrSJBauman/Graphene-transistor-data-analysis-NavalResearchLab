function [pathname filename] = Choosefiles(directory)


if isempty(directory) == 1
    directory = [cd, '\'];
    disp('A directory location has been assigned')
end

[filename, pathname] = uigetfile( ...
    { '*.*',  'All Files (*.*)';...
    '*.xls*',  'Excel Files (.xls)';...
    '*.xyz*',  'Tubegen (.xyz)';...
    '*.txt*',  'Text Files (.txt)';...
    '*.m;*.fig;*.mat;*.mdl','MATLAB Files (*.m,*.fig,*.mat,*.mdl)';
    '*.m',  'M-files (*.m)'; ...
    '*.fig','Figures (*.fig)'; ...
    '*.mat','MAT-files (*.mat)'; ...
    '*.mdl','Models (*.mdl)'}, ...
    'Pick a file', directory,...
    'MultiSelect', 'on');


if isequal(filename,0)
   disp('User selected Cancel');
   filename = []; % Set filename to empty brackets so in he program where
%    this function is used I can do a ismpty(filename) == 1; return so the 
%    program stops if user selects the cancel load file
else
   disp(['User selected Files']);
end

end