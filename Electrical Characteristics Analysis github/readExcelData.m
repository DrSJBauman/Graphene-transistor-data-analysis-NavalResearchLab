function [calcData,compData] =  readExcelData(varargin)

% Imports data from the specified file xls file
% currfile:  file to read
% Variable       Type    Usage
% calcData{f}       Struct  Holds all of the raw data from Calc Sheet with fields named the same as the first row in raw
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
else
    pathname = varargin{1};
    tempfilename = varargin{2};
end
numProcess = 100;
if nargin == 3
    numProcess = varargin{3};
end
if iscell(tempfilename) == 0 %if multiselect is off, no looping
    numloop = 1;
else
    numloop = length(tempfilename); %else loop through number of names
end
%% Compile Data from multiple files and sheets, f loops over files
for f = 1:numloop
    
    %get the name of the file in the current loop
    if numloop == 1
        filename = tempfilename;
    else
        filename = tempfilename{f};
    end
    
    
    % append filename to the path
    currfile = [pathname filename];
    
    % Get the names of all the sheets
    [~,sheets,~]=xlsfinfo(currfile);
    
    %% Get data from the Calc Sheet:
    % Calling the readCalcSheet function
    calcData{f}=readCalcSheet(currfile);
    %% Get data from all sheets
    %Remove the 'calc' and 'settings' sheets since they don't have data to
    %extract
    if length(sheets) > 3
        sheets2= [sheets(1) sheets(4:end)];
    else
        sheets2 = sheets(1);
    end
    %% loop over all - Data and Append sheets
    numLoop = min(length(sheets2),numProcess);%This lets me process only a few sheets
    for j = 1:numLoop
        %clear out data from previous sheet
        clear numbers;% = [];
        clear strings;% = [];
        clear raw ;%= [];
        clear currData;
        clear GMRtemp;
        clear GMFtemp;
        e= 1.602176565e-19; 
        %read in data from current sheet
        display(filename);
        display(sheets2{j});
        [numbers, strings, raw] = xlsread(currfile, sheets2{j});
        if exist('numbers') %#ok<EXIST>
            if ~isempty(numbers)
                currData.data =  numbers;
            else
                display(['No Data in ' currfile ' sheet ' sheets2{j}]);
                continue
            end
        end
        %put the strings in this structure for now if exist
        if ~isempty(strings) && ~isempty(numbers)
            [strRows, strCols] = size(strings);
            [numRows, numCols] = size(numbers);
            %likelyRow is the row bewfore the data begins and is likely the header
            likelyRow = size(raw,1) - numRows;
            
            %store the col headers so a new structure with one field per
            % column can be created.  The elseif is needed becaouse some of
            % the sheets think the column headers are numbers and screws it
            % up!
            if strCols == numCols && likelyRow > 0 && strRows >= likelyRow
                currData.colheaders = strings(likelyRow, :);
            else
                currData.colheaders = strings(1, :);
                numbers = numbers(2:end,:);
                currData.data = numbers;
            end
        end
        % Create new variables in the base workspace from those fields.
        compData(f,j).sheet = sheets2{j}; %Keep the sheet name with each (f,j) pair.
        compData(f,j).file = filename; %Keep the file name with each (f,j) pair - this is redundant with the calcData{f}.file.
        calcFieldNames = fields(calcData{f});
        for i = 1:size(calcFieldNames,1)
            %                 display([f j i])
            %                 size(calcFieldNames)
            %                 calcFieldNames{i}
            %                 size(calcData{f}.(calcFieldNames{i}))
            compData(f,j).(calcFieldNames{i}) = calcData{f}.(calcFieldNames{i})(j);
        end
        
        try
            currData.data;
        catch %#ok<CTCH>
           display('currData.data results in an error in readExcelData.m line 111 cdc.');
        end
        
        for i = 1:size(currData.data,2)
            %%% varnames{i} = genvarname(currData.colheaders{i}); This
            %%% generates variable names but not necessary because the '.()
            %%% syntax does the same thing.
            try
            compData(f,j).(currData.colheaders{i}) = currData.data(:,i);
            catch %#ok<CTCH>
                display('compData(f,j).(currData.colheaders{i}) = currData.data(:,i); results in a error in readExcelData.m line 121 cdc.');
            end
        end
        
        %If its a dual sweep put forward in compData().GateVF and compData().Reverse in GateVR
        %same thing for the DrainI.
        [~,~,dual] = find(compData(f,j).GateV==compData(f,j).GateV(1));
        if sum(dual) == 2
            compData(f,j).Dual = 1;
            len = length(compData(f,j).GateV);
            GateV = compData(f,j).GateV;
            DrainI = compData(f,j).DrainI;
            GM = compData(f,j).GM;
            compData(f,j).DrainIF = DrainI(1:len/2);
            compData(f,j).GateVF = GateV(1:len/2);
            compData(f,j).GMF = GM(1:len/2);
            %Reverse Sweep Info;
            compData(f,j).GateVR = GateV(len/2+1:end);
            compData(f,j).GateVR = flipdim(compData(f,j).GateVR,1); 
            compData(f,j).GMR = GM(len/2+1:end);
            compData(f,j).GMR = flipdim(compData(f,j).GMR,1);
            compData(f,j).DrainIR = DrainI(len/2+1:end);
            compData(f,j).DrainIR = flipdim(compData(f,j).DrainIR,1);
            
        else %Otherwise, put the drain/gate/GM in the forward varible only
            compData(f,j).Dual = 0;
            compData(f,j).DrainIF = compData(f,j).DrainI;
            compData(f,j).GateVF = compData(f,j).GateV;
            GM = compData(f,j).GM; 
            compData(f,j).GMF =  compData(f,j).GM;    
        end
        
        % smooths data by relaxation
