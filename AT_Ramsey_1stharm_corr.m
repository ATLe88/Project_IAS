%% This script is used to measure the Ramsey sequence
% this script use the R&S spectrum analyser to monitor the mechanical
% resonance and the ringdown
% The Keithley 2401 control the applied voltage
% Keysight 81150a generates arb. pulses that can be generated and loaded from the software
% Benchlink Waveform Builder or the iqtools for a customized arb. pulse.
% Important note: the outputs of the DC source Keithley 2401 and the AWG 81150a
%                 should always be turned on. AWG should be in the trigger
%                 mode permanently

% The main sequence of this script is defined as followed:
% 1. define all the parameters
% 2. frequency regulation to get the initial frequency
% 3. load the arb. function either with iqtools or Benchlink Waveform
%    Builder
% 4. identify initial frequency -> trigger to turn on the ramp to determine
%    the final frequency
% 5. create a set of waiting time for the loop
% 6. in the loop: 2 steps of frequency regulations (noise and sinusoidal
%    drive)

% date: 19th October 2021
% created by: Anh Tuan, Le and Avishek Chowdhury

%% Define directory of the file
workingDir = pwd; % directory of measurement-scripts
workingFile = [mfilename('fullpath'),'.m']; % filepath of current file
% Define directory
messordner = 'C:\\Messung\\Anh_Tuan\\3DCavity\\Coax\\Munich\\'; % place for all measurements
messung = 'Ramsey\\1stharm_corr\\repeat_afterVent\\4th_iter_p400mV\\'; % name of measurement
dt = datestr(now, 'yyyy-mm-dd_HH-MM');  % current date_time
ordner = [messordner,messung,dt]; % generating folderpath for measurement
mkdir(ordner);
cd(ordner); % change directory to 'ordner',
copyfile(workingFile, [mfilename,'.m'], 'f');

% Pre-configuration of instruments
% Connect to the devices
% Open_fsv;
% Open_Keith2401_2;
% AWG = ks_pfag_81150a;
% FG = ks_33500b;


%% Pre-define parameters
% Keithley SourceMeter 24001
keith_volt = -20.5; % [V]
keith_volt_init = -20.5;
keith_regstep_init = 20e-4; % voltage regulation step for resonance frequency regulation
keith_regstep = 20e-4; % voltage regulation step for resonance frequency regulation
% Keysight 33500b
NoiseAmplitudeLow = 0; % [dBm]
NoiseAmplitudeHigh = 14; % [dBm]
NoiseOffset = 0; % [V]
NoiseBW = 8e6; % [Hz]
NoiseUnit = 'DBM';
SineUnit = 'DBM';
SineAmplitude = -20;
% FSV
fsv_points = 2001;
fsv_sweeps_noise = 3;
fsv_bw_noise = 10; % pre-measurement bandwidth
fsv_points_low = 1001; % low number of points
fsv_points_high = 2001; % large number of points

fsv_span_noise0 = 20e3; % span for pre-noise measurement
fsv_span_noise = 5e3; % span for noise measurement
fsv_zerospan = 0; % span for ring down measurement

fsv_bw_reg = 100; % bandwidth for regulation measurement
fsv_sweeptime_reg = 1; % sweeptime for regulation measurement
fsv_sweeps_reg = 1; % sweep count for regulation measurement

average = 30; % number of averages
fres_init = 7.075e6;
% Keith2401
Keith2401_set_volt(Keith2401_2, keith_volt);
% Keysight 33500b (noise drive)
selectNoise(FG, NoiseUnit, NoiseAmplitudeLow, NoiseOffset, NoiseBW);
% FSV 
fsv_span(fsv, fsv_span_noise0); % set FSV span
fsv_sweeptype(fsv, 2.0); % FFT mode (2.0)
fsv_bw(fsv, fsv_bw_noise, fsv_points_high, 1.0, 1); % sweep time auto (1.0)
fsv_configMaxAvg(fsv, fsv_points, fres_init, fsv_span_noise0, fsv_sweeps_noise);

