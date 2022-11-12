function [] = fsv_bw(device, bandwidth, sweeppoints, sweepvalue, sweeptime)
% This function defines the bandwidth and sweeptime of the FSV
% 1.0 - sweep time auto, 0.0 - sweep time manual

% defining resolution bandwidth
set(device.Basicoperation, 'Resolution_Bandwidth', bandwidth);

% setting sweep points
window = 1;
groupObj = get(device, 'Configuration');
groupObj = groupObj(1);
invoke(groupObj, 'configuresweeppoints', window, sweeppoints);

% setting sweeptime
if sweepvalue == 1
    set(device.Basicoperation, 'Sweep_Time_Auto', 1.0);
elseif sweepvalue == 0
    set(device.Basicoperation, 'Sweep_Time_Auto', 0.0);
    set(device.Basicoperation, 'Sweep_Time', sweeptime);
end

% groupObj = get(device, 'Configuration');
% groupObj = groupObj(1);
% invoke(groupObj, 'configuresweeptime', window, sweepvalue, sweeptime);

end