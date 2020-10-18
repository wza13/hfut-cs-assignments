# import math
# import numpy as np


def lagrange(f, xs, x):
    ys = [f(i) for i in xs]
    n = len(xs)
    y = 0
    for k in range(0, n):
        t = 1
        for j in range(0, n):
            if j != k:
                s = (x - xs[j]) / (xs[k] - xs[j])
                t = t * s
        y = y + t * ys[k]

    return y


def difference_quotient(f, xs):
    res = 0
    n = len(xs)
    for k in range(n):
        t = 1
        for j in range(n):
            if j != k:
                t *= (xs[k] - xs[j])
        res += f(xs[k]) / t

    return res


def newtown(f, xs, x):
    n = len(xs)
    y = f(xs[0])
    for k in range(1, n):
        t = difference_quotient(f, xs[:k + 1])
        for j in range(k):
            t *= (x - xs[j])
        y += t

    return y


def piecewise_linear(f, xs, x):
    interval = [0, 1]
    if x < xs[0]:
        interval = [xs[0], xs[1]]
    elif x > xs[-1]:
        interval = [xs[-2], xs[-1]]
    else:
        for i in range(len(xs) - 1):
            if x >= xs[i] and x <= xs[i + 1]:
                interval = [xs[i], xs[i + 1]]
                break

    return lagrange(f, interval, x)


# print(lagrange(lambda x: 1 / (1 + x * x), np.linspace(-5, 5, 11), 0.5))
# print(lagrange(lambda x: 1 / (1 + x * x), np.linspace(-5, 5, 11), 4.5))
# print(piecewise_linear(lambda x: 1 / (1 + x * x), np.linspace(-5, 5, 11), 0.5))
# print(piecewise_linear(lambda x: 1 / (1 + x * x), np.linspace(-5, 5, 11), 4.5))

# print(
#     difference_quotient(lambda x: x * x * x - 4 * x, (np.arange(5))[1:]),
#     difference_quotient(lambda x: x * x * x - 4 * x, [1, 2]),
#     difference_quotient(lambda x: x * x * x - 4 * x, [1, 2, 3])
# )

# print(newtown(lambda x: x * x * x - 4 * x, (np.arange(5))[1:], 5))
# print(newtown(lambda x: math.sqrt(x), [1, 4, 9], 5))
