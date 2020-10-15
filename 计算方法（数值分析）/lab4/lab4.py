import math


def newtown(f, df, x0, epsilon, n):
    lambdas = [1]
    xs = [[]]

    while lambdas[-1] > 1e-6:
        k = 0
        x0 = x0
        while k < n:
            x1 = x0 - lambdas[-1] * (f(x0) / df(x0))
            xs[-1].append(x1)
            if math.fabs(x1 - x0) < epsilon and k != 0:

                return "success", xs
            x0 = x1
            k += 1
        lambdas.append(lambdas[-1] / 2)
        xs.append([])

    return "fail", xs


def main():
    f = lambda x: x * x * x - x - 1
    df = lambda x: 3 * x * x - 1
    x0 = 0.6
    epsilon = 1e-6
    n = 8

    res, xs = newtown(f, df, x0, epsilon, n)
    if res != "success":
        print(res)

        return
    print("lambda", end="\t\t")
    for i in range(n):
        print("x[", i + 1, "]", sep="", end="\t\t")
    print()

    lambda_ = 1
    for i in range(len(xs)):
        print(format(lambda_ / (i + 1), ".6f"), end="\t")
        for x in xs[i]:
            print(format(x, ".6f"), end="\t")
        print()


main()
