%% Simulation Parameters

Tf = 500;      % Final time [s]
dt = 0.1;      % Time step [s]

t = 0:dt:Tf;
N = length(t);

%% Reference

r = 15;        % 15 degC above ambient

%% Initial Conditions

TH = 0;
TS = 0;
xI = 0;

%% Storage

TH_hist = zeros(N,1);
TS_hist = zeros(N,1);
u_hist  = zeros(N,1);
e_hist  = zeros(N,1);

%% Simulation Loop

for k = 1:N

    % Output
    y = TS;

    % Tracking error
    e = r - y;

    % Integral state
    xI = xI + e*dt;

    % LQI control law
    u = -(k1*TH + k2*TS + k3*xI);

    % Saturation
    u = max(0,min(100,u));

    % State vector
    x = [TH;
         TS];

    % Plant dynamics
    dx = A*x + B*u;

    % Euler integration
    TH = TH + dx(1)*dt;
    TS = TS + dx(2)*dt;

    % Save data
    TH_hist(k) = TH;
    TS_hist(k) = TS;
    u_hist(k)  = u;
    e_hist(k)  = e;

end

%% Plots

figure

plot(t,TS_hist,'LineWidth',2)
hold on
yline(r,'--')
grid on

xlabel('Time (s)')
ylabel('Temperature Deviation (^{\circ}C)')
title('Sensor Temperature')

legend('T_S','Reference')

figure

plot(t,TH_hist,'LineWidth',2)
grid on

xlabel('Time (s)')
ylabel('Temperature Deviation (^{\circ}C)')
title('Heater Temperature')

figure

plot(t,u_hist,'LineWidth',2)
grid on

xlabel('Time (s)')
ylabel('Heater Input (%)')
title('Control Signal')