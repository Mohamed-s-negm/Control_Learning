from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import savgol_filter
from sklearn.preprocessing import StandardScaler
import pysindy as ps

script_dir = Path(__file__).resolve().parent
data_path = script_dir / "Lorenz_Official" / "csv" / "train" / "X1train.csv"
time_path = script_dir / "Lorenz_Official" / "csv" / "train" / "X1train_timesteps.csv"

if not data_path.is_file():
    raise FileNotFoundError(f"Could not find dataset at: {data_path}")
if not time_path.is_file():
    raise FileNotFoundError(f"Could not find dataset at: {time_path}")

data = pd.read_csv(data_path, header=None)
t = pd.read_csv(time_path, header=None)

x = data.iloc[:, 0].to_numpy()
y = data.iloc[:, 1].to_numpy()
z = data.iloc[:, 2].to_numpy()
t = t.iloc[:, 0].to_numpy().flatten()

# Center and scale each variable to reduce numerical issues.
x = (x - x.mean()) / x.std()
y = (y - y.mean()) / y.std()
z = (z - z.mean()) / z.std()

X = np.column_stack((x, y, z))

# Smooth data and estimate derivatives.
window = 11
poly = 3
dt = float(np.mean(np.diff(t)))

x_s = savgol_filter(x, window_length=window, polyorder=poly)
y_s = savgol_filter(y, window_length=window, polyorder=poly)
z_s = savgol_filter(z, window_length=window, polyorder=poly)

Xs = np.column_stack((x_s, y_s, z_s))

Xdot = np.column_stack((
    savgol_filter(x_s, window_length=window, polyorder=poly, deriv=1, delta=dt),
    savgol_filter(y_s, window_length=window, polyorder=poly, deriv=1, delta=dt),
    savgol_filter(z_s, window_length=window, polyorder=poly, deriv=1, delta=dt),
))

# Normalize inputs/targets for the optimizer.
scaler_X = StandardScaler()
scaler_dX = StandardScaler()
Xn = scaler_X.fit_transform(Xs)
Xdot_n = scaler_dX.fit_transform(Xdot)

print("X shape:", Xn.shape)
print("Xdot shape:", Xdot_n.shape)
print("X sample:\n", Xn[:5])
print("Xdot sample:\n", Xdot_n[:5])

# Build a stable SINDy model.
library = ps.PolynomialLibrary(degree=2, include_bias=True)
optimizer = ps.STLSQ(threshold=0.05, max_iter=100)
model = ps.SINDy(
    feature_library=library,
    optimizer=optimizer,
)
model.fit(Xn, t=t, x_dot=Xdot_n)
model.print()

# Simulate with a robust solver.
X0 = Xn[0]
x_model_n = np.asarray(model.simulate(
    X0,
    t,
    integrator_kws={
        "method": "RK45",
        "rtol": 1e-8,
        "atol": 1e-10,
    },
))

# Convert back to physical coordinates.
x_model = scaler_X.inverse_transform(x_model_n)

fig, axs = plt.subplots(3, 1, figsize=(10, 12), sharex=True)
axs[0].plot(t, X[:, 0], 'r', label='True x')
axs[0].plot(t, x_model[:, 0], 'b--', label='SINDy x')
axs[0].set_ylabel('x')
axs[0].legend()
axs[0].grid(True)

axs[1].plot(t, X[:, 1], 'r', label='True y')
axs[1].plot(t, x_model[:, 1], 'b--', label='SINDy y')
axs[1].set_ylabel('y')
axs[1].legend()
axs[1].grid(True)

axs[2].plot(t, X[:, 2], 'r', label='True z')
axs[2].plot(t, x_model[:, 2], 'b--', label='SINDy z')
axs[2].set_xlabel('Time (s)')
axs[2].set_ylabel('z')
axs[2].legend()
axs[2].grid(True)

plt.tight_layout()
plt.show(block=True)

# Fit percentage (using the same scaled data used for fitting).
fit_percentage = (
    1 - np.linalg.norm(X - x_model, ord='fro') / np.linalg.norm(X - np.mean(X, axis=0))
)
print(f"Fit percentage: {fit_percentage * 100:.2f}%")