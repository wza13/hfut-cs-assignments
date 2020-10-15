def euler(f, x0, y0, n, h):
    x = []
    y = []
    i = 1
    while i <= n:
        x1 = x0 + h
        y1 = y0 + h * f(x0, y0)
        x.append(x1)
        y.append(y1)
        i += 1
        x0 = x1
        y0 = y1

    return x, y


def improved_euler(f, x0, y0, n, h):
    x = []
    y = []
    i = 1
    while i <= n:
        x1 = x0 + h
        y1_ = y0 + h * f(x0, y0)
        y1 = y0 + h / 2 * (f(x0, y0) + f(x1, y1_))
        x.append(x1)
        y.append(y1)
        i += 1
        x0 = x1
        y0 = y1

    return x, y
