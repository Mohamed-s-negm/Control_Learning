clc;
clear;
close all;

%% Parameters
M = 0.5;   % cart mass (kg)
m = 0.2;   % pole mass (kg)
l = 0.3;   % pole length (m)
g = 9.81;  % gravity (m/s^2)

%% State-Space Model

A = [0 1 0 0;
     0 0 (m*g)/M 0;
     0 0 0 1;
     0 0 (g*(M+m))/(M*l) 0];

B = [0;
     1/M;
     0;
     1/(M*l)];

C = eye(4);
D = zeros(4,1);

sys = ss(A,B,C,D);

%% Controllability

Co = ctrb(A,B);
rank_Co = rank(Co);

fprintf('Controllability Rank = %d\n',rank_Co);

%% Open-loop poles

disp('Open-loop poles:')
eig(A)

%% LQR Controller

Q = diag([10 1 100 1]);
R = 0.1;

K_lqr = lqr(A,B,Q,R);

disp('LQR Gain:')
disp(K_lqr)

%% Closed-loop System

Acl = A - B*K_lqr;

sys_cl = ss(Acl,B,C,D);

disp('Closed-loop poles:')
eig(Acl)

%% ====================================================
%% Initial Condition Response
%% ====================================================

x0 = [0;
      0;
      0.1;
      0];      % 0.1 rad (~5.7 deg)

t = 0:0.01:10;

[y,t,x] = initial(sys_cl,x0,t);

figure;

subplot(2,2,1)
plot(t,x(:,1),'LineWidth',1.5)
grid on
title('Cart Position')
xlabel('Time (s)')
ylabel('x (m)')

subplot(2,2,2)
plot(t,x(:,2),'LineWidth',1.5)
grid on
title('Cart Velocity')
xlabel('Time (s)')
ylabel('x dot (m/s)')

subplot(2,2,3)
plot(t,x(:,3),'LineWidth',1.5)
grid on
title('Pole Angle')
xlabel('Time (s)')
ylabel('\theta (rad)')

subplot(2,2,4)
plot(t,x(:,4),'LineWidth',1.5)
grid on
title('Angular Velocity')
xlabel('Time (s)')
ylabel('\theta dot (rad/s)')

sgtitle('LQR Stabilization from Initial Disturbance')

%% ====================================================
%% Step Response
%% ====================================================

t = 0:0.01:10;

[y_step,t_step,x_step] = step(sys_cl,t);

figure;

subplot(2,2,1)
plot(t_step,squeeze(y_step(:,1,:)),'LineWidth',1.5)
grid on
title('Cart Position')

subplot(2,2,2)
plot(t_step,squeeze(y_step(:,2,:)),'LineWidth',1.5)
grid on
title('Cart Velocity')

subplot(2,2,3)
plot(t_step,squeeze(y_step(:,3,:)),'LineWidth',1.5)
grid on
title('Pole Angle')

subplot(2,2,4)
plot(t_step,squeeze(y_step(:,4,:)),'LineWidth',1.5)
grid on
title('Angular Velocity')

sgtitle('Closed-Loop Step Response')