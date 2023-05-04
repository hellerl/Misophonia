
userid = inputdlg("Please enter the user ID:");

% a short snippet of code that moves files to directory
src_info = dir("./*.log");
src_info = src_info(1);
src = strcat(src_info.folder, "/", src_info.name);
dest = strcat("./data/", userid, "/");
movefile(src, dest)

% code to copy a file and rename it as calib.log
copyfile(strcat(dest, src_info.name), strcat(dest, "calib.log"))

% truncated data - IF FIRST TEST FAILED, PUT PREV FILES IN ARCHIVE
stored_log_path = strcat("data/", userid, "/calib.log"); % changed
stored_log = readmatrix(stored_log_path);

watchRecord = readtable("data/"+userid+"/calibration_records.txt");

k = height(watchRecord);

    userid = ""+watchRecord{k, 1};
    sT = watchRecord(1, 2:8);
    sT = sT{1,:};
    eT = watchRecord(1, 9:15);
    eT = eT{1,:};

data = log_time(sT, eT, stored_log);

% store these data as reference
assessments_passed = assess_calib(data);
display_message(assessments_passed)


% -------- helper functions --------

function [] = display_message(assessments_passed)
    if (assessments_passed(1) == true && assessments_passed(2) == true && assessments_passed(3) == true)
	    f = msgbox("You have passed the calibration test. Please notify the experimenter.");
    else
	    error_text = "You have failed the calibration test for the following reason(s): \n";
        if (~assessments_passed(1))
		    error_text = strcat(error_text, "    • Blinking too much \n");
        end
        if (~assessments_passed(3))
		    error_text = strcat(error_text, "    • Not looking within the video player \n");
        end
        if (~assessments_passed(2))
		    error_text = strcat(error_text, "    • Other factors, such as not sitting properly \n");
        end
	    error_text = strcat(error_text, "Please wait for instructions from the experimenter.");
	    f = msgbox(sprintf(error_text));
    end
end

function [data] = log_time(start_time, end_time, stored_log)
    
    dim = size(stored_log);
    rows = dim(1);

    data_with_time = add_time(stored_log, rows);

    [start_row, end_row] = get_start_end_rows(data_with_time, start_time, end_time, rows);

    data = data_with_time(start_row:end_row, :);

end


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



function [start_row, end_row] = get_start_end_rows(data, sT, eT, rows)
    ind = 1;    
    while (ind < rows)
        cmp = compareTime(sT(1),sT(2),sT(3),sT(4),sT(5),sT(6),sT(7), data(ind,1),data(ind,2),data(ind,3),data(ind,4),data(ind,5),data(ind,6),data(ind,7));
        
        if (cmp <= 0) % when video start time turns <= cur log
            break;
        end
        ind = ind + 1;
    end
    start_row = ind;

    while (ind < rows)
        cmp = compareTime(eT(1),eT(2),eT(3),eT(4),eT(5),eT(6),eT(7), data(ind,1),data(ind,2),data(ind,3),data(ind,4),data(ind,5),data(ind,6),data(ind,7));
        
        if (cmp <= 0) % when video end time turns <= cur log
            break;
        end
        ind = ind + 1;
    end
    end_row = ind;

end


function [data_with_time] = add_time(temp_data, rows)
    % columns of new calculated real-time
    newTimes = zeros(rows, 7);
    
    % here add the realtime cols for each row:
    for i=1:rows

        % get the time value (a huge number) from the log file
        curTime = temp_data(i, 5);
    
        % calculate real time from the realTimeCalc function: 
        [year, month, days, hours, minutes, seconds, fraction] = realTimeCalc(curTime);
        newTimes(i, :) = [year+1, month, days, hours-6, minutes, seconds, fraction]; % -6 because weird timing on eyetracker pc
        
    end

    data_with_time = [newTimes temp_data];

end


function [assessments_passed] = assess_calib(data)
	blink_threshold = 0.1;
	quality_threshold = 0.9; % at least three quarters of data should have quality >= quality_value
	gaze_threshold = 0.9;

	quality_value = 0.9;
	gaze_bounds = [-0.5,0.5,-0.5,0.5]; % x-left, x-right, y-left, y-right
	assessments_passed = [false, false, false];

	rows_total = height(data);
	blinks_total = 0;
	quality_passed_total = 0;
	gaze_passed_total = 0;

    for i = 1:height(data)
        row = data(i,:);
		blink = row(43); % row indices to change!!!
		quality = row(45);
		gaze_x = row(39);
		gaze_y = row(40);

        if (~(blink == 0)) % is a blink
		    blinks_total = blinks_total + 1;
        end
        if (quality >= quality_value)
		    quality_passed_total = quality_passed_total + 1;
        end
        if (bound_check(gaze_x, gaze_y, gaze_bounds)) 
		    gaze_passed_total = gaze_passed_total + 1;
        end
    end
	
    if ((blinks_total / rows_total) <= blink_threshold)
		assessments_passed(1) = true;
    end
    if ((quality_passed_total / rows_total) >= quality_threshold)
		assessments_passed(2) = true;
    end
    if ((gaze_passed_total / rows_total) >= gaze_threshold)
		assessments_passed(3) = true;
    end
end


function [is_within_bounds] = bound_check(gaze_x, gaze_y, gaze_bounds)
    if (gaze_x < gaze_bounds(1) || gaze_x > gaze_bounds(2) || gaze_y < gaze_bounds(3) || gaze_y > gaze_bounds(4))
		is_within_bounds = false;
    else 
	    is_within_bounds = true;
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