% % % % % %         drainFtemp = compData(f,j).DrainIF;
% % % % % %         if sum(dual)==2
% % % % % %             drainRtemp = compData(f,j).DrainIR;
% % % % % %         end
% % % % % %         for a=1:15
% % % % % %             for b=2:length(compData(f,j).DrainIF)-1
% % % % % %                 drainFtemp(b) = (compData(f,j).DrainIF(b-1) + compData(f,j).DrainIF(b) + compData(f,j).DrainIF(b+1))/3;
% % % % % %             end
% % % % % %             if sum(dual)==2
% % % % % %                 for c=2:length(compData(f,j).DrainIR)-1
% % % % % %                     drainRtemp(c) = (compData(f,j).DrainIR(c-1) + compData(f,j).DrainIR(c) + compData(f,j).DrainIR(c+1))/3;
% % % % % %                 end
% % % % % %                 compData(f,j).DrainIR = drainRtemp;
% % % % % %             end
% % % % % %             compData(f,j).DrainIF = drainFtemp;            
% % % % % %         end
% % % % % %         %calculates new GMF
% % % % % %         for b=2:length(compData(f,j).DrainIF)
% % % % % %             
% % % % % %             GMFtemp(b) = (compData(f,j).DrainIF(b) - compData(f,j).DrainIF(b-1))/(compData(f,j).GateVF(b) - compData(f,j).GateVF(b-1));
% % % % % %             
% % % % % %         end
% % % % % %         display(length(GMFtemp));
% % % % % %         compData(f,j).GMF = GMFtemp;
% % % % % %         
% % % % % %         if sum(dual)==2
% % % % % %             for c=2:length(compData(f,j).DrainIR)
% % % % % %                 
% % % % % %                 GMRtemp(c) = (compData(f,j).DrainIR(c) - compData(f,j).DrainIR(c-1))/(compData(f,j).GateVR(c) - compData(f,j).GateVR(c-1));
% % % % % %                 
% % % % % %             end
% % % % % %             compData(f,j).GMR = GMRtemp;
% % % % % %         end
        
%% Start to calc Forward Sweep Parameters
compData= calcF(compData,calcData,f,j);
%% Start to calc Reverse Sweep Parameters
if compData(f,j).Dual % Reverse sweep values
    compData = calcR(compData,calcData,f,j);
end
    end
