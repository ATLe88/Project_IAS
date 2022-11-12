function [f_res_init, f_res_final] = AT_Find_Init_Final_frequency_wf(device1, device2, fres, fdelta, span1, span2, delay)
% Pre-Measurement of the Landau Zener in order to localize the positions of the
% initiate and measurement resonances. Use AWG in DC mode to increase to
% the final voltage

fmeas = fres + fdelta;


% Peak search for initiale resonance
[finitpeak1, ~] = AT_fsv_findpeak(device1, fres, span1);
[finitpeak2, finitfit2] = AT_fsv_findpeak(device1, finitpeak1, span2);

disp(['2. Init Peak resonance frequency: ', num2str(finitpeak2/1e6, 7), ' MHz']); % show peak resonance frequency
disp(['2. Init Fit resonance frequency: ', num2str(finitfit2/1e6, 7), ' MHz']); % show fit resonance frequency

% Configurate Keith2401
% Keith2401_setdc_fine(device2, dcV, dcV + stopV);
% pause(delay)

% Configure AWG 81150A (function in classdef)
% setdc_fine(device2, dcV, dcV + stopV);
% pause(delay)
sendMANTrig(device2);
pause(delay)
% Peak search for measurement resonance

[fmeaspeak1, ~] = AT_fsv_findpeak(device1, fmeas, span1);
[fmeaspeak2, fmeasfit2] = AT_fsv_findpeak(device1, fmeaspeak1, span2);

disp(['Peak measurement final frequency: ', num2str(fmeaspeak2/1e6, 7), ' MHz']); % show peak measurement frequency
disp(['Fit measurement  final frequency: ', num2str(fmeasfit2/1e6, 7), ' MHz']); % show fit measurement frequency

% Back configuration of AWG 81150A
% Keith2401_setdc_fine(device2, dcV + stopV, dcV);
% pause(delay)
% setdc_fine(device2, dcV + stopV, dcV);
% pause(delay)


f_res_init = finitpeak2;
f_res_final = fmeaspeak2;
end