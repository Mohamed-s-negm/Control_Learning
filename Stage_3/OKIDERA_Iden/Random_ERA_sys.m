clc
clear
close all

%% Parameters

m = 1;
c = 2;
k = 10;

%% State Space

A = [0 1;
    -k/m -c/m];

B = [0;
     1/m];

C = [1 0];

D = 0;

sys_true = ss(A,B,C,D);

%% Impulse Response
Ts = 0.01;

t = 0:Ts:10;

sysd = c2d(sys_true,Ts);

[y,t] = impulse(sysd);
y = squeeze(y);

%% ERA Hankel Matrices
s = 50;

H0 = hankel(y(1:s),y(s:2*s-1));

H1 = hankel(y(2:s+1),y(s+1:2*s));

%% SVD
[U,S,V] = svd(H0);

figure
semilogy(diag(S),'o-')
grid on
xlabel('Index')
ylabel('Singular Value')
title('ERA Singular Values')


%% Truncation
r = 2;
Ur = U(:,1:r);

Sr = S(1:r,1:r);

Vr = V(:,1:r);

%% Model Recovery
Or = Ur*sqrtm(Sr);
Cr = sqrtm(Sr)*Vr';

A_era = Sr^(-0.5)*Ur'*H1*Vr*Sr^(-0.5);

B_era = Cr(:,1);
C_era = Or(1,:);
D_era = 0;

sys_era_d = ss(A_era,B_era,C_era,D_era,Ts);
sys_era = d2c(sys_era_d);


%% Compare Responses
[y_true,t_true] = impulse(sys_true,t);
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

%% Compare Poles
eig(sysd.A)
eig(A_era)

%% plots
G_true = tf(sysd)

G_era = tf(sys_era_d)

dcgain(sysd)

dcgain(sys_era_d)