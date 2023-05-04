% lines 6 & 13 & 14 must be changed for files. lines 17~23 can be changed with
% new padding and filter values. line 26 can be changed if want to extract
% new set of columns (will also need to change lines 27~30 accordingly).

% log file
logFilePath = "PVP_logfiles_04_21_23/20230421_122303_pv22.log"; % change here to your log file path
% data = readtable(logFilePath); % log file as a table
data = readmatrix(logFilePath);
dim = size(data);
rows = dim(1);

% start/end videoplay file
part = "2";
recordFilePath = "PVP_watchrecords_04_21_23/watchRecord_pv22_2023-4-21_part"+part+".txt"; % change here to your record file path
watchRecord = readtable(recordFilePath);

% variables that can be changed
padding = 6000; % 4000ms
qualityStandard = 0.9; % iterate through 0.9,.91,... and find a good value. each record num of vids having red blinks. pick the optimal val (preserve enough data while few red blinks)
blinkStandard = 25; % filter out 25 data rows since first blink
gazeXl = -1; % XXX change here
gazeXr = 1;
gazeYl = -1; 
gazeYr = 1;

% 1~7=time, 12=rtc, 39~42=gaze-x,y,z,Q, 43=blink, 44~55=pupil, 56~58=filters
columnsToExtract = [1 2 3 4 5 6 7 12 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58]; % change if need new columns
newNames = ["Year", "Month", "Day", "Hour", "Minute", "Second", "Fraction", "RTC", "GazeX", "GazeY", "GazeZ", "GazeQ", "Blink", "PupilDiameter", "PupilDiameterQ", "LeftPupilDiameter", "LeftPupilDiameterQ", "RightPupilDiameter", "RightPupilDiameterQ", "FilteredPupilDiameter", "FilteredPupilDiameterQ", "FilteredLeftPupilDiameter", "FilteredLeftPupilDiameterQ", "FilteredRightPupilDiameter", "FilteredRightPupilDiameterQ", "BlinkFilter", "GazeFilter", "QualityFilter"];
blinkIndex = 43;
qualityIndex = 45; % unfiltered pupil quality
gazeXIndex = 39;

% columns of new calculated real-time
newTimes = zeros(rows, 7);

% here add the realtime cols for each row:
for i=1:rows

    % get the time value (a huge number) from the log file
    curTime = data(i, 5);

    % calculate real time from the realTimeCalc function: 
    [year, month, days, hours, minutes, seconds, fraction] = realTimeCalc(curTime);
    newTimes(i, :) = [year, month, days, hours-5, minutes, seconds, fraction]; % -6 because weird timing on eyetracker pc
    
end

% add the real time data as the left 7 columns of the data matrix
data = [newTimes data];

