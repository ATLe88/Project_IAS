function [] = fsv_startscan(device, modevalue, sweepnumber)
% This function starts a single sweep with the FSV
% 0.0 - single sweep, 1.0 - continuous sweep

window = 1;
timeoutMs = 15000000;

groupObj = get(device, 'Configuration');
groupObj = groupObj(1);
invoke(groupObj, 'configureacquisition', window, modevalue, sweepnumber);

groupObj = get(device, 'Measurementlowlevelmeasurement');
groupObj = groupObj(1);
invoke(groupObj, 'initiate', window, timeoutMs);

end