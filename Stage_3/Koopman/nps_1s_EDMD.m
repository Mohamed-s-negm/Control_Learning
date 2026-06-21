clc;
clear;
close all;

%% Load data
data = readtable("nps_dataset.csv");

t = data{:,1};
x1 = data{:,2};

%% Remove mean
x1 = x1 - mean(x1);

%% Prepare matrices

X = [x1(1:end-1)'];

Xp = [x1(2:end)'];

%% Prepare observers

Z = [
X;
X.^2;
X.^3;
X.^4;
X.^5;
sin(X);
cos(X)
];

Zp = [
Xp;
Xp.^2;
Xp.^3;
Xp.^4;
Xp.^5;
sin(Xp);
cos(Xp)
];

size(Z)
size(Zp)


%% SVD and Truncation, then DMDc
[Uo,So,Vo] = svd(Z,"econ");

r = 7;

Ur = Uo(:,1:r);
Sr = So(1:r,1:r);
Vr = Vo(:,1:r);

A = Zp * Vr / Sr * Ur';

n = size(Z,1);     

A_edmdc = A(:,1:n);
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
    z_pred(:,k+1) = A_edmdc*z_pred(:,k);
end

N = min(size(Z,2), size(z_pred,2));

Zc = Z(:,1:N);
Zpc = z_pred(:,1:N);

d = 1;

X_true = Zc(1:d,:);
X_pred = Zpc(1:d,:);

fit_percent = 100 * ...
    (1 - norm(X_true - X_pred,'fro') / norm(X_true,'fro'))

%% 
Zp_est = A_edmdc*Z;

one_step_fit = 100 * ...
    (1 - norm(Zp - Zp_est,'fro')/norm(Zp,'fro'))