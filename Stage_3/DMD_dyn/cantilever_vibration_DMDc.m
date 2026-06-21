clc;
clear;
close all;

%% Load data
data = readtable("zenodo_cantilever_vibration_dataset/01_random.csv");

t = data{:,1};
u = data{:,2};     % base acceleration
y = data{:,3};     % tip acceleration

%% Remove mean
u = u - mean(u);
y = y - mean(y);

%% Prepare matrices
d = 50;
N = length(y);

% Build simple Hankel matrix for X and Xp

X = zeros(d,N-d);
Xp = zeros(d,N-d);

for k = 1:N-d

    X(:,k) = y(k:k+d-1);

    Xp(:,k) = y(k+1:k+d);

end

U = u(1:N-d)';

size(X)
size(Xp)
size(U)

Omega = [X; U];
size(Omega)


%% SVD and Truncation, then DMDc
[Uo,So,Vo] = svd(Omega,"econ");

r = 10;

Ur = Uo(:,1:r);
Sr = So(1:r,1:r);
Vr = Vo(:,1:r);

G = Xp * Vr / Sr * Ur';

%% Obtain the matrices
n = size(X,1);     % 50
p = size(U,1);     % 1

A_dmdc = G(:,1:n);
B_dmdc = G(:,n+1:n+p);

eig(A_dmdc)

figure
semilogy(diag(So),'o-')
grid on
title('Singular Values of Omega')

%% Mode shapes
[W,D] = eig(A_dmdc);

figure;
plot(real(W(:,1))); hold on;
plot(real(W(:,2)));
plot(real(W(:,3)));
plot(real(W(:,4)));
grid on;
title('State-space mode shapes (A_{dmdc})');