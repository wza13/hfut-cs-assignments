# %%
import math
import matplotlib.pyplot as plt
# from lab3.euler import euler, improved_euler
# from lab3.rung_kutta import rung_kutta
from euler import euler, improved_euler
from rung_kutta import rung_kutta


def main():
    dy = lambda x, y: y - 2 * x / y
    y = lambda x: math.sqrt(1 + 2 * x)
    x0 = 0
    y0 = 1
    n = 40
    h = 0.1

    x, y_e = euler(dy, x0, y0, n, h)
    x, y_i_e = improved_euler(dy, x0, y0, n, h)
    x, y_r_k = rung_kutta(dy, x0, y0, n, h)
    y_true = [y(xi) for xi in x]

    print("x\t\ty(4阶龙格)\ty(改进)\t\ty(欧拉)\t\ty(精确)")
    for i in range(10 if len(x) > 10 else len(x)):
        print(format(x[i], '.6f'),
              format(y_r_k[i], '.6f'),
              format(y_i_e[i], '.6f'),
              format(y_e[i], '.6f'),
              format(y_true[i], '.6f'),
              sep="\t")

    plt.plot(x, y_true)
    plt.plot(x, y_e)
    plt.plot(x, y_i_e)
    plt.plot(x, y_r_k)
    plt.legend(["Original", "Euler", "Improve Euler", "Rung Kutta"])
    plt.show()

    n = 20
    h = 0.2
    x, y_e = euler(dy, x0, y0, n, h)
    x, y_i_e = improved_euler(dy, x0, y0, n, h)
    x, y_r_k = rung_kutta(dy, x0, y0, n, h)
    y_true = [y(xi) for xi in x]
    plt.plot(x, y_true)
    plt.plot(x, y_e)
    plt.plot(x, y_i_e)
    plt.plot(x, y_r_k)
    plt.legend(["Original", "Euler", "Improve Euler", "Rung Kutta"])
    plt.show()

    n = 10
    h = 0.4
    x, y_e = euler(dy, x0, y0, n, h)
    x, y_i_e = improved_euler(dy, x0, y0, n, h)
    x, y_r_k = rung_kutta(dy, x0, y0, n, h)
    y_true = [y(xi) for xi in x]
    plt.plot(x, y_true)
    plt.plot(x, y_e)
    plt.plot(x, y_i_e)
    plt.plot(x, y_r_k)
    plt.legend(["Original", "Euler", "Improve Euler", "Rung Kutta"])
    plt.show()


main()

# Some other functions in written homework
# dy = lambda x, y: 1 / (1 + x * x) - 2 * y * y
# y = lambda x: x / (1 + x * x)
# x0 = 0
# y0 = 0
# n = 10
# h = 0.1
# dy = lambda x, y: 8 - 3 * y
# y = lambda x: 0
# x0 = 0
# y0 = 2
# n = 2
# h = 0.2
# dy = lambda x, y: x + 1 - y
# y = lambda x: x + pow(math.e, 0 - x)
# x0 = 0
# y0 = 1
# n = 10
# h = 0.4

# %%
