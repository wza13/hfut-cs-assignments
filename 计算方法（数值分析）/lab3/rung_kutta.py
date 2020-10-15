def rung_kutta(f, x0, y0, n, h):
    x = []
    y = []
    i = 1
    while i <= n:
        x1 = x0 + h
        k1 = f(x0, y0)
        k2 = f(x0 + 0.5 * h, y0 + 0.5 * h * k1)
        k3 = f(x0 + 0.5 * h, y0 + 0.5 * h * k2)
        k4 = f(x0 + h, y0 + h * k3)
        y1 = y0 + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
        x.append(x1)
        y.append(y1)
        i += 1
        x0 = x1
        y0 = y1

    return x, y
