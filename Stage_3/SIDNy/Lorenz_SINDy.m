clc;
clear;
close all;

%% Load data
baseDir = fileparts(mfilename('fullpath'));
dataFile = fullfile(baseDir, 'Lorenz_Official', 'csv', 'train', 'X1train.csv');
timeFile = fullfile(baseDir, 'Lorenz_Official', 'csv', 'train', 'X1train_timesteps.csv');

data = readmatrix(dataFile);
timesteps = readmatrix(timeFile);

X = data;
t = timesteps(:,1);

x = X(:,1);
y = X(:,2);
z = X(:,3);

%% Remove mean and normalize
% x = x - mean(x);
% y = y - mean(y);
% z = z - mean(z);
% 
% x = x / std(x);
% y = y / std(y);
% z = z / std(z);

%% Plot the data
figure

subplot(3,1,1)
plot(t,x)
grid on
xlabel('Time (s)')
ylabel('x1')
title('x1 vs Time')

subplot(3,1,2)
plot(t,y)
grid on
xlabel('Time (s)')
ylabel('x2')
title('x2 vs Time')

subplot(3,1,3)
plot(t,z)
grid on
xlabel('Time (s)')
ylabel('x3')
title('x3 vs Time')

%% prepare the data and derivation matrices
dt = mean(diff(t));

window = 11;
poly = 3;

x_s = sgolayfilt(x, poly, window);
y_s = sgolayfilt(y, poly, window);
z_s = sgolayfilt(z, poly, window);

dt = mean(diff(t));

dx = sgolayfilt(x_s, poly, window, [], 1) / dt;
dy = sgolayfilt(y_s, poly, window, [], 1) / dt;
dz = sgolayfilt(z_s, poly, window, [], 1) / dt;

X = [x_s, y_s, z_s];

mu = mean(X);
sigma = std(X);

Xn = (X - mu) ./ sigma;

Xdot = [dx, dy, dz];
Xdot_n = (Xdot - mean(Xdot)) ./ std(Xdot);


%% Build Library matrix

Theta = [
    ones(size(Xn,1),1), ...
    Xn(:,1), Xn(:,2), Xn(:,3), ...
    Xn(:,1).*Xn(:,2), ...
    Xn(:,1).*Xn(:,3), ...
    Xn(:,2).*Xn(:,3)
];

%% Solve for Sparse
lambda = 0.05;
Xi = Theta \ Xdot;

for k = 1:10
    small = abs(Xi) < lambda;
    Xi(small) = 0;

    for i = 1:size(Xdot,2)
        idx = ~small(:,i);
        Xi(idx,i) = Theta(:,idx) \ Xdot(:,i);
    end
end

%% Obtain Equations
terms = {'1','x','y','z','xy','xz','yz'};

for state = 1:3
    fprintf('\n xdot_%d = ', state)

    for k = 1:length(terms)
        if abs(Xi(k,state)) > 1e-8
            fprintf(' %+f*%s ', Xi(k,state), terms{k});
        end
    end

    fprintf('\n')
end

%% Results Simulations
x_sim = zeros(length(t),3);
x_sim(1,:) = X(1,:);

for k = 1:length(t)-1

    s = x_sim(k,:)';   % 3×1 column vector

    f = @(v) [
        Xi(1,1) + Xi(2,1)*v(1) + Xi(3,1)*v(2) + Xi(4,1)*v(3) + Xi(5,1)*v(1)*v(2) + Xi(6,1)*v(1)*v(3) + Xi(7,1)*v(2)*v(3);
        Xi(1,2) + Xi(2,2)*v(1) + Xi(3,2)*v(2) + Xi(4,2)*v(3) + Xi(5,2)*v(1)*v(2) + Xi(6,2)*v(1)*v(3) + Xi(7,2)*v(2)*v(3);
        Xi(1,3) + Xi(2,3)*v(1) + Xi(3,3)*v(2) + Xi(4,3)*v(3) + Xi(5,3)*v(1)*v(2) + Xi(6,3)*v(1)*v(3) + Xi(7,3)*v(2)*v(3)
    ];

    k1 = f(s);
    k2 = f(s + 0.5*dt*k1);
    k3 = f(s + 0.5*dt*k2);
    k4 = f(s + dt*k3);

    increment = (dt/6)*(k1 + 2*k2 + 2*k3 + k4);   % 3×1

    x_sim(k+1,:) = (s + increment)';  % convert back to 1×3
end

% x Comparison
figure
plot(t,X(:,1),'LineWidth',1.5)
hold on
plot(t,x_sim(:,1),'--','LineWidth',1.5)
grid on
legend('True','SINDy')
xlabel('Time')
ylabel('x')
title('x Comparison')

% y Comparison
figure
plot(t,X(:,2),'LineWidth',1.5)
hold on
plot(t,x_sim(:,2),'--','LineWidth',1.5)
grid on
legend('True','SINDy')
xlabel('Time')
ylabel('y')
title('y Comparison')

% Z Comparison
figure
plot(t,X(:,3),'LineWidth',1.5)
hold on
plot(t,x_sim(:,3),'--','LineWidth',1.5)
grid on
legend('True','SINDy')
xlabel('Time')
ylabel('z')
title('z Comparison')

%% Phase Portrait Comparison
figure
plot3(X(:,1),X(:,2),X(:,3))
hold on
plot3(x_sim(:,1),x_sim(:,2),x_sim(:,3),'--')
grid on
legend('True','SINDy')
xlabel('x'); ylabel('y'); zlabel('z')
title('Lorenz Attractor')

%% Quantative Fit
fit_percent = 100 * (1 - norm(X - x_sim,'fro') / norm(X,'fro'))