for i=1:height(watchRecord)

    userID = ""+watchRecord{i, 1};
    vidNameNoExtension = split(watchRecord{i, 2}, '.');
    sT = watchRecord(i, 4:10);
    sT = sT{1,:};
    sT_padded = sT;
    eT = watchRecord(i, 11:17);
    eT = eT{1,:};
    eT_padded = eT;

    storagePath = "truncated_files/" + userID + "/part" + part + "/" + vidNameNoExtension{1};

    % calculate padded times
    if (padding < 1000)
        if (sT_padded(7) >= padding)
            sT_padded(7) = sT_padded(7) - padding;
        else
            sT_padded(7) = sT_padded(7) + 1000 - padding;
            if (sT_padded(6) > 0)
                sT_padded(6) = sT_padded(6) - 1;
            else
                sT_padded(6) = 59; % 59 seconds
    
                if (sT_padded(5) > 0)
                    sT_padded(5) = sT_padded(5) - 1;
                else
                    sT_padded(5) = 59;
                    sT_padded(4) = sT_padded(4) - 1; % assume hour is not midnight
                end
    
            end
        end
    
        if (eT_padded(7) < (1000 - padding))
            eT_padded(7) = eT_padded(7) + padding;
        else
            eT_padded(7) = eT_padded(7) - 1000 + padding;
            if (eT_padded(6) < 59)
                eT_padded(6) = eT_padded(6) + 1;
            else
                eT_padded(6) = 0;
    
                if (eT_padded(5) < 59)
                    eT_padded(5) = eT_padded(5) + 1;
                else
                    eT_padded(5) = 0;
                    eT_padded(4) = eT_padded(4) + 1;
                end
    
            end
        end
    else % padding > 1s
        padding = padding / 1000;
        if (sT_padded(6) >= padding)
            sT_padded(6) = sT_padded(6) - padding;
        else
            sT_padded(6) = sT_padded(6) + 60 - padding;
            if (sT_padded(5) > 0)
                sT_padded(5) = sT_padded(5) - 1;
            else
                sT_padded(5) = 59; % 59 minutes
                sT_padded(4) = sT_padded(4) - 1;
    
            end
        end
    
        if (eT_padded(6) < (60 - padding))
            eT_padded(6) = eT_padded(6) + padding;
        else
            eT_padded(6) = eT_padded(6) - 60 + padding;
            if (eT_padded(5) < 59)
                eT_padded(5) = eT_padded(5) + 1;
            else
                eT_padded(5) = 0;
                eT_padded(4) = eT_padded(4) + 1;
    
            end
        end

        padding = padding * 1000;

    end


    % now, go through data to find startRow & endRow
    ind = 1;
    startFlag = false;
    endFlag = false;
    startRow_padded = 0;
    endRow = 0;

    % get start log row
    while (ind < rows)
        comp_padded = compareTime(sT_padded(1),sT_padded(2),sT_padded(3),sT_padded(4),sT_padded(5),sT_padded(6),sT_padded(7), data(ind,1),data(ind,2),data(ind,3),data(ind,4),data(ind,5),data(ind,6),data(ind,7));
        comp = compareTime(sT(1),sT(2),sT(3),sT(4),sT(5),sT(6),sT(7), data(ind,1),data(ind,2),data(ind,3),data(ind,4),data(ind,5),data(ind,6),data(ind,7));
        
        if (~startFlag && comp_padded <= 0) % when video start time turns <= cur log
            startRow_padded = ind - 1;
            startFlag = true;
        end
        
        if (comp <= 0) % when video start time turns <= cur log
            break;
        end
        ind = ind + 1;
    end
    startRow = ind - 1;

    % get end log row
    while (ind < rows)
        comp_padded = compareTime(eT_padded(1),eT_padded(2),eT_padded(3),eT_padded(4),eT_padded(5),eT_padded(6),eT_padded(7), data(ind,1),data(ind,2),data(ind,3),data(ind,4),data(ind,5),data(ind,6),data(ind,7));
        comp = compareTime(eT(1),eT(2),eT(3),eT(4),eT(5),eT(6),eT(7), data(ind,1),data(ind,2),data(ind,3),data(ind,4),data(ind,5),data(ind,6),data(ind,7));
        
        if (~endFlag && comp <= 0) % when video start time turns <= cur log
            endRow = ind;
            endFlag = true;
        end

        if (comp_padded <= 0) % when video end time turns <= cur log
            break;
        end
        ind = ind + 1;
    end
    endRow_padded = ind;

    

    % now extract the rows for the video play. create a new txt file.
    if (startRow + 1 < endRow)
        % truncated data without paddings
        truncatedData = data(startRow:endRow, :); % cols for test_eyetracker_data.log
        truncatedData_padded = data(startRow_padded:endRow_padded, :);

        % add blink/gaze/quality filter columns
        [truncatedData, truncatedData_only_quality] = addFilterColumns(truncatedData, blinkStandard, gazeXl, gazeXr, gazeYl, gazeYr, qualityStandard, blinkIndex, gazeXIndex, qualityIndex);
        [truncatedData_padded, tempDoesntUse] = addFilterColumns(truncatedData_padded, blinkStandard, gazeXl, gazeXr, gazeYl, gazeYr, qualityStandard, blinkIndex, gazeXIndex, qualityIndex);

        % extract the selected columns and the new filter columns
        truncatedData = truncatedData(:, columnsToExtract);
        truncatedData_padded = truncatedData_padded(:, columnsToExtract);
        truncatedData_only_quality = truncatedData_only_quality(:, columnsToExtract);
         
        % make a folder to store all truncated files, if it does't exist
        if not(isfolder('truncated_files'))
            mkdir('truncated_files');
        end
        if not(isfolder(strcat("truncated_files/", userID)))
            mkdir(strcat("truncated_files/", userID));
            
        end
        if not(isfolder(strcat("truncated_files/", userID, "/part", part)))
            mkdir(storagePath);
        end
        if not(isfolder(storagePath))
            mkdir(storagePath);
        end

        % record # trials for the user
        trialPath = 'truncated_files/'+userID+'/part'+part+'/trials.txt';
        if (isfile(trialPath))
            trials = readtable(trialPath, 'Format', '%s %d');
        else
            trials = table();
        end

        trialNumber = 1;

        for ln=1:height(trials)
            if (strcmp(string(trials{ln, 1}), string(vidNameNoExtension{1})))
                trialNumber = trials{ln, 2} + 1;
                trials{ln, 2} = trialNumber; % overwrite the original line
                break;
            end
        end
        if (trialNumber == 1)
            newRow = cell2table({vidNameNoExtension{1} trialNumber});
            trials = [trials; newRow];
        end

        writetable(trials, trialPath);

        txtFileName = watchRecord{i, 1} + "_" + vidNameNoExtension{1} + "_trial" + string(trialNumber) + "_PDR.txt";
                    % later - make sure watchrecord(i,2) is 6 letters max
        txtFileName_padded = watchRecord{i, 1} + "_" + vidNameNoExtension{1} + "_trial" + string(trialNumber) + "_" + string(padding) + "ms_padding_PDR.txt";
        txtFileName_only_quality = watchRecord{i, 1} + "_" + vidNameNoExtension{1} + "_trial" + string(trialNumber) + "_only_quality_PDR.txt";
    
        % make truncated table
        truncatedTable = array2table(truncatedData);
        varNames = [];
        for j=1:length(columnsToExtract)
            varNames = [varNames "truncatedData"+string(j)];
        end
        truncatedTable = renamevars(truncatedTable, varNames, newNames);
        writetable(truncatedTable, storagePath + '/' + txtFileName);

        % make padded truncated table
        truncatedTable_padded = array2table(truncatedData_padded);
        varNames = [];
        for j=1:length(columnsToExtract)
            varNames = [varNames "truncatedData_padded"+string(j)];
        end
        truncatedTable_padded = renamevars(truncatedTable_padded, varNames, newNames);
        writetable(truncatedTable_padded, storagePath + '/' + txtFileName_padded);

        % make quality only truncated table
        truncatedTable_only_quality = array2table(truncatedData_only_quality);
        varNames = [];
        for j=1:length(columnsToExtract)
            varNames = [varNames "truncatedData_only_quality"+string(j)]; %string(columnsToExtract(j))
        end
        truncatedTable_only_quality = renamevars(truncatedTable_only_quality, varNames, newNames);
        writetable(truncatedTable_only_quality, storagePath + '/' + txtFileName_only_quality);

        % video name, trial number, rating, 
        fid = fopen(storagePath + '/info.txt','a+');
        info_line = vidNameNoExtension(1) + "," + trialNumber + "," + (watchRecord{i, 3}) + "\n";
        fprintf(fid, info_line);
        fclose(fid);

    end
