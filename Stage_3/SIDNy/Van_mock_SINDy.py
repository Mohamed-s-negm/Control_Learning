from pathlib import Path


import numpy as np
import pandas as pd
import pysindy as ps
import matplotlib.pyplot as plt


script_dir = Path(__file__).resolve().parent
data_path = script_dir / "Van_mock_data.csv"

if not data_path.is_file():
    raise FileNotFoundError(f"Could not find dataset at: {data_path}")

data = pd.read_csv(data_path, header=None)

# preparing data for SINDy
t = data.iloc[:, 0].to_numpy()
x = data.iloc[:, 1].to_numpy()
y = data.iloc[:, 2].to_numpy()

# remove mean
x = x - np.mean(x)
y = y - np.mean(y)

X = np.column_stack((x, y))
#Xdot = np.column_stack((y, np.gradient(y, t)))

print("X shape:", X.shape)
print("X sample:", X[:10])

# preparing SINDy model
model = ps.SINDy(
    feature_library=ps.PolynomialLibrary(degree=3),
    optimizer=ps.STLSQ(threshold=0.05),
    differentiation_method=ps.SmoothedFiniteDifference()
)

model.fit(X, t=t, feature_names=['x', 'y'])
model.print()

# simulate model
x_model = np.asarray(model.simulate(X[0], t))

fig, axs = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

axs[0].plot(t, x, 'r', label='True_x')
axs[0].plot(t, x_model[:, 0], 'b--', label='SINDy_x')
axs[0].set_ylabel('x')
axs[0].legend()
axs[0].grid(True)

axs[1].plot(t, y, 'r', label='True_y')
axs[1].plot(t, x_model[:, 1], 'b--', label='SINDy_y')
axs[1].set_xlabel('Time (s)')
axs[1].set_ylabel('y')
axs[1].legend()
axs[1].grid(True)

plt.tight_layout()
plt.show()

# Fit percentage
fit_percentage = (1 - np.linalg.norm(X - x_model, ord='fro') / np.linalg.norm(X, ord='fro') if np.linalg.norm(X, ord='fro') != 0 else 0 )
print(f"Fit percentage: {fit_percentage * 100:.2f}%")
