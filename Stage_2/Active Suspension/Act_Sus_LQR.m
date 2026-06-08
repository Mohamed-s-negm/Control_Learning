clc;
clear;
close all;

%% Quarter-Car Parameters

ms = 250;          % Sprung mass (kg)
mu = 50;           % Unsprung mass (kg)

ks = 16000;        % Suspension stiffness (N/m)
cs = 1000;         % Suspension damping (N*s/m)

kt = 190000;       % Tire stiffness (N/m)

%% State-Space Model

A = [0 1 0 0;
    -ks/ms -cs/ms ks/ms cs/ms;
     0 0 0 1;
     ks/mu cs/mu -(ks+kt)/mu -cs/mu];

Bu = [0;
      1/ms;
      0;
     -1/mu];

Br = [0;
      0;
      0;
      kt/mu];

C = eye(4);

D_control = zeros(4,1);
D_road    = zeros(4,1);

%% Open-Loop Analysis

disp('Open-loop poles:')
eig(A)

%% Controllability

Co = ctrb(A,Bu);

disp('Controllability rank:')
rank(Co)

%% Observability

Ob = obsv(A,C);

disp('Observability rank:')
rank(Ob)

%% LQR Design

Q = diag([1e5 1e4 10 10]);

R = 0.01;

K = lqr(A,Bu,Q,R)

%% Closed-Loop System

Acl = A - Bu*K;

disp('Closed-loop poles:')
eig(Acl)

%% Systems for Disturbance Rejection

sys_passive = ss(A,Br,C,D_road);

sys_active = ss(Acl,Br,C,D_road);

%% Simulation Time

t = 0:0.001:5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP ROAD DISTURBANCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[y_passive_step,t_step] = step(sys_passive,t);

[y_active_step,~] = step(sys_active,t);

%% Body Displacement

figure

plot(t_step,y_passive_step(:,1),'LineWidth',1.5)
hold on
plot(t_step,y_active_step(:,1),'LineWidth',1.5)

grid on

xlabel('Time (s)')
ylabel('z_s (m)')

legend('Passive','Active')

title('Body Displacement - Step Road Disturbance')

%% Body Velocity

figure

plot(t_step,y_passive_step(:,2),'LineWidth',1.5)
hold on
plot(t_step,y_active_step(:,2),'LineWidth',1.5)

grid on

xlabel('Time (s)')
ylabel('dz_s/dt (m/s)')

legend('Passive','Active')

title('Body Velocity - Step Road Disturbance')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% IMPULSE ROAD DISTURBANCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[y_passive_imp,t_imp,x_passive_imp] = impulse(sys_passive,t);

[y_active_imp,~,x_active_imp] = impulse(sys_active,t);

%% Body Displacement

figure

plot(t_imp,y_passive_imp(:,1),'LineWidth',1.5)
hold on
plot(t_imp,y_active_imp(:,1),'LineWidth',1.5)

grid on

xlabel('Time (s)')
ylabel('z_s (m)')

legend('Passive','Active')

title('Body Displacement - Impulse Road Disturbance')

%% Body Velocity

figure

plot(t_imp,y_passive_imp(:,2),'LineWidth',1.5)
hold on
plot(t_imp,y_active_imp(:,2),'LineWidth',1.5)

grid on

xlabel('Time (s)')
ylabel('dz_s/dt (m/s)')

legend('Passive','Active')

title('Body Velocity - Impulse Road Disturbance')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIAL CONDITION RESPONSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x0 = [0.05;
      0;
      0;
      0];

sys_cl = ss(Acl,[],eye(4),[]);

[y_init,t_init,x_init] = initial(sys_cl,x0,t);

figure

subplot(4,1,1)
plot(t_init,x_init(:,1),'LineWidth',1.5)
grid on
ylabel('z_s')

subplot(4,1,2)
plot(t_init,x_init(:,2),'LineWidth',1.5)
grid on
ylabel('dz_s/dt')

subplot(4,1,3)
plot(t_init,x_init(:,3),'LineWidth',1.5)
grid on
ylabel('z_u')

subplot(4,1,4)
plot(t_init,x_init(:,4),'LineWidth',1.5)
grid on
ylabel('dz_u/dt')
xlabel('Time (s)')

sgtitle('Closed-Loop State Response')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONTROL FORCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u_control = -K*x_init';

figure

plot(t_init,u_control,'LineWidth',1.5)

grid on

xlabel('Time (s)')
ylabel('Actuator Force (N)')

title('LQR Control Force')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BODY ACCELERATION COMPARISON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

zsdd_passive = ...
    -ks/ms*x_passive_imp(:,1) ...
    -cs/ms*x_passive_imp(:,2) ...
    +ks/ms*x_passive_imp(:,3) ...
    +cs/ms*x_passive_imp(:,4);

zsdd_active = ...
    -ks/ms*x_active_imp(:,1) ...
    -cs/ms*x_active_imp(:,2) ...
    +ks/ms*x_active_imp(:,3) ...
    +cs/ms*x_active_imp(:,4);

figure

plot(t_imp,zsdd_passive,'LineWidth',1.5)
hold on
plot(t_imp,zsdd_active,'LineWidth',1.5)

grid on

xlabel('Time (s)')
ylabel('Body Acceleration (m/s^2)')

legend('Passive','Active')

title('Ride Comfort Comparison')