end
%put the new variables in the base workspace
%  assignin('base','calcDataA', calcData);
%  assignin('base','compDataA', compData);
end
%% Calculate the mobility values
function [compData]= calcF(compData,calcData,f,j)
        e= 1.602176565e-19;
        [compData(f,j).IdMinF,indMinF] = min(abs(compData(f,j).DrainIF));
        compData(f,j).indMinF = indMinF; 
        %make sure min isn't at last or first point
        if indMinF<length(compData(f,j).DrainIF) && indMinF>1 
            scale = compData(f,j).GateVF(2)-compData(f,j).GateVF(1);
            %This fits the area near zero with a quadradic function and
            %gets the min voltage (qintcnp) and current qintIdminF
            [v0, compData(f,j).qintIdMinF,~] = qint(compData(f,j).DrainIF(indMinF-1),compData(f,j).DrainIF(indMinF),compData(f,j).DrainIF(indMinF+1),scale,0);
            %this is needed to shift the v0 to the minvalue that was assumed
            %to be x=0.  
            compData(f,j).qintcnpF= v0 + compData(f,j).GateVF(indMinF); 
            %I'm using qintcnp now as my true dirac point 12-31-2011; 
            %not sure if this is output in FETAnalysisv4 but it will be in FETAnalysisv5beta 
            vgminF = compData(f,j).qintcnpF;
        end  
        compData(f,j).cnpF = compData(f,j).GateVF(indMinF); %%%!!!I Added "&& length(compData(f,j).DrainIF)>33" on 6-27-17 NOTES
        if compData(f,j).cnpF > min(compData(f,j).GateVF) && length(compData(f,j).DrainIF)>33  %Make sure there is a p-branch
            compData(f,j).pIdMaxF = max(abs(compData(f,j).DrainIF(1:indMinF)));%I removed [] from [1:indMinF]
            [maxGMpF, indpMuF] = max(abs(compData(f,j).GMF(1:indMinF))); %#ok<*AGROW>
            compData(f,j).pMuF = maxGMpF*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
            compData(f,j).CAP = 8.854e-14*calcData{f}.epsr(j)/(calcData{f}.tox(j)*1e-7);
            cap = compData(f,j).CAP; 
            compData(f,j).indpMuF = indpMuF;
            compData(f,j).pVMuF = compData(f,j).GateVF(indpMuF);
            compData(f,j).pVtF = -compData(f,j).DrainIF(indpMuF)/-maxGMpF + compData(f,j).GateVF(indpMuF);
            compData(f,j).pOnOffF = compData(f,j).pIdMaxF / compData(f,j).IdMinF;
            compData(f,j).pnF = cap*(compData(f,j).GateVF-vgminF)/e;
            compData(f,j).pF = cap*(compData(f,j).GateVF(1:indMinF)-vgminF)/e; %This is carrier concentrations; This is an array!!
            noP = 0; 
        else
            compData(f,j).pIdMaxF = 0;
            compData(f,j).pMuF = 0;
            compData(f,j).pVtF = 0;
            compData(f,j).pOnOffF = 0;
            noP = 1; 
        end
        if compData(f,j).cnpF < max(compData(f,j).GateVF) %Make sure there is a n-branch
            compData(f,j).nIdMaxF = max(abs(compData(f,j).DrainIF(indMinF:end)));
            [maxGMnF, indnMuF] = max(abs(compData(f,j).GMF(indMinF:end)));
            compData(f,j).nMuF = maxGMnF*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
                     
            compData(f,j).indnMuF = indMinF+indnMuF-1; %The minus one is needed because the min becomes index 1 in the new series but it could be last value in sweep.
            compData(f,j).nVMuF = compData(f,j).GateVF(indnMuF+indMinF-1);
            
            compData(f,j).nVtF = -compData(f,j).DrainIF(indnMuF+indMinF-1)/maxGMnF + compData(f,j).GateVF(indnMuF+indMinF-1);
            compData(f,j).nOnOffF = compData(f,j).nIdMaxF / compData(f,j).IdMinF;
            compData(f,j).nF = cap*(compData(f,j).GateVF(indMinF:end)-vgminF)/e; %This is electron carrier concentrations; This is an array!!
            noN = 0; %#ok<*NASGU>
        else
            compData(f,j).nIdMaxF = 0;
            compData(f,j).nMuF = 0;
            compData(f,j).nVtF = 0;
            compData(f,j).nOnOffF = 0;
            noN = 1;
        end
