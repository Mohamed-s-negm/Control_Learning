clc;
clear;
close all;

%% Make model and Load data
data = readmatrix("Coupled Van der Pol Oscillators — Realistic Mechan\attack1_coupled_mvdp_test.csv");

X = data;
t = X(:,1);
x = X(:,2);
y = X(:,3);

%% Remove mean and normalize
x = x - mean(x);
y = y - mean(y);


x = x / std(x);
y = y / std(y);


%% Plot the data
figure

subplot(2,1,1)
plot(t,x)
grid on
xlabel('Time (s)')
ylabel('x1')
title('x1 vs Time')

subplot(2,1,2)
plot(t,y)
grid on
xlabel('Time (s)')
ylabel('y1')
title('y1 vs Time')


%% prepare the data and derivation matrices
X = [x, y];

dt = mean(diff(t));

Xdot = zeros(size(X));

Xdot(2:end-1,:) = (X(3:end,:) - X(1:end-2,:)) / (2*dt);
Xdot(1,:) = Xdot(2,:);
Xdot(end,:) = Xdot(end-1,:);
Xdot = smoothdata(Xdot);

%% Build Library matrix
Theta = [
    x, y, ...
    x.^2, y.^2, ...
    x.^2 .* y, ...
    x .* y
];
%% Solve for Sparse
Xi = pinv(Theta) * Xdot;

lambda = 0.05;

for k = 1:10
    small = abs(Xi) < lambda;
    Xi(small) = 0;

    for i = 1:size(Xdot,2)
        big = ~small(:,i);
        Xi(big,i) = Theta(:,big) \ Xdot(:,i);
    end
end

%% Obtain Equations
terms = {'x', 'y', ...
    'x.^2', 'y.^2', ...
    'x.^2 .* y', ...
    'x .* y'
    };

for state = 1:2
    fprintf('\n xdot_%d = ', state)

    for k = 1:length(terms)
        if abs(Xi(k,state)) > 1e-8
            fprintf(' %+f*%s ', Xi(k,state), terms{k});
        end
    end

    fprintf('\n')
end

%% Results Simulations
x_sim = zeros(length(t),2);
x_sim(1,:) = X(1,:);

for k = 1:length(t)-1
    x1 = x_sim(k,1);
    x2 = x_sim(k,2);

    theta = [
        x1, x2, ...
        x1.^2, x2.^2, ...
        x1.^2 .* x2, ...
        x1 .* x2
    ];

    xdot = theta * Xi;
    x_sim(k+1,:) = x_sim(k,:) + dt*xdot;
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


%% Quantative Fit
fit_percent = 100 * (1 - norm(X - x_sim,'fro') / norm(X,'fro'))