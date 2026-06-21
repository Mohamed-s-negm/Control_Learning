clc;
clear;
close all;

%% Construct the ideal system
m1 = 1;
m2 = 1;

k1 = 50;
k2 = 50;
k3 = 50;

c1 = 1;
c2 = 1;
c3 = 1;

M = [m1 0;
     0  m2];

K = [k1+k2  -k2;
     -k2    k2+k3];

C = [c1+c2  -c2;
     -c2    c2+c3];

A = [ zeros(2) eye(2);
     -M\K     -M\C ];

eig(A)


%% Simulate the data
dt = 0.01;
T  = 10;

Ad = expm(A*dt);

N = T/dt;

x = zeros(4,N);

x(:,1) = [1;0;0;0];

for k = 1:N-1
    x(:,k+1) = Ad*x(:,k);
end

Ad = expm(A*dt)
eig(Ad)

%% DMD using (pinv)
X = x(:,1:end-1);
Xp = x(:,2:end);

size(X)
size(Xp)

A_dmd = Xp * pinv(X);
eig_dmd = eig(A_dmd);

%% DMD using SVD, starting with SVD
[U,S,V] = svd(X,"econ");

figure
semilogy(diag(S),'o-')
grid on
xlabel('Index')
ylabel('Singular Value')
title('Singular Values')

%% Order Reduction
r = 4;
Ur = U(:,1:r);
Sr = S(1:r,1:r);
Vr = V(:,1:r);

Atilde = Ur' * Xp * Vr / Sr;

disp('Error in A:')
norm(Atilde - Ad)

%% Compare Eigenvalues
eig_true = eig(Ad);
eig_est  = eig(Atilde);

figure;
plot(real(eig_true), imag(eig_true), 'bo', 'MarkerSize',10); hold on;
plot(real(eig_est), imag(eig_est), 'rx', 'MarkerSize',10);
grid on;
xlabel('Real Part');
ylabel('Imaginary Part');
legend('True','DMDc');
title('Eigenvalue Comparison');


%% Time response
x_dmd = zeros(4,N);
x_dmd(:,1) = x(:,1);

for k = 1:N-1
    x_dmd(:,k+1) = Atilde*x_dmd(:,k);
end

t = (0:N-1)*dt;

figure;
for i = 1:4
    subplot(4,1,i)
    plot(t, x(i,:), 'b'); hold on;
    plot(t, x_dmd(i,:), 'r--');
    grid on;
    ylabel(['x_',num2str(i)])
end
xlabel('Time')
legend('True','DMDc')