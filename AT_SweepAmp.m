function [X,deltaU] = AT_SweepAmp(f,Var)
kappa0 = 0.09140777495737493;
k1 =  -0.000257302856496472;
k2 = 0.0003476142363452517;
lambda1 = 9.253057865658614e-6;
lambda2 = -0.000012962566637857543;
kappac = 0.0006030296533052216;
U0 = -7.55872128877901;

rho0 = 2800; 
L0 = 49e-6; 
b0 = 250e-9; 
d0 = 100e-9;
meffinit = rho0*L0*b0*d0./2;

F1 = @(U) sqrt((kappa0+k1.*(U-U0)+lambda1.*(U-U0).^2+kappac)./meffinit);
F2 = @(U) sqrt((kappa0+k2.*(U-U0)+lambda2.*(U-U0).^2+kappac)./meffinit);
F3 = @(U) sqrt(kappac.^2./(meffinit.^2.*F1(U).*F2(U)));
syms U
X(U) = vpasolve(f^2 - abs(0.5.*((F1(U).^2+F2(U).^2)-...
    sqrt((F1(U).^2-F2(U).^2).^2+4.*F3(U).^2.*F1(U).*F2(U))))==0,U,Var);
% taken from Mathematica file Avoided crossing fit
deltaUsym = abs(X(U)) -abs(U0);
deltaU = double(deltaUsym);
X = double(X);






