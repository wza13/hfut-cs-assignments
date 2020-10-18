# %%
import ast
import math
import numpy as np
import matplotlib.pyplot as plt
# from lab1.interpolation import lagrange, newtown, piecewise_linear
from interpolation import lagrange, newtown, piecewise_linear


def main():
    problem1()
    print()
    problem2()
    runge_phenomenon()


def problem1():
    begin = eval(input("输入区间起点："))
    end = eval(input("输入区间终点："))
    n = eval(input("输入划分节点数："))
    pred = ast.literal_eval(input("输入预测点："))

    xs = np.linspace(begin, end, n)
    f = lambda x: 1 / (1 + x * x)
    print("X\ty(精确值)\ty(拉格朗日)\ty(分段线性)\t误差(拉)\t误差(分)")
    for x in pred:
        true_val = f(x)
        la = lagrange(f, xs, x)
        pl = piecewise_linear(f, xs, x)
        print(x,
              format(true_val, ".6f"),
              format(la, ".6f"),
              format(pl, ".6f"),
              format(true_val - la, ".6f"),
              format(true_val - pl, ".6f"),
              sep="\t")


def problem2():
    xs = ast.literal_eval(input("输入数据点集（x）："))
    pred = ast.literal_eval(input("输入预测点："))

    f = lambda x: math.sqrt(x)
    print("X\ty(精确值)\ty(牛顿插值)\t误差")
    for x in pred:
        true_val = f(x)
        nt = newtown(f, xs, x)
        print(x,
              format(true_val, ".6f"),
              format(nt, ".6f"),
              format(true_val - nt, ".6f"),
              sep="\t")


def runge_phenomenon():
    f = lambda x: 1 / (1 + x * x)
    xs_10 = np.linspace(-5, 5, 11)
    xs_5 = np.linspace(-5, 5, 6)
    xx = np.linspace(-5, 5, 501)
    y_original = [1 / (1 + i * i) for i in xx]
    y_piecewise_linear = []
    y_lag_p5 = []
    y_lag_p10 = []
    for i in xx:
        y_piecewise_linear.append(piecewise_linear(f, xs_10, i))
        y_lag_p5.append(lagrange(f, xs_5, i))
        y_lag_p10.append(lagrange(f, xs_10, i))
    plt.plot(xx, y_original)
    plt.plot(xx, y_piecewise_linear)
    plt.plot(xx, y_lag_p5)
    plt.plot(xx, y_lag_p10)
    plt.legend(
        ["Original", "Piecewise Linear", "Lagrange: p5", "Lagrange: p10"])
    plt.show()


main()

# %%
