
CmdWinTool("minimize"); % hide the matlab window

userid = inputdlg("Please enter your user ID:");

filepath = strcat('data/', string(userid), '/calibration_records.txt');
if (~isfolder('data/'+string(userid)))
    mkdir('data/'+string(userid))
    fid = fopen(filepath,'W');
    fprintf(fid, "USERID START_YEAR MONTH DAY HOUR MINUTE SECOND FRACTION END_YEAR MONTH DAY HOUR MINUTE SECOND FRACTION\n");
    fclose(fid);
end

fid = fopen(filepath, 'a+'); % record file
obj = VideoWindowYQ("calibration_test_no_start.mp4", 0, 'WMP');

videoInfo = VideoReader('calibration_test_no_start.mp4');

st = datetime();
[Y,M,D] = ymd(st);
[H,MI,S] = hms(st);
stsec = floor(S);
stfr = floor((S - stsec) * 1000);
start_time = Y + " " + M + " " +D + " " + H + " " + MI + " " + stsec + " " + stfr;

obj.play;
while ~(obj.Status == "Stopped")
    pause(1);
end

close;

et = datetime();
[eyr, emo, ed] = ymd(et);
[ehr, emin, es] = hms(et);
esec = floor(es);
efr = floor((es - esec) * 1000);
end_time = eyr + " " + emo + " " +ed + " " + ehr + " " + emin + " " + esec + " " + efr;

txtLine = userid + " " + start_time + " " + end_time + "\n";

fprintf(fid, txtLine);

fclose(fid);

f = msgbox("Thank you, please wait for the experimenter to process your calibration results.");



