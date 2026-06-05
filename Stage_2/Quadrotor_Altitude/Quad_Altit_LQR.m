clc;
clear;
close all;

%% Assign Parameters

m = 1;
g = 9.81;

Rm = 0.5;      % Motor resistance
L = 1e-3;

K_t = 0.02;
K_e = 0.02;

J = 1e-4;

b = 1e-5;

K_f = 1e-5;
K_q = 1e-6;

%% Compute equilibrium states

omega_e = sqrt((m*g)/(4*K_f));
omega_e_rpm = omega_e*60/(2*pi);

i_e = (b*omega_e + K_q*omega_e^2)/(K_t);

u_e = Rm*i_e + K_e*omega_e;

%% Linearized system

A = [0 1 0 0;
     0 0 0 (8*K_f/m)*omega_e;
     0 0 -Rm/L -K_e/L;
     0 0 K_t/J (-b/J - 2*K_q*omega_e/J)];

B = [0;
     0;
     1/L;
     0];

C = [1 0 0 0];
D = 0;

sys = ss(A,B,C,D);

%% Analysis

disp('Open-loop poles:')
eig(A)

Co = ctrb(A,B);
disp('Controllability rank:')
rank(Co)

Ob = obsv(A,C);
disp('Observability rank:')
rank(Ob)

%% LQR

Q = diag([1000 100 1 1]);
R_lqr = 1;

K = lqr(A,B,Q,R_lqr)

%% Closed-loop system

Acl = A - B*K;

disp('Closed-loop poles:')
eig(Acl)

sys_cl = ss(Acl,B,C,D);

%% Initial Condition Response

t = 0:0.001:5;

x0 = [0.1;
      0;
      0;
      0];

[y,t,x] = initial(sys_cl,x0,t);

figure
subplot(4,1,1)
plot(t,x(:,1),'LineWidth',1.5)
grid on
ylabel('Altitude')

subplot(4,1,2)
plot(t,x(:,2),'LineWidth',1.5)
grid on
ylabel('Velocity')

subplot(4,1,3)
plot(t,x(:,3),'LineWidth',1.5)
grid on
ylabel('Current')

subplot(4,1,4)
plot(t,x(:,4),'LineWidth',1.5)
grid on
ylabel('Omega')
xlabel('Time (s)')

sgtitle('LQR Initial Condition Response')

%% Control Effort

u = -K*x';

figure
plot(t,u,'LineWidth',1.5)
grid on
xlabel('Time (s)')
ylabel('Voltage Perturbation')
title('LQR Control Effort')

%% Observer Design

observer_poles = [-20 -25 -30 -35];

Lobs = place(A',C',observer_poles)'

%% Observer Error Dynamics

Aobs = A - Lobs*C;

disp('Observer poles:')
eig(Aobs)

%% Observer Error Simulation

e0 = [0.1;
      0.1;
      1;
      10];

sys_obs = ss(Aobs,[],eye(4),[]);

[e,tobs] = initial(sys_obs,e0,t);

figure
subplot(4,1,1)
plot(tobs,e(:,1),'LineWidth',1.5)
grid on
ylabel('e_x')

subplot(4,1,2)
plot(tobs,e(:,2),'LineWidth',1.5)
grid on
ylabel('e_v')

subplot(4,1,3)
plot(tobs,e(:,3),'LineWidth',1.5)
grid on
ylabel('e_i')

subplot(4,1,4)
plot(tobs,e(:,4),'LineWidth',1.5)
grid on
ylabel('e_\omega')
xlabel('Time (s)')

sgtitle('Observer Error Convergence')

%% Step Response (Disturbance Input)

figure
step(sys_cl,5)
grid on
title('Closed-Loop Step Response')
ylabel('Altitude')