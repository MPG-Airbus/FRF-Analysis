%% MPG-Airbus FFTs
    %% Written by Carissa Kiehl and Kevin Totts for WSGC
    %% Written July 2022
    %% Updated: [7/29/22]

% This code reads data from the sensor and monitor on the Airbus Tank using
% NI 9234
% Creates individual FFT graphs for sensor and monitor

%% Constants
secs = 5;               % Seconds to record data
fs = 17066;             % 17066, sample frequency        
f1 = 10;                % Low limit x-axis
f2 = 1000;              % High limit x-axis
L = secs*fs;            % Length of data

%% Connect to Device
d = daqlist("ni");      % Connect to the compact DAQ
dq = daq("ni");         % Create a DataAquisition
dq.Rate = fs;
addinput(dq, "cDAQ1Mod1", "ai0", "Voltage");        % Connect to BNC connectors on NI 9234
addinput(dq, "cDAQ1Mod1", "ai1", "Voltage");        % ^^

%% Gather Data
data = read(dq, seconds(secs));                     % Begin reading data
M = timetable2table(data,'ConvertRowTimes',false);  % Convert TimeTable to Table; Gets rid of Time Column

SenData = M(:, 1);  % Separate sensor data
MonData = M(:, 2);  % Separate monitor data

SenData = table2array(SenData); % Convert type from table to double
MonData = table2array(MonData); % ^^

SenData = SenData'; % Switch columns and rows
MonData = MonData'; % ^^

%% Calculate FFTs
Y1 = fft(SenData);  % Take FFT
Y2 = fft(MonData);  % ^^

% Sensor computations
P2 = abs(Y1/L);                 % Compute the two-sided spectrum P2                                 
P1 = P2(1:L/2+1);               % Compute the single-sided spectrum P1
P1(2:end-1) = 2*P1(2:end-1);

% Monitor computations
P4 = abs(Y2/L);                 % Compute the two-sided spectrum P4   
P3 = P4(1:L/2+1);               % Compute the single-sided spectrum P3
P3(2:end-1) = 2*P3(2:end-1);

f = fs*(0:(L/2))/L;             % Define frequency domain

%% Plot FFTs
figure 
% Plot sensor data
subplot(1,2,1)
plot(f,P1) 
title('Sensor FFT')
xlabel('Frequency (Hz)')
ylabel('Amplitude')
xlim([f1 f2])

% Plot monitor data
subplot(1,2,2)
plot(f,P3) 
title('Monitor FFT')
xlabel('Frequency (Hz)')
ylabel('Amplitude')
xlim([f1 f2])
