clc;
clear;
close all;

%% Load data
data = readtable("nps_dataset.csv");

t = data{:,1};
x1 = data{:,2};
x2 = data{:,3};
a = data{:,4};

%% Remove mean
x1 = x1 - mean(x1);
x2 = x2 - mean(x2);
a = a - mean(a);

%% Plot the data
figure

subplot(3,1,1)
plot(t,x1)
grid on
xlabel('Time (s)')
ylabel('Position')
title('Position vs Time')

subplot(3,1,2)
plot(t,x2)
grid on
xlabel('Time (s)')
ylabel('Velocity')
title('Velocity vs Time')

subplot(3,1,3)
plot(t,a)
grid on
xlabel('Time (s)')
ylabel('Acceleration')
title('Acceleration vs Time')

%% prepare the data and derivation matrices
X = [x1'; x2'];
X = X';

Xdot = [x2'; a'];
Xdot = Xdot';

%% Build Library matrix
Theta = [
    ones(size(x1'))
    x1'
    x2'
    x1'.^2
    x1'.*x2'
    x2'.^2
    ];

Theta = Theta';

%% Solve for Sparse
Xi = pinv(Theta)*Xdot;
H = 0.05;

lambda = 0.1;

for k = 1:10
    small = abs(Xi) < lambda;
    Xi(small) = 0;

    for state = 1:size(Xdot,2)
        big = ~small(:,state);
        Xi(big,state) = Theta(:,big) \ Xdot(:,state);
    end

end

%% Obtain Equations
terms = {'1','x1','x2','x1^2','x1*x2','x2^2'};

for state = 1:size(Xi,2)
    fprintf('\n xdot_%d = ',state)

    for k = 1:length(terms)
        if abs(Xi(k,state)) > 1e-8
            fprintf(' %+f*%s ',Xi(k,state),terms{k});
        end
    end

    fprintf('\n')
end

%% Results Simulations
x_sim = zeros(length(t),2);

x_sim(1,:) = X(1,:);

dt = t(2)-t(1);

for k = 1:length(t)-1

    x1s = x_sim(k,1);
    x2s = x_sim(k,2);

    theta = [
        1
        x1s
        x2s
        x1s^2
        x1s*x2s
        x2s^2
    ];

    xdot = (theta' * Xi);

    x_sim(k+1,:) = x_sim(k,:) + dt*xdot;

end

% Position Comparison
figure
plot(t,X(:,1),'LineWidth',1.5)
hold on
plot(t,x_sim(:,1),'--','LineWidth',1.5)
grid on
legend('True','SINDy')
xlabel('Time')
ylabel('x_1')
title('Position Comparison')

% Velocity Comparison
figure
plot(t,X(:,2),'LineWidth',1.5)
hold on
plot(t,x_sim(:,2),'--','LineWidth',1.5)
grid on
legend('True','SINDy')
xlabel('Time')
ylabel('x_2')
title('Velocity Comparison')

%% Phase Portrait Comparison
figure
plot(X(:,1),X(:,2),'LineWidth',1.5)
hold on
plot(x_sim(:,1),x_sim(:,2),'--','LineWidth',1.5)
grid on
legend('True','SINDy')
xlabel('x_1')
ylabel('x_2')
title('Phase Portrait')

%% Quantative Fit
fit_percent = 100 * ...
    (1 - norm(X - x_sim,'fro') / norm(X,'fro'))