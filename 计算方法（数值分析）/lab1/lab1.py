import ast
import math
import numpy as np
# from lab1.interpolation import lagrange, newtown, piecewise_linear
from interpolation import lagrange, newtown, piecewise_linear


def main():
    problem1()
    print()
    problem2()


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
        print(x, true_val, la, pl, true_val - la, true_val - pl, sep="\t")


def problem2():
    xs = ast.literal_eval(input("输入数据点集（x）："))
    pred = ast.literal_eval(input("输入预测点："))

    f = lambda x: math.sqrt(x)
    print("X\ty(精确值)\ty(牛顿插值)\t误差")
    for x in pred:
        true_val = f(x)
        nt = newtown(f, xs, x)
        print(x, true_val, nt, true_val - nt, sep="\t")


main()
