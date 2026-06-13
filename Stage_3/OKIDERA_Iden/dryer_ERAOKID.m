clc
clear
close all

%% Prepare the data
data = readmatrix('dryer.dat');
size(data)

u_sys = data(:,1)';
y_sys = data(:,2)';

r = 9;
numInputs = 1;
numOutputs = 1;
Ts = 0.01;

%% OKID
[H,M] = OKID(y_sys,u_sys,r);
mco = floor((length(H)-1)/2);  % m_c = m_o

%% ERA
[Ar,Br,Cr,Dr] = ERA(H,numInputs,numOutputs,mco,mco,r);
sysERAOKID = ss(Ar,Br,Cr,Dr,Ts);

%% Plot impulse responses for all methods
N = length(u_sys);

u_sys = u_sys.';
y_sys = y_sys.';

t = (0:N-1) * Ts;
y_hat = lsim(sysERAOKID, u_sys, t);

figure
plot(y_sys,'k','LineWidth',1.5)
hold on
plot(y_hat,'r--','LineWidth',1.5)
grid on
legend('Measured output','ERA model output')
title('ERA Validation')
xlabel('Time step')
ylabel('Output')

%% Validation
fit = 100*(1 - norm(y_sys - y_hat)/norm(y_sys - mean(y_sys)));
disp(['Fit = ', num2str(fit), ' %'])

%% Frequency Domain
figure
bode(sysERAOKID)
grid on
title('ERA Model Frequency Response')