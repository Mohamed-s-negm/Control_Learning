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

%% Prepare observers

Z = [X;
     X.^2;
     X.^3;];

Zp = [Xp;
      Xp.^2;
      Xp.^3;];


size(Z)
size(Zp)

U = u(1:N-d)';
size(U)

Omega = [Z; U];
size(Omega)


%% SVD and Truncation, then DMDc
[Uo,So,Vo] = svd(Omega,"econ");

r = 20;

Ur = Uo(:,1:r);
Sr = So(1:r,1:r);
Vr = Vo(:,1:r);

G = Zp * Vr / Sr * Ur';

%% Obtain the matrices
n = size(Z,1);     % 50
p = size(U,1);     % 1

A_edmdc = G(:,1:n);
B_edmdc = G(:,n+1:n+p);

eig(A_edmdc)

figure
semilogy(diag(So),'o-')
grid on
title('Singular Values of Omega')

%% Mode shapes
[W,D] = eig(A_edmdc);

figure;
plot(real(W(:,1))); hold on;
plot(real(W(:,2)));
plot(real(W(:,3)));
plot(real(W(:,4)));
grid on;
title('State-space mode shapes (A_{dmdc})');

%% Eigenvalues plot
lambda = eig(A_edmdc);

dt = t(2)-t(1);

lambda_c = log(lambda)/dt;

freq = abs(imag(lambda_c))/(2*pi);

damp = real(lambda_c);

figure
scatter(freq,damp)
grid on
xlabel('Frequency (Hz)')
ylabel('Decay Rate')
title('Koopman Spectrum')

%% Comparison
Nsteps = size(Z,2);
z_pred(:,1) = Z(:,1);

for k=1:Nsteps-1
    z_pred(:,k+1) = A_edmdc*z_pred(:,k) + B_edmdc*U(:,k);
end

N = min(size(Z,2), size(z_pred,2));

Zc = Z(:,1:N);
Zpc = z_pred(:,1:N);

d = 50;

X_true = Zc(1:d,:);
X_pred = Zpc(1:d,:);

fit_percent = 100 * (1 - norm(X_true - X_pred,'fro') / norm(X_true,'fro'));