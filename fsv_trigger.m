function [] = fsv_trigger(device, mode, delay, polarity, level)
% defines trigger
% mode: 0.0 - free run, 1.0 - external, 2.0 - IF power
% polarity: 0.0 - negative, 1.0 - positive

window = 1;

groupObj = get(device, 'Configurationtrigger');
groupObj = groupObj(1);
invoke(groupObj, 'configuretriggersource', window, mode);

invoke(groupObj, 'configuretrigger', window, delay, polarity);

if mode == 1
    invoke(groupObj, 'configureexternaltrigger', window, level);
end

% set(device.Trigger(1), 'Trigger_Source', 0.0);
end