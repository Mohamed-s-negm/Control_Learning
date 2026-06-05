clc;
clear;
close all;

%% ==========================================================
% Parameters
%% ==========================================================

m = 0.05;      % kg
g = 9.81;      % m/s^2

R = 10;        % Ohm
L = 0.1;       % H

%% Desired levitation height

h = 0.01;      % m

%% Choose equilibrium current

ie = 1;        % A

%% Magnetic constant

k = m*g*h^2/ie^2;

%% Equilibrium values

x1e = h;
x2e = 0;
x3e = ie;

ue = R*ie;

%% ==========================================================
% Linearized State-Space Model
%% ==========================================================

A = [0 1 0;
     (2*k*x3e^2)/(m*x1e^3) 0 (-2*k*x3e)/(m*x1e^2);
     0 0 -R/L];

B = [0;
     0;
     1/L];

C = [1 0 0];
D = 0;

disp('A Matrix')
disp(A)

disp('B Matrix')
disp(B)

%% ==========================================================
% Open Loop Analysis
%% ==========================================================

disp('Open-loop poles:')
disp(eig(A))

%% ==========================================================
% Controllability
%% ==========================================================

Co = ctrb(A,B);

rank_Co = rank(Co);

fprintf('\nControllability Rank = %d\n',rank_Co);

if rank_Co == size(A,1)
    disp('System is Controllable')
else
    disp('System is NOT Controllable')
end

%% ==========================================================
% Observability
%% ==========================================================

Ob = obsv(A,C);

rank_Ob = rank(Ob);

fprintf('\nObservability Rank = %d\n',rank_Ob);

if rank_Ob == size(A,1)
    disp('System is Observable')
else
    disp('System is NOT Observable')
end

%% ==========================================================
% LQR Design
%% ==========================================================

Q = diag([1000 10 1]);
R_lqr = 1;

K = lqr(A,B,Q,R_lqr);

disp('LQR Gain K:')
disp(K)

%% ==========================================================
% Closed Loop System
%% ==========================================================

Acl = A - B*K;

disp('Closed-loop poles:')
disp(eig(Acl))

%% ==========================================================
% Initial Condition Response
%% ==========================================================

sys_cl = ss(Acl,[],eye(3),[]);

t = 0:0.001:1;

% 1 mm position disturbance
x0 = [0.001;
      0;
      0];

[y,t,x] = initial(sys_cl,x0,t);

%% ==========================================================
% Plot States
%% ==========================================================

figure

subplot(3,1,1)
plot(t,x(:,1),'LineWidth',1.5)
grid on
ylabel('Position Error (m)')
title('MagLev LQR Regulation')

subplot(3,1,2)
plot(t,x(:,2),'LineWidth',1.5)
grid on
ylabel('Velocity Error (m/s)')

subplot(3,1,3)
plot(t,x(:,3),'LineWidth',1.5)
grid on
ylabel('Current Error (A)')
xlabel('Time (s)')

%% ==========================================================
% Control Effort
%% ==========================================================

u = -K*x';

figure
plot(t,u,'LineWidth',1.5)
grid on

title('Control Input')
xlabel('Time (s)')
ylabel('u')

%% ==========================================================
% Observer Design
%% ==========================================================

observer_poles = [-200 -220 -250];

Lobs = place(A',C',observer_poles)';

disp('Observer Gain L:')
disp(Lobs)

%% ==========================================================
% Augmented Observer + Controller
%% ==========================================================

Aaug = [A       -B*K;
        Lobs*C  A-B*K-Lobs*C];

disp('Augmented system poles:')
disp(eig(Aaug))