end

%% Calculate the reverse mobilty values
    function [compData]= calcR(compData,calcData,f,j)
    e= 1.602176565e-19;
    cap = compData(f,j).CAP; 
    [compData(f,j).IdMinR,indMinR] = min(abs(compData(f,j).DrainIR));
            compData(f,j).indMinR = indMinR;
            %make sure min isn't at last or first point
            if indMinR<length(compData(f,j).DrainIR) && indMinR>1
                scale = compData(f,j).GateVR(2)-compData(f,j).GateVR(1);
                %This fits the area near zero with a quadradic function and
                %gets the min voltage (qintcnp) and current qintIdminF
                [v0, compData(f,j).qintIdMinR,~] = qint(compData(f,j).DrainIR(indMinR-1),compData(f,j).DrainIR(indMinR),compData(f,j).DrainIR(indMinR+1),scale,0);
                %this is needed to shift the v0 to the minvalue that was assumed
                %to be x=0.
                compData(f,j).qintcnpR= v0 + compData(f,j).GateVR(indMinR);
                vgminR = compData(f,j).qintcnpR;
            end
            compData(f,j).cnpR = compData(f,j).GateVR(indMinR);
            if compData(f,j).cnpR > min(compData(f,j).GateVR) %Make sure there is a p-branch
                compData(f,j).pIdMaxR = max(abs(compData(f,j).DrainIR(1:indMinR)));
                [maxGMpR, indpMuR] = max(abs(compData(f,j).GMR(1:indMinR))); %#ok<*AGROW>
                compData(f,j).pMuR = maxGMpR*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
                compData(f,j).indpMuR = indpMuR;
                compData(f,j).pVMuR = compData(f,j).GateVR(indpMuR);
                compData(f,j).pVtR = -compData(f,j).DrainIR(indpMuR)/-maxGMpR + compData(f,j).GateVR(indpMuR);
                compData(f,j).pOnOffR = compData(f,j).pIdMaxR / compData(f,j).IdMinR;
                noP = 0;
                compData(f,j).hystp = compData(f,j).pVMuR - compData(f,j).pVMuF;
                compData(f,j).pnR = cap*(compData(f,j).GateVR-vgminR)/e;
                temp = flipdim(compData(f,j).pnR,1);
                compData(f,j).pn = [compData(f,j).pnF; temp];%This won't work unless there is a p-branch UPDATE
                compData(f,j).pR = cap*(compData(f,j).GateVR(1:indMinR)-vgminR)/e; %This is carrier concentrations; This is an array!!
            else
                compData(f,j).pIdMaxR = 0;
                compData(f,j).pMuR = 0;
                compData(f,j).pVtR = 0;
                compData(f,j).pOnOffR = 0;
                noP = 1;
                compData(f,j).hystp = 0;
            end
            if compData(f,j).cnpR < max(compData(f,j).GateVR) %Make sure there is a n-branch
                compData(f,j).nIdMaxR = max(abs(compData(f,j).DrainIR(indMinR:end)));
                [maxGMnR, indnMuR] = max(abs(compData(f,j).GMR(indMinR:end)));
                compData(f,j).nMuR = maxGMnR*(calcData{f}.L(j)/calcData{f}.W(j))*(calcData{f}.tox(j)*1e-7/(compData(f,j).DrainV(1)*8.854e-14*calcData{f}.epsr(j)));
                compData(f,j).indnMuR = indnMuR+indMinR-1; %Again, -1 needed because the indnMuR and indMinR could be same point but since indexes start at 1 they would be off by 1. Same as n-branch above
                compData(f,j).nVMuR = compData(f,j).GateVR(indnMuR+indMinR-1);
                compData(f,j).nVtR = -compData(f,j).DrainIR(indnMuR+indMinR-1)/maxGMnR + compData(f,j).GateVR(indnMuR+indMinR-1);
                compData(f,j).nOnOffR = compData(f,j).nIdMaxR / compData(f,j).IdMinR;
                noN = 0;
                compData(f,j).nR = cap*(compData(f,j).GateVR(indMinR:end)-vgminR)/e; %This is electron carrier concentrations; This is an array!!
                
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
            
    end

