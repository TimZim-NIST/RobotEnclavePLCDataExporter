%% Robotic Enclave Experiment Report
%  This is an automated report generated from robotic enclave PLC data.
%  
%  Author:       Timothy Zimmerman (timothy.zimmerman@nist.gov)
%  Organization: National Institute of Standards and Technology
%                U.S. Department of Commerce
%  License:      Public Domain


%% Experiment Details

% Have the user select the DAT metadata file and parse it
metadata_filename = uigetfile('*.dat', 'Select the PLC data file...');
metadata_file = fopen(metadata_filename);
metadata = textscan(metadata_file,'%s %s');
fclose(metadata_file);

%Store the Metadata
metadata_data_file = metadata{2}{1};
metadata_date = metadata{2}{2};
metadata_time = metadata{2}{3};
metadata_exp_mode = metadata{2}{4};
metadata_exp_val = metadata{2}{5};
metadata_sta1_proctime = metadata{2}{6};
metadata_sta2_proctime = metadata{2}{7};
metadata_sta3_proctime = metadata{2}{8};
metadata_sta4_proctime = metadata{2}{9};
metadata_totalparts = metadata{2}{10};
metadata_goodparts = metadata{2}{11};
metadata_rejectparts = metadata{2}{12};
metadata_alarms = metadata{2}{13};

% Use the CSV file referenced in the DAT file
delay_data = importdata(metadata_data_file, ',');

% Calculate size of original array
orig_arr_size = size(delay_data.data,1);

% Define the number of histogram containers (overridden by hist_binwidth)
hist_containers = 15;
% Define the width of the histogram bins
hist_binwidth = 0.05;

% Initialize the data arrays
sta1_delay_msec = [];
sta2_delay_msec = [];
sta3_delay_msec = [];
sta4_delay_msec = [];
sta6_delay_msec = [];
sta1_to_sta2_delay_msec = [];
sta2_to_sta3_delay_msec = [];
sta3_to_sta4_delay_msec = [];
sta6_to_sta1_delay_msec = [];
total_part_time = [];

%#ok<*SAGROW>
%#ok<*AGROW>

% Import the data... but ignore the first two rows of data because the enclave is purged
ignored_parts = [1,2];
i = 1;
for n = 3:size(delay_data.data,1)
    if delay_data.data(n,2) ~= 0 && delay_data.data(n,3) ~= 0 && delay_data.data(n,4) ~= 0 && delay_data.data(n,5) ~= 0 && delay_data.data(n,6) ~= 0 && delay_data.data(n,7) ~= 0 && delay_data.data(n,8) ~= 0 && delay_data.data(n,9) ~= 0 && delay_data.data(n,10) ~= 0
        % Copy data from the event log to dedicated arrays and convert the
        % units to seconds. Only insert the data IF the part was able to
        % complete the manufacturing process (all delays ~= 0)
        sta1_delay_msec(i,1) = delay_data.data(n,2) / 100;
        sta2_delay_msec(i,1) = delay_data.data(n,3) / 100;
        sta3_delay_msec(i,1) = delay_data.data(n,4) / 100;
        sta4_delay_msec(i,1) = delay_data.data(n,5) / 100;
        sta6_delay_msec(i,1) = delay_data.data(n,6) / 100;
        sta1_to_sta2_delay_msec(i,1) = delay_data.data(n,7) / 100;
        sta2_to_sta3_delay_msec(i,1) = delay_data.data(n,8) / 100;
        sta3_to_sta4_delay_msec(i,1) = delay_data.data(n,9) / 100;
        sta6_to_sta1_delay_msec(i,1) = delay_data.data(n,10) / 100;
        % Calculate the total time and put in dedicated array
        total_part_time(i,1) = 0;
        for m = 2:10
            total_part_time(i,1) = total_part_time(i,1) + (delay_data.data(n,m) / 100);
        end
        i = i + 1;
    else
        ignored_parts = [ignored_parts, n];
    end
end

% Print the data for the report
fprintf('Metadata File: \t%s\n', metadata_filename)
fprintf('Data File: \t%s\n\n', metadata_data_file)

