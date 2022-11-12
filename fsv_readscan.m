function [ act_amp, act_freq ] = fsv_readscan(device, points)
% This function performs a sweep with the fsv and gives back the frequency and amplitude of the trace
% Configuration has to be done before via fsv_config

% Defining values
fsv_window = 1;
fsv_trace = 1;

% Initialize arrays
act_amp = zeros(points, 1);
act_freq = zeros(points, 1);

groupObj = get(device, 'Measurement');
groupObj = groupObj(1);

% Records the amplitudes (y-values) from the last measured trace
[~, act_amp] = invoke(groupObj, 'fetchytrace', fsv_window, fsv_trace, points, act_amp);
% Records the frequencies (x-values) from the last measured trace
[~, act_freq] = invoke(groupObj, 'fetchxtrace', fsv_trace, points, act_freq);
end