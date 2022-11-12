function [fpeak, ffit] = AT_fsv_findpeak(device, freq, span)
% This function performs searchs for a peak in the given frequency intervall and gives back the peak frequency
% 0 - no saving, 1 - saving initiated resonance, 2 - saving measurment
% resonance

window = 1;
% bw = 10;
points = 2001;
sweepmode = 0.0;
sweeps = 3;

trace = 1;
timeoutMs = 15000000;
a = zeros(points, 1);
f = zeros(points, 1);

% set span and sweeptype to FFT
set(device.Basicoperation(1), 'Frequency_Span', span);
set(device.Basicoperation(1), 'Sweep_Type', 2.0);

% set bandwidth to 10 Hz and sweep points to 2001 and automatic sweep time
% set(device.Basicoperation, 'Resolution_Bandwidth', bw);

groupObj = get(device, 'Configuration');
groupObj = groupObj(1);
invoke(groupObj, 'configuresweeppoints', window, points);

set(device.Basicoperation, 'Sweep_Time_Auto', 1.0);

% configurate sweep (continuous sweep mode, threefold sweep, centerfrequency
% and span)
groupObj = get(device, 'Configuration');
groupObj = groupObj(1);
invoke(groupObj, 'configureacquisition', window, sweepmode, sweeps);

check = 1;
while abs(check - 1000) > 10 
    groupObj = get(device, 'Configuration');
    groupObj = groupObj(1);
    invoke(groupObj, 'configurefrequencycenterspan', window, freq, span);
    
    pause(2)

    % performing scan
    groupObj = get(device, 'Measurement');
    groupObj = groupObj(1);
    [~, a] = invoke(groupObj, 'readytrace', window, trace, timeoutMs, points, a);
    [~, f] = invoke(groupObj, 'fetchxtrace', trace, points, f);

    % find peak
    [~, pos] = max(a); % find position of maximum signal
    if abs(pos - 1000) < 800
        freq = f(pos); % define resonance frequency as frequency of signal peak
    end
    check = pos;
end

% define peak frequency
fpeak = freq;

% define fit frequency
lindata = [f, 10.^( a ./ 20 - 3/2)]; % linearise signal for fitting
[yfit,coef,dcoef] = LorentzFit(lindata(:,1), lindata(:,2),[]);
ffit = coef(3); % resonance frequency from fit

figure(1);
clf(1)
plot(lindata(:,1),lindata(:,2)); % plot measured data
hold on
plot(lindata(:,1),yfit); % plot fit data


end