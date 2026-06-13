clc
clear
close all

%% Active Suspension
A = 1.0e+03 * [0 0.001 0 0;
    -0.0652 -0.0060 0.0713 0.0040;
    0 0 0 0.0010;
    0.3262 0.0300 -4.1565 -0.0198];

B = [0;
    0;
    0;
    3800];

C = eye(4);

D = zeros(4,1);

sys_True = ss(A, B, C, D);
%% Impulse Response
Ts = 0.01;

t = 0:Ts:10;

sysd = c2d(sys_True,Ts);

[yFull,t] = impulse(sysd,t);
YY = permute(yFull,[2 3 1]);

%% ERA Hanekl Matrices
mco = floor((length(yFull)-1)/2);  % m_c = m_o
m = mco;
n = mco;
nout = size(C, 1); % number of outputs (4)
nin = size(B, 2); % number of inputs (1)
r = 4;

[A_era, B_era, C_era, D_era] = ERA(YY, nin, nout, m, n, r);

sys_era_d = ss(A_era, B_era, C_era, D_era, Ts);
sys_era = d2c(sys_era_d);

%% Compare Responses
[y_true,t_true] = impulse(sys_True,t);
[y_era,t_era] = impulse(sys_era,t);

figure

plot(t_true,y_true,'LineWidth',2)
hold on

plot(t_era,y_era,'--','LineWidth',2)

grid on

legend('True System','ERA Model')

xlabel('Time (s)')
ylabel('Output')

title('Impulse Response Comparison')

hold off
grid off

%% Compare Poles (Discrete-Time)
disp('--- Discrete True Poles ---')
disp(eig(sysd.A))

disp('--- Discrete ERA Poles ---')
disp(eig(sys_era_d.A)) 

%% plots
G_true = tf(sysd)

G_era = tf(sys_era_d)

dcgain(sysd)

dcgain(sys_era_d)