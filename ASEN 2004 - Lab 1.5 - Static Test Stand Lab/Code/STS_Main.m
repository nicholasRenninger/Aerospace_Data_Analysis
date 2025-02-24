%%% Main code to Analyze the Static Test Stand data, made by the
%%% bomb-digiest lab group.
%%%
%%% Authors: Nicholas Renninger & Marshall Herr
%%% Date Created: 04/17/2017
%%% Last Modified: 04/19/2017

clear 
clc
close all

%% Setup
N_BINS = 8;
shouldSaveFigures = true;

saveLocation = '../Figures/';

figName1 = 'Thrust Plot';
saveTitle1 = cat(2, saveLocation, sprintf('%s.pdf', figName1));

figName2 = 'Total Time to Thrust';
saveTitle2 = cat(2, saveLocation, sprintf('%s.pdf', figName2));

figName3 = 'SEM Plot';
saveTitle3 = cat(2, saveLocation, sprintf('%s.pdf', figName3));

set(0, 'defaulttextinterpreter', 'latex');

colorVecs =     {[0.156863 0.156863 0.156863], ... % sgivery dark grey
                 [0.858824 0.439216 0.576471], ... % palevioletred
                 [0.254902 0.411765 0.882353], ... % royal blue
                 [0.854902 0.647059 0.12549]}; % golden rod

             
FONTSIZE = 28;


%% Load in Data from Each Test
disp('Reading in Data...')
data = loadInData;
N = length(data); % number of tests performed

idx_offset = 0;
hFig = figure('name', figName1);
scrz = get(groot, 'ScreenSize');
set(hFig, 'Position', scrz)

% loop through every test
for i = 1:N
    
    % Get Total Time of Thrust
    total_time_thrust_vec(i + idx_offset) = max(data{i}.time) - ...
                                            min(data{i}.time);
    
    current_time = total_time_thrust_vec(i + idx_offset);
    
    % Pull Out Data
    ISP_vec(i) = data{i}.ISP;
    GRP_nums(i) = data{i}.group_num;
    water_mass_vec(i) = data{i}.water_mass;
    pressure_vec(i) = data{i}.pressure;
    temp_vec(i) = data{i}.temp;
    
    % Get Peak Thrust
    peak_thrust_vec(i) = max(data{i}.thrust);
    
    % dont record data that takes longer than 0.32s or shorter than 0.22s
    % to thrust
    if  current_time < 0.3 && current_time > 0.25
    
        thrust_vecs{i + idx_offset} = data{i}.thrust;
        time_vecs{i + idx_offset} = data{i}.time;
        
        % Plot F vs. t
        hold on
        p1 = plot(time_vecs{i + idx_offset}, ...
             smooth(thrust_vecs{i + idx_offset}), 'b', 'linewidth', 1);
        
        
    else % delete data point and reindex one data point less
        idx_offset = idx_offset - 1;
    end
    
        
    
end

disp('Finished')



%% ISP for Each Test
GRP_nums = GRP_nums';
ISP_vec = ISP_vec';
table(GRP_nums, ISP_vec)
avg_ISP = mean(ISP_vec);
std_dev_ISP = std(ISP_vec);


%% Peak Thrust for Each Test
peak_thrust_vec =  peak_thrust_vec';
table(GRP_nums, peak_thrust_vec)

avg_peak_thrust = mean(peak_thrust_vec);
std_dev_peak_thrust = std(peak_thrust_vec);


%% Print these Results after Table

% print to command window
fprintf('Average ISP: %0.3gs\n', avg_ISP)
fprintf('Std. Dev. of Data Set: %0.3gs\n\n', std_dev_ISP)

% print to command window
fprintf('Average Peak Thrust is: %0.3gN\n', avg_peak_thrust)
fprintf('Std. Dev. of Peak Thrust is: %0.3gN\n\n', std_dev_peak_thrust)



%% Format Plot of F vs. t
xMax = 0.3; % [s]

%%% plot avg. peak thrust
t_vec = linspace(0, xMax, 100);
peak_thrust_plot_vec = avg_peak_thrust .* ones(100, 1);

p2 = plot(t_vec, peak_thrust_plot_vec, ':k', 'linewidth', 2);

% legend
legend([p1, p2], {'Thrust Data from Trials', ...
        sprintf('Average Peak Thrust = %0.3gN', avg_peak_thrust)}, ...
       'interpreter', 'latex', 'location', 'best')
