function [] = fsv_span(device, freq_span)
% This function sets the frequency span of the FSV4 Spectrum analyzer

% window = 1;
% sweepModeCont = 0;

% groupObj = get(device, 'Configuration');
% groupObj = groupObj(1);
% invoke(groupObj, 'configureacquisition', instr_window, sweepModeCont, sweep_number);

% groupObj = get(device, 'Configuration');
% groupObj = groupObj(1);
% invoke(groupObj, 'configuresweeppoints', instr_window, sweep_points);

set(device.Basicoperation(1), 'Frequency_Span', freq_span);

% groupObj = get(device, 'Configuration');
% groupObj = groupObj(1);
% invoke(groupObj, 'configurefrequencycenterspan', window, center_freq, freq_span);

end