fprintf('Metadata\n========\n')
fprintf('Date: \t\t\t%s\n', metadata_date)
fprintf('Time: \t\t\t%s EST\n', metadata_time)
fprintf('Experiment Mode: \t%s\n', metadata_exp_mode)
fprintf('Experiment Mode Value: \t%s\n', metadata_exp_val)
fprintf('Station 1 Process Time: %s\n', metadata_sta1_proctime)
fprintf('Station 2 Process Time: %s\n', metadata_sta2_proctime)
fprintf('Station 3 Process Time: %s\n', metadata_sta3_proctime)
fprintf('Station 4 Process Time: %s\n', metadata_sta4_proctime)
fprintf('Total Parts: \t\t%s\n', metadata_totalparts)
fprintf('Good Parts: \t\t%s\n', metadata_goodparts)
fprintf('Rejected Parts: \t%s\n', metadata_rejectparts)


fprintf('\nMATLAB Data\n===========\n')
fprintf('Parsed parts: \t\t%i\n', orig_arr_size)
fprintf('Less ignored: \t\t%i\n', size(sta1_delay_msec,1))
fprintf('Ignored parts:\t')
disp(ignored_parts)

%% Station 6 to Station 1 Delay
h2 = histogram(sta6_to_sta1_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 6 to Station 1 Delay')
this_xlim_max = max(sta6_to_sta1_delay_msec) + 0.1;
this_xlim_min = min(sta6_to_sta1_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta6_to_sta1_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta6_to_sta1_delay_msec))


%% Station 1 Delay
h2 = histogram(sta1_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 1 Delay')
this_xlim_max = max(sta1_delay_msec) + 0.1;
this_xlim_min = min(sta1_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta1_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta1_delay_msec))

%% Station 1 to Station 2 Delay
h2 = histogram(sta1_to_sta2_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 1 to Station 2 Delay')
this_xlim_max = max(sta1_to_sta2_delay_msec) + 0.1;
this_xlim_min = min(sta1_to_sta2_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta1_to_sta2_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta1_to_sta2_delay_msec))

%% Station 2 Delay
h2 = histogram(sta2_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 2 Delay')
this_xlim_max = max(sta2_delay_msec) + 0.1;
this_xlim_min = min(sta2_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta2_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta2_delay_msec))

%% Station 2 to Station 3 Delay
h2 = histogram(sta2_to_sta3_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 2 to Station 3 Delay')
this_xlim_max = max(sta2_to_sta3_delay_msec) + 0.1;
this_xlim_min = min(sta2_to_sta3_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta2_to_sta3_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta2_to_sta3_delay_msec))

%% Station 3 Delay
h2 = histogram(sta3_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 3 Delay')
this_xlim_max = max(sta3_delay_msec) + 0.1;
this_xlim_min = min(sta3_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta3_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta3_delay_msec))

%% Station 3 to Station 4 Delay
h2 = histogram(sta3_to_sta4_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 3 to Station 4 Delay')
this_xlim_max = max(sta3_to_sta4_delay_msec) + 0.1;
this_xlim_min = min(sta3_to_sta4_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta3_to_sta4_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta3_to_sta4_delay_msec))

%% Station 4 Delay
h2 = histogram(sta4_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 4 Delay')
this_xlim_max = max(sta4_delay_msec) + 0.1;
this_xlim_min = min(sta4_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta4_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta4_delay_msec))

%% Station 6 Delay
h2 = histogram(sta6_delay_msec(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = hist_binwidth;
grid on;
grid minor;
xlabel('seconds')
ylabel('# of samples')
title('Station 6 Delay')
this_xlim_max = max(sta6_delay_msec) + 0.1;
this_xlim_min = min(sta6_delay_msec) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(sta6_delay_msec))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(sta6_delay_msec))

%% Total Production Time
h2 = histogram(total_part_time(:,1), hist_containers);
h2.Normalization = 'count';
h2.BinWidth = 0.2;
grid on;
grid minor;
xlabel('seconds');
ylabel('# of samples');
title('Part Production Time');
this_xlim_max = max(total_part_time) + 0.1;
this_xlim_min = min(total_part_time) - 0.1;
xlim([this_xlim_min this_xlim_max]);

fprintf('Minimum Time: \t%.3f seconds\n', this_xlim_min)
fprintf('Maximum Time: \t%.3f seconds\n', this_xlim_max)
fprintf('Mean Time: \t%.3f seconds\n', mean(total_part_time))
fprintf('Std. Dev.: \t±%.3f seconds\n', std(total_part_time))
fprintf('Bin Width: \t%.3f seconds\n', h2.BinWidth)