% give title
title('Representative Thrust Data from Static Test Stand Trials')
% give x and y labels
xlabel('$t$ (s)')
ylabel('$T$ (N)')
ylim([-30 inf])
xlim([0, xMax])
set(gca, 'fontsize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
grid on

%%% setup and save figure as .pdf
if shouldSaveFigures
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen(saveTitle1, 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', saveTitle1);
end


%% Total Time to Thrust
%%% Plotting
hFig = figure('name', figName2);
scrz = get(groot, 'ScreenSize');
set(hFig, 'Position', scrz)

histfit(total_time_thrust_vec, N_BINS)

% give title
title('Total Time to Thrust')
% give x and y labels
xlabel('Time to Thrust, $t$, (s)')
ylabel('\# Trials with Time to Thrust')
set(gca, 'fontsize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
grid on

%%% setup and save figure as .pdf
if shouldSaveFigures
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen(saveTitle2, 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', saveTitle2);
end


%%% printing
avg_time_thrust = mean(total_time_thrust_vec);
std_dev_time_thrust = std(total_time_thrust_vec);

% print to command window
fprintf('Average Time to Thrust is: %0.3gs\n', avg_time_thrust)
fprintf('Std. Dev. of Peak Thrust is: %0.3gs\n\n', std_dev_time_thrust)


%% Plot of SEM vs. N
maxN = 1e4;
N = 1:1:maxN;
SEM_ISP = std_dev_ISP ./ sqrt(N);

SEM_Data_set_ISP = SEM_ISP(length(ISP_vec));

fprintf('The SEM for the ISP data set is: %0.3gs\n\n', SEM_Data_set_ISP)


%%% Plotting
hFig = figure('name', figName3);
scrz = get(groot, 'ScreenSize');
set(hFig, 'Position', scrz)

plot(N, SEM_ISP, 'color', colorVecs{1}, ...
     'linewidth', 2.5)
hold on
plot(N, SEM_ISP .* 1.96, ':', 'color', colorVecs{2}, ...
     'linewidth', 2)
plot(N, SEM_ISP .* 2.24, ':', 'color', colorVecs{3}, ...
     'linewidth', 2)
plot(N, SEM_ISP .* 2.58, ':', 'color', colorVecs{4}, ...
     'linewidth', 2)

% assign legend
legend({'$SEM$ vs. $N$', ...
        'Uncertainty in ISP estimate with 95\% C.I.', ...
        'Uncertainty in ISP estimate with 97.5\% C.I.', ...
        'Uncertainty in ISP estimate with 99\% C.I.'}, ...
       'interpreter', 'latex', 'location', 'best')
% give title
title('$SEM$ vs. $N$')
% give x and y labels
xlabel('$N$ (\# tests conducted)')
ylabel('$SEM$ (s)')
xlim([1 100])
ylim([-inf inf])
set(gca, 'fontsize', FONTSIZE)
set(gca, 'defaulttextinterpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
grid on

%%% setup and save figure as .pdf
if shouldSaveFigures
    curr_fig = gcf;
    set(curr_fig, 'PaperOrientation', 'landscape');
    set(curr_fig, 'PaperUnits', 'normalized');
    set(curr_fig, 'PaperPosition', [0 0 1 1]);
    [fid, errmsg] = fopen(saveTitle3, 'w+');
    if fid < 1 % check if file is already open.
       error('Error Opening File in fopen: \n%s', errmsg); 
    end
    fclose(fid);
    print(gcf, '-dpdf', saveTitle3);
end


%% N for 95% confidence level for mean ISP = 0.1s & mean ISP 0.01s

% set C.I. z-value
z = 1.96;

%%% 95% CI for ISP estimate within 0.1s
confidence_idx = find(z .* SEM_ISP < 0.1, 1, 'first');
N_needed = N(confidence_idx);
fprintf(['N needed to ISP estimate', ...
         ' to within 0.1s with 95%% confidence: N = %d\n'], N_needed);
     
%%% 95% CI for ISP estimate within 0.01s
confidence_idx = find(z .* SEM_ISP < 0.01, 1, 'first');
N_needed = N(confidence_idx);
fprintf(['N needed to ISP estimate', ...
         ' to within 0.01s with 95%% confidence: N = %d\n\n'], N_needed);
     
     
%% N for 97.5% confidence level for mean ISP = 0.1s & mean ISP 0.01s

% set C.I. z-value
z = 2.24;

%%% 97.5% CI for ISP estimate within 0.1s
confidence_idx = find(z .* SEM_ISP < 0.1, 1, 'first');
N_needed = N(confidence_idx);
fprintf(['N needed to ISP estimate', ...
         ' to within 0.1s with 97.5%% confidence: N = %d\n'], N_needed);
     
%%% 97.5% CI for ISP estimate within 0.01s
confidence_idx = find(z .* SEM_ISP < 0.01, 1, 'first');
N_needed = N(confidence_idx);
fprintf(['N needed to ISP estimate', ...
         ' to within 0.01s with 97.5%% confidence: N = %d\n\n'], N_needed);
     
     
%% N for 99% confidence level for mean ISP = 0.1s & mean ISP 0.01s

% set C.I. z-value
z = 2.58;

%%% 99% CI for ISP estimate within 0.1s
confidence_idx = find(z .* SEM_ISP < 0.1, 1, 'first');
N_needed = N(confidence_idx);
fprintf(['N needed to ISP estimate', ...
         ' to within 0.1s with 99%% confidence: N = %d\n'], N_needed);
     
%%% 99% CI for ISP estimate within 0.01s
confidence_idx = find(z .* SEM_ISP < 0.01, 1, 'first');
N_needed = N(confidence_idx);
fprintf(['N needed to ISP estimate', ...
         ' to within 0.01s with 99%% confidence: N = %d\n\n'], N_needed);
     
