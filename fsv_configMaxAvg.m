function [] = fsv_configMaxAvg(device, sweep_points, center_freq, freq_span, sweep_number)
% This function configures the FSV4 Spectrum analyzer for measurement
%   These values in this function have to be set before performing the
%   fsv_freqscan sweep
%% simple settings
% set instrument to single sweep
instr_window = 1;
instr_sweepModeCont = 0;
%instr_numOfSweeps = 1;
%% Calling the VXIpnp Driver library under point configuration
groupObj = get(device, 'Configuration');
groupObj = groupObj(1);
invoke(groupObj, 'configureacquisition', instr_window, instr_sweepModeCont, sweep_number);
% configure sweep points
instr_sweepPoints = sweep_points;
groupObj = get(device, 'Configuration');
groupObj = groupObj(1);
invoke(groupObj, 'configuresweeppoints', instr_window, instr_sweepPoints);
% configure RF parameters
instr_freqCenter = center_freq;
instr_freqSpan = freq_span;
groupObj = get(device, 'Configuration');
groupObj = groupObj(1);
invoke(groupObj, 'configurefrequencycenterspan', instr_window,instr_freqCenter, instr_freqSpan);

end