% Start to ramp up the noise drive
outp_on(FG, 1);
for ii = NoiseAmplitudeLow:1:NoiseAmplitudeHigh
    selectNoise(FG, NoiseUnit, ii, NoiseOffset, NoiseBW);
    pause(1)
end


%% Initial frequency regulation - noise driven resonance peak
                [a, f] = fsv_scan(fsv, fsv_points_high); % perform scan
                [~, pos] = max(a); % find position of maximum signal
                freg = f(pos); % frequency of signal peak
                delta = freg - fres_init; % frequency difference
                
                if delta > 0
                    while delta > 0
                        keith_volt = keith_volt - 2*keith_regstep_init; % change DC voltage
                        Keith2401_set_volt(Keith2401_2, keith_volt); % set new DC voltage
                        pause(2)
                        
                        [a, f] = fsv_scan(fsv, fsv_points_high); % perform scan
                        [~, pos] = max(a); % find position of maximum signal
                        freg = f(pos); % frequency of signal peak
                        delta = freg - fres_init; % define new delta
                    end
                    keith_volt = keith_volt + keith_regstep_init; % change DC voltage
                elseif delta < 0
                    while delta < 0
                        keith_volt = keith_volt + 2*keith_regstep_init; % change DC voltage
                        Keith2401_set_volt(Keith2401_2, keith_volt); % set new DC voltage
                        pause(2)
                        
                        [a, f] = fsv_scan(fsv, fsv_points_high); % perform scan
                        [~, pos] = max(a); % find position of maximum signal
                        freg = f(pos); % frequency of signal peak
                        delta = freg - fres_init; % define new delta
                    end
                    keith_volt = keith_volt - keith_regstep_init; % change DC voltage
                end

Keith2401_set_volt(Keith2401_2, keith_volt); % set appropriate DC voltage



%% Peak search for initiale and final resonance
[finitpeak1, ~] = AT_fsv_findpeak(fsv, fres_init, fsv_span_noise0);
[finitpeak2, finitfit2] = AT_fsv_findpeak(fsv, finitpeak1, fsv_span_noise);
disp(['1. Init Peak resonance frequency: ', num2str(finitpeak2/1e6, 7), ' MHz']); % show peak resonance frequency
disp(['1. Init Fit resonance frequency: ', num2str(finitfit2/1e6, 7), ' MHz']); % show fit resonance frequency

% calculate the ramp voltage "deltaU", AT_SweepAmp(initial frequency,
% initial value to find the right solution)
[~,deltaU] = AT_SweepAmp(finitfit2,-20);

% Keysight PFAG 81150A
AWGMode = 'DC';
AWGInitial = 0.014;

