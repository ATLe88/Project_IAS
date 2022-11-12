function [yfit,coef,dcoef] = LorentzFit(freq, sig, start)
%LorentzFit Fit linear data with mechanical suzceptibility (data in V proportional to displacement)

x = reshape(freq,length(freq),1); % Create array with frequency data
y = reshape(sig,length(sig),1); % Create array with signal

[~,P]=max(y); % Search maximum of signal
if isempty(start) % Fill default start parameter (quality, drive power, f_res, noise level p1, noise level p2)
    start = [75000 1e8 x(P) 0 1];
else
    start(3) = x(P); % Maximum as start parameter for eigenfrequency
end
opts = statset('MaxIter',5000,'TolX',1e-12,'TolFun',1e-18,'TolBnd',1e-15); % Fit options

florentz= @(param,x)( complex( abs((param(1).*param(2))./(param(1).*x.^2-1i.*x.*param(3)-param(1).*param(3).^2)+abs(param(4))*exp(1i*param(5))))); % Fit function complex Lorentzian

warning('off')
mdl = fitnlm(x,y,florentz,start,'Options',opts); % Perform the fitting

coef = nan(size(mdl.Coefficients,1),1); % Exctact the coefficients
dcoef = nan(size(mdl.Coefficients,1)+1,1); % Standard error of coefficients
for k=1:size(mdl.Coefficients,1)
    coef(k)=mdl.Coefficients{k,1};
    dcoef(k)=mdl.Coefficients{k,2};
end
dcoef(end) = mdl.Rsquared.Adjusted;
yfit = mdl.Fitted; % Generate fit line
end
