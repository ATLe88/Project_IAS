function [] = fsv_sweeptype( device, type)
% This function sets the FSV into a specified sweep Mode
% 0.0 - Auto FFT, 1.0 - Sweep, 2.0 - FFT

set(device.Basicoperation(1), 'Sweep_Type', type);

end

