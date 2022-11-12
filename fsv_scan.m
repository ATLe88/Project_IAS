function [ act_amp, act_freq ] = fsv_scan(device, points)
% This function performs a sweep with the fsv and gives back the frequency and amplitude of the trace
% Configuration has to be done before via fsv_config

% Defining values
window = 1;
trace = 1;
timeoutMs = 15000000;

% Initialize arrays
act_amp = zeros(points, 1);
act_freq = zeros(points, 1);

groupObj = get(device, 'Measurement');
groupObj = groupObj(1);

% Performs a sweep and reads the y-values via the library command readytrace
[~, act_amp] = invoke(groupObj, 'readytrace', window, trace, timeoutMs, points, act_amp);
% Records the frequencies(x-values) from the last measured trace
[~, act_freq] = invoke(groupObj, 'fetchxtrace', trace, points, act_freq);

end