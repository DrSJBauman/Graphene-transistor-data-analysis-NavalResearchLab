%% PeakFitSJB ***********************************
% This code takes Raman spectrum .txt file(s) as an input, attempts to fit
% the four graphene peaks, and outputs the peak location, height, width,
% and area as well as height and area ratios (D/G, D/D', D/2D) to .txt 
% file(s) with names matching the opened file(s).

clear all
clf
clc

%% Opening files ********************

% Defining the directory in which to look for files:
directory = 'C:\Users\sbauman\Desktop\SJBauman\Raman\Graphene FETs Point Spectra'
%directory = 'C:\Users\sbauman\Desktop\SJBauman\Raman\Graphene FETs Point Spectra\CCH54B 100eV\Reticle 13.09'

% Choosefiles opens the dialog window for the user to select spectrum files
% to import from the reticle folder.
[pathname tempfilename] = Choosefiles(directory);

% Checks if more than one file has been selected and defines variable ind_length
% as the marker for this
if iscell(tempfilename)
    ind_length = size(tempfilename,2);
else
    ind_length = 1;
end

%% Setting variables to correctly name the outputs by sample and reticle
pathsegments = cell(1,7);
filesegments = cell(ind_length,4);
i = 0;

% Chops up the pathname at every '\' and stores the segments in cell array
remain = pathname;
while 0 == strcmp(remain,'')
    [token,remain] = strtok((remain), '\');
    i = i + 1;
    pathsegments{i} = token; 
end

%% For all of the opened .txt files, load and process the data **********

% Preallocate memory
FitResults = cell(5, ind_length);
FitError = cell(4, ind_length);
RatiosMat = cell(1, ind_length);
Ratios = cell(1, ind_length);
Outputs = cell(1, ind_length);
deads = 0;
DeadDevices = cell(1);

%% Loop through the number of selected files ***************************
for ind = 1:ind_length 
    % *************************************
    % Try-Catch does tries the first line and if an error is thrown, skips to 
    % the catch line without stopping the code. This is used often in this
    % code because if a single file is loaded, tempfilename is considered a
    % char, but if multiple files are loaded, tempfilename is a cell array.
    % *************************************
    try
        spectrum = load([pathname tempfilename{ind}]); % Works if multiple files are selected
    catch
        spectrum = load([pathname tempfilename]); % Needed if only one file is selected
    end
    
    %% All of this is just to find strings to assign names of files/columns
    % Trying to scan for "eV" and use that to grab the energy value.
    % "Sample" contains the sample name and energy if this works.
    try
        samplepath = find(cellfun('length',regexp(pathsegments,'eV')) == 1);
        Sample = pathsegments{samplepath};
        try
            i = 0;
            remain = tempfilename{ind};
            while 0 == strcmp(remain,'')
                [token,remain] = strtok((remain));
                i = i + 1;
                filesegments{ind,i} = token;
            end
        catch
            i = 0;
            remain = tempfilename;
            while 0 == strcmp(remain,'')
                [token,remain] = strtok((remain));
                i = i + 1;
                filesegments{ind,i} = token; 
            end
        end    
        Reticle = filesegments{ind,2};
        Device = filesegments{ind,3};
    % Otherwise, just use the sample name from tempfilename (no energy value)
    catch
        try
            i = 0;
            remain = tempfilename{1};
            while 0 == strcmp(remain,'')
                [token,remain] = strtok((remain));
                i = i + 1;
                filesegments{ind,i} = token;
            end
        catch
            i = 0;
            remain = tempfilename;
            while 0 == strcmp(remain,'')
                [token,remain] = strtok((remain));
                i = i + 1;
                filesegments{ind,i} = token; 
            end
        end
        Sample = filesegments{ind,1};
        Reticle = filesegments{ind,2};
        Device = filesegments{ind,3};
    end
    
    % Add the ion energy to the tempfilename
    try
        tempfilename{ind} = [Device];
    catch
        tempfilename = [Device];
    end

    %% peakfit.m does the heavy lifting for us. *****************
    
    % peakfit(signal,center,window,NumPeaks,peakshape,extra, NumTrials, start, autozero, fixedparameters, plots, bipolar, minwidth, DELTA)
    % FitResults columns are (1)Peak Number, (2)Peak Position, (3)Height (4)Width, (5)Area
    % FitResults rows are (1) D, (2) G, (3) D`, (4) 2D
    
    % Fitting the peaks in three smaller ranges to get better fits for each
    f1 = figure(1);
    [FitResults{2,ind},FitError{2,ind},A,B,C,D,E]= peakfit(spectrum, 1350, 200, 1, 13, 4, 40, [1340 50], 1);
    title([Sample ' ' Reticle ' ' Device ' ' 'D Peak']);
    saveas(f1,['C:\Users\sbauman\Documents\MATLAB\Raman Peak Analysis\Outputs\' Sample ' ' Reticle ' ' Device ' ' 'D Peak' '.fig']);
    f2 = figure(2);
    [FitResults{3,ind},FitError{3,ind}]= peakfit(spectrum, 1600, 200, 2, [13 2], [4 0], 40, [1580 30 1624 30], 1);
    title([Sample ' ' Reticle ' ' Device ' ' 'G and D` Peaks']);
    saveas(f2,['C:\Users\sbauman\Documents\MATLAB\Raman Peak Analysis\Outputs\' Sample ' ' Reticle ' ' Device ' ' 'G and D` Peaks' '.fig']);
    f3 = figure(3);
    [FitResults{4,ind},FitError{4,ind}]= peakfit(spectrum, 2670, 400, 1, 13, 4, 40, [2670 100], 1);
    title([Sample ' ' Reticle ' ' Device ' ' '2D Peak']);
    saveas(f3,['C:\Users\sbauman\Documents\MATLAB\Raman Peak Analysis\Outputs\' Sample ' ' Reticle ' ' Device ' ' '2D Peak' '.fig']);
    
    f4 = figure(4);
    [FitResults{5,ind},FitError{5,ind}]= peakfit(spectrum, 1475, 400, 2, [13 13 2], [4 4 0], 40, [1340 50 1580 30 1624 30], 2);
    
    %***********************************
    % All of the code between asterisks is part of an attempt to
    % make the script combine the peakfit figure outputs into a single
    % figure with subplots. I wasn't able to get this working very well.
         
%     fh = figure(4);
% 
%     for i = 1:6
%         subplot(2,3,i)
%         P{i} = get(gca,'pos');
%     end
% 
%     %clf
%     Figs = findobj('type','figure');
% 
%     for i = 1:3
%         ax = findobj(Figs(i),'type','axes');
%         set(ax,'parent',fh,'pos',P{i}+100)
%         %close(F(i))
%     end
    %***********************************
    
    % Concatenating the four peak results into a single matrix for analysis
    FitResults{1,ind} = cat(1, FitResults{2,ind}, FitResults{3,ind}, FitResults{4,ind});
    FitError{1,ind} = cat(1, FitError{2,ind}, FitError{3,ind}, FitError{4,ind});
    
    %% Checking for bad peak fits and dead devices ******************
    
    % If the error for all three peak fits is above 5%, the device is most
    % likely dead/contains no graphene. We should not keep this result, so
    % it is flagged by zeroing out all of the results.
    % ***NOTE: Maybe we want to raise this value in case fits are just bad.****
    if FitError{1,ind}(:,1) > 5
         FitResults{1,ind} = zeros(size(FitResults{1,ind})); % Flag for dead devices
         deads = deads + 1; % Dead devices counter
         try
            DeadDevices{1,deads} = tempfilename{ind}; % Marking names of deads
         catch
            DeadDevices{1,deads} = tempfilename;
         end
    end
    % If the error for one of the three fits is >3, raise the bad fit flag
    for i = 1:3
        if FitError{1,ind}(i,1) > 3
            FitResults{5,ind}(i,1) = 1; % Bad fit flag is raised
        else FitResults{5,ind}(i,1) = 0; % Bad fit flag is not raised
        end
    end
    % Printing peak and fitting error info to the screen
    fprintf(['Fit results: \n'...
        '    Peak    Position    Height    Width    Area \n'])
    disp(FitResults{1,ind})
    fprintf(['Fit error: \n'...
        '    Error    R^2 \n'])
    disp(FitError{1,ind})
    if FitResults{5,ind}(:,1) == 1 %******CHECK that this is correct*****
        fprintf('Bad fit?\n')
    end
    
    % Sort FitResults by the values in the wavelength position column so
    % that each peak is in the correct row for the Ratios analysis
    FitResults{1,ind} = sortrows(FitResults{1,ind},2);

    %% Preparing Outputs cell array
    % Adding position, height, weight, area
    for i = 1:4
        for j = 2:5
            Outputs{ind} = cat(2, Outputs{ind}, FitResults{1,ind}(i,j)); 
        end            
    end
    
    % Calculating peak ratios and storing them in a matrix for easier output
    % Ratios will hold the h and A ratio values for D/G, D/D`, and D/2D
    for i = 1:3
        RatiosMat{ind}(1,i) = (FitResults{1,ind}(1,3)) ./ (FitResults{1,ind}(i+1,3)); %height ratios
        RatiosMat{ind}(2,i) = (FitResults{1,ind}(1,5)) ./ (FitResults{1,ind}(i+1,5)); %Area ratios
    end
    RatiosMat{ind}(1,4) = (FitResults{1,ind}(3,3)) ./ (FitResults{1,ind}(2,3)); %D`/G height
    RatiosMat{ind}(2,4) = (FitResults{1,ind}(3,5)) ./ (FitResults{1,ind}(2,5)); %D`/G Area
    Ratios{ind} = cat(2, Ratios{ind}, RatiosMat{ind}(:).');
    
    % Adding the three separate peak fit flags, fit error values, and ratio values
    Outputs{ind} = cat(2, Outputs{ind}, FitResults{5,ind}(:,1).', FitError{1,ind}(:,1).', Ratios{ind});
    
    %% Printing ratio results to the screen ******************************

    % fprintf uses the provided strings and inputs the values from Ratios into the output statements.
    % The first numerical value is for how many digits to keep, the second is 
    % how many behind the decimal point, and f means floating point.
    try
        formatSpec = ['Ratios for ' tempfilename ':\n'...
        'D/G height ratio = %5.4f \n'...
        'D/G Area ratio = %5.4f \n'...
        'D/D` height ratio = %5.4f \n'...
        'D/D` Area ratio = %5.4f \n'...
        'D/2D height ratio = %5.4f \n'...
        'D/2D Area ratio = %5.4f \n'...
        'D`/G height ratio = %5.4f \n'...
        'D`/G Area ratio = %5.4f \n' '\n'];
        fprintf(formatSpec,Ratios{ind});
    catch
        formatSpec = ['Ratios for ' tempfilename{ind} ':\n'...
        'D/G height ratio = %5.4f \n'...
        'D/G Area ratio = %5.4f \n'...
        'D/D` height ratio = %5.4f \n'...
        'D/D` Area ratio = %5.4f \n'...
        'D/2D height ratio = %5.4f \n'...
        'D/2D Area ratio = %5.4f \n'...
        'D`/G height ratio = %5.4f \n'...
        'D`/G Area ratio = %5.4f \n' '\n'];
        fprintf(formatSpec,Ratios{ind});
    end    
end

%% Listing devices that had >5% fitting errors as being dead *************
if deads == 0
    DeadDevices{1} = 'None';
end
fprintf('Dead Devices: \n')
disp(DeadDevices)

%% Concatenate the names of the rows to the first column of the output .txt file

% Creates labels for each row in the output file(s)
rows = {'D position',...
    'D height',...
    'D width',...
    'D Area',...
    'G position',...
    'G height',...
    'G width',...
    'G Area',...
    'D` position',...
    'D` height',...
    'D` width',...
    'D` Area',...
    '2D position',...
    '2D height',...
    '2D width',...
    '2D Area',...
    'D fit flag',...
    'G & D` fit flag',...
    '2D fit flag',...
    'D fit error',...
    'G & D` fit error',...
    '2D fit error',...
    'D/G height ratio',...
    'D/G Area ratio',...
    'D/D` height ratio',...
    'D/D` Area ratio',...
    'D/2D height ratio',...
    'D/2D Area ratio',...
    'D`/G height ratio',...
    'D`/G Area ratio'};

    Outputs = {rows, Outputs{:}};
    try
        tempfilename = {[Sample ' Reticle ' Reticle], tempfilename{:}};
    catch
        tempfilename = {[Sample ' Reticle ' Reticle], tempfilename};
    end
    
%% Outputting the results to a .txt file with sample & reticle number

txtfilename = ['Results-' Sample ' Reticle ' Reticle '.txt']

% Calls Cory's function to output nice tab delimited .txt files where each
% column is labeled by device. 
%**** NOTE --- Currently doesn't work when a single file is selected. ****
try
    printCellArray5(tempfilename{ind},Outputs{ind},['C:\Users\sbauman\Documents\MATLAB\Raman Peak Analysis\Outputs\' txtfilename]);
catch 
    printCellArray5(tempfilename,Outputs,['C:\Users\sbauman\Documents\MATLAB\Raman Peak Analysis\Outputs\' txtfilename]);
end
