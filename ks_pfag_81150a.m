% this classdef is still under construction. Use SCPI commands to control
% the device
classdef ks_pfag_81150a < handle
    %KS_PFAG_81150A Class to control the Keysight Pulse Function Arbitrary
    %Generator
    properties
        dev         % device object
        stat        % status bit, '0': no error, '1': error occured
        msg         % error message
    end
    
    
    methods
            function obj = ks_pfag_81150a()
            %KS3 Connect to the device and create the object
            load([userpath '\ips.mat'],'ips'); % Load local file with IP adresses
            % Find a VISA-TCPIP object.
            device = instrfind('Type', 'visa-tcpip', 'RsrcName', ips.ks_pfag_81150a, 'Tag', '');
            % Create the VISA-TCPIP object if it does not exist
            % otherwise use the object that was found.
            if isempty(device)
                device = visa('NI', ips.ks_pfag_81150a);
            else
                fclose(device);
                device = device(1);
            end
            fopen(device); % Connect to instrument object
            %fprintf(device, ':SYST:COMM:RLST REM'); % set the device to remote state
            %fprintf(device,'*RST'); % reset the device
            fprintf(device,'DISP On'); % switch off the automatic update of the display to increase the programming speed
            obj.dev = device;
            end
            
            function errorcheck(obj)
                % Read the status bit and error message
                status = query(obj.dev, '*STB?');
                obj.stat = status(2);
                if (obj.stat ~= '0')
                obj.msg = query(obj.dev, ':SYSTem:ERRor?');
                end
            end
            
            function disconnect(obj)
                fclose(obj.dev);
                obj.dev = [];
            end
            function outp_on(obj, channel)
            %OTP_ON Turn on the device output
            %fprintf(obj.dev, 'OUTPut:SYNC ON'); %Turn on the trigger output
            fprintf(obj.dev, [':OUTP' num2str(channel) ' ON']);
            errorcheck(obj);
            end
            
            function outp_off(obj, channel)
            %OTP_ON Turn on the device output
            fprintf(obj.dev, [':OUTPut' num2str(channel) ' OFF']);
            errorcheck(obj);
            end
            
            function selectFunction(obj, channel, name,offset)
            % Set the desired output function. 
            %   #1 name [string]: {SINusoid|SQUare|RAMP|PULSe|NOISe|USER|DC}
            fprintf(obj.dev, ['SOURce' num2str(channel) ':FUNCtion ' name]);
            fprintf(obj.dev, ['VOLT:OFFS ',num2str(offset)]);
            end
            
            function setDCOffset(obj,offset)
            fprintf(obj.dev, ['VOLT:OFFS ',num2str(offset)]);
            end
            
            function setdc_fine(obj, start, stop)
                if start < stop
                    for dcvolt = start:0.01:stop % set DC voltage to measurement value
                    setDCOffset(obj, dcvolt);
                    pause(0.01)
                    end
                elseif stop < start
                    for dcvolt = start:-0.01:stop % set DC voltage to measurement value
                    setDCOffset(obj, dcvolt);
                    pause(0.01)
                    end
                end

            end
            
            function setvoltage(obj, unit, level, offset)
            % set unit VPP|VRMS|DBM, caution put prime(') 'unit' when defining the
            % unit
            outp_off(FG,1);
            fprintf(obj.dev, ['VOLT:AMPL ',num2str(level)]);
            fprintf(obj.dev, ['VOLT:OFFS ',num2str(offset)]);
            end
            
            function callArbVolatileFunc(obj,channel,unit, level, offset, waveform,freq)
            % set unit VPP|VRMS|DBM caution put prime(') 'unit' when defining the
            % unit
            % pre-defined arb. build-in waveform: EXP_RISE, EXP_FALL, HAVERSINE, SINC, CARDIAC, VOLATILE, GAUSSIAN, NEG_RAMP
            fprintf(obj.dev, ['VOLT:UNIT ',num2str(unit)]);
            fprintf(obj.dev, ['VOLT:AMPL ',num2str(level)]);
            fprintf(obj.dev, ['VOLT:OFFS ',num2str(offset)]);
            fprintf(obj.dev, ['SOURce' num2str(channel) ':FUNCtion USER']);
            fprintf(obj.dev, [':FUNC1:USER ',num2str(waveform)]);
            fprintf(obj.dev, ['FREQ ',num2str(freq)]);
            end
            
            function setTriggerMode(obj,mode)
            %set trigger mode {IMMediate|INTernal[1]|INTernal[2]|EXTernal|BUS| MANual}
                fprintf(obj.dev, ['ARM:SOUR1 ',num2str(mode)]);
            end
            
            function sendMANTrig(obj)
                fprintf(obj.dev, ':TRIG');
            end
           
         
    end
    
end