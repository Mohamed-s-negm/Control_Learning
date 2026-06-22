from pathlib import Path

import numpy as np
import pandas as pd
import pysindy as ps
import matplotlib.pyplot as plt


script_dir = Path(__file__).resolve().parent
data_path = script_dir / "nps_dataset.csv"

if not data_path.is_file():
    raise FileNotFoundError(f"Could not find dataset at: {data_path}")

data = pd.read_csv(data_path)

# preparing data for SINDy
t = data['Time (s)'].values
x1 = data['Position (x)'].values
x2 = data['Velocity (v)'].values
a = data['Acceleration (a)'].values

# remove mean
x1 = x1 - np.mean(x1)
x2 = x2 - np.mean(x2)
a = a - np.mean(a)

X = np.column_stack((x1, x2))
Xdot = np.column_stack((x2, a))

print("X shape:", X.shape)
print("Xdot shape:", Xdot.shape)
print("X sample:", X[:10])
print("Xdot sample:", Xdot[:10])

# preparing SINDy model
model = ps.SINDy()
model.fit(X, t=t, x_dot=Xdot, feature_names=['x', 'v'])
model.print()

# simulate model
x_model = np.asarray(model.simulate(X[0], t))

fig, axs = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

axs[0].plot(t, x1, 'r', label='True Position (x)')
axs[0].plot(t, x_model[:, 0], 'b--', label='SINDy Position (x)')
axs[0].set_ylabel('Position (x)')
axs[0].legend()
axs[0].grid(True)

axs[1].plot(t, x2, 'r', label='True Velocity (v)')
axs[1].plot(t, x_model[:, 1], 'b--', label='SINDy Velocity (v)')
axs[1].set_xlabel('Time (s)')
axs[1].set_ylabel('Velocity (v)')
axs[1].legend()
axs[1].grid(True)

plt.tight_layout()
plt.show()

# Fit percentage
fit_percentage = (1 - np.linalg.norm(X - x_model, ord='fro') / np.linalg.norm(X, ord='fro') if np.linalg.norm(X, ord='fro') != 0 else 0 )
print(f"Fit percentage: {fit_percentage * 100:.2f}%")
