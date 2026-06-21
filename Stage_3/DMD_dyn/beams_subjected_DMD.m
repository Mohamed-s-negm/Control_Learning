clc;
clear;
close all;

%% Load data (robust)
filename = "beams_subjected_vibrations_dataset/Case 3_ Fixed-Fixed Beam/AL/AL-F-1.csv";

% Force semicolon parsing (important for this dataset)
data = readmatrix(filename, "Delimiter", ";");

%% Remove corrupted rows (NaNs introduced by parsing issues)
data = data(all(~isnan(data),2), :);

%% Extract signals
x1 = data(:,1);   % X acceleration
x2 = data(:,2);   % Y acceleration
x3 = data(:,3);   % Z acceleration

%% Build state matrix (3 DOF system)
x_data = [x1 x2 x3];     % N × 3
Xfull  = x_data';        % 3 × N

%% Build DMD snapshot matrices
X  = Xfull(:,1:end-1);
Xp = Xfull(:,2:end);

%% Sanity check (VERY IMPORTANT)
disp(size(X))
disp(any(isnan(X),'all'))

%% SVD
[Uo,So,Vo] = svd(X,'econ');

%% Choose rank (start small!)
r = 2;

Ur = Uo(:,1:r);
Sr = So(1:r,1:r);
Vr = Vo(:,1:r);

%% DMD operator (use stable form first)
A_dmd = Xp * pinv(X);

%% Eigenvalues
lambda = eig(A_dmd)

%% Optional: check stability
abs(lambda)