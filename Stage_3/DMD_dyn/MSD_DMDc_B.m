clc;
clear;
close all;

%% Build the real system

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

F = [1;
     0];

A = [ zeros(2) eye(2);
     -M\K     -M\C ];

B = [ zeros(2,1);
      M\F ];

A_true = A
B_true = B

%% Discretization of the system
dt = 0.01;

sys_c = ss(A,B,eye(4),zeros(4,1));

sys_d = c2d(sys_c,dt);

Ad = sys_d.A;
Bd = sys_d.B;

%% Generate data
T = 20;

N = T/dt;

u = randn(1,N);

x = zeros(4,N);

x(:,1) = [1;
          0;
          0;
          0];

for k = 1:N-1

    x(:,k+1) = Ad*x(:,k) + Bd*u(k);

end

%% DMDc with known B
X = x(:,1:end-1);
Xp = x(:,2:end);
U = u(:,1:end-1);

size(X)
size(Xp)
size(U)

omega = [X;U];
size(omega)

%% SVD and Truncation
[Uo, So, Vo] = svd(omega,"econ");

r = 5;
Ur = Uo(:,1:r);
Sr = So(1:r,1:r);
Vr = Vo(:,1:r);

G = Xp * Vr / Sr * Ur';

%% Recover A and B
n = size(X,1);
p = size(U,1);

A_dmdc = G(:, 1:n);
B_dmdc = G(:, n+1:n+p);

disp('Error in A:')
norm(A_dmdc - Ad)

disp('Error in B:')
norm(B_dmdc - Bd)

%% Compare Eigenvalues
eig_true = eig(Ad);
eig_est  = eig(A_dmdc);

figure;
plot(real(eig_true), imag(eig_true), 'bo', 'MarkerSize',10); hold on;
plot(real(eig_est), imag(eig_est), 'rx', 'MarkerSize',10);
grid on;
xlabel('Real Part');
ylabel('Imaginary Part');
legend('True','DMDc');
title('Eigenvalue Comparison');

%% Time response
x_dmdc = zeros(4,N);
x_dmdc(:,1) = x(:,1);

for k = 1:N-1
    x_dmdc(:,k+1) = A_dmdc*x_dmdc(:,k) + B_dmdc*u(k);
end

t = (0:N-1)*dt;

figure;
for i = 1:4
    subplot(4,1,i)
    plot(t, x(i,:), 'b'); hold on;
    plot(t, x_dmdc(i,:), 'r--');
    grid on;
    ylabel(['x_',num2str(i)])
end
xlabel('Time')
legend('True','DMDc')

%% Mode shapes
[W,D] = eig(A_dmdc);

figure;
plot(real(W(:,1))); hold on;
plot(real(W(:,2)));
plot(real(W(:,3)));
plot(real(W(:,4)));
grid on;
title('State-space mode shapes (A_{dmdc})');