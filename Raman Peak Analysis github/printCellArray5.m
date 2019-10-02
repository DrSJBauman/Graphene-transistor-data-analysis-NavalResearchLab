function printCellArray5(varargin)
%% function printCellArray(headers,data,rows,filename)
%
% headers: these are the column heads for the data.
% data: a cell array of numbers, the length can be different; no matrices.
% rows: row labels for the data.
% filename: the desired output file name (include path or it will be placed in pwd).

% The function prints a single row of headers tab delimited.  It then prints
% out the data array in column format under each header.  I think this is
% pretty slick.  Cory D. Cress

% Tweaks made by Stephen J Bauman July 2017 - want to add row labels

%temp = {[1 2 3 4 5]' [6 7 0] [1 17 18 19 10]};

filename = varargin{nargin};% Always ends with filename

fid = fopen(filename,'a');

headers = varargin{1}; % First one is always the headers
for i =1:length(headers)
    if iscell(headers{i})
        headers{i}= headers{i}{:}
    end
    if ~isstr(headers{i}) 
        headers{i} = num2str(headers{i});
    end
    fprintf(fid,'%s\t', headers{i});
    if i == length(headers)
        fprintf(fid,'\n');
    end
end

if nargin > 2 %there is some data also;
    data = varargin{2};
    [row col] = cellfun(@size,data);
    for i = 1:max(col)
        for j = 1:length(data)
            if j < length(data)% if it is not the last vector in column
                if col(j)>= i  % length of vector is greater than current row
                    dataType = class(data{j});
                    switch dataType
                        case {'cell'}
                            if isempty(data{j}{i}) % if this cell is empty just print a tab
                                 fprintf(fid,' \t');
                            elseif isstr(data{j}{i}) % its a cell string array 
                                fprintf(fid,'%s\t', data{j}{i});
                            else                      % assume its a double
                                fprintf(fid,'%d \t',data{j}{i});
                            end
                            continue
                        case {'double'}
                            fprintf(fid,'%d \t',data{j}(i));
                            continue
                        case {'char'}
                            fprintf(fid,'%s \t',data{j});
                            continue
                    end
                else
                    fprintf(fid,' \t');
                end
            else
                if col(j)>= i  % length of vector is greater than current row
                    dataType = class(data{j});
                    switch dataType
                        case {'cell'}
                            if isempty(data{j}{i}) % if this cell is empty just print a tab
                                 fprintf(fid,' \n');
                            elseif isstr(data{j}{i}) % its a cell string array 
                                fprintf(fid,'%s\n', data{j}{i});
                            else                      % assume its a double
                                fprintf(fid,'%d \n',data{j}{i});
                            end
                            continue
                        case {'double'}
                            fprintf(fid,'%d \n',data{j}(i));
                            continue
                        case {'char'}
                            fprintf(fid,'%s\n',data{j});
                            continue
                    end
                else
                    fprintf(fid,' \n');
                end
            end
                
        end
    end
end
fclose(fid);