end




% compare time
function [isLarger] = compareTime(syr, smo, sday, shr, smin, ssec, sfr, eyr, emo, eday, ehr, emin, esec, efr)

    if (syr > eyr)
        isLarger = 1;
    elseif (syr < eyr)
        isLarger = -1;
    else
        if (smo > emo)
            isLarger = 1;
        elseif (smo < emo)
            isLarger = -1;
        else
            if (sday > eday)
                isLarger = 1;
            elseif (sday < eday)
                isLarger = -1;
            else
               if (shr > ehr)
                   isLarger = 1;
               elseif (shr < ehr)
                   isLarger = -1;
               else
                    if (smin > emin)
                        isLarger = 1;
                    elseif (smin < emin)
                        isLarger = -1;
                    else
                        if (ssec > esec)
                            isLarger = 1;
                        elseif (ssec < esec)
                            isLarger = -1;
                        else
                            if (sfr > efr)
                                isLarger = 1;
                            elseif (sfr < efr)
                                isLarger = -1;
                            else
                               isLarger = 0;
                            end
                        end
                    end
               end
            end
        end
    end




end


% real time calculations
function [actualYear, month, days, hours, minutes, seconds, fraction] = realTimeCalc(rtc)

    oneDay = 864000000000; 														%One day in nanoseconds.
    oneYear = oneDay * 365;														%One year in nanoseconds.
    longTime = 127225728000000000; 												%Nanoseconds from 1601-01-01 to 2004-03-01.
    yearsAfter = (rtc-longTime)/oneYear; 										%Number of years after 2004-03-01.
    actualYear = 2004 + cast(yearsAfter-0.5, "uint32"); 										%The year the recording was done.
    leapDays = cast(yearsAfter/4-0.5, "uint32");											%Number of leap years since 2004 equals the amount of leap days.
    days = cast(rtc-longTime-cast(yearsAfter-0.5, "uint64")*oneYear, "double")/cast(oneDay, "double") - cast(leapDays, "double") + 1;		%Days from 1st of 31 the actual year.
    
    hours = (days-floor(days)) * 24 + 1;
    minutes = (hours-floor(hours)) * 60;
    seconds = (minutes-floor(minutes)) * 60;
    fraction = cast((seconds-floor(seconds)) * 10^3 - 0.5, "uint32");	
    
    % Testing what month it is.
    if days >= 1 && days <= 31  
	    month = "03";
    elseif days > 31 && days <= 61  
	    month = "04";
	    days = days - 31;
    elseif days > 61 && days <= 92 
	    month = "05";
	    days = days - 61;
    elseif days > 92 && days <= 122
	    month = "06";
	    days = days - 92;
    elseif days > 122 && days <= 153
	    month = "07";
	    days = days - 122;
    elseif days > 153 && days <= 184
	    month = "08";
	    days = days - 153;
    elseif days > 184 && days <= 214
	    month = "09";
	    days = days - 184;
    elseif days > 214 && days <= 245
	    month = "10";
	    days = days - 214;
    elseif days > 245 && days <= 275
	    month = "11";
	    days = days - 245;
    elseif days > 275 && days <= 306
	    month = "12";
	    days = days - 275;
    elseif days > 306 && days <= 337
	    month = "01";
	    days = days - 306;
    else
	    month = "02";
	    days = days - 337;
    end
    
    %Getting rid of decimals.
    days = cast(days-0.5, "uint32");
    hours = cast(hours-0.5, "uint32");
    minutes = cast(minutes-0.5, "uint32");
    seconds = cast(seconds-0.5, "uint32");

    
end

