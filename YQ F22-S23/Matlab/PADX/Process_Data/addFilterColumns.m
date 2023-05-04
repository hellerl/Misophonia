function [addedFilterData, onlyQualityData] = addFilterColumns(data, blinkStandard, gazeXl, gazeXr, gazeYl, gazeYr, qualityStandard, blinkIndex, gazeXIndex, qualityIndex)

    gazeYIndex = gazeXIndex + 1;

    dataWidth = width(data);
    addedFilterData = zeros(0, dataWidth+3);
    onlyQualityData = zeros(0, dataWidth+3);

    blinkUntil = 0; % next blinkStandard number of rows should be filtered

    % isFirstBlink - for case where next blink starts before first
    % blink's blinkUntil ends
    isFirstBlink = 1;
    
    for i=1:height(data)
        origRow = data(i, :);

        % blink filter
        if (blinkUntil == 0) % currently not filtering blinks
            if (~(origRow(blinkIndex) == 0)) % is first blink
                blinkUntil = blinkStandard - 1; % the next blinkStandard rows will be filtered
                blinkVal = 0;
                isFirstBlink = 0; % next blink will not be a first blink
            else % not a blink
                blinkVal = 1;
                isFirstBlink = 1;
            end
        else % currently filtering blinks
            if (~(origRow(blinkIndex) == 0) && isFirstBlink) % if current is a new first blink
                isFirstBlink = 0;
                blinkUntil = blinkStandard; % the next blinkStandard rows will be filtered
            end
            blinkUntil = blinkUntil - 1;
            blinkVal = 0;

            if (origRow(blinkIndex) == 0) % not a blink
                isFirstBlink = 1;
            end
        end


        % gaze filter
        if (origRow(gazeXIndex) < gazeXl || origRow(gazeXIndex) > gazeXr) % gaze x out of bound
            gazeVal = 0;
        elseif (origRow(gazeYIndex) < gazeYl || origRow(gazeYIndex) > gazeYr) % gaze y out of bound
            gazeVal = 0;
        else
            gazeVal = 1;
        end

        % quality filter
        if (origRow(qualityIndex) < qualityStandard)
            qualityVal = 0;
        else
            qualityVal = 1;
        end

        % add new row
        newRow = [origRow blinkVal gazeVal qualityVal];
        addedFilterData = [addedFilterData; newRow];
    end

    % get data that pass all three filters
    for i=1:height(data)
        filterRow = addedFilterData(i, :);
        if (filterRow(dataWidth+1) && filterRow(dataWidth+2) && filterRow(dataWidth+3))
            onlyQualityData = [onlyQualityData; filterRow];
        end
    end

end