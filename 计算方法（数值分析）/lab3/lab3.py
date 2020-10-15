# from lab3.euler import euler, improved_euler
# from lab3.rung_kutta import rung_kutta
from euler import euler, improved_euler
from rung_kutta import rung_kutta


def main():
    dy = lambda x, y: y - 2 * x / y
    x, y_e = euler(dy, 0, 1, 10, 0.1)
    x, y_i_e = improved_euler(dy, 0, 1, 10, 0.1)
    x, y_r_k = rung_kutta(dy, 0, 1, 10, 0.1)

    print("x\t\ty(4阶龙格)\ty(改进)\t\ty(欧拉)\t\ty(精确)")
    for i in range(len(x)):
        print(format(x[i], '.6f'),
              format(y_r_k[i], '.6f'),
              format(y_i_e[i], '.6f'),
              format(y_e[i], '.6f'),
              sep="\t")


main()