% Keysight PFAG 81150A (Ramsey Pulse)
TriggerMode = 'MAN';
AWG_Final_Voltage = deltaU+0.4;
AWGUnit = 'VPP';
AWGLevel = AWG_Final_Voltage/2;
AWGOffset = AWGLevel/2;
AWGWaveform = 'VOLATILE';% the ramp function is in the volatile memory 
                         %(use BenchLink WF Builder to create ramp function
% frequency use to determine initial and final frequency
AWGFreq_reg = 0.01;
% frequency for the actual measurement
AWGFreq = 110289/1e4;
% Other parameters
freq_res = finitfit2;
freq_delta = 25e2; % f_final - f_initial
c_eff = 23190; % conversion factor Hz/V 23190
V_final = keith_volt_init + (freq_delta)/(c_eff);
Delta_pulse = 2*abs(keith_volt_init - V_final)/AWG_Final_Voltage;
Delta_V = abs(keith_volt_init-V_final)/2+AWGInitial;
delay = 1;
%% Note: the ratio of ramp and waiting duration is 1: 10 000
% final measurement parameters
fsv_bw_meas = 20e2; % resolution bw of the spectrum analyzer
fsv_sweeptime = 10e-3; % ringdown time 
fsv_delay = 0; % put delay after the trigger for the FSV
fsv_level = 0.9; % trigger level
minsig = -75; % drive signal lower threshold
maxsig = -72;
count = 0;

%  Initialize the devices

% FSV 
fsv_span(fsv, fsv_span_noise0); % set FSV span
fsv_sweeptype(fsv, 2.0); % FFT mode (2.0)
fsv_bw(fsv, fsv_bw_noise, fsv_points_high, 1.0, 1); % sweep time auto (1.0)
fsv_configMaxAvg(fsv, fsv_points, freq_res, fsv_span_noise0, fsv_sweeps_noise);


% Create an arb. pulse and use Ramsey_pulse function to load in to AWG
c = [0.272035, 0, 0, 0];
d = [-0.815085, 0, 0,0];
[~,pulseform1] = Ramsey_pulse_3rdcorr(AWGFreq_reg,20,Delta_pulse,c,d);

% use function from iqtools (provide by Keysight)
iqdownload(pulseform1,AWGFreq_reg*5e5);

% functions from classdef ks_pfag_81150a.m
callArbVolatileFunc(AWG,1,AWGUnit, AWGLevel, AWGOffset, AWGWaveform,AWGFreq_reg);
setTriggerMode(AWG,TriggerMode);
pause(1)
% Initial fitparameters for resonance
[f_res, f_meas] = AT_Find_Init_Final_frequency_wf(fsv, AWG, freq_res, freq_delta, fsv_span_noise0, fsv_span_noise, delay);
freq_res = f_res; % define initialized resonance frequency new
fsv_freq_meas = f_meas; % define measurement frequency new
fsv_freq = freq_res; % scanning frequency of the FSV for the 2nd regulation
pause(1/AWGFreq_reg);
%creating wait time parameters (EVERYTHING IS IN UNITS OF us)
ncycles=4;
omegaest=43019;
twmax=ncycles/(omegaest)*1e6;
twmin=0;
npoints=30;
twstep = (twmax-twmin)/(npoints-1);
%time_start = 0;%waiting time start
%time_stop = 100;%waiting time stop
%time_points = 40;%sampling points for waiting time
%time_step = (time_stop-time_start)/(time_points-1);

%% Start the sweep for different waiting time
for k=twmin:twstep:twmax
    count = count + 1;
% Call Ramsey function Ramsey_pulse(frequency[Hz],waiting time [ms],offset) 

[~,pulseform] = Ramsey_pulse_3rdcorr(AWGFreq,k,Delta_pulse,c,d);
% Load function to AWG
iqdownload(pulseform,AWGFreq*5e5);
callArbVolatileFunc(AWG,1,AWGUnit, AWGLevel, AWGOffset, AWGWaveform,AWGFreq);

%% Start voltage regulation
    A = zeros(fsv_points_high, average); % amplitude matrix
    T = zeros(fsv_points_high, average); % time matrix
    S = zeros(average, 1); % signal matrix
    V = zeros(average, 1); % voltage matrix 
        for i = 1:average
     
        % Frequency regulation
        avg = minsig - 1;
        regcount = 0;
        
        while avg < minsig
       
            regcount = regcount + 1;
            
            if (regcount == 1) || (regcount > 5) || (avg < minsig - 5)
                regcount = 1;
                
                % Configuration of instruments for first frequency regulation (noise)
                selectNoise(FG, NoiseUnit, NoiseAmplitudeHigh, NoiseOffset, NoiseBW);
                
%                 pause(0.5)
                
                % FSV
                fsv_span(fsv, fsv_span_noise); % set FSV span
                fsv_sweeptype(fsv, 2.0); % FFT mode (2.0)
                fsv_bw(fsv, fsv_bw_noise, fsv_points_high, 1.0, 1); % sweep time auto (1.0)
                fsv_configMaxAvg(fsv, fsv_points_high, freq_res, fsv_span_noise, fsv_sweeps_noise); % configurate FSV
                % fsv_trigger(fsv, 0.0, 0, 1.0, 0); % disable external
                % trigger (0.0)  % enable when start the real measurement
                
                pause(1)
                
                %% First frequency regulation - noise driven resonance peak
                [a, f] = fsv_scan(fsv, fsv_points_high); % perform scan
                [~, pos] = max(a); % find position of maximum signal
                freg = f(pos); % frequency of signal peak
                delta = freg - freq_res; % frequency difference
                
                if delta > 0
                    while delta > 0
                        keith_volt = keith_volt - 2*keith_regstep; % change DC voltage
                        Keith2401_set_volt(Keith2401_2, keith_volt); % set new DC voltage
                        pause(2)
                        
                        [a, f] = fsv_scan(fsv, fsv_points_high); % perform scan
                        [~, pos] = max(a); % find position of maximum signal
                        freg = f(pos); % frequency of signal peak
                        delta = freg - freq_res; % define new delta
                    end
                    keith_volt = keith_volt + keith_regstep; % change DC voltage
                elseif delta < 0
                    while delta < 0
                        keith_volt = keith_volt + 2*keith_regstep; % change DC voltage
                        Keith2401_set_volt(Keith2401_2, keith_volt); % set new DC voltage
                        pause(2)
                        
                        [a, f] = fsv_scan(fsv, fsv_points_high); % perform scan
                        [~, pos] = max(a); % find position of maximum signal
                        freg = f(pos); % frequency of signal peak
                        delta = freg - freq_res; % define new delta
                    end
                    keith_volt = keith_volt - keith_regstep; % change DC voltage
                end
                
                Keith2401_set_volt(Keith2401_2, keith_volt); % set appropriate DC voltage
                
                %% Configuration of instruments for second frequency regulation (sine)
                % Ag33 B Channel 1 (Drive)
                
                for iii = NoiseAmplitudeHigh:-2:NoiseAmplitudeLow
                selectNoise(FG,NoiseUnit,iii,NoiseOffset,NoiseBW);
                pause(0.1)
                end
                outp_off(FG, 1);
                pause(1);
                selectSine(FG,SineUnit,SineAmplitude,freq_res,0); % (device,unit,amplitude,frequency,offset)
                outp_on(FG,1);
                
                pause(0.1)
                
                % FSV
                fsv_bw(fsv, fsv_bw_reg, fsv_points_low, 0.0, fsv_sweeptime_reg); % manual sweeptime (0.0)
                fsv_configMaxAvg(fsv, fsv_points_low, fsv_freq, fsv_zerospan, fsv_sweeps_reg); % configurate FSV
                
                pause(1)
            end
            
            %% Second frequency regulation - measurement of signal intensity
            control = 1;
            old_volt = 0;
            
           % while control > 5.5 * keith_regstep
                [a, ~] = fsv_scan(fsv, fsv_points_low); % perform scan
                avg = mean(a); % take average of signal
                old = avg; % define as old average value
                
                % Readjust DC voltage
                keith_volt = keith_volt + keith_regstep; % change DC voltage
                Keith2401_set_volt(Keith2401_2, keith_volt); % set new DC voltage
                pause(2)
                
                [a, ~] = fsv_scan(fsv, fsv_points_low); % perform scan
                avg = mean(a); % take average of signal
                diff = avg - old; % define difference of averages
                old = avg; % define as old average value
                
                if diff > 0 % (new signal higher than old signal)
                    while diff > 0 && old < -72
                        keith_volt = keith_volt + keith_regstep; % change DC voltage
                        Keith2401_set_volt(Keith2401_2, keith_volt); % set new DC voltage
                        pause(2)
                        
                        [a, ~] = fsv_scan(fsv, fsv_points_low); % perform scan
                        avg = mean(a); % take average of signal
                        diff = avg - old; % define difference of averages
                        old = avg; % define as old average value
                    end
                    keith_volt = keith_volt - keith_regstep; % change DC voltage one step back
                else % (new signal lower than old signal)
                    diff = 1;
                    while diff > 0 && old < -72
                        keith_volt = keith_volt - keith_regstep; % change DC voltage
                        Keith2401_set_volt(Keith2401_2, keith_volt); % set new DC voltage
                        pause(2)
                        
                        [a, ~] = fsv_scan(fsv, fsv_points_low); % perform scan
                        avg = mean(a); % take average of signal
                        diff = avg - old; % define difference of averages
                        old = avg; % define as old average value
                    end
                    keith_volt = keith_volt + keith_regstep; % change DC voltage one step back
                end
                
                Keith2401_set_volt(Keith2401_2, keith_volt); % set appropriate DC voltage
                pause(5)
                
                [a, ~] = fsv_scan(fsv, fsv_points_low); % perform scan
                avg = mean(a); % take average of signal
                
                control = abs(keith_volt - old_volt);
                old_volt = keith_volt;
            %end
        end
        
        disp([num2str(count), ' - ', num2str(i), ' - ', num2str(k),' us']);        
        disp(['Signal: ', num2str(avg), ' dBm']); % show average value
        disp(['DC voltage: ', num2str(keith_volt), ' V']); % show DC voltage
        disp(' ');
        
        S(i,1) = avg;
        V(i,1) = keith_volt;
        
        %% Configuration of instruments for main measurement
        % AWG should always be in trigger mode
        % a trigger will start the ramp pulse
        
        % FSV
        fsv_bw(fsv, fsv_bw_meas, fsv_points_high, 0.0, fsv_sweeptime); % manual sweeptime (0.0)
        fsv_configMaxAvg(fsv, fsv_points_high, fsv_freq_meas, fsv_zerospan, 1); % configurate FSV
        fsv_trigger(fsv, 1.0, fsv_delay, 1.0, fsv_level); % configurate FSV trigger (1.0 - external trigger, 1.0 - positiv polarity)
        fsv_startscan(fsv, 1.0, 1); % set FSV to contiouus sweep mode (1.0)
        
        pause(1)
        
        %% Main Measurement
        sendMANTrig(AWG); % send trigger to FSV and AWG 81150A starts to ramp up
        %pause(1)
        [A(:,i), T(:,i)] = fsv_readscan(fsv, fsv_points_high); % record scan
        
        figure(1)
        clf(1)
        plot(T(:,i), sqrt(50).* 10.^(A(:,i)./20 - 3/2),'-o');
        %plot(T(:,i), A(:,i)); % show measurement
        
        pause(5)
                
        fsv_trigger(fsv, 0.0, 0, 1.0, 0); % disable external trigger (0.0)
        fsv_startscan(fsv, 0.0, 1); % single sweep mode (0.0)
    
        end
%% Save the data
    amp(:, ((count-1)*average+1):(count*average)) = A; % save signal amplitude
    time = T(:,1); % save time
    
    volt(((count-1)*average+1):(count*average), 1) = V; % save DC voltage
    avgsig(((count-1)*average+1):(count*average), 1) = S; % save average signal        
end
    twpoints=twmin:twstep:twmax;    
    fname = strcat('Ramsey_1stharm_corr_data',append('_',num2str(twmin),'_us_to_',num2str(twmax),'_us.mat'));
    save(fname, 'amp','time','twpoints','volt', 'avgsig','fsv_freq');
    
% set back the parameters to initial conditions
    outp_off(FG,1); % turn off noise/sinusoidal drive
%     setTriggerMode(AWG,'IMM'); % set AWG to continuous mode
%     selectFunction(AWG, 1, AWGMode,AWGInitial); % set to DC Mode
    selectNoise(FG, NoiseUnit, NoiseAmplitudeLow, NoiseOffset, NoiseBW);
    Keith2401_set_volt(Keith2401_2, keith_volt_init);
    cd(workingDir); % change directory back to measurement-scripts
    disp(ordner)
    disp(datestr(now, 'yyyy-mm-dd_HH-MM'))