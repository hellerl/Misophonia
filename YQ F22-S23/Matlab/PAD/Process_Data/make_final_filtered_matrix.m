% make final matrix

userid = "p20"; % USERS: ONLY EDIT THIS LINE

folderpath = strcat("truncated_files/", string(userid), "/");
matrix_height = 0; % will change to length of longest video
trials_table = readtable(folderpath + "/trials.txt");
matrix_width = 0; % XXX expand later length(folder) - 3; % # vids minus ., .., and trials.txt

filtered_pupil_index = 20; % col of pupil diameter in table. later make it automated
old_names=[];
new_names=[];
trial_numbers=[];
rating_numbers1=[]; rating_numbers2=[]; rating_numbers3=[]; rating_numbers4=[]; rating_numbers5=[]; rating_numbers6=[]; rating_numbers7=[]; rating_numbers8=[]; rating_numbers9=[];
userids=[];
start_times=[];
num_info_rows = 18;


% get matrix height (i.e. length of the longest quality_only data
for i=1:height(trials_table)
    vidname = trials_table{i,1};
    trials_count = trials_table{i,2};
    matrix_width = matrix_width + trials_count;

    info_path = strcat(folderpath, "/", vidname, "/info.txt");
    info_table = readtable(info_path);

    for t=1:trials_count
        old_names = [old_names string(vidname)];
        new_names = [new_names strcat(string(vidname), "_trial",string(t))];
        userids = [userids string(userid)];
        data_filename = strcat(userid, "_", vidname, strcat("_trial", string(t), "_6000ms_padding_PDR.txt")); % to change 1000ms
        data_path = strcat(folderpath, vidname, "/", data_filename);
        trial_numbers = [trial_numbers string(t)];
        rating_numbers1 = [rating_numbers1 info_table{t,3}];
        rating_numbers2 = [rating_numbers2 info_table{t,4}];
        rating_numbers3 = [rating_numbers3 info_table{t,5}];
        rating_numbers4 = [rating_numbers4 info_table{t,6}];
        rating_numbers5 = [rating_numbers5 info_table{t,7}];
        rating_numbers6 = [rating_numbers6 info_table{t,8}];
        rating_numbers7 = [rating_numbers7 info_table{t,9}];
        rating_numbers8 = [rating_numbers8 info_table{t,10}];
        rating_numbers9 = [rating_numbers9 info_table{t,11}];

        if (isfile(data_path))
            data_p = readtable(data_path);
            if (height(data_p) == 0)
                start_time = ["a" "a" "a" "a" "a" "a" "a"]; % converted to NaN later
            else 
                start_time = [data_p{1, 1:7}];
            end
            start_times = [start_times; start_time];
        else
            disp("only quality data not found. aborted.");
    %         exit(0);
            return;
        end

        dim = size(data_p);
        rows = dim(1);
        % update matrix height if needed for current video
        if (rows > matrix_height)
            matrix_height = rows;
        end
    end
end

matrix_height = matrix_height + num_info_rows; % for top info rows


matrix = zeros(matrix_height, matrix_width);

% fill in trial and rating
for c=1:width(matrix)
    matrix(1, c) = userids(c);
    matrix(2, c) = trial_numbers(c);

    matrix(3, c) = rating_numbers1(c);
    matrix(4, c) = rating_numbers2(c);
    matrix(5, c) = rating_numbers3(c);
    matrix(6, c) = rating_numbers4(c);
    matrix(7, c) = rating_numbers5(c);
    matrix(8, c) = rating_numbers6(c);
    matrix(9, c) = rating_numbers7(c);
    matrix(10, c) = rating_numbers8(c);
    matrix(11, c) = rating_numbers9(c);
    
    matrix(12:18, c) = start_times(c, :);
end

% fill in the rest
for r=num_info_rows+1:height(matrix)
    for c=1:width(matrix)
        matrix(r, c) = "N/A";
    end
end


% write data onto matrix
for i=1:matrix_width

    vidname = old_names(i);
    data_filename = strcat(userids(i), "_", new_names(i),  "_6000ms_padding_PDR.txt");
    data_path = strcat(folderpath, vidname, "/", data_filename);
    data_p = readtable(data_path);

    for r=1:height(data_p)
        matrix(r+num_info_rows, i) = data_p{r, filtered_pupil_index};
    end


end

matTable = array2table(matrix);
var_names = [];
for j=1:matrix_width
    var_names = [var_names "matrix"+string(j)];
end
matTable = renamevars(matTable, var_names, new_names);
matTable = matTable(:,sort(matTable.Properties.VariableNames));

% if (~isfolder("final_matrices"))
%     mkdir("final_matrices")
% end

% fix the order of matrices
temp1 = matTable(:,47:50);
temp2 = matTable(:,39:44);
temp3 = matTable(:,45:46);
matTable(:,39:42) = temp1;
matTable(:,43:48) = temp2;
matTable(:,49:50) = temp3;

new_names = sort(new_names);
new_names_copy = new_names;
temp1 = new_names_copy(47:50);
temp2 = new_names_copy(39:44);
temp3 = new_names_copy(45:46);
new_names_copy(39:42) = temp1;
new_names_copy(43:48) = temp2;
new_names_copy(49:50) = temp3;

matTable = renamevars(matTable, new_names, new_names_copy);

writetable(matTable, "final_matrices/YQsorted_0330_filtered/" + string(userid) + "_final");


% matrix.Properties.VariableNames{1};
% x = matrix.Properties.VariableNames;

% disp();
% matrix = renamevars(matrix,"1","vidnamehahaha");
