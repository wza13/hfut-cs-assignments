# %%
import math
import numpy as np
import matplotlib.pyplot as plt


def newtown(f, df, x0, epsilon, n, min_lambda=1e-2):
    lambdas = [1]
    xs = [[]]

    while lambdas[-1] > min_lambda:
        k = 0
        x0 = x0
        while k < n:
            x1 = x0 - lambdas[-1] * (f(x0) / df(x0))
            if math.fabs(f(x1)) > math.fabs(f(x0)):
                if lambdas[-1] / 2.0 < min_lambda:

                    return "try another x0", xs
                break
            xs[-1].append(x1)
            if math.fabs(x1 - x0) < epsilon and k != 0:

                return "success", xs
            x0 = x1
            k += 1
        lambdas.append(lambdas[-1] / 2.0)
        xs.append([])

    lambdas.pop(len(lambdas) - 1)
    xs.pop(len(xs) - 1)
    return "fail, try increasing n or try another x0", xs


def main():
    f = lambda x: x * x * x - x - 1
    df = lambda x: 3 * x * x - 1
    # try 0.5, 0.7, 0.9
    x0 = float(input("输入x0\n"))
    epsilon = 1e-6
    n = 8

    xx = np.linspace(-1, 2, 101)
    yy = [f(x) for x in xx]
    plt.gca().spines['bottom'].set_position(('data', 0))
    plt.plot(xx, yy)
    plt.show()

    res, xs = newtown(f, df, x0, epsilon, n)
    print("lambda", end="\t\t")
    for i in range(n):
        print("x[", i + 1, "]", sep="", end="\t\t")
    print()

    lambda_ = 1
    for i in range(len(xs)):
        print(format(lambda_, ".6f"), end="\t")
        for x in xs[i]:
            print(format(x, ".6f"), end="\t")
        print()
        lambda_ /= 2

    print(res)


main()

# %%
