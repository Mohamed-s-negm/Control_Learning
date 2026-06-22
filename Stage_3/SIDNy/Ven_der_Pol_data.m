
dt = 0.01;
t = 0:dt:40;

mu = 1.0;   % use 0.5–2 range

x = zeros(size(t));
y = zeros(size(t));

x(1) = 2;
y(1) = 0;

for k = 1:length(t)-1
    dx = y(k);
    dy = mu*(1 - x(k)^2)*y(k) - x(k);

    x(k+1) = x(k) + dt*dx;
    y(k+1) = y(k) + dt*dy;
end

data = [t' x' y'];