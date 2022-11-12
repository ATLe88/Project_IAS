% this classdef is still under construction. Use SCPI commands to control
% the device
classdef ks_33500b < handle
    %KS_33500b Class to control the Keysight 33500b Series Waveform
    %Generator Trueform
    
    properties
        dev         % device object
        stat        % status bit, '0': no error, '1': error occured
        msg         % error message
    end
    
    
    methods
            function obj = ks_33500b()
            %KS3 Connect to the device and create the object
            load([userpath '\ips.mat'],'ips'); % Load local file with IP adresses
            % Find a VISA-TCPIP object.
            device = instrfind('Type', 'visa-tcpip', 'RsrcName', ips.ks_33500b, 'Tag', '');
            % Create the VISA-TCPIP object if it does not exist
            % otherwise use the object that was found.
            if isempty(device)
                device = visa('NI', ips.ks_33500b);
            else
                fclose(device);
                device = device(1);
            end
            fopen(device); % Connect to instrument object
            
            %fprintf(device,'*RST'); % reset the device
            fprintf(device,'DISP On'); % switch off the automatic update of the display to increase the programming speed
            obj.dev = device;
            end
            
            function errorcheck(obj)
            %ERCHK Read the status bit and error message
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
           
            function selectSine(obj,unit,amp,freq,offset)
                % select functions {SINusoid|SQUare|TRIangle|RAMP|PULSe|PRBS|NOISe|DC}
                fprintf(obj.dev, ['VOLT:UNIT ', unit]);
                fprintf(obj.dev, ('SOURce1:FUNCtion SINusoid'));
                fprintf(obj.dev,['SOURce1:VOLTage ' num2str(amp)]);
                fprintf(obj.dev,['SOURce1:FREQuency ' num2str(freq)]);
                fprintf(obj.dev,['SOURce1:VOLTage:OFFset ' num2str(offset)]);
            end
            
            function selectDC(obj,offset)
                
                fprintf(obj.dev, ('SOURce1:FUNCtion DC'));
                fprintf(obj.dev,['SOURce1:VOLTage:OFFset ' num2str(offset)]);
             
            end
            function selectSquare(obj,unit,amp,freq,offset,dutycycle)
                fprintf(obj.dev, ['VOLT:UNIT ', unit]);
                fprintf(obj.dev,['SOURce1:VOLTage ' num2str(amp)]);
                fprintf(obj.dev, ('SOURce1:FUNCtion SQUare'));
                fprintf(obj.dev,['SOURce1:FREQuency ' num2str(freq)]);
                fprintf(obj.dev,['SOURce1:VOLTage:OFFset ' num2str(offset)]);
                fprintf(obj.dev, ['SOURce1:FUNC:SQU:DCYC ' num2str(dutycycle)]);
            end
            
            function selectNoise(obj,unit,amplitude,offset,bandwidth)
                fprintf(obj.dev, ['VOLT:UNIT ', unit]);
                fprintf(obj.dev, ('SOURce1:FUNCtion NOISe'));
                fprintf(obj.dev,['SOURce1:VOLTage ' num2str(amplitude)]);
                fprintf(obj.dev,['SOURce1:VOLTage:OFFset ' num2str(offset)]);
                fprintf(obj.dev, ['SOURce1:FUNCtion:NOISe:BANDwidth ' num2str(bandwidth)]);
            end
          
            function burst_mode(obj,state,ncycle)
                % burst mode state ON | OFF
                     fprintf(obj.dev,'SOUR:BURS:MODE TRIG}');
                     fprintf(obj.dev,['SOUR1:BURS:STAT ',state]);
                     fprintf(obj.dev,['BURS:NCYC ',num2str(ncycle)]);
            end
            function set_trigger(obj,source)
                % {IMMediate|EXTernal|TIMer|BUS}
                fprintf(obj.dev,['TRIG:SOUR ',source]);
                fprintf(obj.dev,'BURS:STAT ON');
                fprintf(obj.dev,'BURS:MODE TRIG');
                fprintf(obj.dev,'OUTP:TRIG ON');
                
            end
            
            function sendMANTrig(obj)
                
                fprintf(obj.dev, ':TRIG');
            end
            
    end
end