%% MPG-Airbus Data Collection and FRF
    %% Written by Justin Wheeler, Carissa Kiehl, Kevin Totts for WSGC
    %% Written July 2022
    %% Updated: [7/22/22]
    
% This code reads data from the sensor and monitor on the Airbus Tank using
% NI 9234
% Creates FRFs 
% Surf Plot in other Code

%% Constants
secs = 5;               % Seconds to record data
fs = 17066;             % 17066, sample frequency        
f1 = 10;                % Low limit x-axis
f2 = 5000;              % High limit x-axis
s1 = 1;                 % Starting time series sample of one second data 
s2 = s1 + fs;           % Ending time series sample of one second data

%% Connect to Device
d = daqlist("ni");      % Connect to the compact DAQ
dq = daq("ni");         % Create a DataAquisition
dq.Rate = fs;
addinput(dq, "cDAQ1Mod1", "ai0", "Voltage");        % Connect to BNC connectors on NI 9234
addinput(dq, "cDAQ1Mod1", "ai1", "Voltage");        % ^^

%% Gather Data
data = read(dq, seconds(secs));                     % Begin reading data
M = timetable2table(data,'ConvertRowTimes',false);  % Convert TimeTable to Table; Gets rid of Time Column

%% Preproccess Data
Track1 = M(:, 1);             % First column of data
Track2 = M(:, 2);             % Second column of data
Track1 = Track1{:,:};         % Converts from Table to Matrix
Track2 = Track2{:,:};         % ^^

% Sen = Track1;           % Sensor is the first column of data
% Mon = Track2;           % Monitor is the second column of data

% Use a highpass filter if there is a lot of low frequency noise
highpass_cutoff = 100;
Sen = highpass(Track1,highpass_cutoff,fs); %filter out f < highpass_cuttoff
Mon = highpass(Track2,highpass_cutoff,fs); %filter out f < highpass_cuttoff

data_length = length(Mon)/fs;                       % Calculates length of data                    
disp(fprintf("Data Length: %.2f", data_length))     % Displays number of seconds of data

%% Plotting Setup
ch0=Mon(s1:s2);         % Gathers one sample of data
ch1=Sen(s1:s2);         % ^^

[Txy0,F1]=tfestimate(ch0,ch1,[],[],[],fs);     % Transfer function estimate
Txyabs0 = zeros(length(abs(Txy0)),1);
LowFSample  = round(f1/(fs/2)*length(F1));              % Sample location of f1 in frequency list 
HighFSample  = round(f2/(fs/2)*length(F1));             % Sample location of f2 in frequency list

f = figure;
hold off
xlim([f1 f2])        % X-axis limits

%% Iterate Through Data
while s2 < length(Mon)      % Loop through entire range of data
    ch0=Mon(s1:s2); 
    ch1=Sen(s1:s2);
    
    [Txy0,F1]=tfestimate(ch0,ch1,[],[],[],fs);
    Txyabs0 = abs(Txy0);        % To convert from complex numbers
    s1 = s1 + fs;               % Update s1
    s2 = s1 + fs;               % Update s2
    baseline = rms(Txyabs0);    % Root mean square
    Txyabs0 = Txyabs0 - baseline; % Adjust for baseline

    plot(F1(LowFSample:HighFSample),Txyabs0(LowFSample:HighFSample)) % Create FRF plot
    %pause(1.5);        % See FRFs every pause
end

xlabel('Frequency (Hz)')       % X-axis title
ylabel('Amplitude')            % Y-axis title
title('Airbus one-second FRFs')   % Title 