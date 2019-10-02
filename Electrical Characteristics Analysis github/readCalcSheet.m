function calcData =  readCalcSheet(varargin)
%createVariablesfromExcel(currfile)
% Imports data from the specified file xls file
% varargin - if it has a data file it uses it as the first one.
% Variable       Type    Usage
% calcData(f)       Struct  Holds all of the raw data from Calc Sheet with fields named the same as the first row in raw
% currData       Struct  Holds number, strings, and raw data from excel sheet
% compData(f,j)  Struct  Holds data for all sheets separted into fields that correspond with the column headers
%                        every row (f) in compData is a different file while every

%% Choose Files
if nargin == 0
    directory = '/Users/corycress/Documents/Research/Projects/Graphene/Thin SiO2/CCi120 and C2R28/';
    [pathname tempfilename] = Choosefiles(directory); % Allows user to select multiple files
    if isempty(tempfilename) == 1
        %     export = 'Program Aborted';
        return
    end
    if iscell(tempfilename) == 0 %if multiselect is off, no looping
        numloop = 0;
        
    else
        numloop = 1;%length(tempfilename); %else loop through number of names
    end
else
    numloop = 2; % This means the data filename was passed into the function and don't need to get it
    currfile = varargin{1};
    display(currfile);
end


display(numloop);
%% Compile Data from first file name if a cell array was passed
if numloop == 0
    filename = tempfilename;
    currfile = [pathname filename];
elseif numloop == 1
    filename = tempfilename{1};
    currfile = [pathname filename];
end
% append filename to the path


% Get the names of all the sheets
[types,sheets]=xlsfinfo(currfile);

%% Get data from the Calc Sheet:
% Not doing anything with the header rows indicated by a #.
[numbers, strings, raw] = xlsread(currfile, 'Calc','a1:xx100', 'basic');

[R C] = size(raw);
ind = 1;
for c = 1:C
    numNANs = 0;
    for r = 1:R
        if ~isstr(raw{r,c})
            numNANs = isnan(raw{r,c})+numNANs;% this only adds nan if they are present
        else
            currstr = sscanf(raw{r,c},'%1s',1);
            if strcmp('#',currstr)
                headerRow = r+1;
            end
        end
    end
    if numNANs == R
        removeCols(ind) = c;
        ind = ind+1;
    end
end
keepCols =1:C;
if exist('removeCols');
    keepCols(keepCols(removeCols)) = [];
end
%removed columns with all NANs and remove rows that do not correspond with
%the number of sheets + 1 (the additional one is for the header).
raw =  raw(headerRow:(length(sheets)+1),keepCols);
%removing all non-number data (basically just the heading and 1 line
%headers

if isnumeric(numbers(1,1)) && size(numbers,1)>=(length(sheets)-2)&& ~isnan(numbers(1,2))
    numbers = numbers(1:(length(sheets)-2),:);% If its numberic, get numbers corresponding withs sheets removing the "Calc" and "Settings" sheets
    strings = strings(1:(length(sheets)-2),keepCols);
elseif isnumeric(numbers(1,1)) && size(numbers,1)<(length(sheets)-2)
    numbers = numbers(1:size(numbers,1),:);
    strings = strings(1:size(strings,1),keepCols);
else
    numbers = numbers(headerRow+1:(length(sheets)+1),:);
    strings = strings(headerRow+1:(length(sheets)+1),keepCols);
end
indstr = 1;
indnum = 1;

%determine the string and number column headers
for ss = 1:size(strings,2)
    if isstr(raw{2,ss})|| isnan(raw{2,ss}) %Is a string or column with NAN
        currCalc.strheaders{indstr} = raw{1,ss};
        strCol(indstr) = ss; 
        indstr = indstr +1;
    else
        currCalc.numheaders{indnum} = raw{1,ss};
        indnum = indnum +1;
    end
end

%make the first row of strings the column headers
% % % if ~isempty(strings) && ~isempty(numbers)
% % %     currCalc.colheaders = raw(1,:);
% % % end
% % % % % % % % % calcData = cell2struct(raw(2:end,:),raw(1,:),2);

% Create new structure with fields corresponding to the variables /
% colheaders from calc sheet
% numbers has the data stored as doubles so I'm using the () notation.
% strings has the
for i = 1:size(currCalc.numheaders,2)
    calcData.(currCalc.numheaders{i}) = numbers(:,i);
end
for i = 1:size(currCalc.strheaders,2)
    calcData.(currCalc.strheaders{i}) = strings(:,strCol(i))
end


%there are here so there aren't errors in the data calc later and to allow
%them to be manually inserted later. I mulitply times 
if ~isfield(calcData, 'W')
    calcData.W = numbers(:,1)*0+1000;
end
if ~isfield(calcData, 'L')
    calcData.L = numbers(:,1)*0+1000;
end
if ~isfield(calcData, 'tox')
    calcData.tox = numbers(:,1)*0+250e-7;
end 
if ~isfield(calcData, 'epsr')
    calcData.epsr = numbers(:,1)*0+3.9;
end 


%assignin('base','calcData',calcData);
return

